-- ============================================================================
-- F11 - Anulacion de Facturas (workflow de aprobacion)
-- ============================================================================
-- Implementa la Feature 11 de PLAN_ANULACION_FACTURAS.md:
--   1. Schema changes en COMPROBANTES: columnas de auditoria + CKs
--      (CK_COMPROBANTES_ESTADO, CK_COMPROBANTES_AUDIT)
--   2. Extender CK_CXC_ESTADO y CK_CCD_ESTADO con 'ANULADA'
--   3. Reescribir FN_PUEDE_TRANSICION_OV: permitir FACTURADO -> APROBADO
--   4. TRG_OV_VALIDA_REVERSO_FACT: guarda BEFORE UPDATE en ORDENES_VENTA
--      que solo permite FACTURADO -> APROBADO si existe COMPROBANTE en ESTADO='N'
--   5. PRC_SOLICITAR_ANULACION: A -> P (validaciones de ventana + cuotas)
--   6. PRC_APROBAR_ANULACION: P -> N (reversiones atomicas)
--   7. PRC_RECHAZAR_ANULACION: P -> A (con motivo de rechazo)
--   8. V_ANULACIONES_FACTURAS: vista para P120
--
-- Idempotente: re-correrlo es no-op.
--
-- Pre-requisitos: F8_facturacion.sql y F9_cobros.sql aplicados.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: @db/F11_anulacion_facturas.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == F11.1 Pre-check (F8 + F9 aplicados) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='MOVIMIENTOS_CAJA';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20910,'F8 no aplicado: falta MOVIMIENTOS_CAJA.');
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_COBRAR_CUOTA'
     AND object_type='FUNCTION' AND status='VALID';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20911,'F9 no aplicado: falta FN_COBRAR_CUOTA.');
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_CAJA_ABIERTA_USUARIO'
     AND object_type='FUNCTION' AND status='VALID';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20912,'F8 no aplicado o invalido: falta FN_CAJA_ABIERTA_USUARIO.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F11.2 Agregar columnas de auditoria a COMPROBANTES ==
DECLARE
  PROCEDURE add_col(p_col VARCHAR2, p_ddl VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name='COMPROBANTES' AND column_name=p_col;
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.COMPROBANTES ADD ('||p_ddl||')';
      DBMS_OUTPUT.PUT_LINE('  + '||p_col||' agregada');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  = '||p_col||' ya existe');
    END IF;
  END;
BEGIN
  add_col('MOTIVO_ANULACION', 'MOTIVO_ANULACION VARCHAR2(500)');
  add_col('USUARIO_SOLICITA', 'USUARIO_SOLICITA VARCHAR2(60)');
  add_col('FECHA_SOLICITUD',  'FECHA_SOLICITUD DATE');
  add_col('USUARIO_APRUEBA',  'USUARIO_APRUEBA VARCHAR2(60)');
  add_col('FECHA_RESOLUCION', 'FECHA_RESOLUCION DATE');
  add_col('MOTIVO_RECHAZO',   'MOTIVO_RECHAZO VARCHAR2(500)');
END;
/

prompt == F11.3 CK_COMPROBANTES_ESTADO + CK_COMPROBANTES_AUDIT ==
DECLARE
  v_cnt PLS_INTEGER;
  PROCEDURE drop_ck(p_name VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_constraints
     WHERE owner='WKSP_WORKPLACE' AND constraint_name=p_name;
    IF v_cnt > 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.COMPROBANTES DROP CONSTRAINT '||p_name;
      DBMS_OUTPUT.PUT_LINE('  - '||p_name||' dropeada (recreacion)');
    END IF;
  END;
BEGIN
  drop_ck('CK_COMPROBANTES_ESTADO');
  drop_ck('CK_COMPROBANTES_AUDIT');

  EXECUTE IMMEDIATE q'[
    ALTER TABLE WKSP_WORKPLACE.COMPROBANTES ADD CONSTRAINT CK_COMPROBANTES_ESTADO
      CHECK (ESTADO IN ('A','P','N'))
  ]';
  DBMS_OUTPUT.PUT_LINE('  + CK_COMPROBANTES_ESTADO creada (A/P/N)');

  EXECUTE IMMEDIATE q'[
    ALTER TABLE WKSP_WORKPLACE.COMPROBANTES ADD CONSTRAINT CK_COMPROBANTES_AUDIT
      CHECK (
        ESTADO = 'A'
        OR (ESTADO = 'P'
            AND USUARIO_SOLICITA IS NOT NULL
            AND MOTIVO_ANULACION IS NOT NULL
            AND FECHA_SOLICITUD IS NOT NULL)
        OR (ESTADO = 'N'
            AND USUARIO_APRUEBA IS NOT NULL
            AND FECHA_RESOLUCION IS NOT NULL)
      )
  ]';
  DBMS_OUTPUT.PUT_LINE('  + CK_COMPROBANTES_AUDIT creada');
END;
/

prompt == F11.4 Extender CK_CXC_ESTADO y CK_CCD_ESTADO con 'ANULADA' ==
DECLARE
  v_cnt PLS_INTEGER;
  PROCEDURE drop_ck(p_table VARCHAR2, p_name VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_constraints
     WHERE owner='WKSP_WORKPLACE' AND constraint_name=p_name;
    IF v_cnt > 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.'||p_table||' DROP CONSTRAINT '||p_name;
      DBMS_OUTPUT.PUT_LINE('  - '||p_name||' dropeada (recreacion)');
    END IF;
  END;
BEGIN
  drop_ck('CUENTAS_COBRAR',     'CK_CXC_ESTADO');
  drop_ck('CUENTAS_COBRAR_DET', 'CK_CCD_ESTADO');

  EXECUTE IMMEDIATE q'[
    ALTER TABLE WKSP_WORKPLACE.CUENTAS_COBRAR ADD CONSTRAINT CK_CXC_ESTADO
      CHECK (ESTADO IN ('PENDIENTE','PAGADA','ANULADA'))
  ]';
  DBMS_OUTPUT.PUT_LINE('  + CK_CXC_ESTADO creada (+ANULADA)');

  EXECUTE IMMEDIATE q'[
    ALTER TABLE WKSP_WORKPLACE.CUENTAS_COBRAR_DET ADD CONSTRAINT CK_CCD_ESTADO
      CHECK (ESTADO IN ('PENDIENTE','PAGADA','VENCIDA','ANULADA'))
  ]';
  DBMS_OUTPUT.PUT_LINE('  + CK_CCD_ESTADO creada (+ANULADA)');
END;
/

prompt == F11.5 Reescribir FN_PUEDE_TRANSICION_OV (FACTURADO -> APROBADO permitido) ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_PUEDE_TRANSICION_OV (
  p_actual  IN VARCHAR2,
  p_destino IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
  RETURN CASE
    WHEN p_actual = 'PENDIENTE' AND p_destino IN ('APROBADO','ANULADO','VENCIDO') THEN 'S'
    WHEN p_actual = 'APROBADO'  AND p_destino IN ('FACTURADO','ANULADO')          THEN 'S'
    WHEN p_actual = 'FACTURADO' AND p_destino = 'APROBADO'                        THEN 'S'
    ELSE 'N'
  END;
END;
/

prompt == F11.6 TRG_OV_VALIDA_REVERSO_FACT (guarda FACTURADO -> APROBADO solo con factura ANULADA) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_OV_VALIDA_REVERSO_FACT
BEFORE UPDATE OF ESTADO ON WKSP_WORKPLACE.ORDENES_VENTA
FOR EACH ROW
WHEN (OLD.ESTADO = 'FACTURADO' AND NEW.ESTADO = 'APROBADO')
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt
    FROM WKSP_WORKPLACE.COMPROBANTES
   WHERE ID_ORDEN_VENTA = :NEW.ID_ORDEN
     AND ESTADO = 'N';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(
      -20920,
      'No se puede revertir el presupuesto #'||:NEW.ID_ORDEN||' de FACTURADO a APROBADO '
      ||'sin una factura asociada en estado ANULADO. Use PRC_APROBAR_ANULACION.'
    );
  END IF;
END;
/

prompt == F11.7 PRC_SOLICITAR_ANULACION (ESTADO A -> P) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_SOLICITAR_ANULACION (
  p_id_comprobante IN NUMBER,
  p_motivo         IN VARCHAR2,
  p_usuario        IN VARCHAR2
) IS
  v_c        WKSP_WORKPLACE.COMPROBANTES%ROWTYPE;
  v_cuotas_pagadas PLS_INTEGER;
BEGIN
  IF p_motivo IS NULL OR LENGTH(TRIM(p_motivo)) < 10 THEN
    RAISE_APPLICATION_ERROR(-20930, 'El motivo de anulacion debe tener al menos 10 caracteres.');
  END IF;
  IF p_usuario IS NULL THEN
    RAISE_APPLICATION_ERROR(-20931, 'Usuario solicitante requerido.');
  END IF;

  SELECT * INTO v_c
    FROM WKSP_WORKPLACE.COMPROBANTES
   WHERE ID_COMPROBANTE = p_id_comprobante
   FOR UPDATE;

  IF v_c.ESTADO <> 'A' THEN
    RAISE_APPLICATION_ERROR(-20932,
      'La factura #'||v_c.NRO_COMPROBANTE||' no esta activa (ESTADO='||v_c.ESTADO||'). '
      ||'Solo facturas en estado A pueden solicitar anulacion.');
  END IF;

  IF TRUNC(v_c.FECHA, 'MM') <> TRUNC(SYSDATE, 'MM') THEN
    RAISE_APPLICATION_ERROR(-20933,
      'Fuera de ventana: la factura es del mes '
      ||TO_CHAR(v_c.FECHA,'MM/YYYY')||' y hoy es '||TO_CHAR(SYSDATE,'MM/YYYY')||'. '
      ||'Solo se puede anular dentro del mismo mes calendario.');
  END IF;

  IF v_c.FORMA_PAGO = '1' THEN
    SELECT COUNT(*) INTO v_cuotas_pagadas
      FROM WKSP_WORKPLACE.CUENTAS_COBRAR     cxc
      JOIN WKSP_WORKPLACE.CUENTAS_COBRAR_DET ccd ON ccd.ID_CXC = cxc.ID_CXC
     WHERE cxc.ID_COMPROBANTE = p_id_comprobante
       AND ccd.ESTADO = 'PAGADA';
    IF v_cuotas_pagadas > 0 THEN
      RAISE_APPLICATION_ERROR(-20934,
        'No se puede anular: hay '||v_cuotas_pagadas||' cuota(s) cobrada(s). '
        ||'Revierta los cobros primero.');
    END IF;
  END IF;

  UPDATE WKSP_WORKPLACE.COMPROBANTES
     SET ESTADO           = 'P',
         MOTIVO_ANULACION = TRIM(p_motivo),
         USUARIO_SOLICITA = p_usuario,
         FECHA_SOLICITUD  = SYSDATE,
         USUARIO_APRUEBA  = NULL,
         FECHA_RESOLUCION = NULL,
         MOTIVO_RECHAZO   = NULL
   WHERE ID_COMPROBANTE = p_id_comprobante;
END;
/

prompt == F11.8 PRC_APROBAR_ANULACION (ESTADO P -> N + reversiones) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_APROBAR_ANULACION (
  p_id_comprobante IN NUMBER,
  p_usuario        IN VARCHAR2
) IS
  v_c          WKSP_WORKPLACE.COMPROBANTES%ROWTYPE;
  v_id_caja    NUMBER;
  v_cuotas_pagadas PLS_INTEGER;
  v_mov_origen NUMBER;
  v_id_nuevo_mov NUMBER;
BEGIN
  IF p_usuario IS NULL THEN
    RAISE_APPLICATION_ERROR(-20940, 'Usuario aprobador requerido.');
  END IF;

  SELECT * INTO v_c
    FROM WKSP_WORKPLACE.COMPROBANTES
   WHERE ID_COMPROBANTE = p_id_comprobante
   FOR UPDATE;

  IF v_c.ESTADO <> 'P' THEN
    RAISE_APPLICATION_ERROR(-20941,
      'La factura #'||v_c.NRO_COMPROBANTE||' no esta pendiente de anulacion (ESTADO='||v_c.ESTADO||').');
  END IF;

  IF TRUNC(v_c.FECHA, 'MM') <> TRUNC(SYSDATE, 'MM') THEN
    RAISE_APPLICATION_ERROR(-20942,
      'Fuera de ventana: la factura es del mes '||TO_CHAR(v_c.FECHA,'MM/YYYY')
      ||' y hoy es '||TO_CHAR(SYSDATE,'MM/YYYY')||'.');
  END IF;

  IF v_c.FORMA_PAGO = '1' THEN
    SELECT COUNT(*) INTO v_cuotas_pagadas
      FROM WKSP_WORKPLACE.CUENTAS_COBRAR     cxc
      JOIN WKSP_WORKPLACE.CUENTAS_COBRAR_DET ccd ON ccd.ID_CXC = cxc.ID_CXC
     WHERE cxc.ID_COMPROBANTE = p_id_comprobante
       AND ccd.ESTADO = 'PAGADA';
    IF v_cuotas_pagadas > 0 THEN
      RAISE_APPLICATION_ERROR(-20943,
        'No se puede aprobar la anulacion: aparecieron '||v_cuotas_pagadas||
        ' cuota(s) cobrada(s) desde la solicitud.');
    END IF;
  END IF;

  -- 1) Reverso de stock: una ENTRADA por cada linea de la factura
  FOR rec IN (
    SELECT dc.ID_PRODUCTO, dc.CANTIDAD
      FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE dc
     WHERE dc.ID_COMPROBANTE = p_id_comprobante
  ) LOOP
    INSERT INTO WKSP_WORKPLACE.MOVIMIENTOS_STOCK (
      ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
      FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION, USUARIO, FECHA, HORA
    ) VALUES (
      rec.ID_PRODUCTO, v_c.ID_OFICINA, 'ENTRADA', rec.CANTIDAD,
      SYSDATE,
      'ANULACION_FACTURA#'||v_c.NRO_COMPROBANTE,
      'Reversion por anulacion factura '||v_c.NRO_COMPROBANTE,
      p_usuario, SYSDATE, TO_CHAR(SYSDATE,'HH24:MI:SS')
    );
  END LOOP;

  -- 2) Si es CONTADO (forma de pago != '1'): EGRESO de reversion en caja del aprobador
  IF NVL(v_c.FORMA_PAGO, 'x') <> '1' THEN
    v_id_caja := WKSP_WORKPLACE.FN_CAJA_ABIERTA_USUARIO(p_usuario);
    IF v_id_caja IS NULL THEN
      RAISE_APPLICATION_ERROR(-20944,
        'Para aprobar anulacion contado necesitas tener caja abierta. Abri caja primero (P65).');
    END IF;

    -- Buscar el INGRESO_VENTA original (solo para clonar el detalle de formas de pago)
    BEGIN
      SELECT ID_MOVIMIENTO INTO v_mov_origen
        FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA
       WHERE ID_COMPROBANTE = p_id_comprobante
         AND TIPO = 'INGRESO_VENTA'
         AND ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      v_mov_origen := NULL;
    END;

    INSERT INTO WKSP_WORKPLACE.MOVIMIENTOS_CAJA (
      ID_CLIENTE, ID_CAJA, FECHA, TOTAL_MONEDA_LOCAL, MONEDA,
      TIPO_CAMBIO, TOTAL_MONEDA_ORIGEN, ESTADO, OBSERVACION,
      TIPO, ID_COMPROBANTE, USUARIO
    ) VALUES (
      v_c.ID_CLIENTE, v_id_caja, SYSTIMESTAMP, v_c.TOTAL_MONEDA_LOCAL, v_c.MONEDA,
      v_c.TIPO_CAMBIO, v_c.TOTAL_MONEDA_ORIGEN, 'A',
      'Anulacion factura '||v_c.NRO_COMPROBANTE,
      'EGRESO', p_id_comprobante, p_usuario
    ) RETURNING ID_MOVIMIENTO INTO v_id_nuevo_mov;

    IF v_mov_origen IS NOT NULL THEN
      INSERT INTO WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA (
        ID_MOVIMIENTO, ID_FORMA_PAGO, MONTO_LOCAL, MONTO_ORIGEN, MONEDA,
        TIPO_CAMBIO, NRO_REFERENCIA, NRO_TARJETA, ID_METODO_PAGO
      )
      SELECT v_id_nuevo_mov, ID_FORMA_PAGO, MONTO_LOCAL, MONTO_ORIGEN, MONEDA,
             TIPO_CAMBIO, NRO_REFERENCIA, NRO_TARJETA, ID_METODO_PAGO
        FROM WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA
       WHERE ID_MOVIMIENTO = v_mov_origen;
    END IF;
  END IF;

  -- 3) CxC: marcar cuenta y cuotas como ANULADA
  IF v_c.FORMA_PAGO = '1' THEN
    UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR_DET
       SET ESTADO = 'ANULADA'
     WHERE ID_CXC IN (SELECT ID_CXC
                        FROM WKSP_WORKPLACE.CUENTAS_COBRAR
                       WHERE ID_COMPROBANTE = p_id_comprobante)
       AND ESTADO IN ('PENDIENTE','VENCIDA');

    UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR
       SET ESTADO = 'ANULADA',
           SALDO  = 0
     WHERE ID_COMPROBANTE = p_id_comprobante;
  END IF;

  -- 4) OV vuelve a APROBADO si la factura tenia origen presupuesto
  IF v_c.ID_ORDEN_VENTA IS NOT NULL THEN
    -- Cabecera de la factura: marcar ya 'N' para que el trigger TRG_OV_VALIDA_REVERSO_FACT pase
    UPDATE WKSP_WORKPLACE.COMPROBANTES
       SET ESTADO           = 'N',
           USUARIO_APRUEBA  = p_usuario,
           FECHA_RESOLUCION = SYSDATE
     WHERE ID_COMPROBANTE = p_id_comprobante;

    UPDATE WKSP_WORKPLACE.ORDENES_VENTA
       SET ESTADO = 'APROBADO'
     WHERE ID_ORDEN = v_c.ID_ORDEN_VENTA;
  ELSE
    UPDATE WKSP_WORKPLACE.COMPROBANTES
       SET ESTADO           = 'N',
           USUARIO_APRUEBA  = p_usuario,
           FECHA_RESOLUCION = SYSDATE
     WHERE ID_COMPROBANTE = p_id_comprobante;
  END IF;
END;
/

prompt == F11.9 PRC_RECHAZAR_ANULACION (ESTADO P -> A) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_RECHAZAR_ANULACION (
  p_id_comprobante IN NUMBER,
  p_motivo_rechazo IN VARCHAR2,
  p_usuario        IN VARCHAR2
) IS
  v_estado WKSP_WORKPLACE.COMPROBANTES.ESTADO%TYPE;
BEGIN
  IF p_motivo_rechazo IS NULL OR LENGTH(TRIM(p_motivo_rechazo)) < 10 THEN
    RAISE_APPLICATION_ERROR(-20950, 'El motivo de rechazo debe tener al menos 10 caracteres.');
  END IF;
  IF p_usuario IS NULL THEN
    RAISE_APPLICATION_ERROR(-20951, 'Usuario aprobador requerido.');
  END IF;

  SELECT ESTADO INTO v_estado
    FROM WKSP_WORKPLACE.COMPROBANTES
   WHERE ID_COMPROBANTE = p_id_comprobante
   FOR UPDATE;

  IF v_estado <> 'P' THEN
    RAISE_APPLICATION_ERROR(-20952,
      'La factura no esta pendiente de anulacion (ESTADO='||v_estado||').');
  END IF;

  UPDATE WKSP_WORKPLACE.COMPROBANTES
     SET ESTADO           = 'A',
         MOTIVO_RECHAZO   = TRIM(p_motivo_rechazo),
         USUARIO_APRUEBA  = p_usuario,
         FECHA_RESOLUCION = SYSDATE,
         MOTIVO_ANULACION = NULL,
         USUARIO_SOLICITA = NULL,
         FECHA_SOLICITUD  = NULL
   WHERE ID_COMPROBANTE = p_id_comprobante;
END;
/

prompt == F11.10 Vista V_ANULACIONES_FACTURAS ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_ANULACIONES_FACTURAS AS
SELECT c.ID_COMPROBANTE,
       c.NRO_COMPROBANTE,
       c.FECHA,
       c.TOTAL_MONEDA_LOCAL,
       c.MONEDA,
       c.ESTADO,
       c.FORMA_PAGO,
       c.MOTIVO_ANULACION,
       c.USUARIO_SOLICITA,
       c.FECHA_SOLICITUD,
       c.USUARIO_APRUEBA,
       c.FECHA_RESOLUCION,
       c.MOTIVO_RECHAZO,
       c.ID_CLIENTE,
       TRIM(REGEXP_REPLACE(
         TRIM(BOTH ' ' FROM
           NVL(p.PRIMER_NOMBRE,'')||' '||NVL(p.SEGUNDO_NOMBRE,'')||' '||
           NVL(p.PRIMER_APELLIDO,'')||' '||NVL(p.SEGUNDO_APELLIDO,'')
         ), ' +', ' ')) AS CLIENTE_NOMBRE,
       c.ID_OFICINA,
       o.DESCRIPCION AS OFICINA_NOMBRE
  FROM WKSP_WORKPLACE.COMPROBANTES c
  LEFT JOIN WKSP_WORKPLACE.PERSONAS p ON p.ID_PERSONA = c.ID_CLIENTE
  LEFT JOIN WKSP_WORKPLACE.OFICINAS o ON o.CODIGO_OFICINA = c.ID_OFICINA
 WHERE c.ESTADO IN ('P','N');
/

prompt == F11.11 Verificacion final ==
DECLARE
  v_cnt PLS_INTEGER;
  v_ok  BOOLEAN := TRUE;
  PROCEDURE check_obj(p_name VARCHAR2, p_type VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_objects
     WHERE owner='WKSP_WORKPLACE' AND object_name=p_name AND object_type=p_type AND status='VALID';
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK  '||RPAD(p_type,10)||' '||p_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL '||RPAD(p_type,10)||' '||p_name||' (count='||v_cnt||')');
      v_ok := FALSE;
    END IF;
  END;
  PROCEDURE check_col(p_col VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name='COMPROBANTES' AND column_name=p_col;
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK  COLUMN     COMPROBANTES.'||p_col);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL COLUMN     COMPROBANTES.'||p_col);
      v_ok := FALSE;
    END IF;
  END;
  PROCEDURE check_ck(p_name VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_constraints
     WHERE owner='WKSP_WORKPLACE' AND constraint_name=p_name AND constraint_type='C' AND status='ENABLED';
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK  CHECK      '||p_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL CHECK      '||p_name);
      v_ok := FALSE;
    END IF;
  END;
BEGIN
  check_col('MOTIVO_ANULACION');
  check_col('USUARIO_SOLICITA');
  check_col('FECHA_SOLICITUD');
  check_col('USUARIO_APRUEBA');
  check_col('FECHA_RESOLUCION');
  check_col('MOTIVO_RECHAZO');
  check_ck('CK_COMPROBANTES_ESTADO');
  check_ck('CK_COMPROBANTES_AUDIT');
  check_ck('CK_CXC_ESTADO');
  check_ck('CK_CCD_ESTADO');
  check_obj('FN_PUEDE_TRANSICION_OV',       'FUNCTION');
  check_obj('TRG_OV_VALIDA_REVERSO_FACT',   'TRIGGER');
  check_obj('PRC_SOLICITAR_ANULACION',      'PROCEDURE');
  check_obj('PRC_APROBAR_ANULACION',        'PROCEDURE');
  check_obj('PRC_RECHAZAR_ANULACION',       'PROCEDURE');
  check_obj('V_ANULACIONES_FACTURAS',       'VIEW');

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'F11 aplicado OK.');
  ELSE
    RAISE_APPLICATION_ERROR(-20999, 'F11 verificacion FAIL.');
  END IF;
END;
/

prompt == F11 - fin ==

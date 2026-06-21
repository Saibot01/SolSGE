-- ============================================================================
-- F14 - Nota de Credito Electronica (NCE) - workflow con aprobacion
-- ============================================================================
-- Implementa PLAN_NOTA_CREDITO.md. La NC es el camino fiscal para revertir/
-- ajustar una factura FUERA de la ventana de 48h del Evento de Cancelacion (F11),
-- o para devoluciones/descuentos parciales. A diferencia de F11, la NC NO anula
-- la factura: la factura sigue ESTADO='A' y la NC es un documento NUEVO (tipo
-- SIFEN 5, TIPO_COMPROBANTE='NC') que la credita total o parcialmente.
--
-- Decisiones (con el PO, ver plan §3):
--   1. Alcance total y parcial.
--   2. Workflow con aprobacion (SOLICITA -> APRUEBA / RECHAZA), patron F11.
--   3. La solicitud vive en staging (SOLICITUDES_NOTA_CREDITO + detalle); el
--      numero NC se reserva recien al APROBAR (no se quema si se rechaza).
--   4. Caja contado: EGRESO en la caja abierta del aprobador (espejo F11).
--   5. Credito: se reconcilia CxC + cuotas manteniendo el invariante
--      SALDO = Sum(MONTO_CUOTA de cuotas PENDIENTE/VENCIDA).
--   6. Stock condicional segun motivo (Devolucion 1,2 -> ENTRADA; resto -> no).
--   7. Factura origen queda ESTADO='A'.
--   8. FORMA_PAGO de la NC = NULL (no dispara TRG_INS_CUENTAS_COBRAR).
--
-- Vinculo a la factura: COMPROBANTES.ID_COMPROBANTE_ORIGEN (FK por ID, clave
-- confiable). El nro impreso del documento asociado se DERIVA por join (no se
-- duplica en ID_FAC_ORIGEN, que queda legacy).
--
-- Triggers de venta ya discriminan por tipo: insertar NC no mueve stock
-- (TRG_MOV_STOCK_DETALLE solo FA), no crea CxC (TRG_INS_CUENTAS_COBRAR solo
-- FORMA_PAGO='1'), no toca OV (TRG_FACTURA_ORDEN solo si ID_ORDEN_VENTA NOT NULL).
-- Todos los efectos de la NC son explicitos en PRC_APROBAR_NOTA_CREDITO.
--
-- Rango de error reservado: -20970 .. -20989.
-- Idempotente: re-correrlo es no-op.
-- Pre-requisitos: F8, F9, F11 y F11.2 (MOTIVOS_NOTA_CREDITO) aplicados.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db @db/F14_nota_credito.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F14.0 Pre-check (F8/F9/F11 + MOTIVOS_NOTA_CREDITO) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_OBTENER_COMPROBANTE'
     AND object_type='FUNCTION' AND status='VALID';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20970,'Falta FN_OBTENER_COMPROBANTE (F8).'); END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_CAJA_ABIERTA_USUARIO'
     AND object_type='FUNCTION' AND status='VALID';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20970,'Falta FN_CAJA_ABIERTA_USUARIO (F8).'); END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='MOTIVOS_NOTA_CREDITO';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20970,'Falta MOTIVOS_NOTA_CREDITO (F11.2).'); END IF;

  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F14.1 Limpieza de NC legacy malformadas (permiso PO 2026-06-17) ==
-- Las 3 NC de prueba (atadas a ID_ORDEN_VENTA, sin origen rastreable) se borran.
-- Predicado ID_ORDEN_VENTA IS NOT NULL: las NC del nuevo flujo nacen con NULL,
-- asi que este DELETE es idempotente y NUNCA toca una NC real.
DECLARE
  v_det PLS_INTEGER; v_cab PLS_INTEGER;
BEGIN
  DELETE FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE
   WHERE ID_COMPROBANTE IN (
     SELECT ID_COMPROBANTE FROM WKSP_WORKPLACE.COMPROBANTES
      WHERE TIPO_COMPROBANTE='NC' AND ID_ORDEN_VENTA IS NOT NULL);
  v_det := SQL%ROWCOUNT;
  DELETE FROM WKSP_WORKPLACE.COMPROBANTES
   WHERE TIPO_COMPROBANTE='NC' AND ID_ORDEN_VENTA IS NOT NULL;
  v_cab := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  - NC legacy borradas: '||v_cab||' cabeceras, '||v_det||' detalles');
END;
/

prompt == F14.2 Columnas nuevas en COMPROBANTES (COD_MOTIVO + ID_COMPROBANTE_ORIGEN) ==
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
  add_col('COD_MOTIVO',            'COD_MOTIVO NUMBER(2)');
  add_col('ID_COMPROBANTE_ORIGEN', 'ID_COMPROBANTE_ORIGEN NUMBER');
END;
/

prompt == F14.3 FKs + CK_NC_MOTIVO (ENABLE VALIDATE, sin filas NC residuales) ==
DECLARE
  v_cnt PLS_INTEGER;
  PROCEDURE add_fk(p_name VARCHAR2, p_ddl VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_constraints
     WHERE owner='WKSP_WORKPLACE' AND constraint_name=p_name;
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.COMPROBANTES ADD CONSTRAINT '||p_name||' '||p_ddl;
      DBMS_OUTPUT.PUT_LINE('  + '||p_name||' creada');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  = '||p_name||' ya existe');
    END IF;
  END;
BEGIN
  add_fk('FK_COMP_MOTIVO_NC',
    'FOREIGN KEY (COD_MOTIVO) REFERENCES WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO(COD_MOTIVO)');
  add_fk('FK_COMP_ORIGEN_NC',
    'FOREIGN KEY (ID_COMPROBANTE_ORIGEN) REFERENCES WKSP_WORKPLACE.COMPROBANTES(ID_COMPROBANTE)');

  SELECT COUNT(*) INTO v_cnt FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='CK_NC_MOTIVO';
  IF v_cnt > 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.COMPROBANTES DROP CONSTRAINT CK_NC_MOTIVO';
  END IF;
  EXECUTE IMMEDIATE q'[
    ALTER TABLE WKSP_WORKPLACE.COMPROBANTES ADD CONSTRAINT CK_NC_MOTIVO
      CHECK ( (TIPO_COMPROBANTE='NC' AND COD_MOTIVO IS NOT NULL)
              OR (TIPO_COMPROBANTE<>'NC' AND COD_MOTIVO IS NULL) )
      ENABLE VALIDATE ]';
  DBMS_OUTPUT.PUT_LINE('  + CK_NC_MOTIVO creada (ENABLE VALIDATE)');
END;
/

prompt == F14.4 Tabla SOLICITUDES_NOTA_CREDITO (staging cabecera) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='SOLICITUDES_NOTA_CREDITO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO (
        ID_SOLICITUD_NC       NUMBER GENERATED BY DEFAULT AS IDENTITY,
        ID_COMPROBANTE_ORIGEN NUMBER       NOT NULL,
        COD_MOTIVO            NUMBER(2)    NOT NULL,
        TIPO_NC               CHAR(1)      NOT NULL,
        DEVUELVE_STOCK        CHAR(1)      NOT NULL,
        OBSERVACION           VARCHAR2(500),
        ESTADO                CHAR(1) DEFAULT 'P' NOT NULL,
        USUARIO_SOLICITA      VARCHAR2(60) NOT NULL,
        FECHA_SOLICITUD       DATE         NOT NULL,
        USUARIO_APRUEBA       VARCHAR2(60),
        FECHA_RESOLUCION      DATE,
        MOTIVO_RECHAZO        VARCHAR2(500),
        ID_NC_GENERADA        NUMBER,
        CONSTRAINT PK_SOLICITUD_NC PRIMARY KEY (ID_SOLICITUD_NC),
        CONSTRAINT FK_SOLNC_FACTURA FOREIGN KEY (ID_COMPROBANTE_ORIGEN)
          REFERENCES WKSP_WORKPLACE.COMPROBANTES(ID_COMPROBANTE),
        CONSTRAINT FK_SOLNC_MOTIVO FOREIGN KEY (COD_MOTIVO)
          REFERENCES WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO(COD_MOTIVO),
        CONSTRAINT FK_SOLNC_NC FOREIGN KEY (ID_NC_GENERADA)
          REFERENCES WKSP_WORKPLACE.COMPROBANTES(ID_COMPROBANTE),
        CONSTRAINT CK_SOLNC_TIPO   CHECK (TIPO_NC IN ('T','P')),
        CONSTRAINT CK_SOLNC_STOCK  CHECK (DEVUELVE_STOCK IN ('S','N')),
        CONSTRAINT CK_SOLNC_ESTADO CHECK (ESTADO IN ('P','A','R'))
      )]';
    DBMS_OUTPUT.PUT_LINE('  + Tabla SOLICITUDES_NOTA_CREDITO creada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = SOLICITUDES_NOTA_CREDITO ya existe');
  END IF;
END;
/

prompt == F14.5 Tabla SOLICITUD_NC_DETALLE (lineas a acreditar) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='SOLICITUD_NC_DETALLE';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE WKSP_WORKPLACE.SOLICITUD_NC_DETALLE (
        ID_SOL_NC_DET     NUMBER GENERATED BY DEFAULT AS IDENTITY,
        ID_SOLICITUD_NC   NUMBER       NOT NULL,
        ID_DETALLE_ORIGEN NUMBER       NOT NULL,
        ID_PRODUCTO       NUMBER       NOT NULL,
        CANTIDAD          NUMBER       NOT NULL,
        PRECIO_UNITARIO   NUMBER(12,2),
        PORCENTAJE_IVA    NUMBER(5,2),
        CONSTRAINT PK_SOL_NC_DET PRIMARY KEY (ID_SOL_NC_DET),
        CONSTRAINT FK_SOLNCDET_CAB FOREIGN KEY (ID_SOLICITUD_NC)
          REFERENCES WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO(ID_SOLICITUD_NC) ON DELETE CASCADE,
        CONSTRAINT FK_SOLNCDET_DET FOREIGN KEY (ID_DETALLE_ORIGEN)
          REFERENCES WKSP_WORKPLACE.DETALLE_COMPROBANTE(ID_DETALLE),
        CONSTRAINT CK_SOLNCDET_CANT CHECK (CANTIDAD > 0)
      )]';
    DBMS_OUTPUT.PUT_LINE('  + Tabla SOLICITUD_NC_DETALLE creada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = SOLICITUD_NC_DETALLE ya existe');
  END IF;
END;
/

prompt == F14.6 FN_CANT_ACREDITABLE (cantidad disponible para NC en una linea) ==
-- Cantidad facturada en la linea - Sum(cantidades ya acreditadas por NC aprobadas
-- sobre esa misma linea origen).
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_CANT_ACREDITABLE (
  p_id_detalle_origen IN NUMBER
) RETURN NUMBER IS
  v_facturada   NUMBER;
  v_acreditada  NUMBER;
BEGIN
  SELECT CANTIDAD INTO v_facturada
    FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE
   WHERE ID_DETALLE = p_id_detalle_origen;

  SELECT NVL(SUM(d.CANTIDAD),0) INTO v_acreditada
    FROM WKSP_WORKPLACE.SOLICITUD_NC_DETALLE d
    JOIN WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO s ON s.ID_SOLICITUD_NC = d.ID_SOLICITUD_NC
   WHERE d.ID_DETALLE_ORIGEN = p_id_detalle_origen
     AND s.ESTADO = 'A';

  RETURN v_facturada - v_acreditada;
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN 0;
END;
/
show errors function FN_CANT_ACREDITABLE

prompt == F14.7 FN_NC_ELEGIBLE (bloqueos duros; NULL = se puede emitir NC) ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_NC_ELEGIBLE (
  p_id_factura IN NUMBER
) RETURN VARCHAR2 IS
  v_c        WKSP_WORKPLACE.COMPROBANTES%ROWTYPE;
  v_acred    NUMBER := 0;
  v_total    NUMBER := 0;
BEGIN
  BEGIN
    SELECT * INTO v_c FROM WKSP_WORKPLACE.COMPROBANTES WHERE ID_COMPROBANTE = p_id_factura;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN 'La factura indicada no existe.';
  END;

  IF v_c.TIPO_COMPROBANTE <> 'FA' THEN
    RETURN 'Solo se puede emitir Nota de Credito sobre una factura (FA).';
  END IF;
  IF v_c.ESTADO = 'N' THEN
    RETURN 'La factura esta anulada; no corresponde Nota de Credito.';
  END IF;
  IF v_c.ESTADO <> 'A' THEN
    RETURN 'La factura no esta activa (ESTADO='||v_c.ESTADO||').';
  END IF;

  -- Ya acreditada al 100%?
  SELECT NVL(SUM(CANTIDAD),0) INTO v_total
    FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE WHERE ID_COMPROBANTE = p_id_factura;
  SELECT NVL(SUM(d.CANTIDAD),0) INTO v_acred
    FROM WKSP_WORKPLACE.SOLICITUD_NC_DETALLE d
    JOIN WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO s ON s.ID_SOLICITUD_NC = d.ID_SOLICITUD_NC
   WHERE s.ESTADO='A'
     AND d.ID_DETALLE_ORIGEN IN (SELECT ID_DETALLE FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE
                                  WHERE ID_COMPROBANTE = p_id_factura);
  IF v_total > 0 AND v_acred >= v_total THEN
    RETURN 'La factura ya fue acreditada en su totalidad por Notas de Credito previas.';
  END IF;

  RETURN NULL; -- habilitada
END;
/
show errors function FN_NC_ELEGIBLE

prompt == F14.8 FN_NC_AVISO (advertencia blanda; NULL = sin aviso) ==
-- No bloquea: si la factura aun esta dentro del plazo de 48h sugiere usar la
-- Anulacion (F11) en vez de la NC.
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_NC_AVISO (
  p_id_factura IN NUMBER
) RETURN VARCHAR2 IS
  v_c      WKSP_WORKPLACE.COMPROBANTES%ROWTYPE;
  v_horas  NUMBER;
  v_emis   TIMESTAMP;
BEGIN
  BEGIN
    SELECT * INTO v_c FROM WKSP_WORKPLACE.COMPROBANTES WHERE ID_COMPROBANTE = p_id_factura;
  EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL; END;

  v_horas := NVL(TO_NUMBER(WKSP_WORKPLACE.FN_GET_PARAMETRO('HORAS_LIMITE_CANCELACION','NUMERICO')),48);
  v_emis  := NVL(v_c.FECHA_HORA_EMISION, CAST(v_c.FECHA AS TIMESTAMP));
  IF v_emis >= LOCALTIMESTAMP - NUMTODSINTERVAL(v_horas,'HOUR') THEN
    RETURN 'Esta factura aun esta dentro del plazo de '||v_horas||'h: podes Anularla (F11). '
         ||'La Nota de Credito es para ajustes/devoluciones fuera de ese plazo o parciales.';
  END IF;
  RETURN NULL;
END;
/
show errors function FN_NC_AVISO

prompt == F14.9 PRC_SOLICITAR_NOTA_CREDITO (crea cabecera 'P'; total auto-puebla lineas) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_SOLICITAR_NOTA_CREDITO (
  p_id_factura     IN  NUMBER,
  p_cod_motivo     IN  NUMBER,
  p_tipo_nc        IN  VARCHAR2,          -- 'T' total / 'P' parcial
  p_observacion    IN  VARCHAR2,
  p_usuario        IN  VARCHAR2,
  p_id_solicitud   OUT NUMBER
) IS
  v_bloqueo  VARCHAR2(500);
  v_devstock CHAR(1);
  v_cnt      PLS_INTEGER;
  v_acred    NUMBER;
BEGIN
  IF p_usuario IS NULL THEN
    RAISE_APPLICATION_ERROR(-20971,'Usuario solicitante requerido.');
  END IF;
  IF p_tipo_nc NOT IN ('T','P') THEN
    RAISE_APPLICATION_ERROR(-20972,'Tipo de NC invalido (T=total / P=parcial).');
  END IF;

  v_bloqueo := WKSP_WORKPLACE.FN_NC_ELEGIBLE(p_id_factura);
  IF v_bloqueo IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20973, v_bloqueo);
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO
   WHERE COD_MOTIVO = p_cod_motivo AND ACTIVO='S';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20974,'Motivo de NC inexistente o inactivo.');
  END IF;

  -- Devolucion de stock condicional al motivo (1 Dev.+ajuste, 2 Devolucion)
  v_devstock := CASE WHEN p_cod_motivo IN (1,2) THEN 'S' ELSE 'N' END;

  INSERT INTO WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO (
    ID_COMPROBANTE_ORIGEN, COD_MOTIVO, TIPO_NC, DEVUELVE_STOCK, OBSERVACION,
    ESTADO, USUARIO_SOLICITA, FECHA_SOLICITUD
  ) VALUES (
    p_id_factura, p_cod_motivo, p_tipo_nc, v_devstock, p_observacion,
    'P', p_usuario, SYSDATE
  ) RETURNING ID_SOLICITUD_NC INTO p_id_solicitud;

  -- Total: poblar automaticamente todas las lineas con la cantidad acreditable.
  -- Loop fila por fila (NO INSERT..SELECT): FN_CANT_ACREDITABLE lee
  -- SOLICITUD_NC_DETALLE, que es la tabla donde insertamos -> un INSERT..SELECT
  -- dispararia ORA-04091 (tabla mutante). En statements separados no aplica.
  IF p_tipo_nc = 'T' THEN
    FOR dc IN (SELECT ID_DETALLE, ID_PRODUCTO, PRECIO_UNITARIO, PORCENTAJE_IVA
                 FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE
                WHERE ID_COMPROBANTE = p_id_factura) LOOP
      v_acred := WKSP_WORKPLACE.FN_CANT_ACREDITABLE(dc.ID_DETALLE);
      IF v_acred > 0 THEN
        INSERT INTO WKSP_WORKPLACE.SOLICITUD_NC_DETALLE (
          ID_SOLICITUD_NC, ID_DETALLE_ORIGEN, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, PORCENTAJE_IVA
        ) VALUES (
          p_id_solicitud, dc.ID_DETALLE, dc.ID_PRODUCTO, v_acred, dc.PRECIO_UNITARIO, dc.PORCENTAJE_IVA
        );
      END IF;
    END LOOP;
  END IF;
  -- Parcial: las lineas las inserta la UI (IG) y se validan al aprobar.
END;
/
show errors procedure PRC_SOLICITAR_NOTA_CREDITO

prompt == F14.10 PRC_VALIDAR_SOLICITUD_NC (cantidades acreditables; >0 lineas) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_VALIDAR_SOLICITUD_NC (
  p_id_solicitud IN NUMBER
) IS
  v_lineas PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_lineas
    FROM WKSP_WORKPLACE.SOLICITUD_NC_DETALLE WHERE ID_SOLICITUD_NC = p_id_solicitud;
  IF v_lineas = 0 THEN
    RAISE_APPLICATION_ERROR(-20975,'La solicitud de NC no tiene lineas a acreditar.');
  END IF;

  FOR r IN (SELECT d.CANTIDAD, NVL(d.PRECIO_UNITARIO, oc.PRECIO_UNITARIO) AS precio_nc,
                   oc.PRECIO_UNITARIO AS precio_fac,
                   WKSP_WORKPLACE.FN_CANT_ACREDITABLE(d.ID_DETALLE_ORIGEN) AS acred
              FROM WKSP_WORKPLACE.SOLICITUD_NC_DETALLE d
              JOIN WKSP_WORKPLACE.DETALLE_COMPROBANTE oc ON oc.ID_DETALLE = d.ID_DETALLE_ORIGEN
             WHERE d.ID_SOLICITUD_NC = p_id_solicitud) LOOP
    IF r.CANTIDAD <= 0 THEN
      RAISE_APPLICATION_ERROR(-20976,'Cantidad invalida en una linea de la NC.');
    END IF;
    IF r.CANTIDAD > r.acred THEN
      RAISE_APPLICATION_ERROR(-20977,
        'La cantidad a acreditar ('||r.CANTIDAD||') excede lo disponible ('||r.acred||
        ') en una de las lineas. Otra NC pudo haberla consumido.');
    END IF;
    -- Tope SIFEN: no se puede acreditar a un precio mayor al facturado.
    IF r.precio_nc > r.precio_fac THEN
      RAISE_APPLICATION_ERROR(-20989,
        'El precio a acreditar ('||r.precio_nc||') supera el precio facturado ('||r.precio_fac||
        ') en una de las lineas.');
    END IF;
  END LOOP;
END;
/
show errors procedure PRC_VALIDAR_SOLICITUD_NC

prompt == F14.11 PRC_APROBAR_NOTA_CREDITO (materializa NC + efectos) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_APROBAR_NOTA_CREDITO (
  p_id_solicitud IN NUMBER,
  p_usuario      IN VARCHAR2
) IS
  v_s        WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO%ROWTYPE;
  v_f        WKSP_WORKPLACE.COMPROBANTES%ROWTYPE;   -- factura origen
  v_cxc      WKSP_WORKPLACE.CUENTAS_COBRAR%ROWTYPE;
  v_id_talon NUMBER;
  v_nro_nc   VARCHAR2(20);
  v_id_nc    NUMBER;
  v_total    NUMBER := 0;
  v_iva5     NUMBER := 0;
  v_iva10    NUMBER := 0;
  v_id_caja  NUMBER;
  v_fec_caja DATE;
  v_rem      NUMBER;
BEGIN
  IF p_usuario IS NULL THEN
    RAISE_APPLICATION_ERROR(-20978,'Usuario aprobador requerido.');
  END IF;

  SELECT * INTO v_s FROM WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO
   WHERE ID_SOLICITUD_NC = p_id_solicitud FOR UPDATE;
  IF v_s.ESTADO <> 'P' THEN
    RAISE_APPLICATION_ERROR(-20979,'La solicitud no esta pendiente (ESTADO='||v_s.ESTADO||').');
  END IF;

  -- Re-validar lineas (otra NC pudo aprobarse en el medio)
  WKSP_WORKPLACE.PRC_VALIDAR_SOLICITUD_NC(p_id_solicitud);

  SELECT * INTO v_f FROM WKSP_WORKPLACE.COMPROBANTES
   WHERE ID_COMPROBANTE = v_s.ID_COMPROBANTE_ORIGEN FOR UPDATE;

  -- Talonario NC de la oficina de la factura
  BEGIN
    SELECT MIN(ID_TALONARIO) INTO v_id_talon
      FROM WKSP_WORKPLACE.TALONARIOS
     WHERE TIPO_COMPROBANTE='NC' AND ACTIVO='S' AND ID_OFICINA = v_f.ID_OFICINA
       AND TRUNC(SYSDATE) BETWEEN FECHA_INICIO AND FECHA_FIN
       AND NRO_ACTUAL < NRO_FINAL;
  END;
  IF v_id_talon IS NULL THEN
    RAISE_APPLICATION_ERROR(-20980,
      'No hay talonario NC activo/vigente para la oficina '||v_f.ID_OFICINA||'.');
  END IF;

  -- Totales de la NC desde las lineas acreditadas (IVA incluido, PYG)
  SELECT NVL(SUM(d.CANTIDAD*d.PRECIO_UNITARIO),0),
         NVL(SUM(CASE WHEN d.PORCENTAJE_IVA=5  THEN d.CANTIDAD*d.PRECIO_UNITARIO/21 END),0),
         NVL(SUM(CASE WHEN d.PORCENTAJE_IVA=10 THEN d.CANTIDAD*d.PRECIO_UNITARIO/11 END),0)
    INTO v_total, v_iva5, v_iva10
    FROM WKSP_WORKPLACE.SOLICITUD_NC_DETALLE d
   WHERE d.ID_SOLICITUD_NC = p_id_solicitud;

  IF v_total <= 0 THEN
    RAISE_APPLICATION_ERROR(-20981,'El total de la NC debe ser mayor a cero.');
  END IF;

  -- Reservar numero NC
  v_nro_nc := WKSP_WORKPLACE.FN_OBTENER_COMPROBANTE(v_id_talon);

  -- Cabecera NC (ESTADO='A'; FORMA_PAGO NULL; ID_ORDEN_VENTA NULL)
  INSERT INTO WKSP_WORKPLACE.COMPROBANTES (
    ID_CLIENTE, ID_OFICINA, ID_ORDEN_VENTA, TIPO_COMPROBANTE,
    FECHA, TOTAL_MONEDA_LOCAL, MONEDA, TIPO_CAMBIO, TOTAL_MONEDA_ORIGEN,
    FORMA_PAGO, ESTADO, OBSERVACION, ID_TALONARIO, NRO_COMPROBANTE,
    TOTAL_IVA_5, TOTAL_IVA_10, TOTAL_IVA,
    COD_MOTIVO, ID_COMPROBANTE_ORIGEN
  ) VALUES (
    v_f.ID_CLIENTE, v_f.ID_OFICINA, NULL, 'NC',
    SYSDATE, ROUND(v_total,2), v_f.MONEDA, v_f.TIPO_CAMBIO,
    ROUND(v_total / NVL(v_f.TIPO_CAMBIO,1),2),
    NULL, 'A',
    'Nota de Credito sobre factura '||v_f.NRO_COMPROBANTE||' - '||
      (SELECT DESCRIPCION FROM WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO WHERE COD_MOTIVO=v_s.COD_MOTIVO),
    v_id_talon, v_nro_nc,
    ROUND(v_iva5,2), ROUND(v_iva10,2), ROUND(v_iva5+v_iva10,2),
    v_s.COD_MOTIVO, v_f.ID_COMPROBANTE
  ) RETURNING ID_COMPROBANTE INTO v_id_nc;

  -- Detalle NC (no mueve stock: TIPO_COMPROBANTE='NC')
  INSERT INTO WKSP_WORKPLACE.DETALLE_COMPROBANTE (
    ID_COMPROBANTE, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, TOTAL_LINEA,
    PORCENTAJE_IVA, MONTO_IVA
  )
  SELECT v_id_nc, d.ID_PRODUCTO, d.CANTIDAD, d.PRECIO_UNITARIO,
         ROUND(d.CANTIDAD*d.PRECIO_UNITARIO,2),
         d.PORCENTAJE_IVA,
         ROUND(CASE WHEN d.PORCENTAJE_IVA=5  THEN d.CANTIDAD*d.PRECIO_UNITARIO/21
                    WHEN d.PORCENTAJE_IVA=10 THEN d.CANTIDAD*d.PRECIO_UNITARIO/11
                    ELSE 0 END,2)
    FROM WKSP_WORKPLACE.SOLICITUD_NC_DETALLE d
   WHERE d.ID_SOLICITUD_NC = p_id_solicitud;

  -- Stock condicional: ENTRADA por cada linea si el motivo es devolucion
  IF v_s.DEVUELVE_STOCK = 'S' THEN
    FOR d IN (SELECT ID_PRODUCTO, CANTIDAD FROM WKSP_WORKPLACE.SOLICITUD_NC_DETALLE
               WHERE ID_SOLICITUD_NC = p_id_solicitud) LOOP
      INSERT INTO WKSP_WORKPLACE.MOVIMIENTOS_STOCK (
        ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
        FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION, USUARIO, FECHA, HORA
      ) VALUES (
        d.ID_PRODUCTO, v_f.ID_OFICINA, 'ENTRADA', d.CANTIDAD,
        SYSDATE, 'NOTA_CREDITO#'||v_nro_nc,
        'Devolucion por NC '||v_nro_nc||' (factura '||v_f.NRO_COMPROBANTE||')',
        p_usuario, SYSDATE, TO_CHAR(SYSDATE,'HH24:MI:SS')
      );
    END LOOP;
  END IF;

  -- Efecto financiero
  IF v_f.FORMA_PAGO = '1' THEN
    -- CREDITO: reconciliar CxC + cuotas (invariante SALDO = Sum cuotas vigentes)
    BEGIN
      SELECT * INTO v_cxc FROM WKSP_WORKPLACE.CUENTAS_COBRAR
       WHERE ID_COMPROBANTE = v_f.ID_COMPROBANTE FOR UPDATE;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20987,
        'La factura credito '||v_f.NRO_COMPROBANTE||' no tiene cuenta por cobrar asociada; '
        ||'no se puede emitir NC de credito sobre ella.');
    END;

    IF v_total > v_cxc.SALDO + 0.01 THEN
      RAISE_APPLICATION_ERROR(-20982,
        'La NC ('||ROUND(v_total,2)||') excede el saldo pendiente de la cuenta '||
        '('||v_cxc.SALDO||'). Reverse los cobros antes de acreditar lo ya pagado.');
    END IF;

    IF v_s.TIPO_NC = 'T' OR v_total >= v_cxc.SALDO - 0.01 THEN
      UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR_DET SET ESTADO='ANULADA'
       WHERE ID_CXC = v_cxc.ID_CXC AND ESTADO IN ('PENDIENTE','VENCIDA');
      UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR SET ESTADO='ANULADA', SALDO=0
       WHERE ID_CXC = v_cxc.ID_CXC;
    ELSE
      v_rem := v_total;
      FOR cu IN (SELECT ID_DETALLE, MONTO_CUOTA FROM WKSP_WORKPLACE.CUENTAS_COBRAR_DET
                  WHERE ID_CXC = v_cxc.ID_CXC AND ESTADO IN ('PENDIENTE','VENCIDA')
                  ORDER BY NRO_CUOTA DESC) LOOP
        EXIT WHEN v_rem <= 0;
        IF v_rem >= cu.MONTO_CUOTA THEN
          UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR_DET SET ESTADO='ANULADA'
           WHERE ID_DETALLE = cu.ID_DETALLE;
          v_rem := v_rem - cu.MONTO_CUOTA;
        ELSE
          UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR_DET SET MONTO_CUOTA = cu.MONTO_CUOTA - v_rem
           WHERE ID_DETALLE = cu.ID_DETALLE;
          v_rem := 0;
        END IF;
      END LOOP;
      UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR SET SALDO = SALDO - v_total
       WHERE ID_CXC = v_cxc.ID_CXC;
    END IF;
  ELSE
    -- CONTADO: EGRESO en la caja abierta del aprobador (espejo F11)
    v_id_caja := WKSP_WORKPLACE.FN_CAJA_ABIERTA_USUARIO(p_usuario);
    IF v_id_caja IS NULL THEN
      RAISE_APPLICATION_ERROR(-20983,
        'Para aprobar una NC de contado necesitas tener caja abierta. Abri caja primero (P65).');
    END IF;
    -- La caja abierta debe ser del dia de hoy (coherente con la facturacion:
    -- no se postea efectivo de hoy a una caja de un dia anterior aun abierta).
    SELECT FEC_APERTURA INTO v_fec_caja FROM WKSP_WORKPLACE.CAJAS WHERE ID_CAJA = v_id_caja;
    IF TRUNC(v_fec_caja) <> TRUNC(SYSDATE) THEN
      RAISE_APPLICATION_ERROR(-20988,
        'Tu caja abierta (#'||v_id_caja||') fue abierta el '||TO_CHAR(v_fec_caja,'DD/MM/YYYY')
        ||' y no corresponde al dia de hoy. Cerrala y abri una caja del dia para emitir la NC de contado.');
    END IF;
    INSERT INTO WKSP_WORKPLACE.MOVIMIENTOS_CAJA (
      ID_CLIENTE, ID_CAJA, FECHA, TOTAL_MONEDA_LOCAL, MONEDA,
      TIPO_CAMBIO, TOTAL_MONEDA_ORIGEN, ESTADO, OBSERVACION,
      TIPO, ID_COMPROBANTE, USUARIO
    ) VALUES (
      v_f.ID_CLIENTE, v_id_caja, SYSTIMESTAMP, ROUND(v_total,2), v_f.MONEDA,
      v_f.TIPO_CAMBIO, ROUND(v_total / NVL(v_f.TIPO_CAMBIO,1),2), 'A',
      'Nota de Credito '||v_nro_nc||' (factura '||v_f.NRO_COMPROBANTE||')',
      'EGRESO', v_id_nc, p_usuario
    );
  END IF;

  -- Cerrar la solicitud
  UPDATE WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO
     SET ESTADO='A', USUARIO_APRUEBA=p_usuario, FECHA_RESOLUCION=SYSDATE,
         ID_NC_GENERADA=v_id_nc
   WHERE ID_SOLICITUD_NC = p_id_solicitud;
END;
/
show errors procedure PRC_APROBAR_NOTA_CREDITO

prompt == F14.12 PRC_RECHAZAR_NOTA_CREDITO ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_RECHAZAR_NOTA_CREDITO (
  p_id_solicitud   IN NUMBER,
  p_motivo_rechazo IN VARCHAR2,
  p_usuario        IN VARCHAR2
) IS
  v_estado CHAR(1);
BEGIN
  IF p_motivo_rechazo IS NULL OR LENGTH(TRIM(p_motivo_rechazo)) < 10 THEN
    RAISE_APPLICATION_ERROR(-20984,'El motivo de rechazo debe tener al menos 10 caracteres.');
  END IF;
  IF p_usuario IS NULL THEN
    RAISE_APPLICATION_ERROR(-20985,'Usuario aprobador requerido.');
  END IF;

  SELECT ESTADO INTO v_estado FROM WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO
   WHERE ID_SOLICITUD_NC = p_id_solicitud FOR UPDATE;
  IF v_estado <> 'P' THEN
    RAISE_APPLICATION_ERROR(-20986,'La solicitud no esta pendiente (ESTADO='||v_estado||').');
  END IF;

  UPDATE WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO
     SET ESTADO='R', MOTIVO_RECHAZO=TRIM(p_motivo_rechazo),
         USUARIO_APRUEBA=p_usuario, FECHA_RESOLUCION=SYSDATE
   WHERE ID_SOLICITUD_NC = p_id_solicitud;
END;
/
show errors procedure PRC_RECHAZAR_NOTA_CREDITO

prompt == F14.13 V_SOLICITUDES_NC (listado de aprobacion) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_SOLICITUDES_NC AS
SELECT s.ID_SOLICITUD_NC,
       s.ESTADO,
       s.TIPO_NC,
       s.DEVUELVE_STOCK,
       s.COD_MOTIVO,
       m.DESCRIPCION       AS MOTIVO,
       s.OBSERVACION,
       s.ID_COMPROBANTE_ORIGEN,
       f.NRO_COMPROBANTE   AS FACTURA_NRO,
       f.FORMA_PAGO        AS FACTURA_FORMA_PAGO,
       f.TOTAL_MONEDA_LOCAL AS FACTURA_TOTAL,
       f.ID_CLIENTE,
       TRIM(REGEXP_REPLACE(
         TRIM(BOTH ' ' FROM
           NVL(p.PRIMER_NOMBRE,'')||' '||NVL(p.SEGUNDO_NOMBRE,'')||' '||
           NVL(p.PRIMER_APELLIDO,'')||' '||NVL(p.SEGUNDO_APELLIDO,'')
         ), ' +', ' ')) AS CLIENTE_NOMBRE,
       s.USUARIO_SOLICITA, s.FECHA_SOLICITUD,
       s.USUARIO_APRUEBA, s.FECHA_RESOLUCION, s.MOTIVO_RECHAZO,
       s.ID_NC_GENERADA,
       nc.NRO_COMPROBANTE  AS NC_NRO
  FROM WKSP_WORKPLACE.SOLICITUDES_NOTA_CREDITO s
  JOIN WKSP_WORKPLACE.COMPROBANTES f  ON f.ID_COMPROBANTE = s.ID_COMPROBANTE_ORIGEN
  LEFT JOIN WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO m ON m.COD_MOTIVO = s.COD_MOTIVO
  LEFT JOIN WKSP_WORKPLACE.PERSONAS p ON p.ID_PERSONA = f.ID_CLIENTE
  LEFT JOIN WKSP_WORKPLACE.COMPROBANTES nc ON nc.ID_COMPROBANTE = s.ID_NC_GENERADA;

prompt == F14.14 V_NOTAS_CREDITO (NC emitidas) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_NOTAS_CREDITO AS
SELECT nc.ID_COMPROBANTE,
       nc.NRO_COMPROBANTE,
       nc.FECHA,
       nc.TOTAL_MONEDA_LOCAL,
       nc.MONEDA,
       nc.TOTAL_IVA,
       nc.COD_MOTIVO,
       m.DESCRIPCION        AS MOTIVO,
       nc.ID_COMPROBANTE_ORIGEN,
       f.NRO_COMPROBANTE    AS FACTURA_NRO,
       f.FECHA              AS FACTURA_FECHA,
       nc.ID_CLIENTE,
       TRIM(REGEXP_REPLACE(
         TRIM(BOTH ' ' FROM
           NVL(p.PRIMER_NOMBRE,'')||' '||NVL(p.SEGUNDO_NOMBRE,'')||' '||
           NVL(p.PRIMER_APELLIDO,'')||' '||NVL(p.SEGUNDO_APELLIDO,'')
         ), ' +', ' ')) AS CLIENTE_NOMBRE,
       nc.ID_OFICINA
  FROM WKSP_WORKPLACE.COMPROBANTES nc
  LEFT JOIN WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO m ON m.COD_MOTIVO = nc.COD_MOTIVO
  LEFT JOIN WKSP_WORKPLACE.COMPROBANTES f ON f.ID_COMPROBANTE = nc.ID_COMPROBANTE_ORIGEN
  LEFT JOIN WKSP_WORKPLACE.PERSONAS p ON p.ID_PERSONA = nc.ID_CLIENTE
 WHERE nc.TIPO_COMPROBANTE = 'NC';

prompt == F14.15 FN_KUDE_NOTA_CREDITO_HTML (representacion grafica NC) ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_KUDE_NOTA_CREDITO_HTML (
  p_id_nc IN NUMBER
) RETURN CLOB IS
  v_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');
  v_tel    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('TELEFONO','TEXTO'),'-');

  CURSOR cr IS
    SELECT TRIM(PE.PRIMER_NOMBRE||' '||PE.SEGUNDO_NOMBRE||' '||PE.PRIMER_APELLIDO||' '||PE.SEGUNDO_APELLIDO) AS CLIENTE,
           PE.NRO_DOCUMENTO, PE.CORREO,
           C.ID_COMPROBANTE, C.FECHA, C.TOTAL_MONEDA_LOCAL AS TOTAL, C.NRO_COMPROBANTE,
           NVL(MO.DESCRIPCION, C.MONEDA) AS MONEDA, MO.ES_LOCAL,
           NVL(C.TOTAL_IVA_5,0) AS IVA5, NVL(C.TOTAL_IVA_10,0) AS IVA10, NVL(C.TOTAL_IVA,0) AS IVATOT,
           T.TIMBRADO, T.FECHA_INICIO AS TIMB_INI,
           MT.DESCRIPCION AS MOTIVO,
           F.NRO_COMPROBANTE AS FAC_NRO, F.FECHA AS FAC_FECHA
      FROM WKSP_WORKPLACE.COMPROBANTES C
      JOIN WKSP_WORKPLACE.CLIENTES  CL ON CL.ID_PERSONA = C.ID_CLIENTE
      JOIN WKSP_WORKPLACE.PERSONAS  PE ON PE.ID_PERSONA = CL.ID_PERSONA
      LEFT JOIN WKSP_WORKPLACE.TALONARIOS T ON T.ID_TALONARIO = C.ID_TALONARIO
      LEFT JOIN WKSP_WORKPLACE.MONEDAS   MO ON (MO.CODIGO_MONEDA = C.MONEDA OR MO.DESCRIPCION = C.MONEDA)
      LEFT JOIN WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO MT ON MT.COD_MOTIVO = C.COD_MOTIVO
      LEFT JOIN WKSP_WORKPLACE.COMPROBANTES F ON F.ID_COMPROBANTE = C.ID_COMPROBANTE_ORIGEN
     WHERE C.ID_COMPROBANTE = p_id_nc AND C.TIPO_COMPROBANTE='NC';

  CURSOR cd (p_id NUMBER) IS
    SELECT PR.NOMBRE AS PRODUCTO, DC.CANTIDAD, DC.PRECIO_UNITARIO, DC.TOTAL_LINEA,
           NVL(DC.PORCENTAJE_IVA,0) AS PIVA
      FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE DC
      JOIN WKSP_WORKPLACE.PRODUCTOS PR ON PR.ID_PRODUCTO = DC.ID_PRODUCTO
     WHERE DC.ID_COMPROBANTE = p_id ORDER BY DC.ID_DETALLE;

  v_html   CLOB;
  v_sub_ex NUMBER; v_sub_5 NUMBER; v_sub_10 NUMBER;
  v_ce VARCHAR2(40); v_c5 VARCHAR2(40); v_c10 VARCHAR2(40);

  FUNCTION fmt(n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRANSLATE(TO_CHAR(NVL(n,0),'FM999G999G999G990'), ',', '.');
  END;
BEGIN
  FOR v IN cr LOOP
    v_sub_ex := 0; v_sub_5 := 0; v_sub_10 := 0;
    v_html := '<div class="kude">';
    v_html := v_html || '<div class="ktit">KuDE de Nota de Cr&eacute;dito Electr&oacute;nica</div>';
    v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                     || v_dir||'<br>'||v_ciudad||'<br>Tel.: '||v_tel||'</td>';
    v_html := v_html || '<td class="r"><b>RUC:</b> '||v_ruc
                     || '<br><b>Timbrado N&deg;:</b> '||NVL(v.TIMBRADO,'-')
                     || '<br><b>Inicio de Vigencia:</b> '||NVL(TO_CHAR(v.TIMB_INI,'dd/mm/yyyy'),'-')
                     || '<br><b>Nota de Cr&eacute;dito Electr&oacute;nica</b><br><b>N&deg; '||NVL(v.NRO_COMPROBANTE,'-')||'</b></td></tr></table>';

    v_html := v_html || '<div class="kbox"><table class="krec">';
    v_html := v_html || '<tr><td><span class="klabel">Nombre o Raz&oacute;n Social</span><br>'||v.CLIENTE
                     || '</td><td><span class="klabel">RUC / CI</span><br>'||NVL(v.NRO_DOCUMENTO,'-')
                     || '</td><td><span class="klabel">Moneda</span><br>'||NVL(v.MONEDA,'-')||'</td></tr>';
    v_html := v_html || '<tr><td><span class="klabel">Fecha de Emisi&oacute;n</span><br>'||NVL(TO_CHAR(v.FECHA,'dd/mm/yyyy'),'-')
                     || '</td><td><span class="klabel">Motivo</span><br>'||NVL(v.MOTIVO,'-')
                     || '</td><td><span class="klabel">Documento asociado</span><br>Factura '
                     || NVL(v.FAC_NRO,'-')||' ('||NVL(TO_CHAR(v.FAC_FECHA,'dd/mm/yyyy'),'-')||')</td></tr>';
    v_html := v_html || '</table></div>';

    v_html := v_html || '<table class="kitems"><thead><tr><th>Cant.</th><th>Descripci&oacute;n</th>'
                     || '<th>Precio Unitario</th><th>Exentas</th><th>IVA 5%</th><th>IVA 10%</th></tr></thead><tbody>';
    FOR d IN cd(v.ID_COMPROBANTE) LOOP
      v_ce := ''; v_c5 := ''; v_c10 := '';
      IF d.PIVA = 5 THEN
        v_sub_5 := v_sub_5 + d.TOTAL_LINEA; v_c5 := fmt(d.TOTAL_LINEA);
      ELSIF d.PIVA = 10 THEN
        v_sub_10 := v_sub_10 + d.TOTAL_LINEA; v_c10 := fmt(d.TOTAL_LINEA);
      ELSE
        v_sub_ex := v_sub_ex + d.TOTAL_LINEA; v_ce := fmt(d.TOTAL_LINEA);
      END IF;
      v_html := v_html || '<tr><td class="c">'||TO_CHAR(d.CANTIDAD)||'</td><td>'||d.PRODUCTO
                       || '</td><td class="r">'||fmt(d.PRECIO_UNITARIO)||'</td>'
                       || '<td class="r">'||v_ce||'</td><td class="r">'||v_c5||'</td><td class="r">'||v_c10||'</td></tr>';
    END LOOP;
    v_html := v_html || '<tr class="ksub"><td colspan="3" class="r"><b>Subtotales</b></td><td class="r">'||fmt(v_sub_ex)
                     || '</td><td class="r">'||fmt(v_sub_5)||'</td><td class="r">'||fmt(v_sub_10)||'</td></tr></tbody></table>';

    v_html := v_html || '<table class="ktot"><tr><td><b>Total de la Nota de Cr&eacute;dito:</b> '
                     || CASE WHEN v.ES_LOCAL = 'S' THEN WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL)
                             ELSE WKSP_WORKPLACE.FN_NUMERO_A_LETRAS(v.TOTAL, v.MONEDA) END
                     || '</td><td class="r"><b>'||fmt(v.TOTAL)||'</b></td></tr>';
    v_html := v_html || '<tr><td>Liquidaci&oacute;n del IVA: (5%) '||fmt(v.IVA5)||' &nbsp; (10%) '||fmt(v.IVA10)
                     || '</td><td class="r"><b>Total IVA: '||fmt(v.IVATOT)||'</b></td></tr></table>';

    v_html := v_html || '<div class="kleg">ESTE DOCUMENTO ES UNA REPRESENTACI&Oacute;N GR&Aacute;FICA DE UN DOCUMENTO ELECTR&Oacute;NICO<br>'
                     || '<i>Representaci&oacute;n de demostraci&oacute;n &mdash; sin validez fiscal.</i></div>';
    v_html := v_html || '</div>';
  END LOOP;

  IF v_html IS NULL THEN
    v_html := '<h2>Nota de Cr&eacute;dito no encontrada.</h2>';
  END IF;
  RETURN v_html;
END FN_KUDE_NOTA_CREDITO_HTML;
/
show errors function FN_KUDE_NOTA_CREDITO_HTML

prompt == F14.16 Verificacion final ==
DECLARE
  v_cnt PLS_INTEGER;
  v_ok  BOOLEAN := TRUE;
  PROCEDURE chk_obj(p_name VARCHAR2, p_type VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_objects
     WHERE owner='WKSP_WORKPLACE' AND object_name=p_name AND object_type=p_type AND status='VALID';
    IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  '||RPAD(p_type,10)||' '||p_name);
    ELSE DBMS_OUTPUT.PUT_LINE('  FAIL '||RPAD(p_type,10)||' '||p_name||' (count='||v_cnt||')'); v_ok:=FALSE; END IF;
  END;
  PROCEDURE chk_col(p_col VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name='COMPROBANTES' AND column_name=p_col;
    IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  COLUMN     COMPROBANTES.'||p_col);
    ELSE DBMS_OUTPUT.PUT_LINE('  FAIL COLUMN     COMPROBANTES.'||p_col); v_ok:=FALSE; END IF;
  END;
  PROCEDURE chk_tab(p_tab VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tables
     WHERE owner='WKSP_WORKPLACE' AND table_name=p_tab;
    IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TABLE      '||p_tab);
    ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TABLE      '||p_tab); v_ok:=FALSE; END IF;
  END;
BEGIN
  chk_col('COD_MOTIVO');
  chk_col('ID_COMPROBANTE_ORIGEN');
  chk_tab('SOLICITUDES_NOTA_CREDITO');
  chk_tab('SOLICITUD_NC_DETALLE');
  chk_obj('FN_CANT_ACREDITABLE',         'FUNCTION');
  chk_obj('FN_NC_ELEGIBLE',              'FUNCTION');
  chk_obj('FN_NC_AVISO',                 'FUNCTION');
  chk_obj('PRC_SOLICITAR_NOTA_CREDITO',  'PROCEDURE');
  chk_obj('PRC_VALIDAR_SOLICITUD_NC',    'PROCEDURE');
  chk_obj('PRC_APROBAR_NOTA_CREDITO',    'PROCEDURE');
  chk_obj('PRC_RECHAZAR_NOTA_CREDITO',   'PROCEDURE');
  chk_obj('FN_KUDE_NOTA_CREDITO_HTML',   'FUNCTION');
  chk_obj('V_SOLICITUDES_NC',            'VIEW');
  chk_obj('V_NOTAS_CREDITO',             'VIEW');

  SELECT COUNT(*) INTO v_cnt FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='CK_NC_MOTIVO' AND status='ENABLED';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  CHECK      CK_NC_MOTIVO');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL CHECK      CK_NC_MOTIVO'); v_ok:=FALSE; END IF;

  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.COMPROBANTES
   WHERE TIPO_COMPROBANTE='NC' AND ID_ORDEN_VENTA IS NOT NULL;
  IF v_cnt=0 THEN DBMS_OUTPUT.PUT_LINE('  OK  CLEANUP    sin NC legacy malformadas');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL CLEANUP    quedan '||v_cnt||' NC legacy'); v_ok:=FALSE; END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F14 aplicado OK.');
  ELSE RAISE_APPLICATION_ERROR(-20999,'F14 verificacion FAIL.'); END IF;
END;
/

prompt == F14 - fin ==
set define on

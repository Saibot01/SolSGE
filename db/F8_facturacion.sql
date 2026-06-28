-- ============================================================================
-- F8 - Facturacion contado de presupuestos (Module de Caja + Facturacion)
-- ============================================================================
-- Implementa la Feature 8 de PLAN_FACTURACION.md:
--   1. Renombre RECIBOS_COBRO -> MOVIMIENTOS_CAJA + DETALLE_RECIBO_COBRO -> DETALLE_MOVIMIENTO_CAJA
--   2. Extension de MOVIMIENTOS_CAJA con TIPO/USUARIO/ID_COMPROBANTE y campos del documento (NRO_RECIBO etc)
--   3. Hardening de CAJAS: CK_ESTADO + indice unico parcial UQ_CAJA_ABIERTA_EMP
--   4. Funciones: FN_CAJA_ABIERTA_USUARIO, FN_OFICINA_USUARIO_V2, FN_OBTENER_COMPROBANTE (reescrita atomica)
--   5. Vistas: V_TALONARIOS_DISPONIBLES, V_RECIBOS_COBRO
--   6. Triggers: DROP TRG_ACTUALIZAR_STOCK_FACTURA (roto), REPLACE TRG_OV_LIBERA_RESERVA con FACTURADO, CREATE TRG_CAJA_UNA_POR_DIA
--   7. CERRAR_CAJA v2 (suma MOVIMIENTOS_CAJA)
--
-- Idempotente: re-correrlo es no-op.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: @db/F8_facturacion.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == F8.1 Pre-check de dependencias ==
DECLARE
  v_deps PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_deps
    FROM all_dependencies
   WHERE referenced_owner = 'WKSP_WORKPLACE'
     AND referenced_name  = 'RECIBOS_COBRO'
     AND name             NOT IN ('CERRAR_CAJA');
  IF v_deps > 0 THEN
    DBMS_OUTPUT.PUT_LINE('  ! Hay dependencias inesperadas sobre RECIBOS_COBRO. Revisar manualmente.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = Sin dependencias inesperadas sobre RECIBOS_COBRO');
  END IF;
END;
/

prompt == F8.2 Renombre de tablas y columna PK ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  -- Renombrar RECIBOS_COBRO -> MOVIMIENTOS_CAJA (Autonomous DB usa ALTER TABLE RENAME TO)
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='RECIBOS_COBRO';
  IF v_cnt = 1 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.RECIBOS_COBRO RENAME TO MOVIMIENTOS_CAJA';
    DBMS_OUTPUT.PUT_LINE('  + RECIBOS_COBRO -> MOVIMIENTOS_CAJA');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = MOVIMIENTOS_CAJA ya existe');
  END IF;

  -- Renombrar DETALLE_RECIBO_COBRO -> DETALLE_MOVIMIENTO_CAJA
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='DETALLE_RECIBO_COBRO';
  IF v_cnt = 1 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.DETALLE_RECIBO_COBRO RENAME TO DETALLE_MOVIMIENTO_CAJA';
    DBMS_OUTPUT.PUT_LINE('  + DETALLE_RECIBO_COBRO -> DETALLE_MOVIMIENTO_CAJA');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = DETALLE_MOVIMIENTO_CAJA ya existe');
  END IF;

  -- Renombrar columna ID_RECIBO -> ID_MOVIMIENTO en cabecera
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='MOVIMIENTOS_CAJA' AND column_name='ID_RECIBO';
  IF v_cnt = 1 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.MOVIMIENTOS_CAJA RENAME COLUMN ID_RECIBO TO ID_MOVIMIENTO';
    DBMS_OUTPUT.PUT_LINE('  + MOVIMIENTOS_CAJA.ID_RECIBO -> ID_MOVIMIENTO');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = MOVIMIENTOS_CAJA.ID_MOVIMIENTO ya existe');
  END IF;

  -- Renombrar columna ID_RECIBO -> ID_MOVIMIENTO en detalle
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='DETALLE_MOVIMIENTO_CAJA' AND column_name='ID_RECIBO';
  IF v_cnt = 1 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA RENAME COLUMN ID_RECIBO TO ID_MOVIMIENTO';
    DBMS_OUTPUT.PUT_LINE('  + DETALLE_MOVIMIENTO_CAJA.ID_RECIBO -> ID_MOVIMIENTO');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = DETALLE_MOVIMIENTO_CAJA.ID_MOVIMIENTO ya existe');
  END IF;
END;
/

prompt == F8.3 Columnas extra en MOVIMIENTOS_CAJA ==
DECLARE
  PROCEDURE add_col_if_missing(p_col VARCHAR2, p_def VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name='MOVIMIENTOS_CAJA' AND column_name=p_col;
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.MOVIMIENTOS_CAJA ADD '||p_col||' '||p_def;
      DBMS_OUTPUT.PUT_LINE('  + columna '||p_col||' agregada');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  = columna '||p_col||' ya existe');
    END IF;
  END;
BEGIN
  -- dimension movimiento contable
  add_col_if_missing('TIPO',                 q'[VARCHAR2(20) DEFAULT 'INGRESO_VENTA' NOT NULL]');
  add_col_if_missing('ID_COMPROBANTE',       'NUMBER');
  -- USUARIO se llena explicitamente desde P67/cobros (APEX); no usamos NV() como DEFAULT
  -- porque es funcion APEX y ORA-04044 al evaluarse en DDL.
  add_col_if_missing('USUARIO',              'VARCHAR2(60)');
  -- dimension documento recibo (solo llena para TIPO='COBRO_CXC')
  add_col_if_missing('NRO_RECIBO',           'VARCHAR2(20)');
  add_col_if_missing('ID_TALONARIO_RECIBO',  'NUMBER');
  add_col_if_missing('FECHA_EMISION_RECIBO', 'DATE');
  add_col_if_missing('ID_CUENTA_COBRAR_DET', 'NUMBER');
END;
/

prompt == F8.4 Constraints en MOVIMIENTOS_CAJA ==
DECLARE
  PROCEDURE add_cons_if_missing(p_name VARCHAR2, p_def VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_constraints
     WHERE owner='WKSP_WORKPLACE' AND constraint_name=p_name;
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.MOVIMIENTOS_CAJA ADD CONSTRAINT '||p_name||' '||p_def;
      DBMS_OUTPUT.PUT_LINE('  + constraint '||p_name||' agregada');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  = constraint '||p_name||' ya existe');
    END IF;
  END;
BEGIN
  add_cons_if_missing('FK_MOVCAJA_COMP',
    'FOREIGN KEY (ID_COMPROBANTE) REFERENCES COMPROBANTES(ID_COMPROBANTE)');
  add_cons_if_missing('FK_MOVCAJA_TALONARIO',
    'FOREIGN KEY (ID_TALONARIO_RECIBO) REFERENCES TALONARIOS(ID_TALONARIO)');
  add_cons_if_missing('FK_MOVCAJA_CXC_DET',
    'FOREIGN KEY (ID_CUENTA_COBRAR_DET) REFERENCES CUENTAS_COBRAR_DET(ID_DETALLE)');
  add_cons_if_missing('CK_MOVCAJA_TIPO',
    q'[CHECK (TIPO IN ('INGRESO_VENTA','COBRO_CXC','EGRESO','AJUSTE'))]');
  add_cons_if_missing('CK_MOVCAJA_ESTADO',
    q'[CHECK (ESTADO IS NULL OR ESTADO IN ('A','C'))]');
  add_cons_if_missing('CK_MOVCAJA_RECIBO',
    q'[CHECK (
      (TIPO = 'COBRO_CXC' AND NRO_RECIBO IS NOT NULL AND ID_TALONARIO_RECIBO IS NOT NULL
                          AND FECHA_EMISION_RECIBO IS NOT NULL AND ID_CUENTA_COBRAR_DET IS NOT NULL)
      OR
      (TIPO <> 'COBRO_CXC' AND NRO_RECIBO IS NULL AND ID_TALONARIO_RECIBO IS NULL
                           AND FECHA_EMISION_RECIBO IS NULL AND ID_CUENTA_COBRAR_DET IS NULL)
    )]');
END;
/

prompt == F8.5 Hardening de CAJAS ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  -- CK_CAJAS_ESTADO permite NULL (datos heredados) o 'A'/'C'
  SELECT COUNT(*) INTO v_cnt FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='CK_CAJAS_ESTADO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[ALTER TABLE WKSP_WORKPLACE.CAJAS ADD CONSTRAINT CK_CAJAS_ESTADO
                         CHECK (ESTADO IS NULL OR ESTADO IN ('A','C'))]';
    DBMS_OUTPUT.PUT_LINE('  + CK_CAJAS_ESTADO');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = CK_CAJAS_ESTADO ya existe');
  END IF;

  -- Indice unico parcial: una sola caja con ESTADO='A' por empleado
  SELECT COUNT(*) INTO v_cnt FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_CAJA_ABIERTA_EMP';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[CREATE UNIQUE INDEX WKSP_WORKPLACE.UQ_CAJA_ABIERTA_EMP
                         ON WKSP_WORKPLACE.CAJAS (CASE WHEN ESTADO='A' THEN ID_EMPLEADO END)]';
    DBMS_OUTPUT.PUT_LINE('  + UQ_CAJA_ABIERTA_EMP');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = UQ_CAJA_ABIERTA_EMP ya existe');
  END IF;
END;
/

prompt == F8.6 Funciones nuevas y reescrituras ==

CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_CAJA_ABIERTA_USUARIO (
  p_usuario IN VARCHAR2 DEFAULT V('APP_USER')
) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT MAX(c.ID_CAJA)
    INTO v_id
    FROM WKSP_WORKPLACE.CAJAS c
    JOIN WKSP_WORKPLACE.EMPLEADOS e ON e.ID_EMPLEADO = c.ID_EMPLEADO
   WHERE UPPER(e.CODIGO_USUARIO) = UPPER(p_usuario)
     AND c.ESTADO = 'A';
  RETURN v_id;
END;
/

CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_OFICINA_USUARIO_V2 (
  p_usuario IN VARCHAR2 DEFAULT V('APP_USER')
) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT MAX(c.ID_OFICINA)
    INTO v_id
    FROM WKSP_WORKPLACE.CAJAS c
    JOIN WKSP_WORKPLACE.EMPLEADOS e ON e.ID_EMPLEADO = c.ID_EMPLEADO
   WHERE UPPER(e.CODIGO_USUARIO) = UPPER(p_usuario)
     AND c.ESTADO = 'A';
  RETURN v_id;
END;
/

-- Reescritura atomica: cambio de firma (p_id_oficina, p_tipo) -> (p_id_talonario).
-- Reserva el numero dentro de la funcion via FOR UPDATE + UPDATE NRO_ACTUAL.
-- P67 nueva la llama con el talonario elegido del usuario. P70 no la usa
-- en la practica (PO carga manual el comprobante de proveedor).
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_OBTENER_COMPROBANTE (
  p_id_talonario IN NUMBER
) RETURN VARCHAR2 IS
  v_talon WKSP_WORKPLACE.TALONARIOS%ROWTYPE;
  v_nro   NUMBER;
BEGIN
  SELECT * INTO v_talon
    FROM WKSP_WORKPLACE.TALONARIOS
   WHERE ID_TALONARIO = p_id_talonario
     AND ACTIVO = 'S'
   FOR UPDATE;

  -- Fecha LOCAL (server en UTC; FN_HOY = hora local PY/AR UTC-3). Evita rechazar
  -- el talonario en su ultimo dia de vigencia por el adelanto de SYSDATE de noche.
  IF WKSP_WORKPLACE.FN_HOY NOT BETWEEN v_talon.FECHA_INICIO AND v_talon.FECHA_FIN THEN
    RAISE_APPLICATION_ERROR(-20002,'El talonario no esta vigente en la fecha actual.');
  END IF;
  v_nro := v_talon.NRO_ACTUAL + 1;
  IF v_nro > v_talon.NRO_FINAL THEN
    RAISE_APPLICATION_ERROR(-20001,'El talonario ha llegado a su numeracion final.');
  END IF;

  UPDATE WKSP_WORKPLACE.TALONARIOS SET NRO_ACTUAL = v_nro
   WHERE ID_TALONARIO = p_id_talonario;

  RETURN LPAD(v_talon.ESTABLECIMIENTO,3,'0')||'-'||
         LPAD(v_talon.PUNTO_EXPEDICION,3,'0')||'-'||
         LPAD(v_nro,7,'0');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003,'No se encontro talonario activo para el id indicado.');
END;
/

prompt == F8.7 Vistas ==

CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_TALONARIOS_DISPONIBLES AS
SELECT t.ID_TALONARIO,
       t.ID_OFICINA,
       t.TIPO_COMPROBANTE,
       t.TIMBRADO || ' / ' ||
         LPAD(t.ESTABLECIMIENTO,3,'0')||'-'||LPAD(t.PUNTO_EXPEDICION,3,'0') AS DESCRIPCION
  FROM WKSP_WORKPLACE.TALONARIOS t
 WHERE t.ACTIVO = 'S'
   AND WKSP_WORKPLACE.FN_HOY BETWEEN t.FECHA_INICIO AND t.FECHA_FIN
   AND t.NRO_ACTUAL < t.NRO_FINAL;

CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_RECIBOS_COBRO AS
SELECT mc.ID_MOVIMIENTO            AS ID_RECIBO,
       mc.NRO_RECIBO,
       mc.ID_TALONARIO_RECIBO,
       mc.FECHA_EMISION_RECIBO,
       mc.ID_CAJA,
       mc.ID_CLIENTE,
       mc.USUARIO,
       mc.TOTAL_MONEDA_LOCAL,
       mc.MONEDA,
       mc.TIPO_CAMBIO,
       mc.TOTAL_MONEDA_ORIGEN,
       mc.ESTADO,
       mc.OBSERVACION,
       mc.ID_CUENTA_COBRAR_DET,
       ccd.ID_CXC,
       ccd.NRO_CUOTA,
       cxc.ID_COMPROBANTE        AS COMPROBANTE_ORIGEN,
       cxc.ID_PERSONA
  FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA  mc
  LEFT JOIN WKSP_WORKPLACE.CUENTAS_COBRAR_DET ccd ON ccd.ID_DETALLE = mc.ID_CUENTA_COBRAR_DET
  LEFT JOIN WKSP_WORKPLACE.CUENTAS_COBRAR     cxc ON cxc.ID_CXC      = ccd.ID_CXC
 WHERE mc.TIPO = 'COBRO_CXC';

prompt == F8.8 Triggers ==

-- Drop del trigger roto (lee DETALLE_COMPROBANTE en AFTER INSERT de la cabecera -> no-op
-- pero peligroso si alguien hace UPDATE ESTADO mas tarde -> doble descuento de stock).
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_ACTUALIZAR_STOCK_FACTURA';
  IF v_cnt = 1 THEN
    EXECUTE IMMEDIATE 'DROP TRIGGER WKSP_WORKPLACE.TRG_ACTUALIZAR_STOCK_FACTURA';
    DBMS_OUTPUT.PUT_LINE('  - TRG_ACTUALIZAR_STOCK_FACTURA dropeado (era no-op pero riesgoso)');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = TRG_ACTUALIZAR_STOCK_FACTURA ya estaba dropeado');
  END IF;
END;
/

-- Extender TRG_OV_LIBERA_RESERVA para tambien liberar reservas al pasar a FACTURADO
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_OV_LIBERA_RESERVA
AFTER UPDATE OF ESTADO ON WKSP_WORKPLACE.ORDENES_VENTA
FOR EACH ROW
WHEN (NEW.ESTADO IN ('ANULADO','VENCIDO','FACTURADO')
      AND OLD.ESTADO IN ('PENDIENTE','APROBADO'))
BEGIN
  UPDATE WKSP_WORKPLACE.RESERVAS_PRODUCTO
     SET ESTADO = 'ANULADA'
   WHERE ID_ORDEN_VENTA = :NEW.ID_ORDEN
     AND ESTADO = 'VIGENTE';
END;
/

-- Una caja abierta por empleado + una caja por dia
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_CAJA_UNA_POR_DIA
BEFORE INSERT ON WKSP_WORKPLACE.CAJAS
FOR EACH ROW
DECLARE
  v_otra PLS_INTEGER;
BEGIN
  -- 1) No abrir si ya hay otra abierta del mismo empleado
  SELECT COUNT(*) INTO v_otra
    FROM WKSP_WORKPLACE.CAJAS
   WHERE ID_EMPLEADO = :NEW.ID_EMPLEADO
     AND ESTADO = 'A';
  IF v_otra > 0 THEN
    RAISE_APPLICATION_ERROR(-20020,
      'El empleado ya tiene una caja abierta. Debe cerrarla antes de abrir otra.');
  END IF;

  -- 2) No abrir si ya existe otra caja del mismo empleado para el mismo dia
  SELECT COUNT(*) INTO v_otra
    FROM WKSP_WORKPLACE.CAJAS
   WHERE ID_EMPLEADO = :NEW.ID_EMPLEADO
     AND TRUNC(FEC_APERTURA) = TRUNC(NVL(:NEW.FEC_APERTURA, SYSTIMESTAMP));
  IF v_otra > 0 THEN
    RAISE_APPLICATION_ERROR(-20021,
      'Ya existe una caja del empleado para esta fecha. No se admiten dos cajas del mismo dia.');
  END IF;
END;
/

prompt == F8.9 CERRAR_CAJA v2 (suma MOVIMIENTOS_CAJA) ==

CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.cerrar_caja(
  p_id_caja IN NUMBER,
  p_usuario IN VARCHAR2
) IS
BEGIN
  UPDATE WKSP_WORKPLACE.CAJAS
     SET ESTADO     = 'C',
         FEC_CIERRE = SYSTIMESTAMP,
         USU_CIERRE = p_usuario
   WHERE ID_CAJA = p_id_caja
     AND ESTADO  = 'A';

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20030,'No hay caja abierta con id '||p_id_caja);
  END IF;

  FOR reg IN (
    SELECT cm.MONEDA,
           cm.MONTO_APERTURA,
           NVL((SELECT SUM(NVL(mc.TOTAL_MONEDA_ORIGEN, mc.TOTAL_MONEDA_LOCAL))
                  FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA mc
                 WHERE mc.ID_CAJA = cm.ID_CAJA
                   AND mc.MONEDA  = cm.MONEDA
                   AND mc.TIPO   IN ('INGRESO_VENTA','COBRO_CXC')), 0) AS INGRESOS,
           NVL((SELECT SUM(NVL(mc.TOTAL_MONEDA_ORIGEN, mc.TOTAL_MONEDA_LOCAL))
                  FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA mc
                 WHERE mc.ID_CAJA = cm.ID_CAJA
                   AND mc.MONEDA  = cm.MONEDA
                   AND mc.TIPO    = 'EGRESO'), 0) AS EGRESOS
      FROM WKSP_WORKPLACE.CAJA_MONEDAS cm
     WHERE cm.ID_CAJA = p_id_caja
  ) LOOP
    UPDATE WKSP_WORKPLACE.CAJA_MONEDAS
       SET MONTO_CIERRE = reg.MONTO_APERTURA + reg.INGRESOS - reg.EGRESOS
     WHERE ID_CAJA = p_id_caja
       AND MONEDA  = reg.MONEDA;
  END LOOP;

  UPDATE WKSP_WORKPLACE.MOVIMIENTOS_CAJA
     SET ESTADO = 'C'
   WHERE ID_CAJA = p_id_caja;

  COMMIT;
END;
/

prompt == F8.10 Verificacion final ==
DECLARE
  v_ok BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;

  PROCEDURE expect_object(p_name VARCHAR2, p_type VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_objects
     WHERE owner='WKSP_WORKPLACE' AND object_name=p_name AND object_type=p_type AND status='VALID';
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK '||p_type||' '||p_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL '||p_type||' '||p_name||' (NO existe o INVALID)');
      v_ok := FALSE;
    END IF;
  END;

  PROCEDURE expect_no_object(p_name VARCHAR2, p_type VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_objects
     WHERE owner='WKSP_WORKPLACE' AND object_name=p_name AND object_type=p_type;
    IF v_cnt = 0 THEN
      DBMS_OUTPUT.PUT_LINE('  OK '||p_type||' '||p_name||' (dropeado correctamente)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL '||p_type||' '||p_name||' aun existe');
      v_ok := FALSE;
    END IF;
  END;

  PROCEDURE expect_constraint(p_name VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_constraints
     WHERE owner='WKSP_WORKPLACE' AND constraint_name=p_name AND status='ENABLED';
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK constraint '||p_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL constraint '||p_name);
      v_ok := FALSE;
    END IF;
  END;

  PROCEDURE expect_index(p_name VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_indexes
     WHERE owner='WKSP_WORKPLACE' AND index_name=p_name AND status='VALID';
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK indice '||p_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL indice '||p_name);
      v_ok := FALSE;
    END IF;
  END;

  PROCEDURE expect_col(p_table VARCHAR2, p_col VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name=p_table AND column_name=p_col;
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK columna '||p_table||'.'||p_col);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL columna '||p_table||'.'||p_col);
      v_ok := FALSE;
    END IF;
  END;
BEGIN
  expect_object('MOVIMIENTOS_CAJA',         'TABLE');
  expect_object('DETALLE_MOVIMIENTO_CAJA',  'TABLE');
  expect_no_object('RECIBOS_COBRO',         'TABLE');
  expect_no_object('DETALLE_RECIBO_COBRO',  'TABLE');

  expect_col('MOVIMIENTOS_CAJA', 'ID_MOVIMIENTO');
  expect_col('MOVIMIENTOS_CAJA', 'TIPO');
  expect_col('MOVIMIENTOS_CAJA', 'ID_COMPROBANTE');
  expect_col('MOVIMIENTOS_CAJA', 'USUARIO');
  expect_col('MOVIMIENTOS_CAJA', 'NRO_RECIBO');
  expect_col('MOVIMIENTOS_CAJA', 'ID_TALONARIO_RECIBO');
  expect_col('MOVIMIENTOS_CAJA', 'FECHA_EMISION_RECIBO');
  expect_col('MOVIMIENTOS_CAJA', 'ID_CUENTA_COBRAR_DET');
  expect_col('DETALLE_MOVIMIENTO_CAJA', 'ID_MOVIMIENTO');

  expect_constraint('FK_MOVCAJA_COMP');
  expect_constraint('FK_MOVCAJA_TALONARIO');
  expect_constraint('FK_MOVCAJA_CXC_DET');
  expect_constraint('CK_MOVCAJA_TIPO');
  expect_constraint('CK_MOVCAJA_ESTADO');
  expect_constraint('CK_MOVCAJA_RECIBO');
  expect_constraint('CK_CAJAS_ESTADO');

  expect_index('UQ_CAJA_ABIERTA_EMP');

  expect_object('FN_CAJA_ABIERTA_USUARIO',  'FUNCTION');
  expect_object('FN_OFICINA_USUARIO_V2',    'FUNCTION');
  expect_object('FN_OBTENER_COMPROBANTE',   'FUNCTION');
  expect_object('CERRAR_CAJA',              'PROCEDURE');

  expect_object('V_TALONARIOS_DISPONIBLES', 'VIEW');
  expect_object('V_RECIBOS_COBRO',          'VIEW');

  expect_object('TRG_OV_LIBERA_RESERVA',    'TRIGGER');
  expect_object('TRG_CAJA_UNA_POR_DIA',     'TRIGGER');
  expect_no_object('TRG_ACTUALIZAR_STOCK_FACTURA', 'TRIGGER');

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('F8 backend: TODO OK');
    DBMS_OUTPUT.PUT_LINE('==========================================');
  ELSE
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('F8 backend: HAY FALLAS (ver lineas FAIL)');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    RAISE_APPLICATION_ERROR(-20999,'F8 verificacion fallo');
  END IF;
END;
/

ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

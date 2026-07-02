-- ============================================================================
-- F24 - Cuentas por Pagar (DDL + trigger) - Feature transaccional de CxP
-- ============================================================================
-- H1 del PLAN_CUENTAS_PAGAR.md. El sistema no genera hoy la deuda a proveedores:
-- CUENTAS_PAGAR esta vacia y ningun trigger la puebla. Este script agrega el
-- esquema minimo y el trigger que genera la CxP al registrar la factura de compra,
-- espejando TRG_INS_CUENTAS_COBRAR de ventas (adaptado a pago UNICO, sin cuotas).
--
-- Decisiones del PO (2026-07-02, ver PLAN_CUENTAS_PAGAR.md §2):
--   1. Solo CREDITO genera CxP -> COMPROBANTES_PROVEEDOR.FORMA_PAGO ('1'=credito,
--      '21'=contado; espeja ventas). Default '21' -> no crea CxP sorpresa en
--      comprobantes nuevos hasta que P69/P70 tengan el selector de condicion.
--   2. Vencimiento = FECHA_EMISION + PROVEEDORES.PLAZO_PAGO_DIAS (default 30).
--      -> nueva columna CUENTAS_PAGAR.FECHA_VENCIMIENTO (para el aging de F25).
--   3. La deuda nace AL REGISTRAR la factura (ESTADO='R'), sin esperar recepcion:
--      la deuda es la factura, no los bienes (R/PR/C es el eje de recepcion).
--
-- Este script hace SOLO esquema + trigger. El backfill de los comprobantes
-- historicos y el seed de plazos van aparte (db/F24_2_backfill_cxp.sql). Las
-- tablas ORDENES_PAGO/ORDEN_PAGO_DET + procs van en db/F24_1_ordenes_pago.sql.
--
-- Rango de error reservado: -20935 .. -20939.
-- Idempotente: re-correrlo es no-op (add_col chequea existencia; CREATE OR REPLACE
-- para el trigger; el guard NOT EXISTS evita CxP duplicadas).
-- Pre-requisitos: PROVEEDORES, COMPROBANTES_PROVEEDOR, CUENTAS_PAGAR, FN_AHORA.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F24_cuentas_pagar.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F24.0 Pre-check (objetos base) ==
DECLARE
  v_cnt PLS_INTEGER;
  PROCEDURE need_table(p_tab VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tables
     WHERE owner='WKSP_WORKPLACE' AND table_name=p_tab;
    IF v_cnt = 0 THEN
      RAISE_APPLICATION_ERROR(-20935,'Falta la tabla '||p_tab||'.');
    END IF;
  END;
BEGIN
  need_table('PROVEEDORES');
  need_table('COMPROBANTES_PROVEEDOR');
  need_table('CUENTAS_PAGAR');

  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_AHORA'
     AND object_type='FUNCTION' AND status='VALID';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20935,'Falta FN_AHORA (F19 no aplicado o invalido).');
  END IF;

  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F24.1 Columnas nuevas ==
-- PROVEEDORES.PLAZO_PAGO_DIAS  -> plazo de pago por proveedor (origen del vto).
-- COMPROBANTES_PROVEEDOR.FORMA_PAGO -> condicion de pago ('1' credito / '21' contado).
-- CUENTAS_PAGAR.FECHA_VENCIMIENTO   -> para el aging de deuda (F25).
DECLARE
  PROCEDURE add_col(p_table VARCHAR2, p_col VARCHAR2, p_ddl VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name=p_table AND column_name=p_col;
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.'||p_table||' ADD ('||p_ddl||')';
      DBMS_OUTPUT.PUT_LINE('  + '||p_table||'.'||p_col||' agregada');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  = '||p_table||'.'||p_col||' ya existe');
    END IF;
  END;
BEGIN
  add_col('PROVEEDORES', 'PLAZO_PAGO_DIAS',
          'PLAZO_PAGO_DIAS NUMBER DEFAULT 30');
  add_col('COMPROBANTES_PROVEEDOR', 'FORMA_PAGO',
          'FORMA_PAGO VARCHAR2(2) DEFAULT ''21''');
  add_col('CUENTAS_PAGAR', 'FECHA_VENCIMIENTO',
          'FECHA_VENCIMIENTO DATE');
END;
/

prompt == F24.2 TRG_INS_CUENTAS_PAGAR (genera la deuda al registrar la factura) ==
-- Espejo de TRG_INS_CUENTAS_COBRAR, pago UNICO (sin cuotas). Dispara al registrar
-- (INSERT) y tambien en UPDATE, por si P69/P70 crea el comprobante y setea la
-- condicion/total despues. El guard NOT EXISTS lo hace idempotente: crea la CxP la
-- PRIMERA vez que el comprobante cumple (credito + no anulado + total + fecha) y
-- todavia no tiene CxP. No colisiona con TRG_ACTUALIZAR_COSTO_COMPRA (AFTER UPDATE).
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_INS_CUENTAS_PAGAR
AFTER INSERT OR UPDATE ON WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
FOR EACH ROW
DECLARE
  v_plazo NUMBER;
  v_cnt   PLS_INTEGER;
BEGIN
  IF :NEW.FORMA_PAGO = '1'                       -- credito
     AND :NEW.ESTADO <> 'A'                       -- no anulado
     AND :NEW.TOTAL_COMPROBANTE IS NOT NULL       -- excluye comprobantes basura
     AND :NEW.FECHA_EMISION IS NOT NULL THEN

    -- Guard anti-duplicado: una CxP por comprobante.
    SELECT COUNT(*) INTO v_cnt
      FROM WKSP_WORKPLACE.CUENTAS_PAGAR
     WHERE ID_COMPROBANTE = :NEW.ID_COMPROBANTE;

    IF v_cnt = 0 THEN
      -- Plazo de pago del proveedor (default 30 si no esta cargado).
      SELECT NVL(PLAZO_PAGO_DIAS, 30) INTO v_plazo
        FROM WKSP_WORKPLACE.PROVEEDORES
       WHERE ID_PERSONA = :NEW.ID_PROVEEDOR;

      INSERT INTO WKSP_WORKPLACE.CUENTAS_PAGAR (
        ID_PROVEEDOR, ID_COMPROBANTE, TOTAL_A_PAGAR, SALDO,
        FECHA_REGISTRO, FECHA_VENCIMIENTO, ESTADO
      ) VALUES (
        :NEW.ID_PROVEEDOR, :NEW.ID_COMPROBANTE,
        :NEW.TOTAL_COMPROBANTE, :NEW.TOTAL_COMPROBANTE,
        WKSP_WORKPLACE.FN_AHORA,
        TRUNC(:NEW.FECHA_EMISION) + v_plazo,
        'PENDIENTE'
      );
    END IF;
  END IF;
END;
/
show errors trigger TRG_INS_CUENTAS_PAGAR

prompt == F24.3 Verificacion final ==
DECLARE
  v_cnt PLS_INTEGER;
  v_ok  BOOLEAN := TRUE;
  PROCEDURE chk_col(p_table VARCHAR2, p_col VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name=p_table AND column_name=p_col;
    IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  COLUMN   '||p_table||'.'||p_col);
    ELSE DBMS_OUTPUT.PUT_LINE('  FAIL COLUMN   '||p_table||'.'||p_col); v_ok:=FALSE; END IF;
  END;
BEGIN
  chk_col('PROVEEDORES', 'PLAZO_PAGO_DIAS');
  chk_col('COMPROBANTES_PROVEEDOR', 'FORMA_PAGO');
  chk_col('CUENTAS_PAGAR', 'FECHA_VENCIMIENTO');

  -- trigger valido
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='TRG_INS_CUENTAS_PAGAR'
     AND object_type='TRIGGER' AND status='VALID';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_INS_CUENTAS_PAGAR (VALID)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_INS_CUENTAS_PAGAR no VALID'); v_ok:=FALSE; END IF;

  -- trigger habilitado
  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_INS_CUENTAS_PAGAR'
     AND status='ENABLED';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_INS_CUENTAS_PAGAR (ENABLED)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_INS_CUENTAS_PAGAR no ENABLED'); v_ok:=FALSE; END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F24 (DDL + trigger) aplicado OK.');
  ELSE RAISE_APPLICATION_ERROR(-20939,'F24 verificacion FAIL.'); END IF;
END;
/

prompt == F24 - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

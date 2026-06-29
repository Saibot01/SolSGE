-- ============================================================================
-- F22 - Habilitador de Metas de Cobranza (Reportes Gerenciales / Cobros)
-- ============================================================================
-- Segundo modulo gerencial (Cobros/Caja), replica la plantilla de Ventas (F18).
-- A diferencia de Ventas, NO hace falta habilitador de dimension: el cobrador ya
-- existe poblado en MOVIMIENTOS_CAJA.USUARIO. El unico agregado es la tabla de
-- METAS de cobranza, para medir cumplimiento de recaudacion en el dashboard.
--
-- Decision del PO (2026-06-28): meta por OFICINA x mes (no por cobrador: la
-- cobranza esta concentrada en 1 usuario, un ranking de cobradores quedaria
-- degenerado). Mas simple que METAS_VENTA: sin regla 1-de-2, ID_OFICINA es
-- obligatorio.
--
-- Este script hace SOLO backend de datos (cero cambios en apex-work/):
--   1. METAS_COBRANZA: meta de recaudacion por OFICINA, por mes. PERIODO es DATE
--      truncado al 1ro del mes para joinear directo contra
--      TRUNC(MOVIMIENTOS_CAJA.FECHA,'MM') sin parsear.
--   2. UQ_METAS_COBRANZA_OFI_PER: una meta por (oficina, periodo).
--   3. TRG_METAS_COBRANZA_BI (BEFORE INSERT/UPDATE): trunca PERIODO a 'MM'.
--   4. Bloque de verificacion final.
--
-- Las metas reales las carga el PO; el seed demo va aparte
-- (db/F22_seed_metas_cobranza_demo.sql).
--
-- Rango de error reservado: -20904 .. -20909.
-- Idempotente: re-correrlo es no-op.
-- Pre-requisitos: OFICINAS existente (PK CODIGO_OFICINA).
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F22_metas_cobranza.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F22.0 Pre-check (tablas base) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='OFICINAS';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20904,'Falta OFICINAS.'); END IF;

  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F22.1 Tabla METAS_COBRANZA ==
-- Meta de recaudacion por SUCURSAL (ID_OFICINA), por mes. Para "real vs. meta"
-- en el Dashboard de Cobros. PERIODO = 1ro del mes (DATE).
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='METAS_COBRANZA';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE WKSP_WORKPLACE.METAS_COBRANZA (
        ID_META      NUMBER GENERATED ALWAYS AS IDENTITY
                       CONSTRAINT PK_METAS_COBRANZA PRIMARY KEY,
        ID_OFICINA   NUMBER NOT NULL
                       CONSTRAINT FK_METAS_COBRANZA_OFI
                       REFERENCES WKSP_WORKPLACE.OFICINAS (CODIGO_OFICINA),
        PERIODO      DATE   NOT NULL,
        MONTO_META   NUMBER NOT NULL
                       CONSTRAINT CK_METAS_COBRANZA_MONTO CHECK (MONTO_META > 0)
      )]';
    DBMS_OUTPUT.PUT_LINE('  + METAS_COBRANZA creada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = METAS_COBRANZA ya existe');
  END IF;
END;
/

-- Indice unico: una meta por (oficina, periodo).
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_METAS_COBRANZA_OFI_PER';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'CREATE UNIQUE INDEX WKSP_WORKPLACE.UQ_METAS_COBRANZA_OFI_PER '||
      'ON WKSP_WORKPLACE.METAS_COBRANZA (ID_OFICINA, PERIODO)';
    DBMS_OUTPUT.PUT_LINE('  + UQ_METAS_COBRANZA_OFI_PER creado');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = UQ_METAS_COBRANZA_OFI_PER ya existe');
  END IF;
END;
/

prompt == F22.2 TRG_METAS_COBRANZA_BI (normaliza periodo) ==
-- Trunca PERIODO al 1ro del mes para que joinee directo contra
-- TRUNC(FECHA,'MM') y el UNIQUE (oficina, periodo) no se duplique por dia.
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_METAS_COBRANZA_BI
BEFORE INSERT OR UPDATE ON WKSP_WORKPLACE.METAS_COBRANZA
FOR EACH ROW
BEGIN
  IF :NEW.PERIODO IS NOT NULL THEN
    :NEW.PERIODO := TRUNC(:NEW.PERIODO, 'MM');
  END IF;
END;
/
show errors trigger TRG_METAS_COBRANZA_BI

-- Metas de ejemplo (comentadas): las define el PO. Descomentar y ajustar.
-- INSERT INTO WKSP_WORKPLACE.METAS_COBRANZA (ID_OFICINA, PERIODO, MONTO_META)
--   VALUES (1, DATE '2026-06-01', 2000000);   -- Sucursal 1, jun/26
-- COMMIT;

prompt == F22.3 Verificacion final ==
DECLARE
  v_cnt PLS_INTEGER;
  v_ok  BOOLEAN := TRUE;
BEGIN
  -- tabla de metas
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='METAS_COBRANZA';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TABLE    METAS_COBRANZA');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TABLE    METAS_COBRANZA'); v_ok:=FALSE; END IF;

  -- indice unico
  SELECT COUNT(*) INTO v_cnt FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_METAS_COBRANZA_OFI_PER';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  INDEX    UQ_METAS_COBRANZA_OFI_PER');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL INDEX    UQ_METAS_COBRANZA_OFI_PER'); v_ok:=FALSE; END IF;

  -- trigger valido y habilitado
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='TRG_METAS_COBRANZA_BI'
     AND object_type='TRIGGER' AND status='VALID';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_METAS_COBRANZA_BI (VALID)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_METAS_COBRANZA_BI no VALID'); v_ok:=FALSE; END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_METAS_COBRANZA_BI'
     AND status='ENABLED';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_METAS_COBRANZA_BI (ENABLED)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_METAS_COBRANZA_BI no ENABLED'); v_ok:=FALSE; END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F22 (habilitador) aplicado OK.');
  ELSE RAISE_APPLICATION_ERROR(-20909,'F22 verificacion FAIL.'); END IF;
END;
/

prompt == F22 - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

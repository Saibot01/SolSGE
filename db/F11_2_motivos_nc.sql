-- ============================================================================
-- F11.2 - Catalogo de Motivos de Nota de Credito (groundwork SIFEN)
-- ============================================================================
-- Prepara el camino para el futuro modulo de Nota de Credito (NC).
--
-- IMPORTANTE (decision de diseno):
--   * El EVENTO DE CANCELACION de SIFEN NO usa lista codificada de motivos:
--     su campo `mOtEve` es texto libre (5-500 chars). Por eso el flujo de
--     anulacion (F11) sigue con motivo libre y NO referencia esta tabla.
--   * La lista CODIFICADA de motivos (`iMotEmi`) es exclusiva de la
--     NOTA DE CREDITO / NOTA DE DEBITO. Esta tabla la modela como catalogo
--     de dominio para cuando se construya ese modulo (la NC guardara
--     COD_MOTIVO como FK a esta tabla).
--
-- Se modela como tabla dedicada (no en PARAMETROS) porque:
--   1. Sera target de una FK desde los documentos NC (PARAMETROS no permite
--      FK a un subconjunto filtrado por TIPO).
--   2. Tiene varios atributos por fila (codigo + descripcion + activo).
--   3. Es un dominio fiscal estandar de SIFEN, no un parametro de config.
--
-- Codigos = iMotEmi del Manual Tecnico SIFEN v150.
--
-- Idempotente: re-correrlo es no-op (no pisa descripciones editadas a mano
-- salvo en el seed inicial via MERGE).
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: @db/F11_2_motivos_nc.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == F11.2.1 Crear tabla MOTIVOS_NOTA_CREDITO ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='MOTIVOS_NOTA_CREDITO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      CREATE TABLE WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO (
        COD_MOTIVO  NUMBER(2)      NOT NULL,
        DESCRIPCION VARCHAR2(100)  NOT NULL,
        ACTIVO      CHAR(1)        DEFAULT 'S' NOT NULL,
        CONSTRAINT PK_MOTIVOS_NC      PRIMARY KEY (COD_MOTIVO),
        CONSTRAINT CK_MOTIVOS_NC_ACT  CHECK (ACTIVO IN ('S','N'))
      )
    ]';
    DBMS_OUTPUT.PUT_LINE('  + Tabla MOTIVOS_NOTA_CREDITO creada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = Tabla MOTIVOS_NOTA_CREDITO ya existe');
  END IF;
END;
/

prompt == F11.2.2 Seed iMotEmi (Manual Tecnico SIFEN v150) ==
DECLARE
  PROCEDURE upsert_motivo(p_cod NUMBER, p_desc VARCHAR2) IS
  BEGIN
    MERGE INTO WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO m
    USING (SELECT p_cod AS cod FROM dual) src
       ON (m.COD_MOTIVO = src.cod)
    WHEN MATCHED THEN
      UPDATE SET m.DESCRIPCION = p_desc
    WHEN NOT MATCHED THEN
      INSERT (COD_MOTIVO, DESCRIPCION, ACTIVO)
      VALUES (p_cod, p_desc, 'S');
  END;
BEGIN
  upsert_motivo(1, unistr('Devoluci\00F3n y ajuste de precios'));
  upsert_motivo(2, unistr('Devoluci\00F3n'));
  upsert_motivo(3, 'Descuento');
  upsert_motivo(4, unistr('Bonificaci\00F3n'));
  upsert_motivo(5, unistr('Cr\00E9dito incobrable'));
  upsert_motivo(6, 'Recupero de costo');
  upsert_motivo(7, 'Recupero de gasto');
  upsert_motivo(8, 'Ajuste de precio');
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  + 8 motivos iMotEmi cargados/actualizados');
END;
/

prompt == F11.2.3 Verificacion final ==
DECLARE
  v_cnt PLS_INTEGER;
  v_ok  BOOLEAN := TRUE;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='MOTIVOS_NOTA_CREDITO';
  IF v_cnt = 1 THEN
    DBMS_OUTPUT.PUT_LINE('  OK  TABLE      MOTIVOS_NOTA_CREDITO');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  FAIL TABLE      MOTIVOS_NOTA_CREDITO');
    v_ok := FALSE;
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO WHERE ACTIVO='S';
  IF v_cnt = 8 THEN
    DBMS_OUTPUT.PUT_LINE('  OK  SEED       8 motivos activos');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  FAIL SEED       motivos activos = '||v_cnt||' (esperado 8)');
    v_ok := FALSE;
  END IF;

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'F11.2 aplicado OK.');
  ELSE
    RAISE_APPLICATION_ERROR(-20999, 'F11.2 verificacion FAIL.');
  END IF;
END;
/

prompt == F11.2 - fin ==

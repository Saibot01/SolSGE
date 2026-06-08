-- ============================================================================
-- F10.1 - ESTABLECIMIENTO derivado desde OFICINAS (cumplimiento SET)
-- ============================================================================
-- Cierra la brecha regulatoria F10: hoy TALONARIOS.ESTABLECIMIENTO se carga
-- manualmente en P53, y nada impide que dos talonarios de la misma oficina
-- declaren distinto ESTABLECIMIENTO (lo que violaria la unicidad SET del
-- codigo de local).
--
-- Cambio:
--   1. OFICINAS gana columna ESTABLECIMIENTO_SET VARCHAR2(3) (nullable mientras
--      no haya operacion fiscal en esa oficina).
--   2. Se puebla ESTABLECIMIENTO_SET desde los talonarios existentes; si una
--      oficina tiene >1 talonario con distinto ESTABLECIMIENTO, aborta -- esta
--      es una brecha pre-existente que el operador debe resolver a mano.
--   3. Se reemplaza el trigger TRG_TALONARIO_DERIVA_OFICINA por una version
--      que ademas deriva ESTABLECIMIENTO desde OFICINAS.ESTABLECIMIENTO_SET.
--      Si ESTABLECIMIENTO_SET es NULL para esa oficina, aborta con -20961
--      (forzando al admin a cargarlo primero).
--   4. El nombre del trigger se mantiene (TRG_TALONARIO_DERIVA_OFICINA) por
--      historicidad, aunque ahora deriva tambien ESTABLECIMIENTO.
--
-- Pre-requisitos: F10_talonarios_set.sql aplicado.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: @db/F10_1_establecimiento.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

prompt == F10.1.0 Pre-check (F10 aplicado) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='TALONARIOS'
     AND column_name='ID_CAJA_CONF';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20960,'F10 no aplicado. Aplicar F10_talonarios_set.sql primero.');
  END IF;
END;
/

prompt == F10.1.1 ADD COLUMN OFICINAS.ESTABLECIMIENTO_SET ==
DECLARE
  v_exists PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='OFICINAS'
     AND column_name='ESTABLECIMIENTO_SET';
  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.OFICINAS
                       ADD ESTABLECIMIENTO_SET VARCHAR2(3)';
    DBMS_OUTPUT.PUT_LINE('Columna ESTABLECIMIENTO_SET agregada.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Columna ESTABLECIMIENTO_SET ya existe.');
  END IF;
END;
/

prompt == F10.1.2 Poblar ESTABLECIMIENTO_SET desde talonarios existentes ==
DECLARE
  v_incoherentes PLS_INTEGER;
  v_pobladas     PLS_INTEGER;
BEGIN
  -- Detectar oficinas con talonarios divergentes en ESTABLECIMIENTO
  SELECT COUNT(*) INTO v_incoherentes
    FROM (SELECT t.ID_OFICINA
            FROM WKSP_WORKPLACE.TALONARIOS t
           GROUP BY t.ID_OFICINA
          HAVING COUNT(DISTINCT t.ESTABLECIMIENTO) > 1);
  IF v_incoherentes > 0 THEN
    RAISE_APPLICATION_ERROR(-20962,
      'Hay '||v_incoherentes||' oficina(s) con talonarios que declaran '||
      'distinto ESTABLECIMIENTO. Resolver manualmente antes de F10.1.');
  END IF;

  -- Poblar
  UPDATE WKSP_WORKPLACE.OFICINAS o
     SET o.ESTABLECIMIENTO_SET = (
          SELECT MAX(t.ESTABLECIMIENTO)
            FROM WKSP_WORKPLACE.TALONARIOS t
           WHERE t.ID_OFICINA = o.CODIGO_OFICINA)
   WHERE o.ESTABLECIMIENTO_SET IS NULL
     AND EXISTS (SELECT 1 FROM WKSP_WORKPLACE.TALONARIOS t
                  WHERE t.ID_OFICINA = o.CODIGO_OFICINA);
  v_pobladas := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Oficinas con ESTABLECIMIENTO_SET poblado: '||v_pobladas);
END;
/

prompt == F10.1.3 CREATE OR REPLACE TRG_TALONARIO_DERIVA_OFICINA (deriva tambien ESTABLECIMIENTO) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_TALONARIO_DERIVA_OFICINA
BEFORE INSERT OR UPDATE OF ID_CAJA_CONF ON WKSP_WORKPLACE.TALONARIOS
FOR EACH ROW
DECLARE
  v_oficina NUMBER;
  v_est     WKSP_WORKPLACE.OFICINAS.ESTABLECIMIENTO_SET%TYPE;
BEGIN
  SELECT cc.ID_OFICINA, o.ESTABLECIMIENTO_SET
    INTO v_oficina, v_est
    FROM WKSP_WORKPLACE.CAJA_CONF cc
    JOIN WKSP_WORKPLACE.OFICINAS  o ON o.CODIGO_OFICINA = cc.ID_OFICINA
   WHERE cc.ID_CAJA_CONF = :NEW.ID_CAJA_CONF;

  IF v_est IS NULL THEN
    RAISE_APPLICATION_ERROR(-20961,
      'OFICINAS.ESTABLECIMIENTO_SET no esta cargado para la oficina '||
      v_oficina||'. Cargarlo antes de crear talonarios para sus cajas.');
  END IF;

  :NEW.ID_OFICINA     := v_oficina;
  :NEW.ESTABLECIMIENTO := v_est;
END;
/
show errors trigger TRG_TALONARIO_DERIVA_OFICINA

prompt == F10.1.4 Verificacion ==
DECLARE
  v_col       PLS_INTEGER;
  v_pobladas  PLS_INTEGER;
  v_no_pobladas PLS_INTEGER;
  v_trg       PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_col FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='OFICINAS'
     AND column_name='ESTABLECIMIENTO_SET';

  SELECT COUNT(*) INTO v_pobladas FROM WKSP_WORKPLACE.OFICINAS
   WHERE ESTABLECIMIENTO_SET IS NOT NULL;

  SELECT COUNT(*) INTO v_no_pobladas FROM WKSP_WORKPLACE.OFICINAS o
   WHERE o.ESTABLECIMIENTO_SET IS NULL
     AND EXISTS (SELECT 1 FROM WKSP_WORKPLACE.TALONARIOS t
                  WHERE t.ID_OFICINA = o.CODIGO_OFICINA);

  SELECT COUNT(*) INTO v_trg FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_TALONARIO_DERIVA_OFICINA'
     AND status='ENABLED';

  IF v_col=0 OR v_trg=0 OR v_no_pobladas>0 THEN
    RAISE_APPLICATION_ERROR(-20963,
      'Verificacion F10.1 fallo: col='||v_col||' trg='||v_trg||
      ' oficinas_con_talonarios_sin_est='||v_no_pobladas);
  END IF;
  DBMS_OUTPUT.PUT_LINE('F10.1 OK. Oficinas con ESTABLECIMIENTO_SET cargado: '||v_pobladas);
END;
/

prompt == F10.1 aplicado correctamente ==

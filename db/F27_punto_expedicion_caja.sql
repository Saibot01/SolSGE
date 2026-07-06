-- ============================================================================
-- F27 - PUNTO_EXPEDICION como propiedad de la CAJA_CONF (cumplimiento SET)
-- ============================================================================
-- Cierra la ultima brecha SET en TALONARIOS. Hasta hoy TALONARIOS.PUNTO_EXPEDICION
-- se tipea a mano en P53, lo que permite que:
--   - dos cajas de la misma oficina declaren el MISMO punto de expedicion, o
--   - una misma caja tenga talonarios con puntos distintos.
-- La SET define el numero como ESTABLECIMIENTO-PUNTO_EXPEDICION-NUMERO, donde el
-- PUNTO_EXPEDICION identifica UNA terminal (caja) dentro de un establecimiento.
--
-- Cambio (espeja F10.1 pero para el punto de expedicion):
--   1. CAJA_CONF gana columna PUNTO_EXPEDICION VARCHAR2(3) (nullable mientras la
--      caja no opere fiscalmente).
--   2. Se puebla desde los talonarios existentes (una fila por caja); si una caja
--      tiene talonarios con puntos divergentes, aborta -20931 (brecha pre-existente
--      a resolver a mano).
--   3. Indice unico parcial UQ_CAJA_CONF_OFI_PUNTO sobre (ID_OFICINA, PUNTO_EXPEDICION)
--      => dos cajas de la misma oficina no pueden compartir punto de expedicion.
--   4. Se reemplaza el trigger TRG_TALONARIO_DERIVA_OFICINA para que ademas derive
--      PUNTO_EXPEDICION desde CAJA_CONF.PUNTO_EXPEDICION. Si es NULL para la caja,
--      aborta -20930 (forzando a cargarlo primero, igual que el establecimiento).
--
-- Pre-requisitos: F10 + F10.1 aplicados.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: @db/F27_punto_expedicion_caja.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

prompt == F27.0 Pre-check (F10/F10.1 aplicados) ==
DECLARE
  v_caja_conf PLS_INTEGER;
  v_est_set   PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_caja_conf FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='TALONARIOS' AND column_name='ID_CAJA_CONF';
  SELECT COUNT(*) INTO v_est_set FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='OFICINAS' AND column_name='ESTABLECIMIENTO_SET';
  IF v_caja_conf = 0 OR v_est_set = 0 THEN
    RAISE_APPLICATION_ERROR(-20933,'F10/F10.1 no aplicados. Aplicar F10_talonarios_set.sql y F10_1_establecimiento.sql primero.');
  END IF;
END;
/

prompt == F27.1 ADD COLUMN CAJA_CONF.PUNTO_EXPEDICION ==
DECLARE
  v_exists PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='CAJA_CONF' AND column_name='PUNTO_EXPEDICION';
  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.CAJA_CONF ADD PUNTO_EXPEDICION VARCHAR2(3)';
    DBMS_OUTPUT.PUT_LINE('Columna PUNTO_EXPEDICION agregada a CAJA_CONF.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Columna PUNTO_EXPEDICION ya existe en CAJA_CONF.');
  END IF;
END;
/

prompt == F27.2 Poblar PUNTO_EXPEDICION desde talonarios existentes ==
DECLARE
  v_divergentes PLS_INTEGER;
  v_pobladas    PLS_INTEGER;
BEGIN
  -- Detectar cajas cuyos talonarios declaran distinto PUNTO_EXPEDICION
  SELECT COUNT(*) INTO v_divergentes
    FROM (SELECT t.ID_CAJA_CONF
            FROM WKSP_WORKPLACE.TALONARIOS t
           GROUP BY t.ID_CAJA_CONF
          HAVING COUNT(DISTINCT t.PUNTO_EXPEDICION) > 1);
  IF v_divergentes > 0 THEN
    RAISE_APPLICATION_ERROR(-20931,
      'Hay '||v_divergentes||' caja(s) con talonarios que declaran distinto '||
      'PUNTO_EXPEDICION. Resolver manualmente antes de F27.');
  END IF;

  UPDATE WKSP_WORKPLACE.CAJA_CONF cc
     SET cc.PUNTO_EXPEDICION = (
          SELECT MAX(t.PUNTO_EXPEDICION)
            FROM WKSP_WORKPLACE.TALONARIOS t
           WHERE t.ID_CAJA_CONF = cc.ID_CAJA_CONF)
   WHERE cc.PUNTO_EXPEDICION IS NULL
     AND EXISTS (SELECT 1 FROM WKSP_WORKPLACE.TALONARIOS t
                  WHERE t.ID_CAJA_CONF = cc.ID_CAJA_CONF);
  v_pobladas := SQL%ROWCOUNT;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Cajas con PUNTO_EXPEDICION poblado: '||v_pobladas);
END;
/

prompt == F27.3 Indice unico (ID_OFICINA, PUNTO_EXPEDICION) ==
DECLARE
  v_exists PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_CAJA_CONF_OFI_PUNTO';
  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE q'[CREATE UNIQUE INDEX WKSP_WORKPLACE.UQ_CAJA_CONF_OFI_PUNTO
      ON WKSP_WORKPLACE.CAJA_CONF (
        CASE WHEN PUNTO_EXPEDICION IS NOT NULL THEN ID_OFICINA END,
        CASE WHEN PUNTO_EXPEDICION IS NOT NULL THEN PUNTO_EXPEDICION END)]';
    DBMS_OUTPUT.PUT_LINE('Indice UQ_CAJA_CONF_OFI_PUNTO creado.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Indice UQ_CAJA_CONF_OFI_PUNTO ya existe.');
  END IF;
END;
/

prompt == F27.4 CREATE OR REPLACE TRG_TALONARIO_DERIVA_OFICINA (deriva tambien PUNTO_EXPEDICION) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_TALONARIO_DERIVA_OFICINA
BEFORE INSERT OR UPDATE OF ID_CAJA_CONF ON WKSP_WORKPLACE.TALONARIOS
FOR EACH ROW
DECLARE
  v_oficina NUMBER;
  v_est     WKSP_WORKPLACE.OFICINAS.ESTABLECIMIENTO_SET%TYPE;
  v_punto   WKSP_WORKPLACE.CAJA_CONF.PUNTO_EXPEDICION%TYPE;
BEGIN
  SELECT cc.ID_OFICINA, o.ESTABLECIMIENTO_SET, cc.PUNTO_EXPEDICION
    INTO v_oficina, v_est, v_punto
    FROM WKSP_WORKPLACE.CAJA_CONF cc
    JOIN WKSP_WORKPLACE.OFICINAS  o ON o.CODIGO_OFICINA = cc.ID_OFICINA
   WHERE cc.ID_CAJA_CONF = :NEW.ID_CAJA_CONF;

  IF v_est IS NULL THEN
    RAISE_APPLICATION_ERROR(-20961,
      'OFICINAS.ESTABLECIMIENTO_SET no esta cargado para la oficina '||
      v_oficina||'. Cargarlo antes de crear talonarios para sus cajas.');
  END IF;

  IF v_punto IS NULL THEN
    RAISE_APPLICATION_ERROR(-20930,
      'CAJA_CONF.PUNTO_EXPEDICION no esta cargado para esta caja. '||
      'Cargarlo en Configuracion de Cajas antes de crear su talonario.');
  END IF;

  :NEW.ID_OFICINA      := v_oficina;
  :NEW.ESTABLECIMIENTO := v_est;
  :NEW.PUNTO_EXPEDICION := v_punto;
END;
/
show errors trigger TRG_TALONARIO_DERIVA_OFICINA

prompt == F27.5 Verificacion ==
DECLARE
  v_col        PLS_INTEGER;
  v_idx        PLS_INTEGER;
  v_trg        PLS_INTEGER;
  v_incoherente PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_col FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='CAJA_CONF' AND column_name='PUNTO_EXPEDICION';

  SELECT COUNT(*) INTO v_idx FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_CAJA_CONF_OFI_PUNTO';

  SELECT COUNT(*) INTO v_trg FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_TALONARIO_DERIVA_OFICINA'
     AND status='ENABLED';

  -- Ningun talonario debe quedar con punto distinto al de su caja
  SELECT COUNT(*) INTO v_incoherente
    FROM WKSP_WORKPLACE.TALONARIOS t
    JOIN WKSP_WORKPLACE.CAJA_CONF cc ON cc.ID_CAJA_CONF = t.ID_CAJA_CONF
   WHERE cc.PUNTO_EXPEDICION IS NOT NULL
     AND t.PUNTO_EXPEDICION <> cc.PUNTO_EXPEDICION;

  IF v_col=0 OR v_idx=0 OR v_trg=0 OR v_incoherente>0 THEN
    RAISE_APPLICATION_ERROR(-20932,
      'Verificacion F27 fallo: col='||v_col||' idx='||v_idx||' trg='||v_trg||
      ' talonarios_incoherentes='||v_incoherente);
  END IF;
  DBMS_OUTPUT.PUT_LINE('F27 OK. Cajas con PUNTO_EXPEDICION cargado, indice y trigger activos.');
END;
/

prompt == F27 aplicado correctamente ==

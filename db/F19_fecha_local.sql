-- ============================================================================
-- F19 - Fecha/hora LOCAL de negocio (fix de zona horaria)
-- ============================================================================
-- El servidor de la BD corre en UTC (DBTIMEZONE = +00:00). Usar SYSDATE como
-- "dia de hoy" adelanta la fecha ~3hs: despues de las 21hs locales SYSDATE ya
-- esta en el dia siguiente. Eso rompia validaciones de negocio (caja del dia,
-- vigencia de talonarios) que rechazaban operaciones legitimas de noche.
--
-- OJO con la zona: el archivo de timezones de la BD tiene reglas viejas de
-- 'America/Asuncion' (aplica DST -> UTC-4 en invierno), cuando Paraguay desde
-- 2024 quedo fijo en UTC-3. Por eso se usa 'America/Argentina/Buenos_Aires'
-- (UTC-3 estable, sin DST), que coincide con la hora local real y con la zona
-- que ya usaban otros componentes (P67).
--
-- FN_HOY   -> fecha local truncada (DATE, sin hora). Reemplaza TRUNC(SYSDATE).
-- FN_AHORA -> fecha+hora local (DATE con hora). Reemplaza SYSDATE de negocio.
--
-- Idempotente: CREATE OR REPLACE, re-correrlo es no-op.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db @db/F19_fecha_local.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_HOY RETURN DATE IS
BEGIN
  RETURN TRUNC(CAST(SYSTIMESTAMP AT TIME ZONE 'America/Argentina/Buenos_Aires' AS DATE));
END FN_HOY;
/

CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_AHORA RETURN DATE IS
BEGIN
  RETURN CAST(SYSTIMESTAMP AT TIME ZONE 'America/Argentina/Buenos_Aires' AS DATE);
END FN_AHORA;
/

-- Verificacion
DECLARE
  v_hoy   DATE := WKSP_WORKPLACE.FN_HOY;
  v_ahora DATE := WKSP_WORKPLACE.FN_AHORA;
BEGIN
  DBMS_OUTPUT.PUT_LINE('FN_HOY   = '||TO_CHAR(v_hoy,  'YYYY-MM-DD HH24:MI:SS'));
  DBMS_OUTPUT.PUT_LINE('FN_AHORA = '||TO_CHAR(v_ahora,'YYYY-MM-DD HH24:MI:SS'));
  DBMS_OUTPUT.PUT_LINE('SYSDATE  = '||TO_CHAR(SYSDATE,'YYYY-MM-DD HH24:MI:SS')||' (UTC, NO usar para negocio)');
END;
/

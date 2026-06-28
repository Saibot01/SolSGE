-- ============================================================================
-- F18 (seed) - Backfill DEMO de la dimension "Vendedor" en ORDENES_VENTA
-- ============================================================================
-- !!! DATOS DE DEMOSTRACION, NO HISTORICO REAL !!!
-- ORDENES_VENTA.USUARIO_CREACION recien existe desde F18 (trigger
-- TRG_OV_USUARIO_CREACION). Las 35 ordenes previas no registraron quien las
-- creo -> backfill IMPOSIBLE de forma fidedigna. Este script SIEMBRA una
-- atribucion de demo para que el Dashboard de Ventas (P133) y el informe (P134)
-- tengan datos en "ventas por vendedor". En la defensa debe presentarse como
-- dato de demostracion, no como atribucion real.
--
-- Criterio (PO 2026-06-26, opcion "reparto entre los 4"):
--   USUARIO_CREACION := COALESCE(
--       USUARIO_APROBACION,                 -- respeta el unico dato real que hay
--                                           --   (10 TCASCO + 1 CBARRIOS)
--       <reparto deterministico por MOD(ID_ORDEN,8)>)  -- el resto, demo
--   Reparto ponderado hacia TCASCO (vendedor principal):
--       MOD 0..3 -> TCASCO    (~50%)
--       MOD 4..5 -> CBARRIOS  (~25%)
--       MOD 6    -> FPAREDES  (~12%)
--       MOD 7    -> NCACERES  (~12%)
--   Codigos = EMPLEADOS.CODIGO_USUARIO (TCASCO=81, CBARRIOS=61, FPAREDES=141,
--   NCACERES=192), mismo formato que estampa el trigger.
--
-- IDEMPOTENTE: solo toca filas con USUARIO_CREACION IS NULL. Re-correrlo no pisa
-- presupuestos nuevos (reales) ni re-aleatoriza los ya sembrados.
-- Pre-requisito: F18 aplicado (columna USUARIO_CREACION existe).
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F18_seed_vendedor_demo.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F18.seed.0 Pre-check (columna USUARIO_CREACION existe) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='ORDENES_VENTA'
     AND column_name='USUARIO_CREACION';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20991,
      'Falta ORDENES_VENTA.USUARIO_CREACION: corra antes db/F18_habilitador_vendedor.sql');
  END IF;
  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F18.seed.1 Backfill demo (solo filas NULL) ==
DECLARE
  v_filas PLS_INTEGER;
BEGIN
  UPDATE WKSP_WORKPLACE.ORDENES_VENTA
     SET usuario_creacion = COALESCE(
           usuario_aprobacion,
           CASE MOD(id_orden, 8)
             WHEN 0 THEN 'TCASCO'  WHEN 1 THEN 'TCASCO'
             WHEN 2 THEN 'TCASCO'  WHEN 3 THEN 'TCASCO'
             WHEN 4 THEN 'CBARRIOS' WHEN 5 THEN 'CBARRIOS'
             WHEN 6 THEN 'FPAREDES'
             ELSE 'NCACERES'
           END)
   WHERE usuario_creacion IS NULL;
  v_filas := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('  + filas sembradas: '||v_filas);
END;
/

prompt == F18.seed.2 Verificacion (distribucion resultante) ==
DECLARE
  v_nulos PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_nulos FROM WKSP_WORKPLACE.ORDENES_VENTA
   WHERE usuario_creacion IS NULL;
  DBMS_OUTPUT.PUT_LINE('  ordenes con vendedor NULL restantes: '||v_nulos);
  FOR r IN (
    SELECT usuario_creacion AS vendedor, COUNT(*) AS cnt,
           COUNT(CASE WHEN estado='FACTURADO' THEN 1 END) AS facturadas
      FROM WKSP_WORKPLACE.ORDENES_VENTA
     GROUP BY usuario_creacion
     ORDER BY cnt DESC
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('  '||RPAD(r.vendedor,12)||' total='||
      LPAD(r.cnt,3)||'  facturadas='||LPAD(r.facturadas,3));
  END LOOP;
  IF v_nulos = 0 THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F18 seed demo OK.');
  ELSE RAISE_APPLICATION_ERROR(-20998,'Quedaron ordenes sin vendedor.'); END IF;
END;
/

commit;
prompt == F18 seed demo - commit hecho ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

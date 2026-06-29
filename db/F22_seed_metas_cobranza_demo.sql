-- ============================================================================
-- F22 - Seed DEMO de Metas de Cobranza (H5)
-- ============================================================================
-- Carga metas de recaudacion de DEMOSTRACION en METAS_COBRANZA (creada en F22)
-- para que el Dashboard de Cobros (P136) muestre el KPI "Cumplimiento meta" y el
-- chart "Recaudacion por sucursal vs. meta" con datos (sin esto quedan en "-" /
-- vacios). Mismo enfoque que el seed de Ventas (F18).
--
-- DATO DE DEMOSTRACION, NO objetivo real: presentarlo asi en la defensa. Las
-- metas reales las carga/edita el PO desde la pantalla de carga (P138) o aca.
--
-- Calibracion (datos vivos 2026-06-29): la unica sucursal con cobranza es
-- Roberto L Petit (CODIGO_OFICINA=1) en jun/2026, neto 1.866.530,4. Meta demo
-- 1.700.000 -> cumplimiento ~110% (sobre meta). El chart/KPI solo muestran
-- periodos+sucursales que TIENEN cobranza (V_COBROS_OFICINA_META se arma desde
-- V_COBROS_NETO_MES); metas de sucursal/mes sin cobranza no se visualizan en el
-- dashboard (si en la pantalla de carga).
--
-- MERGE idempotente por (ID_OFICINA, PERIODO): re-correrlo no duplica y respeta
-- el indice unico UQ_METAS_COBRANZA_OFI_PER. El trigger TRG_METAS_COBRANZA_BI
-- trunca PERIODO a 'MM' igual; usamos el 1ro del mes explicito.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F22_seed_metas_cobranza_demo.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F22 seed metas - MERGE demo ==
MERGE INTO WKSP_WORKPLACE.METAS_COBRANZA d
USING (
  -- Metas DEMO (sucursal, periodo 1ro de mes, monto). Editar/ampliar a gusto.
  SELECT 1 AS id_oficina, DATE '2026-06-01' AS periodo, 1700000 AS monto_meta FROM dual
) s
ON (d.id_oficina = s.id_oficina AND d.periodo = s.periodo)
WHEN MATCHED THEN
  UPDATE SET d.monto_meta = s.monto_meta
WHEN NOT MATCHED THEN
  INSERT (id_oficina, periodo, monto_meta)
  VALUES (s.id_oficina, s.periodo, s.monto_meta);

prompt == Verificacion ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.METAS_COBRANZA;
  DBMS_OUTPUT.PUT_LINE('  METAS_COBRANZA filas: '||v_cnt);
  FOR r IN (
    SELECT oficina, TO_CHAR(periodo,'YYYY-MM') periodo, neto, monto_meta, cumplimiento_pct
      FROM WKSP_WORKPLACE.V_COBROS_OFICINA_META
     WHERE monto_meta IS NOT NULL
     ORDER BY periodo, oficina
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('  '||RPAD(r.oficina,24)||' '||r.periodo
      ||'  neto='||r.neto||'  meta='||r.monto_meta||'  cumpl='||r.cumplimiento_pct||'%');
  END LOOP;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE(CHR(10)||'F22 seed metas demo aplicado (COMMIT).');
END;
/

prompt == F22 seed metas - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

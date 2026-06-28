-- ============================================================================
-- F18 (seed) - Metas de venta DEMO (METAS_VENTA)
-- ============================================================================
-- !!! DATOS DE DEMOSTRACION !!!
-- Siembra metas por VENDEDOR (ID_EMPLEADO) x mes para que el chart
-- "ventas por vendedor vs. meta" (V_VENTAS_VENDEDOR_META, P133) y el informe
-- (P134) muestren cumplimiento. Las define el PO en produccion; esto es solo
-- para la defensa.
--
-- Calibradas contra el neto real (V_VENTAS_NETA_MES) para dar un MIX de
-- cumplimiento (algunos sobre meta, otros debajo). Periodos con ventas:
-- 2025-11 (mes rico, 4 vendedores) y 2026-06 (mes en curso).
--   emp  vendedor   periodo    meta         neto real   ~cumpl.
--   81   TCASCO     2025-11    18.000.000   16.068.000   89%
--   81   TCASCO     2026-06     5.000.000    3.922.720   78%
--   61   CBARRIOS   2025-11    20.000.000   22.692.288   113%
--   61   CBARRIOS   2026-06     4.000.000       62.400   2%
--   192  NCACERES   2025-11    10.000.000   12.836.144   128%
--   141  FPAREDES   2025-11     5.000.000    2.980.000   60%
--
-- IDEMPOTENTE: MERGE por (ID_EMPLEADO, PERIODO) -> re-correrlo re-ajusta el monto,
-- no duplica. Solo toca estas 6 metas de empleado; no pisa otras.
-- Pre-requisito: F18 (METAS_VENTA + TRG_METAS_VENTA_BI) aplicado.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F18_seed_metas_demo.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F18.metas.1 MERGE de metas demo (por empleado x mes) ==
MERGE INTO WKSP_WORKPLACE.METAS_VENTA m
USING (
  SELECT 81  AS id_empleado, DATE '2025-11-01' AS periodo, 18000000 AS monto_meta FROM dual UNION ALL
  SELECT 81,  DATE '2026-06-01',  5000000 FROM dual UNION ALL
  SELECT 61,  DATE '2025-11-01', 20000000 FROM dual UNION ALL
  SELECT 61,  DATE '2026-06-01',  4000000 FROM dual UNION ALL
  SELECT 192, DATE '2025-11-01', 10000000 FROM dual UNION ALL
  SELECT 141, DATE '2025-11-01',  5000000 FROM dual
) s
ON (m.id_empleado = s.id_empleado AND m.periodo = s.periodo)
WHEN MATCHED THEN UPDATE SET m.monto_meta = s.monto_meta
WHEN NOT MATCHED THEN
  INSERT (id_empleado, id_oficina, periodo, monto_meta)
  VALUES (s.id_empleado, NULL, s.periodo, s.monto_meta);

prompt == F18.metas.2 Verificacion (cumplimiento via la vista) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.METAS_VENTA;
  DBMS_OUTPUT.PUT_LINE('  metas en METAS_VENTA: '||v_cnt);
  FOR r IN (
    SELECT TO_CHAR(periodo,'YYYY-MM') mes, vendedor_cod, neto, monto_meta, cumplimiento_pct
    FROM WKSP_WORKPLACE.V_VENTAS_VENDEDOR_META
    WHERE monto_meta IS NOT NULL
    ORDER BY periodo, vendedor_cod
  ) LOOP
    DBMS_OUTPUT.PUT_LINE('  '||r.mes||'  '||RPAD(r.vendedor_cod,10)||
      ' neto='||LPAD(r.neto,11)||' meta='||LPAD(r.monto_meta,11)||
      ' -> '||r.cumplimiento_pct||'%');
  END LOOP;
END;
/

commit;
prompt == F18 seed metas demo - commit hecho ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

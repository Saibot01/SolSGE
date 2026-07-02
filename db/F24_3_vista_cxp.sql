-- ============================================================================
-- F24.3 - Vista de deuda a proveedores (consumo APEX H4)
-- ============================================================================
-- V_CXP_DEUDA: single source of truth para P146 (Deuda a Proveedores) y P147
-- (Generar Orden de Pago). Une CUENTAS_PAGAR con proveedor/persona/comprobante y
-- calcula dias de atraso con FN_HOY (UTC-3), nunca SYSDATE (BD en UTC).
--
-- Idempotente: CREATE OR REPLACE VIEW.
-- Pre-requisitos: F24 H1 (CUENTAS_PAGAR.FECHA_VENCIMIENTO), FN_HOY.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F24_3_vista_cxp.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F24.3 Vista V_CXP_DEUDA ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_CXP_DEUDA AS
SELECT cp.ID_CXP,
       cp.ID_PROVEEDOR,
       TRIM(per.PRIMER_NOMBRE||' '||per.PRIMER_APELLIDO) PROVEEDOR,
       cp.ID_COMPROBANTE,
       comp.NRO_COMPROBANTE,
       comp.FECHA_EMISION,
       cp.TOTAL_A_PAGAR,
       cp.SALDO,
       cp.FECHA_VENCIMIENTO,
       (TRUNC(WKSP_WORKPLACE.FN_HOY) - TRUNC(cp.FECHA_VENCIMIENTO)) AS DIAS_ATRASO,
       CASE
         WHEN cp.ESTADO = 'PAGADA' THEN 'Pagada'
         WHEN cp.SALDO IS NULL OR cp.FECHA_VENCIMIENTO IS NULL THEN 'Sin fecha'
         WHEN TRUNC(cp.FECHA_VENCIMIENTO) >= TRUNC(WKSP_WORKPLACE.FN_HOY) THEN 'Por vencer'
         ELSE 'Vencida'
       END AS SITUACION,
       cp.ESTADO
  FROM WKSP_WORKPLACE.CUENTAS_PAGAR cp
  JOIN WKSP_WORKPLACE.PROVEEDORES pr  ON pr.ID_PERSONA = cp.ID_PROVEEDOR
  LEFT JOIN WKSP_WORKPLACE.PERSONAS per ON per.ID_PERSONA = pr.ID_PERSONA
  LEFT JOIN WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR comp ON comp.ID_COMPROBANTE = cp.ID_COMPROBANTE;

prompt == F24.3 Verificacion ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='V_CXP_DEUDA'
     AND object_type='VIEW' AND status='VALID';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  VIEW V_CXP_DEUDA (VALID)');
  ELSE RAISE_APPLICATION_ERROR(-20939,'V_CXP_DEUDA no valida.'); END IF;
END;
/

prompt == F24.3 - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

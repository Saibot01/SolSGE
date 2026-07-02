-- ============================================================================
-- F24.2 - Backfill de Cuentas por Pagar desde comprobantes historicos
-- ============================================================================
-- H3 del PLAN_CUENTAS_PAGAR.md. Puebla CUENTAS_PAGAR con la deuda de los
-- comprobantes de proveedor ya existentes (el trigger TRG_INS_CUENTAS_PAGAR solo
-- cubre inserciones/updates futuros).
--
-- Decisiones del PO (2026-07-02):
--   * Plazo de pago por proveedor (demo): proveedor 1 -> 30 dias, 101 -> 45 dias.
--   * Los 7 comprobantes historicos no anulados se asumen a CREDITO -> FORMA_PAGO='1'
--     -> TODOS generan CxP (para tener aging real que consume F25). El comprobante
--     21 (FECHA/TOTAL NULL) se excluye solo.
--
-- Como el trigger es AFTER INSERT OR UPDATE, el UPDATE de FORMA_PAGO ya dispara la
-- creacion de la CxP; el INSERT ... WHERE NOT EXISTS explicito queda como respaldo
-- idempotente e independiente del trigger (por si estuviera deshabilitado).
--
-- Rango de error: -20935 (verificacion).
-- Idempotente: plazos con UPDATE puntual; FORMA_PAGO ya '1' -> no cambia; INSERT
-- con NOT EXISTS -> no duplica. Re-correrlo es no-op.
-- Pre-requisitos: F24 H1 (trigger + columnas) aplicado.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F24_2_backfill_cxp.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F24.2.0 Pre-check ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='CUENTAS_PAGAR' AND column_name='FECHA_VENCIMIENTO';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20935,'Falta CUENTAS_PAGAR.FECHA_VENCIMIENTO (aplicar F24 H1 antes).');
  END IF;
  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_INS_CUENTAS_PAGAR' AND status='ENABLED';
  IF v_cnt = 0 THEN
    DBMS_OUTPUT.PUT_LINE('  ! TRG_INS_CUENTAS_PAGAR no habilitado; el backfill usa el INSERT explicito.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F24.2.1 Seed de plazos de pago por proveedor (demo) ==
UPDATE WKSP_WORKPLACE.PROVEEDORES SET PLAZO_PAGO_DIAS = 30
 WHERE ID_PERSONA = 1   AND NVL(PLAZO_PAGO_DIAS,-1) <> 30;
UPDATE WKSP_WORKPLACE.PROVEEDORES SET PLAZO_PAGO_DIAS = 45
 WHERE ID_PERSONA = 101 AND NVL(PLAZO_PAGO_DIAS,-1) <> 45;
COMMIT;

prompt == F24.2.2 Condicion de los historicos: los 7 no anulados a CREDITO ==
-- Dispara TRG_INS_CUENTAS_PAGAR (AFTER UPDATE) -> crea la CxP con el plazo ya seteado.
UPDATE WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
   SET FORMA_PAGO = '1'
 WHERE ESTADO <> 'A'
   AND TOTAL_COMPROBANTE IS NOT NULL
   AND FECHA_EMISION IS NOT NULL
   AND NVL(FORMA_PAGO,'x') <> '1';
COMMIT;

prompt == F24.2.3 Respaldo: INSERT explicito de CxP faltantes (idempotente) ==
INSERT INTO WKSP_WORKPLACE.CUENTAS_PAGAR (
  ID_PROVEEDOR, ID_COMPROBANTE, TOTAL_A_PAGAR, SALDO,
  FECHA_REGISTRO, FECHA_VENCIMIENTO, ESTADO
)
SELECT cp.ID_PROVEEDOR, cp.ID_COMPROBANTE, cp.TOTAL_COMPROBANTE, cp.TOTAL_COMPROBANTE,
       WKSP_WORKPLACE.FN_AHORA,
       TRUNC(cp.FECHA_EMISION) + NVL(pr.PLAZO_PAGO_DIAS, 30),
       'PENDIENTE'
  FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR cp
  JOIN WKSP_WORKPLACE.PROVEEDORES pr ON pr.ID_PERSONA = cp.ID_PROVEEDOR
 WHERE cp.FORMA_PAGO = '1'
   AND cp.ESTADO <> 'A'
   AND cp.TOTAL_COMPROBANTE IS NOT NULL
   AND cp.FECHA_EMISION IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM WKSP_WORKPLACE.CUENTAS_PAGAR x
                    WHERE x.ID_COMPROBANTE = cp.ID_COMPROBANTE);
COMMIT;

prompt == F24.2.4 Verificacion final ==
DECLARE
  v_esperado PLS_INTEGER;
  v_cxp      PLS_INTEGER;
  v_mal      PLS_INTEGER;
  v_c21      PLS_INTEGER;
  v_ok       BOOLEAN := TRUE;
BEGIN
  -- Comprobantes que DEBERIAN tener CxP
  SELECT COUNT(*) INTO v_esperado
    FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
   WHERE FORMA_PAGO='1' AND ESTADO<>'A'
     AND TOTAL_COMPROBANTE IS NOT NULL AND FECHA_EMISION IS NOT NULL;

  SELECT COUNT(*) INTO v_cxp FROM WKSP_WORKPLACE.CUENTAS_PAGAR;

  IF v_cxp = v_esperado THEN
    DBMS_OUTPUT.PUT_LINE('  OK  CxP='||v_cxp||' = comprobantes credito esperados');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  FAIL CxP='||v_cxp||' <> esperados='||v_esperado); v_ok:=FALSE;
  END IF;

  -- Ninguna CxP mal formada (saldo<>total inicial, vto NULL, o total NULL)
  SELECT COUNT(*) INTO v_mal FROM WKSP_WORKPLACE.CUENTAS_PAGAR
   WHERE FECHA_VENCIMIENTO IS NULL OR TOTAL_A_PAGAR IS NULL OR SALDO IS NULL;
  IF v_mal = 0 THEN DBMS_OUTPUT.PUT_LINE('  OK  todas las CxP con total/saldo/vencimiento');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL '||v_mal||' CxP sin total/saldo/vencimiento'); v_ok:=FALSE; END IF;

  -- El comprobante 21 (basura) NO debe tener CxP
  SELECT COUNT(*) INTO v_c21 FROM WKSP_WORKPLACE.CUENTAS_PAGAR WHERE ID_COMPROBANTE = 21;
  IF v_c21 = 0 THEN DBMS_OUTPUT.PUT_LINE('  OK  comprobante 21 (basura) sin CxP');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL comprobante 21 genero CxP'); v_ok:=FALSE; END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F24.2 (backfill) aplicado OK. CxP pobladas: '||v_cxp);
  ELSE RAISE_APPLICATION_ERROR(-20935,'F24.2 verificacion FAIL.'); END IF;
END;
/

prompt == F24.2.5 Resumen de la deuda generada ==
SELECT p.ID_PERSONA proveedor,
       TRIM(per.PRIMER_NOMBRE||' '||per.PRIMER_APELLIDO) nombre,
       cp.ID_COMPROBANTE, cp.TOTAL_A_PAGAR,
       cp.SALDO, TO_CHAR(cp.FECHA_VENCIMIENTO,'YYYY-MM-DD') vto, cp.ESTADO
  FROM WKSP_WORKPLACE.CUENTAS_PAGAR cp
  JOIN WKSP_WORKPLACE.PROVEEDORES p   ON p.ID_PERSONA = cp.ID_PROVEEDOR
  LEFT JOIN WKSP_WORKPLACE.PERSONAS per ON per.ID_PERSONA = p.ID_PERSONA
 ORDER BY cp.FECHA_VENCIMIENTO;

prompt == F24.2 - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

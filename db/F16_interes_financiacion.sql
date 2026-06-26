-- ============================================================================
-- F16 - Interes de Financiacion en la Factura (backend / Hito H1)
-- ============================================================================
-- Implementa PLAN_INTERES_FINANCIACION.md (opcion B - interes en cabecera,
-- scope minimal, aprobado por el PO 2026-06-25).
--
-- Problema que corrige: hoy TRG_INS_CUENTAS_COBRAR re-suma el interes de
-- financiacion (TOTAL * tasa/100) a la CxC y a las cuotas, pero la factura
-- (COMPROBANTES.TOTAL_MONEDA_LOCAL) guarda solo los bienes. Resultado:
--   factura  <  CxC.SALDO == Sum cuotas   (no concilian).
--
-- Opcion B: el interes se guarda como columna de cabecera en COMPROBANTES y P67
-- (H2) lo suma a TOTAL_MONEDA_LOCAL/TOTAL_IVA_10/TOTAL_IVA antes del INSERT. El
-- trigger entonces deja de calcular interes y arma la CxC desde el total YA
-- financiado -> factura == CxC.SALDO == Sum cuotas.
--
-- Este script (H1) hace solo el backend de datos:
--   1. COMPROBANTES.INTERES_FINANCIACION (NUMBER, nullable) - monto del interes
--      con IVA incluido; NULL/0 en contado. El IVA del interes es derivable
--      (INTERES_FINANCIACION * 10/110) y ya queda dentro de TOTAL_IVA_10.
--   2. TRG_INS_CUENTAS_COBRAR v2: deja de re-sumar interes; arma la CxC desde
--      :NEW.TOTAL_MONEDA_LOCAL tal cual. Se preserva intacta la generacion de
--      cuotas (RETURNING ID_CXC, ADD_MONTHS, loop). Solo cambia la linea del
--      interes.
--
-- IMPORTANTE: NO se toca ningun trigger de stock (esa es la ventaja de B).
--
-- Rango de error reservado: -20953 .. -20969.
-- Idempotente: re-correrlo es no-op.
-- Pre-requisitos: COMPROBANTES, CUENTAS_COBRAR(_DET), PLANES_CUOTA y el trigger
-- TRG_INS_CUENTAS_COBRAR existentes (modulo de facturacion a credito, F8/F9).
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db @db/F16_interes_financiacion.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F16.0 Pre-check (tablas y trigger del modulo credito) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='COMPROBANTES';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20953,'Falta COMPROBANTES.'); END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='CUENTAS_COBRAR';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20953,'Falta CUENTAS_COBRAR.'); END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='CUENTAS_COBRAR_DET';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20953,'Falta CUENTAS_COBRAR_DET.'); END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='PLANES_CUOTA';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20953,'Falta PLANES_CUOTA.'); END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_INS_CUENTAS_COBRAR';
  IF v_cnt = 0 THEN RAISE_APPLICATION_ERROR(-20953,'Falta TRG_INS_CUENTAS_COBRAR.'); END IF;

  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F16.1 Columna COMPROBANTES.INTERES_FINANCIACION ==
-- Monto del interes de financiacion (IVA incluido). Nullable: solo la llena la
-- venta a credito (P67, H2); NULL/0 en contado.
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='COMPROBANTES'
     AND column_name='INTERES_FINANCIACION';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.COMPROBANTES ADD (INTERES_FINANCIACION NUMBER)';
    DBMS_OUTPUT.PUT_LINE('  + INTERES_FINANCIACION agregada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = INTERES_FINANCIACION ya existe');
  END IF;
END;
/

prompt == F16.2 TRG_INS_CUENTAS_COBRAR v2 (sin re-sumar interes) ==
-- Cambio unico vs. v1: la factura ya viene financiada (P67 sumo el interes a
-- TOTAL_MONEDA_LOCAL). El trigger NO recalcula interes: arma la CxC y parte las
-- cuotas desde :NEW.TOTAL_MONEDA_LOCAL tal cual -> factura == CxC == Sum cuotas.
-- La generacion de cuotas (RETURNING ID_CXC, ADD_MONTHS, loop) se preserva.
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_INS_CUENTAS_COBRAR
AFTER INSERT ON WKSP_WORKPLACE.COMPROBANTES
FOR EACH ROW
DECLARE
    v_total_a_pagar   NUMBER(12,2);
    v_id_cxc          NUMBER;
    v_cuotas          NUMBER;
    v_monto_cuota     NUMBER(12,2);
    v_monto_i         NUMBER(12,2);
    v_fecha_vto       DATE;
BEGIN
    -- Solo insertar si la forma de pago es '1' (credito o cuotas)
    IF :NEW.FORMA_PAGO = '1' THEN

        -- Buscar el plan de cuotas (cantidad de cuotas)
        SELECT NVL(CUOTAS,1)
        INTO v_cuotas
        FROM PLANES_CUOTA
        WHERE ID_PLAN_CUOTA = :NEW.ID_PLAN_CUOTA;

        -- F16: el interes de financiacion ya viene INCLUIDO en
        -- :NEW.TOTAL_MONEDA_LOCAL (lo setea P67 al facturar a credito). El
        -- trigger ya NO re-suma interes -> factura == CxC.SALDO == Sum cuotas.
        v_total_a_pagar := :NEW.TOTAL_MONEDA_LOCAL;

        -- Insertar cabecera en CUENTAS_COBRAR
        INSERT INTO CUENTAS_COBRAR (
            ID_PERSONA,
            ID_COMPROBANTE,
            TOTAL_A_PAGAR,
            SALDO,
            FECHA_REGISTRO,
            ESTADO
        )
        VALUES (
            :NEW.ID_CLIENTE,
            :NEW.ID_COMPROBANTE,
            v_total_a_pagar,
            v_total_a_pagar,
            SYSDATE,
            'PENDIENTE'
        )
        RETURNING ID_CXC INTO v_id_cxc;

        -- Monto base de cada cuota. ROUND(...,0): los Guaranies (moneda local,
        -- PYG) no llevan centavos -> SIFEN exige montos enteros en gPagCred.
        v_monto_cuota := ROUND(v_total_a_pagar / v_cuotas, 0);
        v_fecha_vto := ADD_MONTHS(TRUNC(:NEW.FECHA), 1);

        -- Generar las cuotas detalle
        FOR i IN 1 .. v_cuotas LOOP
            -- La ultima cuota absorbe el remanente de redondeo para que
            -- Sum(cuotas) == v_total_a_pagar EXACTO (factura == CxC == Sum cuotas,
            -- reconciliacion SIFEN). Las demas llevan el monto base.
            v_monto_i := CASE
                           WHEN i < v_cuotas THEN v_monto_cuota
                           ELSE v_total_a_pagar - v_monto_cuota * (v_cuotas - 1)
                         END;

            INSERT INTO CUENTAS_COBRAR_DET (
                ID_CXC,
                NRO_CUOTA,
                FECHA_VENCIMIENTO,
                MONTO_CUOTA,
                ESTADO
            )
            VALUES (
                v_id_cxc,
                i,
                v_fecha_vto,
                v_monto_i,
                'PENDIENTE'
            );

            v_fecha_vto := ADD_MONTHS(v_fecha_vto, 1); -- siguiente mes
        END LOOP;
    END IF;
END;
/
show errors trigger TRG_INS_CUENTAS_COBRAR

prompt == F16.3 Verificacion final ==
DECLARE
  v_cnt PLS_INTEGER;
  v_ok  BOOLEAN := TRUE;
BEGIN
  -- columna nueva
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='COMPROBANTES'
     AND column_name='INTERES_FINANCIACION';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  COLUMN   COMPROBANTES.INTERES_FINANCIACION');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL COLUMN   COMPROBANTES.INTERES_FINANCIACION'); v_ok:=FALSE; END IF;

  -- trigger valido y habilitado
  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_INS_CUENTAS_COBRAR'
     AND status='ENABLED';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_INS_CUENTAS_COBRAR (ENABLED)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_INS_CUENTAS_COBRAR'); v_ok:=FALSE; END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='TRG_INS_CUENTAS_COBRAR'
     AND object_type='TRIGGER' AND status='VALID';
  IF v_cnt=1 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  TRG_INS_CUENTAS_COBRAR (VALID)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  TRG_INS_CUENTAS_COBRAR no VALID'); v_ok:=FALSE; END IF;

  -- guard: el cuerpo del trigger ya NO debe re-sumar interes (TASA_INTERES).
  -- all_triggers.trigger_body es LONG (no admite LIKE); se usa all_source.
  SELECT COUNT(*) INTO v_cnt FROM all_source
   WHERE owner='WKSP_WORKPLACE' AND name='TRG_INS_CUENTAS_COBRAR'
     AND type='TRIGGER' AND UPPER(text) LIKE '%TASA_INTERES%';
  IF v_cnt=0 THEN DBMS_OUTPUT.PUT_LINE('  OK  TRIGGER  ya no calcula interes (sin TASA_INTERES)');
  ELSE DBMS_OUTPUT.PUT_LINE('  FAIL TRIGGER  todavia referencia TASA_INTERES (doble interes)'); v_ok:=FALSE; END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F16 (H1) aplicado OK.');
  ELSE RAISE_APPLICATION_ERROR(-20969,'F16 verificacion FAIL.'); END IF;
END;
/

prompt == F16 (H1) - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

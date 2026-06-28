-- ============================================================================
-- F17 - Estado y Cierre de Caja  (cierra el modulo de Caja de F8)
-- ============================================================================
-- Implementa el H0 (backend) de PLAN_CIERRE_CAJA.md:
--   1. Columnas de arqueo en CAJA_MONEDAS: MONTO_DECLARADO, MONTO_DIFERENCIA,
--      MONTO_CIERRE_PREV (auditoria del recalculo).
--   2. Vista V_CAJA_SALDO: saldo esperado por moneda con join de moneda
--      NORMALIZADO contra MONEDAS (CODIGO='1' o DESCRIPCION='PYG'), misma fuente
--      de verdad para la pantalla de estado y para el cierre.
--   3. CERRAR_CAJA v3: calcula MONTO_CIERRE desde V_CAJA_SALDO (join correcto) y,
--      si el cajero cargo MONTO_DECLARADO, computa MONTO_DIFERENCIA. Firma
--      backward-compatible (P61 sigue llamando con 2 args).
--   4. Recalculo de cierres historicos mal calculados, guardando el valor previo
--      en MONTO_CIERRE_PREV.
--
-- CONTEXTO DEL BUG (verificado 2026-06-26): CERRAR_CAJA v2 unia
-- MOVIMIENTOS_CAJA.MONEDA = CAJA_MONEDAS.MONEDA con igualdad estricta, pero
-- MOVIMIENTOS_CAJA guarda 'PYG' (texto) en COBRO_CXC y en EGRESO de reverso (F15)
-- mientras CAJA_MONEDAS guarda '1' (codigo). Esos movimientos quedaban fuera del
-- cierre => el efectivo se subvaluaba (caja 67 cerro en 100.000 ignorando ~1,7M).
--
-- Idempotente: re-correrlo es no-op.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db @db/F17_cierre_caja.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == F17.1 Pre-check de dependencias ==
DECLARE
  v_cnt PLS_INTEGER;
  PROCEDURE need(p_name VARCHAR2, p_type VARCHAR2) IS
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_objects
     WHERE owner='WKSP_WORKPLACE' AND object_name=p_name AND object_type=p_type;
    IF v_cnt = 0 THEN
      RAISE_APPLICATION_ERROR(-20940, 'F8 no aplicado o invalido: falta '||p_type||' '||p_name);
    END IF;
  END;
BEGIN
  need('MOVIMIENTOS_CAJA','TABLE');
  need('CAJA_MONEDAS','TABLE');
  need('MONEDAS','TABLE');
  need('CAJAS','TABLE');
  DBMS_OUTPUT.PUT_LINE('  = dependencias OK');
END;
/

prompt == F17.2 Columnas de arqueo en CAJA_MONEDAS ==
DECLARE
  PROCEDURE add_col_if_missing(p_col VARCHAR2, p_def VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name='CAJA_MONEDAS' AND column_name=p_col;
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.CAJA_MONEDAS ADD '||p_col||' '||p_def;
      DBMS_OUTPUT.PUT_LINE('  + columna '||p_col||' agregada');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  = columna '||p_col||' ya existe');
    END IF;
  END;
BEGIN
  add_col_if_missing('MONTO_DECLARADO',   'NUMBER');  -- efectivo contado por el cajero
  add_col_if_missing('MONTO_DIFERENCIA',  'NUMBER');  -- declarado - esperado (sobrante/faltante)
  add_col_if_missing('MONTO_CIERRE_PREV', 'NUMBER');  -- auditoria: cierre previo al recalculo F17
END;
/

prompt == F17.3 Vista V_CAJA_SALDO (saldo esperado, moneda normalizada) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_CAJA_SALDO AS
WITH mov AS (
  SELECT mc.ID_CAJA,
         m.CODIGO_MONEDA AS MONEDA,                              -- normalizada al codigo
         mc.TIPO,
         NVL(mc.TOTAL_MONEDA_ORIGEN, mc.TOTAL_MONEDA_LOCAL) AS MONTO
    FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA mc
    JOIN WKSP_WORKPLACE.MONEDAS m
      ON (m.CODIGO_MONEDA = mc.MONEDA OR m.DESCRIPCION = mc.MONEDA)
)
SELECT cm.ID_CAJA,
       cm.MONEDA,
       cm.MONTO_APERTURA,
       NVL(SUM(CASE WHEN mv.TIPO IN ('INGRESO_VENTA','COBRO_CXC') THEN mv.MONTO END),0) AS INGRESOS,
       NVL(SUM(CASE WHEN mv.TIPO = 'EGRESO'                       THEN mv.MONTO END),0) AS EGRESOS,
       NVL(cm.MONTO_APERTURA,0)
         + NVL(SUM(CASE WHEN mv.TIPO IN ('INGRESO_VENTA','COBRO_CXC') THEN mv.MONTO
                        WHEN mv.TIPO = 'EGRESO'                       THEN -mv.MONTO END),0) AS SALDO_ESPERADO,
       cm.MONTO_CIERRE,
       cm.MONTO_DECLARADO,
       cm.MONTO_DIFERENCIA
  FROM WKSP_WORKPLACE.CAJA_MONEDAS cm
  LEFT JOIN mov mv ON mv.ID_CAJA = cm.ID_CAJA AND mv.MONEDA = cm.MONEDA
 GROUP BY cm.ID_CAJA, cm.MONEDA, cm.MONTO_APERTURA, cm.MONTO_CIERRE,
          cm.MONTO_DECLARADO, cm.MONTO_DIFERENCIA;

prompt == F17.4 CERRAR_CAJA v3 (join normalizado + diferencia de arqueo) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.cerrar_caja(
  p_id_caja IN NUMBER,
  p_usuario IN VARCHAR2
) IS
BEGIN
  UPDATE WKSP_WORKPLACE.CAJAS
     SET ESTADO     = 'C',
         FEC_CIERRE = WKSP_WORKPLACE.FN_AHORA,
         USU_CIERRE = p_usuario
   WHERE ID_CAJA = p_id_caja
     AND ESTADO  = 'A';

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20940, 'No hay caja abierta con id '||p_id_caja);
  END IF;

  -- MONTO_CIERRE = saldo esperado normalizado (V_CAJA_SALDO ya corrige el join de
  -- moneda). Si el cajero cargo MONTO_DECLARADO antes de cerrar (P61), se calcula
  -- la diferencia declarado - esperado.
  FOR reg IN (
    SELECT MONEDA, SALDO_ESPERADO, MONTO_DECLARADO
      FROM WKSP_WORKPLACE.V_CAJA_SALDO
     WHERE ID_CAJA = p_id_caja
  ) LOOP
    UPDATE WKSP_WORKPLACE.CAJA_MONEDAS
       SET MONTO_CIERRE     = reg.SALDO_ESPERADO,
           MONTO_DIFERENCIA = CASE WHEN reg.MONTO_DECLARADO IS NOT NULL
                                   THEN reg.MONTO_DECLARADO - reg.SALDO_ESPERADO
                                   END
     WHERE ID_CAJA = p_id_caja
       AND MONEDA  = reg.MONEDA;
  END LOOP;

  UPDATE WKSP_WORKPLACE.MOVIMIENTOS_CAJA
     SET ESTADO = 'C'
   WHERE ID_CAJA = p_id_caja;

  COMMIT;
END;
/

prompt == F17.5 Recalculo de cierres historicos (con auditoria) ==
DECLARE
  v_upd PLS_INTEGER := 0;
BEGIN
  FOR reg IN (
    SELECT v.ID_CAJA, v.MONEDA, v.SALDO_ESPERADO, cm.MONTO_CIERRE AS ACTUAL
      FROM WKSP_WORKPLACE.V_CAJA_SALDO v
      JOIN WKSP_WORKPLACE.CAJA_MONEDAS cm ON cm.ID_CAJA = v.ID_CAJA AND cm.MONEDA = v.MONEDA
      JOIN WKSP_WORKPLACE.CAJAS        c  ON c.ID_CAJA  = v.ID_CAJA AND c.ESTADO  = 'C'
     WHERE NVL(cm.MONTO_CIERRE, -1) <> NVL(v.SALDO_ESPERADO, -1)
  ) LOOP
    UPDATE WKSP_WORKPLACE.CAJA_MONEDAS
       SET MONTO_CIERRE_PREV = NVL(MONTO_CIERRE_PREV, MONTO_CIERRE),  -- solo la 1a vez
           MONTO_CIERRE      = reg.SALDO_ESPERADO
     WHERE ID_CAJA = reg.ID_CAJA
       AND MONEDA  = reg.MONEDA;
    v_upd := v_upd + 1;
    DBMS_OUTPUT.PUT_LINE('  ~ caja '||reg.ID_CAJA||' mon '||reg.MONEDA||
                         ': '||NVL(TO_CHAR(reg.ACTUAL),'(null)')||' -> '||reg.SALDO_ESPERADO);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('  recalculadas '||v_upd||' filas de cierre');
  COMMIT;
END;
/

prompt == F17.6 Verificacion final ==
DECLARE
  v_ok   BOOLEAN := TRUE;
  v_cnt  PLS_INTEGER;
  v_num  NUMBER;
BEGIN
  -- columnas de arqueo presentes
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='CAJA_MONEDAS'
     AND column_name IN ('MONTO_DECLARADO','MONTO_DIFERENCIA','MONTO_CIERRE_PREV');
  IF v_cnt = 3 THEN DBMS_OUTPUT.PUT_LINE('  OK columnas de arqueo (3/3)');
  ELSE v_ok := FALSE; DBMS_OUTPUT.PUT_LINE('  XX faltan columnas de arqueo ('||v_cnt||'/3)'); END IF;

  -- objetos validos
  FOR r IN (SELECT object_name, object_type, status FROM all_objects
             WHERE owner='WKSP_WORKPLACE'
               AND object_name IN ('V_CAJA_SALDO','CERRAR_CAJA')) LOOP
    IF r.status = 'VALID' THEN DBMS_OUTPUT.PUT_LINE('  OK '||r.object_type||' '||r.object_name);
    ELSE v_ok := FALSE; DBMS_OUTPUT.PUT_LINE('  XX '||r.object_type||' '||r.object_name||' INVALID'); END IF;
  END LOOP;

  -- ningun cierre historico debe quedar desalineado del saldo esperado
  SELECT COUNT(*) INTO v_cnt
    FROM WKSP_WORKPLACE.V_CAJA_SALDO v
    JOIN WKSP_WORKPLACE.CAJAS c ON c.ID_CAJA = v.ID_CAJA AND c.ESTADO = 'C'
   WHERE NVL(v.MONTO_CIERRE,-1) <> NVL(v.SALDO_ESPERADO,-1);
  IF v_cnt = 0 THEN DBMS_OUTPUT.PUT_LINE('  OK cierres historicos alineados');
  ELSE v_ok := FALSE; DBMS_OUTPUT.PUT_LINE('  XX '||v_cnt||' cierres aun desalineados'); END IF;

  -- smoke caso conocido: caja 67 (tenia COBRO_CXC ignorados) debe ser > apertura
  BEGIN
    SELECT SALDO_ESPERADO INTO v_num FROM WKSP_WORKPLACE.V_CAJA_SALDO
     WHERE ID_CAJA = 67 AND MONEDA = '1';
    DBMS_OUTPUT.PUT_LINE('  i caja 67 saldo esperado = '||v_num||' (apertura 100000)');
  EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('  i caja 67 no presente (entorno distinto)'); END;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== F17 H0 OK ==');
  ELSE RAISE_APPLICATION_ERROR(-20940,'F17 H0 incompleto: revisar mensajes XX'); END IF;
END;
/

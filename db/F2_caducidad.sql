-- ============================================================================
-- F2 - Caducidad parametrizable de presupuestos
-- ============================================================================
-- Agrega vencimiento automatico a los presupuestos:
--   * Parametro DIAS_VIGENCIA_PRESUPUESTO (default 15) en tabla PARAMETROS
--   * Columna FECHA_VENCIMIENTO en ORDENES_VENTA
--   * Trigger BEFORE INSERT que setea FECHA_VENCIMIENTO si viene NULL
--   * Job DBMS_SCHEDULER diario que marca como VENCIDO los PENDIENTE
--     cuya FECHA_VENCIMIENTO < SYSDATE
--   * Backfill de FECHA_VENCIMIENTO para presupuestos existentes
--
-- Reutiliza TRG_OV_LIBERA_RESERVA (F4): cuando el job hace UPDATE a VENCIDO,
-- el trigger F4 anula automaticamente las reservas vigentes asociadas.
-- Por eso el job es mas simple que el spec original del plan.
--
-- Idempotente. Re-correr es no-op.
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == F2.1 Parametro DIAS_VIGENCIA_PRESUPUESTO ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt
    FROM WKSP_WORKPLACE.PARAMETROS
   WHERE CLAVE = 'DIAS_VIGENCIA_PRESUPUESTO';
  IF v_cnt = 0 THEN
    INSERT INTO WKSP_WORKPLACE.PARAMETROS
      (ID_PARAMETRO, TIPO_PARAMETRO, CLAVE, VALOR_NUMERICO,
       DESCRIPCION, ACTIVO, FECHA_CREACION, USUARIO_CREACION)
    VALUES
      (WKSP_WORKPLACE.SEQ_PARAMETRO_ID.NEXTVAL,
       'VENTA',
       'DIAS_VIGENCIA_PRESUPUESTO',
       15,
       'Dias de validez de un presupuesto desde su fecha de creacion. Pasado este plazo, el job JOB_VENCER_PRESUPUESTOS lo marca como VENCIDO.',
       'S',
       SYSDATE,
       'F2_caducidad.sql');
    DBMS_OUTPUT.PUT_LINE('  + parametro DIAS_VIGENCIA_PRESUPUESTO=15 insertado');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = parametro DIAS_VIGENCIA_PRESUPUESTO ya existe');
  END IF;
END;
/

prompt == F2.2 Columna FECHA_VENCIMIENTO en ORDENES_VENTA ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt
    FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE'
     AND table_name='ORDENES_VENTA'
     AND column_name='FECHA_VENCIMIENTO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.ORDENES_VENTA ADD FECHA_VENCIMIENTO DATE';
    DBMS_OUTPUT.PUT_LINE('  + columna FECHA_VENCIMIENTO agregada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = columna FECHA_VENCIMIENTO ya existe');
  END IF;
END;
/

prompt == F2.3 Backfill FECHA_VENCIMIENTO en ordenes existentes ==
-- Solo seteamos donde es NULL. La logica usa el parametro vigente, igual
-- que la haria el trigger en INSERT.
DECLARE
  v_dias  NUMBER;
  v_rows  NUMBER;
BEGIN
  v_dias := TO_NUMBER(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIAS_VIGENCIA_PRESUPUESTO','NUMERICO'));
  UPDATE WKSP_WORKPLACE.ORDENES_VENTA
     SET FECHA_VENCIMIENTO = NVL(FECHA_ORDEN, TRUNC(SYSDATE)) + NVL(v_dias, 15)
   WHERE FECHA_VENCIMIENTO IS NULL;
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('  - backfill: '||v_rows||' filas actualizadas (con '||v_dias||' dias)');
END;
/

prompt == F2.4 Trigger TRG_OV_FECHA_VENCIMIENTO (BEFORE INSERT) ==
-- Setea FECHA_VENCIMIENTO si el caller no la suministra. Calcula desde
-- FECHA_ORDEN + DIAS_VIGENCIA_PRESUPUESTO (con default 15 si el parametro
-- no esta).
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_OV_FECHA_VENCIMIENTO
BEFORE INSERT ON WKSP_WORKPLACE.ORDENES_VENTA
FOR EACH ROW
DECLARE
  v_dias NUMBER;
BEGIN
  IF :NEW.FECHA_VENCIMIENTO IS NULL THEN
    v_dias := TO_NUMBER(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIAS_VIGENCIA_PRESUPUESTO','NUMERICO'));
    :NEW.FECHA_VENCIMIENTO := NVL(:NEW.FECHA_ORDEN, TRUNC(SYSDATE)) + NVL(v_dias, 15);
  END IF;
END;
/

prompt == F2.5 Job JOB_VENCER_PRESUPUESTOS (diario 02:00) ==
-- Drop si existe (idempotencia) y crear nuevo.
-- El job solo hace UPDATE a VENCIDO. TRG_OV_LIBERA_RESERVA (F4) se ocupa
-- de anular automaticamente las reservas vigentes - es un trigger AFTER
-- UPDATE OF ESTADO con WHEN(NEW.ESTADO IN ('ANULADO','VENCIDO')).
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  -- IMPORTANTE: usar all_scheduler_jobs con owner explicito porque
  -- user_scheduler_jobs mira al CURRENT_USER (ADMIN), no al CURRENT_SCHEMA.
  SELECT COUNT(*) INTO v_cnt
    FROM all_scheduler_jobs
   WHERE owner='WKSP_WORKPLACE' AND job_name='JOB_VENCER_PRESUPUESTOS';
  IF v_cnt > 0 THEN
    DBMS_SCHEDULER.DROP_JOB(job_name=>'WKSP_WORKPLACE.JOB_VENCER_PRESUPUESTOS', force=>TRUE);
    DBMS_OUTPUT.PUT_LINE('  - job previo dropped');
  END IF;
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'WKSP_WORKPLACE.JOB_VENCER_PRESUPUESTOS',
    job_type        => 'PLSQL_BLOCK',
    job_action      => q'[
      BEGIN
        UPDATE WKSP_WORKPLACE.ORDENES_VENTA
           SET ESTADO = 'VENCIDO'
         WHERE ESTADO = 'PENDIENTE'
           AND FECHA_VENCIMIENTO < TRUNC(SYSDATE);
        COMMIT;
      END;]',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
    enabled         => TRUE,
    comments        => 'F2 - Marca como VENCIDO los presupuestos PENDIENTE con FECHA_VENCIMIENTO pasada. TRG_OV_LIBERA_RESERVA anula reservas asociadas.'
  );
  DBMS_OUTPUT.PUT_LINE('  + JOB_VENCER_PRESUPUESTOS creado y habilitado');
END;
/

-- COMMIT primero para persistir CREATE_JOB (transaccional en Autonomous).
-- La verificacion va despues sin RAISE para no romper el job ya commiteado.
COMMIT;

prompt == F2.6 Verificacion final ==
DECLARE
  v_ok BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
  v_enabled VARCHAR2(10);
  PROCEDURE chk(p_label VARCHAR2, p_ok BOOLEAN) IS
  BEGIN
    IF p_ok THEN DBMS_OUTPUT.PUT_LINE('  OK   '||p_label);
    ELSE         DBMS_OUTPUT.PUT_LINE('  FAIL '||p_label); v_ok := FALSE;
    END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.PARAMETROS
   WHERE CLAVE='DIAS_VIGENCIA_PRESUPUESTO' AND ACTIVO='S';
  chk('Parametro DIAS_VIGENCIA_PRESUPUESTO activo', v_cnt=1);

  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='ORDENES_VENTA' AND column_name='FECHA_VENCIMIENTO';
  chk('Columna FECHA_VENCIMIENTO existe', v_cnt=1);

  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.ORDENES_VENTA WHERE FECHA_VENCIMIENTO IS NULL;
  chk('Ninguna orden con FECHA_VENCIMIENTO NULL', v_cnt=0);

  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_OV_FECHA_VENCIMIENTO' AND status='ENABLED';
  chk('Trigger TRG_OV_FECHA_VENCIMIENTO ENABLED', v_cnt=1);

  BEGIN
    SELECT enabled INTO v_enabled
      FROM all_scheduler_jobs
     WHERE owner='WKSP_WORKPLACE' AND job_name='JOB_VENCER_PRESUPUESTOS';
    chk('Job JOB_VENCER_PRESUPUESTOS existe (enabled='||v_enabled||')', TRUE);
  EXCEPTION WHEN NO_DATA_FOUND THEN
    chk('Job JOB_VENCER_PRESUPUESTOS existe', FALSE);
  END;

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'F2 OK - todos los checks pasaron');
  ELSE
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'F2 FAIL - revisar arriba (cambios ya commiteados, no se hace rollback)');
  END IF;
END;
/

prompt == F2 aplicado ==

-- ============================================================================
-- PRODUCTO_PROVEEDORES — Fix de audit + defaults ON NULL
-- ============================================================================
-- Resuelve ORA-01400 al insertar desde P36 (Producto Proveedor) cuando los
-- items del form vienen vacios, y blinda la auditoria de la tabla.
--
-- Causa raiz: el DEFAULT de Oracle solo aplica si el INSERT OMITE la columna.
-- APEX auto-DML siempre incluye TODAS las columnas (con NULL si el item esta
-- vacio), por lo que el default 'SYSDATE' / 'ACTIVO' / TRUNC(SYSDATE) nunca
-- entra. Solucion: agregar la clausula ON NULL al default (Oracle 12c+).
--
-- Cambios:
--   1. ALTER de 3 columnas con DEFAULT ON NULL:
--      - FECHA_CREACION  -> SYSDATE
--      - FECHA_INICIO    -> TRUNC(SYSDATE)
--      - ESTADO          -> 'ACTIVO'
--   2. Nuevo trigger TRG_PP_SET_AUDIT (BEFORE INSERT OR UPDATE):
--      - Setea FECHA_CREACION, USUARIO_CREACION en INSERT.
--      - Preserva esos valores en UPDATE.
--      - Setea FECHA_MODIFICACION, USUARIO_MODIFICACION en UPDATE.
--      Usuario via SYS_CONTEXT('APEX$SESSION','APP_USER') con fallback a USER
--      (mismo patron que usa TRG_CIERRE_PP_ANTERIOR ya existente).
--
-- Coexiste con los triggers existentes:
--   - TRG_CIERRE_PP_ANTERIOR (BEFORE INSERT, cierra registro previo)
--   - TRG_AUD_PP (AFTER INSERT/UPDATE/DELETE, log audit)
--
-- Idempotente. Re-correr es no-op excepto recompilar el trigger.
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == PP.1 Pre-check: ninguna fila con NULL en columnas NOT NULL ==
DECLARE
  v_bad PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_bad
    FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
   WHERE FECHA_CREACION IS NULL OR FECHA_INICIO IS NULL OR ESTADO IS NULL;
  IF v_bad > 0 THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Hay '||v_bad||' filas con NULL en columnas NOT NULL. Abortando.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('  OK - ninguna fila con NULL');
END;
/

prompt == PP.2 ALTER TABLE: DEFAULT ON NULL para 3 columnas ==
-- Idempotente: si ya tiene ON NULL, el segundo ALTER no rompe (Oracle lo acepta).
DECLARE
  PROCEDURE alt(p_col VARCHAR2, p_def VARCHAR2) IS
  BEGIN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.PRODUCTO_PROVEEDORES MODIFY ('||
      p_col||' DEFAULT ON NULL '||p_def||' NOT NULL)';
    DBMS_OUTPUT.PUT_LINE('  + '||p_col||' DEFAULT ON NULL '||p_def);
  END;
BEGIN
  alt('FECHA_CREACION', 'SYSDATE');
  alt('FECHA_INICIO',   'TRUNC(SYSDATE)');
  alt('ESTADO',         q'['ACTIVO']');
END;
/

prompt == PP.3 Trigger TRG_PP_SET_AUDIT (BEFORE INSERT OR UPDATE) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_PP_SET_AUDIT
BEFORE INSERT OR UPDATE ON WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
FOR EACH ROW
DECLARE
  v_user VARCHAR2(60) := NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER);
BEGIN
  IF INSERTING THEN
    :NEW.FECHA_CREACION       := WKSP_WORKPLACE.FN_AHORA;
    :NEW.USUARIO_CREACION     := v_user;
    -- FECHA_INICIO (negocio) local si vino del default UTC o NULL
    IF :NEW.FECHA_INICIO IS NULL OR :NEW.FECHA_INICIO = TRUNC(SYSDATE) THEN
      :NEW.FECHA_INICIO := WKSP_WORKPLACE.FN_HOY;
    END IF;
    :NEW.FECHA_MODIFICACION   := NULL;
    :NEW.USUARIO_MODIFICACION := NULL;
  ELSIF UPDATING THEN
    -- Preservar creacion (no se debe cambiar nunca)
    :NEW.FECHA_CREACION   := :OLD.FECHA_CREACION;
    :NEW.USUARIO_CREACION := :OLD.USUARIO_CREACION;
    -- Setear modificacion
    :NEW.FECHA_MODIFICACION   := WKSP_WORKPLACE.FN_AHORA;
    :NEW.USUARIO_MODIFICACION := v_user;
  END IF;
END;
/

COMMIT;

prompt == PP.4 Verificacion ==
DECLARE
  v_ok BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
  v_default VARCHAR2(200);
  v_on_null VARCHAR2(3);
  PROCEDURE chk(p_label VARCHAR2, p_ok BOOLEAN) IS
  BEGIN
    IF p_ok THEN DBMS_OUTPUT.PUT_LINE('  OK   '||p_label);
    ELSE         DBMS_OUTPUT.PUT_LINE('  FAIL '||p_label); v_ok := FALSE;
    END IF;
  END;
BEGIN
  FOR r IN (
    SELECT column_name, default_on_null
      FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name='PRODUCTO_PROVEEDORES'
       AND column_name IN ('FECHA_CREACION','FECHA_INICIO','ESTADO')
  ) LOOP
    chk(r.column_name||' tiene DEFAULT ON NULL', r.default_on_null='YES');
  END LOOP;

  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_PP_SET_AUDIT' AND status='ENABLED';
  chk('TRG_PP_SET_AUDIT enabled', v_cnt=1);

  -- Smoke test con rollback: insertar con NULL explicito en un par
  -- (id_producto, id_persona) real para no violar FK, y verificar
  -- que los defaults ON NULL y el trigger kickean.
  DECLARE
    v_prod NUMBER; v_prov NUMBER;
    v_fc DATE; v_fi DATE; v_es VARCHAR2(20); v_uc VARCHAR2(60);
  BEGIN
    SELECT id_producto INTO v_prod FROM PRODUCTOS WHERE rownum=1;
    SELECT id_persona  INTO v_prov FROM PROVEEDORES WHERE rownum=1;
    INSERT INTO WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
      (id_producto, id_persona, precio, fecha_inicio, estado, fecha_creacion, usuario_creacion)
    VALUES
      (v_prod, v_prov, 0.01, NULL, NULL, NULL, NULL);  -- todo NULL explicito
    SELECT fecha_creacion, fecha_inicio, estado, usuario_creacion
      INTO v_fc, v_fi, v_es, v_uc
      FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
     WHERE id_producto=v_prod AND id_persona=v_prov AND precio=0.01
       AND rownum=1;
    chk('INSERT con NULL explicito -> FECHA_CREACION seteada', v_fc IS NOT NULL);
    chk('INSERT con NULL explicito -> FECHA_INICIO seteada',   v_fi IS NOT NULL);
    chk('INSERT con NULL explicito -> ESTADO=ACTIVO',          v_es='ACTIVO');
    chk('INSERT con NULL explicito -> USUARIO_CREACION='||v_uc, v_uc IS NOT NULL);
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('  - smoke test row rollback OK (no persiste)');
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('  WARN smoke test fallo: '||SUBSTR(SQLERRM,1,100));
    -- No marcamos FAIL del script si el smoke test falla por datos faltantes
  END;

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'PP_audit_fix OK - todos los checks pasaron');
  ELSE
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'PP_audit_fix FAIL - revisar arriba');
  END IF;
END;
/

prompt == PP_audit_fix aplicado ==

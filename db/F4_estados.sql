-- ============================================================================
-- F4 - Estados del Presupuesto / Orden de Venta
-- ============================================================================
-- Captura idempotente del estado actual en la BD live para WKSP_WORKPLACE.
-- Implementa la Feature 4 de PLAN_VENTAS.md: ciclo completo de estados
-- PENDIENTE -> APROBADO -> FACTURADO / ANULADO / VENCIDO con funcion guardiana
-- y triggers que mantienen la integridad de RESERVAS_PRODUCTO.
--
-- Aplicado originalmente en sesion no versionada (anterior al 2026-05-26).
-- Este archivo refleja el codigo extraido de la BD live, hecho idempotente.
-- Re-correrlo contra la BD ya cargada debe ser no-op.
--
-- Conexion sugerida: SQLCL_CONNECTION=tesis_db (current_schema = WKSP_WORKPLACE)
-- Ejecucion:  @db/F4_estados.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == F4.1 Migracion de datos heredados ==
-- Normaliza valores existentes antes del CHECK. NULL y variantes camelCase
-- pasaron a PENDIENTE; valores ya correctos no se tocan.
UPDATE WKSP_WORKPLACE.ORDENES_VENTA
   SET ESTADO = 'PENDIENTE'
 WHERE ESTADO IS NULL OR (UPPER(ESTADO) = 'PENDIENTE' AND ESTADO <> 'PENDIENTE');

UPDATE WKSP_WORKPLACE.ORDENES_VENTA
   SET ESTADO = 'FACTURADO'
 WHERE UPPER(ESTADO) = 'FACTURADO' AND ESTADO <> 'FACTURADO';

prompt == F4.2 Columnas de auditoria (idempotente) ==
DECLARE
  PROCEDURE add_col_if_missing(p_col VARCHAR2, p_def VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt
      FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name='ORDENES_VENTA' AND column_name=p_col;
    IF v_cnt = 0 THEN
      EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.ORDENES_VENTA ADD '||p_col||' '||p_def;
      DBMS_OUTPUT.PUT_LINE('  + columna '||p_col||' agregada');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  = columna '||p_col||' ya existe');
    END IF;
  END;
BEGIN
  add_col_if_missing('FECHA_APROBACION',   'DATE');
  add_col_if_missing('USUARIO_APROBACION', 'VARCHAR2(60)');
  add_col_if_missing('FECHA_ANULACION',    'DATE');
  add_col_if_missing('USUARIO_ANULACION',  'VARCHAR2(60)');
  add_col_if_missing('MOTIVO_ANULACION',   'VARCHAR2(400)');
END;
/

prompt == F4.3 CHECK constraint CK_OV_ESTADO (idempotente) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt
    FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND table_name='ORDENES_VENTA' AND constraint_name='CK_OV_ESTADO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE q'[
      ALTER TABLE WKSP_WORKPLACE.ORDENES_VENTA ADD CONSTRAINT CK_OV_ESTADO
        CHECK (ESTADO IN ('PENDIENTE','APROBADO','FACTURADO','ANULADO','VENCIDO'))
    ]';
    DBMS_OUTPUT.PUT_LINE('  + CK_OV_ESTADO agregado');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = CK_OV_ESTADO ya existe');
  END IF;
END;
/

prompt == F4.4 Funcion guardiana FN_PUEDE_TRANSICION_OV ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_PUEDE_TRANSICION_OV (
  p_actual  IN VARCHAR2,
  p_destino IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
  RETURN CASE
    WHEN p_actual = 'PENDIENTE' AND p_destino IN ('APROBADO','ANULADO','VENCIDO') THEN 'S'
    WHEN p_actual = 'APROBADO'  AND p_destino IN ('FACTURADO','ANULADO')          THEN 'S'
    ELSE 'N'
  END;
END;
/

prompt == F4.5 Trigger TRG_FACTURA_ORDEN (endurecido) ==
-- Valida que la orden este en estado APROBADO antes de marcarla FACTURADO.
-- Usa la funcion guardiana en vez de comparar string para mantener una
-- sola fuente de verdad del modelo de transiciones.
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_FACTURA_ORDEN
AFTER INSERT ON WKSP_WORKPLACE.COMPROBANTES
FOR EACH ROW
DECLARE
  v_estado_actual WKSP_WORKPLACE.ORDENES_VENTA.ESTADO%TYPE;
BEGIN
  IF :NEW.ID_ORDEN_VENTA IS NULL THEN
    RETURN;
  END IF;
  SELECT ESTADO
    INTO v_estado_actual
    FROM WKSP_WORKPLACE.ORDENES_VENTA
   WHERE ID_ORDEN = :NEW.ID_ORDEN_VENTA
     FOR UPDATE;
  IF WKSP_WORKPLACE.FN_PUEDE_TRANSICION_OV(v_estado_actual, 'FACTURADO') <> 'S' THEN
    RAISE_APPLICATION_ERROR(
      -20010,
      'No se puede facturar el presupuesto #' || :NEW.ID_ORDEN_VENTA ||
      '. Estado actual: ' || v_estado_actual ||
      '. Solo se pueden facturar presupuestos en estado APROBADO.'
    );
  END IF;
  UPDATE WKSP_WORKPLACE.ORDENES_VENTA
     SET ESTADO = 'FACTURADO'
   WHERE ID_ORDEN = :NEW.ID_ORDEN_VENTA;
END;
/

prompt == F4.6 Trigger TRG_GENERAR_RESERVA_ORDEN (filtrado por estado) ==
-- Solo crea reserva si la orden esta en PENDIENTE o APROBADO. Evita reservas
-- zombi cuando se edita una orden anulada/vencida.
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_GENERAR_RESERVA_ORDEN
AFTER INSERT ON WKSP_WORKPLACE.DETALLE_ORDEN
FOR EACH ROW
DECLARE
  v_id_oficina WKSP_WORKPLACE.ORDENES_VENTA.ID_OFICINA%TYPE;
  v_estado     WKSP_WORKPLACE.ORDENES_VENTA.ESTADO%TYPE;
BEGIN
  SELECT ID_OFICINA, ESTADO
    INTO v_id_oficina, v_estado
    FROM WKSP_WORKPLACE.ORDENES_VENTA
   WHERE ID_ORDEN = :NEW.ID_ORDEN;
  IF v_estado NOT IN ('PENDIENTE','APROBADO') THEN
    RETURN;
  END IF;
  INSERT INTO WKSP_WORKPLACE.RESERVAS_PRODUCTO (
    ID_PRODUCTO,
    ID_OFICINA,
    CANTIDAD_RESERVADA,
    FECHA_RESERVA,
    ESTADO,
    OBSERVACION,
    ID_ORDEN_VENTA
  )
  VALUES (
    :NEW.ID_PRODUCTO,
    v_id_oficina,
    :NEW.CANTIDAD,
    WKSP_WORKPLACE.FN_AHORA,
    'VIGENTE',
    'Reserva automatica desde orden',
    :NEW.ID_ORDEN
  );
END;
/

prompt == F4.7 Trigger TRG_OV_LIBERA_RESERVA (libera reservas al anular/vencer) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_OV_LIBERA_RESERVA
AFTER UPDATE OF ESTADO ON WKSP_WORKPLACE.ORDENES_VENTA
FOR EACH ROW
WHEN (NEW.ESTADO IN ('ANULADO','VENCIDO') AND OLD.ESTADO IN ('PENDIENTE','APROBADO'))
BEGIN
  UPDATE WKSP_WORKPLACE.RESERVAS_PRODUCTO
     SET ESTADO = 'ANULADA'
   WHERE ID_ORDEN_VENTA = :NEW.ID_ORDEN
     AND ESTADO = 'VIGENTE';
END;
/

prompt == F4.8 Verificacion final ==
DECLARE
  v_ok BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
  PROCEDURE chk(p_label VARCHAR2, p_expected BOOLEAN, p_actual BOOLEAN) IS
  BEGIN
    IF p_expected = p_actual THEN
      DBMS_OUTPUT.PUT_LINE('  OK   '||p_label);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL '||p_label);
      v_ok := FALSE;
    END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='CK_OV_ESTADO';
  chk('CK_OV_ESTADO existe', TRUE, v_cnt>0);

  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_PUEDE_TRANSICION_OV' AND status='VALID';
  chk('FN_PUEDE_TRANSICION_OV VALID', TRUE, v_cnt>0);

  SELECT COUNT(*) INTO v_cnt FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name IN
         ('TRG_FACTURA_ORDEN','TRG_GENERAR_RESERVA_ORDEN','TRG_OV_LIBERA_RESERVA')
     AND status='ENABLED';
  chk('3 triggers F4 ENABLED', TRUE, v_cnt=3);

  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='ORDENES_VENTA'
     AND column_name IN ('FECHA_APROBACION','USUARIO_APROBACION',
                         'FECHA_ANULACION','USUARIO_ANULACION','MOTIVO_ANULACION');
  chk('5 columnas auditoria', TRUE, v_cnt=5);

  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.ORDENES_VENTA
   WHERE ESTADO IS NULL OR ESTADO NOT IN
         ('PENDIENTE','APROBADO','FACTURADO','ANULADO','VENCIDO');
  chk('Sin valores ESTADO invalidos', TRUE, v_cnt=0);

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'F4 OK - todos los checks pasaron');
  ELSE
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'F4 FAIL - revisar errores arriba');
    RAISE_APPLICATION_ERROR(-20999,'F4 verification failed');
  END IF;
END;
/

COMMIT;
prompt == F4 aplicado ==

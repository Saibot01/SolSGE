-- ============================================================================
-- F9 - Cobro de cuotas de CxC
-- ============================================================================
-- Implementa la Feature 9 de PLAN_FACTURACION.md:
--   1. Normalizacion de datos: CUENTAS_COBRAR_DET.ESTADO 'PAGADO' -> 'PAGADA'
--   2. Reset del caso de prueba CXC id=2 (cuotas a PENDIENTE, SALDO=TOTAL)
--   3. Extension DETALLE_MOVIMIENTO_CAJA con ID_METODO_PAGO (FK METODOS_PAGO)
--   4. Constraints CK_CCD_ESTADO / CK_CXC_ESTADO
--   5. FN_COBRAR_CUOTA: atomica, reserva nro recibo, baja saldo, devuelve NRO_RECIBO
--   6. JOB_VENCER_CUOTAS: marca cuotas vencidas diariamente (DAILY 02:00)
--
-- Idempotente: re-correrlo es no-op.
--
-- Pre-requisitos: F8_facturacion.sql aplicado (MOVIMIENTOS_CAJA + FN_OBTENER_COMPROBANTE
-- + talonario RC vigente).
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: @db/F9_cobros.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == F9.1 Pre-check (F8 aplicado + talonario RC vigente) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  -- MOVIMIENTOS_CAJA debe existir (F8.A)
  SELECT COUNT(*) INTO v_cnt FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='MOVIMIENTOS_CAJA';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20901,'F8 no aplicado: falta MOVIMIENTOS_CAJA. Corra db/F8_facturacion.sql primero.');
  END IF;

  -- FN_OBTENER_COMPROBANTE debe existir (F8.A — reescritura atomica)
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_OBTENER_COMPROBANTE'
     AND object_type='FUNCTION' AND status='VALID';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20902,'F8 no aplicado o invalido: FN_OBTENER_COMPROBANTE no esta valida.');
  END IF;

  -- Talonario RC vigente
  SELECT COUNT(*) INTO v_cnt
    FROM WKSP_WORKPLACE.TALONARIOS
   WHERE TIPO_COMPROBANTE='RC'
     AND ACTIVO='S'
     AND TRUNC(SYSDATE) BETWEEN FECHA_INICIO AND FECHA_FIN;
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20903,'No hay talonario RC vigente. Cargue uno antes de aplicar F9.');
  END IF;

  DBMS_OUTPUT.PUT_LINE('  = Pre-check OK');
END;
/

prompt == F9.2 Normalizar CUENTAS_COBRAR_DET.ESTADO 'PAGADO' -> 'PAGADA' ==
DECLARE
  v_rows PLS_INTEGER;
BEGIN
  UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR_DET
     SET ESTADO='PAGADA'
   WHERE ESTADO='PAGADO';
  v_rows := SQL%ROWCOUNT;
  IF v_rows > 0 THEN
    DBMS_OUTPUT.PUT_LINE('  + '||v_rows||' cuotas normalizadas PAGADO -> PAGADA');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = Sin filas que normalizar');
  END IF;
  COMMIT;
END;
/

prompt == F9.3 Reset del caso de prueba CxC id=2 (cuotas -> PENDIENTE, SALDO=TOTAL) ==
DECLARE
  v_rows PLS_INTEGER;
  v_total NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_rows FROM WKSP_WORKPLACE.CUENTAS_COBRAR WHERE ID_CXC=2;
  IF v_rows = 0 THEN
    DBMS_OUTPUT.PUT_LINE('  = CxC id=2 no existe, nada que resetear');
    RETURN;
  END IF;

  UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR_DET
     SET ESTADO='PENDIENTE'
   WHERE ID_CXC=2
     AND ESTADO <> 'PENDIENTE';
  v_rows := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('  + '||v_rows||' cuotas reseteadas a PENDIENTE');

  SELECT TOTAL_A_PAGAR INTO v_total FROM WKSP_WORKPLACE.CUENTAS_COBRAR WHERE ID_CXC=2;
  UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR
     SET SALDO = v_total, ESTADO='PENDIENTE'
   WHERE ID_CXC=2;
  DBMS_OUTPUT.PUT_LINE('  + CxC id=2 SALDO restaurado a '||v_total||' y ESTADO=PENDIENTE');

  -- Borrar movimientos de cobro previos sobre cuotas de la CxC=2 (datos sucios de prueba)
  DELETE FROM WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA
   WHERE ID_MOVIMIENTO IN (
     SELECT ID_MOVIMIENTO FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA
      WHERE TIPO='COBRO_CXC'
        AND ID_CUENTA_COBRAR_DET IN (SELECT ID_DETALLE FROM WKSP_WORKPLACE.CUENTAS_COBRAR_DET WHERE ID_CXC=2)
   );
  DELETE FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA
   WHERE TIPO='COBRO_CXC'
     AND ID_CUENTA_COBRAR_DET IN (SELECT ID_DETALLE FROM WKSP_WORKPLACE.CUENTAS_COBRAR_DET WHERE ID_CXC=2);

  COMMIT;
END;
/

prompt == F9.4 Extender DETALLE_MOVIMIENTO_CAJA con ID_METODO_PAGO ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE'
     AND table_name='DETALLE_MOVIMIENTO_CAJA'
     AND column_name='ID_METODO_PAGO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA ADD (ID_METODO_PAGO NUMBER NULL)';
    DBMS_OUTPUT.PUT_LINE('  + DETALLE_MOVIMIENTO_CAJA.ID_METODO_PAGO agregada');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = DETALLE_MOVIMIENTO_CAJA.ID_METODO_PAGO ya existe');
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='FK_DETMOVCAJA_METPAG';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA
         ADD CONSTRAINT FK_DETMOVCAJA_METPAG
         FOREIGN KEY (ID_METODO_PAGO) REFERENCES WKSP_WORKPLACE.METODOS_PAGO(ID_METODO_PAGO)';
    DBMS_OUTPUT.PUT_LINE('  + FK_DETMOVCAJA_METPAG creado');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = FK_DETMOVCAJA_METPAG ya existe');
  END IF;
END;
/

prompt == F9.5 Constraints CK_CCD_ESTADO + CK_CXC_ESTADO ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  -- CK_CCD_ESTADO: estados validos de cuota
  SELECT COUNT(*) INTO v_cnt FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='CK_CCD_ESTADO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.CUENTAS_COBRAR_DET
         ADD CONSTRAINT CK_CCD_ESTADO
         CHECK (ESTADO IN (''PENDIENTE'',''PAGADA'',''VENCIDA''))';
    DBMS_OUTPUT.PUT_LINE('  + CK_CCD_ESTADO creado');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = CK_CCD_ESTADO ya existe');
  END IF;

  -- CK_CXC_ESTADO: estados validos de cuenta global
  SELECT COUNT(*) INTO v_cnt FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='CK_CXC_ESTADO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.CUENTAS_COBRAR
         ADD CONSTRAINT CK_CXC_ESTADO
         CHECK (ESTADO IN (''PENDIENTE'',''PAGADA''))';
    DBMS_OUTPUT.PUT_LINE('  + CK_CXC_ESTADO creado');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  = CK_CXC_ESTADO ya existe');
  END IF;
END;
/

prompt == F9.6 FN_COBRAR_CUOTA (atomica) ==
-- Nota semantica: p_monto_pago es lo que el cajero recibio del cliente; se valida
-- contra MONTO_CUOTA (debe ser >=). El MOVIMIENTOS_CAJA y su detalle se registran
-- con MONTO_CUOTA (no p_monto_pago) — el vuelto = p_monto_pago - MONTO_CUOTA se
-- muestra en la UI pero no se persiste como movimiento.
CREATE OR REPLACE FUNCTION FN_COBRAR_CUOTA (
  p_id_detalle      IN NUMBER,
  p_id_caja         IN NUMBER,
  p_id_talonario_rc IN NUMBER,
  p_id_forma_pago   IN NUMBER,
  p_id_metodo_pago  IN NUMBER,
  p_monto_pago      IN NUMBER,
  p_moneda          IN VARCHAR2 DEFAULT 'PYG',
  p_nro_ref         IN VARCHAR2 DEFAULT NULL,
  p_usuario         IN VARCHAR2 DEFAULT V('APP_USER')
) RETURN VARCHAR2
IS
  v_cuota   WKSP_WORKPLACE.CUENTAS_COBRAR_DET%ROWTYPE;
  v_cxc     WKSP_WORKPLACE.CUENTAS_COBRAR%ROWTYPE;
  v_caja    WKSP_WORKPLACE.CAJAS%ROWTYPE;
  v_talon   WKSP_WORKPLACE.TALONARIOS%ROWTYPE;
  v_nro_rec VARCHAR2(20);
  v_id_mov  NUMBER;
  v_nuevo_saldo NUMBER;
  v_monto_mov NUMBER;
BEGIN
  -- 1) Lockear cuota y validar estado
  BEGIN
    SELECT * INTO v_cuota
      FROM WKSP_WORKPLACE.CUENTAS_COBRAR_DET
     WHERE ID_DETALLE = p_id_detalle
       FOR UPDATE;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20910,'Cuota no encontrada.');
  END;

  IF v_cuota.ESTADO NOT IN ('PENDIENTE','VENCIDA') THEN
    RAISE_APPLICATION_ERROR(-20911,'La cuota no esta en estado cobrable (estado actual: '||v_cuota.ESTADO||').');
  END IF;

  IF p_monto_pago < v_cuota.MONTO_CUOTA THEN
    RAISE_APPLICATION_ERROR(-20912,'El monto pagado ('||p_monto_pago||') es menor al monto de la cuota ('||v_cuota.MONTO_CUOTA||').');
  END IF;

  v_monto_mov := v_cuota.MONTO_CUOTA;

  -- 2) Lockear cabecera CxC
  SELECT * INTO v_cxc
    FROM WKSP_WORKPLACE.CUENTAS_COBRAR
   WHERE ID_CXC = v_cuota.ID_CXC
     FOR UPDATE;

  -- 3) Validar caja abierta y del usuario
  BEGIN
    SELECT * INTO v_caja
      FROM WKSP_WORKPLACE.CAJAS
     WHERE ID_CAJA = p_id_caja;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20913,'Caja no encontrada.');
  END;
  IF v_caja.ESTADO IS NULL OR v_caja.ESTADO <> 'A' THEN
    RAISE_APPLICATION_ERROR(-20914,'La caja no esta abierta.');
  END IF;

  -- 4) Validar talonario y oficina (debe ser RC vigente y de la oficina de la caja)
  BEGIN
    SELECT * INTO v_talon
      FROM WKSP_WORKPLACE.TALONARIOS
     WHERE ID_TALONARIO = p_id_talonario_rc;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20915,'Talonario de recibo no encontrado.');
  END;
  IF v_talon.TIPO_COMPROBANTE <> 'RC' THEN
    RAISE_APPLICATION_ERROR(-20916,'El talonario indicado no es de tipo RC (recibo).');
  END IF;
  IF v_talon.ID_OFICINA <> v_caja.ID_OFICINA THEN
    RAISE_APPLICATION_ERROR(-20917,'El talonario no pertenece a la oficina de la caja.');
  END IF;

  -- 5) Reservar nro de recibo (atomica, reusa FN_OBTENER_COMPROBANTE de F8)
  v_nro_rec := FN_OBTENER_COMPROBANTE(p_id_talonario_rc);

  -- 6) Insertar cabecera MOVIMIENTOS_CAJA TIPO='COBRO_CXC'
  INSERT INTO WKSP_WORKPLACE.MOVIMIENTOS_CAJA (
    ID_CLIENTE, ID_CAJA, FECHA,
    TOTAL_MONEDA_LOCAL, MONEDA, TIPO_CAMBIO, TOTAL_MONEDA_ORIGEN,
    ESTADO, TIPO, USUARIO,
    NRO_RECIBO, ID_TALONARIO_RECIBO, FECHA_EMISION_RECIBO, ID_CUENTA_COBRAR_DET
  ) VALUES (
    v_cxc.ID_PERSONA, p_id_caja, WKSP_WORKPLACE.FN_AHORA,
    v_monto_mov, NVL(p_moneda,'PYG'), 1, v_monto_mov,
    'A', 'COBRO_CXC', p_usuario,
    v_nro_rec, p_id_talonario_rc, WKSP_WORKPLACE.FN_HOY, p_id_detalle
  ) RETURNING ID_MOVIMIENTO INTO v_id_mov;

  -- 7) Detalle por forma+metodo de pago
  INSERT INTO WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA (
    ID_MOVIMIENTO, ID_FORMA_PAGO, ID_METODO_PAGO,
    MONTO_LOCAL, MONTO_ORIGEN, MONEDA, TIPO_CAMBIO, NRO_REFERENCIA
  ) VALUES (
    v_id_mov, p_id_forma_pago, p_id_metodo_pago,
    v_monto_mov, v_monto_mov, NVL(p_moneda,'PYG'), 1, p_nro_ref
  );

  -- 8) Cuota -> PAGADA
  UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR_DET
     SET ESTADO = 'PAGADA'
   WHERE ID_DETALLE = p_id_detalle;

  -- 9) Bajar saldo de la CxC; si llega a cero -> PAGADA
  v_nuevo_saldo := NVL(v_cxc.SALDO,0) - v_cuota.MONTO_CUOTA;
  IF v_nuevo_saldo < 0 THEN v_nuevo_saldo := 0; END IF;
  UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR
     SET SALDO  = v_nuevo_saldo,
         ESTADO = CASE WHEN v_nuevo_saldo = 0 THEN 'PAGADA' ELSE 'PENDIENTE' END
   WHERE ID_CXC = v_cxc.ID_CXC;

  RETURN v_nro_rec;
END;
/
show errors function FN_COBRAR_CUOTA

prompt == F9.7 JOB_VENCER_CUOTAS (DAILY 02:00) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_scheduler_jobs
   WHERE owner='WKSP_WORKPLACE' AND job_name='JOB_VENCER_CUOTAS';
  IF v_cnt > 0 THEN
    DBMS_SCHEDULER.DROP_JOB('WKSP_WORKPLACE.JOB_VENCER_CUOTAS', force => TRUE);
    DBMS_OUTPUT.PUT_LINE('  = JOB_VENCER_CUOTAS anterior eliminado (recrear)');
  END IF;

  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'WKSP_WORKPLACE.JOB_VENCER_CUOTAS',
    job_type        => 'PLSQL_BLOCK',
    job_action      => q'[
BEGIN
  UPDATE WKSP_WORKPLACE.CUENTAS_COBRAR_DET
     SET ESTADO = 'VENCIDA'
   WHERE ESTADO = 'PENDIENTE'
     AND FECHA_VENCIMIENTO < TRUNC(SYSDATE);
  COMMIT;
END;
]',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
    enabled         => TRUE,
    comments        => 'F9 - Marca cuotas vencidas (FECHA_VENCIMIENTO < hoy) como VENCIDA'
  );
  DBMS_OUTPUT.PUT_LINE('  + JOB_VENCER_CUOTAS creado y habilitado');
END;
/

prompt == F9.8 Parametros de emisor (TIPO_PARAMETRO=EMPRESA) ==
-- Datos del emisor que aparecen en documentos (recibo, factura, etc). Se cargan en
-- PARAMETROS con TIPO_PARAMETRO='EMPRESA'. Las paginas de print los leen dinamicamente.
DECLARE
  PROCEDURE upsert_param(p_clave VARCHAR2, p_valor VARCHAR2, p_desc VARCHAR2) IS
  BEGIN
    MERGE INTO WKSP_WORKPLACE.PARAMETROS p
    USING (SELECT 'EMPRESA' AS tipo, p_clave AS clave FROM dual) src
       ON (p.TIPO_PARAMETRO = src.tipo AND p.CLAVE = src.clave)
    WHEN MATCHED THEN
      UPDATE SET p.VALOR_TEXTO = p_valor,
                 p.DESCRIPCION = p_desc,
                 p.FECHA_MODIFICACION = SYSDATE,
                 p.USUARIO_MODIFICACION = 'F9_cobros.sql'
    WHEN NOT MATCHED THEN
      INSERT (TIPO_PARAMETRO, CLAVE, VALOR_TEXTO, DESCRIPCION, ACTIVO, FECHA_CREACION, USUARIO_CREACION)
      VALUES ('EMPRESA', p_clave, p_valor, p_desc, 'S', SYSDATE, 'F9_cobros.sql');
  END;
BEGIN
  upsert_param('RUC',           '80004571-1',          'RUC del emisor (cabecera de documentos)');
  upsert_param('RAZON_SOCIAL',  'SOLSGE',              unistr('Raz\00F3n social del emisor'));
  upsert_param('DIRECCION',     unistr('Itaugu\00E1 Km 25 Mboiy'), unistr('Direcci\00F3n del emisor'));
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('  + Parametros EMPRESA cargados/actualizados (RUC, RAZON_SOCIAL, DIRECCION)');
END;
/

prompt == F9.9 Verificacion final ==
DECLARE
  v_ok BOOLEAN := TRUE;
  v_dirty PLS_INTEGER;

  PROCEDURE expect_constraint(p_name VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_constraints
     WHERE owner='WKSP_WORKPLACE' AND constraint_name=p_name;
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK constraint '||p_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL constraint '||p_name);
      v_ok := FALSE;
    END IF;
  END;

  PROCEDURE expect_column(p_table VARCHAR2, p_col VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
     WHERE owner='WKSP_WORKPLACE' AND table_name=p_table AND column_name=p_col;
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK columna '||p_table||'.'||p_col);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL columna '||p_table||'.'||p_col);
      v_ok := FALSE;
    END IF;
  END;

  PROCEDURE expect_object(p_name VARCHAR2, p_type VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_objects
     WHERE owner='WKSP_WORKPLACE' AND object_name=p_name AND object_type=p_type AND status='VALID';
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK '||p_type||' '||p_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL '||p_type||' '||p_name);
      v_ok := FALSE;
    END IF;
  END;

  PROCEDURE expect_job(p_name VARCHAR2) IS
    v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt FROM all_scheduler_jobs
     WHERE owner='WKSP_WORKPLACE' AND job_name=p_name AND enabled='TRUE';
    IF v_cnt = 1 THEN
      DBMS_OUTPUT.PUT_LINE('  OK job '||p_name);
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL job '||p_name);
      v_ok := FALSE;
    END IF;
  END;
BEGIN
  expect_column('DETALLE_MOVIMIENTO_CAJA','ID_METODO_PAGO');
  expect_constraint('FK_DETMOVCAJA_METPAG');
  expect_constraint('CK_CCD_ESTADO');
  expect_constraint('CK_CXC_ESTADO');
  expect_object('FN_COBRAR_CUOTA','FUNCTION');
  expect_job('JOB_VENCER_CUOTAS');

  -- Parametros EMPRESA cargados
  DECLARE v_cnt PLS_INTEGER;
  BEGIN
    SELECT COUNT(*) INTO v_cnt
      FROM WKSP_WORKPLACE.PARAMETROS
     WHERE TIPO_PARAMETRO='EMPRESA'
       AND CLAVE IN ('RUC','RAZON_SOCIAL','DIRECCION')
       AND ACTIVO='S';
    IF v_cnt = 3 THEN
      DBMS_OUTPUT.PUT_LINE('  OK parametros EMPRESA (3)');
    ELSE
      DBMS_OUTPUT.PUT_LINE('  FAIL parametros EMPRESA (encontrados: '||v_cnt||')');
      v_ok := FALSE;
    END IF;
  END;

  -- Sin filas con ESTADO='PAGADO' en cuotas
  SELECT COUNT(*) INTO v_dirty FROM WKSP_WORKPLACE.CUENTAS_COBRAR_DET WHERE ESTADO='PAGADO';
  IF v_dirty = 0 THEN
    DBMS_OUTPUT.PUT_LINE('  OK sin cuotas con ESTADO=PAGADO (sin normalizar)');
  ELSE
    DBMS_OUTPUT.PUT_LINE('  FAIL hay '||v_dirty||' cuotas con ESTADO=PAGADO');
    v_ok := FALSE;
  END IF;

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('F9 backend: TODO OK');
    DBMS_OUTPUT.PUT_LINE('==========================================');
  ELSE
    DBMS_OUTPUT.PUT_LINE('==========================================');
    DBMS_OUTPUT.PUT_LINE('F9 backend: HAY FALLAS (ver lineas FAIL)');
    DBMS_OUTPUT.PUT_LINE('==========================================');
    RAISE_APPLICATION_ERROR(-20999,'F9 verificacion fallo');
  END IF;
END;
/

ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

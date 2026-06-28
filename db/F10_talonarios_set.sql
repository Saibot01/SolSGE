-- ============================================================================
-- F10 - TALONARIOS por CAJA_CONF (cumplimiento SET Paraguay)
-- ============================================================================
-- Re-ancla TALONARIOS a CAJA_CONF en vez de OFICINAS para cumplir la regla SET
-- "PUNTO_EXPEDICION identifica una unica caja fisica".
--
-- Pasos:
--   1. ADD COLUMN ID_CAJA_CONF NUMBER (nullable, idempotente).
--   2. POPULATE: TMP_MAP_TALONARIO_CAJA si existe; sino inferencia automatica
--      (1 CAJA_CONF por oficina); abortar si quedan NULL.
--   2bis. Guard historico: si la asignacion afecta talonarios con
--         NRO_ACTUAL > NRO_INICIAL, abortar salvo que exista
--         TMP_F10_AUTH con bypass='SI'.
--   3. MODIFY ID_CAJA_CONF NOT NULL.
--   4. ADD FK_TALONARIO_CAJA_CONF -> CAJA_CONF.
--   5. CREATE UNIQUE INDEX parcial UQ_TALONARIO_CAJA_TIPO_ACT
--      sobre (ID_CAJA_CONF, TIPO_COMPROBANTE) WHERE ACTIVO='S'.
--   6. CREATE OR REPLACE TRIGGER TRG_TALONARIO_DERIVA_OFICINA
--      (mantiene ID_OFICINA derivado).
--   7. CREATE OR REPLACE FUNCTION FN_CAJA_CONF_USUARIO.
--   8. CREATE OR REPLACE VIEW V_TALONARIOS_DISPONIBLES (agrega ID_CAJA_CONF).
--   9. CREATE OR REPLACE FUNCTION FN_COBRAR_CUOTA
--      (cambia validacion paso 4 a ID_CAJA_CONF).
--  10. Verificacion final.
--
-- Idempotente: re-correrlo es no-op.
--
-- Pre-requisitos:
--   - F8_facturacion.sql y F9_cobros.sql aplicados.
--   - F10_preflight.sql ejecutado y revisado.
--   - Si alguna oficina tiene >1 CAJA_CONF y hay talonarios compartidos:
--       CREATE TABLE WKSP_WORKPLACE.TMP_MAP_TALONARIO_CAJA (
--         ID_TALONARIO  NUMBER PRIMARY KEY,
--         ID_CAJA_CONF  NUMBER NOT NULL
--       );
--       INSERT INTO TMP_MAP_TALONARIO_CAJA VALUES (...);
--       COMMIT;
--   - Si la migracion reasigna talonarios con historico emitido
--     (NRO_ACTUAL > NRO_INICIAL):
--       CREATE TABLE WKSP_WORKPLACE.TMP_F10_AUTH (bypass VARCHAR2(2));
--       INSERT INTO TMP_F10_AUTH VALUES ('SI');
--       COMMIT;
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: @db/F10_talonarios_set.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

SET SERVEROUTPUT ON SIZE UNLIMITED
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

prompt == F10.0 Pre-check (F8+F9 aplicados) ==
DECLARE
  v_cnt PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_COBRAR_CUOTA'
     AND object_type='FUNCTION';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20949,'FN_COBRAR_CUOTA no existe. Aplicar F9_cobros.sql primero.');
  END IF;
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='TALONARIOS';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20949,'TALONARIOS no existe.');
  END IF;
END;
/

prompt == F10.1 ADD COLUMN TALONARIOS.ID_CAJA_CONF (nullable) ==
DECLARE
  v_exists PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='TALONARIOS'
     AND column_name='ID_CAJA_CONF';
  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.TALONARIOS ADD ID_CAJA_CONF NUMBER';
    DBMS_OUTPUT.PUT_LINE('Columna ID_CAJA_CONF agregada.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Columna ID_CAJA_CONF ya existe.');
  END IF;
END;
/

prompt == F10.2 POPULATE ID_CAJA_CONF (TMP_MAP o inferencia automatica) ==
DECLARE
  v_tmp_exists      PLS_INTEGER;
  v_rows_via_map    PLS_INTEGER := 0;
  v_rows_via_auto   PLS_INTEGER := 0;
  v_nulls_restantes PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_tmp_exists FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='TMP_MAP_TALONARIO_CAJA';

  IF v_tmp_exists > 0 THEN
    EXECUTE IMMEDIATE '
      UPDATE WKSP_WORKPLACE.TALONARIOS t
         SET t.ID_CAJA_CONF = (SELECT m.ID_CAJA_CONF
                                 FROM WKSP_WORKPLACE.TMP_MAP_TALONARIO_CAJA m
                                WHERE m.ID_TALONARIO = t.ID_TALONARIO)
       WHERE t.ID_CAJA_CONF IS NULL
         AND EXISTS (SELECT 1
                       FROM WKSP_WORKPLACE.TMP_MAP_TALONARIO_CAJA m
                      WHERE m.ID_TALONARIO = t.ID_TALONARIO)';
    v_rows_via_map := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE('Filas pobladas via TMP_MAP_TALONARIO_CAJA: '||v_rows_via_map);
  END IF;

  -- Inferencia automatica para filas que sigan NULL: solo aplica si la
  -- oficina del talonario tiene exactamente 1 CAJA_CONF.
  UPDATE WKSP_WORKPLACE.TALONARIOS t
     SET t.ID_CAJA_CONF = (
          SELECT MIN(cc.ID_CAJA_CONF)
            FROM WKSP_WORKPLACE.CAJA_CONF cc
           WHERE cc.ID_OFICINA = t.ID_OFICINA
          HAVING COUNT(*) = 1)
   WHERE t.ID_CAJA_CONF IS NULL;
  v_rows_via_auto := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('Filas pobladas via inferencia automatica: '||v_rows_via_auto);

  COMMIT;

  SELECT COUNT(*) INTO v_nulls_restantes
    FROM WKSP_WORKPLACE.TALONARIOS WHERE ID_CAJA_CONF IS NULL;

  IF v_nulls_restantes > 0 THEN
    RAISE_APPLICATION_ERROR(-20950,
      'Quedan '||v_nulls_restantes||' talonarios sin ID_CAJA_CONF. '||
      'Crear TMP_MAP_TALONARIO_CAJA(ID_TALONARIO,ID_CAJA_CONF) con el mapeo '||
      'manual y reintentar.');
  END IF;
END;
/

prompt == F10.2bis Guard historico (NRO_ACTUAL > NRO_INICIAL) ==
DECLARE
  v_auth_exists  PLS_INTEGER;
  v_bypass       VARCHAR2(2) := 'NO';
  v_afectados    PLS_INTEGER;
BEGIN
  -- Solo evaluamos guard sobre talonarios reasignados via TMP_MAP_TALONARIO_CAJA
  -- (la inferencia automatica requiere 1 CAJA_CONF por oficina, por lo que la
  -- caja resultante es la unica posible -> no hay "reasignacion" semantica).
  SELECT COUNT(*) INTO v_auth_exists FROM all_tables
   WHERE owner='WKSP_WORKPLACE' AND table_name='TMP_F10_AUTH';
  IF v_auth_exists > 0 THEN
    EXECUTE IMMEDIATE
      'SELECT MAX(bypass) FROM WKSP_WORKPLACE.TMP_F10_AUTH' INTO v_bypass;
  END IF;

  SELECT COUNT(*) INTO v_afectados
    FROM WKSP_WORKPLACE.TALONARIOS t
   WHERE t.NRO_ACTUAL > t.NRO_INICIAL
     AND EXISTS (SELECT 1 FROM all_tables
                  WHERE owner='WKSP_WORKPLACE'
                    AND table_name='TMP_MAP_TALONARIO_CAJA');

  IF v_afectados > 0 AND NVL(v_bypass,'NO') <> 'SI' THEN
    RAISE_APPLICATION_ERROR(-20952,
      'Hay '||v_afectados||' talonarios con historico emitido afectados por la '||
      'reasignacion. Para autorizar, crear WKSP_WORKPLACE.TMP_F10_AUTH(bypass '||
      'VARCHAR2(2)) e INSERT VALUES (''SI'').');
  ELSIF v_afectados > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Guard historico BYPASSEADO ('||v_afectados||' talonarios con historico).');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Guard historico OK (0 talonarios afectados).');
  END IF;
END;
/

prompt == F10.3 ID_CAJA_CONF NOT NULL ==
DECLARE
  v_nullable VARCHAR2(1);
BEGIN
  SELECT nullable INTO v_nullable FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='TALONARIOS'
     AND column_name='ID_CAJA_CONF';
  IF v_nullable = 'Y' THEN
    EXECUTE IMMEDIATE
      'ALTER TABLE WKSP_WORKPLACE.TALONARIOS MODIFY ID_CAJA_CONF NOT NULL';
    DBMS_OUTPUT.PUT_LINE('ID_CAJA_CONF ahora NOT NULL.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('ID_CAJA_CONF ya era NOT NULL.');
  END IF;
END;
/

prompt == F10.4 FK_TALONARIO_CAJA_CONF ==
DECLARE
  v_exists PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='FK_TALONARIO_CAJA_CONF';
  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE '
      ALTER TABLE WKSP_WORKPLACE.TALONARIOS
        ADD CONSTRAINT FK_TALONARIO_CAJA_CONF
        FOREIGN KEY (ID_CAJA_CONF)
        REFERENCES WKSP_WORKPLACE.CAJA_CONF(ID_CAJA_CONF)';
    DBMS_OUTPUT.PUT_LINE('FK_TALONARIO_CAJA_CONF creada.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('FK_TALONARIO_CAJA_CONF ya existe.');
  END IF;
END;
/

prompt == F10.5 Indice unico parcial UQ_TALONARIO_CAJA_TIPO_ACT ==
DECLARE
  v_exists PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_exists FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_TALONARIO_CAJA_TIPO_ACT';
  IF v_exists = 0 THEN
    EXECUTE IMMEDIATE '
      CREATE UNIQUE INDEX WKSP_WORKPLACE.UQ_TALONARIO_CAJA_TIPO_ACT
        ON WKSP_WORKPLACE.TALONARIOS (
          CASE WHEN ACTIVO=''S'' THEN ID_CAJA_CONF END,
          CASE WHEN ACTIVO=''S'' THEN TIPO_COMPROBANTE END
        )';
    DBMS_OUTPUT.PUT_LINE('UQ_TALONARIO_CAJA_TIPO_ACT creado.');
  ELSE
    DBMS_OUTPUT.PUT_LINE('UQ_TALONARIO_CAJA_TIPO_ACT ya existe.');
  END IF;
END;
/

prompt == F10.6 TRG_TALONARIO_DERIVA_OFICINA ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_TALONARIO_DERIVA_OFICINA
BEFORE INSERT OR UPDATE OF ID_CAJA_CONF ON WKSP_WORKPLACE.TALONARIOS
FOR EACH ROW
BEGIN
  SELECT cc.ID_OFICINA
    INTO :NEW.ID_OFICINA
    FROM WKSP_WORKPLACE.CAJA_CONF cc
   WHERE cc.ID_CAJA_CONF = :NEW.ID_CAJA_CONF;
END;
/
show errors trigger TRG_TALONARIO_DERIVA_OFICINA

prompt == F10.7 FN_CAJA_CONF_USUARIO ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_CAJA_CONF_USUARIO (
  p_usuario IN VARCHAR2 DEFAULT V('APP_USER')
) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT MAX(c.ID_CAJA_CONF)
    INTO v_id
    FROM WKSP_WORKPLACE.CAJAS     c
    JOIN WKSP_WORKPLACE.EMPLEADOS e ON e.ID_EMPLEADO = c.ID_EMPLEADO
   WHERE UPPER(e.CODIGO_USUARIO) = UPPER(p_usuario)
     AND c.ESTADO = 'A';
  RETURN v_id;
END;
/
show errors function FN_CAJA_CONF_USUARIO

prompt == F10.8 V_TALONARIOS_DISPONIBLES (agrega ID_CAJA_CONF) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_TALONARIOS_DISPONIBLES AS
SELECT t.ID_TALONARIO,
       t.ID_CAJA_CONF,
       t.ID_OFICINA,
       t.TIPO_COMPROBANTE,
       t.TIMBRADO || ' / ' ||
         LPAD(t.ESTABLECIMIENTO,3,'0')||'-'||LPAD(t.PUNTO_EXPEDICION,3,'0')
         AS DESCRIPCION
  FROM WKSP_WORKPLACE.TALONARIOS t
 WHERE t.ACTIVO = 'S'
   AND WKSP_WORKPLACE.FN_HOY BETWEEN t.FECHA_INICIO AND t.FECHA_FIN
   AND t.NRO_ACTUAL < t.NRO_FINAL;

prompt == F10.9 FN_COBRAR_CUOTA (validacion paso 4 -> ID_CAJA_CONF) ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_COBRAR_CUOTA (
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
  v_cuota       WKSP_WORKPLACE.CUENTAS_COBRAR_DET%ROWTYPE;
  v_cxc         WKSP_WORKPLACE.CUENTAS_COBRAR%ROWTYPE;
  v_caja        WKSP_WORKPLACE.CAJAS%ROWTYPE;
  v_talon       WKSP_WORKPLACE.TALONARIOS%ROWTYPE;
  v_nro_rec     VARCHAR2(20);
  v_id_mov      NUMBER;
  v_nuevo_saldo NUMBER;
  v_monto_mov   NUMBER;
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

  -- 4) Validar talonario y CAJA_CONF (RC vigente y de la caja del usuario)
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
  IF v_talon.ID_CAJA_CONF <> v_caja.ID_CAJA_CONF THEN
    RAISE_APPLICATION_ERROR(-20917,'El talonario no pertenece a la caja del usuario.');
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

prompt == F10.10 Verificacion final ==
DECLARE
  v_nulls         PLS_INTEGER;
  v_fk            PLS_INTEGER;
  v_uq            PLS_INTEGER;
  v_fn            PLS_INTEGER;
  v_trg           PLS_INTEGER;
  v_vista_columns PLS_INTEGER;
  v_data_drift    PLS_INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_nulls
    FROM WKSP_WORKPLACE.TALONARIOS WHERE ID_CAJA_CONF IS NULL;

  SELECT COUNT(*) INTO v_fk FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='FK_TALONARIO_CAJA_CONF';

  SELECT COUNT(*) INTO v_uq FROM all_indexes
   WHERE owner='WKSP_WORKPLACE' AND index_name='UQ_TALONARIO_CAJA_TIPO_ACT';

  SELECT COUNT(*) INTO v_fn FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_CAJA_CONF_USUARIO'
     AND object_type='FUNCTION' AND status='VALID';

  SELECT COUNT(*) INTO v_trg FROM all_triggers
   WHERE owner='WKSP_WORKPLACE' AND trigger_name='TRG_TALONARIO_DERIVA_OFICINA'
     AND status='ENABLED';

  SELECT COUNT(*) INTO v_vista_columns FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='V_TALONARIOS_DISPONIBLES'
     AND column_name='ID_CAJA_CONF';

  SELECT COUNT(*) INTO v_data_drift
    FROM WKSP_WORKPLACE.TALONARIOS t
    JOIN WKSP_WORKPLACE.CAJA_CONF  cc ON cc.ID_CAJA_CONF = t.ID_CAJA_CONF
   WHERE t.ID_OFICINA <> cc.ID_OFICINA;

  IF v_nulls>0 OR v_fk=0 OR v_uq=0 OR v_fn=0 OR v_trg=0
     OR v_vista_columns=0 OR v_data_drift>0 THEN
    RAISE_APPLICATION_ERROR(-20951,
      'Verificacion F10 fallo: nulls='||v_nulls||
      ' fk='||v_fk||' uq='||v_uq||' fn='||v_fn||
      ' trg='||v_trg||' vista='||v_vista_columns||
      ' drift='||v_data_drift);
  END IF;
  DBMS_OUTPUT.PUT_LINE('F10 OK');
END;
/

prompt == F10 aplicado correctamente ==

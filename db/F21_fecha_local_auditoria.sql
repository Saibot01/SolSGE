-- ============================================================================
-- F21 - Fecha/hora LOCAL en AUDITORIA (continuacion de F19/F20)
-- ============================================================================
-- Pasa a hora local (FN_AHORA) los timestamps de auditoria que quedaban en UTC
-- (SYSDATE): FECHA_CREACION/MODIFICACION/REGISTRO/ALTA y similares. Aplica a los
-- objetos que solo vivian en la base (no estaban en otro archivo db/).
--
-- Los objetos de auditoria que SI estaban en archivos db/ se corrigieron ahi
-- (F11, F14, F15, F16, F17, F20, PP_audit_fix).
--
-- LIMITACION conocida: un DEFAULT de columna NO puede llamar a una funcion de
-- usuario (ORA-00904). Las columnas con DEFAULT SYSDATE/TRUNC(SYSDATE) no se
-- pueden pasar a FN_AHORA/FN_HOY directamente; donde importa, un trigger las
-- sobreescribe con hora local (ej. PRODUCTO_PROVEEDORES via TRG_PP_SET_AUDIT).
--
-- NO se tocan: tokens de PKG_EMPLEADOS (auth; expiry y compare ambos en UTC,
-- consistente) ni el start_date de jobs de scheduler.
--
-- Pre-requisito: F19 (FN_HOY/FN_AHORA) aplicado.
-- Idempotente: CREATE OR REPLACE, re-correrlo es no-op.
-- Ejecucion: sql -S -name tesis_db @db/F21_fecha_local_auditoria.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F21.1 EMPLEADOS_T_CONTRA (FECHA_ALTA local) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.EMPLEADOS_T_CONTRA
BEFORE INSERT ON EMPLEADOS
FOR EACH ROW
DECLARE
  v_codigo VARCHAR2(100);
BEGIN
  -- Codigo de usuario: inicial nombre + apellido en mayusculas
  BEGIN
    SELECT UPPER(SUBSTR(primer_nombre, 1, 1) || primer_apellido)
      INTO v_codigo
      FROM personas
     WHERE ID_PERSONA = :NEW.ID_PERSONA;
    :NEW.CODIGO_USUARIO := v_codigo;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  :NEW.FECHA_ALTA := WKSP_WORKPLACE.FN_AHORA;
END;
/

prompt == F21.2 PR_ALTA_RAPIDA_CLIENTE (fecha_registro local) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PR_ALTA_RAPIDA_CLIENTE (
    p_nro_documento     IN VARCHAR2,
    p_primer_nombre     IN VARCHAR2,
    p_primer_apellido   IN VARCHAR2,
    p_categoria_cliente IN VARCHAR2,
    p_tipo_documento    IN NUMBER DEFAULT '1',
    p_tipo_persona      IN VARCHAR2 DEFAULT 'F',
    p_codigo_usuario    IN VARCHAR2 DEFAULT 'APEX',
    p_id_persona_out    OUT NUMBER
) AS
    v_id_persona PERSONAS.ID_PERSONA%TYPE;
BEGIN
    -- Verificar si la persona ya existe
    BEGIN
        SELECT id_persona INTO v_id_persona
          FROM personas
         WHERE nro_documento = p_nro_documento;

        BEGIN
            INSERT INTO clientes (id_persona, codigo_usuario, estado, categoria_cliente)
            VALUES (v_id_persona, p_codigo_usuario, 'A', p_categoria_cliente);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL; -- ya es cliente
        END;

        p_id_persona_out := v_id_persona;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL; -- si no existe, continua el alta
    END;

    -- Insertar nueva persona
    INSERT INTO personas (
        nro_documento, tipo_documento, tipo_persona,
        primer_nombre, primer_apellido, fecha_registro
    ) VALUES (
        p_nro_documento, p_tipo_documento, p_tipo_persona,
        p_primer_nombre, p_primer_apellido, WKSP_WORKPLACE.FN_AHORA
    )
    RETURNING id_persona INTO v_id_persona;

    -- Insertar en clientes
    INSERT INTO clientes (
        id_persona, codigo_usuario, estado, categoria_cliente
    ) VALUES (
        v_id_persona, p_codigo_usuario, 'A', p_categoria_cliente
    );

    p_id_persona_out := v_id_persona;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Error al registrar cliente: ' || SQLERRM);
END PR_ALTA_RAPIDA_CLIENTE;
/

prompt == F21.3 PRC_TRANSFERIR_STOCK (hora + fecha de transferencia/movimiento local) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_TRANSFERIR_STOCK (
  p_id_producto       IN NUMBER,
  p_oficina_origen    IN NUMBER,
  p_oficina_destino   IN NUMBER,
  p_cantidad          IN NUMBER,
  p_observacion       IN VARCHAR2,
  p_usuario           IN VARCHAR2
) AS
  v_stock_origen  NUMBER;
  v_id_trans      NUMBER;
  v_hora          VARCHAR2(10);
BEGIN
  IF p_oficina_origen = p_oficina_destino THEN
    RAISE_APPLICATION_ERROR(-20010, 'El depósito origen y destino no pueden ser el mismo.');
  END IF;

  IF p_cantidad <= 0 THEN
    RAISE_APPLICATION_ERROR(-20011, 'La cantidad a transferir debe ser mayor a cero.');
  END IF;

  BEGIN
    SELECT NVL(CANTIDAD, 0)
    INTO   v_stock_origen
    FROM   WKSP_WORKPLACE.STOCK_PRODUCTO
    WHERE  ID_PRODUCTO = p_id_producto
      AND  ID_OFICINA  = p_oficina_origen
    FOR UPDATE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN v_stock_origen := 0;
  END;

  IF v_stock_origen < p_cantidad THEN
    RAISE_APPLICATION_ERROR(-20012,
      'Stock insuficiente en origen. Disponible: ' || v_stock_origen ||
      ', solicitado: ' || p_cantidad || '.');
  END IF;

  v_hora := TO_CHAR(WKSP_WORKPLACE.FN_AHORA, 'HH24:MI:SS');

  INSERT INTO WKSP_WORKPLACE.TRANSFERENCIAS_STOCK (
    ID_PRODUCTO, ID_OFICINA_ORIGEN, ID_OFICINA_DESTINO,
    CANTIDAD, FECHA, OBSERVACION, USUARIO, HORA
  ) VALUES (
    p_id_producto, p_oficina_origen, p_oficina_destino,
    p_cantidad, WKSP_WORKPLACE.FN_AHORA, p_observacion, p_usuario, v_hora
  ) RETURNING ID_TRANSFERENCIA INTO v_id_trans;

  -- Movimiento 1: SALIDA del depósito origen
  INSERT INTO WKSP_WORKPLACE.MOVIMIENTOS_STOCK (
    ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
    FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION, USUARIO
  ) VALUES (
    p_id_producto, p_oficina_origen, 'SALIDA', p_cantidad,
    WKSP_WORKPLACE.FN_AHORA, 'TRANS-' || v_id_trans, p_observacion, p_usuario
  );

  -- Movimiento 2: ENTRADA al depósito destino
  INSERT INTO WKSP_WORKPLACE.MOVIMIENTOS_STOCK (
    ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
    FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION, USUARIO
  ) VALUES (
    p_id_producto, p_oficina_destino, 'ENTRADA', p_cantidad,
    WKSP_WORKPLACE.FN_AHORA, 'TRANS-' || v_id_trans, p_observacion, p_usuario
  );
END PRC_TRANSFERIR_STOCK;
/

prompt == F21.4 TRG_CIERRE_MARGEN_ANTERIOR (fecha_modificacion local) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_CIERRE_MARGEN_ANTERIOR
BEFORE INSERT ON WKSP_WORKPLACE.MARGEN_CATEGORIA
FOR EACH ROW
BEGIN
  UPDATE WKSP_WORKPLACE.MARGEN_CATEGORIA
  SET  fecha_fin            = TRUNC(:NEW.fecha_inicio) - 1,
       estado               = 'INACTIVO',
       fecha_modificacion   = WKSP_WORKPLACE.FN_AHORA,
       usuario_modificacion = NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER)
  WHERE id_categoria      = :NEW.id_categoria
    AND categoria_cliente  = :NEW.categoria_cliente
    AND estado             = 'ACTIVO'
    AND fecha_fin          IS NULL;
END TRG_CIERRE_MARGEN_ANTERIOR;
/

prompt == F21.5 TRG_PARAMETRO_BI / BU (auditoria local) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_PARAMETRO_BI
BEFORE INSERT ON PARAMETROS
FOR EACH ROW
BEGIN
  IF :NEW.ID_PARAMETRO IS NULL THEN
    :NEW.ID_PARAMETRO := SEQ_PARAMETRO_ID.NEXTVAL;
  END IF;
  :NEW.FECHA_CREACION      := WKSP_WORKPLACE.FN_AHORA;
  :NEW.FECHA_MODIFICACION  := WKSP_WORKPLACE.FN_AHORA;
END TRG_PARAMETRO_BI;
/

CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_PARAMETRO_BU
BEFORE UPDATE ON PARAMETROS
FOR EACH ROW
BEGIN
  :NEW.FECHA_MODIFICACION := WKSP_WORKPLACE.FN_AHORA;
END TRG_PARAMETRO_BU;
/

prompt == F21.6 TRG_STOCK_CONFIG_BIU (auditoria local) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_STOCK_CONFIG_BIU
BEFORE INSERT OR UPDATE OF STOCK_MAXIMO, STOCK_MINIMO ON STOCK_PRODUCTO
FOR EACH ROW
BEGIN
  -- Primera configuracion del maximo
  IF :OLD.STOCK_MAXIMO IS NULL AND :NEW.STOCK_MAXIMO IS NOT NULL THEN
    :NEW.FECHA_CREACION   := WKSP_WORKPLACE.FN_AHORA;
    :NEW.USUARIO_CREACION := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
  END IF;

  -- Cualquier cambio en maximo o minimo
  IF (:NEW.STOCK_MAXIMO != NVL(:OLD.STOCK_MAXIMO, -1)) OR
     (:NEW.STOCK_MINIMO != NVL(:OLD.STOCK_MINIMO, -1)) THEN
    :NEW.FECHA_MODIFICACION   := WKSP_WORKPLACE.FN_AHORA;
    :NEW.USUARIO_MODIFICACION := SYS_CONTEXT('APEX$SESSION', 'APP_USER');
  END IF;
END TRG_STOCK_CONFIG_BIU;
/

prompt == F21.7 SP_INSERTAR_PRODUCTO_PROVEEDOR (auditoria local) ==
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.SP_INSERTAR_PRODUCTO_PROVEEDOR (
  p_id_producto       IN NUMBER,
  p_id_persona        IN NUMBER,
  p_codigo_referencia IN VARCHAR2,
  p_precio            IN NUMBER,
  p_fecha_inicio      IN DATE,
  p_fecha_fin         IN DATE DEFAULT NULL,
  p_estado            IN VARCHAR2 DEFAULT 'ACTIVO',
  p_usuario           IN VARCHAR2,
  p_resultado         OUT VARCHAR2
) AS
  v_existe NUMBER := 0;
BEGIN
  IF p_precio IS NULL OR p_precio <= 0 THEN
    p_resultado := 'ERROR: PRECIO debe ser mayor a 0';
    RETURN;
  END IF;
  IF p_fecha_fin IS NOT NULL AND p_fecha_fin < p_fecha_inicio THEN
    p_resultado := 'ERROR: FECHA_FIN no puede ser menor a FECHA_INICIO';
    RETURN;
  END IF;

  SELECT COUNT(*) INTO v_existe
    FROM PRODUCTO_PROVEEDORES
   WHERE ID_PRODUCTO = p_id_producto AND ID_PERSONA = p_id_persona
     AND FECHA_INICIO = TRUNC(p_fecha_inicio);

  IF v_existe > 0 THEN
    UPDATE PRODUCTO_PROVEEDORES
       SET CODIGO_REFERENCIA = p_codigo_referencia,
           PRECIO = p_precio,
           FECHA_FIN = p_fecha_fin,
           ESTADO = p_estado,
           FECHA_MODIFICACION = WKSP_WORKPLACE.FN_AHORA,
           USUARIO_MODIFICACION = p_usuario
     WHERE ID_PRODUCTO = p_id_producto AND ID_PERSONA = p_id_persona
       AND FECHA_INICIO = TRUNC(p_fecha_inicio);
    p_resultado := 'EXITO: Registro actualizado';
  ELSE
    INSERT INTO PRODUCTO_PROVEEDORES (
        ID_PRODUCTO, ID_PERSONA, CODIGO_REFERENCIA, PRECIO,
        FECHA_INICIO, FECHA_FIN, ESTADO, FECHA_CREACION, USUARIO_CREACION
    ) VALUES (
        p_id_producto, p_id_persona, p_codigo_referencia, p_precio,
        TRUNC(p_fecha_inicio), p_fecha_fin, p_estado, WKSP_WORKPLACE.FN_AHORA, p_usuario
    );
    p_resultado := 'EXITO: Registro insertado';
  END IF;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    p_resultado := 'ERROR: ' || SQLERRM;
    ROLLBACK;
END SP_INSERTAR_PRODUCTO_PROVEEDOR;
/

prompt == F21.8 TRG_AUD_PP (FECHA_CAMBIO de auditoria local) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_AUD_PP
AFTER INSERT OR UPDATE OR DELETE ON PRODUCTO_PROVEEDORES
FOR EACH ROW
DECLARE
  v_user VARCHAR2(100);
BEGIN
  v_user := NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER);
  IF INSERTING THEN
    INSERT INTO AUDITORIA_PRODUCTO_PROVEEDOR
      (ID_AUDITORIA, ID_PRODUCTO, ID_PERSONA, FECHA_INICIO, PRECIO_ANTERIOR, PRECIO_NUEVO,
       ESTADO_ANTERIOR, ESTADO_NUEVO, TIPO_OPERACION, FECHA_CAMBIO, USUARIO_CAMBIO)
    VALUES
      (SEQ_AUDITORIA_PP.NEXTVAL, :NEW.ID_PRODUCTO, :NEW.ID_PERSONA, :NEW.FECHA_INICIO, NULL, :NEW.PRECIO,
       NULL, :NEW.ESTADO, 'INSERT', WKSP_WORKPLACE.FN_AHORA, v_user);
  ELSIF UPDATING THEN
    INSERT INTO AUDITORIA_PRODUCTO_PROVEEDOR
      (ID_AUDITORIA, ID_PRODUCTO, ID_PERSONA, FECHA_INICIO, PRECIO_ANTERIOR, PRECIO_NUEVO,
       ESTADO_ANTERIOR, ESTADO_NUEVO, TIPO_OPERACION, FECHA_CAMBIO, USUARIO_CAMBIO)
    VALUES
      (SEQ_AUDITORIA_PP.NEXTVAL, :NEW.ID_PRODUCTO, :NEW.ID_PERSONA, :NEW.FECHA_INICIO, :OLD.PRECIO, :NEW.PRECIO,
       :OLD.ESTADO, :NEW.ESTADO, 'UPDATE', WKSP_WORKPLACE.FN_AHORA, v_user);
  ELSIF DELETING THEN
    INSERT INTO AUDITORIA_PRODUCTO_PROVEEDOR
      (ID_AUDITORIA, ID_PRODUCTO, ID_PERSONA, FECHA_INICIO, PRECIO_ANTERIOR, PRECIO_NUEVO,
       ESTADO_ANTERIOR, ESTADO_NUEVO, TIPO_OPERACION, FECHA_CAMBIO, USUARIO_CAMBIO)
    VALUES
      (SEQ_AUDITORIA_PP.NEXTVAL, :OLD.ID_PRODUCTO, :OLD.ID_PERSONA, :OLD.FECHA_INICIO, :OLD.PRECIO, NULL,
       :OLD.ESTADO, NULL, 'DELETE', WKSP_WORKPLACE.FN_AHORA, v_user);
  END IF;
END;
/

prompt == F21.9 TRG_CIERRE_PP_ANTERIOR (fecha_modificacion local) ==
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_CIERRE_PP_ANTERIOR
BEFORE INSERT ON WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
FOR EACH ROW
BEGIN
  UPDATE WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
  SET  fecha_fin            = TRUNC(:NEW.fecha_inicio) - 1,
       estado               = 'INACTIVO',
       fecha_modificacion   = WKSP_WORKPLACE.FN_AHORA,
       usuario_modificacion = NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER)
  WHERE id_producto  = :NEW.id_producto
    AND id_persona   = :NEW.id_persona
    AND estado       = 'ACTIVO'
    AND fecha_fin    IS NULL
    AND fecha_inicio <= :NEW.fecha_inicio;  -- no cerrar registros con inicio futuro
END TRG_CIERRE_PP_ANTERIOR;
/

prompt == F21 OK ==

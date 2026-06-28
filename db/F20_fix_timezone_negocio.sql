-- ============================================================================
-- F20 - Fix de zona horaria en logica de NEGOCIO (continuacion de F19)
-- ============================================================================
-- El server corre en UTC; SYSDATE/SYSTIMESTAMP adelantan el dia ~3hs de noche.
-- Se reemplaza el uso de SYSDATE como "fecha/hora local de negocio" por los
-- helpers de F19: FN_HOY (fecha local) y FN_AHORA (fecha+hora local, UTC-3).
--
-- Alcance: objetos que NO viven en otro archivo db/ (estaban solo en la base).
-- Los que si viven en archivos db/ se corrigen en su archivo de origen
-- (F2, F4, F8, F10, F14, F15, F16).
--
-- NO se tocan los timestamps de pura auditoria (FECHA_CREACION/MODIFICACION),
-- que se dejan en UTC a proposito.
--
-- Pre-requisito: F19 (FN_HOY/FN_AHORA) aplicado.
-- Idempotente: CREATE OR REPLACE, re-correrlo es no-op.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion: sql -S -name tesis_db @db/F20_fix_timezone_negocio.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F20.1 Funciones de precio/costo (vigencia con fecha local) ==

CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_OBTENER_PRECIO_VIGENTE (
  p_id_producto IN NUMBER,
  p_id_persona  IN NUMBER
) RETURN NUMBER AS
  v_precio NUMBER;
BEGIN
  SELECT PRECIO INTO v_precio
    FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
   WHERE ID_PRODUCTO = p_id_producto
     AND ID_PERSONA  = p_id_persona
     AND ESTADO      = 'ACTIVO'
     AND WKSP_WORKPLACE.FN_HOY >= FECHA_INICIO
     AND (FECHA_FIN IS NULL OR WKSP_WORKPLACE.FN_HOY <= FECHA_FIN)
   FETCH FIRST 1 ROW ONLY;
  RETURN v_precio;
EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
END FN_OBTENER_PRECIO_VIGENTE;
/

CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_PRECIO_VENTA (
    p_id_producto       IN NUMBER,
    p_categoria_cliente IN VARCHAR2
) RETURN NUMBER
IS
    v_costo  NUMBER;
    v_margen NUMBER;
BEGIN
    v_costo := WKSP_WORKPLACE.FN_COSTO_PONDERADO(p_id_producto);

    IF v_costo IS NULL THEN
        BEGIN
            SELECT pp.precio
            INTO   v_costo
            FROM   WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp
            WHERE  pp.id_producto  = p_id_producto
              AND  pp.estado       = 'ACTIVO'
              AND  pp.fecha_fin    IS NULL
              AND  pp.fecha_inicio <= WKSP_WORKPLACE.FN_HOY
            ORDER BY pp.fecha_inicio DESC
            FETCH FIRST 1 ROW ONLY;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN RETURN NULL;
        END;
    END IF;

    SELECT mc.porcentaje
    INTO   v_margen
    FROM   WKSP_WORKPLACE.MARGEN_CATEGORIA mc
    JOIN   WKSP_WORKPLACE.PRODUCTOS p ON p.id_categoria = mc.id_categoria
    WHERE  p.id_producto        = p_id_producto
      AND  mc.categoria_cliente = p_categoria_cliente
      AND  mc.estado            = 'ACTIVO'
      AND  mc.fecha_fin         IS NULL;

    RETURN ROUND(v_costo * (1 + v_margen / 100));
EXCEPTION
    WHEN NO_DATA_FOUND  THEN RETURN NULL;
    WHEN TOO_MANY_ROWS  THEN RETURN NULL;
END FN_PRECIO_VENTA;
/

CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_COSTO_PONDERADO (
    p_id_producto    IN NUMBER,
    p_ventana_dias   IN NUMBER DEFAULT NULL
) RETURN NUMBER
IS
    v_ventana NUMBER;
    v_costo   NUMBER;
BEGIN
    IF p_ventana_dias IS NULL THEN
        BEGIN
            SELECT valor_numerico INTO v_ventana
            FROM   WKSP_WORKPLACE.PARAMETROS
            WHERE  tipo_parametro = 'COSTO'
              AND  clave          = 'COSTO_VENTANA_DIAS'
              AND  activo         = 'S';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN v_ventana := 90;
        END;
    ELSE
        v_ventana := p_ventana_dias;
    END IF;

    SELECT SUM(dcp.cantidad * dcp.precio_unitario * NVL(cp.tipo_cambio, 1))
           / NULLIF(SUM(dcp.cantidad), 0)
    INTO   v_costo
    FROM   WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV dcp
    JOIN   WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR   cp ON cp.id_comprobante = dcp.id_comprobante
    WHERE  dcp.id_producto    = p_id_producto
      AND  cp.estado          = 'C'
      AND  cp.fecha_emision  >= WKSP_WORKPLACE.FN_HOY - v_ventana
      AND  dcp.cantidad        > 0
      AND  dcp.precio_unitario > 0;

    RETURN v_costo;
END FN_COSTO_PONDERADO;
/

prompt == F20.2 Vistas de vigencia/caducidad de precios (fecha local) ==

CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_ALERTAS_CADUCIDAD_PP AS
SELECT pp.ID_PRODUCTO,
       p.NOMBRE AS PRODUCTO_NOMBRE,
       pp.ID_PERSONA,
       TRIM(NVL(pers.PRIMER_NOMBRE,'')||' '||NVL(pers.PRIMER_APELLIDO,'')) AS PROVEEDOR_NOMBRE,
       pp.PRECIO,
       pp.FECHA_FIN,
       TRUNC(pp.FECHA_FIN - WKSP_WORKPLACE.FN_AHORA) AS DIAS_PARA_CADUCIDAD,
       CASE WHEN TRUNC(pp.FECHA_FIN - WKSP_WORKPLACE.FN_AHORA) <= 0  THEN 'CADUCADO'
            WHEN TRUNC(pp.FECHA_FIN - WKSP_WORKPLACE.FN_AHORA) <= 7  THEN 'CRITICO'
            WHEN TRUNC(pp.FECHA_FIN - WKSP_WORKPLACE.FN_AHORA) <= 30 THEN 'PROXIMO MES'
            ELSE 'NORMAL' END AS NIVEL_ALERTA
  FROM PRODUCTO_PROVEEDORES pp
  INNER JOIN PRODUCTOS  p    ON pp.ID_PRODUCTO = p.ID_PRODUCTO
  INNER JOIN PROVEEDORES prov ON pp.ID_PERSONA = prov.ID_PERSONA
  INNER JOIN PERSONAS   pers  ON prov.ID_PERSONA = pers.ID_PERSONA
 WHERE pp.ESTADO = 'ACTIVO'
   AND pp.FECHA_FIN IS NOT NULL
   AND pp.FECHA_FIN <= WKSP_WORKPLACE.FN_HOY + 60
 ORDER BY pp.FECHA_FIN ASC;

CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_COMPARATIVA_PRECIO_PROVEEDORES AS
SELECT p.ID_PRODUCTO,
       p.NOMBRE AS PRODUCTO_NOMBRE,
       TRIM(NVL(pers.PRIMER_NOMBRE,'')||' '||NVL(pers.PRIMER_APELLIDO,'')) AS PROVEEDOR_NOMBRE,
       pp.PRECIO,
       ROUND(AVG(pp.PRECIO) OVER (PARTITION BY p.ID_PRODUCTO), 2) AS PRECIO_PROMEDIO,
       ROUND(pp.PRECIO - AVG(pp.PRECIO) OVER (PARTITION BY p.ID_PRODUCTO), 2) AS DIFERENCIA,
       ROW_NUMBER() OVER (PARTITION BY p.ID_PRODUCTO ORDER BY pp.PRECIO ASC) AS RANKING_PRECIO
  FROM PRODUCTO_PROVEEDORES pp
  INNER JOIN PRODUCTOS  p    ON pp.ID_PRODUCTO = p.ID_PRODUCTO
  INNER JOIN PROVEEDORES prov ON pp.ID_PERSONA = prov.ID_PERSONA
  INNER JOIN PERSONAS   pers  ON prov.ID_PERSONA = pers.ID_PERSONA
 WHERE pp.ESTADO = 'ACTIVO'
   AND WKSP_WORKPLACE.FN_HOY >= pp.FECHA_INICIO
   AND (pp.FECHA_FIN IS NULL OR WKSP_WORKPLACE.FN_HOY <= pp.FECHA_FIN);

CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_PRODUCTO_PROVEEDOR_VIGENTE AS
SELECT pp.ID_PRODUCTO,
       p.NOMBRE AS PRODUCTO_NOMBRE,
       p.CODIGO_PROVEEDOR AS PRODUCTO_CODIGO,
       pp.ID_PERSONA,
       TRIM(NVL(pers.PRIMER_NOMBRE,'')||' '||NVL(pers.PRIMER_APELLIDO,'')) AS PROVEEDOR_NOMBRE,
       pp.CODIGO_REFERENCIA,
       pp.PRECIO,
       pp.FECHA_INICIO,
       pp.FECHA_FIN,
       pp.ESTADO,
       CASE WHEN pp.ESTADO = 'ACTIVO' AND WKSP_WORKPLACE.FN_HOY >= pp.FECHA_INICIO
                 AND (pp.FECHA_FIN IS NULL OR WKSP_WORKPLACE.FN_HOY <= pp.FECHA_FIN) THEN 'VIGENTE'
            WHEN pp.ESTADO = 'ACTIVO' AND pp.FECHA_FIN IS NOT NULL
                 AND WKSP_WORKPLACE.FN_HOY > pp.FECHA_FIN THEN 'CADUCADO'
            ELSE 'INACTIVO' END AS VIGENCIA,
       CASE WHEN pp.FECHA_FIN IS NOT NULL THEN TRUNC(pp.FECHA_FIN - WKSP_WORKPLACE.FN_AHORA) ELSE NULL END AS DIAS_PARA_CADUCIDAD,
       pp.FECHA_CREACION,
       pp.USUARIO_CREACION
  FROM PRODUCTO_PROVEEDORES pp
  INNER JOIN PRODUCTOS  p    ON pp.ID_PRODUCTO = p.ID_PRODUCTO
  INNER JOIN PROVEEDORES prov ON pp.ID_PERSONA = prov.ID_PERSONA
  INNER JOIN PERSONAS   pers  ON prov.ID_PERSONA = pers.ID_PERSONA;

prompt == F20.3 Triggers de HORA local (movimientos/ajustes de stock) ==

CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_AJUSTES_HORA
BEFORE INSERT ON WKSP_WORKPLACE.AJUSTES_STOCK
FOR EACH ROW
BEGIN
  IF :NEW.HORA IS NULL THEN
    :NEW.HORA := TO_CHAR(WKSP_WORKPLACE.FN_AHORA, 'HH24:MI:SS');
  END IF;
END;
/

CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_MOVIMIENTOS_HORA
BEFORE INSERT ON WKSP_WORKPLACE.MOVIMIENTOS_STOCK
FOR EACH ROW
BEGIN
  IF :NEW.HORA IS NULL THEN
    :NEW.HORA := TO_CHAR(WKSP_WORKPLACE.FN_AHORA, 'HH24:MI:SS');
  END IF;
END;
/

prompt == F20.4 Numeracion de documento de inventario (mes local) ==

CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.INVENTARIO_BI
BEFORE INSERT ON WKSP_WORKPLACE.INVENTARIO
FOR EACH ROW
BEGIN
  IF :NEW.NRO_DOCUMENTO IS NULL THEN
    :NEW.NRO_DOCUMENTO := 'INV-'||TO_CHAR(WKSP_WORKPLACE.FN_HOY,'YYYYMM')||'-'||LPAD(SEQ_NRO_DOC_INV.NEXTVAL,6,'0');
  END IF;
END;
/

prompt == F20.5 Costo de compra: fecha_inicio de vigencia = fecha local ==

CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_ACTUALIZAR_COSTO_COMPRA
AFTER UPDATE OF ESTADO ON WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
FOR EACH ROW
WHEN (OLD.ESTADO != 'C' AND NEW.ESTADO = 'C')
DECLARE
  v_user VARCHAR2(100);
BEGIN
  v_user := NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER);

  FOR linea IN (
    SELECT dcp.id_producto,
           ROUND(dcp.precio_unitario * NVL(:NEW.tipo_cambio, 1), 2) AS precio_pyg
    FROM   WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV dcp
    WHERE  dcp.id_comprobante  = :NEW.id_comprobante
      AND  dcp.precio_unitario IS NOT NULL
  ) LOOP
    -- fecha_inicio = fecha local de negocio; fecha_creacion queda en UTC (auditoria)
    INSERT INTO WKSP_WORKPLACE.PRODUCTO_PROVEEDORES (
        id_producto, id_persona, fecha_inicio, precio,
        estado, usuario_creacion, fecha_creacion
    ) VALUES (
        linea.id_producto, :NEW.id_proveedor, WKSP_WORKPLACE.FN_HOY,
        linea.precio_pyg, 'ACTIVO', v_user, SYSDATE
    );
  END LOOP;
END TRG_ACTUALIZAR_COSTO_COMPRA;
/

prompt == F20.6 Movimientos de stock: FECHA_MOVIMIENTO = fecha+hora local ==

CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_MOV_STOCK_DETALLE
AFTER INSERT ON WKSP_WORKPLACE.DETALLE_COMPROBANTE
FOR EACH ROW
DECLARE
  v_id_oficina     COMPROBANTES.ID_OFICINA%TYPE;
  v_estado         COMPROBANTES.ESTADO%TYPE;
  v_tipo_comp      COMPROBANTES.TIPO_COMPROBANTE%TYPE;
  v_stock_actual   NUMBER;
BEGIN
  SELECT ESTADO, TIPO_COMPROBANTE, ID_OFICINA
  INTO v_estado, v_tipo_comp, v_id_oficina
  FROM COMPROBANTES
  WHERE ID_COMPROBANTE = :NEW.ID_COMPROBANTE;

  IF v_estado = 'A' AND v_tipo_comp = 'FA' THEN
    SELECT CANTIDAD INTO v_stock_actual
    FROM STOCK_PRODUCTO
    WHERE ID_PRODUCTO = :NEW.ID_PRODUCTO
      AND ID_OFICINA = v_id_oficina
    FOR UPDATE;

    IF v_stock_actual < :NEW.CANTIDAD THEN
      RAISE_APPLICATION_ERROR(-20005, 'Stock insuficiente para producto ' || :NEW.ID_PRODUCTO);
    END IF;

    INSERT INTO MOVIMIENTOS_STOCK (
      ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
      FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION
    ) VALUES (
      :NEW.ID_PRODUCTO, v_id_oficina, 'SALIDA', :NEW.CANTIDAD,
      WKSP_WORKPLACE.FN_AHORA, 'VENTA - COMPROBANTE ' || :NEW.ID_COMPROBANTE,
      'Salida generada automáticamente por facturación.'
    );
  END IF;
END;
/

CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_MOV_STOCK_DETALLE_PROV
AFTER INSERT ON WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV
FOR EACH ROW
DECLARE
  v_id_oficina     COMPROBANTES.ID_OFICINA%TYPE;
  v_estado         COMPROBANTES.ESTADO%TYPE;
  v_tipo_comp      COMPROBANTES.TIPO_COMPROBANTE%TYPE;
  v_stock_actual   NUMBER;
BEGIN
  SELECT ESTADO, TIPO_COMPROBANTE, ID_OFICINA
  INTO v_estado, v_tipo_comp, v_id_oficina
  FROM COMPROBANTES_PROVEEDOR
  WHERE ID_COMPROBANTE = :NEW.ID_COMPROBANTE;

  IF v_estado = 'R' AND v_tipo_comp = 'FA' THEN
    INSERT INTO MOVIMIENTOS_STOCK (
      ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
      FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION
    ) VALUES (
      :NEW.ID_PRODUCTO, v_id_oficina, 'ENTRADA', :NEW.CANTIDAD,
      WKSP_WORKPLACE.FN_AHORA, 'COMPRA - COMPROBANTE ' || :NEW.ID_COMPROBANTE,
      'ENTRADA generada automáticamente por COMPRA.'
    );
  END IF;
END;
/
-- Se mantiene DESHABILITADO (estado original).
ALTER TRIGGER WKSP_WORKPLACE.TRG_MOV_STOCK_DETALLE_PROV DISABLE;

CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_MOV_STOCK_RECEPCION
AFTER INSERT ON WKSP_WORKPLACE.DETALLE_RECEPCION_COMPRA
FOR EACH ROW
DECLARE
  v_id_oficina   ORDENES_COMPRA.ID_OFICINA%TYPE;
  v_id_oc        ORDENES_COMPRA.ID_ORDEN_COMPRA%TYPE;
BEGIN
  SELECT r.ID_ORDEN_COMPRA, oc.ID_OFICINA
    INTO v_id_oc, v_id_oficina
    FROM RECEPCIONES_COMPRA r
    JOIN ORDENES_COMPRA oc ON oc.ID_ORDEN_COMPRA = r.ID_ORDEN_COMPRA
   WHERE r.ID_RECEPCION = :NEW.ID_RECEPCION;

  INSERT INTO MOVIMIENTOS_STOCK (
    ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
    FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION
  ) VALUES (
    :NEW.ID_PRODUCTO, v_id_oficina, 'ENTRADA', :NEW.CANTIDAD_RECIBIDA,
    WKSP_WORKPLACE.FN_AHORA, 'RECEPCION OC ' || v_id_oc,
    'Entrada generada automáticamente por RECEPCIÓN ' || :NEW.ID_RECEPCION
  );
END;
/

prompt == F20.7 INVENTARIO_PKG: FECHA_MOVIMIENTO de ajustes = fecha+hora local ==

CREATE OR REPLACE PACKAGE BODY WKSP_WORKPLACE.INVENTARIO_PKG AS
  PROCEDURE assert_estado(p_id NUMBER, p_estado VARCHAR2) IS
    v_estado INVENTARIO.ESTADO%TYPE;
  BEGIN
    SELECT estado INTO v_estado
      FROM INVENTARIO
     WHERE ID_INVENTARIO = p_id
     FOR UPDATE;
    IF v_estado <> p_estado THEN
      RAISE_APPLICATION_ERROR(-20001,'Estado inválido. Esperado '||p_estado||', actual: '||v_estado);
    END IF;
  END;

  -- ENVIAR: no mueve stock; solo sella y pasa a ENVIADO
  PROCEDURE enviar(p_id_inventario IN NUMBER, p_usuario IN VARCHAR2) IS
  BEGIN
    assert_estado(p_id_inventario,'BORRADOR');
    UPDATE INVENTARIO
       SET ESTADO='ENVIADO',
           USUARIO_ENVIO = p_usuario,
           FECHA_ENVIO   = SYSDATE
     WHERE ID_INVENTARIO = p_id_inventario;
  END enviar;

  -- APROBAR: genera movimientos de ajuste y pasa a APROBADO
  PROCEDURE aprobar(p_id_inventario IN NUMBER, p_usuario IN VARCHAR2) IS
    CURSOR c_det IS
      SELECT ID_PRODUCTO, DIFERENCIA
        FROM INVENTARIO_DETALLE
       WHERE ID_INVENTARIO = p_id_inventario
         AND DIFERENCIA <> 0;
    v_oficina NUMBER;
  BEGIN
    assert_estado(p_id_inventario,'ENVIADO');

    SELECT ID_OFICINA INTO v_oficina
      FROM INVENTARIO
     WHERE ID_INVENTARIO = p_id_inventario;

    FOR r IN c_det LOOP
      IF r.DIFERENCIA > 0 THEN
        INSERT INTO MOVIMIENTOS_STOCK
          (ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD, FECHA_MOVIMIENTO,
           REFERENCIA, OBSERVACION, USUARIO)
        VALUES
          (r.ID_PRODUCTO, v_oficina, 'ENTRADA', r.DIFERENCIA, WKSP_WORKPLACE.FN_AHORA,
           'INV:'||p_id_inventario, 'Ajuste inventario (aprobar)', p_usuario);
      ELSE
        INSERT INTO MOVIMIENTOS_STOCK
          (ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD, FECHA_MOVIMIENTO,
           REFERENCIA, OBSERVACION, USUARIO)
        VALUES
          (r.ID_PRODUCTO, v_oficina, 'SALIDA', ABS(r.DIFERENCIA), WKSP_WORKPLACE.FN_AHORA,
           'INV:'||p_id_inventario, 'Ajuste inventario (aprobar)', p_usuario);
      END IF;
    END LOOP;

    UPDATE INVENTARIO
       SET ESTADO             = 'APROBADO',
           USUARIO_APROBACION = p_usuario,
           FECHA_APROBACION   = SYSDATE
     WHERE ID_INVENTARIO = p_id_inventario;
  END aprobar;

  -- RECHAZAR: no mueve stock (como nunca se movió en ENVIADO)
  PROCEDURE rechazar(p_id_inventario IN NUMBER, p_usuario IN VARCHAR2, p_obs IN VARCHAR2) IS
  BEGIN
    assert_estado(p_id_inventario,'ENVIADO');
    UPDATE INVENTARIO
       SET ESTADO          = 'RECHAZADO',
           USUARIO_RECHAZO = p_usuario,
           FECHA_RECHAZO   = SYSDATE,
           OBSERVACION     = NVL(OBSERVACION,'')||CHR(10)||'Rechazado: '||p_obs
     WHERE ID_INVENTARIO = p_id_inventario;
  END rechazar;
END INVENTARIO_PKG;
/

prompt == F20 OK ==

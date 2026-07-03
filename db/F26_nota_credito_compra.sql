-- ============================================================================
-- F26 — Nota de Crédito de Compra / Proveedor (backend)
-- Plan: PLAN_NOTA_CREDITO_COMPRA.md
-- Espejo invertido y recortado de F14 (NC de venta): la NC la emite el PROVEEDOR
-- y nosotros la CAPTURAMOS. Reduce CxP (F24) y, si es devolución (motivos 1,2),
-- saca stock (SALIDA). Captura directa (sin workflow, sin talonario propio).
--
-- Idempotente. Aplicar:  sql -S -name tesis_db < db/F26_nota_credito_compra.sql
-- Rango de error: -20910 .. -20920
-- ============================================================================
SET DEFINE OFF
SET SERVEROUTPUT ON

-- ---------------------------------------------------------------------------
-- Paso 1 — Columnas nuevas (idempotente)
-- ---------------------------------------------------------------------------
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='COMPROBANTES_PROVEEDOR'
     AND column_name='COD_MOTIVO';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR ADD COD_MOTIVO NUMBER(2)';
    DBMS_OUTPUT.PUT_LINE('  + COMPROBANTES_PROVEEDOR.COD_MOTIVO agregada');
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE' AND table_name='DETALLE_COMPROBANTE_PROV'
     AND column_name='ID_DETALLE_ORIGEN';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV ADD ID_DETALLE_ORIGEN NUMBER';
    DBMS_OUTPUT.PUT_LINE('  + DETALLE_COMPROBANTE_PROV.ID_DETALLE_ORIGEN agregada');
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM all_constraints
   WHERE owner='WKSP_WORKPLACE' AND constraint_name='FK_CMPPROV_MOTIVO_NC';
  IF v_cnt = 0 THEN
    EXECUTE IMMEDIATE 'ALTER TABLE WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
      ADD CONSTRAINT FK_CMPPROV_MOTIVO_NC FOREIGN KEY (COD_MOTIVO)
      REFERENCES WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO(COD_MOTIVO)';
    DBMS_OUTPUT.PUT_LINE('  + FK_CMPPROV_MOTIVO_NC agregada');
  END IF;
END;
/

-- ---------------------------------------------------------------------------
-- Paso 2a — FN_CANT_ACREDITABLE_COMPRA: tope de la línea a fines de NC/CxP
--   = cantidad facturada − Σ ya acreditada por NC (cualquier motivo) sobre la línea.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_CANT_ACREDITABLE_COMPRA (
  p_id_detalle_origen IN NUMBER
) RETURN NUMBER IS
  v_facturada  NUMBER;
  v_acreditada NUMBER;
BEGIN
  SELECT CANTIDAD INTO v_facturada
    FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV
   WHERE ID_DETALLE = p_id_detalle_origen;

  SELECT NVL(SUM(d.CANTIDAD),0) INTO v_acreditada
    FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV d
    JOIN WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR nc ON nc.ID_COMPROBANTE = d.ID_COMPROBANTE
   WHERE d.ID_DETALLE_ORIGEN = p_id_detalle_origen
     AND nc.TIPO_COMPROBANTE = 'NC'
     AND nc.ESTADO <> 'A';

  RETURN NVL(v_facturada,0) - v_acreditada;
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN 0;
END;
/

-- ---------------------------------------------------------------------------
-- Paso 2b — FN_CANT_DEVOLVIBLE_COMPRA: tope de STOCK para devolución
--   = Σ recibido de ese producto (recepción ligada al comprobante, o a su OC si
--     la recepción no trae comprobante) − Σ ya devuelto por NC devolución previas.
--   Devuelve 0 si no hubo recepción → bloquea la SALIDA fantasma.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_CANT_DEVOLVIBLE_COMPRA (
  p_id_detalle_origen IN NUMBER
) RETURN NUMBER IS
  v_prod     NUMBER;
  v_comp     NUMBER;
  v_oc       NUMBER;
  v_recibido NUMBER;
  v_devuelto NUMBER;
BEGIN
  SELECT ID_PRODUCTO, ID_COMPROBANTE INTO v_prod, v_comp
    FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV
   WHERE ID_DETALLE = p_id_detalle_origen;

  SELECT ID_ORDEN_COMPRA INTO v_oc
    FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
   WHERE ID_COMPROBANTE = v_comp;

  SELECT NVL(SUM(drc.CANTIDAD_RECIBIDA),0) INTO v_recibido
    FROM WKSP_WORKPLACE.RECEPCIONES_COMPRA rc
    JOIN WKSP_WORKPLACE.DETALLE_RECEPCION_COMPRA drc ON drc.ID_RECEPCION = rc.ID_RECEPCION
   WHERE drc.ID_PRODUCTO = v_prod
     AND ( rc.ID_COMPROBANTE = v_comp
        OR (rc.ID_COMPROBANTE IS NULL AND rc.ID_ORDEN_COMPRA = v_oc) );

  SELECT NVL(SUM(d.CANTIDAD),0) INTO v_devuelto
    FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV d
    JOIN WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR nc ON nc.ID_COMPROBANTE = d.ID_COMPROBANTE
   WHERE d.ID_DETALLE_ORIGEN = p_id_detalle_origen
     AND nc.TIPO_COMPROBANTE = 'NC'
     AND nc.COD_MOTIVO IN (1,2)
     AND nc.ESTADO <> 'A';

  RETURN GREATEST(v_recibido - v_devuelto, 0);
EXCEPTION WHEN NO_DATA_FOUND THEN
  RETURN 0;
END;
/

-- ---------------------------------------------------------------------------
-- Paso 3 — FN_NC_COMPRA_ELEGIBLE: mensaje de bloqueo (o NULL si es elegible)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_NC_COMPRA_ELEGIBLE (
  p_id_factura IN NUMBER
) RETURN VARCHAR2 IS
  v_tipo   CHAR(2);
  v_estado VARCHAR2(30);
  v_forma  VARCHAR2(2);
  v_saldo  NUMBER;
BEGIN
  BEGIN
    SELECT TIPO_COMPROBANTE, ESTADO, FORMA_PAGO
      INTO v_tipo, v_estado, v_forma
      FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
     WHERE ID_COMPROBANTE = p_id_factura;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN 'La factura de compra no existe.';
  END;

  IF v_tipo <> 'FA' THEN
    RETURN 'El comprobante no es una factura de compra.';
  END IF;
  IF v_estado = 'A' THEN
    RETURN 'La factura está anulada.';
  END IF;
  IF NVL(v_forma,'x') <> '1' THEN
    RETURN 'La factura es de contado (sin cuenta por pagar); el reembolso está fuera de alcance.';
  END IF;

  BEGIN
    SELECT SALDO INTO v_saldo
      FROM WKSP_WORKPLACE.CUENTAS_PAGAR
     WHERE ID_COMPROBANTE = p_id_factura;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN 'La factura no generó cuenta por pagar.';
  END;

  IF NVL(v_saldo,0) <= 0 THEN
    RETURN 'La factura ya está saldada; no hay saldo pendiente para acreditar.';
  END IF;

  RETURN NULL;  -- elegible
END;
/

-- ---------------------------------------------------------------------------
-- Paso 4 — PRC_REGISTRAR_NC_COMPRA (atómica, captura directa + efectos)
--   Líneas vía arrays paralelos (ID_DETALLE_ORIGEN, cantidad, precio a acreditar).
--   NO hace COMMIT (APEX commitea). Errores -20911..-20920.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_REGISTRAR_NC_COMPRA (
  p_id_factura      IN  NUMBER,
  p_cod_motivo      IN  NUMBER,
  p_nro_comprobante IN  VARCHAR2,
  p_nro_timbrado    IN  VARCHAR2,
  p_fecha_emision   IN  DATE,
  p_observacion     IN  VARCHAR2,
  p_det_origen      IN  SYS.ODCINUMBERLIST,
  p_det_cantidad    IN  SYS.ODCINUMBERLIST,
  p_det_precio      IN  SYS.ODCINUMBERLIST,
  p_id_nc           OUT NUMBER
) IS
  v_msg            VARCHAR2(400);
  v_dev_stock      CHAR(1);
  v_total          NUMBER := 0;
  v_saldo          NUMBER;
  v_cnt            NUMBER;
  -- datos de la factura origen
  v_proveedor      NUMBER;
  v_moneda         VARCHAR2(10);
  v_tipo_cambio    NUMBER;
  v_oficina        NUMBER;
  v_oc             NUMBER;
  -- por línea
  v_linea_comp     NUMBER;
  v_precio_fact    NUMBER;
  v_producto       NUMBER;
  v_onhand         NUMBER;
  v_usuario        VARCHAR2(60) := NVL(V('APP_USER'), USER);
BEGIN
  -- 1. Elegibilidad de la factura
  v_msg := WKSP_WORKPLACE.FN_NC_COMPRA_ELEGIBLE(p_id_factura);
  IF v_msg IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20911, v_msg);
  END IF;

  -- Motivo válido y activo
  SELECT COUNT(*) INTO v_cnt FROM WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO
   WHERE COD_MOTIVO = p_cod_motivo AND ACTIVO = 'S';
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20917, 'El motivo de la nota de crédito no existe o no está activo.');
  END IF;

  -- Arrays coherentes y no vacíos
  IF p_det_origen IS NULL OR p_det_origen.COUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20914, 'La nota de crédito no tiene líneas a acreditar.');
  END IF;
  IF p_det_cantidad.COUNT <> p_det_origen.COUNT
     OR p_det_precio.COUNT <> p_det_origen.COUNT THEN
    RAISE_APPLICATION_ERROR(-20914, 'Las líneas de la nota de crédito están incompletas.');
  END IF;

  -- Datos de la factura origen (proveedor, moneda, oficina, OC)
  SELECT c.ID_PROVEEDOR, c.MONEDA, c.TIPO_CAMBIO, c.ID_ORDEN_COMPRA,
         NVL(oc.ID_OFICINA, c.ID_OFICINA)
    INTO v_proveedor, v_moneda, v_tipo_cambio, v_oc, v_oficina
    FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR c
    LEFT JOIN WKSP_WORKPLACE.ORDENES_COMPRA oc ON oc.ID_ORDEN_COMPRA = c.ID_ORDEN_COMPRA
   WHERE c.ID_COMPROBANTE = p_id_factura;

  -- Devuelve stock sólo para Devolución (motivos 1 y 2)
  v_dev_stock := CASE WHEN p_cod_motivo IN (1,2) THEN 'S' ELSE 'N' END;

  -- 2. Validar cada línea + calcular total
  FOR i IN 1 .. p_det_origen.COUNT LOOP
    -- la línea origen debe pertenecer a la factura
    BEGIN
      SELECT ID_COMPROBANTE, PRECIO_UNITARIO, ID_PRODUCTO
        INTO v_linea_comp, v_precio_fact, v_producto
        FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV
       WHERE ID_DETALLE = p_det_origen(i);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20912, 'La línea a acreditar no existe.');
    END;
    IF v_linea_comp <> p_id_factura THEN
      RAISE_APPLICATION_ERROR(-20912, 'La línea a acreditar no pertenece a la factura indicada.');
    END IF;

    IF NVL(p_det_cantidad(i),0) <= 0 THEN
      RAISE_APPLICATION_ERROR(-20912, 'La cantidad a acreditar debe ser mayor a 0.');
    END IF;
    IF p_det_cantidad(i) > WKSP_WORKPLACE.FN_CANT_ACREDITABLE_COMPRA(p_det_origen(i)) THEN
      RAISE_APPLICATION_ERROR(-20912, 'La cantidad a acreditar excede lo disponible en la línea.');
    END IF;

    IF NVL(p_det_precio(i),0) <= 0 OR p_det_precio(i) > v_precio_fact THEN
      RAISE_APPLICATION_ERROR(-20913, 'El precio a acreditar debe estar entre 0 y el precio facturado.');
    END IF;

    -- Devolución: tope por recibido (-20919) + guarda de on-hand (-20920)
    IF v_dev_stock = 'S' THEN
      IF p_det_cantidad(i) > WKSP_WORKPLACE.FN_CANT_DEVOLVIBLE_COMPRA(p_det_origen(i)) THEN
        RAISE_APPLICATION_ERROR(-20919,
          'No se puede devolver más de lo recibido (la factura puede no tener mercadería recibida). '
          ||'Para un descuento/anulación usá un motivo sin devolución.');
      END IF;
      SELECT NVL(MAX(CANTIDAD),0) INTO v_onhand
        FROM WKSP_WORKPLACE.STOCK_PRODUCTO
       WHERE ID_PRODUCTO = v_producto AND ID_OFICINA = v_oficina;
      IF p_det_cantidad(i) > v_onhand THEN
        RAISE_APPLICATION_ERROR(-20920,
          'Stock insuficiente para la devolución: la mercadería ya no está disponible.');
      END IF;
    END IF;

    v_total := v_total + (p_det_cantidad(i) * p_det_precio(i));
  END LOOP;

  IF v_total <= 0 THEN
    RAISE_APPLICATION_ERROR(-20914, 'El total de la nota de crédito es 0.');
  END IF;

  -- 3. Cap contra el saldo de la CxP (lock)
  BEGIN
    SELECT SALDO INTO v_saldo
      FROM WKSP_WORKPLACE.CUENTAS_PAGAR
     WHERE ID_COMPROBANTE = p_id_factura
     FOR UPDATE;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20916, 'La factura no tiene cuenta por pagar asociada.');
  END;
  IF v_total > v_saldo THEN
    RAISE_APPLICATION_ERROR(-20915,
      'La nota de crédito excede el saldo pendiente; el reembolso de lo ya pagado está fuera de alcance.');
  END IF;

  -- 4. INSERT cabecera NC (FORMA_PAGO=NULL para no disparar TRG_INS_CUENTAS_PAGAR)
  INSERT INTO WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR (
    TIPO_COMPROBANTE, ESTADO, ID_PROVEEDOR, MONEDA, TIPO_CAMBIO, ID_OFICINA,
    ID_ORDEN_COMPRA, FORMA_PAGO, COD_MOTIVO, ID_FAC_ORIGEN,
    NRO_COMPROBANTE, NRO_TIMBRADO, FECHA_EMISION, TOTAL_COMPROBANTE, OBSERVACION
  ) VALUES (
    'NC', 'R', v_proveedor, v_moneda, v_tipo_cambio, v_oficina,
    NULL, NULL, p_cod_motivo, p_id_factura,
    p_nro_comprobante, p_nro_timbrado, p_fecha_emision, v_total, p_observacion
  ) RETURNING ID_COMPROBANTE INTO p_id_nc;

  -- 5. INSERT detalle (no mueve stock: TRG_MOV_STOCK_DETALLE_PROV está DISABLED)
  FOR i IN 1 .. p_det_origen.COUNT LOOP
    SELECT ID_PRODUCTO INTO v_producto
      FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV WHERE ID_DETALLE = p_det_origen(i);
    INSERT INTO WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV (
      ID_COMPROBANTE, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, TOTAL, ID_DETALLE_ORIGEN
    ) VALUES (
      p_id_nc, v_producto, p_det_cantidad(i), p_det_precio(i),
      p_det_cantidad(i) * p_det_precio(i), p_det_origen(i)
    );
  END LOOP;

  -- 6. Stock SALIDA (sólo devolución). El trigger TRG_ACTUALIZAR_STOCK_MOVIMIENTO
  --    decrementa STOCK_PRODUCTO y es el backstop final de stock no-negativo.
  IF v_dev_stock = 'S' THEN
    FOR i IN 1 .. p_det_origen.COUNT LOOP
      SELECT ID_PRODUCTO INTO v_producto
        FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV WHERE ID_DETALLE = p_det_origen(i);
      INSERT INTO WKSP_WORKPLACE.MOVIMIENTOS_STOCK (
        ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
        FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION, USUARIO
      ) VALUES (
        v_producto, v_oficina, 'SALIDA', p_det_cantidad(i),
        WKSP_WORKPLACE.FN_AHORA, 'NC COMPRA '||p_id_nc,
        'Devolución a proveedor por NC de compra '||p_id_nc||' (factura '||p_id_factura||')',
        v_usuario
      );
    END LOOP;
  END IF;

  -- 7. Reducir la CxP; total → ANULADA (deuda extinguida por crédito), parcial → PARCIAL
  UPDATE WKSP_WORKPLACE.CUENTAS_PAGAR
     SET SALDO  = SALDO - v_total,
         ESTADO = CASE WHEN SALDO - v_total <= 0 THEN 'ANULADA' ELSE 'PARCIAL' END
   WHERE ID_COMPROBANTE = p_id_factura;
END;
/

-- ---------------------------------------------------------------------------
-- Paso 6 — Vista V_NC_COMPRA (NC emitidas por proveedor)
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_NC_COMPRA AS
SELECT nc.ID_COMPROBANTE                                   AS ID_NC,
       nc.NRO_COMPROBANTE,
       nc.NRO_TIMBRADO,
       nc.FECHA_EMISION,
       nc.ID_PROVEEDOR,
       TRIM(per.PRIMER_NOMBRE||' '||per.PRIMER_APELLIDO)   AS PROVEEDOR,
       nc.COD_MOTIVO,
       m.DESCRIPCION                                       AS MOTIVO,
       CASE WHEN nc.COD_MOTIVO IN (1,2) THEN 'S' ELSE 'N' END AS DEVUELVE_STOCK,
       nc.TOTAL_COMPROBANTE                                AS TOTAL,
       nc.ID_FAC_ORIGEN,
       f.NRO_COMPROBANTE                                   AS NRO_FACTURA_ORIGEN,
       nc.ESTADO,
       nc.OBSERVACION
  FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR nc
  JOIN WKSP_WORKPLACE.PROVEEDORES pr             ON pr.ID_PERSONA   = nc.ID_PROVEEDOR
  LEFT JOIN WKSP_WORKPLACE.PERSONAS per          ON per.ID_PERSONA  = pr.ID_PERSONA
  LEFT JOIN WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO m ON m.COD_MOTIVO    = nc.COD_MOTIVO
  LEFT JOIN WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR f ON f.ID_COMPROBANTE = nc.ID_FAC_ORIGEN
 WHERE nc.TIPO_COMPROBANTE = 'NC';

-- ---------------------------------------------------------------------------
-- Paso 7 — Verificación
-- ---------------------------------------------------------------------------
DECLARE
  v_cols   NUMBER;
  v_inval  NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cols FROM all_tab_columns
   WHERE owner='WKSP_WORKPLACE'
     AND ( (table_name='COMPROBANTES_PROVEEDOR'  AND column_name='COD_MOTIVO')
        OR (table_name='DETALLE_COMPROBANTE_PROV' AND column_name='ID_DETALLE_ORIGEN') );

  SELECT COUNT(*) INTO v_inval FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND status='INVALID'
     AND object_name IN ('FN_CANT_ACREDITABLE_COMPRA','FN_CANT_DEVOLVIBLE_COMPRA',
                         'FN_NC_COMPRA_ELEGIBLE','PRC_REGISTRAR_NC_COMPRA','V_NC_COMPRA');

  DBMS_OUTPUT.PUT_LINE('=== F26 verificación ===');
  DBMS_OUTPUT.PUT_LINE('Columnas nuevas presentes (esperado 2): '||v_cols);
  DBMS_OUTPUT.PUT_LINE('Objetos F26 INVALID (esperado 0): '||v_inval);

  IF v_cols <> 2 OR v_inval <> 0 THEN
    RAISE_APPLICATION_ERROR(-20910, 'F26: verificación fallida (columnas o compilación).');
  END IF;
  DBMS_OUTPUT.PUT_LINE('F26 OK.');
END;
/

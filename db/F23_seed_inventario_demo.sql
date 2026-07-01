-- ============================================================================
-- F23_seed_inventario_demo.sql  (H1 — Reportes Gerenciales de Inventario)
-- ----------------------------------------------------------------------------
-- Seed de DEMOSTRACION (idempotente) para los Reportes Gerenciales de Inventario.
-- NO crea DDL: min/max ya existen en STOCK_PRODUCTO y el costo se resuelve por
-- COALESCE(FN_COSTO_PONDERADO, ultimo precio ACTIVO de PRODUCTO_PROVEEDORES).
--
-- Hace tres cosas (todas idempotentes, solo tocan lo que falta):
--   A) Rellena STOCK_MINIMO / STOCK_MAXIMO faltantes de las 6 filas existentes,
--      calibrado para un mix de niveles (algun BAJO_MINIMO).
--   B) Agrega 4 productos demo en categorias reales distintas a "Gaming"
--      (Laptops, Smartphones, Audio, Televisores) con marca, stock (mix de
--      niveles: OK / SOBRE_MAXIMO / QUIEBRE / BAJO_MINIMO) y precio de proveedor
--      (Nissei S.A., id 101) -> costo resoluble sin mover stock.
--   C) Completa el costo del Monitor (prod 1), que no tenia ninguna fuente de
--      costo, con un precio ACTIVO en PRODUCTO_PROVEEDORES (sin factura de
--      compra -> no dispara ENTRADA de stock, ver PLAN_REPORTES_INVENTARIO.md
--      seccion 1.3).
--
-- Notas de mecanica (verificadas en tesis_db 2026-06-30):
--   * ID_PRODUCTO / ID_MARCA son IDENTITY -> se capturan por nombre.
--   * PRODUCTO_PROVEEDORES.TRG_CIERRE_PP_ANTERIOR cierra el precio activo previo
--     al insertar uno nuevo -> el insert de precio se guarda con NOT EXISTS para
--     no apilar precios al re-correr.
--   * Fechas de negocio/auditoria en hora LOCAL via FN_HOY/FN_AHORA (BD en UTC).
--   * Proveedor: Nissei S.A. (ID_PERSONA=101). Dato de DEMO, no historico real.
--
-- Rango de error del modulo: -20921 .. -20929  (verificacion -> -20921).
-- Aplicar:  sql -S -name tesis_db < db/F23_seed_inventario_demo.sql
-- ============================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF

DECLARE
  c_prov_nissei   CONSTANT NUMBER := 101;   -- Nissei S.A.
  c_ofi_petit     CONSTANT NUMBER := 1;     -- Suc - Roberto L Petit
  c_ofi_villa     CONSTANT NUMBER := 2;     -- Suc - Villarrica
  c_iva_10        CONSTANT NUMBER := 1;     -- IVA 10%

  v_id_lenovo   NUMBER;
  v_id_samsung  NUMBER;
  v_id_jbl      NUMBER;
  v_id_lg       NUMBER;

  v_p_notebook  NUMBER;
  v_p_smart     NUMBER;
  v_p_parlante  NUMBER;
  v_p_tv        NUMBER;

  -- Verificacion
  v_sin_nivel   NUMBER;
  v_bajo        NUMBER;
  v_sobre       NUMBER;
  v_quiebre     NUMBER;
  v_sin_costo   NUMBER;

  -- ------------------------------------------------------------------
  -- Marca: devuelve el ID (crea si no existe, por NOMBRE)
  -- ------------------------------------------------------------------
  FUNCTION get_or_create_marca(p_nombre IN VARCHAR2) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    BEGIN
      SELECT ID_MARCA INTO v_id
      FROM WKSP_WORKPLACE.MARCAS WHERE UPPER(NOMBRE) = UPPER(p_nombre);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO WKSP_WORKPLACE.MARCAS (NOMBRE) VALUES (p_nombre)
      RETURNING ID_MARCA INTO v_id;
    END;
    RETURN v_id;
  END;

  -- ------------------------------------------------------------------
  -- Producto: devuelve el ID (crea si no existe, por NOMBRE)
  -- ------------------------------------------------------------------
  FUNCTION get_or_create_producto(
      p_nombre    IN VARCHAR2,
      p_categoria IN NUMBER,
      p_marca     IN NUMBER,
      p_modelo    IN VARCHAR2,
      p_cod_prov  IN VARCHAR2,
      p_descr     IN VARCHAR2
  ) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    BEGIN
      SELECT ID_PRODUCTO INTO v_id
      FROM WKSP_WORKPLACE.PRODUCTOS WHERE UPPER(NOMBRE) = UPPER(p_nombre);
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO WKSP_WORKPLACE.PRODUCTOS
        (NOMBRE, ID_CATEGORIA, ID_MARCA, DESCRIPCION, MODELO, CODIGO_PROVEEDOR, ACTIVO, ID_TIPO_IVA)
      VALUES
        (p_nombre, p_categoria, p_marca, p_descr, p_modelo, p_cod_prov, 'S', c_iva_10)
      RETURNING ID_PRODUCTO INTO v_id;
    END;
    RETURN v_id;
  END;

  -- ------------------------------------------------------------------
  -- Stock: inserta la fila (prod,ofi) si no existe, con cantidad/min/max
  -- ------------------------------------------------------------------
  PROCEDURE upsert_stock(
      p_prod IN NUMBER, p_ofi IN NUMBER,
      p_cant IN NUMBER, p_min IN NUMBER, p_max IN NUMBER
  ) IS
    v_ex NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_ex
    FROM WKSP_WORKPLACE.STOCK_PRODUCTO
    WHERE ID_PRODUCTO = p_prod AND ID_OFICINA = p_ofi;

    IF v_ex = 0 THEN
      INSERT INTO WKSP_WORKPLACE.STOCK_PRODUCTO
        (ID_PRODUCTO, ID_OFICINA, CANTIDAD, STOCK_MINIMO, STOCK_MAXIMO)
      VALUES (p_prod, p_ofi, p_cant, p_min, p_max);
    ELSE
      -- solo completa min/max si estaban NULL (no pisa datos ya cargados)
      UPDATE WKSP_WORKPLACE.STOCK_PRODUCTO
         SET STOCK_MINIMO = NVL(STOCK_MINIMO, p_min),
             STOCK_MAXIMO = NVL(STOCK_MAXIMO, p_max)
       WHERE ID_PRODUCTO = p_prod AND ID_OFICINA = p_ofi;
    END IF;
  END;

  -- ------------------------------------------------------------------
  -- Precio de proveedor ACTIVO: inserta si no hay uno vigente (idempotente)
  -- ------------------------------------------------------------------
  PROCEDURE ensure_precio(p_prod IN NUMBER, p_persona IN NUMBER, p_precio IN NUMBER) IS
    v_ex NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_ex
    FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
    WHERE ID_PRODUCTO = p_prod AND ID_PERSONA = p_persona
      AND ESTADO = 'ACTIVO' AND FECHA_FIN IS NULL;

    IF v_ex = 0 THEN
      INSERT INTO WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
        (ID_PRODUCTO, ID_PERSONA, PRECIO, FECHA_INICIO, ESTADO)
      VALUES (p_prod, p_persona, p_precio, WKSP_WORKPLACE.FN_HOY, 'ACTIVO');
    END IF;
  END;

BEGIN
  -- ==================================================================
  -- A) Rellenar min/max faltantes de las 6 filas existentes
  --    (NVL -> idempotente; calibrado para mostrar BAJO_MINIMO)
  -- ==================================================================
  upsert_stock(1, c_ofi_petit, NULL, 10,  50);   -- Monitor Petit    15 -> OK
  upsert_stock(1, c_ofi_villa, NULL,  8,  30);   -- Monitor Villa     5 -> BAJO_MINIMO
  upsert_stock(2, c_ofi_petit, NULL, 20, 100);   -- Silla Petit      79 -> OK
  upsert_stock(3, c_ofi_petit, NULL, 15,  70);   -- Auriculares Petit 35 -> OK
  upsert_stock(4, c_ofi_villa, NULL,  5,  25);   -- Mouse Villa       3 -> BAJO_MINIMO
  -- (4,Petit) ya tiene min 10 / max 140 -> no se toca

  -- ==================================================================
  -- B) Productos demo nuevos (categorias reales) + marca + stock + precio
  -- ==================================================================
  v_id_lenovo  := get_or_create_marca('Lenovo');
  v_id_samsung := get_or_create_marca('Samsung');
  v_id_jbl     := get_or_create_marca('JBL');
  v_id_lg      := get_or_create_marca('LG');

  -- Laptops (9)  -> OK
  v_p_notebook := get_or_create_producto(
      'Notebook Lenovo IdeaPad Slim 3', 9, v_id_lenovo,
      'IdeaPad Slim 3 15IAU7', 'LENV-LAP-007',
      'Notebook 15.6" Intel Core i5, 8GB RAM, 512GB SSD');
  upsert_stock(v_p_notebook, c_ofi_petit, 8, 5, 20);
  ensure_precio(v_p_notebook, c_prov_nissei, 3200000);

  -- Smartphones (10)  -> SOBRE_MAXIMO (45 > 40)
  v_p_smart := get_or_create_producto(
      'Smartphone Samsung Galaxy A54 5G', 10, v_id_samsung,
      'Galaxy A54 5G 256GB', 'SMSG-SPH-008',
      'Smartphone 6.4" AMOLED, 256GB, 5G');
  upsert_stock(v_p_smart, c_ofi_petit, 45, 15, 40);
  ensure_precio(v_p_smart, c_prov_nissei, 2100000);

  -- Audio (4)  -> QUIEBRE (cantidad 0)
  v_p_parlante := get_or_create_producto(
      'Parlante Bluetooth JBL Charge 5', 4, v_id_jbl,
      'Charge 5', 'JBL-AUD-009',
      'Parlante portatil Bluetooth resistente al agua IP67');
  upsert_stock(v_p_parlante, c_ofi_petit, 0, 5, 30);
  ensure_precio(v_p_parlante, c_prov_nissei, 620000);

  -- Televisores (8)  -> Petit OK / Villarrica BAJO_MINIMO (2 < 4)
  v_p_tv := get_or_create_producto(
      'Smart TV LG 50" UHD 4K', 8, v_id_lg,
      '50UR7300', 'LG-TVL-010',
      'Smart TV LED 50" 4K UHD webOS');
  upsert_stock(v_p_tv, c_ofi_petit, 12, 6, 25);
  upsert_stock(v_p_tv, c_ofi_villa,  2, 4, 15);
  ensure_precio(v_p_tv, c_prov_nissei, 2450000);

  -- ==================================================================
  -- C) Completar costo del Monitor (prod 1): sin compras ni precio previo
  -- ==================================================================
  ensure_precio(1, c_prov_nissei, 1500000);

  -- ==================================================================
  -- VERIFICACION (todo debe cumplirse antes de COMMIT)
  -- ==================================================================
  -- 1) Ninguna fila de stock sin min/max
  SELECT COUNT(*) INTO v_sin_nivel
  FROM WKSP_WORKPLACE.STOCK_PRODUCTO
  WHERE STOCK_MINIMO IS NULL OR STOCK_MAXIMO IS NULL;

  -- 2) Conteo de niveles (semaforo) sobre el on-hand
  SELECT
      SUM(CASE WHEN CANTIDAD = 0 THEN 1 ELSE 0 END),
      SUM(CASE WHEN CANTIDAD > 0 AND CANTIDAD < STOCK_MINIMO THEN 1 ELSE 0 END),
      SUM(CASE WHEN STOCK_MAXIMO IS NOT NULL AND CANTIDAD > STOCK_MAXIMO THEN 1 ELSE 0 END)
    INTO v_quiebre, v_bajo, v_sobre
  FROM WKSP_WORKPLACE.STOCK_PRODUCTO;

  -- 3) Todo producto con stock debe tener costo resoluble (ponderado o precio prov.)
  SELECT COUNT(*) INTO v_sin_costo
  FROM ( SELECT DISTINCT sp.ID_PRODUCTO FROM WKSP_WORKPLACE.STOCK_PRODUCTO sp ) x
  WHERE COALESCE(
          WKSP_WORKPLACE.FN_COSTO_PONDERADO(x.ID_PRODUCTO, 100000),
          (SELECT MAX(pp.PRECIO) FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp
            WHERE pp.ID_PRODUCTO = x.ID_PRODUCTO AND pp.ESTADO = 'ACTIVO' AND pp.FECHA_FIN IS NULL)
        ) IS NULL;

  DBMS_OUTPUT.PUT_LINE('Verificacion F23 seed:');
  DBMS_OUTPUT.PUT_LINE('  filas stock sin min/max : ' || v_sin_nivel);
  DBMS_OUTPUT.PUT_LINE('  QUIEBRE (0)             : ' || v_quiebre);
  DBMS_OUTPUT.PUT_LINE('  BAJO_MINIMO             : ' || v_bajo);
  DBMS_OUTPUT.PUT_LINE('  SOBRE_MAXIMO            : ' || v_sobre);
  DBMS_OUTPUT.PUT_LINE('  productos sin costo     : ' || v_sin_costo);

  IF v_sin_nivel > 0 THEN
    RAISE_APPLICATION_ERROR(-20921, 'F23 seed: quedaron '||v_sin_nivel||' filas de stock sin min/max.');
  END IF;
  IF v_sin_costo > 0 THEN
    RAISE_APPLICATION_ERROR(-20921, 'F23 seed: quedaron '||v_sin_costo||' productos sin costo resoluble.');
  END IF;
  IF v_quiebre < 1 OR v_bajo < 1 OR v_sobre < 1 THEN
    RAISE_APPLICATION_ERROR(-20921, 'F23 seed: el mix de niveles no cubre QUIEBRE/BAJO/SOBRE (q='||
      v_quiebre||' b='||v_bajo||' s='||v_sobre||').');
  END IF;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('F23 seed aplicado y verificado OK. COMMIT.');
END;
/

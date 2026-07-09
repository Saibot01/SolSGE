-- ============================================================================
-- F29_seed_ubicaciones_inventario.sql  (Ubicacion fisica de inventario - Oficina 1)
-- ----------------------------------------------------------------------------
-- Puebla el mapa de ubicacion fisica de la sucursal "Suc - Roberto L Petit"
-- (ID_OFICINA=1) y corrige el inventario INV-202607-000081 (ID_INVENTARIO=81),
-- cuyos renglones mostraban ORDEN_SECTOR / ORDEN_UBICACION = 999999.
--
-- CAUSA (diagnostico verificado en tesis_db 2026-07-09):
--   999999 NO es un dato erroneo: es el fallback "sin ubicacion asignada" que el
--   detalle guarda cuando el producto no tiene fila en PRODUCTO_UBICACION.
--   Las tres tablas de ubicacion fisica estaban VACIAS (0 filas), por eso TODOS
--   los renglones caian al placeholder con ID_SECTOR / ID_UBICACION en NULL.
--
-- Hace tres cosas (todas idempotentes -> re-ejecutable sin duplicar):
--   A) SECTORES:            4 zonas del deposito para la oficina 1, con ORDEN de
--                           recorrido (Gaming 10, Audio/Video 20, Informatica 30,
--                           Telefonia 40).
--   B) UBICACIONES:         7 estantes (CODIGO nemotecnico: <sector>-<rack><nivel>,
--                           p.ej. G-A1), con ORDEN de recorrido dentro del sector.
--   C) PRODUCTO_UBICACION:  8 asignaciones producto -> sector+ubicacion (oficina 1)
--                           para los productos del inventario 81.
--   D) INVENTARIO_DETALLE:  reemplaza NULL/999999 del inventario 81 por el sector,
--                           la ubicacion y sus ordenes reales (via PRODUCTO_UBICACION).
--
-- Notas de mecanica (verificadas en tesis_db 2026-07-09):
--   * SECTORES.ID_SECTOR y UBICACIONES.ID_UBICACION son IDENTITY (BY DEFAULT) ->
--     se resuelven por clave natural (UK_SECTOR = id_oficina+nombre;
--     UK_UBIC = id_sector+codigo), no por id fijo, para ser re-ejecutable.
--   * PRODUCTO_UBICACION: PK (id_producto, id_oficina) -> insert con NOT EXISTS.
--   * CODIGO de UBICACIONES es solo etiqueta legible para el operario; el ORDEN
--     de la planilla lo fijan SECTORES.ORDEN y UBICACIONES.ORDEN, no el string.
--   * Fecha de auditoria en hora LOCAL de negocio (UTC-3): la BD corre en UTC y
--     FN_HOY/FN_AHORA no existen en este entorno -> se usa
--     CAST(SYSTIMESTAMP AT TIME ZONE 'America/Argentina/Buenos_Aires' AS DATE).
--   * cantidad_fisica NO se toca (queda 0): es el conteo fisico y el inventario
--     esta en BORRADOR.
--
-- Aplicar:  sql -S -name tesis_db < db/F29_seed_ubicaciones_inventario.sql
-- ============================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF

DECLARE
  c_ofi_petit  CONSTANT NUMBER := 1;   -- Suc - Roberto L Petit
  c_inv        CONSTANT NUMBER := 81;  -- INV-202607-000081
  v_now        DATE := CAST(SYSTIMESTAMP AT TIME ZONE 'America/Argentina/Buenos_Aires' AS DATE);
  v_user       CONSTANT VARCHAR2(100) := 'DATA_FIX';

  -- Variables de trabajo (deben declararse antes de los subprogramas anidados).
  s_gaming NUMBER; s_av NUMBER; s_inf NUMBER; s_tel NUMBER;
  u_ga1 NUMBER; u_ga2 NUMBER; u_gb1 NUMBER; u_ava1 NUMBER; u_ava2 NUMBER; u_inf1 NUMBER; u_tel1 NUMBER;
  v_upd NUMBER;

  -- Alta idempotente de un sector; devuelve su id (existente o nuevo).
  FUNCTION get_sector(p_nombre VARCHAR2, p_orden NUMBER) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    BEGIN
      SELECT id_sector INTO v_id
        FROM WKSP_WORKPLACE.SECTORES
       WHERE id_oficina = c_ofi_petit AND nombre = p_nombre;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO WKSP_WORKPLACE.SECTORES (id_oficina, nombre, orden, activo)
      VALUES (c_ofi_petit, p_nombre, p_orden, 'S')
      RETURNING id_sector INTO v_id;
    END;
    RETURN v_id;
  END;

  -- Alta idempotente de una ubicacion; devuelve su id (existente o nueva).
  FUNCTION get_ubic(p_sector NUMBER, p_codigo VARCHAR2, p_orden NUMBER) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    BEGIN
      SELECT id_ubicacion INTO v_id
        FROM WKSP_WORKPLACE.UBICACIONES
       WHERE id_sector = p_sector AND codigo = p_codigo;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      INSERT INTO WKSP_WORKPLACE.UBICACIONES (id_sector, codigo, orden, activo)
      VALUES (p_sector, p_codigo, p_orden, 'S')
      RETURNING id_ubicacion INTO v_id;
    END;
    RETURN v_id;
  END;

  -- Asigna un producto a una ubicacion (oficina 1) si aun no lo esta.
  PROCEDURE set_prod_ubic(p_prod NUMBER, p_sector NUMBER, p_ubic NUMBER, p_pos NUMBER) IS
  BEGIN
    INSERT INTO WKSP_WORKPLACE.PRODUCTO_UBICACION
      (id_producto, id_oficina, id_sector, id_ubicacion, orden_posicion, fecha_creacion, usuario_creacion)
    SELECT p_prod, c_ofi_petit, p_sector, p_ubic, p_pos, v_now, v_user FROM dual
     WHERE NOT EXISTS (
       SELECT 1 FROM WKSP_WORKPLACE.PRODUCTO_UBICACION
        WHERE id_producto = p_prod AND id_oficina = c_ofi_petit);
  END;
BEGIN
  -- A) SECTORES (oficina 1) --------------------------------------------------
  s_gaming := get_sector('Depósito Gaming',         10);
  s_av     := get_sector('Depósito Audio y Video',  20);
  s_inf    := get_sector('Depósito Informática',    30);
  s_tel    := get_sector('Depósito Telefonía',      40);

  -- B) UBICACIONES (estantes por sector) -------------------------------------
  u_ga1  := get_ubic(s_gaming, 'G-A1',  1);
  u_ga2  := get_ubic(s_gaming, 'G-A2',  2);
  u_gb1  := get_ubic(s_gaming, 'G-B1',  3);
  u_ava1 := get_ubic(s_av,     'AV-A1', 1);
  u_ava2 := get_ubic(s_av,     'AV-A2', 2);
  u_inf1 := get_ubic(s_inf,    'INF-A1',1);
  u_tel1 := get_ubic(s_tel,    'TEL-A1',1);

  -- C) PRODUCTO_UBICACION (asignacion oficina 1) -----------------------------
  --    prod, sector, ubicacion, orden dentro de la ubicacion
  set_prod_ubic(1,  s_gaming, u_ga1,  1);  -- Monitor Gaming Gigabyte G27Q
  set_prod_ubic(3,  s_gaming, u_ga2,  1);  -- Auriculares HyperX Cloud II
  set_prod_ubic(4,  s_gaming, u_ga2,  2);  -- Mouse Razer DeathAdder V2
  set_prod_ubic(2,  s_gaming, u_gb1,  1);  -- Silla Gamer DXRacer Formula (voluminoso)
  set_prod_ubic(23, s_av,     u_ava1, 1);  -- Parlante Bluetooth JBL Charge 5
  set_prod_ubic(24, s_av,     u_ava2, 1);  -- Smart TV LG 50" UHD 4K
  set_prod_ubic(21, s_inf,    u_inf1, 1);  -- Notebook Lenovo IdeaPad Slim 3
  set_prod_ubic(22, s_tel,    u_tel1, 1);  -- Smartphone Samsung Galaxy A54 5G

  -- D) Corregir el detalle del inventario 81 desde las asignaciones ----------
  UPDATE WKSP_WORKPLACE.INVENTARIO_DETALLE d
     SET (d.id_sector, d.id_ubicacion, d.orden_sector, d.orden_ubicacion) =
         (SELECT pu.id_sector, pu.id_ubicacion, s.orden, u.orden
            FROM WKSP_WORKPLACE.PRODUCTO_UBICACION pu
            JOIN WKSP_WORKPLACE.SECTORES    s ON s.id_sector    = pu.id_sector
            JOIN WKSP_WORKPLACE.UBICACIONES u ON u.id_ubicacion = pu.id_ubicacion
           WHERE pu.id_producto = d.id_producto AND pu.id_oficina = c_ofi_petit)
   WHERE d.id_inventario = c_inv
     AND EXISTS (SELECT 1 FROM WKSP_WORKPLACE.PRODUCTO_UBICACION pu
                  WHERE pu.id_producto = d.id_producto AND pu.id_oficina = c_ofi_petit);
  v_upd := SQL%ROWCOUNT;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('F29 OK - sectores/ubicaciones/asignaciones aplicados; '
                       || 'renglones de inventario '||c_inv||' actualizados: '||v_upd);
END;
/

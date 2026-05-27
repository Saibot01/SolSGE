-- ============================================================================
-- F3 - Disponibilidad de stock por oficina (backend)
-- ============================================================================
-- Provee 3 funciones para que la UI (P54 Presupuesto) muestre al vendedor
-- si un producto esta disponible en su oficina sin exponer cantidades:
--
--   FN_OFICINA_USUARIO(p_usuario)   -> id_oficina del usuario logueado
--                                       (resuelto via caja abierta)
--   FN_HAY_STOCK(prod, ofic, orden) -> 'S' / 'N'  (excluye reservas
--                                       de la misma orden para edicion)
--   FN_OFICINAS_CON_STOCK(prod, orden) -> lista de oficinas con stock
--                                       disponible, para aviso UX
--
-- Reglas (Plan §4 F3, decisiones PO §3):
--   - LOV de producto NO se filtra por oficina (catalogo completo)
--   - Vendedor nunca ve cantidades, solo si hay/no hay
--   - Reservas VIGENTE se descuentan de la disponibilidad
--   - Vendedor sin caja abierta -> FN_OFICINA_USUARIO devuelve NULL
--     (la UI debe bloquear el alta de presupuesto en ese caso)
--
-- Las funciones se invocan desde la UI mediante DA AJAX + validacion
-- server-side - ver checklist §7 para los pendientes UI manuales.
--
-- Idempotente. CREATE OR REPLACE es no-op si el body es identico.
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
whenever sqlerror exit sql.sqlcode rollback

prompt == F3.1 FN_OFICINA_USUARIO ==
-- Resuelve la oficina del usuario logueado via su caja abierta.
-- Si tiene mas de una caja abierta (no deberia), devuelve la mayor id.
-- Si no tiene caja abierta, devuelve NULL.
-- Default del parametro: V('APP_USER') (NO NV - APP_USER es VARCHAR2).
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_OFICINA_USUARIO (
  p_usuario IN VARCHAR2 DEFAULT V('APP_USER')
) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT MAX(c.ID_OFICINA)
    INTO v_id
    FROM WKSP_WORKPLACE.CAJAS c
   WHERE UPPER(c.USU_APERTURA) = UPPER(p_usuario)
     AND c.ESTADO = 'A';
  RETURN v_id;
END;
/

prompt == F3.2 FN_HAY_STOCK ==
-- Devuelve 'S' si el producto tiene cantidad disponible en la oficina
-- (descontando reservas VIGENTE, excluyendo la propia orden si se pasa
-- p_id_orden - permite editar una orden sin verse a si misma como
-- consumiendo stock).
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_HAY_STOCK (
  p_id_producto IN NUMBER,
  p_id_oficina  IN NUMBER,
  p_id_orden    IN NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS
  v_disp NUMBER;
BEGIN
  SELECT NVL(sp.CANTIDAD,0)
       - NVL((SELECT SUM(rp.CANTIDAD_RESERVADA)
                FROM WKSP_WORKPLACE.RESERVAS_PRODUCTO rp
               WHERE rp.ID_PRODUCTO   = p_id_producto
                 AND rp.ID_OFICINA    = p_id_oficina
                 AND rp.ESTADO        = 'VIGENTE'
                 AND (p_id_orden IS NULL
                      OR rp.ID_ORDEN_VENTA <> p_id_orden)), 0)
    INTO v_disp
    FROM WKSP_WORKPLACE.STOCK_PRODUCTO sp
   WHERE sp.ID_PRODUCTO = p_id_producto
     AND sp.ID_OFICINA  = p_id_oficina;
  RETURN CASE WHEN v_disp > 0 THEN 'S' ELSE 'N' END;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN 'N';
END;
/

prompt == F3.3 FN_OFICINAS_CON_STOCK ==
-- Devuelve lista CSV de oficinas (descripcion) que tienen el producto
-- disponible. Para usarse en el mensaje "Sin disponibilidad en tu
-- oficina. Hay stock en: <lista>".
-- Devuelve NULL si nadie tiene stock disponible.
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_OFICINAS_CON_STOCK (
  p_id_producto IN NUMBER,
  p_id_orden    IN NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS
  v_lista VARCHAR2(4000);
BEGIN
  SELECT LISTAGG(o.DESCRIPCION, ', ') WITHIN GROUP (ORDER BY o.DESCRIPCION)
    INTO v_lista
    FROM WKSP_WORKPLACE.STOCK_PRODUCTO sp
    JOIN WKSP_WORKPLACE.OFICINAS      o ON o.CODIGO_OFICINA = sp.ID_OFICINA
   WHERE sp.ID_PRODUCTO = p_id_producto
     AND sp.CANTIDAD
       - NVL((SELECT SUM(rp.CANTIDAD_RESERVADA)
                FROM WKSP_WORKPLACE.RESERVAS_PRODUCTO rp
               WHERE rp.ID_PRODUCTO   = sp.ID_PRODUCTO
                 AND rp.ID_OFICINA    = sp.ID_OFICINA
                 AND rp.ESTADO        = 'VIGENTE'
                 AND (p_id_orden IS NULL
                      OR rp.ID_ORDEN_VENTA <> p_id_orden)), 0) > 0;
  RETURN v_lista;
END;
/

prompt == F3.4 Verificacion ==
DECLARE
  v_ok BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
  v_disp VARCHAR2(1);
  v_lista VARCHAR2(4000);
  PROCEDURE chk(p_label VARCHAR2, p_ok BOOLEAN) IS
  BEGIN
    IF p_ok THEN DBMS_OUTPUT.PUT_LINE('  OK   '||p_label);
    ELSE         DBMS_OUTPUT.PUT_LINE('  FAIL '||p_label); v_ok := FALSE;
    END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE'
     AND object_name IN ('FN_OFICINA_USUARIO','FN_HAY_STOCK','FN_OFICINAS_CON_STOCK')
     AND object_type='FUNCTION' AND status='VALID';
  chk('3 funciones F3 VALID', v_cnt=3);

  -- Test FN_HAY_STOCK: producto 1 en oficina 1 tiene CANTIDAD=15
  v_disp := WKSP_WORKPLACE.FN_HAY_STOCK(1, 1);
  chk('FN_HAY_STOCK(prod=1, ofic=1) = S (esperado S, devolvio '||v_disp||')', v_disp='S');

  -- Test FN_HAY_STOCK: producto inexistente
  v_disp := WKSP_WORKPLACE.FN_HAY_STOCK(99999, 1);
  chk('FN_HAY_STOCK(prod=99999) = N (esperado N, devolvio '||v_disp||')', v_disp='N');

  -- Test FN_OFICINAS_CON_STOCK: producto 1 (tiene stock en multiples)
  v_lista := WKSP_WORKPLACE.FN_OFICINAS_CON_STOCK(1);
  chk('FN_OFICINAS_CON_STOCK(prod=1) no vacia -> "'||v_lista||'"', v_lista IS NOT NULL);

  -- FN_OFICINA_USUARIO no se testea con APP_USER (no hay sesion APEX),
  -- pero si con un usuario sin caja abierta para confirmar devuelve NULL
  DECLARE v_id NUMBER;
  BEGIN
    v_id := WKSP_WORKPLACE.FN_OFICINA_USUARIO('USUARIO_INEXISTENTE_XYZ');
    chk('FN_OFICINA_USUARIO(usuario inexistente) IS NULL', v_id IS NULL);
  END;

  IF v_ok THEN
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'F3 OK - todos los checks pasaron');
  ELSE
    DBMS_OUTPUT.PUT_LINE(CHR(10)||'F3 FAIL - revisar arriba');
  END IF;
END;
/

prompt == F3 backend aplicado ==

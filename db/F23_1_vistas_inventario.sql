-- ============================================================================
-- F23_1_vistas_inventario.sql  (H2 — Reportes Gerenciales de Inventario)
-- ----------------------------------------------------------------------------
-- Capa de vistas = UNICO source of truth compartido por el dashboard (P142) y el
-- informe imprimible (P143). Idempotente (CREATE OR REPLACE FORCE VIEW).
--
-- Reglas de oro (ver PLAN_REPORTES_INVENTARIO.md seccion 1.2):
--   * STOCK_PRODUCTO.CANTIDAD es el on-hand autoritativo (el kardex NO reconcilia
--     la apertura -> no sumar movimientos desde cero).
--   * Stock/valorizacion/niveles = SNAPSHOT a-hoy; el tiempo solo vive en
--     MOVIMIENTOS_STOCK (flujo/rotacion).
--   * TIPO_MOVIMIENTO viene con mayuscula mixta ('ENTRADA'/'Entrada') -> UPPER().
--   * Costo = COALESCE(FN_COSTO_PONDERADO(prod, ventana amplia),
--             ultimo precio ACTIVO de PRODUCTO_PROVEEDORES). Si ambos NULL ->
--             '(sin costo)' y se excluye del total valorizado.
--   * disponible = CANTIDAD - Σ RESERVAS_PRODUCTO (ESTADO='VIGENTE').
--   * Fechas de negocio con FN_HOY (BD en UTC), nunca SYSDATE.
--
-- Ventana de costo: 3650 dias (10 anios) -> captura todas las compras del dataset
-- para el promedio ponderado; el precio de proveedor es el fallback.
-- ============================================================================
SET DEFINE OFF

-- ----------------------------------------------------------------------------
-- V_INV_STOCK : grano producto x oficina (SNAPSHOT a-hoy)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_INV_STOCK AS
SELECT
    sp.ID_PRODUCTO,
    p.NOMBRE                                   AS PRODUCTO,
    p.ID_CATEGORIA,
    NVL(c.NOMBRE, '(sin categoria)')           AS CATEGORIA,
    p.ID_MARCA,
    m.NOMBRE                                   AS MARCA,
    sp.ID_OFICINA,
    o.DESCRIPCION                              AS OFICINA,
    sp.CANTIDAD,
    sp.STOCK_MINIMO,
    sp.STOCK_MAXIMO,
    NVL(r.RESERVADO, 0)                        AS RESERVADO,
    sp.CANTIDAD - NVL(r.RESERVADO, 0)          AS DISPONIBLE,
    cst.COSTO_UNITARIO,
    CASE
        WHEN cst.COSTO_UNITARIO IS NULL THEN NULL
        ELSE sp.CANTIDAD * cst.COSTO_UNITARIO
    END                                        AS VALOR_STOCK,
    cst.COSTO_ORIGEN,
    CASE
        WHEN sp.CANTIDAD = 0                                            THEN 'QUIEBRE'
        WHEN sp.STOCK_MINIMO IS NULL OR sp.STOCK_MAXIMO IS NULL         THEN 'SIN_DEFINIR'
        WHEN sp.CANTIDAD < sp.STOCK_MINIMO                              THEN 'BAJO_MINIMO'
        WHEN sp.CANTIDAD > sp.STOCK_MAXIMO                              THEN 'SOBRE_MAXIMO'
        ELSE 'OK'
    END                                        AS ESTADO_NIVEL
FROM WKSP_WORKPLACE.STOCK_PRODUCTO sp
JOIN WKSP_WORKPLACE.PRODUCTOS p            ON p.ID_PRODUCTO = sp.ID_PRODUCTO
LEFT JOIN WKSP_WORKPLACE.CATEGORIAS_PRODUCTOS c ON c.ID_CATEGORIA = p.ID_CATEGORIA
LEFT JOIN WKSP_WORKPLACE.MARCAS m         ON m.ID_MARCA = p.ID_MARCA
LEFT JOIN WKSP_WORKPLACE.OFICINAS o       ON o.CODIGO_OFICINA = sp.ID_OFICINA
LEFT JOIN (
    SELECT ID_PRODUCTO, ID_OFICINA, SUM(CANTIDAD_RESERVADA) AS RESERVADO
    FROM WKSP_WORKPLACE.RESERVAS_PRODUCTO
    WHERE ESTADO = 'VIGENTE'
    GROUP BY ID_PRODUCTO, ID_OFICINA
) r ON r.ID_PRODUCTO = sp.ID_PRODUCTO AND r.ID_OFICINA = sp.ID_OFICINA
CROSS APPLY (
    SELECT
        COALESCE(
            WKSP_WORKPLACE.FN_COSTO_PONDERADO(sp.ID_PRODUCTO, 3650),
            (SELECT MAX(pp.PRECIO)
               FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp
              WHERE pp.ID_PRODUCTO = sp.ID_PRODUCTO
                AND pp.ESTADO = 'ACTIVO' AND pp.FECHA_FIN IS NULL)
        ) AS COSTO_UNITARIO,
        CASE
            WHEN WKSP_WORKPLACE.FN_COSTO_PONDERADO(sp.ID_PRODUCTO, 3650) IS NOT NULL THEN 'PONDERADO'
            WHEN (SELECT MAX(pp.PRECIO) FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp
                   WHERE pp.ID_PRODUCTO = sp.ID_PRODUCTO
                     AND pp.ESTADO = 'ACTIVO' AND pp.FECHA_FIN IS NULL) IS NOT NULL THEN 'PRECIO_PROV'
            ELSE 'SIN_COSTO'
        END AS COSTO_ORIGEN
) cst;

-- ----------------------------------------------------------------------------
-- V_INV_MOV : grano movimiento (kardex normalizado; dimension TIEMPO)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_INV_MOV AS
SELECT
    ms.ID_MOVIMIENTO,
    ms.ID_PRODUCTO,
    p.NOMBRE                                   AS PRODUCTO,
    p.ID_CATEGORIA,
    NVL(c.NOMBRE, '(sin categoria)')           AS CATEGORIA,
    ms.ID_OFICINA,
    o.DESCRIPCION                              AS OFICINA,
    UPPER(ms.TIPO_MOVIMIENTO)                  AS TIPO_MOVIMIENTO,
    ms.CANTIDAD,
    CASE UPPER(ms.TIPO_MOVIMIENTO)
        WHEN 'ENTRADA' THEN  ms.CANTIDAD
        WHEN 'SALIDA'  THEN -ms.CANTIDAD
        ELSE ms.CANTIDAD                       -- AJUSTE: valor tal cual
    END                                        AS SIGNO_CANTIDAD,
    ms.FECHA_MOVIMIENTO,
    TRUNC(ms.FECHA_MOVIMIENTO, 'MM')           AS PERIODO,
    ms.USUARIO,
    ms.REFERENCIA,
    CASE
        WHEN UPPER(ms.REFERENCIA) LIKE 'VENTA%'         THEN 'VENTA'
        WHEN UPPER(ms.REFERENCIA) LIKE 'NOTA_CREDITO%'  THEN 'NOTA_CREDITO'
        WHEN UPPER(ms.REFERENCIA) LIKE 'ANULACION%'     THEN 'ANULACION'
        WHEN UPPER(ms.REFERENCIA) LIKE 'COMPRA%'        THEN 'COMPRA'
        WHEN UPPER(ms.REFERENCIA) LIKE 'RECEPCION%'     THEN 'RECEPCION'
        WHEN UPPER(ms.TIPO_MOVIMIENTO) = 'AJUSTE'       THEN 'AJUSTE'
        ELSE 'OTRO'
    END                                        AS CLASE_REF
FROM WKSP_WORKPLACE.MOVIMIENTOS_STOCK ms
JOIN WKSP_WORKPLACE.PRODUCTOS p            ON p.ID_PRODUCTO = ms.ID_PRODUCTO
LEFT JOIN WKSP_WORKPLACE.CATEGORIAS_PRODUCTOS c ON c.ID_CATEGORIA = p.ID_CATEGORIA
LEFT JOIN WKSP_WORKPLACE.OFICINAS o        ON o.CODIGO_OFICINA = ms.ID_OFICINA;

-- ----------------------------------------------------------------------------
-- V_INV_FLUJO_MES : entradas vs salidas por periodo x oficina
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_INV_FLUJO_MES AS
SELECT
    PERIODO,
    ID_OFICINA,
    OFICINA,
    SUM(CASE WHEN TIPO_MOVIMIENTO = 'ENTRADA' THEN CANTIDAD ELSE 0 END) AS ENTRADAS,
    SUM(CASE WHEN TIPO_MOVIMIENTO = 'SALIDA'  THEN CANTIDAD ELSE 0 END) AS SALIDAS,
    SUM(CASE WHEN TIPO_MOVIMIENTO = 'AJUSTE'  THEN CANTIDAD ELSE 0 END) AS AJUSTES,
    SUM(SIGNO_CANTIDAD)                                                 AS NETO
FROM WKSP_WORKPLACE.V_INV_MOV
GROUP BY PERIODO, ID_OFICINA, OFICINA;

-- ----------------------------------------------------------------------------
-- V_INV_ROTACION : rotacion / obsolescencia por producto (proxy con stock actual)
--   INDICE_ROTACION = salidas por venta / stock actual (documentado como proxy;
--   no hay historia de stock -> se usa el on-hand como aprox. del promedio).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_INV_ROTACION AS
WITH sal AS (
    SELECT ID_PRODUCTO,
           SUM(CANTIDAD)           AS SALIDAS_VENTA,
           MAX(FECHA_MOVIMIENTO)   AS ULTIMA_SALIDA
    FROM WKSP_WORKPLACE.V_INV_MOV
    WHERE TIPO_MOVIMIENTO = 'SALIDA' AND CLASE_REF = 'VENTA'
    GROUP BY ID_PRODUCTO
),
mov AS (
    SELECT ID_PRODUCTO, MAX(FECHA_MOVIMIENTO) AS ULTIMO_MOV
    FROM WKSP_WORKPLACE.V_INV_MOV
    GROUP BY ID_PRODUCTO
),
stk AS (
    SELECT ID_PRODUCTO, SUM(CANTIDAD) AS STOCK_ACTUAL
    FROM WKSP_WORKPLACE.STOCK_PRODUCTO
    GROUP BY ID_PRODUCTO
)
SELECT
    p.ID_PRODUCTO,
    p.NOMBRE                                   AS PRODUCTO,
    NVL(c.NOMBRE, '(sin categoria)')           AS CATEGORIA,
    NVL(stk.STOCK_ACTUAL, 0)                   AS STOCK_ACTUAL,
    NVL(sal.SALIDAS_VENTA, 0)                  AS SALIDAS_VENTA,
    ROUND(NVL(sal.SALIDAS_VENTA, 0) / NULLIF(stk.STOCK_ACTUAL, 0), 2) AS INDICE_ROTACION,
    mov.ULTIMO_MOV,
    CASE WHEN mov.ULTIMO_MOV IS NOT NULL
         THEN TRUNC(WKSP_WORKPLACE.FN_HOY) - TRUNC(mov.ULTIMO_MOV) END AS DIAS_SIN_MOV,
    CASE
        WHEN NVL(sal.SALIDAS_VENTA, 0) = 0 THEN 'SIN_MOVIMIENTO'
        WHEN NVL(sal.SALIDAS_VENTA, 0) / NULLIF(stk.STOCK_ACTUAL, 0) >= 1 THEN 'RAPIDO'
        ELSE 'LENTO'
    END                                        AS CLASE_ROTACION
FROM WKSP_WORKPLACE.PRODUCTOS p
LEFT JOIN WKSP_WORKPLACE.CATEGORIAS_PRODUCTOS c ON c.ID_CATEGORIA = p.ID_CATEGORIA
LEFT JOIN stk ON stk.ID_PRODUCTO = p.ID_PRODUCTO
LEFT JOIN sal ON sal.ID_PRODUCTO = p.ID_PRODUCTO
LEFT JOIN mov ON mov.ID_PRODUCTO = p.ID_PRODUCTO
WHERE p.ACTIVO = 'S';

-- ----------------------------------------------------------------------------
-- V_INV_CONTEO_DIF : diferencias de inventario fisico (conteos)
--   DIFERENCIA = CANTIDAD_FISICA - STOCK_SISTEMA (verificado en datos).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FORCE VIEW WKSP_WORKPLACE.V_INV_CONTEO_DIF AS
SELECT
    i.ID_INVENTARIO,
    i.NRO_DOCUMENTO,
    i.ESTADO                                   AS ESTADO_DOC,
    i.ID_OFICINA,
    o.DESCRIPCION                              AS OFICINA,
    i.FECHA_INVENTARIO,
    idt.ID_PRODUCTO,
    pr.NOMBRE                                  AS PRODUCTO,
    NVL(c.NOMBRE, '(sin categoria)')           AS CATEGORIA,
    idt.STOCK_SISTEMA,
    idt.CANTIDAD_FISICA,
    idt.DIFERENCIA,
    ABS(idt.DIFERENCIA)                        AS DIF_ABS,
    -- Coincidencia acotada 0..100 (min/max) — robusta ante conteos muy dispares
    CASE
        WHEN idt.DIFERENCIA = 0 THEN 100
        WHEN NVL(idt.STOCK_SISTEMA,0) = 0 OR NVL(idt.CANTIDAD_FISICA,0) = 0 THEN 0
        ELSE ROUND( LEAST(idt.STOCK_SISTEMA, idt.CANTIDAD_FISICA)
                    / GREATEST(idt.STOCK_SISTEMA, idt.CANTIDAD_FISICA) * 100, 1)
    END                                        AS EXACTITUD_PCT
FROM WKSP_WORKPLACE.INVENTARIO_DETALLE idt
JOIN WKSP_WORKPLACE.INVENTARIO i           ON i.ID_INVENTARIO = idt.ID_INVENTARIO
LEFT JOIN WKSP_WORKPLACE.OFICINAS o        ON o.CODIGO_OFICINA = i.ID_OFICINA
LEFT JOIN WKSP_WORKPLACE.PRODUCTOS pr      ON pr.ID_PRODUCTO = idt.ID_PRODUCTO
LEFT JOIN WKSP_WORKPLACE.CATEGORIAS_PRODUCTOS c ON c.ID_CATEGORIA = pr.ID_CATEGORIA;

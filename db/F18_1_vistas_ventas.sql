-- ============================================================================
-- F18.1 - Vistas de apoyo para el Dashboard/Informe de Ventas (H2)
-- ============================================================================
-- Capa de vistas que es el UNICO source of truth de la cifra de ventas, para
-- que el Dashboard interactivo (P133) y el Informe imprimible (P134) muestren
-- exactamente los mismos numeros. Implementa la "REGLA DE ORO" del plan:
--   ventas/meta cuentan SOLO lo facturado, atribuido por la FACTURA
--   (COMPROBANTES.ID_ORDEN_VENTA), nunca por ORDENES_VENTA.ESTADO.
--
-- Vistas (todas en WKSP_WORKPLACE):
--   V_VENTAS_FACTURA       grano factura (FA activas) -> facturacion/mes, por
--                          sucursal, contado/credito, por vendedor (bruto),
--                          top clientes, KPIs.
--   V_VENTAS_NC            grano NC (activas), atribuida a la dimension de la
--                          FACTURA ORIGEN (periodo/oficina/vendedor), porque las
--                          NC NO tienen ID_ORDEN_VENTA (dos saltos via
--                          ID_COMPROBANTE_ORIGEN).
--   V_VENTAS_NETA_MES      periodo x oficina x vendedor -> neto = FA - NC.
--   V_VENTAS_VENDEDOR_META neto por vendedor/periodo vs. METAS_VENTA (empleado),
--                          con cumplimiento %.
--   V_VENTAS_LINEA         grano factura x producto (FA activas) -> top productos.
--
-- Convenciones (verificadas tesis_db 2026-06-26): COMPROBANTES.ESTADO 'A'/'N';
-- TIPO_COMPROBANTE 'FA'/'NC'; FORMA_PAGO '21'=contado, '1'=credito; todo PYG
-- (TOTAL_MONEDA_LOCAL). Vendedor = ORDENES_VENTA.USUARIO_CREACION, join a
-- EMPLEADOS por CODIGO_USUARIO.
--
-- Idempotente (CREATE OR REPLACE VIEW). Solo lectura: no modifica datos.
-- Pre-requisito: F18 (USUARIO_CREACION + METAS_VENTA) aplicado.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F18_1_vistas_ventas.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F18.1.1 V_VENTAS_FACTURA (grano factura, FA activas) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_VENTAS_FACTURA AS
SELECT
  c.id_comprobante,
  c.nro_comprobante,
  c.fecha,
  TRUNC(c.fecha, 'MM')                          AS periodo,
  c.id_oficina,
  o.descripcion                                 AS oficina,
  c.id_orden_venta,
  NVL(ov.usuario_creacion, '(sin asignar)')     AS vendedor_cod,
  NVL(e.nombre, '(sin asignar)')                AS vendedor_nombre,
  c.id_cliente,
  TRIM(p.primer_nombre || ' ' || p.primer_apellido) AS cliente,
  c.forma_pago,
  CASE WHEN c.forma_pago = '21' THEN 'CONTADO' ELSE 'CREDITO' END AS condicion,
  CASE WHEN c.forma_pago = '21' THEN 'S' ELSE 'N' END            AS es_contado,
  c.total_moneda_local                          AS total
FROM WKSP_WORKPLACE.COMPROBANTES c
LEFT JOIN WKSP_WORKPLACE.ORDENES_VENTA ov ON ov.id_orden      = c.id_orden_venta
LEFT JOIN WKSP_WORKPLACE.EMPLEADOS     e  ON e.codigo_usuario = ov.usuario_creacion
LEFT JOIN WKSP_WORKPLACE.OFICINAS      o  ON o.codigo_oficina = c.id_oficina
LEFT JOIN WKSP_WORKPLACE.PERSONAS      p  ON p.id_persona     = c.id_cliente
WHERE c.tipo_comprobante = 'FA' AND c.estado = 'A';

prompt == F18.1.2 V_VENTAS_NC (grano NC, atribuida a la factura origen) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_VENTAS_NC AS
SELECT
  nc.id_comprobante,
  nc.nro_comprobante,
  nc.fecha                                      AS fecha_nc,
  nc.id_comprobante_origen,
  TRUNC(fo.fecha, 'MM')                         AS periodo,      -- periodo de la FACTURA origen
  fo.id_oficina,
  o.descripcion                                 AS oficina,
  NVL(ov.usuario_creacion, '(sin asignar)')     AS vendedor_cod,
  NVL(e.nombre, '(sin asignar)')                AS vendedor_nombre,
  nc.total_moneda_local                         AS total_nc
FROM WKSP_WORKPLACE.COMPROBANTES nc
JOIN WKSP_WORKPLACE.COMPROBANTES   fo ON fo.id_comprobante = nc.id_comprobante_origen
LEFT JOIN WKSP_WORKPLACE.ORDENES_VENTA ov ON ov.id_orden      = fo.id_orden_venta
LEFT JOIN WKSP_WORKPLACE.EMPLEADOS     e  ON e.codigo_usuario = ov.usuario_creacion
LEFT JOIN WKSP_WORKPLACE.OFICINAS      o  ON o.codigo_oficina = fo.id_oficina
WHERE nc.tipo_comprobante = 'NC' AND nc.estado = 'A';

prompt == F18.1.3 V_VENTAS_NETA_MES (periodo x oficina x vendedor, neto FA-NC) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_VENTAS_NETA_MES AS
SELECT
  periodo, id_oficina, oficina, vendedor_cod, vendedor_nombre,
  SUM(monto_fa)                 AS facturado,
  SUM(monto_nc)                 AS notas_credito,
  SUM(monto_fa) - SUM(monto_nc) AS neto,
  SUM(cant_fa)                  AS facturas
FROM (
  SELECT periodo, id_oficina, oficina, vendedor_cod, vendedor_nombre,
         total AS monto_fa, 0 AS monto_nc, 1 AS cant_fa
  FROM WKSP_WORKPLACE.V_VENTAS_FACTURA
  UNION ALL
  SELECT periodo, id_oficina, oficina, vendedor_cod, vendedor_nombre,
         0 AS monto_fa, total_nc AS monto_nc, 0 AS cant_fa
  FROM WKSP_WORKPLACE.V_VENTAS_NC
)
GROUP BY periodo, id_oficina, oficina, vendedor_cod, vendedor_nombre;

prompt == F18.1.4 V_VENTAS_VENDEDOR_META (neto vs. meta de empleado) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_VENTAS_VENDEDOR_META AS
SELECT
  v.periodo,
  v.vendedor_cod,
  v.vendedor_nombre,
  e.id_empleado,
  v.neto,
  m.monto_meta,
  CASE WHEN m.monto_meta > 0
       THEN ROUND(v.neto / m.monto_meta * 100, 1) END AS cumplimiento_pct
FROM (
  SELECT periodo, vendedor_cod, vendedor_nombre, SUM(neto) AS neto
  FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES
  GROUP BY periodo, vendedor_cod, vendedor_nombre
) v
LEFT JOIN WKSP_WORKPLACE.EMPLEADOS   e ON e.codigo_usuario = v.vendedor_cod
LEFT JOIN WKSP_WORKPLACE.METAS_VENTA m ON m.id_empleado    = e.id_empleado
                                       AND m.periodo        = v.periodo;

prompt == F18.1.5 V_VENTAS_LINEA (grano factura x producto, FA activas) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_VENTAS_LINEA AS
SELECT
  c.id_comprobante, c.fecha, c.periodo, c.id_oficina, c.oficina,
  c.vendedor_cod, c.vendedor_nombre, c.condicion, c.es_contado,
  d.id_producto,
  NVL(pr.nombre, pr.descripcion) AS producto,
  d.cantidad,
  d.total_linea
FROM WKSP_WORKPLACE.V_VENTAS_FACTURA c
JOIN WKSP_WORKPLACE.DETALLE_COMPROBANTE d ON d.id_comprobante = c.id_comprobante
LEFT JOIN WKSP_WORKPLACE.PRODUCTOS pr     ON pr.id_producto    = d.id_producto;

prompt == F18.1.6 Verificacion (contra datos reales) ==
DECLARE
  v_fa_cnt   PLS_INTEGER; v_fa_tot   NUMBER;
  v_nc_cnt   PLS_INTEGER; v_nc_tot   NUMBER;
  v_neto     NUMBER;      v_lin_cnt  PLS_INTEGER;
  v_ok BOOLEAN := TRUE;
BEGIN
  SELECT COUNT(*), NVL(SUM(total),0) INTO v_fa_cnt, v_fa_tot
    FROM WKSP_WORKPLACE.V_VENTAS_FACTURA;
  SELECT COUNT(*), NVL(SUM(total_nc),0) INTO v_nc_cnt, v_nc_tot
    FROM WKSP_WORKPLACE.V_VENTAS_NC;
  SELECT NVL(SUM(neto),0) INTO v_neto FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES;
  SELECT COUNT(*) INTO v_lin_cnt FROM WKSP_WORKPLACE.V_VENTAS_LINEA;

  DBMS_OUTPUT.PUT_LINE('  V_VENTAS_FACTURA : '||v_fa_cnt||' facturas, total '||v_fa_tot);
  DBMS_OUTPUT.PUT_LINE('  V_VENTAS_NC      : '||v_nc_cnt||' NC, total '||v_nc_tot);
  DBMS_OUTPUT.PUT_LINE('  V_VENTAS_NETA_MES: neto '||v_neto||' (= FA-NC)');
  DBMS_OUTPUT.PUT_LINE('  V_VENTAS_LINEA   : '||v_lin_cnt||' lineas');

  -- chequeo de consistencia: neto agregado == FA - NC
  IF v_neto != (v_fa_tot - v_nc_tot) THEN
    DBMS_OUTPUT.PUT_LINE('  FAIL neto != FA-NC'); v_ok := FALSE;
  END IF;
  -- no debe haber facturas sin atribuir (todas las FA tienen orden->vendedor)
  SELECT COUNT(*) INTO v_fa_cnt FROM WKSP_WORKPLACE.V_VENTAS_FACTURA
   WHERE vendedor_cod = '(sin asignar)';
  IF v_fa_cnt > 0 THEN
    DBMS_OUTPUT.PUT_LINE('  WARN '||v_fa_cnt||' facturas sin vendedor (revisar)');
  END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F18.1 vistas OK.');
  ELSE RAISE_APPLICATION_ERROR(-20997,'F18.1 verificacion FAIL.'); END IF;
END;
/

prompt == F18.1 - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

-- ============================================================================
-- F22.1 - Vistas de apoyo para el Dashboard/Informe de Cobros (H2)
-- ============================================================================
-- Capa de vistas que es el UNICO source of truth de la cifra de cobranza, para
-- que el Dashboard interactivo (P136) y el Informe imprimible (P137) muestren
-- exactamente los mismos numeros. Implementa la "REGLA DE ORO" del plan:
--   cobranza_neta = Sum(COBRO_CXC validos) - Sum(EGRESO de reverso)
-- atribuyendo cada reverso al cobro ORIGINAL (periodo/oficina/cobrador).
--
-- GOTCHA CRITICO (verificado tesis_db 2026-06-29): MOVIMIENTOS_CAJA.ESTADO NO es
-- activo/anulado -> es abierta/cerrada de CAJA. 'A' = caja abierta, 'C' = caja
-- cerrada (al cerrar la caja en F17 los movimientos pasan de 'A' a 'C'). AMBOS
-- son dinero valido. Filtrar SIEMPRE ESTADO IN ('A','C'), nunca solo '='C''
-- (eso borraria la cobranza de cajas abiertas). El reverso NO marca el
-- movimiento: lo compensa un EGRESO contrapartida (ID_MOVIMIENTO_REVERSADO).
--
-- Vistas (todas en WKSP_WORKPLACE):
--   V_COBROS_MOV          grano movimiento (COBRO_CXC validos) enriquecido con
--                         oficina/cobrador/cliente/periodo -> recaudacion bruta,
--                         por mes/oficina/cliente, KPIs, detalle de recibos.
--   V_COBROS_REVERSO      EGRESO de reverso (ID_MOVIMIENTO_REVERSADO not null)
--                         atribuido a la dimension del COBRO ORIGINAL, para
--                         restarlo por periodo/oficina/cobrador.
--   V_COBROS_NETO_MES     periodo x oficina x cobrador -> neto = bruto - reverso.
--   V_COBROS_MEDIO        grano detalle de COBRO x medio de pago (efectivo/POS/
--                         transferencia/QR) -> donut "medios de cobro" (BRUTO:
--                         como pagan los clientes; el reverso solo afecta el neto
--                         de cabecera, no se descuenta por medio).
--   V_CARTERA_CXC         cuotas no pagadas (PENDIENTE/VENCIDA) con aging por
--                         FECHA_VENCIMIENTO vs FN_HOY -> antiguedad, top deudores.
--   V_COBROS_OFICINA_META neto por oficina/periodo vs METAS_COBRANZA, cumpl. %.
--
-- Convenciones: cobrador = MOVIMIENTOS_CAJA.USUARIO (join a EMPLEADOS por
-- CODIGO_USUARIO); cliente = PERSONAS por ID_CLIENTE; oficina del cobro via
-- CAJAS.ID_OFICINA -> OFICINAS.CODIGO_OFICINA; oficina de la cartera via la
-- factura origen (COMPROBANTES.ID_OFICINA). Fecha de negocio con FN_HOY (BD en
-- UTC; MOVIMIENTOS_CAJA.FECHA se guarda en hora local post-fix F20). Todo PYG.
--
-- Idempotente (CREATE OR REPLACE VIEW). Solo lectura: no modifica datos.
-- Pre-requisito: F22 (METAS_COBRANZA) aplicado.
--
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F22_1_vistas_cobros.sql
-- ============================================================================

ALTER SESSION SET CURRENT_SCHEMA = WKSP_WORKPLACE;

set serveroutput on size unlimited
set define off
whenever sqlerror exit sql.sqlcode rollback

prompt == F22.1.1 V_COBROS_MOV (grano movimiento, COBRO_CXC validos) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_COBROS_MOV AS
SELECT
  mc.id_movimiento,
  mc.nro_recibo,
  mc.fecha,
  TRUNC(mc.fecha, 'MM')                                AS periodo,
  c.id_oficina,
  o.descripcion                                        AS oficina,
  mc.usuario                                           AS cobrador_cod,
  NVL(e.nombre, mc.usuario)                            AS cobrador_nombre,
  mc.id_cliente,
  REGEXP_REPLACE(TRIM(p.primer_nombre||' '||p.segundo_nombre||' '||
                      p.primer_apellido||' '||p.segundo_apellido), ' +', ' ') AS cliente,
  mc.id_cuenta_cobrar_det,
  mc.total_moneda_local                                AS total
FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA mc
JOIN      WKSP_WORKPLACE.CAJAS     c ON c.id_caja        = mc.id_caja
LEFT JOIN WKSP_WORKPLACE.OFICINAS  o ON o.codigo_oficina = c.id_oficina
LEFT JOIN WKSP_WORKPLACE.EMPLEADOS e ON e.codigo_usuario = mc.usuario
LEFT JOIN WKSP_WORKPLACE.PERSONAS  p ON p.id_persona     = mc.id_cliente
WHERE mc.tipo = 'COBRO_CXC' AND mc.estado IN ('A','C');

prompt == F22.1.2 V_COBROS_REVERSO (EGRESO de reverso, atribuido al cobro origen) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_COBROS_REVERSO AS
SELECT
  eg.id_movimiento                                     AS id_egreso,
  mo.id_movimiento                                     AS id_cobro,
  mo.nro_recibo,
  mo.fecha,                                                          -- fecha del COBRO original (para filtrar por rango)
  TRUNC(mo.fecha, 'MM')                                AS periodo,   -- periodo del COBRO original
  c.id_oficina,
  o.descripcion                                        AS oficina,
  mo.usuario                                           AS cobrador_cod,
  NVL(e.nombre, mo.usuario)                            AS cobrador_nombre,
  eg.total_moneda_local                                AS total_reverso
FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA eg
JOIN      WKSP_WORKPLACE.MOVIMIENTOS_CAJA mo ON mo.id_movimiento  = eg.id_movimiento_reversado
JOIN      WKSP_WORKPLACE.CAJAS     c ON c.id_caja        = mo.id_caja
LEFT JOIN WKSP_WORKPLACE.OFICINAS  o ON o.codigo_oficina = c.id_oficina
LEFT JOIN WKSP_WORKPLACE.EMPLEADOS e ON e.codigo_usuario = mo.usuario
WHERE eg.tipo = 'EGRESO' AND eg.estado IN ('A','C')
  AND eg.id_movimiento_reversado IS NOT NULL;

prompt == F22.1.3 V_COBROS_NETO_MES (periodo x oficina x cobrador, neto bruto-reverso) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_COBROS_NETO_MES AS
SELECT
  periodo, id_oficina, oficina, cobrador_cod, cobrador_nombre,
  SUM(monto_cobro)                  AS bruto,
  SUM(monto_rev)                    AS reversos,
  SUM(monto_cobro) - SUM(monto_rev) AS neto,
  SUM(cant_cobro)                   AS recibos
FROM (
  SELECT periodo, id_oficina, oficina, cobrador_cod, cobrador_nombre,
         total AS monto_cobro, 0 AS monto_rev, 1 AS cant_cobro
  FROM WKSP_WORKPLACE.V_COBROS_MOV
  UNION ALL
  SELECT periodo, id_oficina, oficina, cobrador_cod, cobrador_nombre,
         0 AS monto_cobro, total_reverso AS monto_rev, 0 AS cant_cobro
  FROM WKSP_WORKPLACE.V_COBROS_REVERSO
)
GROUP BY periodo, id_oficina, oficina, cobrador_cod, cobrador_nombre;

prompt == F22.1.4 V_COBROS_MEDIO (grano detalle COBRO x medio de pago, BRUTO) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_COBROS_MEDIO AS
SELECT
  m.fecha,
  m.periodo,
  m.id_oficina,
  m.oficina,
  m.cobrador_cod,
  d.id_metodo_pago                  AS metodo_cod,
  NVL(mp.descripcion, '(sin medio)') AS metodo,
  d.monto_local                     AS monto
FROM WKSP_WORKPLACE.V_COBROS_MOV m
JOIN      WKSP_WORKPLACE.DETALLE_MOVIMIENTO_CAJA d ON d.id_movimiento  = m.id_movimiento
LEFT JOIN WKSP_WORKPLACE.METODOS_PAGO            mp ON mp.id_metodo_pago = d.id_metodo_pago;

prompt == F22.1.5 V_CARTERA_CXC (cuotas no pagadas con aging) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_CARTERA_CXC AS
SELECT
  ccd.id_detalle,
  ccd.id_cxc,
  ccd.nro_cuota,
  ccd.fecha_vencimiento,
  ccd.monto_cuota,
  ccd.estado                                           AS estado_cuota,
  cxc.id_persona,
  REGEXP_REPLACE(TRIM(p.primer_nombre||' '||p.segundo_nombre||' '||
                      p.primer_apellido||' '||p.segundo_apellido), ' +', ' ') AS cliente,
  cxc.id_comprobante,
  co.nro_comprobante                                   AS comprobante_origen,
  co.id_oficina,
  o.descripcion                                        AS oficina,
  (WKSP_WORKPLACE.FN_HOY - ccd.fecha_vencimiento)      AS dias_atraso,
  CASE WHEN ccd.fecha_vencimiento >= WKSP_WORKPLACE.FN_HOY THEN 'S' ELSE 'N' END AS por_vencer,
  CASE
    WHEN ccd.fecha_vencimiento >= WKSP_WORKPLACE.FN_HOY                       THEN 'Por vencer'
    WHEN WKSP_WORKPLACE.FN_HOY - ccd.fecha_vencimiento <= 30                  THEN '1-30 dias'
    WHEN WKSP_WORKPLACE.FN_HOY - ccd.fecha_vencimiento <= 60                  THEN '31-60 dias'
    WHEN WKSP_WORKPLACE.FN_HOY - ccd.fecha_vencimiento <= 90                  THEN '61-90 dias'
    ELSE '+90 dias'
  END                                                  AS bucket,
  CASE
    WHEN ccd.fecha_vencimiento >= WKSP_WORKPLACE.FN_HOY                       THEN 0
    WHEN WKSP_WORKPLACE.FN_HOY - ccd.fecha_vencimiento <= 30                  THEN 1
    WHEN WKSP_WORKPLACE.FN_HOY - ccd.fecha_vencimiento <= 60                  THEN 2
    WHEN WKSP_WORKPLACE.FN_HOY - ccd.fecha_vencimiento <= 90                  THEN 3
    ELSE 4
  END                                                  AS bucket_orden
FROM WKSP_WORKPLACE.CUENTAS_COBRAR_DET ccd
JOIN      WKSP_WORKPLACE.CUENTAS_COBRAR cxc ON cxc.id_cxc        = ccd.id_cxc
LEFT JOIN WKSP_WORKPLACE.COMPROBANTES   co  ON co.id_comprobante = cxc.id_comprobante
LEFT JOIN WKSP_WORKPLACE.OFICINAS       o   ON o.codigo_oficina  = co.id_oficina
LEFT JOIN WKSP_WORKPLACE.PERSONAS       p   ON p.id_persona      = cxc.id_persona
WHERE ccd.estado IN ('PENDIENTE','VENCIDA');

prompt == F22.1.6 V_COBROS_OFICINA_META (neto vs. meta de oficina) ==
CREATE OR REPLACE VIEW WKSP_WORKPLACE.V_COBROS_OFICINA_META AS
SELECT
  v.periodo,
  v.id_oficina,
  v.oficina,
  v.neto,
  m.monto_meta,
  CASE WHEN m.monto_meta > 0
       THEN ROUND(v.neto / m.monto_meta * 100, 1) END AS cumplimiento_pct
FROM (
  SELECT periodo, id_oficina, oficina, SUM(neto) AS neto
  FROM WKSP_WORKPLACE.V_COBROS_NETO_MES
  GROUP BY periodo, id_oficina, oficina
) v
LEFT JOIN WKSP_WORKPLACE.METAS_COBRANZA m ON m.id_oficina = v.id_oficina
                                          AND m.periodo    = v.periodo;

prompt == F22.1.7 Verificacion (contra datos reales) ==
DECLARE
  v_mov_cnt PLS_INTEGER; v_bruto NUMBER;
  v_rev_cnt PLS_INTEGER; v_rev   NUMBER;
  v_neto    NUMBER;
  v_cart    NUMBER;      v_medio NUMBER;
  v_ok BOOLEAN := TRUE;
BEGIN
  SELECT COUNT(*), NVL(SUM(total),0)         INTO v_mov_cnt, v_bruto FROM WKSP_WORKPLACE.V_COBROS_MOV;
  SELECT COUNT(*), NVL(SUM(total_reverso),0) INTO v_rev_cnt, v_rev   FROM WKSP_WORKPLACE.V_COBROS_REVERSO;
  SELECT NVL(SUM(neto),0)                    INTO v_neto             FROM WKSP_WORKPLACE.V_COBROS_NETO_MES;
  SELECT NVL(SUM(monto_cuota),0)             INTO v_cart             FROM WKSP_WORKPLACE.V_CARTERA_CXC;
  SELECT NVL(SUM(monto),0)                   INTO v_medio            FROM WKSP_WORKPLACE.V_COBROS_MEDIO;

  DBMS_OUTPUT.PUT_LINE('  V_COBROS_MOV     : '||v_mov_cnt||' cobros, bruto '||v_bruto);
  DBMS_OUTPUT.PUT_LINE('  V_COBROS_REVERSO : '||v_rev_cnt||' reversos, total '||v_rev);
  DBMS_OUTPUT.PUT_LINE('  V_COBROS_NETO_MES: neto '||v_neto||' (= bruto-reverso)');
  DBMS_OUTPUT.PUT_LINE('  V_COBROS_MEDIO   : suma por medio '||v_medio||' (= bruto)');
  DBMS_OUTPUT.PUT_LINE('  V_CARTERA_CXC    : saldo pendiente '||v_cart);

  -- consistencia 1: neto agregado == bruto - reverso
  IF v_neto != (v_bruto - v_rev) THEN
    DBMS_OUTPUT.PUT_LINE('  FAIL neto != bruto-reverso'); v_ok := FALSE;
  END IF;
  -- consistencia 2: el desglose por medio (bruto) suma el bruto de los cobros
  IF v_medio != v_bruto THEN
    DBMS_OUTPUT.PUT_LINE('  FAIL V_COBROS_MEDIO ('||v_medio||') != bruto ('||v_bruto||')'); v_ok := FALSE;
  END IF;

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE(CHR(10)||'F22.1 vistas OK.');
  ELSE RAISE_APPLICATION_ERROR(-20908,'F22.1 verificacion FAIL.'); END IF;
END;
/

prompt == F22.1 - fin ==
set define on
ALTER SESSION SET CURRENT_SCHEMA = ADMIN;

-- ============================================================================
-- F18.2 - Informe de Ventas imprimible por FILTROS (FN_INFORME_VENTAS_HTML)
-- ============================================================================
-- Genera el HTML del Informe de Ventas parametrizado por filtros (pedido del
-- profesor, 2026-06-27): rango de fechas (cubre dia / mes / anio / rango libre),
-- vendedor, sucursal y condicion (contado/credito). La pagina P135 (Generador de
-- Informe de Ventas) lo invoca con:
--   RETURN FN_INFORME_VENTAS_HTML(:P135_DESDE, :P135_HASTA, :P135_VENDEDOR,
--                                 :P135_OFICINA, :P135_CONDICION).
--
-- MISMA convencion que el arqueo (F17.1) y el KuDE (F12): documento de CONTROL
-- INTERNO, sin CDC/QR, reusa las clases visuales (kude). NO es DE SIFEN.
-- "Graficos" = BARRAS CSS/HTML (divs con width:%), NO JET charts.
-- Misma fuente que el Dashboard P133 (vistas V_VENTAS_* de F18.1).
--
-- Desglose temporal AUTOMATICO: si el rango es <= 31 dias, las barras van por
-- DIA; si es mas largo, por MES.
--
-- Parametros (todos opcionales):
--   p_fecha_desde / p_fecha_hasta  rango de fechas (NULL = sin tope; ambos NULL = todo).
--   p_vendedor   CODIGO_USUARIO (= USUARIO_CREACION), NULL = todos.
--   p_oficina    CODIGO_OFICINA, NULL = todas.
--   p_condicion  'CONTADO' | 'CREDITO' | NULL = ambas. (No filtra las NC.)
--
-- Reusa: FN_GET_PARAMETRO (emisor), FN_HOY/FN_AHORA (fecha local UTC-3, F19).
-- Pre-requisito: F18.1 (vistas, con V_VENTAS_LINEA.fecha).
-- Idempotente: CREATE OR REPLACE.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F18_2_informe_ventas_html.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F18.2 FN_INFORME_VENTAS_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_INFORME_VENTAS_HTML (
  p_fecha_desde IN DATE     DEFAULT NULL,
  p_fecha_hasta IN DATE     DEFAULT NULL,
  p_vendedor    IN VARCHAR2 DEFAULT NULL,
  p_oficina     IN NUMBER   DEFAULT NULL,
  p_condicion   IN VARCHAR2 DEFAULT NULL
) RETURN CLOB IS
  v_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');

  v_html   CLOB;
  v_desde  DATE := TRUNC(NVL(p_fecha_desde, DATE '1900-01-01'));
  v_hasta  DATE := TRUNC(NVL(p_fecha_hasta, WKSP_WORKPLACE.FN_HOY));
  v_hasta1 DATE;                       -- limite superior exclusivo (hasta + 1 dia)
  v_fmt    VARCHAR2(4);                 -- 'DDD' (dia) | 'MM' (mes)
  v_grano  VARCHAR2(3);
  v_max    NUMBER;
  v_any    PLS_INTEGER;
  v_lbl    VARCHAR2(40);
  v_f_ofi  VARCHAR2(255);
  v_f_ven  VARCHAR2(255);

  v_neto NUMBER; v_fac NUMBER; v_tot NUMBER; v_cont NUMBER;
  v_tick NUMBER; v_pcont NUMBER; v_meta NUMBER; v_pcump NUMBER;

  FUNCTION fmt(n NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TRANSLATE(TO_CHAR(ROUND(NVL(n,0)),'FM999G999G999G990'), ',', '.');
  END;

  FUNCTION bar(p_val NUMBER, p_max NUMBER, p_ok VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    w NUMBER := CASE WHEN NVL(p_max,0) > 0
                     THEN LEAST(ROUND(NVL(p_val,0)/p_max*100), 100) ELSE 0 END;
  BEGIN
    RETURN '<div class="track"><div class="bar'||
           CASE WHEN p_ok='S' THEN ' ok' WHEN p_ok='N' THEN ' warn' ELSE '' END||
           '" style="width:'||w||'%"></div></div>';
  END;
BEGIN
  IF v_hasta < v_desde THEN v_hasta := v_desde; END IF;
  v_hasta1 := v_hasta + 1;
  v_grano  := CASE WHEN (v_hasta - v_desde) <= 31 THEN 'DIA' ELSE 'MES' END;
  v_fmt    := CASE v_grano WHEN 'DIA' THEN 'DDD' ELSE 'MM' END;

  -- Etiquetas de filtros (PL/SQL no admite scalar subquery en asignacion -> SELECT INTO)
  IF p_oficina IS NOT NULL THEN
    BEGIN SELECT descripcion INTO v_f_ofi FROM WKSP_WORKPLACE.OFICINAS WHERE codigo_oficina = p_oficina;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_ofi := 'Oficina '||p_oficina; END;
  ELSE v_f_ofi := 'Todas'; END IF;
  IF p_vendedor IS NOT NULL THEN
    BEGIN SELECT nombre INTO v_f_ven FROM WKSP_WORKPLACE.EMPLEADOS WHERE codigo_usuario = p_vendedor;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_ven := p_vendedor; END;
  ELSE v_f_ven := 'Todos'; END IF;

  -- ===== KPIs (FA en rango - NC en rango) =====
  SELECT NVL(SUM(monto),0) INTO v_neto FROM (
    SELECT f.total monto FROM WKSP_WORKPLACE.V_VENTAS_FACTURA f
     WHERE f.fecha >= v_desde AND f.fecha < v_hasta1
       AND (p_oficina   IS NULL OR f.id_oficina   = p_oficina)
       AND (p_vendedor  IS NULL OR f.vendedor_cod = p_vendedor)
       AND (p_condicion IS NULL OR f.condicion    = p_condicion)
    UNION ALL
    SELECT -nc.total_nc FROM WKSP_WORKPLACE.V_VENTAS_NC nc
     WHERE nc.fecha_nc >= v_desde AND nc.fecha_nc < v_hasta1
       AND (p_oficina  IS NULL OR nc.id_oficina   = p_oficina)
       AND (p_vendedor IS NULL OR nc.vendedor_cod = p_vendedor)
  );

  SELECT COUNT(*), NVL(SUM(total),0), NVL(SUM(CASE WHEN es_contado='S' THEN total END),0)
    INTO v_fac, v_tot, v_cont
    FROM WKSP_WORKPLACE.V_VENTAS_FACTURA f
   WHERE f.fecha >= v_desde AND f.fecha < v_hasta1
     AND (p_oficina   IS NULL OR f.id_oficina   = p_oficina)
     AND (p_vendedor  IS NULL OR f.vendedor_cod = p_vendedor)
     AND (p_condicion IS NULL OR f.condicion    = p_condicion);

  v_tick  := CASE WHEN v_fac > 0 THEN ROUND(v_neto/v_fac) END;
  v_pcont := CASE WHEN v_tot > 0 THEN ROUND(v_cont/v_tot*100,1) END;

  -- meta = suma de metas mensuales de los meses tocados por el rango (filtrada por vendedor)
  SELECT NVL(SUM(mv.monto_meta),0) INTO v_meta
    FROM WKSP_WORKPLACE.METAS_VENTA mv
    JOIN WKSP_WORKPLACE.EMPLEADOS e ON e.id_empleado = mv.id_empleado
   WHERE mv.periodo BETWEEN TRUNC(v_desde,'MM') AND TRUNC(v_hasta,'MM')
     AND (p_vendedor IS NULL OR e.codigo_usuario = p_vendedor);
  v_pcump := CASE WHEN v_meta > 0 THEN ROUND(v_neto/v_meta*100,1) END;

  -- ===== Encabezado =====
  v_html := '<div class="kude"><div class="ktit">Informe de Ventas</div>';
  v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                   || v_dir||'<br>'||v_ciudad||'<br><b>RUC:</b> '||v_ruc||'</td>';
  v_html := v_html || '<td class="r">'
                   || '<b>Per&iacute;odo:</b> '
                   || CASE WHEN p_fecha_desde IS NULL AND p_fecha_hasta IS NULL THEN 'Todo el hist&oacute;rico'
                           ELSE TO_CHAR(v_desde,'dd/mm/yyyy')||' al '||TO_CHAR(v_hasta,'dd/mm/yyyy') END
                   || '<br><b>Sucursal:</b> '||v_f_ofi
                   || '<br><b>Vendedor:</b> '||v_f_ven
                   || '<br><b>Condici&oacute;n:</b> '||NVL(INITCAP(p_condicion),'Todas')
                   || '<br><span class="klabel">Generado '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'</span>'
                   || '</td></tr></table>';

  -- ===== KPIs =====
  v_html := v_html || '<div class="kbox"><table class="krec">'
                   || '<tr><td><span class="klabel">Facturaci&oacute;n neta</span><br><b>&#8370; '||fmt(v_neto)||'</b></td>'
                   || '<td><span class="klabel">Facturas</span><br><b>'||v_fac||'</b></td>'
                   || '<td><span class="klabel">Ticket promedio</span><br><b>&#8370; '||fmt(v_tick)||'</b></td></tr>'
                   || '<tr><td><span class="klabel">Contado</span><br><b>'||NVL(TO_CHAR(v_pcont),'-')||' %</b></td>'
                   || '<td><span class="klabel">Cr&eacute;dito</span><br><b>'||NVL(TO_CHAR(ROUND(100-v_pcont,1)),'-')||' %</b></td>'
                   || '<td><span class="klabel">Cumplimiento meta</span><br><b>'||NVL(TO_CHAR(v_pcump),'&mdash;')||' %</b></td></tr>'
                   || '</table></div>';

  -- ===== Ventas netas por dia / mes (barras) =====
  SELECT NVL(MAX(neto),0) INTO v_max FROM (
    SELECT SUM(monto) neto FROM (
      SELECT TRUNC(f.fecha, v_fmt) b, f.total monto FROM WKSP_WORKPLACE.V_VENTAS_FACTURA f
       WHERE f.fecha >= v_desde AND f.fecha < v_hasta1
         AND (p_oficina IS NULL OR f.id_oficina=p_oficina)
         AND (p_vendedor IS NULL OR f.vendedor_cod=p_vendedor)
         AND (p_condicion IS NULL OR f.condicion=p_condicion)
      UNION ALL
      SELECT TRUNC(nc.fecha_nc, v_fmt), -nc.total_nc FROM WKSP_WORKPLACE.V_VENTAS_NC nc
       WHERE nc.fecha_nc >= v_desde AND nc.fecha_nc < v_hasta1
         AND (p_oficina IS NULL OR nc.id_oficina=p_oficina)
         AND (p_vendedor IS NULL OR nc.vendedor_cod=p_vendedor)
    ) GROUP BY b);
  v_html := v_html || '<div class="kbox"><span class="klabel">Ventas netas por '
                   || CASE v_grano WHEN 'DIA' THEN 'd&iacute;a' ELSE 'mes' END
                   || '</span><table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT b, SUM(monto) neto FROM (
      SELECT TRUNC(f.fecha, v_fmt) b, f.total monto FROM WKSP_WORKPLACE.V_VENTAS_FACTURA f
       WHERE f.fecha >= v_desde AND f.fecha < v_hasta1
         AND (p_oficina IS NULL OR f.id_oficina=p_oficina)
         AND (p_vendedor IS NULL OR f.vendedor_cod=p_vendedor)
         AND (p_condicion IS NULL OR f.condicion=p_condicion)
      UNION ALL
      SELECT TRUNC(nc.fecha_nc, v_fmt), -nc.total_nc FROM WKSP_WORKPLACE.V_VENTAS_NC nc
       WHERE nc.fecha_nc >= v_desde AND nc.fecha_nc < v_hasta1
         AND (p_oficina IS NULL OR nc.id_oficina=p_oficina)
         AND (p_vendedor IS NULL OR nc.vendedor_cod=p_vendedor)
    ) GROUP BY b ORDER BY b
  ) LOOP
    v_lbl := CASE v_grano
               WHEN 'DIA' THEN TO_CHAR(r.b,'dd/mm/yyyy')
               ELSE INITCAP(TO_CHAR(r.b,'fmMonth','NLS_DATE_LANGUAGE=SPANISH'))||' '||TO_CHAR(r.b,'YYYY') END;
    v_html := v_html || '<tr><td class="kb-lbl">'||v_lbl||'</td><td class="kb-bar">'
                     || bar(r.neto, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.neto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Por sucursal (barras) =====
  SELECT NVL(MAX(neto),0) INTO v_max FROM (
    SELECT SUM(monto) neto FROM (
      SELECT NVL(f.oficina,'(sin oficina)') ofi, f.total monto FROM WKSP_WORKPLACE.V_VENTAS_FACTURA f
       WHERE f.fecha >= v_desde AND f.fecha < v_hasta1
         AND (p_oficina IS NULL OR f.id_oficina=p_oficina)
         AND (p_vendedor IS NULL OR f.vendedor_cod=p_vendedor)
         AND (p_condicion IS NULL OR f.condicion=p_condicion)
      UNION ALL
      SELECT NVL(nc.oficina,'(sin oficina)'), -nc.total_nc FROM WKSP_WORKPLACE.V_VENTAS_NC nc
       WHERE nc.fecha_nc >= v_desde AND nc.fecha_nc < v_hasta1
         AND (p_oficina IS NULL OR nc.id_oficina=p_oficina)
         AND (p_vendedor IS NULL OR nc.vendedor_cod=p_vendedor)
    ) GROUP BY ofi);
  v_html := v_html || '<div class="kbox"><span class="klabel">Facturaci&oacute;n neta por sucursal</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT ofi, SUM(monto) neto FROM (
      SELECT NVL(f.oficina,'(sin oficina)') ofi, f.total monto FROM WKSP_WORKPLACE.V_VENTAS_FACTURA f
       WHERE f.fecha >= v_desde AND f.fecha < v_hasta1
         AND (p_oficina IS NULL OR f.id_oficina=p_oficina)
         AND (p_vendedor IS NULL OR f.vendedor_cod=p_vendedor)
         AND (p_condicion IS NULL OR f.condicion=p_condicion)
      UNION ALL
      SELECT NVL(nc.oficina,'(sin oficina)'), -nc.total_nc FROM WKSP_WORKPLACE.V_VENTAS_NC nc
       WHERE nc.fecha_nc >= v_desde AND nc.fecha_nc < v_hasta1
         AND (p_oficina IS NULL OR nc.id_oficina=p_oficina)
         AND (p_vendedor IS NULL OR nc.vendedor_cod=p_vendedor)
    ) GROUP BY ofi ORDER BY neto DESC
  ) LOOP
    v_html := v_html || '<tr><td class="kb-lbl">'||r.ofi||'</td><td class="kb-bar">'
                     || bar(r.neto, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.neto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Top productos (barras) =====
  SELECT NVL(MAX(s),0) INTO v_max FROM (
    SELECT SUM(total_linea) s FROM WKSP_WORKPLACE.V_VENTAS_LINEA
     WHERE fecha >= v_desde AND fecha < v_hasta1
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
       AND (p_condicion IS NULL OR condicion=p_condicion)
     GROUP BY producto);
  v_html := v_html || '<div class="kbox"><span class="klabel">Top productos</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT producto, SUM(total_linea) monto FROM WKSP_WORKPLACE.V_VENTAS_LINEA
     WHERE fecha >= v_desde AND fecha < v_hasta1
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
       AND (p_condicion IS NULL OR condicion=p_condicion)
     GROUP BY producto ORDER BY monto DESC FETCH FIRST 10 ROWS ONLY
  ) LOOP
    v_html := v_html || '<tr><td class="kb-lbl">'||r.producto||'</td><td class="kb-bar">'
                     || bar(r.monto, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.monto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Ranking vendedores vs meta (meta de los meses del rango) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Ranking de vendedores vs. meta '
                   || '<i>(meta de los meses del rango)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Vendedor</th><th>Neto</th><th>Meta</th><th>Cumplimiento</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT v.vendedor_nombre, v.neto, NVL(m.meta,0) meta,
           CASE WHEN NVL(m.meta,0) > 0 THEN ROUND(v.neto/m.meta*100,1) END pct
    FROM (
      SELECT vendedor_cod, MAX(vendedor_nombre) vendedor_nombre, SUM(monto) neto FROM (
        SELECT f.vendedor_cod, f.vendedor_nombre, f.total monto FROM WKSP_WORKPLACE.V_VENTAS_FACTURA f
         WHERE f.fecha >= v_desde AND f.fecha < v_hasta1
           AND (p_oficina IS NULL OR f.id_oficina=p_oficina)
           AND (p_vendedor IS NULL OR f.vendedor_cod=p_vendedor)
           AND (p_condicion IS NULL OR f.condicion=p_condicion)
        UNION ALL
        SELECT nc.vendedor_cod, nc.vendedor_nombre, -nc.total_nc FROM WKSP_WORKPLACE.V_VENTAS_NC nc
         WHERE nc.fecha_nc >= v_desde AND nc.fecha_nc < v_hasta1
           AND (p_oficina IS NULL OR nc.id_oficina=p_oficina)
           AND (p_vendedor IS NULL OR nc.vendedor_cod=p_vendedor)
      ) GROUP BY vendedor_cod
    ) v
    LEFT JOIN (
      SELECT e.codigo_usuario cod, SUM(mv.monto_meta) meta
        FROM WKSP_WORKPLACE.METAS_VENTA mv
        JOIN WKSP_WORKPLACE.EMPLEADOS e ON e.id_empleado = mv.id_empleado
       WHERE mv.periodo BETWEEN TRUNC(v_desde,'MM') AND TRUNC(v_hasta,'MM')
       GROUP BY e.codigo_usuario
    ) m ON m.cod = v.vendedor_cod
    ORDER BY pct DESC NULLS LAST, v.neto DESC
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.vendedor_nombre
                     || '</td><td class="r">&#8370; '||fmt(r.neto)
                     || '</td><td class="r">'||CASE WHEN r.meta>0 THEN '&#8370; '||fmt(r.meta) ELSE '&mdash;' END
                     || '</td><td class="kb-bar">'
                     || CASE WHEN r.pct IS NOT NULL
                             THEN bar(r.pct, 100, CASE WHEN r.pct>=100 THEN 'S' ELSE 'N' END) ELSE '' END
                     || '<span class="kb-pct">'||NVL(TO_CHAR(r.pct),'-')||' %</span></td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="4" class="klabel">Sin ventas para el filtro seleccionado.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Detalle de facturas del rango =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Detalle de facturas</span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Fecha</th><th>Comprobante</th><th>Vendedor</th><th>Cliente</th>'
                   || '<th>Cond.</th><th>Total</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT f.fecha, f.nro_comprobante, f.vendedor_nombre, f.cliente, f.condicion, f.total
      FROM WKSP_WORKPLACE.V_VENTAS_FACTURA f
     WHERE f.fecha >= v_desde AND f.fecha < v_hasta1
       AND (p_oficina IS NULL OR f.id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR f.vendedor_cod=p_vendedor)
       AND (p_condicion IS NULL OR f.condicion=p_condicion)
     ORDER BY f.fecha, f.nro_comprobante
     FETCH FIRST 200 ROWS ONLY
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||TO_CHAR(r.fecha,'dd/mm/yyyy')
                     || '</td><td>'||r.nro_comprobante
                     || '</td><td>'||r.vendedor_nombre
                     || '</td><td>'||r.cliente
                     || '</td><td class="c">'||INITCAP(r.condicion)
                     || '</td><td class="r">&#8370; '||fmt(r.total)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="6" class="klabel">Sin facturas en el rango.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Pie =====
  v_html := v_html || '<div class="kleg">Informe de control interno &mdash; m&oacute;dulo de Ventas.<br>'
                   || '<i>No es un documento electr&oacute;nico (SIFEN) &mdash; sin validez fiscal.</i><br>'
                   || 'Facturaci&oacute;n neta = facturas activas &minus; notas de cr&eacute;dito. '
                   || 'Generado el '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'.</div></div>';

  RETURN v_html;
END FN_INFORME_VENTAS_HTML;
/

prompt == F18.2 Verificacion ==
DECLARE
  v_ok   BOOLEAN := TRUE;
  v_cnt  PLS_INTEGER;
  v_clob CLOB;
  PROCEDURE chk(p_cond BOOLEAN, p_msg VARCHAR2) IS
  BEGIN
    IF p_cond THEN DBMS_OUTPUT.PUT_LINE('  OK   '||p_msg);
    ELSE DBMS_OUTPUT.PUT_LINE('  FAIL '||p_msg); v_ok := FALSE; END IF;
  END;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM all_objects
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_INFORME_VENTAS_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_INFORME_VENTAS_HTML VALID');

  v_clob := WKSP_WORKPLACE.FN_INFORME_VENTAS_HTML(NULL, NULL, NULL, NULL, NULL);
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Informe de Ventas%',
      'HTML sin filtros ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
  chk(v_clob LIKE '%Detalle de facturas%', 'incluye detalle de facturas');
  chk(v_clob LIKE '%Ventas netas por mes%', 'rango largo -> desglose por mes');

  -- rango de un mes (nov-2025), por dia
  v_clob := WKSP_WORKPLACE.FN_INFORME_VENTAS_HTML(DATE '2025-11-01', DATE '2025-11-30', NULL, NULL, NULL);
  chk(v_clob LIKE '%Ventas netas por d%', 'rango <=31 dias -> desglose por dia');

  -- filtros combinados
  v_clob := WKSP_WORKPLACE.FN_INFORME_VENTAS_HTML(DATE '2025-11-01', DATE '2025-11-30', 'TCASCO', NULL, 'CONTADO');
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0, 'filtros combinados (vendedor + condicion) genera');

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== F18.2 OK ==');
  ELSE RAISE_APPLICATION_ERROR(-20996,'F18.2 con errores'); END IF;
END;
/

set define on

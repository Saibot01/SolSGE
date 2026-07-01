-- ============================================================================
-- F23.2 - Informe de Inventario imprimible por FILTROS (FN_INFORME_INVENTARIO_HTML)
-- ============================================================================
-- Genera el HTML del Informe de Inventario parametrizado por filtros: sucursal,
-- categoria y rango de fechas. La pagina P143 (Generador de Informe de Inventario)
-- lo invoca con:
--   RETURN FN_INFORME_INVENTARIO_HTML(:P143_OFICINA, :P143_CATEGORIA,
--            TO_DATE(:P143_DESDE,'YYYY-MM-DD'), TO_DATE(:P143_HASTA,'YYYY-MM-DD')).
--
-- MISMA convencion que el Informe de Cobros (F22.2) / Ventas (F18.2) / arqueo /
-- KuDE: documento de CONTROL INTERNO, sin CDC/QR, reusa las clases visuales
-- (kude, acento azul del modulo). NO es DE SIFEN. "Graficos" = BARRAS CSS/HTML.
-- Misma fuente que el Dashboard P142 (vistas V_INV_* de F23.1).
--
-- SNAPSHOT vs RANGO (ver PLAN_REPORTES_INVENTARIO.md seccion 1.2):
--   * Stock / valorizacion / niveles / detalle / conteos = SNAPSHOT a-hoy;
--     respetan filtro de sucursal + categoria (NO el rango de fechas).
--   * Flujo entradas/salidas = por el RANGO (desglose auto <=31d por dia / mes).
--   * Rotacion / obsolescencia = nivel producto (todas las sucursales).
--
-- Parametros (todos opcionales):
--   p_oficina    CODIGO_OFICINA, NULL = todas.
--   p_categoria  ID_CATEGORIA,   NULL = todas.
--   p_fecha_desde / p_fecha_hasta  rango para el flujo (NULL = sin tope).
--
-- Reusa: FN_GET_PARAMETRO (emisor), FN_HOY/FN_AHORA (fecha local UTC-3, F19).
-- Pre-requisito: F23.1 (vistas V_INV_*). Idempotente: CREATE OR REPLACE.
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F23_2_informe_inventario_html.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F23.2 FN_INFORME_INVENTARIO_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_INFORME_INVENTARIO_HTML (
  p_oficina     IN NUMBER DEFAULT NULL,
  p_categoria   IN NUMBER DEFAULT NULL,
  p_fecha_desde IN DATE   DEFAULT NULL,
  p_fecha_hasta IN DATE   DEFAULT NULL
) RETURN CLOB IS
  v_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');

  v_html   CLOB;
  v_desde  DATE := TRUNC(NVL(p_fecha_desde, DATE '1900-01-01'));
  v_hasta  DATE := TRUNC(NVL(p_fecha_hasta, WKSP_WORKPLACE.FN_HOY));
  v_hasta1 DATE;
  v_fmt    VARCHAR2(4);
  v_grano  VARCHAR2(3);
  v_max    NUMBER;
  v_any    PLS_INTEGER;
  v_lbl    VARCHAR2(60);
  v_f_ofi  VARCHAR2(255);
  v_f_cat  VARCHAR2(255);

  v_valor NUMBER; v_skus NUMBER; v_bajo NUMBER; v_sobre NUMBER;
  v_quiebre NUMBER; v_sinmov NUMBER;

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

  IF p_oficina IS NOT NULL THEN
    BEGIN SELECT descripcion INTO v_f_ofi FROM WKSP_WORKPLACE.OFICINAS WHERE codigo_oficina = p_oficina;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_ofi := 'Oficina '||p_oficina; END;
  ELSE v_f_ofi := 'Todas'; END IF;
  IF p_categoria IS NOT NULL THEN
    BEGIN SELECT nombre INTO v_f_cat FROM WKSP_WORKPLACE.CATEGORIAS_PRODUCTOS WHERE id_categoria = p_categoria;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_cat := 'Categoria '||p_categoria; END;
  ELSE v_f_cat := 'Todas'; END IF;

  -- ===== KPIs (snapshot) =====
  SELECT NVL(SUM(valor_stock),0), COUNT(DISTINCT id_producto),
         SUM(CASE WHEN estado_nivel='BAJO_MINIMO'  THEN 1 ELSE 0 END),
         SUM(CASE WHEN estado_nivel='SOBRE_MAXIMO' THEN 1 ELSE 0 END),
         SUM(CASE WHEN estado_nivel='QUIEBRE'      THEN 1 ELSE 0 END)
    INTO v_valor, v_skus, v_bajo, v_sobre, v_quiebre
    FROM WKSP_WORKPLACE.V_INV_STOCK
   WHERE (p_oficina   IS NULL OR id_oficina   = p_oficina)
     AND (p_categoria IS NULL OR id_categoria = p_categoria);
  SELECT COUNT(*) INTO v_sinmov FROM WKSP_WORKPLACE.V_INV_ROTACION
   WHERE clase_rotacion = 'SIN_MOVIMIENTO';

  -- ===== Encabezado =====
  v_html := '<div class="kude"><div class="ktit">Informe de Inventario</div>';
  v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                   || v_dir||'<br>'||v_ciudad||'<br><b>RUC:</b> '||v_ruc||'</td>';
  v_html := v_html || '<td class="r">'
                   || '<b>Sucursal:</b> '||v_f_ofi
                   || '<br><b>Categor&iacute;a:</b> '||v_f_cat
                   || '<br><b>Stock al:</b> '||TO_CHAR(WKSP_WORKPLACE.FN_HOY,'dd/mm/yyyy')
                   || '<br><b>Flujo:</b> '
                   || CASE WHEN p_fecha_desde IS NULL AND p_fecha_hasta IS NULL THEN 'Todo el hist&oacute;rico'
                           ELSE TO_CHAR(v_desde,'dd/mm/yyyy')||' al '||TO_CHAR(v_hasta,'dd/mm/yyyy') END
                   || '<br><span class="klabel">Generado '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'</span>'
                   || '</td></tr></table>';

  -- ===== KPIs =====
  v_html := v_html || '<div class="kbox"><table class="krec">'
                   || '<tr><td><span class="klabel">Valor inmovilizado</span><br><b>&#8370; '||fmt(v_valor)||'</b></td>'
                   || '<td><span class="klabel">Productos (SKU)</span><br><b>'||v_skus||'</b></td>'
                   || '<td><span class="klabel">Sin movimiento</span><br><b>'||v_sinmov||'</b></td></tr>'
                   || '<tr><td><span class="klabel">Bajo m&iacute;nimo</span><br><b>'||v_bajo||'</b></td>'
                   || '<td><span class="klabel">Sobre m&aacute;ximo</span><br><b>'||v_sobre||'</b></td>'
                   || '<td><span class="klabel">Quiebres</span><br><b>'||v_quiebre||'</b></td></tr>'
                   || '</table></div>';

  -- ===== Stock valorizado por categoria (barras, snapshot) =====
  SELECT NVL(MAX(v),0) INTO v_max FROM (
    SELECT SUM(valor_stock) v FROM WKSP_WORKPLACE.V_INV_STOCK
     WHERE (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_categoria IS NULL OR id_categoria=p_categoria)
     GROUP BY categoria);
  v_html := v_html || '<div class="kbox"><span class="klabel">Stock valorizado por categor&iacute;a</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT categoria, SUM(valor_stock) v FROM WKSP_WORKPLACE.V_INV_STOCK
     WHERE (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_categoria IS NULL OR id_categoria=p_categoria)
     GROUP BY categoria ORDER BY v DESC NULLS LAST
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td class="kb-lbl">'||r.categoria||'</td><td class="kb-bar">'
                     || bar(r.v, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.v)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="3" class="klabel">Sin stock.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Alertas de nivel (bajo minimo / sobre maximo / quiebre) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Alertas de nivel de stock '
                   || '<i>(bajo m&iacute;nimo / sobre m&aacute;ximo / quiebre)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Producto</th><th>Sucursal</th><th>Stock</th><th>M&iacute;n</th>'
                   || '<th>M&aacute;x</th><th>Estado</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT producto, oficina, cantidad, stock_minimo, stock_maximo, estado_nivel
      FROM WKSP_WORKPLACE.V_INV_STOCK
     WHERE estado_nivel IN ('QUIEBRE','BAJO_MINIMO','SOBRE_MAXIMO')
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_categoria IS NULL OR id_categoria=p_categoria)
     ORDER BY CASE estado_nivel WHEN 'QUIEBRE' THEN 1 WHEN 'BAJO_MINIMO' THEN 2 ELSE 3 END, producto
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.producto||'</td><td>'||r.oficina
                     || '</td><td class="r">'||fmt(r.cantidad)
                     || '</td><td class="r">'||NVL(TO_CHAR(r.stock_minimo),'-')
                     || '</td><td class="r">'||NVL(TO_CHAR(r.stock_maximo),'-')
                     || '</td><td>'||REPLACE(INITCAP(r.estado_nivel),'_',' ')||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="6" class="klabel">Sin alertas: todo el stock dentro de rango.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Flujo entradas/salidas por dia/mes (RANGO) =====
  SELECT NVL(MAX(GREATEST(NVL(ent,0),NVL(sal,0))),0) INTO v_max FROM (
    SELECT TRUNC(fecha_movimiento, v_fmt) b,
           SUM(CASE WHEN tipo_movimiento='ENTRADA' THEN cantidad ELSE 0 END) ent,
           SUM(CASE WHEN tipo_movimiento='SALIDA'  THEN cantidad ELSE 0 END) sal
      FROM WKSP_WORKPLACE.V_INV_MOV
     WHERE fecha_movimiento >= v_desde AND fecha_movimiento < v_hasta1
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_categoria IS NULL OR id_categoria=p_categoria)
     GROUP BY TRUNC(fecha_movimiento, v_fmt));
  v_html := v_html || '<div class="kbox"><span class="klabel">Entradas vs. salidas por '
                   || CASE v_grano WHEN 'DIA' THEN 'd&iacute;a' ELSE 'mes' END
                   || ' <i>(rango seleccionado)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Per&iacute;odo</th><th>Entradas</th><th>Salidas</th>'
                   || '<th>Salidas (barra)</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT TRUNC(fecha_movimiento, v_fmt) b,
           SUM(CASE WHEN tipo_movimiento='ENTRADA' THEN cantidad ELSE 0 END) ent,
           SUM(CASE WHEN tipo_movimiento='SALIDA'  THEN cantidad ELSE 0 END) sal
      FROM WKSP_WORKPLACE.V_INV_MOV
     WHERE fecha_movimiento >= v_desde AND fecha_movimiento < v_hasta1
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_categoria IS NULL OR id_categoria=p_categoria)
     GROUP BY TRUNC(fecha_movimiento, v_fmt) ORDER BY b
  ) LOOP
    v_any := v_any + 1;
    v_lbl := CASE v_grano
               WHEN 'DIA' THEN TO_CHAR(r.b,'dd/mm/yyyy')
               ELSE INITCAP(TO_CHAR(r.b,'fmMonth','NLS_DATE_LANGUAGE=SPANISH'))||' '||TO_CHAR(r.b,'YYYY') END;
    v_html := v_html || '<tr><td>'||v_lbl||'</td><td class="r">'||fmt(r.ent)
                     || '</td><td class="r">'||fmt(r.sal)||'</td><td class="kb-bar">'
                     || bar(r.sal, v_max)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="4" class="klabel">Sin movimientos en el rango.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Rotacion / obsolescencia (nivel producto, snapshot) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Rotaci&oacute;n y obsolescencia '
                   || '<i>(&iacute;ndice = salidas por venta / stock actual; nivel producto)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Producto</th><th>Stock</th><th>Salidas</th><th>&Iacute;ndice</th>'
                   || '<th>Clase</th><th>D&iacute;as sin mov.</th></tr></thead><tbody>';
  FOR r IN (
    SELECT producto, stock_actual, salidas_venta, indice_rotacion, clase_rotacion, dias_sin_mov
      FROM WKSP_WORKPLACE.V_INV_ROTACION
     ORDER BY CASE clase_rotacion WHEN 'RAPIDO' THEN 1 WHEN 'LENTO' THEN 2 ELSE 3 END,
              indice_rotacion DESC NULLS LAST
  ) LOOP
    v_html := v_html || '<tr><td>'||r.producto
                     || '</td><td class="r">'||fmt(r.stock_actual)
                     || '</td><td class="r">'||fmt(r.salidas_venta)
                     || '</td><td class="r">'||NVL(TO_CHAR(r.indice_rotacion),'-')
                     || '</td><td>'||REPLACE(INITCAP(r.clase_rotacion),'_',' ')
                     || '</td><td class="r">'||NVL(TO_CHAR(r.dias_sin_mov),'-')||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Diferencias de inventario fisico (conteos, snapshot) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Diferencias de inventario f&iacute;sico '
                   || '<i>(conteos)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Documento</th><th>Fecha</th><th>Estado</th><th>L&iacute;neas</th>'
                   || '<th>&Sigma; |dif.|</th><th>Exactitud</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT nro_documento, MAX(fecha_inventario) fecha, MAX(estado_doc) estado,
           COUNT(*) lineas, SUM(dif_abs) dif_abs, ROUND(AVG(exactitud_pct),1) exact
      FROM WKSP_WORKPLACE.V_INV_CONTEO_DIF
     WHERE (p_oficina IS NULL OR id_oficina=p_oficina)
     GROUP BY nro_documento ORDER BY MAX(fecha_inventario) DESC, nro_documento
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.nro_documento||'</td><td>'||TO_CHAR(r.fecha,'dd/mm/yyyy')
                     || '</td><td>'||INITCAP(r.estado)
                     || '</td><td class="r">'||r.lineas
                     || '</td><td class="r">'||fmt(r.dif_abs)
                     || '</td><td class="r">'||NVL(TO_CHAR(r.exact),'-')||' %</td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="6" class="klabel">Sin conteos registrados.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Detalle de stock valorizado (snapshot) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Detalle de stock valorizado</span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Producto</th><th>Categor&iacute;a</th><th>Sucursal</th><th>Stock</th>'
                   || '<th>Costo unit.</th><th>Valor</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT producto, categoria, oficina, cantidad, costo_unitario, valor_stock
      FROM WKSP_WORKPLACE.V_INV_STOCK
     WHERE (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_categoria IS NULL OR id_categoria=p_categoria)
     ORDER BY valor_stock DESC NULLS LAST
     FETCH FIRST 200 ROWS ONLY
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.producto||'</td><td>'||r.categoria||'</td><td>'||r.oficina
                     || '</td><td class="r">'||fmt(r.cantidad)
                     || '</td><td class="r">'||CASE WHEN r.costo_unitario IS NULL THEN '(sin costo)' ELSE '&#8370; '||fmt(r.costo_unitario) END
                     || '</td><td class="r">'||CASE WHEN r.valor_stock IS NULL THEN '&mdash;' ELSE '&#8370; '||fmt(r.valor_stock) END
                     || '</td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="6" class="klabel">Sin stock para el filtro seleccionado.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Pie =====
  v_html := v_html || '<div class="kleg">Informe de control interno &mdash; m&oacute;dulo de Inventario.<br>'
                   || '<i>No es un documento electr&oacute;nico (SIFEN) &mdash; sin validez fiscal.</i><br>'
                   || 'Stock, valorizaci&oacute;n y niveles: saldo actual. '
                   || 'Costo = promedio ponderado de compras o precio de proveedor. '
                   || 'Generado el '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'.</div></div>';

  RETURN v_html;
END FN_INFORME_INVENTARIO_HTML;
/

prompt == F23.2 Verificacion ==
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
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_INFORME_INVENTARIO_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_INFORME_INVENTARIO_HTML VALID');

  v_clob := WKSP_WORKPLACE.FN_INFORME_INVENTARIO_HTML(NULL, NULL, NULL, NULL);
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Informe de Inventario%',
      'HTML sin filtros ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
  chk(v_clob LIKE '%Stock valorizado por categor%', 'incluye valorizacion por categoria');
  chk(v_clob LIKE '%Alertas de nivel de stock%', 'incluye alertas de nivel');
  chk(v_clob LIKE '%Rotaci%n y obsolescencia%', 'incluye rotacion');
  chk(v_clob LIKE '%Diferencias de inventario f%', 'incluye diferencias de conteo');
  chk(v_clob LIKE '%Detalle de stock valorizado%', 'incluye detalle de stock');

  -- rango de un mes (jun-2026) -> desglose por dia
  v_clob := WKSP_WORKPLACE.FN_INFORME_INVENTARIO_HTML(NULL, NULL, DATE '2026-06-01', DATE '2026-06-30');
  chk(v_clob LIKE '%por d%a%', 'rango <=31 dias -> desglose por dia');

  -- filtros combinados (sucursal + categoria)
  v_clob := WKSP_WORKPLACE.FN_INFORME_INVENTARIO_HTML(1, 2, NULL, NULL);
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0, 'filtros combinados (sucursal + categoria) genera');

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== F23.2 OK ==');
  ELSE RAISE_APPLICATION_ERROR(-20922,'F23.2 con errores'); END IF;
END;
/

set define on

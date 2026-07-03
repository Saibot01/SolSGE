-- ============================================================================
-- F25.2 - Informe de Compras imprimible por FILTROS (FN_INFORME_COMPRAS_HTML)
-- ============================================================================
-- Genera el HTML del Informe Gerencial de Compras parametrizado por filtros:
-- rango de fechas, proveedor y categoria. La pagina P145 lo invoca con:
--   RETURN FN_INFORME_COMPRAS_HTML(TO_DATE(:P145_DESDE,'YYYY-MM-DD'),
--            TO_DATE(:P145_HASTA,'YYYY-MM-DD'), :P145_PROVEEDOR, :P145_CATEGORIA).
--
-- MISMA convencion que Inventario (F23.2) / Cobros (F22.2) / Ventas (F18.2) / KuDE:
-- documento de CONTROL INTERNO, sin CDC/QR, reusa las clases visuales (kude, acento
-- azul). NO es DE SIFEN. "Graficos" = BARRAS CSS/HTML. Fuente = vistas V_CMP_* (F25.1)
-- + V_CXP_DEUDA (F24).
--
-- SNAPSHOT vs RANGO:
--   * Gasto / gasto por proveedor-categoria-periodo / detalle / recepciones = RANGO
--     (desglose auto <=31d por dia / mes) respetando proveedor.
--   * Embudo de OC / OC abiertas / aging de deuda / top acreedores = SNAPSHOT a-hoy
--     (respetan proveedor; el aging es la foto de la deuda al momento).
--   * Categoria filtra las secciones a nivel producto (gasto por categoria / detalle).
--
-- Reusa: FN_GET_PARAMETRO (emisor), FN_HOY/FN_AHORA (fecha local UTC-3, F19).
-- Pre-requisito: F25.1 (vistas V_CMP_*), F24 (V_CXP_DEUDA). Idempotente: CREATE OR REPLACE.
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F25_2_informe_compras_html.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F25.2 FN_INFORME_COMPRAS_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_INFORME_COMPRAS_HTML (
  p_fecha_desde IN DATE   DEFAULT NULL,
  p_fecha_hasta IN DATE   DEFAULT NULL,
  p_proveedor   IN NUMBER DEFAULT NULL,
  p_categoria   IN NUMBER DEFAULT NULL
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
  v_f_prov VARCHAR2(255);
  v_f_cat  VARCHAR2(255);

  v_gasto NUMBER; v_ncomp NUMBER; v_deuda NUMBER; v_venc NUMBER; v_pctvenc NUMBER;
  v_ocab NUMBER; v_ocval NUMBER;

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

  IF p_proveedor IS NOT NULL THEN
    BEGIN
      SELECT TRIM(per.primer_nombre||' '||per.primer_apellido) INTO v_f_prov
        FROM WKSP_WORKPLACE.PERSONAS per WHERE per.id_persona = p_proveedor;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_prov := 'Proveedor '||p_proveedor; END;
  ELSE v_f_prov := 'Todos'; END IF;
  IF p_categoria IS NOT NULL THEN
    BEGIN SELECT descripcion INTO v_f_cat FROM WKSP_WORKPLACE.CATEGORIAS_PRODUCTOS WHERE id_categoria = p_categoria;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_cat := 'Categoria '||p_categoria; END;
  ELSE v_f_cat := 'Todas'; END IF;

  -- ===== KPIs =====
  SELECT NVL(SUM(total),0), COUNT(*)
    INTO v_gasto, v_ncomp
    FROM WKSP_WORKPLACE.V_CMP_COMPRA
   WHERE fecha_emision >= v_desde AND fecha_emision < v_hasta1
     AND (p_proveedor IS NULL OR id_proveedor = p_proveedor);
  SELECT NVL(SUM(saldo),0), NVL(SUM(CASE WHEN dias_atraso>0 THEN saldo ELSE 0 END),0)
    INTO v_deuda, v_venc
    FROM WKSP_WORKPLACE.V_CMP_CXP_AGING
   WHERE (p_proveedor IS NULL OR id_proveedor = p_proveedor);
  v_pctvenc := CASE WHEN v_deuda>0 THEN ROUND(v_venc*100/v_deuda) ELSE 0 END;
  SELECT COUNT(*), NVL(SUM(total_orden),0) INTO v_ocab, v_ocval
    FROM WKSP_WORKPLACE.V_CMP_OC_ABIERTA
   WHERE (p_proveedor IS NULL OR id_proveedor = p_proveedor);

  -- ===== Encabezado =====
  v_html := '<div class="kude"><div class="ktit">Informe Gerencial de Compras</div>';
  v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                   || v_dir||'<br>'||v_ciudad||'<br><b>RUC:</b> '||v_ruc||'</td>';
  v_html := v_html || '<td class="r">'
                   || '<b>Proveedor:</b> '||v_f_prov
                   || '<br><b>Categor&iacute;a:</b> '||v_f_cat
                   || '<br><b>Per&iacute;odo:</b> '
                   || CASE WHEN p_fecha_desde IS NULL AND p_fecha_hasta IS NULL THEN 'Todo el hist&oacute;rico'
                           ELSE TO_CHAR(v_desde,'dd/mm/yyyy')||' al '||TO_CHAR(v_hasta,'dd/mm/yyyy') END
                   || '<br><b>Deuda al:</b> '||TO_CHAR(WKSP_WORKPLACE.FN_HOY,'dd/mm/yyyy')
                   || '<br><span class="klabel">Generado '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'</span>'
                   || '</td></tr></table>';

  -- ===== KPIs =====
  v_html := v_html || '<div class="kbox"><table class="krec">'
                   || '<tr><td><span class="klabel">Gasto de compra</span><br><b>&#8370; '||fmt(v_gasto)||'</b></td>'
                   || '<td><span class="klabel">Comprobantes</span><br><b>'||v_ncomp||'</b></td>'
                   || '<td><span class="klabel">OC abiertas</span><br><b>'||v_ocab||'</b></td></tr>'
                   || '<tr><td><span class="klabel">Deuda a proveedores</span><br><b>&#8370; '||fmt(v_deuda)||'</b></td>'
                   || '<td><span class="klabel">Deuda vencida</span><br><b>'||v_pctvenc||' %</b></td>'
                   || '<td><span class="klabel">Comprometido en OC</span><br><b>&#8370; '||fmt(v_ocval)||'</b></td></tr>'
                   || '</table></div>';

  -- ===== Gasto por proveedor (barras, rango) =====
  SELECT NVL(MAX(v),0) INTO v_max FROM (
    SELECT SUM(total) v FROM WKSP_WORKPLACE.V_CMP_COMPRA
     WHERE fecha_emision >= v_desde AND fecha_emision < v_hasta1
       AND (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY proveedor);
  v_html := v_html || '<div class="kbox"><span class="klabel">Gasto de compra por proveedor</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT proveedor, SUM(total) v FROM WKSP_WORKPLACE.V_CMP_COMPRA
     WHERE fecha_emision >= v_desde AND fecha_emision < v_hasta1
       AND (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY proveedor ORDER BY v DESC NULLS LAST
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td class="kb-lbl">'||r.proveedor||'</td><td class="kb-bar">'
                     || bar(r.v, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.v)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="3" class="klabel">Sin compras en el rango.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Gasto por categoria (barras, rango, nivel producto) =====
  SELECT NVL(MAX(v),0) INTO v_max FROM (
    SELECT SUM(total) v FROM WKSP_WORKPLACE.V_CMP_LINEA
     WHERE periodo >= TRUNC(v_desde,'MM') AND periodo < v_hasta1
       AND (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY categoria);
  v_html := v_html || '<div class="kbox"><span class="klabel">Gasto de compra por categor&iacute;a</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT categoria, SUM(total) v FROM WKSP_WORKPLACE.V_CMP_LINEA
     WHERE periodo >= TRUNC(v_desde,'MM') AND periodo < v_hasta1
       AND (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY categoria ORDER BY v DESC NULLS LAST
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td class="kb-lbl">'||NVL(r.categoria,'(sin categor&iacute;a)')||'</td><td class="kb-bar">'
                     || bar(r.v, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.v)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="3" class="klabel">Sin compras en el rango.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Gasto por periodo dia/mes (barras, rango) =====
  SELECT NVL(MAX(v),0) INTO v_max FROM (
    SELECT SUM(total) v FROM WKSP_WORKPLACE.V_CMP_COMPRA
     WHERE fecha_emision >= v_desde AND fecha_emision < v_hasta1
       AND (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY TRUNC(fecha_emision, v_fmt));
  v_html := v_html || '<div class="kbox"><span class="klabel">Gasto de compra por '
                   || CASE v_grano WHEN 'DIA' THEN 'd&iacute;a' ELSE 'mes' END
                   || ' <i>(rango seleccionado)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Per&iacute;odo</th><th>Compras</th><th>Gasto</th>'
                   || '<th>Gasto (barra)</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT TRUNC(fecha_emision, v_fmt) b, COUNT(*) n, SUM(total) v
      FROM WKSP_WORKPLACE.V_CMP_COMPRA
     WHERE fecha_emision >= v_desde AND fecha_emision < v_hasta1
       AND (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY TRUNC(fecha_emision, v_fmt) ORDER BY b
  ) LOOP
    v_any := v_any + 1;
    v_lbl := CASE v_grano
               WHEN 'DIA' THEN TO_CHAR(r.b,'dd/mm/yyyy')
               ELSE INITCAP(TO_CHAR(r.b,'fmMonth','NLS_DATE_LANGUAGE=SPANISH'))||' '||TO_CHAR(r.b,'YYYY') END;
    v_html := v_html || '<tr><td>'||v_lbl||'</td><td class="r">'||r.n
                     || '</td><td class="r">&#8370; '||fmt(r.v)||'</td><td class="kb-bar">'
                     || bar(r.v, v_max)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="4" class="klabel">Sin compras en el rango.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Embudo de Ordenes de Compra (snapshot) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Embudo de &oacute;rdenes de compra</span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Estado</th><th>&Oacute;rdenes</th><th>Monto</th></tr></thead><tbody>';
  FOR r IN (
    SELECT estado_label, n_oc, monto FROM WKSP_WORKPLACE.V_CMP_OC_EMBUDO ORDER BY orden
  ) LOOP
    v_html := v_html || '<tr><td>'||r.estado_label||'</td><td class="r">'||r.n_oc
                     || '</td><td class="r">&#8370; '||fmt(r.monto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Desempeno de recepcion / lead time por proveedor (rango) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Desempe&ntilde;o de recepci&oacute;n '
                   || '<i>(d&iacute;as OC &rarr; recepci&oacute;n; rango)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Proveedor</th><th>Recepciones</th><th>Lead prom.</th>'
                   || '<th>Lead m&aacute;x.</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT proveedor, COUNT(*) n, ROUND(AVG(lead_dias),1) prom, MAX(lead_dias) mx
      FROM WKSP_WORKPLACE.V_CMP_RECEPCION
     WHERE fecha_recepcion >= v_desde AND fecha_recepcion < v_hasta1
       AND lead_dias IS NOT NULL
       AND (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY proveedor ORDER BY prom DESC NULLS LAST
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.proveedor||'</td><td class="r">'||r.n
                     || '</td><td class="r">'||NVL(TO_CHAR(r.prom),'-')||' d</td>'
                     || '<td class="r">'||NVL(TO_CHAR(r.mx),'-')||' d</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="4" class="klabel">Sin recepciones en el rango.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Ordenes de compra abiertas (snapshot) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">&Oacute;rdenes de compra abiertas '
                   || '<i>(aprobadas, pendientes de recepci&oacute;n)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>OC</th><th>Proveedor</th><th>Sucursal</th><th>Fecha</th>'
                   || '<th>D&iacute;as</th><th>Monto</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT id_orden_compra, proveedor, oficina, fecha_orden, dias_abierta, total_orden
      FROM WKSP_WORKPLACE.V_CMP_OC_ABIERTA
     WHERE (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     ORDER BY dias_abierta DESC NULLS LAST
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td class="r">'||r.id_orden_compra||'</td><td>'||r.proveedor
                     || '</td><td>'||NVL(r.oficina,'-')||'</td><td>'||TO_CHAR(r.fecha_orden,'dd/mm/yyyy')
                     || '</td><td class="r">'||r.dias_abierta
                     || '</td><td class="r">&#8370; '||fmt(r.total_orden)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="6" class="klabel">Sin OC abiertas.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Aging de deuda por tramo (barras, snapshot) =====
  SELECT NVL(MAX(v),0) INTO v_max FROM (
    SELECT SUM(saldo) v FROM WKSP_WORKPLACE.V_CMP_CXP_AGING
     WHERE (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY bucket);
  v_html := v_html || '<div class="kbox"><span class="klabel">Aging de deuda a proveedores '
                   || '<i>(saldo por tramo de atraso; snapshot)</i></span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT bucket, bucket_orden, SUM(saldo) v FROM WKSP_WORKPLACE.V_CMP_CXP_AGING
     WHERE (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY bucket, bucket_orden ORDER BY bucket_orden
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td class="kb-lbl">'||r.bucket||'</td><td class="kb-bar">'
                     || bar(r.v, v_max, CASE WHEN r.bucket_orden=1 THEN 'S' ELSE 'N' END)
                     || '</td><td class="r kb-val">&#8370; '||fmt(r.v)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="3" class="klabel">Sin deuda pendiente.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Top acreedores (snapshot) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Deuda por proveedor (top acreedores)</span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Proveedor</th><th>Saldo</th><th>Vencido</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT proveedor, SUM(saldo) saldo,
           SUM(CASE WHEN dias_atraso>0 THEN saldo ELSE 0 END) venc
      FROM WKSP_WORKPLACE.V_CMP_CXP_AGING
     WHERE (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     GROUP BY proveedor ORDER BY saldo DESC NULLS LAST
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.proveedor||'</td><td class="r">&#8370; '||fmt(r.saldo)
                     || '</td><td class="r">&#8370; '||fmt(r.venc)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="3" class="klabel">Sin deuda pendiente.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Detalle de compras (rango) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Detalle de compras</span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Fecha</th><th>Proveedor</th><th>Cond.</th><th>Estado</th>'
                   || '<th>Sucursal</th><th>Total</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT fecha_emision, proveedor, condicion, estado_label, oficina, total
      FROM WKSP_WORKPLACE.V_CMP_COMPRA
     WHERE fecha_emision >= v_desde AND fecha_emision < v_hasta1
       AND (p_proveedor IS NULL OR id_proveedor = p_proveedor)
     ORDER BY fecha_emision DESC
     FETCH FIRST 200 ROWS ONLY
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||TO_CHAR(r.fecha_emision,'dd/mm/yyyy')||'</td><td>'||r.proveedor
                     || '</td><td>'||r.condicion||'</td><td>'||r.estado_label
                     || '</td><td>'||NVL(r.oficina,'-')||'</td><td class="r">&#8370; '||fmt(r.total)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN v_html := v_html || '<tr><td colspan="6" class="klabel">Sin compras en el rango.</td></tr>'; END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Pie =====
  v_html := v_html || '<div class="kleg">Informe de control interno &mdash; m&oacute;dulo de Compras.<br>'
                   || '<i>No es un documento electr&oacute;nico (SIFEN) &mdash; sin validez fiscal.</i><br>'
                   || 'Gasto = comprobantes de proveedor no anulados (factura de compra). '
                   || 'Deuda / aging / OC abiertas: saldo actual. '
                   || 'Generado el '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'.</div></div>';

  RETURN v_html;
END FN_INFORME_COMPRAS_HTML;
/

prompt == F25.2 Verificacion ==
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
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_INFORME_COMPRAS_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_INFORME_COMPRAS_HTML VALID');

  v_clob := WKSP_WORKPLACE.FN_INFORME_COMPRAS_HTML(NULL, NULL, NULL, NULL);
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Informe Gerencial de Compras%',
      'HTML sin filtros ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
  chk(v_clob LIKE '%Gasto de compra por proveedor%', 'incluye gasto por proveedor');
  chk(v_clob LIKE '%Gasto de compra por categor%', 'incluye gasto por categoria');
  chk(v_clob LIKE '%Embudo de %rdenes de compra%', 'incluye embudo de OC');
  chk(v_clob LIKE '%Desempe%o de recepci%', 'incluye desempeno de recepcion');
  chk(v_clob LIKE '%Aging de deuda a proveedores%', 'incluye aging de deuda');
  chk(v_clob LIKE '%Detalle de compras%', 'incluye detalle de compras');

  -- rango de un mes -> desglose por dia
  v_clob := WKSP_WORKPLACE.FN_INFORME_COMPRAS_HTML(DATE '2025-11-01', DATE '2025-11-30', NULL, NULL);
  chk(v_clob LIKE '%por d%a%', 'rango <=31 dias -> desglose por dia');

  -- filtros combinados (proveedor)
  v_clob := WKSP_WORKPLACE.FN_INFORME_COMPRAS_HTML(NULL, NULL, 101, NULL);
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0, 'filtro por proveedor genera');

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== F25.2 OK ==');
  ELSE RAISE_APPLICATION_ERROR(-20947,'F25.2 con errores'); END IF;
END;
/

set define on

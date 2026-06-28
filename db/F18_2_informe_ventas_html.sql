-- ============================================================================
-- F18.2 - Informe Gerencial de Ventas imprimible (FN_INFORME_VENTAS_HTML)
-- ============================================================================
-- H4 de PLAN_REPORTES_GERENCIALES.md. Genera el HTML del Informe Gerencial de
-- Ventas. P134 (Informe Gerencial de Ventas) lo invoca con
---   RETURN FN_INFORME_VENTAS_HTML(:P134_PERIODO, :P134_OFICINA, :P134_VENDEDOR).
--
-- MISMA convencion que el arqueo (F17.1) y el KuDE (F12): documento de CONTROL
-- INTERNO, sin CDC/QR, reusa las clases visuales (kude). NO es DE SIFEN.
-- Los "graficos" del imprimible van como BARRAS CSS/HTML (divs con width:%),
-- NO JET charts (esos son JS y no entran en el HTML del servidor).
--
-- Misma fuente de datos que el Dashboard P133 (vistas V_VENTAS_* de F18.1) ->
-- los numeros coinciden con la pantalla.
--
-- Parametros (todos opcionales; NULL = sin filtrar):
--   p_periodo   'YYYY-MM' de un mes puntual, o NULL = todos los periodos.
--   p_oficina   CODIGO_OFICINA, o NULL = todas las sucursales.
--   p_vendedor  CODIGO_USUARIO (= USUARIO_CREACION), o NULL = todos.
--
-- Reusa: FN_GET_PARAMETRO (emisor) de F12. Pre-requisito: F18.1 (vistas).
-- Idempotente: CREATE OR REPLACE.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F18_2_informe_ventas_html.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F18.2 FN_INFORME_VENTAS_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_INFORME_VENTAS_HTML (
  p_periodo  IN VARCHAR2 DEFAULT NULL,
  p_oficina  IN NUMBER   DEFAULT NULL,
  p_vendedor IN VARCHAR2 DEFAULT NULL
) RETURN CLOB IS
  v_razon  VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RAZON_SOCIAL','TEXTO'),'-');
  v_ruc    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('RUC','TEXTO'),'-');
  v_dir    VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('DIRECCION','TEXTO'),'-');
  v_ciudad VARCHAR2(255) := NVL(WKSP_WORKPLACE.FN_GET_PARAMETRO('CIUDAD','TEXTO'),'-');

  v_html   CLOB;
  v_f_ofi  VARCHAR2(255);
  v_f_ven  VARCHAR2(255);
  v_max    NUMBER;
  v_any    PLS_INTEGER;

  -- KPIs
  v_neto NUMBER; v_fac NUMBER; v_tot NUMBER; v_cont NUMBER;
  v_tick NUMBER; v_pcont NUMBER; v_meta NUMBER; v_neto_m NUMBER; v_pcump NUMBER;

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
  -- Etiquetas de filtros
  IF p_oficina IS NOT NULL THEN
    BEGIN SELECT DESCRIPCION INTO v_f_ofi FROM WKSP_WORKPLACE.OFICINAS WHERE CODIGO_OFICINA = p_oficina;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_ofi := 'Oficina '||p_oficina; END;
  ELSE v_f_ofi := 'Todas las sucursales'; END IF;

  IF p_vendedor IS NOT NULL THEN
    BEGIN SELECT NOMBRE INTO v_f_ven FROM WKSP_WORKPLACE.EMPLEADOS WHERE CODIGO_USUARIO = p_vendedor;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_ven := p_vendedor; END;
  ELSE v_f_ven := 'Todos los vendedores'; END IF;

  -- KPIs (con filtros)
  SELECT NVL(SUM(neto),0) INTO v_neto
    FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES
   WHERE (p_periodo  IS NULL OR TO_CHAR(periodo,'YYYY-MM') = p_periodo)
     AND (p_oficina  IS NULL OR id_oficina = p_oficina)
     AND (p_vendedor IS NULL OR vendedor_cod = p_vendedor);

  SELECT COUNT(*), NVL(SUM(total),0), NVL(SUM(CASE WHEN es_contado='S' THEN total END),0)
    INTO v_fac, v_tot, v_cont
    FROM WKSP_WORKPLACE.V_VENTAS_FACTURA
   WHERE (p_periodo  IS NULL OR TO_CHAR(periodo,'YYYY-MM') = p_periodo)
     AND (p_oficina  IS NULL OR id_oficina = p_oficina)
     AND (p_vendedor IS NULL OR vendedor_cod = p_vendedor);

  v_tick  := CASE WHEN v_fac > 0 THEN ROUND(v_neto/v_fac) END;
  v_pcont := CASE WHEN v_tot > 0 THEN ROUND(v_cont/v_tot*100,1) END;

  SELECT NVL(SUM(monto_meta),0), NVL(SUM(neto),0) INTO v_meta, v_neto_m
    FROM WKSP_WORKPLACE.V_VENTAS_VENDEDOR_META
   WHERE monto_meta IS NOT NULL
     AND (p_periodo  IS NULL OR TO_CHAR(periodo,'YYYY-MM') = p_periodo)
     AND (p_vendedor IS NULL OR vendedor_cod = p_vendedor);
  v_pcump := CASE WHEN v_meta > 0 THEN ROUND(v_neto_m/v_meta*100,1) END;

  -- ====== Encabezado ======
  v_html := '<div class="kude"><div class="ktit">Informe Gerencial de Ventas</div>';
  v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                   || v_dir||'<br>'||v_ciudad||'<br><b>RUC:</b> '||v_ruc||'</td>';
  v_html := v_html || '<td class="r">'
                   || '<b>Per&iacute;odo:</b> '||
                      CASE WHEN p_periodo IS NULL THEN 'Todos los meses'
                           ELSE INITCAP(TO_CHAR(TO_DATE(p_periodo,'YYYY-MM'),'fmMonth','NLS_DATE_LANGUAGE=SPANISH'))
                                ||' '||SUBSTR(p_periodo,1,4) END
                   ||'<br>'
                   || '<b>Sucursal:</b> '||v_f_ofi||'<br>'
                   || '<b>Vendedor:</b> '||v_f_ven||'<br>'
                   || '<span class="klabel">Generado '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'</span>'
                   || '</td></tr></table>';

  -- ====== Resumen / KPIs ======
  v_html := v_html || '<div class="kbox"><table class="krec">'
                   || '<tr><td><span class="klabel">Facturaci&oacute;n neta</span><br><b>&#8370; '||fmt(v_neto)||'</b></td>'
                   || '<td><span class="klabel">Facturas</span><br><b>'||v_fac||'</b></td>'
                   || '<td><span class="klabel">Ticket promedio</span><br><b>&#8370; '||fmt(v_tick)||'</b></td></tr>'
                   || '<tr><td><span class="klabel">Contado</span><br><b>'||NVL(TO_CHAR(v_pcont),'-')||' %</b></td>'
                   || '<td><span class="klabel">Cr&eacute;dito</span><br><b>'||NVL(TO_CHAR(ROUND(100-v_pcont,1)),'-')||' %</b></td>'
                   || '<td><span class="klabel">Cumplimiento meta</span><br><b>'||NVL(TO_CHAR(v_pcump),'&mdash;')||' %</b></td></tr>'
                   || '</table></div>';

  -- ====== Facturacion neta por mes (barras) ======
  SELECT NVL(MAX(neto_mes),0) INTO v_max FROM (
    SELECT SUM(neto) neto_mes FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES
     WHERE (p_periodo IS NULL OR TO_CHAR(periodo,'YYYY-MM')=p_periodo)
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
     GROUP BY periodo);
  v_html := v_html || '<div class="kbox"><span class="klabel">Facturaci&oacute;n neta por mes</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT TO_CHAR(periodo,'YYYY-MM') mes, SUM(neto) neto
      FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES
     WHERE (p_periodo IS NULL OR TO_CHAR(periodo,'YYYY-MM')=p_periodo)
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
     GROUP BY periodo ORDER BY periodo
  ) LOOP
    v_html := v_html || '<tr><td class="kb-lbl">'||r.mes||'</td><td class="kb-bar">'
                     || bar(r.neto, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.neto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ====== Por sucursal (barras) ======
  SELECT NVL(MAX(s),0) INTO v_max FROM (
    SELECT SUM(neto) s FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES
     WHERE (p_periodo IS NULL OR TO_CHAR(periodo,'YYYY-MM')=p_periodo)
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
     GROUP BY oficina);
  v_html := v_html || '<div class="kbox"><span class="klabel">Facturaci&oacute;n neta por sucursal</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT NVL(oficina,'(sin oficina)') ofi, SUM(neto) neto
      FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES
     WHERE (p_periodo IS NULL OR TO_CHAR(periodo,'YYYY-MM')=p_periodo)
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
     GROUP BY oficina ORDER BY neto DESC
  ) LOOP
    v_html := v_html || '<tr><td class="kb-lbl">'||r.ofi||'</td><td class="kb-bar">'
                     || bar(r.neto, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.neto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ====== Top productos (barras) ======
  SELECT NVL(MAX(s),0) INTO v_max FROM (
    SELECT SUM(total_linea) s FROM WKSP_WORKPLACE.V_VENTAS_LINEA
     WHERE (p_periodo IS NULL OR TO_CHAR(periodo,'YYYY-MM')=p_periodo)
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
     GROUP BY producto);
  v_html := v_html || '<div class="kbox"><span class="klabel">Top productos</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT producto, SUM(total_linea) monto
      FROM WKSP_WORKPLACE.V_VENTAS_LINEA
     WHERE (p_periodo IS NULL OR TO_CHAR(periodo,'YYYY-MM')=p_periodo)
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
     GROUP BY producto ORDER BY monto DESC FETCH FIRST 10 ROWS ONLY
  ) LOOP
    v_html := v_html || '<tr><td class="kb-lbl">'||r.producto||'</td><td class="kb-bar">'
                     || bar(r.monto, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.monto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ====== Ranking vendedores vs meta (barras de cumplimiento) ======
  v_html := v_html || '<div class="kbox"><span class="klabel">Ranking de vendedores vs. meta</span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Vendedor</th><th>Neto</th><th>Meta</th><th>Cumplimiento</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT vendedor_nombre, SUM(neto) neto, SUM(monto_meta) meta,
           CASE WHEN SUM(monto_meta)>0 THEN ROUND(SUM(neto)/SUM(monto_meta)*100,1) END pct
      FROM WKSP_WORKPLACE.V_VENTAS_VENDEDOR_META
     WHERE monto_meta IS NOT NULL
       AND (p_periodo  IS NULL OR TO_CHAR(periodo,'YYYY-MM')=p_periodo)
       AND (p_vendedor IS NULL OR vendedor_cod=p_vendedor)
     GROUP BY vendedor_nombre ORDER BY pct DESC NULLS LAST
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.vendedor_nombre
                     || '</td><td class="r">&#8370; '||fmt(r.neto)
                     || '</td><td class="r">&#8370; '||fmt(r.meta)
                     || '</td><td class="kb-bar">'||bar(r.pct, 100, CASE WHEN r.pct>=100 THEN 'S' ELSE 'N' END)
                     || '<span class="kb-pct">'||NVL(TO_CHAR(r.pct),'-')||' %</span></td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="4" class="klabel">Sin metas cargadas para el filtro seleccionado.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ====== Pie ======
  v_html := v_html || '<div class="kleg">Informe gerencial de control interno &mdash; m&oacute;dulo de Ventas.<br>'
                   || '<i>No es un documento electr&oacute;nico (SIFEN) &mdash; sin validez fiscal.</i><br>'
                   || 'Facturaci&oacute;n neta = facturas activas &minus; notas de cr&eacute;dito. '
                   || 'Generado el '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'.</div></div>';

  RETURN v_html;
END FN_INFORME_VENTAS_HTML;
/

prompt == F18.2 Verificacion ==
DECLARE
  v_ok  BOOLEAN := TRUE;
  v_cnt PLS_INTEGER;
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

  v_clob := WKSP_WORKPLACE.FN_INFORME_VENTAS_HTML(NULL, NULL, NULL);
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Informe Gerencial de Ventas%',
      'HTML sin filtros ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
  chk(v_clob LIKE '%Ranking de vendedores%', 'incluye ranking vendedores');
  chk(v_clob LIKE '%class="bar%', 'incluye barras CSS');

  v_clob := WKSP_WORKPLACE.FN_INFORME_VENTAS_HTML('2025-11', NULL, 'TCASCO');
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0, 'HTML filtrado (2025-11, TCASCO) genera');

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== F18.2 OK ==');
  ELSE RAISE_APPLICATION_ERROR(-20996,'F18.2 con errores'); END IF;
END;
/

set define on

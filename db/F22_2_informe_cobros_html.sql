-- ============================================================================
-- F22.2 - Informe de Cobros imprimible por FILTROS (FN_INFORME_COBROS_HTML)
-- ============================================================================
-- Genera el HTML del Informe de Cobros parametrizado por filtros: rango de
-- fechas (cubre dia / mes / anio / rango libre), sucursal y cobrador. La pagina
-- P137 (Generador de Informe de Cobros) lo invoca con:
--   RETURN FN_INFORME_COBROS_HTML(:P137_DESDE, :P137_HASTA, :P137_OFICINA,
--                                 :P137_COBRADOR).
--
-- MISMA convencion que el Informe de Ventas (F18.2), el arqueo (F17.1) y el KuDE
-- (F12): documento de CONTROL INTERNO, sin CDC/QR, reusa las clases visuales
-- (kude). NO es DE SIFEN. "Graficos" = BARRAS CSS/HTML (divs con width:%), NO JET.
-- Misma fuente que el Dashboard P136 (vistas V_COBROS_* / V_CARTERA_CXC de F22.1).
--
-- REGLA DE ORO (F22): recaudacion neta = COBRO_CXC (ESTADO IN 'A','C') menos los
-- EGRESO de reverso, atribuidos al COBRO original (V_COBROS_REVERSO.fecha = fecha
-- del cobro original). El reverso esta OCULTO desde 2026-06-29 pero el historico
-- persiste, por eso se sigue restando.
--
-- Desglose temporal AUTOMATICO: rango <= 31 dias -> por DIA; si no -> por MES.
-- Cartera/aging/top-deudores son SNAPSHOT actual (no dependen del rango); solo
-- respetan el filtro de sucursal (la cartera no tiene cobrador).
--
-- Parametros (todos opcionales):
--   p_fecha_desde / p_fecha_hasta  rango (NULL = sin tope; ambos NULL = todo).
--   p_oficina    CODIGO_OFICINA, NULL = todas.
--   p_cobrador   USUARIO (= CODIGO_USUARIO), NULL = todos.
--
-- Reusa: FN_GET_PARAMETRO (emisor), FN_HOY/FN_AHORA (fecha local UTC-3, F19).
-- Pre-requisito: F22.1 (vistas, con V_COBROS_REVERSO.fecha y V_COBROS_MEDIO.fecha).
-- Idempotente: CREATE OR REPLACE.
-- Conexion: SQLCL_CONNECTION=tesis_db
-- Ejecucion (esta maquina): sql -S -name tesis_db < db/F22_2_informe_cobros_html.sql
-- ============================================================================
set define off
set serveroutput on

prompt == F22.2 FN_INFORME_COBROS_HTML ==
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_INFORME_COBROS_HTML (
  p_fecha_desde IN DATE     DEFAULT NULL,
  p_fecha_hasta IN DATE     DEFAULT NULL,
  p_oficina     IN NUMBER   DEFAULT NULL,
  p_cobrador    IN VARCHAR2 DEFAULT NULL
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
  v_f_cob  VARCHAR2(255);

  v_neto NUMBER; v_rec NUMBER; v_bruto NUMBER; v_efe NUMBER;
  v_tick NUMBER; v_pefe NUMBER; v_cart NUMBER; v_venc NUMBER;
  v_pvenc NUMBER; v_meta NUMBER; v_pcump NUMBER;

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
  IF p_cobrador IS NOT NULL THEN
    BEGIN SELECT nombre INTO v_f_cob FROM WKSP_WORKPLACE.EMPLEADOS WHERE codigo_usuario = p_cobrador;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_f_cob := p_cobrador; END;
  ELSE v_f_cob := 'Todos'; END IF;

  -- ===== KPIs =====
  SELECT NVL(SUM(monto),0) INTO v_neto FROM (
    SELECT mc.total monto FROM WKSP_WORKPLACE.V_COBROS_MOV mc
     WHERE mc.fecha >= v_desde AND mc.fecha < v_hasta1
       AND (p_oficina  IS NULL OR mc.id_oficina   = p_oficina)
       AND (p_cobrador IS NULL OR mc.cobrador_cod = p_cobrador)
    UNION ALL
    SELECT -rv.total_reverso FROM WKSP_WORKPLACE.V_COBROS_REVERSO rv
     WHERE rv.fecha >= v_desde AND rv.fecha < v_hasta1
       AND (p_oficina  IS NULL OR rv.id_oficina   = p_oficina)
       AND (p_cobrador IS NULL OR rv.cobrador_cod = p_cobrador)
  );

  SELECT COUNT(*) INTO v_rec FROM WKSP_WORKPLACE.V_COBROS_MOV mc
   WHERE mc.fecha >= v_desde AND mc.fecha < v_hasta1
     AND (p_oficina  IS NULL OR mc.id_oficina   = p_oficina)
     AND (p_cobrador IS NULL OR mc.cobrador_cod = p_cobrador);

  SELECT NVL(SUM(monto),0), NVL(SUM(CASE WHEN metodo_cod=1 THEN monto END),0)
    INTO v_bruto, v_efe FROM WKSP_WORKPLACE.V_COBROS_MEDIO
   WHERE fecha >= v_desde AND fecha < v_hasta1
     AND (p_oficina  IS NULL OR id_oficina   = p_oficina)
     AND (p_cobrador IS NULL OR cobrador_cod = p_cobrador);

  v_tick := CASE WHEN v_rec   > 0 THEN ROUND(v_neto/v_rec) END;
  v_pefe := CASE WHEN v_bruto > 0 THEN ROUND(v_efe/v_bruto*100,1) END;

  -- cartera: snapshot actual, filtro de sucursal (no tiene cobrador)
  SELECT NVL(SUM(monto_cuota),0), NVL(SUM(CASE WHEN por_vencer='N' THEN monto_cuota END),0)
    INTO v_cart, v_venc FROM WKSP_WORKPLACE.V_CARTERA_CXC
   WHERE (p_oficina IS NULL OR id_oficina = p_oficina);
  v_pvenc := CASE WHEN v_cart > 0 THEN ROUND(v_venc/v_cart*100,1) END;

  -- meta = suma de metas mensuales de los meses del rango (filtrada por sucursal)
  SELECT NVL(SUM(monto_meta),0) INTO v_meta FROM WKSP_WORKPLACE.METAS_COBRANZA
   WHERE periodo BETWEEN TRUNC(v_desde,'MM') AND TRUNC(v_hasta,'MM')
     AND (p_oficina IS NULL OR id_oficina = p_oficina);
  v_pcump := CASE WHEN v_meta > 0 THEN ROUND(v_neto/v_meta*100,1) END;

  -- ===== Encabezado =====
  v_html := '<div class="kude"><div class="ktit">Informe de Cobros</div>';
  v_html := v_html || '<table class="khead"><tr><td class="kemis"><b>'||v_razon||'</b><br>'
                   || v_dir||'<br>'||v_ciudad||'<br><b>RUC:</b> '||v_ruc||'</td>';
  v_html := v_html || '<td class="r">'
                   || '<b>Per&iacute;odo:</b> '
                   || CASE WHEN p_fecha_desde IS NULL AND p_fecha_hasta IS NULL THEN 'Todo el hist&oacute;rico'
                           ELSE TO_CHAR(v_desde,'dd/mm/yyyy')||' al '||TO_CHAR(v_hasta,'dd/mm/yyyy') END
                   || '<br><b>Sucursal:</b> '||v_f_ofi
                   || '<br><b>Cobrador:</b> '||v_f_cob
                   || '<br><span class="klabel">Generado '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'</span>'
                   || '</td></tr></table>';

  -- ===== KPIs =====
  v_html := v_html || '<div class="kbox"><table class="krec">'
                   || '<tr><td><span class="klabel">Recaudaci&oacute;n neta</span><br><b>&#8370; '||fmt(v_neto)||'</b></td>'
                   || '<td><span class="klabel">Recibos</span><br><b>'||v_rec||'</b></td>'
                   || '<td><span class="klabel">Cobro promedio</span><br><b>&#8370; '||fmt(v_tick)||'</b></td></tr>'
                   || '<tr><td><span class="klabel">Efectivo</span><br><b>'||NVL(TO_CHAR(v_pefe),'-')||' %</b></td>'
                   || '<td><span class="klabel">Cartera por cobrar</span><br><b>&#8370; '||fmt(v_cart)||'</b></td>'
                   || '<td><span class="klabel">Vencido</span><br><b>'||NVL(TO_CHAR(v_pvenc),'-')||' %</b></td></tr>'
                   || '<tr><td><span class="klabel">Meta del per&iacute;odo</span><br><b>'||CASE WHEN v_meta>0 THEN '&#8370; '||fmt(v_meta) ELSE '&mdash;' END||'</b></td>'
                   || '<td><span class="klabel">Cumplimiento meta</span><br><b>'||NVL(TO_CHAR(v_pcump),'&mdash;')||' %</b></td>'
                   || '<td></td></tr>'
                   || '</table></div>';

  -- ===== Recaudacion neta por dia / mes (barras) =====
  SELECT NVL(MAX(neto),0) INTO v_max FROM (
    SELECT SUM(monto) neto FROM (
      SELECT TRUNC(mc.fecha, v_fmt) b, mc.total monto FROM WKSP_WORKPLACE.V_COBROS_MOV mc
       WHERE mc.fecha >= v_desde AND mc.fecha < v_hasta1
         AND (p_oficina IS NULL OR mc.id_oficina=p_oficina)
         AND (p_cobrador IS NULL OR mc.cobrador_cod=p_cobrador)
      UNION ALL
      SELECT TRUNC(rv.fecha, v_fmt), -rv.total_reverso FROM WKSP_WORKPLACE.V_COBROS_REVERSO rv
       WHERE rv.fecha >= v_desde AND rv.fecha < v_hasta1
         AND (p_oficina IS NULL OR rv.id_oficina=p_oficina)
         AND (p_cobrador IS NULL OR rv.cobrador_cod=p_cobrador)
    ) GROUP BY b);
  v_html := v_html || '<div class="kbox"><span class="klabel">Recaudaci&oacute;n neta por '
                   || CASE v_grano WHEN 'DIA' THEN 'd&iacute;a' ELSE 'mes' END
                   || '</span><table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT b, SUM(monto) neto FROM (
      SELECT TRUNC(mc.fecha, v_fmt) b, mc.total monto FROM WKSP_WORKPLACE.V_COBROS_MOV mc
       WHERE mc.fecha >= v_desde AND mc.fecha < v_hasta1
         AND (p_oficina IS NULL OR mc.id_oficina=p_oficina)
         AND (p_cobrador IS NULL OR mc.cobrador_cod=p_cobrador)
      UNION ALL
      SELECT TRUNC(rv.fecha, v_fmt), -rv.total_reverso FROM WKSP_WORKPLACE.V_COBROS_REVERSO rv
       WHERE rv.fecha >= v_desde AND rv.fecha < v_hasta1
         AND (p_oficina IS NULL OR rv.id_oficina=p_oficina)
         AND (p_cobrador IS NULL OR rv.cobrador_cod=p_cobrador)
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
      SELECT NVL(mc.oficina,'(sin oficina)') ofi, mc.total monto FROM WKSP_WORKPLACE.V_COBROS_MOV mc
       WHERE mc.fecha >= v_desde AND mc.fecha < v_hasta1
         AND (p_oficina IS NULL OR mc.id_oficina=p_oficina)
         AND (p_cobrador IS NULL OR mc.cobrador_cod=p_cobrador)
      UNION ALL
      SELECT NVL(rv.oficina,'(sin oficina)'), -rv.total_reverso FROM WKSP_WORKPLACE.V_COBROS_REVERSO rv
       WHERE rv.fecha >= v_desde AND rv.fecha < v_hasta1
         AND (p_oficina IS NULL OR rv.id_oficina=p_oficina)
         AND (p_cobrador IS NULL OR rv.cobrador_cod=p_cobrador)
    ) GROUP BY ofi);
  v_html := v_html || '<div class="kbox"><span class="klabel">Recaudaci&oacute;n neta por sucursal</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT ofi, SUM(monto) neto FROM (
      SELECT NVL(mc.oficina,'(sin oficina)') ofi, mc.total monto FROM WKSP_WORKPLACE.V_COBROS_MOV mc
       WHERE mc.fecha >= v_desde AND mc.fecha < v_hasta1
         AND (p_oficina IS NULL OR mc.id_oficina=p_oficina)
         AND (p_cobrador IS NULL OR mc.cobrador_cod=p_cobrador)
      UNION ALL
      SELECT NVL(rv.oficina,'(sin oficina)'), -rv.total_reverso FROM WKSP_WORKPLACE.V_COBROS_REVERSO rv
       WHERE rv.fecha >= v_desde AND rv.fecha < v_hasta1
         AND (p_oficina IS NULL OR rv.id_oficina=p_oficina)
         AND (p_cobrador IS NULL OR rv.cobrador_cod=p_cobrador)
    ) GROUP BY ofi ORDER BY neto DESC
  ) LOOP
    v_html := v_html || '<tr><td class="kb-lbl">'||r.ofi||'</td><td class="kb-bar">'
                     || bar(r.neto, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.neto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Medios de cobro (barras, bruto) =====
  SELECT NVL(MAX(s),0) INTO v_max FROM (
    SELECT SUM(monto) s FROM WKSP_WORKPLACE.V_COBROS_MEDIO
     WHERE fecha >= v_desde AND fecha < v_hasta1
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_cobrador IS NULL OR cobrador_cod=p_cobrador)
     GROUP BY metodo);
  v_html := v_html || '<div class="kbox"><span class="klabel">Medios de cobro</span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  FOR r IN (
    SELECT metodo, SUM(monto) monto FROM WKSP_WORKPLACE.V_COBROS_MEDIO
     WHERE fecha >= v_desde AND fecha < v_hasta1
       AND (p_oficina IS NULL OR id_oficina=p_oficina)
       AND (p_cobrador IS NULL OR cobrador_cod=p_cobrador)
     GROUP BY metodo ORDER BY monto DESC
  ) LOOP
    v_html := v_html || '<tr><td class="kb-lbl">'||r.metodo||'</td><td class="kb-bar">'
                     || bar(r.monto, v_max)||'</td><td class="r kb-val">&#8370; '||fmt(r.monto)||'</td></tr>';
  END LOOP;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Antiguedad de la cartera (barras, snapshot) =====
  SELECT NVL(MAX(s),0) INTO v_max FROM (
    SELECT SUM(monto_cuota) s FROM WKSP_WORKPLACE.V_CARTERA_CXC
     WHERE (p_oficina IS NULL OR id_oficina=p_oficina)
     GROUP BY bucket);
  v_html := v_html || '<div class="kbox"><span class="klabel">Antig&uuml;edad de la cartera '
                   || '<i>(saldo actual al '||TO_CHAR(WKSP_WORKPLACE.FN_HOY,'dd/mm/yyyy')||')</i></span>'
                   || '<table class="kitems kbars" style="margin-top:.4em;"><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT bucket, MIN(bucket_orden) ord, SUM(monto_cuota) monto FROM WKSP_WORKPLACE.V_CARTERA_CXC
     WHERE (p_oficina IS NULL OR id_oficina=p_oficina)
     GROUP BY bucket ORDER BY ord
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td class="kb-lbl">'||r.bucket||'</td><td class="kb-bar">'
                     || bar(r.monto, v_max, CASE WHEN r.ord=0 THEN 'S' ELSE 'N' END)
                     || '</td><td class="r kb-val">&#8370; '||fmt(r.monto)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="3" class="klabel">Sin cartera pendiente.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Ranking sucursal vs meta (meta de los meses del rango) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Recaudaci&oacute;n por sucursal vs. meta '
                   || '<i>(meta de los meses del rango)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Sucursal</th><th>Neto</th><th>Meta</th><th>Cumplimiento</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT v.oficina, v.neto, NVL(m.meta,0) meta,
           CASE WHEN NVL(m.meta,0) > 0 THEN ROUND(v.neto/m.meta*100,1) END pct
    FROM (
      SELECT id_oficina, MAX(oficina) oficina, SUM(monto) neto FROM (
        SELECT mc.id_oficina, mc.oficina, mc.total monto FROM WKSP_WORKPLACE.V_COBROS_MOV mc
         WHERE mc.fecha >= v_desde AND mc.fecha < v_hasta1
           AND (p_oficina IS NULL OR mc.id_oficina=p_oficina)
           AND (p_cobrador IS NULL OR mc.cobrador_cod=p_cobrador)
        UNION ALL
        SELECT rv.id_oficina, rv.oficina, -rv.total_reverso FROM WKSP_WORKPLACE.V_COBROS_REVERSO rv
         WHERE rv.fecha >= v_desde AND rv.fecha < v_hasta1
           AND (p_oficina IS NULL OR rv.id_oficina=p_oficina)
           AND (p_cobrador IS NULL OR rv.cobrador_cod=p_cobrador)
      ) GROUP BY id_oficina
    ) v
    LEFT JOIN (
      SELECT id_oficina, SUM(monto_meta) meta FROM WKSP_WORKPLACE.METAS_COBRANZA
       WHERE periodo BETWEEN TRUNC(v_desde,'MM') AND TRUNC(v_hasta,'MM')
       GROUP BY id_oficina
    ) m ON m.id_oficina = v.id_oficina
    ORDER BY pct DESC NULLS LAST, v.neto DESC
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.oficina
                     || '</td><td class="r">&#8370; '||fmt(r.neto)
                     || '</td><td class="r">'||CASE WHEN r.meta>0 THEN '&#8370; '||fmt(r.meta) ELSE '&mdash;' END
                     || '</td><td class="kb-bar">'
                     || CASE WHEN r.pct IS NOT NULL
                             THEN bar(r.pct, 100, CASE WHEN r.pct>=100 THEN 'S' ELSE 'N' END) ELSE '' END
                     || '<span class="kb-pct">'||NVL(TO_CHAR(r.pct),'-')||' %</span></td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="4" class="klabel">Sin cobranza para el filtro seleccionado.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Top deudores (snapshot) =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Top deudores '
                   || '<i>(saldo actual)</i></span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Cliente</th><th>Saldo</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT cliente, SUM(monto_cuota) saldo FROM WKSP_WORKPLACE.V_CARTERA_CXC
     WHERE (p_oficina IS NULL OR id_oficina=p_oficina)
     GROUP BY cliente ORDER BY saldo DESC FETCH FIRST 10 ROWS ONLY
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||r.cliente||'</td><td class="r">&#8370; '||fmt(r.saldo)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="2" class="klabel">Sin deudores.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Detalle de recibos del rango =====
  v_html := v_html || '<div class="kbox"><span class="klabel">Detalle de recibos</span>'
                   || '<table class="kitems" style="margin-top:.4em;"><thead><tr>'
                   || '<th>Fecha</th><th>Recibo</th><th>Cobrador</th><th>Cliente</th>'
                   || '<th>Total</th></tr></thead><tbody>';
  v_any := 0;
  FOR r IN (
    SELECT mc.fecha, mc.nro_recibo, mc.cobrador_nombre, mc.cliente, mc.total
      FROM WKSP_WORKPLACE.V_COBROS_MOV mc
     WHERE mc.fecha >= v_desde AND mc.fecha < v_hasta1
       AND (p_oficina IS NULL OR mc.id_oficina=p_oficina)
       AND (p_cobrador IS NULL OR mc.cobrador_cod=p_cobrador)
     ORDER BY mc.fecha, mc.nro_recibo
     FETCH FIRST 200 ROWS ONLY
  ) LOOP
    v_any := v_any + 1;
    v_html := v_html || '<tr><td>'||TO_CHAR(r.fecha,'dd/mm/yyyy')
                     || '</td><td>'||r.nro_recibo
                     || '</td><td>'||r.cobrador_nombre
                     || '</td><td>'||r.cliente
                     || '</td><td class="r">&#8370; '||fmt(r.total)||'</td></tr>';
  END LOOP;
  IF v_any = 0 THEN
    v_html := v_html || '<tr><td colspan="5" class="klabel">Sin recibos en el rango.</td></tr>';
  END IF;
  v_html := v_html || '</tbody></table></div>';

  -- ===== Pie =====
  v_html := v_html || '<div class="kleg">Informe de control interno &mdash; m&oacute;dulo de Cobros.<br>'
                   || '<i>No es un documento electr&oacute;nico (SIFEN) &mdash; sin validez fiscal.</i><br>'
                   || 'Recaudaci&oacute;n neta = cobros de CxC &minus; reversos. '
                   || 'Cartera y deudores: saldo actual. '
                   || 'Generado el '||TO_CHAR(WKSP_WORKPLACE.FN_AHORA,'dd/mm/yyyy hh24:mi')||'.</div></div>';

  RETURN v_html;
END FN_INFORME_COBROS_HTML;
/

prompt == F22.2 Verificacion ==
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
   WHERE owner='WKSP_WORKPLACE' AND object_name='FN_INFORME_COBROS_HTML'
     AND object_type='FUNCTION' AND status='VALID';
  chk(v_cnt = 1, 'FUNCTION FN_INFORME_COBROS_HTML VALID');

  v_clob := WKSP_WORKPLACE.FN_INFORME_COBROS_HTML(NULL, NULL, NULL, NULL);
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0 AND v_clob LIKE '%Informe de Cobros%',
      'HTML sin filtros ('||DBMS_LOB.GETLENGTH(v_clob)||' chars)');
  chk(v_clob LIKE '%Detalle de recibos%', 'incluye detalle de recibos');
  chk(v_clob LIKE '%Antig%edad de la cartera%', 'incluye aging de cartera');
  chk(v_clob LIKE '%Medios de cobro%', 'incluye medios de cobro');

  -- rango de un mes (jun-2026), por dia
  v_clob := WKSP_WORKPLACE.FN_INFORME_COBROS_HTML(DATE '2026-06-01', DATE '2026-06-30', NULL, NULL);
  chk(v_clob LIKE '%Recaudaci%n neta por d%', 'rango <=31 dias -> desglose por dia');

  -- filtros combinados (sucursal + cobrador)
  v_clob := WKSP_WORKPLACE.FN_INFORME_COBROS_HTML(DATE '2026-06-01', DATE '2026-06-30', 1, 'TCASCO');
  chk(DBMS_LOB.GETLENGTH(v_clob) > 0, 'filtros combinados (sucursal + cobrador) genera');

  IF v_ok THEN DBMS_OUTPUT.PUT_LINE('== F22.2 OK ==');
  ELSE RAISE_APPLICATION_ERROR(-20906,'F22.2 con errores'); END IF;
END;
/

set define on

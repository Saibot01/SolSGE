prompt --application/pages/page_00136
begin
--   Manifest
--     PAGE: 00136
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.17'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_page.create_page(
 p_id=>136
,p_name=>'Dashboard de Cobros'
,p_alias=>'DASHBOARD-COBROS'
,p_step_title=>'Dashboard de Cobros'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Dashboard de Cobros (F22 - Reportes Gerenciales) */',
'.dv-kpis { display:flex; flex-wrap:wrap; gap:14px; margin:6px 0; }',
'.dv-kpi { flex:1 1 180px; background:#fff; border:1px solid #e3e3e3;',
'          border-left:5px solid #00695c; border-radius:.4em; padding:14px 16px;',
'          box-shadow:0 1px 2px rgba(0,0,0,.05); }',
'.dv-kpi .dv-lbl { color:#666; font-size:.78rem; text-transform:uppercase;',
'                  letter-spacing:.05em; }',
'.dv-kpi .dv-val { font-size:1.55rem; font-weight:700; color:#00695c;',
'                  margin-top:.2em; line-height:1.1; }',
'.dv-kpi .dv-sub { color:#888; font-size:.75rem; margin-top:.25em; }',
'.dv-kpi.ok   { border-left-color:#2e7d32; } .dv-kpi.ok   .dv-val { color:#2e7d32; }',
'.dv-kpi.warn { border-left-color:#c62828; } .dv-kpi.warn .dv-val { color:#c62828; }'))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000136005)
,p_plug_name=>'Filtros'
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_point=>'BODY'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000136006)
,p_name=>'P136_PERIODO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000136005)
,p_prompt=>'Mes'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DISTINCT',
'   INITCAP(TO_CHAR(periodo,''fmMonth'',''NLS_DATE_LANGUAGE=SPANISH''))||'' ''||TO_CHAR(periodo,''YYYY'') d,',
'   TO_CHAR(periodo,''YYYY-MM'') r',
'  FROM WKSP_WORKPLACE.V_COBROS_NETO_MES',
' ORDER BY 2 DESC'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Todos los meses'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000136010)
,p_plug_name=>'Resumen de Cobros'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_ajax_items_to_submit=>'P136_PERIODO'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l        VARCHAR2(32767);',
'  v_neto   NUMBER; v_rec NUMBER; v_tick NUMBER;',
'  v_bruto  NUMBER; v_efe NUMBER; v_pefe NUMBER;',
'  v_cart   NUMBER; v_venc NUMBER; v_pvenc NUMBER;',
'  v_meta   NUMBER; v_neto_m NUMBER; v_pcump NUMBER;',
'  FUNCTION g(p NUMBER) RETURN VARCHAR2 IS',
'  BEGIN',
'    RETURN TO_CHAR(NVL(p,0),''FM999G999G999G990'',''NLS_NUMERIC_CHARACTERS=,.'');',
'  END;',
'BEGIN',
'  SELECT NVL(SUM(neto),0), NVL(SUM(recibos),0) INTO v_neto, v_rec',
'    FROM WKSP_WORKPLACE.V_COBROS_NETO_MES',
'   WHERE (:P136_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'')=:P136_PERIODO);',
'  v_tick := CASE WHEN v_rec>0 THEN ROUND(v_neto/v_rec) END;',
'  SELECT NVL(SUM(monto),0), NVL(SUM(CASE WHEN metodo_cod=1 THEN monto END),0)',
'    INTO v_bruto, v_efe FROM WKSP_WORKPLACE.V_COBROS_MEDIO',
'   WHERE (:P136_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'')=:P136_PERIODO);',
'  v_pefe := CASE WHEN v_bruto>0 THEN ROUND(v_efe/v_bruto*100,1) END;',
'  -- cartera: snapshot actual, no depende del mes',
'  SELECT NVL(SUM(monto_cuota),0), NVL(SUM(CASE WHEN por_vencer=''N'' THEN monto_cuota END),0)',
'    INTO v_cart, v_venc FROM WKSP_WORKPLACE.V_CARTERA_CXC;',
'  v_pvenc := CASE WHEN v_cart>0 THEN ROUND(v_venc/v_cart*100,1) END;',
'  -- cumplimiento de meta del periodo (oficinas con meta)',
'  SELECT NVL(SUM(monto_meta),0), NVL(SUM(neto),0)',
'    INTO v_meta, v_neto_m FROM WKSP_WORKPLACE.V_COBROS_OFICINA_META',
'   WHERE monto_meta IS NOT NULL',
'     AND (:P136_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'')=:P136_PERIODO);',
'  v_pcump := CASE WHEN v_meta>0 THEN ROUND(v_neto_m/v_meta*100,1) END;',
'',
'  l := ''<div class="dv-kpis">'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Recaudaci''||unistr(''\00F3'')||''n neta</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_neto)||''</div>''||',
'       ''<div class="dv-sub">cobros ''||unistr(''\2212'')||'' reversos</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Recibos</div>''||',
'       ''<div class="dv-val">''||v_rec||''</div>''||',
'       ''<div class="dv-sub">cobros de CxC</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Cobro promedio</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_tick)||''</div>''||',
'       ''<div class="dv-sub">neto / recibo</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Efectivo</div>''||',
'       ''<div class="dv-val">''||TO_CHAR(NVL(v_pefe,0),''FM990D0'',''NLS_NUMERIC_CHARACTERS=,.'')||'' %</div>''||',
'       ''<div class="dv-sub">del bruto cobrado</div></div>'';',
'  l := l||''<div class="dv-kpi ''||CASE WHEN v_pvenc>0 THEN ''warn'' ELSE '''' END||''">''||',
'       ''<div class="dv-lbl">Cartera por cobrar</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_cart)||''</div>''||',
'       ''<div class="dv-sub">''||TO_CHAR(NVL(v_pvenc,0),''FM990D0'',''NLS_NUMERIC_CHARACTERS=,.'')||'' % vencido</div></div>'';',
'  l := l||''<div class="dv-kpi ''||CASE WHEN v_pcump>=100 THEN ''ok'' WHEN v_pcump IS NULL THEN '''' ELSE ''warn'' END||''">''||',
'       ''<div class="dv-lbl">Cumplimiento meta</div>''||',
'       ''<div class="dv-val">''||CASE WHEN v_pcump IS NULL THEN unistr(''\2014'') ELSE TO_CHAR(v_pcump,''FM999G990D0'',''NLS_NUMERIC_CHARACTERS=,.'')||'' %'' END||''</div>''||',
'       ''<div class="dv-sub">neto vs. meta de sucursal</div></div>'';',
'  l := l||''</div>'';',
'  RETURN l;',
'EXCEPTION WHEN OTHERS THEN',
'  RETURN ''<div style="color:#b00020">KPI region error: ''||SQLERRM||''</div>'';',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
--==================== Chart 1: Recaudacion neta por mes (bar) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000136020)
,p_plug_name=>unistr('Recaudaci\00F3n neta por mes')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000136021)
,p_region_id=>wwv_flow_imp.id(36000000000136020)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000136022)
,p_chart_id=>wwv_flow_imp.id(36000000000136021)
,p_seq=>10
,p_name=>'Neto'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P136_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT TO_CHAR(periodo,''YYYY-MM'') AS d_label,',
'       SUM(neto)                  AS d_value',
'  FROM WKSP_WORKPLACE.V_COBROS_NETO_MES',
' WHERE (:P136_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P136_PERIODO)',
' GROUP BY periodo',
' ORDER BY periodo'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136023)
,p_chart_id=>wwv_flow_imp.id(36000000000136021)
,p_axis=>'x'
,p_title=>'Mes'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136024)
,p_chart_id=>wwv_flow_imp.id(36000000000136021)
,p_axis=>'y'
,p_title=>unistr('Guaran\00EDes')
,p_format_type=>'decimal'
);
--==================== Chart 2: Recaudacion por sucursal (bar) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000136030)
,p_plug_name=>unistr('Recaudaci\00F3n neta por sucursal')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000136031)
,p_region_id=>wwv_flow_imp.id(36000000000136030)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000136032)
,p_chart_id=>wwv_flow_imp.id(36000000000136031)
,p_seq=>10
,p_name=>'Neto'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P136_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT NVL(oficina,''(sin oficina)'') AS d_label,',
'       SUM(neto)                      AS d_value',
'  FROM WKSP_WORKPLACE.V_COBROS_NETO_MES',
' WHERE (:P136_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P136_PERIODO)',
' GROUP BY oficina',
' ORDER BY d_value DESC'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136033)
,p_chart_id=>wwv_flow_imp.id(36000000000136031)
,p_axis=>'x'
,p_title=>'Sucursal'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136034)
,p_chart_id=>wwv_flow_imp.id(36000000000136031)
,p_axis=>'y'
,p_format_type=>'decimal'
);
--==================== Chart 3: Medios de cobro (donut) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000136040)
,p_plug_name=>'Medios de cobro'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000136041)
,p_region_id=>wwv_flow_imp.id(36000000000136040)
,p_chart_type=>'donut'
,p_height=>'380'
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000136042)
,p_chart_id=>wwv_flow_imp.id(36000000000136041)
,p_seq=>10
,p_name=>'Medio'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P136_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT metodo     AS d_label,',
'       SUM(monto) AS d_value',
'  FROM WKSP_WORKPLACE.V_COBROS_MEDIO',
' WHERE (:P136_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P136_PERIODO)',
' GROUP BY metodo',
' ORDER BY d_value DESC'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
--==================== Chart 4: Aging de cartera (bar, snapshot) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000136050)
,p_plug_name=>unistr('Antig\00FCedad de la cartera')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000136051)
,p_region_id=>wwv_flow_imp.id(36000000000136050)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000136052)
,p_chart_id=>wwv_flow_imp.id(36000000000136051)
,p_seq=>10
,p_name=>'Saldo'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT bucket          AS d_label,',
'       SUM(monto_cuota) AS d_value',
'  FROM WKSP_WORKPLACE.V_CARTERA_CXC',
' GROUP BY bucket, bucket_orden',
' ORDER BY bucket_orden'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136053)
,p_chart_id=>wwv_flow_imp.id(36000000000136051)
,p_axis=>'x'
,p_title=>unistr('Antig\00FCedad')
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136054)
,p_chart_id=>wwv_flow_imp.id(36000000000136051)
,p_axis=>'y'
,p_format_type=>'decimal'
);
--==================== Chart 5: Top deudores (bar horizontal, snapshot) ============
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000136060)
,p_plug_name=>'Top deudores'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000136061)
,p_region_id=>wwv_flow_imp.id(36000000000136060)
,p_chart_type=>'bar'
,p_orientation=>'horizontal'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000136062)
,p_chart_id=>wwv_flow_imp.id(36000000000136061)
,p_seq=>10
,p_name=>'Saldo'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT cliente         AS d_label,',
'       SUM(monto_cuota) AS d_value',
'  FROM WKSP_WORKPLACE.V_CARTERA_CXC',
' GROUP BY cliente',
' ORDER BY d_value DESC',
' FETCH FIRST 10 ROWS ONLY'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136063)
,p_chart_id=>wwv_flow_imp.id(36000000000136061)
,p_axis=>'x'
,p_title=>'Cliente'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136064)
,p_chart_id=>wwv_flow_imp.id(36000000000136061)
,p_axis=>'y'
,p_format_type=>'decimal'
);
--==================== Chart 6: Recaudacion por sucursal vs meta (bar, 2 series) ====
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000136070)
,p_plug_name=>unistr('Recaudaci\00F3n por sucursal vs. meta')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000136071)
,p_region_id=>wwv_flow_imp.id(36000000000136070)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000136072)
,p_chart_id=>wwv_flow_imp.id(36000000000136071)
,p_seq=>10
,p_name=>'Neto'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P136_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT oficina   AS d_label,',
'       SUM(neto) AS d_value',
'  FROM WKSP_WORKPLACE.V_COBROS_OFICINA_META',
' WHERE monto_meta IS NOT NULL',
'   AND (:P136_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P136_PERIODO)',
' GROUP BY oficina',
' ORDER BY d_value DESC'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000136073)
,p_chart_id=>wwv_flow_imp.id(36000000000136071)
,p_seq=>20
,p_name=>'Meta'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P136_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT oficina        AS d_label,',
'       SUM(monto_meta) AS d_value',
'  FROM WKSP_WORKPLACE.V_COBROS_OFICINA_META',
' WHERE monto_meta IS NOT NULL',
'   AND (:P136_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P136_PERIODO)',
' GROUP BY oficina'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136074)
,p_chart_id=>wwv_flow_imp.id(36000000000136071)
,p_axis=>'x'
,p_title=>'Sucursal'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000136075)
,p_chart_id=>wwv_flow_imp.id(36000000000136071)
,p_axis=>'y'
,p_format_type=>'decimal'
);
--==================== Reporte: Detalle de recibos (cobros) ====================
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000136080)
,p_name=>'Detalle de recibos'
,p_template=>4072358936313175081
,p_display_sequence=>80
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight:t-Report--staticRowColors'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT nro_recibo,',
'       TO_CHAR(fecha,''DD/MM/YYYY'') AS fecha,',
'       oficina,',
'       cobrador_nombre,',
'       cliente,',
'       total',
'  FROM WKSP_WORKPLACE.V_COBROS_MOV',
' WHERE (:P136_PERIODO IS NULL OR TO_CHAR(fecha,''YYYY-MM'') = :P136_PERIODO)',
' ORDER BY fecha DESC, nro_recibo'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P136_PERIODO'
,p_lazy_loading=>false
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_num_rows=>15
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>500
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000136081)
,p_query_column_id=>1
,p_column_alias=>'NRO_RECIBO'
,p_column_display_sequence=>1
,p_column_heading=>unistr('N\00B0 Recibo')
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000136082)
,p_query_column_id=>2
,p_column_alias=>'FECHA'
,p_column_display_sequence=>2
,p_column_heading=>'Fecha'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000136083)
,p_query_column_id=>3
,p_column_alias=>'OFICINA'
,p_column_display_sequence=>3
,p_column_heading=>'Sucursal'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000136084)
,p_query_column_id=>4
,p_column_alias=>'COBRADOR_NOMBRE'
,p_column_display_sequence=>4
,p_column_heading=>'Cobrador'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000136085)
,p_query_column_id=>5
,p_column_alias=>'CLIENTE'
,p_column_display_sequence=>5
,p_column_heading=>'Cliente'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000136086)
,p_query_column_id=>6
,p_column_alias=>'TOTAL'
,p_column_display_sequence=>6
,p_column_heading=>'Total cobrado'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_column_format=>'FML999G999G999G990'
);
--==================== Boton: Imprimir informe (-> P137) ====================
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000136015)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000136010)
,p_button_name=>'IMPRIMIR_INFORME'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Generar informe imprimible'
,p_button_position=>'RIGHT_OF_TITLE'
,p_button_redirect_url=>'f?p=&APP_ID.:137:&APP_SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-print'
);
--==================== DA: al cambiar el Mes, refrescar regiones por periodo =======
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000136090)
,p_name=>'Cambio de Mes - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P136_PERIODO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000136091)
,p_event_id=>wwv_flow_imp.id(36000000000136090)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000136010)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000136092)
,p_event_id=>wwv_flow_imp.id(36000000000136090)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000136020)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000136093)
,p_event_id=>wwv_flow_imp.id(36000000000136090)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000136030)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000136094)
,p_event_id=>wwv_flow_imp.id(36000000000136090)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000136040)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000136095)
,p_event_id=>wwv_flow_imp.id(36000000000136090)
,p_event_result=>'TRUE'
,p_action_sequence=>50
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000136070)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000136096)
,p_event_id=>wwv_flow_imp.id(36000000000136090)
,p_event_result=>'TRUE'
,p_action_sequence=>60
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000136080)
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00133
begin
--   Manifest
--     PAGE: 00133
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
 p_id=>133
,p_name=>'Dashboard de Ventas'
,p_alias=>'DASHBOARD-VENTAS'
,p_step_title=>'Dashboard de Ventas'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Dashboard de Ventas (F18 - Reportes Gerenciales) */',
'.dv-kpis { display:flex; flex-wrap:wrap; gap:14px; margin:6px 0; }',
'.dv-kpi { flex:1 1 180px; background:#fff; border:1px solid #e3e3e3;',
'          border-left:5px solid #1b3a5b; border-radius:.4em; padding:14px 16px;',
'          box-shadow:0 1px 2px rgba(0,0,0,.05); }',
'.dv-kpi .dv-lbl { color:#666; font-size:.78rem; text-transform:uppercase;',
'                  letter-spacing:.05em; }',
'.dv-kpi .dv-val { font-size:1.55rem; font-weight:700; color:#1b3a5b;',
'                  margin-top:.2em; line-height:1.1; }',
'.dv-kpi .dv-sub { color:#888; font-size:.75rem; margin-top:.25em; }',
'.dv-kpi.ok   { border-left-color:#2e7d32; } .dv-kpi.ok   .dv-val { color:#2e7d32; }',
'.dv-kpi.warn { border-left-color:#c62828; } .dv-kpi.warn .dv-val { color:#c62828; }'))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000133005)
,p_plug_name=>'Filtros'
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_point=>'BODY'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000133006)
,p_name=>'P133_PERIODO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000133005)
,p_prompt=>'Mes'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DISTINCT',
'   INITCAP(TO_CHAR(periodo,''fmMonth'',''NLS_DATE_LANGUAGE=SPANISH''))||'' ''||TO_CHAR(periodo,''YYYY'') d,',
'   TO_CHAR(periodo,''YYYY-MM'') r',
'  FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES',
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
 p_id=>wwv_flow_imp.id(36000000000133010)
,p_plug_name=>'Resumen de Ventas'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_ajax_items_to_submit=>'P133_PERIODO'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l   VARCHAR2(32767);',
'  v_neto   NUMBER; v_fac NUMBER; v_tick NUMBER;',
'  v_cont   NUMBER; v_tot NUMBER; v_pcont NUMBER;',
'  v_meta   NUMBER; v_neto_m NUMBER; v_pcump NUMBER;',
'  FUNCTION g(p NUMBER) RETURN VARCHAR2 IS',
'  BEGIN',
'    RETURN TO_CHAR(NVL(p,0),''FM999G999G999G990'',''NLS_NUMERIC_CHARACTERS=,.'');',
'  END;',
'BEGIN',
'  SELECT NVL(SUM(neto),0) INTO v_neto FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES',
'   WHERE (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'')=:P133_PERIODO);',
'  SELECT COUNT(*), NVL(SUM(total),0),',
'         NVL(SUM(CASE WHEN es_contado=''S'' THEN total END),0)',
'    INTO v_fac, v_tot, v_cont FROM WKSP_WORKPLACE.V_VENTAS_FACTURA',
'   WHERE (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'')=:P133_PERIODO);',
'  v_tick  := CASE WHEN v_fac>0 THEN ROUND(v_neto/v_fac) END;',
'  v_pcont := CASE WHEN v_tot>0 THEN ROUND(v_cont/v_tot*100,1) END;',
'  -- cumplimiento global sobre los periodos/vendedores que tienen meta',
'  SELECT NVL(SUM(monto_meta),0), NVL(SUM(neto),0)',
'    INTO v_meta, v_neto_m FROM WKSP_WORKPLACE.V_VENTAS_VENDEDOR_META',
'   WHERE monto_meta IS NOT NULL',
'     AND (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'')=:P133_PERIODO);',
'  v_pcump := CASE WHEN v_meta>0 THEN ROUND(v_neto_m/v_meta*100,1) END;',
'',
'  l := ''<div class="dv-kpis">'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Facturaci''||unistr(''\00F3'')||''n neta</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_neto)||''</div>''||',
'       ''<div class="dv-sub">FA activas ''||unistr(''\2212'')||'' NC</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Facturas</div>''||',
'       ''<div class="dv-val">''||v_fac||''</div>''||',
'       ''<div class="dv-sub">comprobantes FA activos</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Ticket promedio</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_tick)||''</div>''||',
'       ''<div class="dv-sub">neto / factura</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Contado</div>''||',
'       ''<div class="dv-val">''||TO_CHAR(NVL(v_pcont,0),''FM990D0'',''NLS_NUMERIC_CHARACTERS=,.'')||'' %</div>''||',
'       ''<div class="dv-sub">del monto facturado</div></div>'';',
'  l := l||''<div class="dv-kpi ''||CASE WHEN v_pcump>=100 THEN ''ok'' WHEN v_pcump IS NULL THEN '''' ELSE ''warn'' END||''">''||',
'       ''<div class="dv-lbl">Cumplimiento meta</div>''||',
'       ''<div class="dv-val">''||CASE WHEN v_pcump IS NULL THEN unistr(''\2014'') ELSE TO_CHAR(v_pcump,''FM999G990D0'',''NLS_NUMERIC_CHARACTERS=,.'')||'' %'' END||''</div>''||',
'       ''<div class="dv-sub">neto vs. meta (per''||unistr(''\00ED'')||''odos con meta)</div></div>'';',
'  l := l||''</div>'';',
'  RETURN l;',
'EXCEPTION WHEN OTHERS THEN',
'  RETURN ''<div style="color:#b00020">KPI region error: ''||SQLERRM||''</div>'';',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000133020)
,p_plug_name=>unistr('Facturaci\00F3n neta por mes')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000133021)
,p_region_id=>wwv_flow_imp.id(36000000000133020)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000133022)
,p_chart_id=>wwv_flow_imp.id(36000000000133021)
,p_seq=>10
,p_name=>'Neto'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P133_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT TO_CHAR(periodo,''YYYY-MM'') AS d_label,',
'       SUM(neto)               AS d_value',
'  FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES',
' WHERE (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P133_PERIODO)',
' GROUP BY periodo',
' ORDER BY periodo'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133023)
,p_chart_id=>wwv_flow_imp.id(36000000000133021)
,p_axis=>'x'
,p_title=>'Mes'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133024)
,p_chart_id=>wwv_flow_imp.id(36000000000133021)
,p_axis=>'y'
,p_title=>unistr('Guaran\00EDes')
,p_format_type=>'decimal'
);
--==================== Chart 2: Facturacion por sucursal (bar) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000133030)
,p_plug_name=>unistr('Facturaci\00F3n neta por sucursal')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000133031)
,p_region_id=>wwv_flow_imp.id(36000000000133030)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000133032)
,p_chart_id=>wwv_flow_imp.id(36000000000133031)
,p_seq=>10
,p_name=>'Neto'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P133_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT NVL(oficina,''(sin oficina)'') AS d_label,',
'       SUM(neto)                      AS d_value',
'  FROM WKSP_WORKPLACE.V_VENTAS_NETA_MES',
' WHERE (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P133_PERIODO)',
' GROUP BY oficina',
' ORDER BY d_value DESC'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133033)
,p_chart_id=>wwv_flow_imp.id(36000000000133031)
,p_axis=>'x'
,p_title=>'Sucursal'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133034)
,p_chart_id=>wwv_flow_imp.id(36000000000133031)
,p_axis=>'y'
,p_format_type=>'decimal'
);
--==================== Chart 3: Contado vs Credito (donut) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000133040)
,p_plug_name=>unistr('Contado vs. Cr\00E9dito')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000133041)
,p_region_id=>wwv_flow_imp.id(36000000000133040)
,p_chart_type=>'donut'
,p_height=>'380'
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000133042)
,p_chart_id=>wwv_flow_imp.id(36000000000133041)
,p_seq=>10
,p_name=>unistr('Condici\00F3n')
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P133_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT condicion AS d_label,',
'       SUM(total) AS d_value',
'  FROM WKSP_WORKPLACE.V_VENTAS_FACTURA',
' WHERE (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P133_PERIODO)',
' GROUP BY condicion'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
--==================== Chart 4: Top productos (bar horizontal) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000133050)
,p_plug_name=>'Top productos'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000133051)
,p_region_id=>wwv_flow_imp.id(36000000000133050)
,p_chart_type=>'bar'
,p_orientation=>'horizontal'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000133052)
,p_chart_id=>wwv_flow_imp.id(36000000000133051)
,p_seq=>10
,p_name=>'Facturado'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P133_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT producto AS d_label,',
'       SUM(total_linea) AS d_value',
'  FROM WKSP_WORKPLACE.V_VENTAS_LINEA',
' WHERE (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P133_PERIODO)',
' GROUP BY producto',
' ORDER BY d_value DESC',
' FETCH FIRST 10 ROWS ONLY'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133053)
,p_chart_id=>wwv_flow_imp.id(36000000000133051)
,p_axis=>'x'
,p_title=>'Producto'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133054)
,p_chart_id=>wwv_flow_imp.id(36000000000133051)
,p_axis=>'y'
,p_format_type=>'decimal'
);
--==================== Chart 5: Vendedor vs Meta (bar, 2 series) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000133060)
,p_plug_name=>'Ventas por vendedor vs. meta'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000133061)
,p_region_id=>wwv_flow_imp.id(36000000000133060)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000133062)
,p_chart_id=>wwv_flow_imp.id(36000000000133061)
,p_seq=>10
,p_name=>'Neto'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P133_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT vendedor_nombre AS d_label,',
'       SUM(neto)       AS d_value',
'  FROM WKSP_WORKPLACE.V_VENTAS_VENDEDOR_META',
' WHERE monto_meta IS NOT NULL',
'   AND (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P133_PERIODO)',
' GROUP BY vendedor_nombre',
' ORDER BY d_value DESC'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000133063)
,p_chart_id=>wwv_flow_imp.id(36000000000133061)
,p_seq=>20
,p_name=>'Meta'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P133_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT vendedor_nombre AS d_label,',
'       SUM(monto_meta)  AS d_value',
'  FROM WKSP_WORKPLACE.V_VENTAS_VENDEDOR_META',
' WHERE monto_meta IS NOT NULL',
'   AND (:P133_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P133_PERIODO)',
' GROUP BY vendedor_nombre'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133064)
,p_chart_id=>wwv_flow_imp.id(36000000000133061)
,p_axis=>'x'
,p_title=>'Vendedor'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133065)
,p_chart_id=>wwv_flow_imp.id(36000000000133061)
,p_axis=>'y'
,p_format_type=>'decimal'
);
--==================== Chart 6: Embudo presupuesto -> factura (bar, estados) ========
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000133070)
,p_plug_name=>unistr('Embudo Presupuesto \2192 Factura')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000133071)
,p_region_id=>wwv_flow_imp.id(36000000000133070)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000133072)
,p_chart_id=>wwv_flow_imp.id(36000000000133071)
,p_seq=>10
,p_name=>unistr('\00D3rdenes')
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P133_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT estado     AS d_label,',
'       COUNT(*)   AS d_value',
'  FROM WKSP_WORKPLACE.ORDENES_VENTA',
' WHERE (:P133_PERIODO IS NULL OR TO_CHAR(FECHA_ORDEN,''YYYY-MM'') = :P133_PERIODO)',
' GROUP BY estado',
' ORDER BY d_value DESC'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133073)
,p_chart_id=>wwv_flow_imp.id(36000000000133071)
,p_axis=>'x'
,p_title=>'Estado'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000133074)
,p_chart_id=>wwv_flow_imp.id(36000000000133071)
,p_axis=>'y'
,p_title=>'Cantidad'
);
--==================== Reporte: Detalle de ventas (facturas) ====================
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000133080)
,p_name=>'Detalle de ventas (facturas)'
,p_template=>4072358936313175081
,p_display_sequence=>80
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight:t-Report--staticRowColors'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT nro_comprobante,',
'       TO_CHAR(fecha,''DD/MM/YYYY'') AS fecha,',
'       oficina,',
'       vendedor_nombre,',
'       cliente,',
'       condicion,',
'       total',
'  FROM WKSP_WORKPLACE.V_VENTAS_FACTURA',
' WHERE (:P133_PERIODO IS NULL OR TO_CHAR(fecha,''YYYY-MM'') = :P133_PERIODO)',
' ORDER BY fecha DESC, nro_comprobante'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P133_PERIODO'
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
 p_id=>wwv_flow_imp.id(36000000000133081)
,p_query_column_id=>1
,p_column_alias=>'NRO_COMPROBANTE'
,p_column_display_sequence=>1
,p_column_heading=>unistr('N\00B0 Comprobante')
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000133082)
,p_query_column_id=>2
,p_column_alias=>'FECHA'
,p_column_display_sequence=>2
,p_column_heading=>'Fecha'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000133083)
,p_query_column_id=>3
,p_column_alias=>'OFICINA'
,p_column_display_sequence=>3
,p_column_heading=>'Sucursal'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000133084)
,p_query_column_id=>4
,p_column_alias=>'VENDEDOR_NOMBRE'
,p_column_display_sequence=>4
,p_column_heading=>'Vendedor'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000133085)
,p_query_column_id=>5
,p_column_alias=>'CLIENTE'
,p_column_display_sequence=>5
,p_column_heading=>'Cliente'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000133086)
,p_query_column_id=>6
,p_column_alias=>'CONDICION'
,p_column_display_sequence=>6
,p_column_heading=>unistr('Condici\00F3n')
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000133087)
,p_query_column_id=>7
,p_column_alias=>'TOTAL'
,p_column_display_sequence=>7
,p_column_heading=>'Total'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_column_format=>'FML999G999G999G990'
);
--==================== Boton: Imprimir informe (-> P134 modal) ====================
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000133015)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000133010)
,p_button_name=>'IMPRIMIR_INFORME'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Generar informe imprimible'
,p_button_position=>'RIGHT_OF_TITLE'
,p_button_redirect_url=>'f?p=&APP_ID.:135:&APP_SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-print'
);
--==================== DA: al cambiar el Mes, refrescar todas las regiones ========
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000133090)
,p_name=>'Cambio de Mes - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P133_PERIODO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000133091)
,p_event_id=>wwv_flow_imp.id(36000000000133090)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000133010)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000133092)
,p_event_id=>wwv_flow_imp.id(36000000000133090)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000133020)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000133093)
,p_event_id=>wwv_flow_imp.id(36000000000133090)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000133030)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000133094)
,p_event_id=>wwv_flow_imp.id(36000000000133090)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000133040)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000133095)
,p_event_id=>wwv_flow_imp.id(36000000000133090)
,p_event_result=>'TRUE'
,p_action_sequence=>50
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000133050)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000133096)
,p_event_id=>wwv_flow_imp.id(36000000000133090)
,p_event_result=>'TRUE'
,p_action_sequence=>60
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000133060)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000133097)
,p_event_id=>wwv_flow_imp.id(36000000000133090)
,p_event_result=>'TRUE'
,p_action_sequence=>70
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000133070)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000133098)
,p_event_id=>wwv_flow_imp.id(36000000000133090)
,p_event_result=>'TRUE'
,p_action_sequence=>80
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000133080)
);
wwv_flow_imp.component_end;
end;
/

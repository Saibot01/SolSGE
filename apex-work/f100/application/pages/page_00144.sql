prompt --application/pages/page_00144
begin
--   Manifest
--     PAGE: 00144
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
 p_id=>144
,p_name=>'Dashboard de Compras'
,p_alias=>'DASHBOARD-COMPRAS'
,p_step_title=>'Dashboard de Compras'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Dashboard de Compras (F25 - Reportes Gerenciales) */',
'.dv-kpis { display:flex; flex-wrap:wrap; gap:14px; margin:6px 0; }',
'.dv-kpi { flex:1 1 180px; background:#fff; border:1px solid #e3e3e3;',
'          border-left:5px solid #1565c0; border-radius:.4em; padding:14px 16px;',
'          box-shadow:0 1px 2px rgba(0,0,0,.05); }',
'.dv-kpi .dv-lbl { color:#666; font-size:.78rem; text-transform:uppercase;',
'                  letter-spacing:.05em; }',
'.dv-kpi .dv-val { font-size:1.55rem; font-weight:700; color:#1565c0;',
'                  margin-top:.2em; line-height:1.1; }',
'.dv-kpi .dv-sub { color:#888; font-size:.75rem; margin-top:.25em; }',
'.dv-kpi.ok   { border-left-color:#2e7d32; } .dv-kpi.ok   .dv-val { color:#2e7d32; }',
'.dv-kpi.warn { border-left-color:#c62828; } .dv-kpi.warn .dv-val { color:#c62828; }'))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
--==================== Filtros (contenedor plano) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000144005)
,p_plug_name=>'Filtros'
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_point=>'BODY'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000144006)
,p_name=>'P144_PERIODO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000144005)
,p_prompt=>'Mes'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT TO_CHAR(periodo,''YYYY-MM'') d, TO_CHAR(periodo,''YYYY-MM'') r',
'  FROM (SELECT DISTINCT periodo FROM WKSP_WORKPLACE.V_CMP_COMPRA)',
' ORDER BY 1 DESC'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Todos los meses'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
--==================== KPIs (Dynamic Content PL/SQL) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000144010)
,p_plug_name=>'Resumen de Compras'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_ajax_items_to_submit=>'P144_PERIODO'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l VARCHAR2(32767);',
'  v_gasto NUMBER; v_ncomp NUMBER; v_ticket NUMBER;',
'  v_ocab NUMBER; v_ocval NUMBER;',
'  v_deuda NUMBER; v_venc NUMBER; v_pctvenc NUMBER; v_lead NUMBER;',
'  FUNCTION g(p NUMBER) RETURN VARCHAR2 IS',
'  BEGIN',
'    RETURN TO_CHAR(NVL(p,0),''FM999G999G999G990'',''NLS_NUMERIC_CHARACTERS=,.'');',
'  END;',
'BEGIN',
'  SELECT NVL(SUM(total),0), COUNT(*), NVL(ROUND(AVG(total)),0)',
'    INTO v_gasto, v_ncomp, v_ticket',
'    FROM WKSP_WORKPLACE.V_CMP_COMPRA',
'   WHERE (:P144_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P144_PERIODO);',
'  SELECT COUNT(*), NVL(SUM(total_orden),0) INTO v_ocab, v_ocval',
'    FROM WKSP_WORKPLACE.V_CMP_OC_ABIERTA;',
'  SELECT NVL(SUM(saldo),0),',
'         NVL(SUM(CASE WHEN dias_atraso>0 THEN saldo ELSE 0 END),0)',
'    INTO v_deuda, v_venc FROM WKSP_WORKPLACE.V_CMP_CXP_AGING;',
'  v_pctvenc := CASE WHEN v_deuda>0 THEN ROUND(v_venc*100/v_deuda) ELSE 0 END;',
'  SELECT NVL(ROUND(AVG(lead_dias),0),0) INTO v_lead',
'    FROM WKSP_WORKPLACE.V_CMP_RECEPCION WHERE lead_dias IS NOT NULL;',
'',
'  l := ''<div class="dv-kpis">'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Gasto de compra</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_gasto)||''</div>''||',
'       ''<div class="dv-sub">per''||unistr(''\00ED'')||''odo seleccionado</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Comprobantes</div>''||',
'       ''<div class="dv-val">''||v_ncomp||''</div>''||',
'       ''<div class="dv-sub">facturas de compra</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Ticket promedio</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_ticket)||''</div>''||',
'       ''<div class="dv-sub">por comprobante</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">OC abiertas</div>''||',
'       ''<div class="dv-val">''||v_ocab||''</div>''||',
'       ''<div class="dv-sub">''||unistr(''\20B2'')||'' ''||g(v_ocval)||'' comprometido</div></div>'';',
'  l := l||''<div class="dv-kpi ''||CASE WHEN v_pctvenc>0 THEN ''warn'' ELSE '''' END||''">''||',
'       ''<div class="dv-lbl">Deuda a proveedores</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_deuda)||''</div>''||',
'       ''<div class="dv-sub">''||v_pctvenc||''% vencido</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Lead time prom.</div>''||',
'       ''<div class="dv-val">''||v_lead||''</div>''||',
'       ''<div class="dv-sub">d''||unistr(''\00ED'')||''as OC ''||unistr(''\2192'')||'' recepci''||unistr(''\00F3'')||''n</div></div>'';',
'  l := l||''</div>'';',
'  RETURN l;',
'EXCEPTION WHEN OTHERS THEN',
'  RETURN ''<div style="color:#b00020">KPI region error: ''||SQLERRM||''</div>'';',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
--==================== Chart 1: Gasto de compra por mes (bar) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000144020)
,p_plug_name=>'Gasto de compra por mes'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000144021)
,p_region_id=>wwv_flow_imp.id(36000000000144020)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000144022)
,p_chart_id=>wwv_flow_imp.id(36000000000144021)
,p_seq=>10
,p_name=>'Gasto'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT TO_CHAR(periodo,''YYYY-MM'') AS d_label,',
'       SUM(gasto)                  AS d_value',
'  FROM WKSP_WORKPLACE.V_CMP_GASTO_MES',
' GROUP BY periodo',
' ORDER BY periodo'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144023)
,p_chart_id=>wwv_flow_imp.id(36000000000144021)
,p_axis=>'x'
,p_title=>'Mes'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144024)
,p_chart_id=>wwv_flow_imp.id(36000000000144021)
,p_axis=>'y'
,p_title=>unistr('Guaran\00EDes')
,p_format_type=>'decimal'
);
--==================== Chart 2: Gasto por proveedor (bar) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000144030)
,p_plug_name=>'Gasto por proveedor'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000144031)
,p_region_id=>wwv_flow_imp.id(36000000000144030)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000144032)
,p_chart_id=>wwv_flow_imp.id(36000000000144031)
,p_seq=>10
,p_name=>'Gasto'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P144_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT proveedor          AS d_label,',
'       SUM(total)         AS d_value',
'  FROM WKSP_WORKPLACE.V_CMP_COMPRA',
' WHERE (:P144_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P144_PERIODO)',
' GROUP BY proveedor',
' ORDER BY d_value DESC NULLS LAST'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144033)
,p_chart_id=>wwv_flow_imp.id(36000000000144031)
,p_axis=>'x'
,p_title=>'Proveedor'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144034)
,p_chart_id=>wwv_flow_imp.id(36000000000144031)
,p_axis=>'y'
,p_title=>unistr('Guaran\00EDes')
,p_format_type=>'decimal'
);
--==================== Chart 3: Top productos comprados (bar horizontal) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000144040)
,p_plug_name=>'Top productos comprados (valor)'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000144041)
,p_region_id=>wwv_flow_imp.id(36000000000144040)
,p_chart_type=>'bar'
,p_orientation=>'horizontal'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000144042)
,p_chart_id=>wwv_flow_imp.id(36000000000144041)
,p_seq=>10
,p_name=>'Valor'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P144_PERIODO'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT producto          AS d_label,',
'       SUM(total)         AS d_value',
'  FROM WKSP_WORKPLACE.V_CMP_LINEA',
' WHERE (:P144_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P144_PERIODO)',
' GROUP BY producto',
' ORDER BY d_value DESC NULLS LAST',
' FETCH FIRST 10 ROWS ONLY'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144043)
,p_chart_id=>wwv_flow_imp.id(36000000000144041)
,p_axis=>'x'
,p_title=>'Producto'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144044)
,p_chart_id=>wwv_flow_imp.id(36000000000144041)
,p_axis=>'y'
,p_title=>unistr('Guaran\00EDes')
,p_format_type=>'decimal'
);
--==================== Chart 4: Embudo de Ordenes de Compra (bar) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000144050)
,p_plug_name=>'Embudo de Ordenes de Compra'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000144051)
,p_region_id=>wwv_flow_imp.id(36000000000144050)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000144052)
,p_chart_id=>wwv_flow_imp.id(36000000000144051)
,p_seq=>10
,p_name=>unistr('N\00BA OC')
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT estado_label       AS d_label,',
'       n_oc               AS d_value',
'  FROM WKSP_WORKPLACE.V_CMP_OC_EMBUDO',
' ORDER BY orden'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144053)
,p_chart_id=>wwv_flow_imp.id(36000000000144051)
,p_axis=>'x'
,p_title=>'Estado'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144054)
,p_chart_id=>wwv_flow_imp.id(36000000000144051)
,p_axis=>'y'
,p_title=>unistr('\00D3rdenes')
,p_format_type=>'decimal'
);
--==================== Chart 5: Lead time promedio por proveedor (bar horizontal) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000144060)
,p_plug_name=>'Lead time promedio por proveedor'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000144061)
,p_region_id=>wwv_flow_imp.id(36000000000144060)
,p_chart_type=>'bar'
,p_orientation=>'horizontal'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000144062)
,p_chart_id=>wwv_flow_imp.id(36000000000144061)
,p_seq=>10
,p_name=>unistr('D\00EDas')
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT proveedor              AS d_label,',
'       ROUND(AVG(lead_dias),1) AS d_value',
'  FROM WKSP_WORKPLACE.V_CMP_RECEPCION',
' WHERE lead_dias IS NOT NULL',
' GROUP BY proveedor',
' ORDER BY d_value DESC NULLS LAST'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144063)
,p_chart_id=>wwv_flow_imp.id(36000000000144061)
,p_axis=>'x'
,p_title=>'Proveedor'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144064)
,p_chart_id=>wwv_flow_imp.id(36000000000144061)
,p_axis=>'y'
,p_title=>unistr('D\00EDas OC \2192 recepci\00F3n')
,p_format_type=>'decimal'
);
--==================== Chart 6: Aging de deuda a proveedores (bar) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000144070)
,p_plug_name=>'Aging de deuda a proveedores'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000144071)
,p_region_id=>wwv_flow_imp.id(36000000000144070)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000144072)
,p_chart_id=>wwv_flow_imp.id(36000000000144071)
,p_seq=>10
,p_name=>'Saldo'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT bucket             AS d_label,',
'       SUM(saldo)         AS d_value',
'  FROM WKSP_WORKPLACE.V_CMP_CXP_AGING',
' GROUP BY bucket, bucket_orden',
' ORDER BY bucket_orden'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144073)
,p_chart_id=>wwv_flow_imp.id(36000000000144071)
,p_axis=>'x'
,p_title=>'Tramo (dias de atraso)'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000144074)
,p_chart_id=>wwv_flow_imp.id(36000000000144071)
,p_axis=>'y'
,p_title=>unistr('Guaran\00EDes')
,p_format_type=>'decimal'
);
--==================== Reporte: Detalle de compras ====================
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000144080)
,p_name=>'Detalle de compras'
,p_template=>4072358936313175081
,p_display_sequence=>80
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight:t-Report--staticRowColors'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT fecha_emision,',
'       proveedor,',
'       condicion,',
'       estado_label,',
'       oficina,',
'       comprador,',
'       total',
'  FROM WKSP_WORKPLACE.V_CMP_COMPRA',
' WHERE (:P144_PERIODO IS NULL OR TO_CHAR(periodo,''YYYY-MM'') = :P144_PERIODO)',
' ORDER BY fecha_emision DESC'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P144_PERIODO'
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
 p_id=>wwv_flow_imp.id(36000000000144081)
,p_query_column_id=>1
,p_column_alias=>'FECHA_EMISION'
,p_column_display_sequence=>1
,p_column_heading=>'Fecha'
,p_heading_alignment=>'LEFT'
,p_column_format=>'DD/MM/YYYY'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000144082)
,p_query_column_id=>2
,p_column_alias=>'PROVEEDOR'
,p_column_display_sequence=>2
,p_column_heading=>'Proveedor'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000144083)
,p_query_column_id=>3
,p_column_alias=>'CONDICION'
,p_column_display_sequence=>3
,p_column_heading=>unistr('Condici\00F3n')
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000144084)
,p_query_column_id=>4
,p_column_alias=>'ESTADO_LABEL'
,p_column_display_sequence=>4
,p_column_heading=>'Estado'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000144085)
,p_query_column_id=>5
,p_column_alias=>'OFICINA'
,p_column_display_sequence=>5
,p_column_heading=>'Sucursal'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000144086)
,p_query_column_id=>6
,p_column_alias=>'COMPRADOR'
,p_column_display_sequence=>6
,p_column_heading=>'Comprador'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000144087)
,p_query_column_id=>7
,p_column_alias=>'TOTAL'
,p_column_display_sequence=>7
,p_column_heading=>'Total'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_column_format=>'FML999G999G999G990'
);
--==================== Boton: Imprimir informe (-> P145) ====================
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000144015)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000144010)
,p_button_name=>'IMPRIMIR_INFORME'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Generar informe imprimible'
,p_button_position=>'RIGHT_OF_TITLE'
,p_button_redirect_url=>'f?p=&APP_ID.:145:&APP_SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-print'
);
--==================== DA: al cambiar el Mes, refrescar regiones filtradas ====================
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000144090)
,p_name=>'Cambio de Mes - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P144_PERIODO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000144091)
,p_event_id=>wwv_flow_imp.id(36000000000144090)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000144010)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000144092)
,p_event_id=>wwv_flow_imp.id(36000000000144090)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000144030)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000144093)
,p_event_id=>wwv_flow_imp.id(36000000000144090)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000144040)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000144094)
,p_event_id=>wwv_flow_imp.id(36000000000144090)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000144080)
);
wwv_flow_imp.component_end;
end;
/

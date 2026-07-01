prompt --application/pages/page_00142
begin
--   Manifest
--     PAGE: 00142
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
 p_id=>142
,p_name=>'Dashboard de Inventario'
,p_alias=>'DASHBOARD-INVENTARIO'
,p_step_title=>'Dashboard de Inventario'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Dashboard de Inventario (F23 - Reportes Gerenciales) */',
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
 p_id=>wwv_flow_imp.id(36000000000142005)
,p_plug_name=>'Filtros'
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_plug_display_point=>'BODY'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000142006)
,p_name=>'P142_OFICINA'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000142005)
,p_prompt=>'Sucursal'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT o.DESCRIPCION d, o.CODIGO_OFICINA r',
'  FROM WKSP_WORKPLACE.OFICINAS o',
' WHERE EXISTS (SELECT 1 FROM WKSP_WORKPLACE.STOCK_PRODUCTO sp',
'                WHERE sp.ID_OFICINA = o.CODIGO_OFICINA)',
' ORDER BY 1'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Todas las sucursales'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
--==================== KPIs (Dynamic Content PL/SQL) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000142010)
,p_plug_name=>'Resumen de Inventario'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_ajax_items_to_submit=>'P142_OFICINA'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l VARCHAR2(32767);',
'  v_valor NUMBER; v_skus NUMBER;',
'  v_bajo NUMBER; v_sobre NUMBER; v_quiebre NUMBER; v_sinmov NUMBER;',
'  FUNCTION g(p NUMBER) RETURN VARCHAR2 IS',
'  BEGIN',
'    RETURN TO_CHAR(NVL(p,0),''FM999G999G999G990'',''NLS_NUMERIC_CHARACTERS=,.'');',
'  END;',
'BEGIN',
'  SELECT NVL(SUM(valor_stock),0),',
'         COUNT(DISTINCT id_producto),',
'         SUM(CASE WHEN estado_nivel=''BAJO_MINIMO''  THEN 1 ELSE 0 END),',
'         SUM(CASE WHEN estado_nivel=''SOBRE_MAXIMO'' THEN 1 ELSE 0 END),',
'         SUM(CASE WHEN estado_nivel=''QUIEBRE''      THEN 1 ELSE 0 END)',
'    INTO v_valor, v_skus, v_bajo, v_sobre, v_quiebre',
'    FROM WKSP_WORKPLACE.V_INV_STOCK',
'   WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA);',
'  SELECT COUNT(*) INTO v_sinmov',
'    FROM WKSP_WORKPLACE.V_INV_ROTACION',
'   WHERE clase_rotacion = ''SIN_MOVIMIENTO'';',
'',
'  l := ''<div class="dv-kpis">'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Valor inmovilizado</div>''||',
'       ''<div class="dv-val">''||unistr(''\20B2'')||'' ''||g(v_valor)||''</div>''||',
'       ''<div class="dv-sub">stock a costo</div></div>'';',
'  l := l||''<div class="dv-kpi"><div class="dv-lbl">Productos (SKU)</div>''||',
'       ''<div class="dv-val">''||v_skus||''</div>''||',
'       ''<div class="dv-sub">con stock</div></div>'';',
'  l := l||''<div class="dv-kpi ''||CASE WHEN v_bajo>0 THEN ''warn'' ELSE '''' END||''">''||',
'       ''<div class="dv-lbl">Bajo m''||unistr(''\00ED'')||''nimo</div>''||',
'       ''<div class="dv-val">''||v_bajo||''</div>''||',
'       ''<div class="dv-sub">a reponer</div></div>'';',
'  l := l||''<div class="dv-kpi ''||CASE WHEN v_sobre>0 THEN ''warn'' ELSE '''' END||''">''||',
'       ''<div class="dv-lbl">Sobre m''||unistr(''\00E1'')||''ximo</div>''||',
'       ''<div class="dv-val">''||v_sobre||''</div>''||',
'       ''<div class="dv-sub">exceso</div></div>'';',
'  l := l||''<div class="dv-kpi ''||CASE WHEN v_quiebre>0 THEN ''warn'' ELSE '''' END||''">''||',
'       ''<div class="dv-lbl">Quiebres</div>''||',
'       ''<div class="dv-val">''||v_quiebre||''</div>''||',
'       ''<div class="dv-sub">stock en cero</div></div>'';',
'  l := l||''<div class="dv-kpi ''||CASE WHEN v_sinmov>0 THEN ''warn'' ELSE '''' END||''">''||',
'       ''<div class="dv-lbl">Sin movimiento</div>''||',
'       ''<div class="dv-val">''||v_sinmov||''</div>''||',
'       ''<div class="dv-sub">sin ventas</div></div>'';',
'  l := l||''</div>'';',
'  RETURN l;',
'EXCEPTION WHEN OTHERS THEN',
'  RETURN ''<div style="color:#b00020">KPI region error: ''||SQLERRM||''</div>'';',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
--==================== Chart 1: Valor de stock por categoria (bar) ====================
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000142020)
,p_plug_name=>unistr('Valor de stock por categor\00EDa')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000142021)
,p_region_id=>wwv_flow_imp.id(36000000000142020)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142022)
,p_chart_id=>wwv_flow_imp.id(36000000000142021)
,p_seq=>10
,p_name=>'Valor'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P142_OFICINA'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT categoria           AS d_label,',
'       SUM(valor_stock)    AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_STOCK',
' WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA)',
' GROUP BY categoria',
' ORDER BY d_value DESC NULLS LAST'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142023)
,p_chart_id=>wwv_flow_imp.id(36000000000142021)
,p_axis=>'x'
,p_title=>unistr('Categor\00EDa')
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142024)
,p_chart_id=>wwv_flow_imp.id(36000000000142021)
,p_axis=>'y'
,p_title=>unistr('Guaran\00EDes')
,p_format_type=>'decimal'
);
--==================== Chart 2: Stock actual vs min/max por producto (bar, 3 series) ====
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000142030)
,p_plug_name=>unistr('Stock actual vs. m\00EDn/m\00E1x por producto')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000142031)
,p_region_id=>wwv_flow_imp.id(36000000000142030)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142032)
,p_chart_id=>wwv_flow_imp.id(36000000000142031)
,p_seq=>10
,p_name=>'Stock'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P142_OFICINA'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT producto           AS d_label,',
'       SUM(cantidad)       AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_STOCK',
' WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA)',
' GROUP BY producto',
' ORDER BY producto'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142035)
,p_chart_id=>wwv_flow_imp.id(36000000000142031)
,p_seq=>20
,p_name=>unistr('M\00EDnimo')
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P142_OFICINA'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT producto              AS d_label,',
'       SUM(stock_minimo)     AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_STOCK',
' WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA)',
' GROUP BY producto',
' ORDER BY producto'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142036)
,p_chart_id=>wwv_flow_imp.id(36000000000142031)
,p_seq=>30
,p_name=>unistr('M\00E1ximo')
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P142_OFICINA'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT producto              AS d_label,',
'       SUM(stock_maximo)     AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_STOCK',
' WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA)',
' GROUP BY producto',
' ORDER BY producto'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142033)
,p_chart_id=>wwv_flow_imp.id(36000000000142031)
,p_axis=>'x'
,p_title=>'Producto'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142034)
,p_chart_id=>wwv_flow_imp.id(36000000000142031)
,p_axis=>'y'
,p_title=>'Unidades'
,p_format_type=>'decimal'
);
--==================== Chart 3: Entradas vs Salidas por mes (bar, 2 series) ====
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000142040)
,p_plug_name=>'Entradas vs. Salidas por mes'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000142041)
,p_region_id=>wwv_flow_imp.id(36000000000142040)
,p_chart_type=>'bar'
,p_height=>'380'
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142042)
,p_chart_id=>wwv_flow_imp.id(36000000000142041)
,p_seq=>10
,p_name=>'Entradas'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P142_OFICINA'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT TO_CHAR(periodo,''YYYY-MM'') AS d_label,',
'       SUM(entradas)               AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_FLUJO_MES',
' WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA)',
' GROUP BY periodo',
' ORDER BY periodo'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142043)
,p_chart_id=>wwv_flow_imp.id(36000000000142041)
,p_seq=>20
,p_name=>'Salidas'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P142_OFICINA'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT TO_CHAR(periodo,''YYYY-MM'') AS d_label,',
'       SUM(salidas)                AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_FLUJO_MES',
' WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA)',
' GROUP BY periodo',
' ORDER BY periodo'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142044)
,p_chart_id=>wwv_flow_imp.id(36000000000142041)
,p_axis=>'x'
,p_title=>'Mes'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142045)
,p_chart_id=>wwv_flow_imp.id(36000000000142041)
,p_axis=>'y'
,p_title=>'Unidades'
,p_format_type=>'decimal'
);
--==================== Chart 4: Rotacion por producto (bar horizontal) ====
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000142050)
,p_plug_name=>unistr('Rotaci\00F3n por producto (\00EDndice)')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000142051)
,p_region_id=>wwv_flow_imp.id(36000000000142050)
,p_chart_type=>'bar'
,p_orientation=>'horizontal'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142052)
,p_chart_id=>wwv_flow_imp.id(36000000000142051)
,p_seq=>10
,p_name=>unistr('\00CDndice')
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT producto          AS d_label,',
'       NVL(indice_rotacion,0) AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_ROTACION',
' WHERE salidas_venta > 0',
' ORDER BY indice_rotacion DESC NULLS LAST',
' FETCH FIRST 10 ROWS ONLY'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142053)
,p_chart_id=>wwv_flow_imp.id(36000000000142051)
,p_axis=>'x'
,p_title=>'Producto'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142054)
,p_chart_id=>wwv_flow_imp.id(36000000000142051)
,p_axis=>'y'
,p_title=>unistr('Salidas / stock')
,p_format_type=>'decimal'
);
--==================== Chart 5: Valor inmovilizado por sucursal (donut, snapshot) ====
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000142060)
,p_plug_name=>'Valor inmovilizado por sucursal'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000142061)
,p_region_id=>wwv_flow_imp.id(36000000000142060)
,p_chart_type=>'donut'
,p_height=>'380'
,p_legend_rendered=>'on'
,p_legend_position=>'bottom'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142062)
,p_chart_id=>wwv_flow_imp.id(36000000000142061)
,p_seq=>10
,p_name=>'Valor'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT oficina           AS d_label,',
'       SUM(valor_stock)  AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_STOCK',
' GROUP BY oficina',
' ORDER BY d_value DESC NULLS LAST'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
--==================== Chart 6: Top productos por valor de stock (bar horizontal) ====
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000142070)
,p_plug_name=>'Top productos por valor de stock'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_plug_display_point=>'BODY'
,p_plug_source_type=>'NATIVE_JET_CHART'
);
wwv_flow_imp_page.create_jet_chart(
 p_id=>wwv_flow_imp.id(36000000000142071)
,p_region_id=>wwv_flow_imp.id(36000000000142070)
,p_chart_type=>'bar'
,p_orientation=>'horizontal'
,p_height=>'380'
,p_legend_rendered=>'off'
);
wwv_flow_imp_page.create_jet_chart_series(
 p_id=>wwv_flow_imp.id(36000000000142072)
,p_chart_id=>wwv_flow_imp.id(36000000000142071)
,p_seq=>10
,p_name=>'Valor'
,p_data_source_type=>'SQL'
,p_location=>'LOCAL'
,p_ajax_items_to_submit=>'P142_OFICINA'
,p_data_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT producto          AS d_label,',
'       SUM(valor_stock)  AS d_value',
'  FROM WKSP_WORKPLACE.V_INV_STOCK',
' WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA)',
' GROUP BY producto',
' ORDER BY d_value DESC NULLS LAST',
' FETCH FIRST 10 ROWS ONLY'))
,p_items_label_column_name=>'D_LABEL'
,p_items_value_column_name=>'D_VALUE'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142073)
,p_chart_id=>wwv_flow_imp.id(36000000000142071)
,p_axis=>'x'
,p_title=>'Producto'
);
wwv_flow_imp_page.create_jet_chart_axis(
 p_id=>wwv_flow_imp.id(36000000000142074)
,p_chart_id=>wwv_flow_imp.id(36000000000142071)
,p_axis=>'y'
,p_title=>unistr('Guaran\00EDes')
,p_format_type=>'decimal'
);
--==================== Reporte: Detalle de stock ====================
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000142080)
,p_name=>'Detalle de stock'
,p_template=>4072358936313175081
,p_display_sequence=>80
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight:t-Report--staticRowColors'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT producto,',
'       categoria,',
'       oficina,',
'       cantidad,',
'       stock_minimo,',
'       stock_maximo,',
'       estado_nivel,',
'       valor_stock',
'  FROM WKSP_WORKPLACE.V_INV_STOCK',
' WHERE (:P142_OFICINA IS NULL OR id_oficina = :P142_OFICINA)',
' ORDER BY valor_stock DESC NULLS LAST'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P142_OFICINA'
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
 p_id=>wwv_flow_imp.id(36000000000142081)
,p_query_column_id=>1
,p_column_alias=>'PRODUCTO'
,p_column_display_sequence=>1
,p_column_heading=>'Producto'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000142082)
,p_query_column_id=>2
,p_column_alias=>'CATEGORIA'
,p_column_display_sequence=>2
,p_column_heading=>unistr('Categor\00EDa')
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000142083)
,p_query_column_id=>3
,p_column_alias=>'OFICINA'
,p_column_display_sequence=>3
,p_column_heading=>'Sucursal'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000142084)
,p_query_column_id=>4
,p_column_alias=>'CANTIDAD'
,p_column_display_sequence=>4
,p_column_heading=>'Stock'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_column_format=>'999G999G990'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000142085)
,p_query_column_id=>5
,p_column_alias=>'STOCK_MINIMO'
,p_column_display_sequence=>5
,p_column_heading=>unistr('M\00EDn')
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_column_format=>'999G999G990'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000142086)
,p_query_column_id=>6
,p_column_alias=>'STOCK_MAXIMO'
,p_column_display_sequence=>6
,p_column_heading=>unistr('M\00E1x')
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_column_format=>'999G999G990'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000142087)
,p_query_column_id=>7
,p_column_alias=>'ESTADO_NIVEL'
,p_column_display_sequence=>7
,p_column_heading=>'Nivel'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000142088)
,p_query_column_id=>8
,p_column_alias=>'VALOR_STOCK'
,p_column_display_sequence=>8
,p_column_heading=>'Valor'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_column_format=>'FML999G999G999G990'
);
--==================== Boton: Imprimir informe (-> P143) ====================
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000142015)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000142010)
,p_button_name=>'IMPRIMIR_INFORME'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Generar informe imprimible'
,p_button_position=>'RIGHT_OF_TITLE'
,p_button_redirect_url=>'f?p=&APP_ID.:143:&APP_SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-print'
);
--==================== DA: al cambiar la Sucursal, refrescar regiones filtradas ====
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000142090)
,p_name=>'Cambio de Sucursal - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P142_OFICINA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000142091)
,p_event_id=>wwv_flow_imp.id(36000000000142090)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000142010)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000142092)
,p_event_id=>wwv_flow_imp.id(36000000000142090)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000142020)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000142093)
,p_event_id=>wwv_flow_imp.id(36000000000142090)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000142030)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000142094)
,p_event_id=>wwv_flow_imp.id(36000000000142090)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000142040)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000142095)
,p_event_id=>wwv_flow_imp.id(36000000000142090)
,p_event_result=>'TRUE'
,p_action_sequence=>50
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000142070)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000142096)
,p_event_id=>wwv_flow_imp.id(36000000000142090)
,p_event_result=>'TRUE'
,p_action_sequence=>60
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000142080)
);
wwv_flow_imp.component_end;
end;
/

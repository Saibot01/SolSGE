prompt --application/pages/page_00062
begin
--   Manifest
--     PAGE: 00062
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
 p_id=>62
,p_name=>'Caja'
,p_alias=>'CAJA'
,p_step_title=>'Estado de Caja'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'// Auto-refresh de movimientos en vivo cada 20s (H3 - PLAN_CIERRE_CAJA)',
'setInterval(function () {',
'  try {',
'    var r = apex.region("mov_caja");',
'    if (r) { r.refresh(); }',
'  } catch (e) {}',
'}, 20000);'))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000062010)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000062020)
,p_plug_name=>unistr('Selecci\00F3n de Caja')
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000062030)
,p_name=>'Datos de la Caja'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--staticRowColors'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT c.ID_CAJA,',
'       CASE c.ESTADO WHEN ''A'' THEN ''Abierta'' WHEN ''C'' THEN ''Cerrada'' ELSE NVL(c.ESTADO,''-'') END AS ESTADO,',
'       NVL(cf.DESCRIPCION,''-'') AS CAJA,',
'       c.USU_APERTURA,',
'       TO_CHAR(c.FEC_APERTURA,''DD/MM/YYYY HH24:MI'') AS APERTURA,',
'       c.USU_CIERRE,',
'       TO_CHAR(c.FEC_CIERRE,''DD/MM/YYYY HH24:MI'') AS CIERRE',
'  FROM CAJAS c',
'  LEFT JOIN CAJA_CONF cf ON cf.ID_CAJA_CONF = c.ID_CAJA_CONF',
' WHERE c.ID_CAJA = :P62_ID_CAJA'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P62_ID_CAJA'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>1
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('Seleccion\00E1 una caja para ver su estado.')
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>500
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062031)
,p_query_column_id=>1
,p_column_alias=>'ID_CAJA'
,p_column_display_sequence=>1
,p_column_heading=>'Caja N&deg;'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062032)
,p_query_column_id=>2
,p_column_alias=>'ESTADO'
,p_column_display_sequence=>2
,p_column_heading=>'Estado'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062033)
,p_query_column_id=>3
,p_column_alias=>'CAJA'
,p_column_display_sequence=>3
,p_column_heading=>'Caja'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062034)
,p_query_column_id=>4
,p_column_alias=>'USU_APERTURA'
,p_column_display_sequence=>4
,p_column_heading=>'Cajero (apertura)'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062035)
,p_query_column_id=>5
,p_column_alias=>'APERTURA'
,p_column_display_sequence=>5
,p_column_heading=>'Fecha Apertura'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062036)
,p_query_column_id=>6
,p_column_alias=>'USU_CIERRE'
,p_column_display_sequence=>6
,p_column_heading=>'Cajero (cierre)'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062037)
,p_query_column_id=>7
,p_column_alias=>'CIERRE'
,p_column_display_sequence=>7
,p_column_heading=>'Fecha Cierre'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000062040)
,p_name=>'Saldo por Moneda'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT NVL(m.DESCRIPCION, v.MONEDA) AS MONEDA,',
'       v.MONTO_APERTURA, v.INGRESOS, v.EGRESOS, v.SALDO_ESPERADO,',
'       v.MONTO_DECLARADO, v.MONTO_DIFERENCIA',
'  FROM V_CAJA_SALDO v',
'  LEFT JOIN MONEDAS m ON m.CODIGO_MONEDA = v.MONEDA',
' WHERE v.ID_CAJA = :P62_ID_CAJA',
' ORDER BY v.MONEDA'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P62_ID_CAJA'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'Sin saldos para esta caja.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>500
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062041)
,p_query_column_id=>1
,p_column_alias=>'MONEDA'
,p_column_display_sequence=>1
,p_column_heading=>'Moneda'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062042)
,p_query_column_id=>2
,p_column_alias=>'MONTO_APERTURA'
,p_column_display_sequence=>2
,p_column_heading=>'Apertura'
,p_column_format=>'999G999G999G990D00'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062043)
,p_query_column_id=>3
,p_column_alias=>'INGRESOS'
,p_column_display_sequence=>3
,p_column_heading=>'Ingresos'
,p_column_format=>'999G999G999G990D00'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062044)
,p_query_column_id=>4
,p_column_alias=>'EGRESOS'
,p_column_display_sequence=>4
,p_column_heading=>'Egresos'
,p_column_format=>'999G999G999G990D00'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062045)
,p_query_column_id=>5
,p_column_alias=>'SALDO_ESPERADO'
,p_column_display_sequence=>5
,p_column_heading=>'Saldo Esperado'
,p_column_format=>'999G999G999G990D00'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062046)
,p_query_column_id=>6
,p_column_alias=>'MONTO_DECLARADO'
,p_column_display_sequence=>6
,p_column_heading=>'Declarado'
,p_column_format=>'999G999G999G990D00'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062047)
,p_query_column_id=>7
,p_column_alias=>'MONTO_DIFERENCIA'
,p_column_display_sequence=>7
,p_column_heading=>'Diferencia'
,p_column_format=>'999G999G999G990D00'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000062050)
,p_name=>'Movimientos en vivo'
,p_region_name=>'mov_caja'
,p_template=>4072358936313175081
,p_display_sequence=>40
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody:js-showMaximizeButton'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT mc.ID_MOVIMIENTO,',
'       CASE mc.TIPO WHEN ''INGRESO_VENTA'' THEN ''Venta contado''',
'                    WHEN ''COBRO_CXC''     THEN ''Cobro de cuota''',
'                    WHEN ''EGRESO''         THEN ''Egreso/Reverso''',
'                    WHEN ''AJUSTE''         THEN ''Ajuste'' ELSE mc.TIPO END AS TIPO,',
'       NVL(mc.TOTAL_MONEDA_ORIGEN, mc.TOTAL_MONEDA_LOCAL) AS MONTO,',
'       NVL(mo.DESCRIPCION, mc.MONEDA) AS MONEDA,',
'       mc.NRO_RECIBO,',
'       mc.USUARIO,',
'       TO_CHAR(mc.FECHA,''DD/MM/YYYY HH24:MI'') AS FECHA,',
'       mc.ID_COMPROBANTE,',
'       mc.OBSERVACION',
'  FROM MOVIMIENTOS_CAJA mc',
'  LEFT JOIN MONEDAS mo ON (mo.CODIGO_MONEDA = mc.MONEDA OR mo.DESCRIPCION = mc.MONEDA)',
' WHERE mc.ID_CAJA = :P62_ID_CAJA',
'   AND (:P62_TIPO IS NULL OR mc.TIPO = :P62_TIPO)',
' ORDER BY mc.ID_MOVIMIENTO DESC'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P62_ID_CAJA,P62_TIPO'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'Sin movimientos para los filtros actuales.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>5000
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062051)
,p_query_column_id=>1
,p_column_alias=>'ID_MOVIMIENTO'
,p_column_display_sequence=>1
,p_column_heading=>'N&deg;'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062052)
,p_query_column_id=>2
,p_column_alias=>'TIPO'
,p_column_display_sequence=>2
,p_column_heading=>'Tipo'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062053)
,p_query_column_id=>3
,p_column_alias=>'MONTO'
,p_column_display_sequence=>3
,p_column_heading=>'Monto'
,p_column_format=>'999G999G999G990D00'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062054)
,p_query_column_id=>4
,p_column_alias=>'MONEDA'
,p_column_display_sequence=>4
,p_column_heading=>'Moneda'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062055)
,p_query_column_id=>5
,p_column_alias=>'NRO_RECIBO'
,p_column_display_sequence=>5
,p_column_heading=>'Nro. Recibo'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062056)
,p_query_column_id=>6
,p_column_alias=>'USUARIO'
,p_column_display_sequence=>6
,p_column_heading=>'Usuario'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062057)
,p_query_column_id=>7
,p_column_alias=>'FECHA'
,p_column_display_sequence=>7
,p_column_heading=>'Fecha'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062058)
,p_query_column_id=>8
,p_column_alias=>'ID_COMPROBANTE'
,p_column_display_sequence=>8
,p_column_heading=>'Comprobante'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000062059)
,p_query_column_id=>9
,p_column_alias=>'OBSERVACION'
,p_column_display_sequence=>9
,p_column_heading=>'Observaci&oacute;n'
,p_heading_alignment=>'LEFT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000062070)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000062020)
,p_button_name=>'CERRAR_CAJA'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Cerrar Caja'
,p_button_position=>'EDIT'
,p_button_redirect_url=>'f?p=&APP_ID.:61:&APP_SESSION.::&DEBUG.:RP,61::'
,p_icon_css_classes=>'fa-lock'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000062071)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(36000000000062020)
,p_button_name=>'VER_ARQUEO'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Ver Arqueo'
,p_button_position=>'EDIT'
,p_button_redirect_url=>'f?p=&APP_ID.:132:&APP_SESSION.::&DEBUG.:RP,132:P132_ID_CAJA:&P62_ID_CAJA.'
,p_button_condition=>'P62_ID_CAJA'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_icon_css_classes=>'fa-file-text-o'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000062060)
,p_name=>'P62_ID_CAJA'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000062020)
,p_prompt=>'Caja'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ''Caja ''||c.ID_CAJA||'' - ''||NVL(cf.DESCRIPCION,''?'')||'' (''||',
'       CASE c.ESTADO WHEN ''A'' THEN ''Abierta'' WHEN ''C'' THEN ''Cerrada'' ELSE NVL(c.ESTADO,''-'') END||'') ''||',
'       TO_CHAR(c.FEC_APERTURA,''DD/MM/YYYY'') AS d,',
'       c.ID_CAJA AS r',
'  FROM CAJAS c',
'  LEFT JOIN CAJA_CONF cf ON cf.ID_CAJA_CONF = c.ID_CAJA_CONF',
' ORDER BY c.ID_CAJA DESC'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>unistr('- eleg\00ED una caja -')
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_item_default=>'SELECT WKSP_WORKPLACE.FN_CAJA_ABIERTA_USUARIO(:APP_USER) FROM dual'
,p_item_default_type=>'SQL_QUERY'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000062061)
,p_name=>'P62_TIPO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(36000000000062020)
,p_prompt=>'Tipo de movimiento'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ''Venta contado'' d, ''INGRESO_VENTA'' r FROM dual',
'UNION ALL SELECT ''Cobro de cuota'', ''COBRO_CXC'' FROM dual',
'UNION ALL SELECT ''Egreso/Reverso'', ''EGRESO'' FROM dual',
'UNION ALL SELECT ''Ajuste'', ''AJUSTE'' FROM dual'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'(Todos los tipos)'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000062080)
,p_name=>'Cambio de Caja - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P62_ID_CAJA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000062081)
,p_event_id=>wwv_flow_imp.id(36000000000062080)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000062030)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000062082)
,p_event_id=>wwv_flow_imp.id(36000000000062080)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000062040)
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000062083)
,p_event_id=>wwv_flow_imp.id(36000000000062080)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000062050)
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000062084)
,p_name=>'Cambio de Tipo - Refrescar Movimientos'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P62_TIPO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000062085)
,p_event_id=>wwv_flow_imp.id(36000000000062084)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000062050)
);
wwv_flow_imp.component_end;
end;
/

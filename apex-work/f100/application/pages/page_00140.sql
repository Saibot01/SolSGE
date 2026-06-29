prompt --application/pages/page_00140
begin
--   Manifest
--     PAGE: 00140
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
 p_id=>140
,p_name=>'Metas de Venta'
,p_alias=>'METAS-DE-VENTA'
,p_step_title=>'Metas de Venta'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000140010)
,p_plug_name=>'Metas de Venta'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT m.id_meta,',
'       CASE WHEN m.id_empleado IS NOT NULL THEN ''Vendedor'' ELSE ''Sucursal'' END AS tipo,',
'       COALESCE(e.nombre, o.descripcion) AS dimension,',
'       TO_CHAR(m.periodo,''YYYY-MM'')      AS periodo,',
'       m.monto_meta,',
'       vm.neto,',
'       vm.cumplimiento_pct',
'  FROM WKSP_WORKPLACE.METAS_VENTA m',
'  LEFT JOIN WKSP_WORKPLACE.EMPLEADOS e  ON e.id_empleado    = m.id_empleado',
'  LEFT JOIN WKSP_WORKPLACE.OFICINAS  o  ON o.codigo_oficina = m.id_oficina',
'  LEFT JOIN WKSP_WORKPLACE.V_VENTAS_VENDEDOR_META vm',
'         ON vm.id_empleado = m.id_empleado AND vm.periodo = m.periodo'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Metas de Venta'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(36000000000140050)
,p_name=>'Metas de Venta'
,p_max_row_count_message=>'El m&aacute;ximo de filas es #MAX_ROW_COUNT#. Aplique un filtro.'
,p_no_data_found_message=>'No hay metas cargadas. Use "Crear" para agregar.'
,p_base_pk1=>'ID_META'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_detail_link=>'f?p=&APP_ID.:141:&APP_SESSION.::&DEBUG.:RP:P141_ID_META:\#ID_META#\'
,p_detail_link_text=>'<span role="img" aria-label="Editar" class="fa fa-edit" title="Editar"></span>'
,p_owner=>'SIS_APEX'
,p_internal_uid=>36000000000140050
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000140051)
,p_db_column_name=>'ID_META'
,p_display_order=>1
,p_is_primary_key=>'Y'
,p_column_identifier=>'A'
,p_column_label=>'Id Meta'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000140052)
,p_db_column_name=>'TIPO'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Tipo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000140053)
,p_db_column_name=>'DIMENSION'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Vendedor / Sucursal'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000140054)
,p_db_column_name=>'PERIODO'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>unistr('Per\00EDodo')
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000140055)
,p_db_column_name=>'MONTO_META'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Monto meta'
,p_column_type=>'NUMBER'
,p_format_mask=>'FML999G999G999G990'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000140056)
,p_db_column_name=>'NETO'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>unistr('Venta neta')
,p_column_type=>'NUMBER'
,p_format_mask=>'FML999G999G999G990'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000140057)
,p_db_column_name=>'CUMPLIMIENTO_PCT'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>'Cumplimiento %'
,p_column_type=>'NUMBER'
,p_format_mask=>'999G990D0'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(36000000000140060)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'METVTA1'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID_META:TIPO:DIMENSION:PERIODO:MONTO_META:NETO:CUMPLIMIENTO_PCT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000140020)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000140010)
,p_button_name=>'CREAR'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear meta'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:141:&APP_SESSION.::&DEBUG.:141::'
,p_icon_css_classes=>'fa-plus'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000140030)
,p_name=>'Cierre del modal - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(36000000000140010)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000140031)
,p_event_id=>wwv_flow_imp.id(36000000000140030)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000140010)
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00113
begin
--   Manifest
--     PAGE: 00113
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_page.create_page(
 p_id=>113
,p_name=>'Transferencias de Stock'
,p_alias=>'TRANSFERENCIAS-STOCK'
,p_step_title=>'Transferencias de Stock'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(5600113001)
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
 p_id=>wwv_flow_imp.id(5600113002)
,p_plug_name=>'Transferencias de Stock'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'  ts.ID_TRANSFERENCIA,',
'  p.NOMBRE           AS PRODUCTO,',
'  o1.DESCRIPCION     AS ORIGEN,',
'  o2.DESCRIPCION     AS DESTINO,',
'  ts.CANTIDAD,',
'  ts.FECHA,',
'  ts.OBSERVACION,',
'  ts.USUARIO',
'FROM TRANSFERENCIAS_STOCK ts',
'JOIN PRODUCTOS p  ON p.ID_PRODUCTO     = ts.ID_PRODUCTO',
'JOIN OFICINAS  o1 ON o1.CODIGO_OFICINA = ts.ID_OFICINA_ORIGEN',
'JOIN OFICINAS  o2 ON o2.CODIGO_OFICINA = ts.ID_OFICINA_DESTINO',
'ORDER BY ts.FECHA DESC'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Transferencias de Stock'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(5600113003)
,p_name=>'Transferencias de Stock'
,p_max_row_count_message=>'The maximum row count for this report is #MAX_ROW_COUNT# rows.  Please apply a filter to reduce the number of records in your query.'
,p_no_data_found_message=>'No se encontraron transferencias.'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_owner=>'WKSP_WORKPLACE'
,p_internal_uid=>5600113003
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(5600113010)
,p_db_column_name=>'ID_TRANSFERENCIA'
,p_display_order=>1
,p_is_primary_key=>'Y'
,p_column_identifier=>'A'
,p_column_label=>'Id'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(5600113020)
,p_db_column_name=>'PRODUCTO'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Producto'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(5600113030)
,p_db_column_name=>'ORIGEN'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Origen'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(5600113040)
,p_db_column_name=>'DESTINO'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Destino'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(5600113050)
,p_db_column_name=>'CANTIDAD'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Cantidad'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(5600113060)
,p_db_column_name=>'FECHA'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Fecha'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(5600113070)
,p_db_column_name=>'OBSERVACION'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>'Observacion'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(5600113080)
,p_db_column_name=>'USUARIO'
,p_display_order=>8
,p_column_identifier=>'H'
,p_column_label=>'Usuario'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(5600113090)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'560011309'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID_TRANSFERENCIA:PRODUCTO:ORIGEN:DESTINO:CANTIDAD:FECHA:OBSERVACION:USUARIO'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(5600113110)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(5600113002)
,p_button_name=>'CREATE'
,p_button_action=>'REDIRECT_URL'
,p_button_redirect_url=>'f?p=&APP_ID.:114:&SESSION.::&DEBUG.:114::'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Nueva Transferencia'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(5600113200)
,p_name=>'Transferencia Creada - Dialog Closed'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(5600113002)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(5600113201)
,p_event_id=>wwv_flow_imp.id(5600113200)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(5600113002)
);
wwv_flow_imp.component_end;
end;
/

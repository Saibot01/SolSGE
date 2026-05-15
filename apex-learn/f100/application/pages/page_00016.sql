prompt --application/pages/page_00016
begin
--   Manifest
--     PAGE: 00016
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
 p_id=>16
,p_name=>'Empleados IG'
,p_alias=>'EMPLEADOS-IG'
,p_step_title=>'Empleados'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11516387187464580)
,p_plug_name=>'Empleados IG'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'EMPLEADOS'
,p_include_rowid_column=>false
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Empleados IG'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(11516480733464580)
,p_name=>'Empleados IG'
,p_max_row_count_message=>'The maximum row count for this report is #MAX_ROW_COUNT# rows.  Please apply a filter to reduce the number of records in your query.'
,p_no_data_found_message=>'No data found.'
,p_base_pk1=>'ID_EMPLEADO'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:RP:P20_ID_EMPLEADO:\#ID_EMPLEADO#\'
,p_detail_link_text=>'<span role="img" aria-label="Edit" class="fa fa-edit" title="Edit"></span>'
,p_owner=>'SIS_APEX'
,p_internal_uid=>11516480733464580
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11517110538464585)
,p_db_column_name=>'ID_EMPLEADO'
,p_display_order=>0
,p_is_primary_key=>'Y'
,p_column_identifier=>'A'
,p_column_label=>'Id Empleado'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11517586455464586)
,p_db_column_name=>'ID_PERSONA'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Nro Documento'
,p_column_type=>'STRING'
,p_display_text_as=>'LOV_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_rpt_named_lov=>wwv_flow_imp.id(9739886888480172)
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11517962756464587)
,p_db_column_name=>'NOMBRE'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Nombre'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11518373061464587)
,p_db_column_name=>'FECHA_ALTA'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Fecha Alta'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11518746012464587)
,p_db_column_name=>'CARGO'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Cargo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11519180934464587)
,p_db_column_name=>unistr('CONTRASE\00D1A')
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>unistr('Contrase\00F1a')
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11519527981464588)
,p_db_column_name=>'CODIGO_USUARIO'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>'Codigo del Usuario'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11519971171464588)
,p_db_column_name=>'CODIGO_VERIFICACION'
,p_display_order=>8
,p_column_identifier=>'H'
,p_column_label=>'Codigo Verificacion'
,p_column_type=>'STRING'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(11520352203464588)
,p_db_column_name=>'CORREO'
,p_display_order=>9
,p_column_identifier=>'I'
,p_column_label=>'Correo Laboral'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(11523044968465097)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'115231'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>unistr('ID_EMPLEADO:ID_PERSONA:NOMBRE:FECHA_ALTA:CARGO:CONTRASE\00D1A:CODIGO_USUARIO:CODIGO_VERIFICACION:CORREO')
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11522404563464591)
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
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11520888599464589)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(11516387187464580)
,p_button_name=>'CREATE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:20:&APP_SESSION.::&DEBUG.:20::'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11521117502464589)
,p_name=>'Edit Report - Dialog Closed'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(11516387187464580)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11521661217464590)
,p_event_id=>wwv_flow_imp.id(11521117502464589)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(11516387187464580)
);
wwv_flow_imp.component_end;
end;
/

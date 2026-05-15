prompt --application/pages/page_00041
begin
--   Manifest
--     PAGE: 00041
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
 p_id=>41
,p_name=>'Proveedores IG'
,p_alias=>'PROVEEDORES-IG'
,p_step_title=>'Proveedores IG'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_last_updated_on=>wwv_flow_imp.dz('20250412003709Z')
,p_created_by=>'SIS_APEX'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9808649399312828)
,p_plug_name=>'Proveedores IG'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'	ID_PERSONA,',
'	(select p.primer_nombre || '' '' || NVL(p.segundo_nombre, '''') || '' '' || p.primer_apellido || '' '' || NVL(p.segundo_apellido, '''') AS nombre_completo from personas p where p.id_persona = proveedores.id_persona) nombre,',
'       CODIGO_USUARIO,',
'       CASE ESTADO ',
'           WHEN ''A'' THEN ''Activo''',
'           WHEN ''I'' THEN ''Inactivo''',
'           ELSE ''Desconocido''',
'       END AS ESTADO,',
'       FECHA_REGISTRO,',
'       CASE CATEGORIA ',
'           WHEN ''N'' THEN ''Nacional''',
'           WHEN ''I'' THEN ''Internacional''',
'           ELSE ''Desconocido'' END AS CATEGORIA',
'  from Proveedores'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Proveedores IG'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412003709Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(9808734934312828)
,p_name=>'Proveedores IG'
,p_max_row_count_message=>'The maximum row count for this report is #MAX_ROW_COUNT# rows.  Please apply a filter to reduce the number of records in your query.'
,p_no_data_found_message=>'No data found.'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:42:&APP_SESSION.::&DEBUG.:RP:P42_ID_PERSONA:\#ID_PERSONA#\'
,p_detail_link_text=>'<span role="img" aria-label="Edit" class="fa fa-edit" title="Edit"></span>'
,p_owner=>'SIS_APEX'
,p_internal_uid=>9808734934312828
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412001516Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'TCASCO'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9809426734312831)
,p_db_column_name=>'ID_PERSONA'
,p_display_order=>0
,p_is_primary_key=>'Y'
,p_column_identifier=>'A'
,p_column_label=>'Id Persona'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000750Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9809840056312831)
,p_db_column_name=>'CODIGO_USUARIO'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Codigo Usuario'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000750Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9810292289312831)
,p_db_column_name=>'ESTADO'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Estado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000750Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9810633726312832)
,p_db_column_name=>'FECHA_REGISTRO'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Fecha Registro'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000750Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9811077068312832)
,p_db_column_name=>'CATEGORIA'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Categoria'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000750Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(9716592082137613)
,p_db_column_name=>'NOMBRE'
,p_display_order=>15
,p_column_identifier=>'F'
,p_column_label=>'Nombre'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250412001515Z')
,p_updated_on=>wwv_flow_imp.dz('20250412001515Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(9814827990357464)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'98149'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID_PERSONA:CODIGO_USUARIO:ESTADO:FECHA_REGISTRO:CATEGORIA:NOMBRE'
,p_created_on=>wwv_flow_imp.dz('20250412001516Z')
,p_updated_on=>wwv_flow_imp.dz('20250412001516Z')
,p_created_by=>'TCASCO'
,p_updated_by=>'TCASCO'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(9813105564312834)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000750Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9811539523312832)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(9808649399312828)
,p_button_name=>'CREATE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:42:&APP_SESSION.::&DEBUG.:42::'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412001515Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(9811867371312833)
,p_name=>'Edit Report - Dialog Closed'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(9808649399312828)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000750Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9812346069312834)
,p_event_id=>wwv_flow_imp.id(9811867371312833)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(9808649399312828)
,p_created_on=>wwv_flow_imp.dz('20250412000750Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000750Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

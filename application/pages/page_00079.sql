prompt --application/pages/page_00079
begin
--   Manifest
--     PAGE: 00079
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
 p_id=>79
,p_name=>'Proceso de Inventario'
,p_alias=>'PROCESO-DE-INVENTARIO'
,p_step_title=>'Proceso de Inventario'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_last_updated_on=>wwv_flow_imp.dz('20251010172547Z')
,p_created_by=>'SIS_APEX'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14747282833426956)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20250930094041Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14747979913426962)
,p_plug_name=>'Proceso de Inventario'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT i.ID_INVENTARIO,',
'       i.NRO_DOCUMENTO,',
'       o.DESCRIPCION AS OFICINA,',
'       i.FECHA_INVENTARIO,',
'       i.ESTADO,',
'       (SELECT COUNT(*) FROM INVENTARIO_DETALLE d WHERE d.ID_INVENTARIO = i.ID_INVENTARIO) AS ITEMS,',
'       (SELECT SUM(d.DIFERENCIA) FROM INVENTARIO_DETALLE d WHERE d.ID_INVENTARIO = i.ID_INVENTARIO) AS DIF_TOTAL',
'  FROM INVENTARIO i',
'  JOIN OFICINAS o ON o.CODIGO_OFICINA = i.ID_OFICINA',
'  WHERE I.ESTADO = ''BORRADOR''',
' ORDER BY i.ID_INVENTARIO DESC',
''))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Proceso de Inventario'
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20251010172547Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(14748086050426962)
,p_name=>'Proceso de Inventario'
,p_max_row_count_message=>'The maximum row count for this report is #MAX_ROW_COUNT# rows.  Please apply a filter to reduce the number of records in your query.'
,p_no_data_found_message=>'No data found.'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_owner=>'SIS_APEX'
,p_internal_uid=>14748086050426962
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20251010171351Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(14748720119426966)
,p_db_column_name=>'ID_INVENTARIO'
,p_display_order=>1
,p_column_identifier=>'A'
,p_column_label=>'Id Inventario'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20250930094041Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(14749151965426968)
,p_db_column_name=>'NRO_DOCUMENTO'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Nro Documento'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20250930094041Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(14749536946426968)
,p_db_column_name=>'OFICINA'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Oficina'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20250930094041Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(14749997889426968)
,p_db_column_name=>'FECHA_INVENTARIO'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Fecha Inventario'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20250930094041Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(14750330964426968)
,p_db_column_name=>'ESTADO'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Estado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20250930094041Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(14750776833426969)
,p_db_column_name=>'ITEMS'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Items'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20250930094041Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(14751196870426969)
,p_db_column_name=>'DIF_TOTAL'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>'Dif Total'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20250930094041Z')
,p_updated_on=>wwv_flow_imp.dz('20251010171351Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(14805243860056139)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'148053'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID_INVENTARIO:NRO_DOCUMENTO:OFICINA:FECHA_INVENTARIO:ESTADO:ITEMS:DIF_TOTAL'
,p_created_on=>wwv_flow_imp.dz('20250930112533Z')
,p_updated_on=>wwv_flow_imp.dz('20250930112533Z')
,p_created_by=>'TCASCO'
,p_updated_by=>'TCASCO'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9719900525137647)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14747282833426956)
,p_button_name=>'Crear'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'CREATE'
,p_button_redirect_url=>'f?p=&APP_ID.:84:&SESSION.::&DEBUG.:84:P84_ID_INVENTARIO:'
,p_created_on=>wwv_flow_imp.dz('20250930113229Z')
,p_updated_on=>wwv_flow_imp.dz('20250930113301Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15277869675490616)
,p_name=>'New'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(14747979913426962)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
,p_created_on=>wwv_flow_imp.dz('20251010003251Z')
,p_updated_on=>wwv_flow_imp.dz('20251010003251Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15277919975490617)
,p_event_id=>wwv_flow_imp.id(15277869675490616)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14747979913426962)
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20251010003251Z')
,p_updated_on=>wwv_flow_imp.dz('20251010003251Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

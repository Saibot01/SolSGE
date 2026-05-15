prompt --application/pages/page_00059
begin
--   Manifest
--     PAGE: 00059
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
 p_id=>59
,p_name=>'Reservas de Productos'
,p_alias=>'RESERVAS-DE-PRODUCTOS'
,p_step_title=>'Reservas de Productos'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12150151382730084)
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
 p_id=>wwv_flow_imp.id(12150849631730084)
,p_plug_name=>'Reservas de Productos'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'RESERVAS_PRODUCTO'
,p_include_rowid_column=>false
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Reservas de Productos'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(12150959656730084)
,p_name=>'Reservas de Productos'
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
,p_owner=>'WILLIAN'
,p_internal_uid=>12150959656730084
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(12151968915730171)
,p_db_column_name=>'ID_RESERVA'
,p_display_order=>0
,p_is_primary_key=>'Y'
,p_column_identifier=>'A'
,p_column_label=>'Id Reserva'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(12152368426730171)
,p_db_column_name=>'ID_PRODUCTO'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Id Producto'
,p_column_type=>'STRING'
,p_display_text_as=>'LOV_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_rpt_named_lov=>wwv_flow_imp.id(11765368439189441)
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(12152749478730172)
,p_db_column_name=>'ID_OFICINA'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Id Oficina'
,p_column_type=>'STRING'
,p_display_text_as=>'LOV_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_rpt_named_lov=>wwv_flow_imp.id(8245359747955872)
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(12153132265730172)
,p_db_column_name=>'CANTIDAD_RESERVADA'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Cantidad Reservada'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(12153535161730172)
,p_db_column_name=>'FECHA_RESERVA'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Fecha Reserva'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(12153900248730172)
,p_db_column_name=>'ESTADO'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Estado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(12154301463730173)
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
 p_id=>wwv_flow_imp.id(12154780498730173)
,p_db_column_name=>'ID_ORDEN_VENTA'
,p_display_order=>8
,p_column_identifier=>'H'
,p_column_label=>'Id Orden Venta'
,p_column_type=>'STRING'
,p_display_text_as=>'LOV_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_rpt_named_lov=>wwv_flow_imp.id(12151050193730169)
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(12155150084730888)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'121552'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID_RESERVA:ID_PRODUCTO:ID_OFICINA:CANTIDAD_RESERVADA:FECHA_RESERVA:ESTADO:OBSERVACION:ID_ORDEN_VENTA'
);
wwv_flow_imp.component_end;
end;
/

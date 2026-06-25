prompt --application/pages/page_00129
begin
--   Manifest
--     PAGE: 00129
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
 p_id=>129
,p_name=>'Reversos de Cobro'
,p_alias=>'REVERSOS-DE-COBRO'
,p_step_title=>'Reversos de Cobro'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23157706952069535)
,p_plug_name=>'Reversos de Cobro'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_SOLICITUD_RC,',
'  CASE ESTADO WHEN ''P'' THEN ''Pendiente'' WHEN ''A'' THEN ''Aprobado'' WHEN ''R'' THEN ''Rechazado'' END AS ESTADO,',
'  MOTIVO, ID_MOVIMIENTO, NRO_RECIBO, FECHA_COBRO, MONTO, ID_CUENTA_COBRAR_DET,',
'  ID_CXC, NRO_CUOTA, ESTADO_CUOTA, ID_CLIENTE, CLIENTE_NOMBRE,',
'  USUARIO_SOLICITA, FECHA_SOLICITUD, USUARIO_APRUEBA, FECHA_RESOLUCION,',
'  MOTIVO_RECHAZO, ID_MOVIMIENTO_EGRESO',
'FROM WKSP_WORKPLACE.V_SOLICITUDES_REVERSO'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'MILLIMETERS'
,p_prn_paper_size=>'A4'
,p_prn_width=>297
,p_prn_height=>210
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header_font_color=>'#000000'
,p_prn_page_header_font_family=>'Helvetica'
,p_prn_page_header_font_weight=>'normal'
,p_prn_page_header_font_size=>'12'
,p_prn_page_footer_font_color=>'#000000'
,p_prn_page_footer_font_family=>'Helvetica'
,p_prn_page_footer_font_weight=>'normal'
,p_prn_page_footer_font_size=>'12'
,p_prn_header_bg_color=>'#EEEEEE'
,p_prn_header_font_color=>'#000000'
,p_prn_header_font_family=>'Helvetica'
,p_prn_header_font_weight=>'bold'
,p_prn_header_font_size=>'10'
,p_prn_body_bg_color=>'#FFFFFF'
,p_prn_body_font_color=>'#000000'
,p_prn_body_font_family=>'Helvetica'
,p_prn_body_font_weight=>'normal'
,p_prn_body_font_size=>'10'
,p_prn_border_width=>.5
,p_prn_page_header_alignment=>'CENTER'
,p_prn_page_footer_alignment=>'CENTER'
,p_prn_border_color=>'#666666'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(23157820445069536)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:130:&SESSION.::&DEBUG.:130:P130_ID_SOLICITUD:#ID_SOLICITUD_RC#'
,p_detail_link_text=>'<span aria-hidden="true" class="fa fa-share-square"></span> Resolver'
,p_owner=>'SIS_APEX'
,p_internal_uid=>23157820445069536
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(23910000000000100)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'RC129PRIN'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ESTADO:NRO_RECIBO:FECHA_COBRO:MONTO:NRO_CUOTA:ESTADO_CUOTA:CLIENTE_NOMBRE:MOTIVO:USUARIO_SOLICITA:FECHA_SOLICITUD:USUARIO_APRUEBA:FECHA_RESOLUCION:MOTIVO_RECHAZO'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23157970457069537)
,p_db_column_name=>'ID_SOLICITUD_RC'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Id Solicitud Rc'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158070452069538)
,p_db_column_name=>'ESTADO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Estado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158136449069539)
,p_db_column_name=>'MOTIVO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Motivo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158256990069540)
,p_db_column_name=>'ID_MOVIMIENTO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Id Movimiento'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158341269069541)
,p_db_column_name=>'NRO_RECIBO'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Nro Recibo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158497221069542)
,p_db_column_name=>'FECHA_COBRO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Fecha Cobro'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158507441069543)
,p_db_column_name=>'MONTO'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Monto'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158696982069544)
,p_db_column_name=>'ID_CUENTA_COBRAR_DET'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Id Cuenta Cobrar Det'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158749260069545)
,p_db_column_name=>'ID_CXC'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Id Cxc'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158812662069546)
,p_db_column_name=>'NRO_CUOTA'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Nro Cuota'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23158945270069547)
,p_db_column_name=>'ESTADO_CUOTA'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Estado Cuota'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23159094243069548)
,p_db_column_name=>'ID_CLIENTE'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'Id Cliente'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23159181288069549)
,p_db_column_name=>'CLIENTE_NOMBRE'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'Cliente Nombre'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23159261286069550)
,p_db_column_name=>'USUARIO_SOLICITA'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'Usuario Solicita'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23785338521550701)
,p_db_column_name=>'FECHA_SOLICITUD'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'Fecha Solicitud'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23785455040550702)
,p_db_column_name=>'USUARIO_APRUEBA'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'Usuario Aprueba'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23785591767550703)
,p_db_column_name=>'FECHA_RESOLUCION'
,p_display_order=>170
,p_column_identifier=>'Q'
,p_column_label=>'Fecha Resolucion'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23785643712550704)
,p_db_column_name=>'MOTIVO_RECHAZO'
,p_display_order=>180
,p_column_identifier=>'R'
,p_column_label=>'Motivo Rechazo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23785754167550705)
,p_db_column_name=>'ID_MOVIMIENTO_EGRESO'
,p_display_order=>190
,p_column_identifier=>'S'
,p_column_label=>'Id Movimiento Egreso'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23784608785534881)
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
wwv_flow_imp.component_end;
end;
/

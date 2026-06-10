prompt --application/pages/page_00120
begin
--   Manifest
--     PAGE: 00120
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
 p_id=>120
,p_name=>'Anulaciones de Facturas'
,p_alias=>'ANULACIONES-DE-FACTURAS'
,p_step_title=>'Anulaciones de Facturas'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23053753830849651)
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
 p_id=>wwv_flow_imp.id(23054426910849657)
,p_plug_name=>'Anulaciones de Facturas'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'  ID_COMPROBANTE,',
'  NRO_COMPROBANTE,',
'  FECHA,',
'  CLIENTE_NOMBRE,',
'  TOTAL_MONEDA_LOCAL,',
'  MONEDA,',
'  CASE ESTADO',
'    WHEN ''P'' THEN ''Pendiente''',
'    WHEN ''N'' THEN ''Anulada''',
'  END AS ESTADO_P,',
'  CASE ESTADO',
'    WHEN ''P'' THEN ''<span class="t-Label t-Label--warning">Pendiente</span>''',
'    WHEN ''N'' THEN ''<span class="t-Label t-Label--danger">Anulada</span>''',
'  END AS ESTADO_BADGE,',
'  MOTIVO_ANULACION,',
'  USUARIO_SOLICITA,',
'  FECHA_SOLICITUD,',
'  USUARIO_APRUEBA,',
'  FECHA_RESOLUCION,',
'  MOTIVO_RECHAZO,',
'  OFICINA_NOMBRE',
'FROM V_ANULACIONES_FACTURAS',
'ORDER BY DECODE(ESTADO,''P'',0,1), FECHA_SOLICITUD DESC NULLS LAST, FECHA DESC'))
,p_plug_source_type=>'NATIVE_IR'
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
 p_id=>wwv_flow_imp.id(23002993744484146)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:121:&SESSION.::&DEBUG.::P121_ID_COMPROBANTE:#ID_COMPROBANTE#'
,p_detail_link_text=>'<span role="img" aria-label="Edit" class="fa fa-edit" title="Edit"></span>'
,p_owner=>'SIS_APEX'
,p_internal_uid=>23002993744484146
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23003068640484147)
,p_db_column_name=>'ID_COMPROBANTE'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Id Comprobante'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23003128535484148)
,p_db_column_name=>'NRO_COMPROBANTE'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Nro Comprobante'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23003289003484149)
,p_db_column_name=>'FECHA'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Fecha'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY HH24:MI'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23003302946484150)
,p_db_column_name=>'CLIENTE_NOMBRE'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Cliente Nombre'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23063136812889401)
,p_db_column_name=>'TOTAL_MONEDA_LOCAL'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Total Moneda Local'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23063247889889402)
,p_db_column_name=>'MONEDA'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Moneda'
,p_column_type=>'STRING'
,p_display_text_as=>'LOV_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_rpt_named_lov=>wwv_flow_imp.id(16216046217015840)
,p_rpt_show_filter_lov=>'1'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23063428117889404)
,p_db_column_name=>'ESTADO_BADGE'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Estado Badge'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23063528879889405)
,p_db_column_name=>'MOTIVO_ANULACION'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Motivo Anulacion'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23063638183889406)
,p_db_column_name=>'USUARIO_SOLICITA'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Usuario Solicita'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23063761247889407)
,p_db_column_name=>'FECHA_SOLICITUD'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Fecha Solicitud'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY HH24:MI'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23063818200889408)
,p_db_column_name=>'USUARIO_APRUEBA'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'Usuario Aprueba'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23063938885889409)
,p_db_column_name=>'FECHA_RESOLUCION'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'Fecha Resolucion'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY HH24:MI'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23064075378889410)
,p_db_column_name=>'MOTIVO_RECHAZO'
,p_display_order=>140
,p_column_identifier=>'N'
,p_column_label=>'Motivo Rechazo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23064199309889411)
,p_db_column_name=>'OFICINA_NOMBRE'
,p_display_order=>150
,p_column_identifier=>'O'
,p_column_label=>'Oficina Nombre'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23154328678069501)
,p_db_column_name=>'ESTADO_P'
,p_display_order=>160
,p_column_identifier=>'P'
,p_column_label=>'Estado'
,p_column_html_expression=>'<span class="t-Badge #ESTADO_BADGE#">#ESTADO_P#</span>'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(23080030138953695)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'230801'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID_COMPROBANTE:NRO_COMPROBANTE:FECHA:CLIENTE_NOMBRE:TOTAL_MONEDA_LOCAL:MONEDA:ESTADO_BADGE:MOTIVO_ANULACION:USUARIO_SOLICITA:FECHA_SOLICITUD:USUARIO_APRUEBA:FECHA_RESOLUCION:MOTIVO_RECHAZO:OFICINA_NOMBRE'
);
wwv_flow_imp.component_end;
end;
/

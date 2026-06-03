prompt --application/pages/page_00111
begin
--   Manifest
--     PAGE: 00111
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.16'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_page.create_page(
 p_id=>111
,p_name=>'Anulados y Vencidos'
,p_alias=>'ANULADOS-Y-VENCIDOS'
,p_step_title=>'Anulados y Vencidos'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(21975881681430703)
,p_plug_name=>'Presupuestos Anulados y Vencidos'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select o.ID_ORDEN,',
'          o.FECHA_ORDEN,',
'          o.FECHA_VENCIMIENTO,',
'          o.FECHA_ANULACION,',
'          p.PRIMER_NOMBRE || '' '' || p.PRIMER_APELLIDO as CLIENTE,',
'          f.DESCRIPCION as OFICINA,',
'          o.TOTAL,',
'          o.ESTADO,',
'          case when O.ESTADO = ''ANULADO'' then ''t-Badge--danger'' else ''t-Badge--muted'' end as ESTADO_CLASS,',
'          o.USUARIO_ANULACION,',
'          o.MOTIVO_ANULACION',
'     from ORDENES_VENTA o',
'     left join PERSONAS p on p.ID_PERSONA      = o.ID_PERSONA',
'     left join OFICINAS f on f.CODIGO_OFICINA  = o.ID_OFICINA',
'    where o.ESTADO IN (''ANULADO'',''VENCIDO'')',
'    order by coalesce(o.FECHA_ANULACION, o.FECHA_VENCIMIENTO) desc'))
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
 p_id=>wwv_flow_imp.id(21975910443430704)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:6:&SESSION.::&DEBUG.::P6_ID_ORDEN:#ID_ORDEN#'
,p_detail_link_text=>'<span class="fa fa-print" title="Imprimir"></span>'
,p_owner=>'SIS_APEX'
,p_internal_uid=>21975910443430704
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976061068430705)
,p_db_column_name=>'ID_ORDEN'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Id Orden'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976152208430706)
,p_db_column_name=>'FECHA_ORDEN'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Fecha Orden'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976238269430707)
,p_db_column_name=>'FECHA_VENCIMIENTO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Fecha Vencimiento'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976324602430708)
,p_db_column_name=>'FECHA_ANULACION'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Fecha Anulacion'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976489146430709)
,p_db_column_name=>'CLIENTE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Cliente'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976522776430710)
,p_db_column_name=>'OFICINA'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Oficina'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976612910430711)
,p_db_column_name=>'TOTAL'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Total'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_format_mask=>'FML999G999G999G999G990D00'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976767198430712)
,p_db_column_name=>'ESTADO'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Estado'
,p_column_html_expression=>'<span class="t-Badge #ESTADO_CLASS#">#ESTADO#</span>'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976865438430713)
,p_db_column_name=>'USUARIO_ANULACION'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Usuario Anulacion'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21976975354430714)
,p_db_column_name=>'MOTIVO_ANULACION'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Motivo Anulacion'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(21977018418430715)
,p_db_column_name=>'ESTADO_CLASS'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Estado Class'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(22390306962481076)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'223904'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID_ORDEN:CLIENTE:OFICINA:TOTAL:ESTADO:FECHA_ORDEN:FECHA_VENCIMIENTO:FECHA_ANULACION:USUARIO_ANULACION:MOTIVO_ANULACION:'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(22384329371345763)
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

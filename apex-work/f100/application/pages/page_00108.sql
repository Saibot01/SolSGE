prompt --application/pages/page_00108
begin
--   Manifest
--     PAGE: 00108
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
 p_id=>108
,p_name=>unistr('M\00E1rgenes por Categor\00EDa')
,p_alias=>unistr('M\00C1RGENES-POR-CATEGOR\00CDA')
,p_step_title=>unistr('M\00E1rgenes por Categor\00EDa')
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(20607077198469419)
,p_plug_name=>unistr('M\00E1rgenes Vigentes')
,p_title=>unistr('M\00E1rgenes Vigentes')
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT mc.id_margen,',
'         mc.id_categoria,',
'         c.nombre AS categoria,',
'         mc.categoria_cliente AS segmento,',
'         mc.porcentaje,',
'         mc.fecha_inicio,',
'         mc.usuario_creacion',
'  FROM   MARGEN_CATEGORIA mc',
'  JOIN   CATEGORIAS_PRODUCTOS c ON c.id_categoria = mc.id_categoria',
'  WHERE  mc.estado    = ''ACTIVO''',
'    AND  mc.fecha_fin IS NULL',
'  ORDER BY c.nombre, mc.categoria_cliente'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'MILLIMETERS'
,p_prn_paper_size=>'A4'
,p_prn_width=>297
,p_prn_height=>210
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header=>unistr('M\00E1rgenes Vigentes')
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
 p_id=>wwv_flow_imp.id(20607191091469420)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:109:&SESSION.::&DEBUG.::P109_ID_MARGEN:&ID_MARGEN.'
,p_detail_link_text=>'<span role="img" aria-label="Cambiar margen" class="fa fa-edit" title="Edit"></span>'
,p_owner=>'SIS_APEX'
,p_internal_uid=>20607191091469420
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20607223610469421)
,p_db_column_name=>'ID_MARGEN'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Id Margen'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20607337946469422)
,p_db_column_name=>'ID_CATEGORIA'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Id Categoria'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20607454051469423)
,p_db_column_name=>'CATEGORIA'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Categoria'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20607539775469424)
,p_db_column_name=>'SEGMENTO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Segmento'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20607673872469425)
,p_db_column_name=>'PORCENTAJE'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Porcentaje'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_format_mask=>'FM999G990D00'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20607786355469426)
,p_db_column_name=>'FECHA_INICIO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Fecha Inicio'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20607829291469427)
,p_db_column_name=>'USUARIO_CREACION'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Usuario Creacion'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(21307923180125417)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'213080'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ID_MARGEN:ID_CATEGORIA:CATEGORIA:SEGMENTO:PORCENTAJE:FECHA_INICIO:USUARIO_CREACION'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(20607965675469428)
,p_plug_name=>'Historial'
,p_title=>'Historial'
,p_region_template_options=>'#DEFAULT#:is-expanded:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2664334895415463485
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT c.nombre AS categoria,',
'         mc.categoria_cliente AS segmento,',
'         mc.porcentaje,',
'         mc.fecha_inicio,',
'         mc.fecha_fin,',
'         mc.estado,',
'         mc.usuario_creacion AS creado_por,',
'         mc.fecha_creacion,',
'         mc.usuario_modificacion AS modificado_por,',
'         mc.fecha_modificacion',
'  FROM   MARGEN_CATEGORIA mc',
'  JOIN   CATEGORIAS_PRODUCTOS c ON c.id_categoria = mc.id_categoria',
'  ORDER BY c.nombre, mc.categoria_cliente, mc.fecha_inicio DESC'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_content_disposition=>'ATTACHMENT'
,p_prn_units=>'MILLIMETERS'
,p_prn_paper_size=>'A4'
,p_prn_width=>297
,p_prn_height=>210
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header=>'Historial'
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
 p_id=>wwv_flow_imp.id(20608099477469429)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_owner=>'SIS_APEX'
,p_internal_uid=>20608099477469429
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608125867469430)
,p_db_column_name=>'CATEGORIA'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Categoria'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608231068469431)
,p_db_column_name=>'SEGMENTO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Segmento'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608355792469432)
,p_db_column_name=>'PORCENTAJE'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Porcentaje'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608440206469433)
,p_db_column_name=>'FECHA_INICIO'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Fecha Inicio'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608587328469434)
,p_db_column_name=>'FECHA_FIN'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Fecha Fin'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608626520469435)
,p_db_column_name=>'ESTADO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Estado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608771103469436)
,p_db_column_name=>'CREADO_POR'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Creado Por'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608816796469437)
,p_db_column_name=>'FECHA_CREACION'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Fecha Creacion'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20608914718469438)
,p_db_column_name=>'MODIFICADO_POR'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Modificado Por'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(20609054012469439)
,p_db_column_name=>'FECHA_MODIFICACION'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Fecha Modificacion'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(21308466969125444)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'213085'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'CATEGORIA:SEGMENTO:PORCENTAJE:FECHA_INICIO:FECHA_FIN:ESTADO:CREADO_POR:FECHA_CREACION:MODIFICADO_POR:FECHA_MODIFICACION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20609166286469440)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(20607077198469419)
,p_button_name=>'Create'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Nuevo Margen'
,p_button_redirect_url=>'f?p=&APP_ID.:109:&SESSION.::&DEBUG.:109::'
,p_grid_new_row=>'Y'
);
wwv_flow_imp.component_end;
end;
/

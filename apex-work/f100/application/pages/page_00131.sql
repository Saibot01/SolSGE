prompt --application/pages/page_00131
begin
--   Manifest
--     PAGE: 00131
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
 p_id=>131
,p_name=>'Recibos de Cobro'
,p_alias=>'RECIBOS-DE-COBRO'
,p_step_title=>'Recibos de Cobro'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23803762974234787)
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
 p_id=>wwv_flow_imp.id(23804634639235501)
,p_plug_name=>'Recibos de Cobro'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_RECIBO, NRO_RECIBO, FECHA_EMISION_RECIBO, TOTAL_MONEDA_LOCAL, MONEDA,',
'       USUARIO, NRO_CUOTA, ID_CXC, COMPROBANTE_ORIGEN, FACTURA_NRO, ID_PERSONA,',
'       CLIENTE_NOMBRE,',
'       CASE REVERSADO WHEN ''S'' THEN ''Reversado'' ELSE ''Vigente'' END AS REVERSADO',
'FROM WKSP_WORKPLACE.V_RECIBOS_LISTA'))
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
 p_id=>wwv_flow_imp.id(23804737875235502)
,p_max_row_count=>'1000000'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>'Y'
,p_detail_link=>'f?p=&APP_ID.:119:&SESSION.::&DEBUG.:119:P119_ID_RECIBO:#ID_RECIBO#'
,p_detail_link_text=>'<span aria-hidden="true" class="fa fa-print"></span> Recibo'
,p_owner=>'SIS_APEX'
,p_internal_uid=>23804737875235502
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(23930000000000200)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'RC131PRIN'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'NRO_RECIBO:FECHA_EMISION_RECIBO:CLIENTE_NOMBRE:NRO_CUOTA:FACTURA_NRO:TOTAL_MONEDA_LOCAL:MONEDA:USUARIO:REVERSADO'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23804802889235503)
,p_db_column_name=>'ID_RECIBO'
,p_display_order=>10
,p_column_identifier=>'A'
,p_column_label=>'Id Recibo'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23804981951235504)
,p_db_column_name=>'NRO_RECIBO'
,p_display_order=>20
,p_column_identifier=>'B'
,p_column_label=>'Nro Recibo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805065660235505)
,p_db_column_name=>'FECHA_EMISION_RECIBO'
,p_display_order=>30
,p_column_identifier=>'C'
,p_column_label=>'Fecha Emision Recibo'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805167207235506)
,p_db_column_name=>'TOTAL_MONEDA_LOCAL'
,p_display_order=>40
,p_column_identifier=>'D'
,p_column_label=>'Total Moneda Local'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805273605235507)
,p_db_column_name=>'MONEDA'
,p_display_order=>50
,p_column_identifier=>'E'
,p_column_label=>'Moneda'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805318063235508)
,p_db_column_name=>'USUARIO'
,p_display_order=>60
,p_column_identifier=>'F'
,p_column_label=>'Usuario'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805499892235509)
,p_db_column_name=>'NRO_CUOTA'
,p_display_order=>70
,p_column_identifier=>'G'
,p_column_label=>'Nro Cuota'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805586109235510)
,p_db_column_name=>'ID_CXC'
,p_display_order=>80
,p_column_identifier=>'H'
,p_column_label=>'Id Cxc'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805671546235511)
,p_db_column_name=>'COMPROBANTE_ORIGEN'
,p_display_order=>90
,p_column_identifier=>'I'
,p_column_label=>'Comprobante Origen'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805799688235512)
,p_db_column_name=>'FACTURA_NRO'
,p_display_order=>100
,p_column_identifier=>'J'
,p_column_label=>'Factura Nro'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805852362235513)
,p_db_column_name=>'ID_PERSONA'
,p_display_order=>110
,p_column_identifier=>'K'
,p_column_label=>'Id Persona'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23805901981235514)
,p_db_column_name=>'CLIENTE_NOMBRE'
,p_display_order=>120
,p_column_identifier=>'L'
,p_column_label=>'Cliente Nombre'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23806044173235515)
,p_db_column_name=>'REVERSADO'
,p_display_order=>130
,p_column_identifier=>'M'
,p_column_label=>'Reversado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_use_as_row_header=>'N'
);
wwv_flow_imp.component_end;
end;
/

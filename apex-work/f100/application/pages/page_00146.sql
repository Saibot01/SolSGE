prompt --application/pages/page_00146
begin
--   Manifest
--     PAGE: 00146
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
 p_id=>146
,p_name=>'Deuda a Proveedores'
,p_alias=>'DEUDA-A-PROVEEDORES'
,p_step_title=>'Deuda a Proveedores'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000146010)
,p_plug_name=>'Deuda a Proveedores'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT id_cxp,',
'       id_proveedor,',
'       proveedor,',
'       nro_comprobante,',
'       fecha_emision,',
'       total_a_pagar,',
'       saldo,',
'       fecha_vencimiento,',
'       dias_atraso,',
'       situacion,',
'       estado',
'  FROM WKSP_WORKPLACE.V_CXP_DEUDA'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Deuda a Proveedores'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(36000000000146050)
,p_name=>'Deuda a Proveedores'
,p_max_row_count_message=>'El m&aacute;ximo de filas es #MAX_ROW_COUNT#. Aplique un filtro.'
,p_no_data_found_message=>'No hay deuda a proveedores registrada.'
,p_base_pk1=>'ID_CXP'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'N'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_owner=>'SIS_APEX'
,p_internal_uid=>36000000000146050
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146051)
,p_db_column_name=>'ID_CXP'
,p_display_order=>1
,p_is_primary_key=>'Y'
,p_column_identifier=>'A'
,p_column_label=>'Id CxP'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146052)
,p_db_column_name=>'ID_PROVEEDOR'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Id Proveedor'
,p_column_type=>'NUMBER'
,p_display_text_as=>'HIDDEN_ESCAPE_SC'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146053)
,p_db_column_name=>'PROVEEDOR'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Proveedor'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'Y'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146054)
,p_db_column_name=>'NRO_COMPROBANTE'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Comprobante'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146055)
,p_db_column_name=>'FECHA_EMISION'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>unistr('Emisi\00F3n')
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_column_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146056)
,p_db_column_name=>'TOTAL_A_PAGAR'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Total'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_format_mask=>'FML999G999G999G990'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146057)
,p_db_column_name=>'SALDO'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>'Saldo'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_format_mask=>'FML999G999G999G990'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146058)
,p_db_column_name=>'FECHA_VENCIMIENTO'
,p_display_order=>8
,p_column_identifier=>'H'
,p_column_label=>'Vencimiento'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_column_alignment=>'LEFT'
,p_format_mask=>'DD/MM/YYYY'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146059)
,p_db_column_name=>'DIAS_ATRASO'
,p_display_order=>9
,p_column_identifier=>'I'
,p_column_label=>unistr('D\00EDas atraso')
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_format_mask=>'999G999G990'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146060)
,p_db_column_name=>'SITUACION'
,p_display_order=>10
,p_column_identifier=>'J'
,p_column_label=>unistr('Situaci\00F3n')
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000146061)
,p_db_column_name=>'ESTADO'
,p_display_order=>11
,p_column_identifier=>'K'
,p_column_label=>'Estado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(36000000000146070)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'CXPDEU1'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'PROVEEDOR:NRO_COMPROBANTE:FECHA_EMISION:TOTAL_A_PAGAR:SALDO:FECHA_VENCIMIENTO:DIAS_ATRASO:SITUACION:ESTADO'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000146020)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000146010)
,p_button_name=>'GENERAR_OP'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Generar Orden de Pago'
,p_button_position=>'RIGHT_OF_IR_SEARCH_BAR'
,p_button_redirect_url=>'f?p=&APP_ID.:147:&APP_SESSION.::&DEBUG.:::'
,p_icon_css_classes=>'fa-money'
);
wwv_flow_imp.component_end;
end;
/

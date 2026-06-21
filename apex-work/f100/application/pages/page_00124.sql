prompt --application/pages/page_00124
begin
--   Manifest
--     PAGE: 00124
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
 p_id=>124
,p_name=>unistr('Notas de Cr\00E9dito')
,p_alias=>unistr('NOTAS-DE-CR\00C9DITO')
,p_step_title=>unistr('Notas de Cr\00E9dito')
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'18'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23241670196193118)
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
 p_id=>wwv_flow_imp.id(23242350822193120)
,p_plug_name=>unistr('Notas de Cr\00E9dito')
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_SOLICITUD_NC,',
'  CASE ESTADO WHEN ''P'' THEN ''Pendiente'' WHEN ''A'' THEN ''Aprobada'' WHEN ''R'' THEN ''Rechazada'' END AS ESTADO,',
'  CASE TIPO_NC WHEN ''T'' THEN ''Total'' WHEN ''P'' THEN ''Parcial'' END AS TIPO_NC,',
'  CASE DEVUELVE_STOCK WHEN ''S'' THEN ''Si'' ELSE ''No'' END AS DEVUELVE_STOCK,',
'  COD_MOTIVO, MOTIVO, OBSERVACION, ID_COMPROBANTE_ORIGEN, FACTURA_NRO,',
'  CASE FACTURA_FORMA_PAGO WHEN ''1'' THEN ''Credito'' ELSE ''Contado'' END AS FACTURA_FORMA_PAGO,',
'  FACTURA_TOTAL, ID_CLIENTE, CLIENTE_NOMBRE, USUARIO_SOLICITA, FECHA_SOLICITUD,',
'  USUARIO_APRUEBA, FECHA_RESOLUCION, MOTIVO_RECHAZO, ID_NC_GENERADA, NC_NRO',
'FROM V_SOLICITUDES_NC'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>unistr('Notas de Cr\00E9dito')
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(23242426772193120)
,p_name=>unistr('Notas de Cr\00E9dito')
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
,p_detail_link=>'f?p=&APP_ID.:126:&SESSION.::&DEBUG.:126:P126_ID_SOLICITUD:#ID_SOLICITUD_NC#'
,p_detail_link_text=>'<span aria-hidden="true" class="fa fa-share-square"></span> Resolver'
,p_owner=>'SIS_APEX'
,p_internal_uid=>23242426772193120
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(23270000000000100)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'NC124PRIN'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'ESTADO:TIPO_NC:MOTIVO:FACTURA_NRO:FACTURA_FORMA_PAGO:FACTURA_TOTAL:CLIENTE_NOMBRE:OBSERVACION:DEVUELVE_STOCK:USUARIO_SOLICITA:FECHA_SOLICITUD:USUARIO_APRUEBA:FECHA_RESOLUCION:MOTIVO_RECHAZO:NC_NRO'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23243145644193123)
,p_db_column_name=>'ID_SOLICITUD_NC'
,p_display_order=>1
,p_column_identifier=>'A'
,p_column_label=>'Id Solicitud Nc'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23243529269193124)
,p_db_column_name=>'ESTADO'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Estado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23243977920193125)
,p_db_column_name=>'TIPO_NC'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>'Tipo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23244369929193126)
,p_db_column_name=>'DEVUELVE_STOCK'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Devuelve Stock'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23244725976193126)
,p_db_column_name=>'COD_MOTIVO'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Cod Motivo'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23245196211193127)
,p_db_column_name=>'MOTIVO'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Motivo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23245500329193128)
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
 p_id=>wwv_flow_imp.id(23245924915193129)
,p_db_column_name=>'ID_COMPROBANTE_ORIGEN'
,p_display_order=>8
,p_column_identifier=>'H'
,p_column_label=>'Id Comprobante Origen'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23246360504193130)
,p_db_column_name=>'FACTURA_NRO'
,p_display_order=>9
,p_column_identifier=>'I'
,p_column_label=>'Factura Nro'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23246700705193131)
,p_db_column_name=>'FACTURA_FORMA_PAGO'
,p_display_order=>10
,p_column_identifier=>'J'
,p_column_label=>'Forma de Pago'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23247125283193132)
,p_db_column_name=>'FACTURA_TOTAL'
,p_display_order=>11
,p_column_identifier=>'K'
,p_column_label=>'Factura Total'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23247598583193132)
,p_db_column_name=>'ID_CLIENTE'
,p_display_order=>12
,p_column_identifier=>'L'
,p_column_label=>'Id Cliente'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23247998100193133)
,p_db_column_name=>'CLIENTE_NOMBRE'
,p_display_order=>13
,p_column_identifier=>'M'
,p_column_label=>'Cliente Nombre'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23248396267193134)
,p_db_column_name=>'USUARIO_SOLICITA'
,p_display_order=>14
,p_column_identifier=>'N'
,p_column_label=>'Usuario Solicita'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23248724703193135)
,p_db_column_name=>'FECHA_SOLICITUD'
,p_display_order=>15
,p_column_identifier=>'O'
,p_column_label=>'Fecha Solicitud'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23249199252193136)
,p_db_column_name=>'USUARIO_APRUEBA'
,p_display_order=>16
,p_column_identifier=>'P'
,p_column_label=>'Usuario Aprueba'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23249581557193137)
,p_db_column_name=>'FECHA_RESOLUCION'
,p_display_order=>17
,p_column_identifier=>'Q'
,p_column_label=>'Fecha Resolucion'
,p_column_type=>'DATE'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23249985295193137)
,p_db_column_name=>'MOTIVO_RECHAZO'
,p_display_order=>18
,p_column_identifier=>'R'
,p_column_label=>'Motivo Rechazo'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23250382377193138)
,p_db_column_name=>'ID_NC_GENERADA'
,p_display_order=>19
,p_column_identifier=>'S'
,p_column_label=>'Id Nc Generada'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(23250792390193139)
,p_db_column_name=>'NC_NRO'
,p_display_order=>20
,p_column_identifier=>'T'
,p_column_label=>'Nro NC (imprimir)'
,p_column_link=>'f?p=&APP_ID.:127:&SESSION.::&DEBUG.::P127_ID_COMPROBANTE:#ID_NC_GENERADA#'
,p_column_linktext=>'#NC_NRO#'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp.component_end;
end;
/

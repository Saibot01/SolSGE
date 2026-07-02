prompt --application/pages/page_00148
begin
--   Manifest
--     PAGE: 00148
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
 p_id=>148
,p_name=>'Ordenes de Pago'
,p_alias=>'ORDENES-DE-PAGO'
,p_step_title=>'Ordenes de Pago'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000148010)
,p_plug_name=>'Ordenes de Pago'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT op.id_orden_pago AS nro,',
'       TRIM(per.primer_nombre||'' ''||per.primer_apellido) AS proveedor,',
'       op.fecha_emision AS emision,',
'       op.total_pago AS total,',
'       op.estado AS estado,',
'       op.fecha_pago AS pago,',
'       mp.nombre AS metodo,',
'       op.usuario AS usuario',
'  FROM WKSP_WORKPLACE.ORDENES_PAGO op',
'  JOIN WKSP_WORKPLACE.PROVEEDORES pr ON pr.id_persona = op.id_proveedor',
'  LEFT JOIN WKSP_WORKPLACE.PERSONAS per ON per.id_persona = pr.id_persona',
'  LEFT JOIN WKSP_WORKPLACE.METODOS_PAGO mp ON mp.id_metodo_pago = op.id_metodo_pago'))
,p_plug_source_type=>'NATIVE_IR'
,p_prn_page_header=>'Ordenes de Pago'
);
wwv_flow_imp_page.create_worksheet(
 p_id=>wwv_flow_imp.id(36000000000148050)
,p_name=>'Ordenes de Pago'
,p_max_row_count_message=>'El m&aacute;ximo de filas es #MAX_ROW_COUNT#. Aplique un filtro.'
,p_no_data_found_message=>'No hay ordenes de pago. Genere una desde Deuda a Proveedores.'
,p_base_pk1=>'NRO'
,p_pagination_type=>'ROWS_X_TO_Y'
,p_pagination_display_pos=>'BOTTOM_RIGHT'
,p_report_list_mode=>'TABS'
,p_lazy_loading=>false
,p_show_detail_link=>'C'
,p_show_notify=>'Y'
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_detail_link=>'f?p=&APP_ID.:150:&APP_SESSION.::&DEBUG.:150:P150_ID_ORDEN_PAGO:\#NRO#\'
,p_detail_link_text=>'<span aria-hidden="true" class="fa fa-share-square"></span> Resolver'
,p_owner=>'SIS_APEX'
,p_internal_uid=>36000000000148050
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000148051)
,p_db_column_name=>'NRO'
,p_display_order=>1
,p_is_primary_key=>'Y'
,p_column_identifier=>'A'
,p_column_label=>'N&deg; OP'
,p_column_link=>'f?p=&APP_ID.:149:&APP_SESSION.::&DEBUG.:149:P149_ID_ORDEN_PAGO:\#NRO#\'
,p_column_linktext=>'#NRO#'
,p_column_type=>'NUMBER'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000148052)
,p_db_column_name=>'PROVEEDOR'
,p_display_order=>2
,p_column_identifier=>'B'
,p_column_label=>'Proveedor'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'Y'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000148053)
,p_db_column_name=>'EMISION'
,p_display_order=>3
,p_column_identifier=>'C'
,p_column_label=>unistr('Emisi\00F3n')
,p_column_type=>'DATE'
,p_format_mask=>'DD/MM/YYYY'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000148054)
,p_db_column_name=>'TOTAL'
,p_display_order=>4
,p_column_identifier=>'D'
,p_column_label=>'Total'
,p_column_type=>'NUMBER'
,p_format_mask=>'FML999G999G999G990'
,p_heading_alignment=>'RIGHT'
,p_column_alignment=>'RIGHT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000148055)
,p_db_column_name=>'ESTADO'
,p_display_order=>5
,p_column_identifier=>'E'
,p_column_label=>'Estado'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000148056)
,p_db_column_name=>'PAGO'
,p_display_order=>6
,p_column_identifier=>'F'
,p_column_label=>'Fecha pago'
,p_column_type=>'DATE'
,p_format_mask=>'DD/MM/YYYY'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000148057)
,p_db_column_name=>'METODO'
,p_display_order=>7
,p_column_identifier=>'G'
,p_column_label=>unistr('M\00E9todo')
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_column(
 p_id=>wwv_flow_imp.id(36000000000148058)
,p_db_column_name=>'USUARIO'
,p_display_order=>8
,p_column_identifier=>'H'
,p_column_label=>'Usuario'
,p_column_type=>'STRING'
,p_heading_alignment=>'LEFT'
,p_tz_dependent=>'N'
,p_use_as_row_header=>'N'
);
wwv_flow_imp_page.create_worksheet_rpt(
 p_id=>wwv_flow_imp.id(36000000000148070)
,p_application_user=>'APXWS_DEFAULT'
,p_report_seq=>10
,p_report_alias=>'ORDPAG1'
,p_status=>'PUBLIC'
,p_is_default=>'Y'
,p_report_columns=>'NRO:PROVEEDOR:EMISION:TOTAL:ESTADO:PAGO:METODO:USUARIO'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000148080)
,p_name=>'Cierre del modal - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(36000000000148010)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000148081)
,p_event_id=>wwv_flow_imp.id(36000000000148080)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000148010)
);
wwv_flow_imp.component_end;
end;
/

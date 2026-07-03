prompt --application/pages/page_00094
begin
--   Manifest
--     PAGE: 00094
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
 p_id=>94
,p_name=>'Nota de Credito Proveedor'
,p_alias=>'NOTA-DE-CREDITO-PROVEEDOR'
,p_step_title=>'Nota de Credito Proveedor'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function applyMask(input) {',
unistr('    // Solo n\00FAmeros'),
'    let value = input.value.replace(/\D/g, '''');',
'',
unistr('    // Limitar a 13 d\00EDgitos m\00E1ximo (3+3+7)'),
'    value = value.substring(0, 13);',
'',
unistr('    // Aplicar m\00E1scara 000-000-0000000'),
'    if (value.length > 6) {',
'        value = value.substring(0, 3) + ''-'' + value.substring(3, 6) + ''-'' + value.substring(6);',
'    } else if (value.length > 3) {',
'        value = value.substring(0, 3) + ''-'' + value.substring(3);',
'    }',
'',
'    input.value = value;',
'}',
''))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000094010)
,p_plug_name=>'Datos de la Nota de Credito'
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000094030)
,p_name=>'Lineas a acreditar'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'  APEX_ITEM.HIDDEN(1, dcp.ID_DETALLE)                        AS F01,',
'  pr.NOMBRE                                                  AS PRODUCTO,',
'  dcp.CANTIDAD                                               AS CANT_FACTURADA,',
'  WKSP_WORKPLACE.FN_CANT_ACREDITABLE_COMPRA(dcp.ID_DETALLE)  AS ACREDITABLE,',
'  WKSP_WORKPLACE.FN_CANT_DEVOLVIBLE_COMPRA(dcp.ID_DETALLE)   AS DEVOLVIBLE,',
'  dcp.PRECIO_UNITARIO                                        AS PRECIO_FACT,',
'  APEX_ITEM.TEXT(p_idx=>2, p_value=>NULL, p_size=>8, p_maxlength=>8,',
'    p_attributes=>''style="text-align:right"'')               AS CANT_ACREDITAR,',
'  APEX_ITEM.TEXT(p_idx=>3, p_value=>TO_CHAR(dcp.PRECIO_UNITARIO), p_size=>14, p_maxlength=>14,',
'    p_attributes=>''style="text-align:right"'')               AS PRECIO_ACREDITAR',
'FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV dcp',
'JOIN WKSP_WORKPLACE.PRODUCTOS pr ON pr.ID_PRODUCTO = dcp.ID_PRODUCTO',
'WHERE dcp.ID_COMPROBANTE = :P94_ID_FACTURA',
'ORDER BY dcp.ID_DETALLE'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P94_ID_FACTURA'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('Eleg\00ED una factura de compra para acreditar.')
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094031)
,p_query_column_id=>1
,p_column_alias=>'F01'
,p_column_display_sequence=>1
,p_column_css_class=>'col-oculta'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094032)
,p_query_column_id=>2
,p_column_alias=>'PRODUCTO'
,p_column_display_sequence=>2
,p_column_heading=>'Producto'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094033)
,p_query_column_id=>3
,p_column_alias=>'CANT_FACTURADA'
,p_column_display_sequence=>3
,p_column_heading=>'Cant. facturada'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094034)
,p_query_column_id=>4
,p_column_alias=>'ACREDITABLE'
,p_column_display_sequence=>4
,p_column_heading=>'Acreditable'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094035)
,p_query_column_id=>5
,p_column_alias=>'DEVOLVIBLE'
,p_column_display_sequence=>5
,p_column_heading=>'Devolvible'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094036)
,p_query_column_id=>6
,p_column_alias=>'PRECIO_FACT'
,p_column_display_sequence=>6
,p_column_heading=>'Precio facturado'
,p_column_format=>'FML999G999G999G990'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094037)
,p_query_column_id=>7
,p_column_alias=>'CANT_ACREDITAR'
,p_column_display_sequence=>7
,p_column_heading=>'Cant. a acreditar'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094038)
,p_query_column_id=>8
,p_column_alias=>'PRECIO_ACREDITAR'
,p_column_display_sequence=>8
,p_column_heading=>'Precio a acreditar'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000094020)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000094030)
,p_button_name=>'REGISTRAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Registrar Nota de Credito'
,p_button_position=>'CHANGE'
,p_icon_css_classes=>'fa-file-text-o'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(36000000000094040)
,p_branch_name=>'BR_RECARGA_P94'
,p_branch_action=>'f?p=&APP_ID.:94:&SESSION.::&DEBUG.:94::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_when_button_id=>wwv_flow_imp.id(36000000000094020)
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000094050)
,p_name=>'P94_ID_FACTURA'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000094010)
,p_prompt=>'Factura de compra'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT c.NRO_COMPROBANTE||'' - ''||TRIM(per.PRIMER_NOMBRE||'' ''||per.PRIMER_APELLIDO)||'' (saldo ''||cp.SALDO||'')'' d,',
'       c.ID_COMPROBANTE r',
'  FROM WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR c',
'  JOIN WKSP_WORKPLACE.CUENTAS_PAGAR cp ON cp.ID_COMPROBANTE = c.ID_COMPROBANTE AND cp.SALDO > 0',
'  JOIN WKSP_WORKPLACE.PROVEEDORES ppr ON ppr.ID_PERSONA = c.ID_PROVEEDOR',
'  LEFT JOIN WKSP_WORKPLACE.PERSONAS per ON per.ID_PERSONA = ppr.ID_PERSONA',
' WHERE c.TIPO_COMPROBANTE = ''FA'' AND c.ESTADO <> ''A'' AND c.FORMA_PAGO = ''1''',
' ORDER BY c.NRO_COMPROBANTE'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>unistr('- eleg\00ED una factura -')
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000094051)
,p_name=>'P94_COD_MOTIVO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(36000000000094010)
,p_prompt=>'Motivo'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DESCRIPCION d, COD_MOTIVO r FROM WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO',
' WHERE ACTIVO = ''S'' ORDER BY COD_MOTIVO'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>unistr('- eleg\00ED el motivo -')
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000094052)
,p_name=>'P94_NRO_COMPROBANTE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(36000000000094010)
,p_prompt=>'Nro de la NC (del proveedor)'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>50
,p_tag_attributes=>'oninput="applyMask(this)"'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000094053)
,p_name=>'P94_NRO_TIMBRADO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(36000000000094010)
,p_prompt=>'Timbrado'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>20
,p_cMaxlength=>20
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000094054)
,p_name=>'P94_FECHA_EMISION'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(36000000000094010)
,p_prompt=>unistr('Fecha de emisi\00F3n')
,p_format_mask=>'YYYY-MM-DD'
,p_display_as=>'NATIVE_DATE_PICKER'
,p_cSize=>15
,p_cMaxlength=>10
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000094055)
,p_name=>'P94_OBSERVACION'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(36000000000094010)
,p_prompt=>unistr('Observaci\00F3n')
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>255
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000094060)
,p_name=>'Cambio de Factura - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P94_ID_FACTURA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000094061)
,p_event_id=>wwv_flow_imp.id(36000000000094060)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000094030)
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000094070)
,p_process_sequence=>10
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'REGISTRAR_NC_COMPRA'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_det   SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();',
'  v_cant  SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();',
'  v_prec  SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();',
'  v_c     NUMBER;',
'  v_p     NUMBER;',
'  v_id_nc NUMBER;',
'BEGIN',
'  IF NVL(APEX_APPLICATION.G_F01.COUNT,0) = 0 THEN',
'    RAISE_APPLICATION_ERROR(-20914, ''No hay lineas para la nota de credito.'');',
'  END IF;',
'  FOR i IN 1 .. APEX_APPLICATION.G_F01.COUNT LOOP',
'    v_c := NVL(TO_NUMBER(REPLACE(REPLACE(TRIM(APEX_APPLICATION.G_F02(i)),''.'',''''),'','','''')), 0);',
'    IF v_c > 0 THEN',
'      v_p := NVL(TO_NUMBER(REPLACE(REPLACE(TRIM(APEX_APPLICATION.G_F03(i)),''.'',''''),'','','''')), 0);',
'      v_det.EXTEND;  v_det(v_det.COUNT)   := TO_NUMBER(APEX_APPLICATION.G_F01(i));',
'      v_cant.EXTEND; v_cant(v_cant.COUNT) := v_c;',
'      v_prec.EXTEND; v_prec(v_prec.COUNT) := v_p;',
'    END IF;',
'  END LOOP;',
'  IF v_det.COUNT = 0 THEN',
'    RAISE_APPLICATION_ERROR(-20914, ''Ingrese al menos una cantidad a acreditar.'');',
'  END IF;',
'  WKSP_WORKPLACE.PRC_REGISTRAR_NC_COMPRA(',
'    p_id_factura      => :P94_ID_FACTURA,',
'    p_cod_motivo      => :P94_COD_MOTIVO,',
'    p_nro_comprobante => :P94_NRO_COMPROBANTE,',
'    p_nro_timbrado    => :P94_NRO_TIMBRADO,',
'    p_fecha_emision   => TO_DATE(:P94_FECHA_EMISION, ''YYYY-MM-DD''),',
'    p_observacion     => :P94_OBSERVACION,',
'    p_det_origen      => v_det,',
'    p_det_cantidad    => v_cant,',
'    p_det_precio      => v_prec,',
'    p_id_nc           => v_id_nc);',
'  apex_application.g_print_success_message :=',
'    ''Nota de credito de compra registrada (Nro interno ''||v_id_nc||'').'';',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(36000000000094020)
,p_internal_uid=>36000000000094070
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000094080)
,p_name=>'Notas de credito registradas'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_NC,',
'       NRO_COMPROBANTE,',
'       PROVEEDOR,',
'       MOTIVO,',
'       TOTAL,',
'       NRO_FACTURA_ORIGEN,',
'       TO_CHAR(FECHA_EMISION, ''DD/MM/YYYY'') AS FECHA_EMISION',
'  FROM WKSP_WORKPLACE.V_NC_COMPRA',
' ORDER BY ID_NC DESC'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>25
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('A\00FAn no hay notas de cr\00E9dito registradas.')
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094081)
,p_query_column_id=>1
,p_column_alias=>'ID_NC'
,p_column_display_sequence=>1
,p_column_heading=>'NC N&deg;'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094082)
,p_query_column_id=>2
,p_column_alias=>'NRO_COMPROBANTE'
,p_column_display_sequence=>2
,p_column_heading=>'Documento'
,p_column_link=>'f?p=&APP_ID.:151:&SESSION.::&DEBUG.:RP,151:P151_ID_NC:#ID_NC#'
,p_column_linktext=>'#NRO_COMPROBANTE#'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094083)
,p_query_column_id=>3
,p_column_alias=>'PROVEEDOR'
,p_column_display_sequence=>3
,p_column_heading=>'Proveedor'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094084)
,p_query_column_id=>4
,p_column_alias=>'MOTIVO'
,p_column_display_sequence=>4
,p_column_heading=>'Motivo'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094085)
,p_query_column_id=>5
,p_column_alias=>'TOTAL'
,p_column_display_sequence=>5
,p_column_heading=>'Total'
,p_column_format=>'FML999G999G999G990'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094086)
,p_query_column_id=>6
,p_column_alias=>'NRO_FACTURA_ORIGEN'
,p_column_display_sequence=>6
,p_column_heading=>'Factura origen'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000094087)
,p_query_column_id=>7
,p_column_alias=>'FECHA_EMISION'
,p_column_display_sequence=>7
,p_column_heading=>'Fecha'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp.component_end;
end;
/

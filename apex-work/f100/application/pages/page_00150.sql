prompt --application/pages/page_00150
begin
--   Manifest
--     PAGE: 00150
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
 p_id=>150
,p_name=>'Resolver Orden de Pago'
,p_alias=>'RESOLVER-ORDEN-DE-PAGO'
,p_page_mode=>'MODAL'
,p_step_title=>'Resolver Orden de Pago'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000150010)
,p_plug_name=>'Datos de la orden'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000150020)
,p_plug_name=>'Comprobantes aplicados'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v CLOB;',
'  FUNCTION f(n NUMBER) RETURN VARCHAR2 IS BEGIN',
'    RETURN TRANSLATE(TO_CHAR(NVL(n,0),''FM999G999G999G990''),'','',''.''); END;',
'BEGIN',
'  v := ''<table class="t-Report-report" style="width:100%"><thead><tr>''',
'    ||''<th>Comprobante</th><th>Vencimiento</th><th style="text-align:right">Monto aplicado</th></tr></thead><tbody>'';',
'  FOR r IN (',
'    SELECT comp.NRO_COMPROBANTE nro, cp.FECHA_VENCIMIENTO vto, d.MONTO_APLICADO m',
'      FROM WKSP_WORKPLACE.ORDEN_PAGO_DET d',
'      JOIN WKSP_WORKPLACE.CUENTAS_PAGAR cp ON cp.ID_CXP = d.ID_CXP',
'      LEFT JOIN WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR comp ON comp.ID_COMPROBANTE = cp.ID_COMPROBANTE',
'     WHERE d.ID_ORDEN_PAGO = :P150_ID_ORDEN_PAGO',
'     ORDER BY cp.FECHA_VENCIMIENTO) LOOP',
'    v := v||''<tr><td>''||NVL(r.nro,''-'')||''</td><td>''||NVL(TO_CHAR(r.vto,''DD/MM/YYYY''),''-'')',
'      ||''</td><td class="u-tR">''||f(r.m)||''</td></tr>'';',
'  END LOOP;',
'  v := v||''</tbody></table>'';',
'  RETURN v;',
'END;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000150030)
,p_plug_name=>unistr('Resoluci\00F3n')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_location=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000150050)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000150030)
,p_button_name=>'CONFIRMAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Confirmar pago'
,p_button_position=>'NEXT'
,p_button_condition=>':P150_ESTADO = ''BORRADOR'''
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000150051)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(36000000000150030)
,p_button_name=>'ANULAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--danger'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Anular'
,p_button_position=>'PREVIOUS'
,p_button_condition=>':P150_ESTADO = ''BORRADOR'''
,p_button_condition_type=>'EXPRESSION'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000150040)
,p_name=>'P150_ID_ORDEN_PAGO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000150010)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000150041)
,p_name=>'P150_PROVEEDOR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(36000000000150010)
,p_prompt=>'Proveedor'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT TRIM(per.primer_nombre||'' ''||per.primer_apellido)',
'  FROM WKSP_WORKPLACE.ORDENES_PAGO op',
'  JOIN WKSP_WORKPLACE.PROVEEDORES pr ON pr.id_persona = op.id_proveedor',
'  LEFT JOIN WKSP_WORKPLACE.PERSONAS per ON per.id_persona = pr.id_persona',
' WHERE op.id_orden_pago = :P150_ID_ORDEN_PAGO'))
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000150042)
,p_name=>'P150_TOTAL'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(36000000000150010)
,p_prompt=>'Total a pagar'
,p_source=>'SELECT TO_CHAR(total_pago,''FM999G999G999G990'') FROM WKSP_WORKPLACE.ORDENES_PAGO WHERE id_orden_pago = :P150_ID_ORDEN_PAGO'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000150043)
,p_name=>'P150_ESTADO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(36000000000150010)
,p_prompt=>'Estado'
,p_source=>'SELECT estado FROM WKSP_WORKPLACE.ORDENES_PAGO WHERE id_orden_pago = :P150_ID_ORDEN_PAGO'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000150045)
,p_name=>'P150_ID_METODO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000150030)
,p_item_default=>'1'
,p_prompt=>unistr('M\00E9todo de pago (al confirmar)')
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT nombre d, id_metodo_pago r',
'  FROM WKSP_WORKPLACE.METODOS_PAGO',
' ORDER BY id_metodo_pago'))
,p_lov_display_null=>'NO'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000150046)
,p_name=>'P150_MOTIVO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(36000000000150030)
,p_prompt=>unistr('Motivo de anulaci\00F3n (al anular)')
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>40
,p_cHeight=>3
,p_cMaxlength=>255
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(36000000000150060)
,p_validation_name=>'Motivo requerido al anular'
,p_validation_sequence=>10
,p_validation=>wwv_flow_string.join(wwv_flow_t_varchar2(
'RETURN CASE',
'  WHEN :REQUEST=''ANULAR'' AND (:P150_MOTIVO IS NULL OR LENGTH(TRIM(:P150_MOTIVO)) < 5)',
'    THEN ''Ingrese un motivo de anulacion (min 5 caracteres).''',
'  ELSE NULL',
'END;'))
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_associated_item=>wwv_flow_imp.id(36000000000150046)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000150070)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Confirmar pago'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_CONFIRMAR_ORDEN_PAGO(',
'    p_id_orden_pago  => :P150_ID_ORDEN_PAGO,',
'    p_id_metodo_pago => :P150_ID_METODO);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(36000000000150050)
,p_process_success_message=>'Orden de pago confirmada (pagada).'
,p_internal_uid=>36000000000150070
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000150071)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Anular orden'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_ANULAR_ORDEN_PAGO(',
'    p_id_orden_pago => :P150_ID_ORDEN_PAGO,',
'    p_motivo        => :P150_MOTIVO);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(36000000000150051)
,p_process_success_message=>'Orden de pago anulada.'
,p_internal_uid=>36000000000150071
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000150072)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>36000000000150072
);
wwv_flow_imp.component_end;
end;
/

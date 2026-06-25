prompt --application/pages/page_00130
begin
--   Manifest
--     PAGE: 00130
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
 p_id=>130
,p_name=>'Aprobar/Rechazar Reverso'
,p_alias=>'APROBAR-RECHAZAR-REVERSO'
,p_page_mode=>'MODAL'
,p_step_title=>'Aprobar/Rechazar Reverso'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23786074097550708)
,p_plug_name=>'Detalle de la solicitud'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23786488827550712)
,p_plug_name=>'Datos'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23786543196550713)
,p_plug_name=>unistr('Aprobaci\00F3n')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23786144620550709)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(23786543196550713)
,p_button_name=>'APROBAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Aprobar'
,p_button_position=>'NEXT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23786303814550711)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(23786543196550713)
,p_button_name=>'RECHAZAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--danger'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Rechazar'
,p_button_position=>'PREVIOUS'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23785896222550706)
,p_name=>'P130_ID_SOLICITUD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(23786488827550712)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23785989335550707)
,p_name=>'P130_MOTIVO_RECHAZO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(23786488827550712)
,p_prompt=>'Motivo de rechazo'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>30
,p_cHeight=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23920000000000004)
,p_name=>'P130_RECIBO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(23786074097550708)
,p_prompt=>'Recibo'
,p_source=>'SELECT NRO_RECIBO FROM WKSP_WORKPLACE.V_SOLICITUDES_REVERSO WHERE ID_SOLICITUD_RC = :P130_ID_SOLICITUD'
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
 p_id=>wwv_flow_imp.id(23920000000000005)
,p_name=>'P130_CLIENTE'
,p_item_sequence=>11
,p_item_plug_id=>wwv_flow_imp.id(23786074097550708)
,p_prompt=>'Cliente'
,p_source=>'SELECT CLIENTE_NOMBRE FROM WKSP_WORKPLACE.V_SOLICITUDES_REVERSO WHERE ID_SOLICITUD_RC = :P130_ID_SOLICITUD'
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
 p_id=>wwv_flow_imp.id(23920000000000006)
,p_name=>'P130_NRO_CUOTA'
,p_item_sequence=>12
,p_item_plug_id=>wwv_flow_imp.id(23786074097550708)
,p_prompt=>'Cuota N&deg;'
,p_source=>'SELECT NRO_CUOTA FROM WKSP_WORKPLACE.V_SOLICITUDES_REVERSO WHERE ID_SOLICITUD_RC = :P130_ID_SOLICITUD'
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
 p_id=>wwv_flow_imp.id(23920000000000007)
,p_name=>'P130_MONTO'
,p_item_sequence=>13
,p_item_plug_id=>wwv_flow_imp.id(23786074097550708)
,p_prompt=>'Monto cobrado'
,p_source=>'SELECT TO_CHAR(MONTO,''FM999G999G999G990'') FROM WKSP_WORKPLACE.V_SOLICITUDES_REVERSO WHERE ID_SOLICITUD_RC = :P130_ID_SOLICITUD'
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
 p_id=>wwv_flow_imp.id(23920000000000008)
,p_name=>'P130_MOTIVO_PEDIDO'
,p_item_sequence=>14
,p_item_plug_id=>wwv_flow_imp.id(23786074097550708)
,p_prompt=>'Motivo del pedido'
,p_source=>'SELECT MOTIVO FROM WKSP_WORKPLACE.V_SOLICITUDES_REVERSO WHERE ID_SOLICITUD_RC = :P130_ID_SOLICITUD'
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
 p_id=>wwv_flow_imp.id(23920000000000009)
,p_name=>'P130_SOLICITANTE'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(23786074097550708)
,p_prompt=>'Solicitado por'
,p_source=>'SELECT USUARIO_SOLICITA FROM WKSP_WORKPLACE.V_SOLICITUDES_REVERSO WHERE ID_SOLICITUD_RC = :P130_ID_SOLICITUD'
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
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(23920000000000020)
,p_validation_name=>'Motivo rechazo >= 10 chars'
,p_validation_sequence=>10
,p_validation=>wwv_flow_string.join(wwv_flow_t_varchar2(
'RETURN CASE',
'  WHEN :REQUEST=''RECHAZAR'' AND (:P130_MOTIVO_RECHAZO IS NULL OR LENGTH(TRIM(:P130_MOTIVO_RECHAZO)) < 10)',
'    THEN ''El motivo de rechazo debe tener al menos 10 caracteres.''',
'  ELSE NULL',
'END;'))
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_associated_item=>wwv_flow_imp.id(23785989335550707)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23920000000000030)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Aprobar reverso'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_APROBAR_REVERSO_COBRO(',
'    p_id_solicitud => :P130_ID_SOLICITUD,',
'    p_usuario      => :APP_USER);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23786144620550709)
,p_process_success_message=>'Reverso aprobado correctamente.'
,p_internal_uid=>23920000000000030
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23920000000000031)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Rechazar reverso'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_RECHAZAR_REVERSO_COBRO(',
'    p_id_solicitud   => :P130_ID_SOLICITUD,',
'    p_motivo_rechazo => :P130_MOTIVO_RECHAZO,',
'    p_usuario        => :APP_USER);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23786303814550711)
,p_process_success_message=>'Solicitud de reverso rechazada.'
,p_internal_uid=>23920000000000031
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23920000000000032)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>23920000000000032
);
wwv_flow_imp.component_end;
end;
/

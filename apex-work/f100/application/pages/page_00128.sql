prompt --application/pages/page_00128
begin
--   Manifest
--     PAGE: 00128
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
 p_id=>128
,p_name=>'Solicitar Reverso de Cobro'
,p_alias=>'SOLICITAR-REVERSO-DE-COBRO'
,p_page_mode=>'MODAL'
,p_step_title=>'Solicitar Reverso de Cobro'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'17'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23157512709069533)
,p_plug_name=>'Datos del cobro'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23786679926550714)
,p_plug_name=>'Solicitud'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23157640378069534)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(23786679926550714)
,p_button_name=>'SOLICITAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Solicitar'
,p_button_position=>'NEXT'
,p_button_condition=>'P128_BLOQUEO'
,p_button_condition_type=>'ITEM_IS_NULL'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23157311445069531)
,p_name=>'P128_ID_MOVIMIENTO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(23786679926550714)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23157458596069532)
,p_name=>'P128_MOTIVO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(23786679926550714)
,p_prompt=>'Motivo del reverso'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>30
,p_cHeight=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_display_when=>'P128_BLOQUEO'
,p_display_when_type=>'ITEM_IS_NULL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23900000000000002)
,p_name=>'P128_BLOQUEO'
,p_item_sequence=>4
,p_item_plug_id=>wwv_flow_imp.id(23157512709069533)
,p_prompt=>'No se puede reversar'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_display_when=>'P128_BLOQUEO'
,p_display_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23900000000000004)
,p_name=>'P128_RECIBO'
,p_item_sequence=>11
,p_item_plug_id=>wwv_flow_imp.id(23157512709069533)
,p_prompt=>'Recibo'
,p_source=>'SELECT NRO_RECIBO FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA WHERE ID_MOVIMIENTO = :P128_ID_MOVIMIENTO'
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
 p_id=>wwv_flow_imp.id(23900000000000005)
,p_name=>'P128_CLIENTE'
,p_item_sequence=>12
,p_item_plug_id=>wwv_flow_imp.id(23157512709069533)
,p_prompt=>'Cliente'
,p_source=>'SELECT TRIM(p.PRIMER_NOMBRE||'' ''||p.PRIMER_APELLIDO) FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA mc JOIN WKSP_WORKPLACE.PERSONAS p ON p.ID_PERSONA=mc.ID_CLIENTE WHERE mc.ID_MOVIMIENTO = :P128_ID_MOVIMIENTO'
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
 p_id=>wwv_flow_imp.id(23900000000000006)
,p_name=>'P128_NRO_CUOTA'
,p_item_sequence=>13
,p_item_plug_id=>wwv_flow_imp.id(23157512709069533)
,p_prompt=>'Cuota N&deg;'
,p_source=>'SELECT cd.NRO_CUOTA FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA mc JOIN WKSP_WORKPLACE.CUENTAS_COBRAR_DET cd ON cd.ID_DETALLE=mc.ID_CUENTA_COBRAR_DET WHERE mc.ID_MOVIMIENTO = :P128_ID_MOVIMIENTO'
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
 p_id=>wwv_flow_imp.id(23900000000000007)
,p_name=>'P128_MONTO'
,p_item_sequence=>14
,p_item_plug_id=>wwv_flow_imp.id(23157512709069533)
,p_prompt=>'Monto cobrado'
,p_source=>'SELECT TO_CHAR(TOTAL_MONEDA_LOCAL,''FM999G999G999G990'') FROM WKSP_WORKPLACE.MOVIMIENTOS_CAJA WHERE ID_MOVIMIENTO = :P128_ID_MOVIMIENTO'
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
 p_id=>wwv_flow_imp.id(23900000000000020)
,p_validation_name=>'Motivo >= 10 chars'
,p_validation_sequence=>10
,p_validation=>wwv_flow_string.join(wwv_flow_t_varchar2(
'RETURN CASE',
'  WHEN :P128_MOTIVO IS NULL OR LENGTH(TRIM(:P128_MOTIVO)) < 10',
'    THEN ''El motivo del reverso debe tener al menos 10 caracteres.''',
'  ELSE NULL',
'END;'))
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_associated_item=>wwv_flow_imp.id(23157458596069532)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
,p_when_button_pressed=>wwv_flow_imp.id(23157640378069534)
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23900000000000010)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Set bloqueo'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  :P128_BLOQUEO := WKSP_WORKPLACE.FN_COBRO_REVERSABLE(:P128_ID_MOVIMIENTO);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>23900000000000010
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23900000000000030)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Solicitar reverso'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE v_id NUMBER;',
'BEGIN',
'  WKSP_WORKPLACE.PRC_SOLICITAR_REVERSO_COBRO(',
'    p_id_movimiento => :P128_ID_MOVIMIENTO,',
'    p_motivo        => :P128_MOTIVO,',
'    p_usuario       => :APP_USER,',
'    p_id_solicitud  => v_id);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23157640378069534)
,p_process_success_message=>'Solicitud de reverso creada.'
,p_internal_uid=>23900000000000030
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23900000000000031)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23157640378069534)
,p_internal_uid=>23900000000000031
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00121
begin
--   Manifest
--     PAGE: 00121
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
 p_id=>121
,p_name=>unistr('Detalle Anulaci\00F3n')
,p_alias=>unistr('DETALLE-ANULACI\00D3N')
,p_page_mode=>'MODAL'
,p_step_title=>unistr('Detalle Anulaci\00F3n')
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'11'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23065603523889426)
,p_button_sequence=>120
,p_button_name=>'Cancelar'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#:t-Button--pillStart'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_warn_on_unsaved_changes=>null
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23065572139889425)
,p_button_sequence=>140
,p_button_name=>'RECHAZAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--warning:t-Button--pill'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Rechazar'
,p_confirm_message=>unistr('Esta seguro que desea rechazar la anulaci\00F3n?')
,p_grid_new_row=>'N'
,p_grid_column=>9
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23065482698889424)
,p_button_sequence=>150
,p_button_name=>'APROBAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Aprobar'
,p_confirm_message=>unistr('Esta seguro que desea aprobar la anulaci\00F3n? ')
,p_grid_new_row=>'N'
,p_grid_column=>11
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23064302287889413)
,p_name=>'P121_ID_COMPROBANTE'
,p_item_sequence=>10
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23064422343889414)
,p_name=>'P121_NRO_COMPROBANTE'
,p_item_sequence=>20
,p_prompt=>unistr('N\00BA Factura')
,p_source=>'SELECT Nro_comprobante FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23064509747889415)
,p_name=>'P121_FECHA'
,p_item_sequence=>30
,p_prompt=>'Fecha Emision'
,p_source=>'SELECT fecha FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23064635079889416)
,p_name=>'P121_CLIENTE'
,p_item_sequence=>40
,p_prompt=>'Cliente'
,p_source=>'SELECT id_cliente  FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23064764566889417)
,p_name=>'P121_TOTAL'
,p_item_sequence=>50
,p_prompt=>'Total'
,p_source=>'SELECT total_moneda_local FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23064815052889418)
,p_name=>'P121_FORMA_PAGO'
,p_item_sequence=>60
,p_prompt=>'Forma Pago'
,p_source=>unistr('SELECT CASE FORMA_PAGO WHEN ''1'' THEN ''Cr\00E9dito'' ELSE ''Contado'' END FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE')
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
 p_id=>wwv_flow_imp.id(23064927410889419)
,p_name=>'P121_USUARIO_SOLICITA'
,p_item_sequence=>70
,p_prompt=>'Solicitante'
,p_source=>'SELECT USUARIO_SOLICITA FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23065084415889420)
,p_name=>'P121_FECHA_SOLICITUD'
,p_item_sequence=>80
,p_prompt=>'Fecha Solicitud'
,p_source=>'SELECT FECHA_SOLICITUD FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23065180427889421)
,p_name=>'P121_MOTIVO_ANULACION'
,p_item_sequence=>90
,p_prompt=>'Motivo Solicitado'
,p_source=>'SELECT MOTIVO_ANULACION FROM V_ANULACIONES_FACTURAS WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23065284377889422)
,p_name=>'P121_MOTIVO_RECHAZO'
,p_item_sequence=>100
,p_prompt=>'Motivo Rechazo'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(23066035448889430)
,p_validation_name=>'New'
,p_validation_sequence=>9
,p_validation=>wwv_flow_string.join(wwv_flow_t_varchar2(
'RETURN CASE',
'  WHEN :P121_MOTIVO_RECHAZO IS NULL OR LENGTH(TRIM(:P121_MOTIVO_RECHAZO)) < 10',
'    THEN ''Para rechazar, el motivo debe tener al menos 10 caracteres.''',
'  ELSE NULL',
'END;'))
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_when_button_pressed=>wwv_flow_imp.id(23065572139889425)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(23065751850889427)
,p_name=>'New'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(23065603523889426)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(23065882133889428)
,p_event_id=>wwv_flow_imp.id(23065751850889427)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23066153791889431)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Aprobar'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  PRC_APROBAR_ANULACION(',
'    p_id_comprobante => :P121_ID_COMPROBANTE,',
'    p_usuario        => :APP_USER',
'  );',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23065482698889424)
,p_process_success_message=>'Factura anulada. Se revirtieron stock, OV y caja.'
,p_internal_uid=>23066153791889431
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23066272694889432)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Rechazar'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  PRC_RECHAZAR_ANULACION(',
'    p_id_comprobante => :P121_ID_COMPROBANTE,',
'    p_motivo_rechazo => :P121_MOTIVO_RECHAZO,',
'    p_usuario        => :APP_USER',
'  );',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23065572139889425)
,p_process_success_message=>'Solicitud rechazada. La factura vuelve a estado activo.'
,p_internal_uid=>23066272694889432
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23066304932889433)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23065572139889425)
,p_internal_uid=>23066304932889433
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23066423168889434)
,p_process_sequence=>100
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog_1'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23065482698889424)
,p_internal_uid=>23066423168889434
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23065342809889423)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'New'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_estado COMPROBANTES.ESTADO%TYPE;',
'BEGIN',
'  SELECT ESTADO INTO v_estado FROM COMPROBANTES WHERE ID_COMPROBANTE = :P121_ID_COMPROBANTE;',
'  IF v_estado <> ''P'' THEN',
'    apex_error.add_error(',
unistr('      p_message => ''Esta factura ya no est\00E1 pendiente de anulaci\00F3n (estado ''||v_estado||'').'','),
'      p_display_location => apex_error.c_inline_in_notification);',
'    apex_util.redirect_url(''f?p=&APP_ID.:120:&SESSION.'');',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>23065342809889423
);
wwv_flow_imp.component_end;
end;
/

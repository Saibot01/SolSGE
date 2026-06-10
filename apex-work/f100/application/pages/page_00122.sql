prompt --application/pages/page_00122
begin
--   Manifest
--     PAGE: 00122
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
 p_id=>122
,p_name=>unistr('Solicitar Anulaci\00F3n')
,p_alias=>unistr('SOLICITAR-ANULACI\00D3N')
,p_page_mode=>'MODAL'
,p_step_title=>unistr('Solicitar Anulaci\00F3n')
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23066762730889437)
,p_plug_name=>'Solicitud'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23067744633889447)
,p_button_sequence=>20
,p_button_name=>'SOLICITAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Solicitar'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23066814988889438)
,p_name=>'P122_ID_COMPROBANTE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(23066762730889437)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23066922939889439)
,p_name=>'P122_NRO_COMPROBANTE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(23066762730889437)
,p_prompt=>'Nro Comprobante'
,p_source=>'SELECT NRO_COMPROBANTE FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23067029250889440)
,p_name=>'P122_FECHA'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(23066762730889437)
,p_prompt=>'Fecha'
,p_source=>'SELECT TO_CHAR(FECHA,''DD/MM/YYYY'') FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23067119423889441)
,p_name=>'P122_TOTAL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(23066762730889437)
,p_prompt=>'Total'
,p_source=>'SELECT TO_CHAR(TOTAL_MONEDA_LOCAL,''FM999G999G999G990'')||'' ''||MONEDA FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23067280022889442)
,p_name=>'P122_CLIENTE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(23066762730889437)
,p_prompt=>'Cliente'
,p_source=>'SELECT TRIM(p.PRIMER_NOMBRE||'' ''||p.PRIMER_APELLIDO) FROM COMPROBANTES c JOIN PERSONAS p ON p.ID_PERSONA = c.ID_CLIENTE WHERE c.ID_COMPROBANTE = :P122_ID_COMPROBANTE'
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
 p_id=>wwv_flow_imp.id(23067328025889443)
,p_name=>'P122_FORMA_PAGO'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(23066762730889437)
,p_prompt=>'Forma Pago'
,p_source=>unistr('SELECT CASE FORMA_PAGO WHEN ''1'' THEN ''Cr\00E9dito'' ELSE ''Contado'' END FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE')
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
 p_id=>wwv_flow_imp.id(23067486240889444)
,p_name=>'P122_MOTIVO'
,p_is_required=>true
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(23066762730889437)
,p_prompt=>'Motivo'
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
 p_id=>wwv_flow_imp.id(23067891551889448)
,p_validation_name=>unistr('Motivo \2265 10 chars')
,p_validation_sequence=>9
,p_validation=>wwv_flow_string.join(wwv_flow_t_varchar2(
'RETURN CASE',
'  WHEN :P122_MOTIVO IS NULL OR LENGTH(TRIM(:P122_MOTIVO)) < 10',
'    THEN ''El motivo debe tener al menos 10 caracteres.''',
'  ELSE NULL',
'END;'))
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23067902742889449)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>unistr('Solicitar anulaci\00F3n')
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  PRC_SOLICITAR_ANULACION(',
'    p_id_comprobante => :P122_ID_COMPROBANTE,',
'    p_motivo         => :P122_MOTIVO,',
'    p_usuario        => :APP_USER',
'  );',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23067744633889447)
,p_process_success_message=>unistr('Solicitud de anulaci\00F3n registrada. La factura qued\00F3 pendiente de aprobaci\00F3n.')
,p_internal_uid=>23067902742889449
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23068089552889450)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23067744633889447)
,p_internal_uid=>23068089552889450
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23067508324889445)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Pre-check: factura activa + ventana + cuotas'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_estado    COMPROBANTES.ESTADO%TYPE;',
'  v_fecha     COMPROBANTES.FECHA%TYPE;',
'  v_fp        COMPROBANTES.FORMA_PAGO%TYPE;',
'  v_nro       COMPROBANTES.NRO_COMPROBANTE%TYPE;',
'  v_cuotas    PLS_INTEGER;',
'BEGIN',
'  SELECT ESTADO, FECHA, FORMA_PAGO, NRO_COMPROBANTE',
'    INTO v_estado, v_fecha, v_fp, v_nro',
'    FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE;',
'',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>23067508324889445
);
wwv_flow_imp.component_end;
end;
/

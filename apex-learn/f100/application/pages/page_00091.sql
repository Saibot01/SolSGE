prompt --application/pages/page_00091
begin
--   Manifest
--     PAGE: 00091
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_page.create_page(
 p_id=>91
,p_name=>'Alta de Clientes'
,p_alias=>'ALTA-DE-CLIENTES'
,p_page_mode=>'MODAL'
,p_step_title=>'Alta de Clientes'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15463419371249327)
,p_plug_name=>'New'
,p_region_template_options=>'#DEFAULT#:t-Region--hideHeader js-addHiddenHeadingRoleDesc:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(15463564765249328)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(15463419371249327)
,p_button_name=>'Crear'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'CREATE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15463193559249324)
,p_name=>'P91_DOCUMENTO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(15463419371249327)
,p_prompt=>'Numero de Documento'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15463279647249325)
,p_name=>'P91_NOMBRE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(15463419371249327)
,p_prompt=>'Nombre'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15463353749249326)
,p_name=>'P91_APELLIDO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(15463419371249327)
,p_prompt=>'Apellido'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15463666588249329)
,p_name=>'P91_CATEGORIA_CLIENTE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(15463419371249327)
,p_prompt=>'Categoria Cliente'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:Minorista;Minorista,Mayorista;Mayorista'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(15465051379249343)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Alta de Cliente'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    v_id_persona NUMBER;',
'BEGIN',
'    PR_ALTA_RAPIDA_CLIENTE(',
'        p_nro_documento     => :P91_DOCUMENTO,',
'        p_primer_nombre     => :P91_NOMBRE,',
'        p_primer_apellido   => :P91_APELLIDO,',
'        p_categoria_cliente => :P91_CATEGORIA_CLIENTE,',
'        p_codigo_usuario    => ''&APP_USER'',',
'        p_id_persona_out    => v_id_persona',
'    );',
'',
'    DBMS_OUTPUT.PUT_LINE(''Cliente registrado con ID_PERSONA='' || v_id_persona);',
'END;',
'',
''))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(15463564765249328)
,p_internal_uid=>15465051379249343
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(15465182578249344)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'Crear'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>15465182578249344
);
wwv_flow_imp.component_end;
end;
/

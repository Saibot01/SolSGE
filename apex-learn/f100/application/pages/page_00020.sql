prompt --application/pages/page_00020
begin
--   Manifest
--     PAGE: 00020
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
 p_id=>20
,p_name=>'Empleados IG Forms'
,p_alias=>'EMPLEADOS-IG-FORMS'
,p_page_mode=>'MODAL'
,p_step_title=>'Empleados IG Forms'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>1661186590416509825
,p_page_template_options=>'#DEFAULT#:js-dialog-class-t-Drawer--pullOutEnd'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11505182297464549)
,p_plug_name=>'Empleados IG Forms'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'EMPLEADOS'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11511726818464568)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11512166136464568)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(11511726818464568)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11513594051464572)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(11511726818464568)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Eliminar'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>'P20_ID_EMPLEADO'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11513994133464573)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(11511726818464568)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Guardar'
,p_button_position=>'NEXT'
,p_button_condition=>'P20_ID_EMPLEADO'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11514366380464573)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(11511726818464568)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'NEXT'
,p_button_condition=>'P20_ID_EMPLEADO'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11505424286464554)
,p_name=>'P20_ID_EMPLEADO'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Id Empleado'
,p_source=>'ID_EMPLEADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11505829993464560)
,p_name=>'P20_ID_PERSONA'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_prompt=>'Nro Documento'
,p_source=>'ID_PERSONA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_named_lov=>'PERSONAS.NRO_DOCUMENTO_1'
,p_lov_display_null=>'YES'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11506293914464563)
,p_name=>'P20_NOMBRE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Nombre'
,p_source=>'NOMBRE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_label_alignment=>'RIGHT'
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
 p_id=>wwv_flow_imp.id(11506693488464563)
,p_name=>'P20_FECHA_ALTA'
,p_source_data_type=>'DATE'
,p_is_query_only=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_prompt=>'Fecha Alta'
,p_source=>'FECHA_ALTA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11507022620464563)
,p_name=>'P20_CARGO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Cargo'
,p_source=>'CARGO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_label_alignment=>'RIGHT'
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
 p_id=>wwv_flow_imp.id(11507433427464564)
,p_name=>unistr('P20_CONTRASE\00D1A')
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_source=>unistr('CONTRASE\00D1A')
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11507890309464564)
,p_name=>'P20_CODIGO_USUARIO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_prompt=>'Codigo  de Usuario'
,p_source=>'CODIGO_USUARIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11508236702464564)
,p_name=>'P20_CODIGO_VERIFICACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_source=>'CODIGO_VERIFICACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11508611210464564)
,p_name=>'P20_CORREO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_item_source_plug_id=>wwv_flow_imp.id(11505182297464549)
,p_prompt=>'Correo Laboral'
,p_source=>'CORREO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>1000
,p_cHeight=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11512282509464568)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(11512166136464568)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11513013124464571)
,p_event_id=>wwv_flow_imp.id(11512282509464568)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(9716648712137614)
,p_name=>'ASIGNAR_NOMBRE'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P20_ID_PERSONA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9716760404137615)
,p_event_id=>wwv_flow_imp.id(9716648712137614)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SET_VALUE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P20_NOMBRE'
,p_attribute_01=>'SQL_STATEMENT'
,p_attribute_03=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select primer_nombre||'' ''||primer_apellido ',
'		--into :NOMBRE',
'		from personas ',
'		where ID_PERSONA = :P20_ID_PERSONA;',
'        '))
,p_attribute_07=>'P20_ID_PERSONA'
,p_attribute_08=>'Y'
,p_attribute_09=>'N'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(9716819969137616)
,p_name=>'ASIGNAR COD_USUARIO'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P20_ID_PERSONA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(9716986940137617)
,p_event_id=>wwv_flow_imp.id(9716819969137616)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SET_VALUE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P20_CODIGO_USUARIO'
,p_attribute_01=>'SQL_STATEMENT'
,p_attribute_03=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT UPPER(SUBSTR(primer_nombre, 1, 1) || primer_apellido)',
'       --INTO v_codigo_usuario',
'        FROM personas',
'        where ID_PERSONA = :P20_ID_PERSONA;'))
,p_attribute_07=>'P20_ID_PERSONA'
,p_attribute_08=>'Y'
,p_attribute_09=>'N'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16597366208211741)
,p_process_sequence=>5
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Registrar Empleado'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_id EMPLEADOS.ID_EMPLEADO%TYPE;',
'BEGIN',
'  APEX_DEBUG.MESSAGE(''Iniciando registro - ID_PERSONA: '' || :P20_ID_PERSONA);',
'  ',
'  PKG_EMPLEADOS.registrar_empleado(',
'    p_id_persona  => :P20_ID_PERSONA,',
'    p_nombre      => :P20_NOMBRE,',
'    p_cargo       => :P20_CARGO,',
'    p_correo      => :P20_CORREO,',
'    p_url_reset   => ''https://gd48788b1691042-orapdbtes.adb.sa-vinhedo-1.oraclecloudapps.com/ords/r/workplace/solsge/reset-password'',',
'    p_id_empleado => v_id',
'  );',
'',
'  :P20_ID_EMPLEADO := v_id;',
'',
'  APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE :=',
'    ''Empleado registrado. Credenciales enviadas a '' || :P20_CORREO;',
'',
'EXCEPTION',
'  WHEN OTHERS THEN',
'    RAISE_APPLICATION_ERROR(-20099, ''Error: '' || SQLERRM);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_process_error_message=>'Error registrando el empleado'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(11514366380464573)
,p_process_when=>'P20_ID_EMPLEADO'
,p_process_when_type=>'ITEM_IS_NULL'
,p_internal_uid=>16597366208211741
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11515179556464575)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(11505182297464549)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Empleados IG Forms'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(11513994133464573)
,p_process_when=>'P20_ID_EMPLEADO'
,p_process_when_type=>'ITEM_IS_NOT_NULL'
,p_internal_uid=>11515179556464575
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11515538130464575)
,p_process_sequence=>15
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>11515538130464575
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11514718947464575)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(11505182297464549)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Empleados IG Forms'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>11514718947464575
);
wwv_flow_imp.component_end;
end;
/

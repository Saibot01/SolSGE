prompt --application/pages/page_00083
begin
--   Manifest
--     PAGE: 00083
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
 p_id=>83
,p_name=>'Roles Privilegios'
,p_alias=>'ROLES-PRIVILEGIOS1'
,p_page_mode=>'MODAL'
,p_step_title=>'Roles Privilegios'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>1661186590416509825
,p_page_template_options=>'#DEFAULT#:js-dialog-class-t-Drawer--pullOutEnd'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_last_updated_on=>wwv_flow_imp.dz('20250911115143Z')
,p_created_by=>'SIS_APEX'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14263211499094970)
,p_plug_name=>'Roles Privilegios'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'ROLES_PRIVILEGIOS'
,p_include_rowid_column=>true
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14265794276094971)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14266174048094971)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14265794276094971)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancel'
,p_button_position=>'CLOSE'
,p_button_alignment=>'RIGHT'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14267590015094972)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(14265794276094971)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--danger:t-Button--simple'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Delete'
,p_button_position=>'DELETE'
,p_button_alignment=>'RIGHT'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>'P83_ROWID'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14267982006094972)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(14265794276094971)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Apply Changes'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_button_condition=>'P83_ROWID'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14268314303094972)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(14265794276094971)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Create'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_button_condition=>'P83_ROWID'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14263619872094970)
,p_name=>'P83_ROWID'
,p_source_data_type=>'VARCHAR2'
,p_is_primary_key=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(14263211499094970)
,p_item_source_plug_id=>wwv_flow_imp.id(14263211499094970)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Rowid'
,p_source=>'ROWID'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14264033375094970)
,p_name=>'P83_ID_ROL'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(14263211499094970)
,p_item_source_plug_id=>wwv_flow_imp.id(14263211499094970)
,p_prompt=>'Id Rol'
,p_source=>'ID_ROL'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911115143Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14264473516094970)
,p_name=>'P83_ID_PRIV'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(14263211499094970)
,p_item_source_plug_id=>wwv_flow_imp.id(14263211499094970)
,p_prompt=>'Id Priv'
,p_source=>'ID_PRIV'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_named_lov=>'PRIVILEGIOS'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('SELECT codigo || '' \2014 '' || nombre d, id_priv r'),
'FROM privilegios',
'WHERE activo = ''S''',
'ORDER BY codigo',
''))
,p_lov_display_null=>'YES'
,p_cSize=>32
,p_cMaxlength=>255
,p_field_template=>1609122147107268652
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
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911115143Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14266299269094971)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(14266174048094971)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14267016389094972)
,p_event_id=>wwv_flow_imp.id(14266299269094971)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(14269187392094972)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(14263211499094970)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Roles Privilegios'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>14269187392094972
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(14269569037094973)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_01=>'P83_ROWID,REQUEST'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>14269569037094973
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(14268739322094972)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(14263211499094970)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Roles Privilegios'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>14268739322094972
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

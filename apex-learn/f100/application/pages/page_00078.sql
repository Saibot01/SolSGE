prompt --application/pages/page_00078
begin
--   Manifest
--     PAGE: 00078
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
 p_id=>78
,p_name=>'Recursos  Form'
,p_alias=>'RECURSOS-FORM'
,p_page_mode=>'MODAL'
,p_step_title=>'Recursos  Form'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>1661186590416509825
,p_page_template_options=>'#DEFAULT#:js-dialog-class-t-Drawer--pullOutEnd'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14287220800158707)
,p_plug_name=>'Recursos  Form'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'RECURSOS'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14291747178158714)
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
 p_id=>wwv_flow_imp.id(14292196351158714)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14291747178158714)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14293556605158714)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(14291747178158714)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Eliminar'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>'P78_ID_RECURSO'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14293993191158715)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(14291747178158714)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Guardar'
,p_button_position=>'NEXT'
,p_button_condition=>'P78_ID_RECURSO'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14294370053158715)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(14291747178158714)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'NEXT'
,p_button_condition=>'P78_ID_RECURSO'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14287525178158709)
,p_name=>'P78_ID_RECURSO'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_item_source_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Id Recurso'
,p_source=>'ID_RECURSO'
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
 p_id=>wwv_flow_imp.id(14287959161158710)
,p_name=>'P78_APP_ID'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_item_source_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_item_default=>'100'
,p_prompt=>'App Id'
,p_source=>'APP_ID'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14288383652158711)
,p_name=>'P78_PAGE_ID'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_item_source_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_prompt=>'Pagina'
,p_source=>'PAGE_ID'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_named_lov=>'PAGINAS'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT page_id || '' - '' || page_name d, page_id r',
'FROM apex_application_pages',
'WHERE application_id = :APP_ID',
'ORDER BY page_id',
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14288785778158712)
,p_name=>'P78_COMPONENT_STATIC_ID'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_item_source_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_prompt=>'Componente'
,p_source=>'COMPONENT_STATIC_ID'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT label d, comp_key r',
'FROM (',
unistr('  SELECT ''[''||region_name||''] Regi\00F3n'' AS label, ''REG:''||region_name AS comp_key'),
'  FROM apex_application_page_regions',
'  WHERE application_id = :P78_APP_ID',
'    AND page_id        = :P78_PAGE_ID',
'    AND region_name    IS NOT NULL',
'  UNION ALL',
unistr('  SELECT ''[''||button_name||''] Bot\00F3n'', ''BTN:''||button_name'),
'  FROM apex_application_page_buttons',
'  WHERE application_id = :P78_APP_ID',
'    AND page_id        = :P78_PAGE_ID',
'    AND button_name    IS NOT NULL',
'  UNION ALL',
unistr('  SELECT ''[''||item_name||''] \00CDtem'', ''ITEM:''||item_name'),
'  FROM apex_application_page_items',
'  WHERE application_id = :P78_APP_ID',
'    AND page_id        = :P78_PAGE_ID',
'    AND item_name      IS NOT NULL',
')',
'ORDER BY 1',
''))
,p_lov_display_null=>'YES'
,p_lov_cascade_parent_items=>'P78_APP_ID,P78_PAGE_ID'
,p_ajax_items_to_submit=>'P78_APP_ID,P78_PAGE_ID'
,p_ajax_optimize_refresh=>'Y'
,p_cSize=>32
,p_cMaxlength=>200
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
 p_id=>wwv_flow_imp.id(14289140530158712)
,p_name=>'P78_ID_PRIV_REQUERIDO'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_item_source_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_prompt=>'Privilegio Requerido'
,p_source=>'ID_PRIV_REQUERIDO'
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
,p_cSize=>30
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14289594476158712)
,p_name=>'P78_ACTIVO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_item_source_plug_id=>wwv_flow_imp.id(14287220800158707)
,p_prompt=>'Activo'
,p_source=>'ACTIVO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:Activo;S,Inactivo;N'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14292270226158714)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(14292196351158714)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14293070455158714)
,p_event_id=>wwv_flow_imp.id(14292270226158714)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(14295130117158715)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(14287220800158707)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Recursos  Form'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>14295130117158715
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(14295585097158716)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>14295585097158716
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(14294735045158715)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(14287220800158707)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Recursos  Form'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>14294735045158715
);
wwv_flow_imp.component_end;
end;
/

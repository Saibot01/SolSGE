prompt --application/pages/page_00141
begin
--   Manifest
--     PAGE: 00141
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
 p_id=>141
,p_name=>'Meta de Venta'
,p_alias=>'META-DE-VENTA'
,p_page_mode=>'MODAL'
,p_step_title=>'Meta de Venta'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000141010)
,p_plug_name=>'Meta de Venta'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'METAS_VENTA'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000141020)
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
 p_id=>wwv_flow_imp.id(36000000000141021)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000141020)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000141022)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(36000000000141020)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Eliminar'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>unistr('\00BFEliminar esta meta?')
,p_confirm_style=>'danger'
,p_button_condition=>'P141_ID_META'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000141023)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(36000000000141020)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Guardar cambios'
,p_button_position=>'NEXT'
,p_button_condition=>'P141_ID_META'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000141024)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(36000000000141020)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'NEXT'
,p_button_condition=>'P141_ID_META'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000141011)
,p_name=>'P141_ID_META'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_source=>'ID_META'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000141012)
,p_name=>'P141_TIPO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_default=>'VENDEDOR'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_prompt=>'Tipo de meta'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Vendedor;VENDEDOR,Sucursal;SUCURSAL'
,p_lov_display_null=>'NO'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_is_persistent=>'N'
,p_help_text=>'Una meta es por vendedor O por sucursal (exactamente uno).'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000141013)
,p_name=>'P141_ID_EMPLEADO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_prompt=>'Vendedor'
,p_source=>'ID_EMPLEADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT nombre d, id_empleado r',
'  FROM WKSP_WORKPLACE.EMPLEADOS',
' WHERE codigo_usuario IS NOT NULL',
' ORDER BY nombre'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Seleccione -'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000141014)
,p_name=>'P141_ID_OFICINA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_prompt=>'Sucursal'
,p_source=>'ID_OFICINA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT descripcion d, codigo_oficina r',
'  FROM WKSP_WORKPLACE.OFICINAS',
' ORDER BY descripcion'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Seleccione -'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000141015)
,p_name=>'P141_PERIODO'
,p_source_data_type=>'DATE'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_prompt=>unistr('Per\00EDodo (mes)')
,p_source=>'PERIODO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER'
,p_cSize=>32
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_format_mask=>'YYYY-MM-DD'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'has_time_component', 'N',
  'show', 'true',
  'show_on', 'focus')).to_clob
,p_help_text=>unistr('Eleg\00ED cualquier d\00EDa del mes; se guarda como el 1ro del mes.')
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000141016)
,p_name=>'P141_MONTO_META'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000141010)
,p_prompt=>'Monto meta'
,p_source=>'MONTO_META'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_help_text=>'Monto objetivo de venta neta para el mes (PYG, > 0).'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'right',
  'virtual_keyboard', 'decimal')).to_clob
);
--==================== DA: Cancelar ====================
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000141030)
,p_name=>'Cancelar Dialogo'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(36000000000141021)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000141031)
,p_event_id=>wwv_flow_imp.id(36000000000141030)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
--==================== DA: Tipo -> mostrar/ocultar dimension (+ page load) =========
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000141032)
,p_name=>'Tipo de meta - mostrar dimension'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P141_TIPO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000141033)
,p_event_id=>wwv_flow_imp.id(36000000000141032)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'var v = apex.item("P141_TIPO").getValue();',
'if (v === "SUCURSAL") {',
'  apex.item("P141_ID_EMPLEADO").setValue("", null, true);',
'  apex.item("P141_ID_EMPLEADO").hide();',
'  apex.item("P141_ID_OFICINA").show();',
'} else {',
'  apex.item("P141_ID_OFICINA").setValue("", null, true);',
'  apex.item("P141_ID_OFICINA").hide();',
'  apex.item("P141_ID_EMPLEADO").show();',
'}'))
);
--==================== Procesos ====================
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000141040)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(36000000000141010)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Meta de Venta'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>36000000000141040
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000141041)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Set P141_TIPO segun dimension'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  :P141_TIPO := CASE WHEN :P141_ID_OFICINA IS NOT NULL THEN ''SUCURSAL'' ELSE ''VENDEDOR'' END;',
'END;'))
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>36000000000141041
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000141042)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(36000000000141010)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Meta de Venta'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>36000000000141042
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000141043)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Cerrar Dialogo'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>36000000000141043
);
wwv_flow_imp.component_end;
end;
/

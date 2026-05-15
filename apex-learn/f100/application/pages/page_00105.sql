prompt --application/pages/page_00105
begin
--   Manifest
--     PAGE: 00105
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
 p_id=>105
,p_name=>unistr('Formulario Par\00E1metros')
,p_alias=>unistr('FORMULARIO-PAR\00C1METROS')
,p_page_mode=>'MODAL'
,p_step_title=>unistr('Formulario Par\00E1metros')
,p_autocomplete_on_off=>'OFF'
,p_step_template=>1661186590416509825
,p_page_template_options=>'#DEFAULT#:js-dialog-class-t-Drawer--pullOutEnd'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(20421126382365907)
,p_plug_name=>unistr('Formulario Par\00E1metros')
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'PARAMETROS'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(20430558624365920)
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
 p_id=>wwv_flow_imp.id(20430970871365921)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(20430558624365920)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20432300099365923)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(20430558624365920)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Eliminar'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>'P105_ID_PARAMETRO'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20432730133365923)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(20430558624365920)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Guardar'
,p_button_position=>'NEXT'
,p_button_condition=>'P105_ID_PARAMETRO'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20433158413365924)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(20430558624365920)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'NEXT'
,p_button_condition=>'P105_ID_PARAMETRO'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20421463413365911)
,p_name=>'P105_ID_PARAMETRO'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Id Parametro'
,p_source=>'ID_PARAMETRO'
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
 p_id=>wwv_flow_imp.id(20421890734365914)
,p_name=>'P105_TIPO_PARAMETRO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_prompt=>'Tipo Parametro'
,p_source=>'TIPO_PARAMETRO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:LIMITE_OC;LIMITE_OC,CONFIGURACION;CONFIGURACION'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20422221358365915)
,p_name=>'P105_CLAVE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_prompt=>'Clave'
,p_source=>'CLAVE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>100
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_inline_help_text=>unistr('La clave debe ser may\00FAsculas, n\00FAmeros y gui\00F3n bajo. Sin espacios.')
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'text_case', 'UPPER',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20422676777365915)
,p_name=>'P105_VALOR_NUMERICO'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_prompt=>'Valor Numerico'
,p_source=>'VALOR_NUMERICO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20423002419365916)
,p_name=>'P105_VALOR_TEXTO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_prompt=>'Valor Texto'
,p_source=>'VALOR_TEXTO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>500
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
 p_id=>wwv_flow_imp.id(20423447627365916)
,p_name=>'P105_DESCRIPCION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Descripcion'
,p_source=>'DESCRIPCION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>500
,p_cHeight=>4
,p_label_alignment=>'RIGHT'
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
 p_id=>wwv_flow_imp.id(20423819654365917)
,p_name=>'P105_MES_APLICABLE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_prompt=>'Mes Aplicable'
,p_source=>'MES_APLICABLE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:Enero;01,Febrero;02,Marzo;03,Abril;04,Mayo;05,Junio;06,Julio;07,Agosto;08,Septiembre;09,Octubre;10,Noviembre;11,Diciembre;12'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20424299379365917)
,p_name=>'P105_ANO_APLICABLE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_prompt=>unistr('A\00F1o Aplicable')
,p_source=>'ANO_APLICABLE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>4
,p_display_when=>':ANO_APLICABLE IS NULL OR REGEXP_LIKE(:ANO_APLICABLE, ''^\d{4}$'')'
,p_display_when2=>'PLSQL'
,p_display_when_type=>'EXPRESSION'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_inline_help_text=>unistr('El a\00F1o debe tener 4 d\00EDgitos (ej: 2026).')
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20424686693365917)
,p_name=>'P105_ACTIVO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_prompt=>'Activo'
,p_source=>'ACTIVO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:Activo;S,Inactivo;N'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20425000792365917)
,p_name=>'P105_FECHA_CREACION'
,p_source_data_type=>'DATE'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_source=>'FECHA_CREACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20425495162365917)
,p_name=>'P105_USUARIO_CREACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_source=>'USUARIO_CREACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20425891864365918)
,p_name=>'P105_FECHA_MODIFICACION'
,p_source_data_type=>'DATE'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_source=>'FECHA_MODIFICACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20426239458365918)
,p_name=>'P105_USUARIO_MODIFICACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_item_source_plug_id=>wwv_flow_imp.id(20421126382365907)
,p_source=>'USUARIO_MODIFICACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(20237450192558345)
,p_validation_name=>'VAL_CLAVE_FORMATO'
,p_validation_sequence=>10
,p_validation=>'REGEXP_LIKE(:P105_CLAVE, ''^[A-Z0-9_]+$'')'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>unistr('La clave debe ser may\00FAsculas, n\00FAmeros y gui\00F3n bajo. Sin espacios.')
,p_when_button_pressed=>wwv_flow_imp.id(20432730133365923)
,p_associated_item=>wwv_flow_imp.id(20422221358365915)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(20237541586558346)
,p_validation_name=>'VAL_CLAVE_FORMATO_1'
,p_validation_sequence=>20
,p_validation=>'REGEXP_LIKE(:P105_CLAVE, ''^[A-Z0-9_]+$'')'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>unistr('La clave debe ser may\00FAsculas, n\00FAmeros y gui\00F3n bajo. Sin espacios.')
,p_when_button_pressed=>wwv_flow_imp.id(20433158413365924)
,p_associated_item=>wwv_flow_imp.id(20422221358365915)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(20431033839365921)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(20430970871365921)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20431809733365923)
,p_event_id=>wwv_flow_imp.id(20431033839365921)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20433985410365925)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(20421126382365907)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>unistr('Process form Formulario Par\00E1metros')
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>20433985410365925
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20434383603365925)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>20434383603365925
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20433509250365924)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(20421126382365907)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>unistr('Initialize form Formulario Par\00E1metros')
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>20433509250365924
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20237399019558344)
,p_process_sequence=>5
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Auditoria'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('-- INSERT: PK vac\00EDa = registro nuevo'),
'IF :P105_ID_PARAMETRO IS NULL THEN',
'  :P105_USUARIO_CREACION  := :APP_USER;',
'  :P105_FECHA_CREACION    := SYSDATE;',
'END IF;',
'',
'-- Siempre en INSERT y UPDATE',
':P105_USUARIO_MODIFICACION := :APP_USER;',
':P105_FECHA_MODIFICACION   := SYSDATE;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>20237399019558344
);
wwv_flow_imp.component_end;
end;
/

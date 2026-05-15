prompt --application/pages/page_00036
begin
--   Manifest
--     PAGE: 00036
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
 p_id=>36
,p_name=>'Producto Proveedor'
,p_alias=>'PRODUCTO-PROVEEDOR1'
,p_page_mode=>'MODAL'
,p_step_title=>'Producto Proveedor'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_page_is_public_y_n=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
,p_created_on=>wwv_flow_imp.dz('20250507105931Z')
,p_last_updated_on=>wwv_flow_imp.dz('20260511064706Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11783115562223053)
,p_plug_name=>'Producto Proveedor'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'PRODUCTO_PROVEEDORES'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064107Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11784877747223054)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11785293936223055)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(11784877747223054)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancel'
,p_button_position=>'CLOSE'
,p_button_alignment=>'RIGHT'
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11786613154223056)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(11784877747223054)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Delete'
,p_button_position=>'DELETE'
,p_button_alignment=>'RIGHT'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>':P36_ID_PRODUCTO is not null and :P36_ID_PERSONA is not null'
,p_button_condition2=>'SQL'
,p_button_condition_type=>'EXPRESSION'
,p_database_action=>'DELETE'
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11787076215223056)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(11784877747223054)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Apply Changes'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_button_condition=>':P36_ID_PRODUCTO is not null and :P36_ID_PERSONA is not null'
,p_button_condition2=>'SQL'
,p_button_condition_type=>'EXPRESSION'
,p_database_action=>'UPDATE'
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11787421038223056)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(11784877747223054)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Create'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_button_condition=>':P36_ID_PRODUCTO is null or :P36_ID_PERSONA is null'
,p_button_condition2=>'SQL'
,p_button_condition_type=>'EXPRESSION'
,p_database_action=>'INSERT'
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11783476438223053)
,p_name=>'P36_ID_PRODUCTO'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_is_primary_key=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_prompt=>'Producto'
,p_source=>'ID_PRODUCTO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_named_lov=>'PRODUCTOS.NOMBRE'
,p_lov_display_null=>'YES'
,p_cSize=>30
,p_colspan=>6
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20251121090721Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11783814705223054)
,p_name=>'P36_ID_PERSONA'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_is_primary_key=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_prompt=>'Proveedor'
,p_source=>'ID_PERSONA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_named_lov=>'PROVEEDORES.NOMBRE'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ',
'  p.primer_nombre || '' '' || p.primer_apellido  AS display_value,',
'  pr.id_persona                             AS return_value',
'FROM proveedores pr',
'JOIN personas p ',
'     ON p.id_persona = pr.id_persona',
'ORDER BY p.primer_nombre, p.primer_apellido;',
''))
,p_lov_display_null=>'YES'
,p_cSize=>30
,p_colspan=>6
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20251121090721Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14820048092450425)
,p_name=>'P36_PRECIO'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_prompt=>'Precio'
,p_source=>'PRECIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
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
,p_created_on=>wwv_flow_imp.dz('20251121090721Z')
,p_updated_on=>wwv_flow_imp.dz('20251121090721Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20235437262558325)
,p_name=>'P36_CODIGO_REFERENCIA'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_prompt=>'Codigo Referencia'
,p_source=>'CODIGO_REFERENCIA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260511064107Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064107Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20235554369558326)
,p_name=>'P36_FECHA_INICIO'
,p_source_data_type=>'DATE'
,p_is_primary_key=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_prompt=>'Fecha Inicio'
,p_source=>'FECHA_INICIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260511064107Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064706Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20235688137558327)
,p_name=>'P36_FECHA_FIN'
,p_source_data_type=>'DATE'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_prompt=>'Fecha Fin'
,p_source=>'FECHA_FIN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260511064107Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064107Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20235724836558328)
,p_name=>'P36_ESTADO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_prompt=>'Estado'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:ACTIVO;ACTIVO,INACTIVO;INACTIVO,SUSPENDIDO;SUSPENDIDO'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260511064107Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064107Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20235890911558329)
,p_name=>'P36_FECHA_CREACION'
,p_source_data_type=>'DATE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_source=>'FECHA_CREACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260511064107Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064413Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20235989717558330)
,p_name=>'P36_USUARIO_CREACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_source=>'USUARIO_CREACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260511064107Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064413Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20236016802558331)
,p_name=>'P36_FECHA_MODIFICACION'
,p_source_data_type=>'DATE'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_source=>'FECHA_MODIFICACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260511064107Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064413Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20236192281558332)
,p_name=>'P36_USUARIO_MODIFICACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_item_source_plug_id=>wwv_flow_imp.id(11783115562223053)
,p_source=>'USUARIO_MODIFICACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260511064107Z')
,p_updated_on=>wwv_flow_imp.dz('20260511064413Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11785367933223055)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(11785293936223055)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11786150985223055)
,p_event_id=>wwv_flow_imp.id(11785367933223055)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11788295596223057)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(11783115562223053)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Producto Proveedor'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>11788295596223057
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11788673299223057)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>11788673299223057
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11787825729223056)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(11783115562223053)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Producto Proveedor'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>11787825729223056
,p_created_on=>wwv_flow_imp.dz('20250507105932Z')
,p_updated_on=>wwv_flow_imp.dz('20250507105932Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

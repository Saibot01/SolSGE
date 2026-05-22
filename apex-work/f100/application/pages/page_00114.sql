prompt --application/pages/page_00114
begin
--   Manifest
--     PAGE: 00114
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
 p_id=>114
,p_name=>'Nueva Transferencia de Stock'
,p_alias=>'NUEVA-TRANSFERENCIA-STOCK'
,p_page_mode=>'MODAL'
,p_step_title=>'Nueva Transferencia de Stock'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#:ui-dialog--stretch'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'17'
);
-- -----------------------------------------------------------------------
-- Buttons bar region (REGION_POSITION_03)
-- -----------------------------------------------------------------------
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(5600114001)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
);
-- -----------------------------------------------------------------------
-- Form region
-- -----------------------------------------------------------------------
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(5600114002)
,p_plug_name=>'Transferencia de Stock'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
-- -----------------------------------------------------------------------
-- Items
-- -----------------------------------------------------------------------
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(5600114010)
,p_name=>'P114_ID_PRODUCTO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(5600114002)
,p_prompt=>'Producto'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT NOMBRE, ID_PRODUCTO',
'FROM   PRODUCTOS',
'ORDER BY NOMBRE'))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'Y'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(5600114020)
,p_name=>'P114_ID_OFICINA_ORIGEN'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(5600114002)
,p_prompt=>'Origen'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DESCRIPCION, CODIGO_OFICINA',
'FROM   OFICINAS',
'ORDER BY DESCRIPCION'))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'Y'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(5600114025)
,p_name=>'P114_STOCK_DISPONIBLE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(5600114002)
,p_prompt=>'Stock Disponible'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'Y'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'N',
  'show_line_breaks', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(5600114030)
,p_name=>'P114_ID_OFICINA_DESTINO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(5600114002)
,p_prompt=>'Destino'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DESCRIPCION, CODIGO_OFICINA',
'FROM   OFICINAS',
'ORDER BY DESCRIPCION'))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'Y'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(5600114040)
,p_name=>'P114_CANTIDAD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(5600114002)
,p_prompt=>'Cantidad'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'Y'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(5600114050)
,p_name=>'P114_OBSERVACION'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(5600114002)
,p_prompt=>'Observacion'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>30
,p_cMaxlength=>255
,p_cHeight=>4
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'Y'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(5600114060)
,p_name=>'P114_USUARIO'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(5600114002)
,p_item_default=>':APP_USER'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'Y'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
-- -----------------------------------------------------------------------
-- Buttons
-- -----------------------------------------------------------------------
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(5600114070)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(5600114001)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(5600114080)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(5600114001)
,p_button_name=>'TRANSFERIR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--large'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Transferir'
,p_button_position=>'NEXT'
,p_database_action=>'INSERT'
);
-- -----------------------------------------------------------------------
-- Dynamic Actions
-- -----------------------------------------------------------------------
-- DA: Cancel Dialog
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(5600114100)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(5600114070)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(5600114101)
,p_event_id=>wwv_flow_imp.id(5600114100)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
-- DA: Actualizar stock cuando cambia el producto
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(5600114090)
,p_name=>'Actualizar Stock — Producto'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P114_ID_PRODUCTO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(5600114091)
,p_event_id=>wwv_flow_imp.id(5600114090)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  SELECT NVL(CANTIDAD, 0)',
'  INTO   :P114_STOCK_DISPONIBLE',
'  FROM   STOCK_PRODUCTO',
'  WHERE  ID_PRODUCTO = :P114_ID_PRODUCTO',
'    AND  ID_OFICINA  = :P114_ID_OFICINA_ORIGEN;',
'EXCEPTION',
'  WHEN NO_DATA_FOUND THEN',
'    :P114_STOCK_DISPONIBLE := 0;',
'END;'))
,p_attribute_02=>'P114_ID_PRODUCTO,P114_ID_OFICINA_ORIGEN'
,p_attribute_03=>'P114_STOCK_DISPONIBLE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
-- DA: Actualizar stock cuando cambia la oficina origen
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(5600114093)
,p_name=>'Actualizar Stock — Origen'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P114_ID_OFICINA_ORIGEN'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(5600114094)
,p_event_id=>wwv_flow_imp.id(5600114093)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  SELECT NVL(CANTIDAD, 0)',
'  INTO   :P114_STOCK_DISPONIBLE',
'  FROM   STOCK_PRODUCTO',
'  WHERE  ID_PRODUCTO = :P114_ID_PRODUCTO',
'    AND  ID_OFICINA  = :P114_ID_OFICINA_ORIGEN;',
'EXCEPTION',
'  WHEN NO_DATA_FOUND THEN',
'    :P114_STOCK_DISPONIBLE := 0;',
'END;'))
,p_attribute_02=>'P114_ID_PRODUCTO,P114_ID_OFICINA_ORIGEN'
,p_attribute_03=>'P114_STOCK_DISPONIBLE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
-- -----------------------------------------------------------------------
-- Processes
-- -----------------------------------------------------------------------
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(5600114110)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRC_TRANSFERIR_STOCK'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_TRANSFERIR_STOCK(',
'    p_id_producto     => :P114_ID_PRODUCTO,',
'    p_oficina_origen  => :P114_ID_OFICINA_ORIGEN,',
'    p_oficina_destino => :P114_ID_OFICINA_DESTINO,',
'    p_cantidad        => :P114_CANTIDAD,',
'    p_observacion     => :P114_OBSERVACION,',
'    p_usuario         => :APP_USER',
'  );',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(5600114080)
,p_internal_uid=>5600114110
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(5600114120)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'TRANSFERIR'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>5600114120
);
wwv_flow_imp.component_end;
end;
/

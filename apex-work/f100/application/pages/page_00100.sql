prompt --application/pages/page_00100
begin
--   Manifest
--     PAGE: 00100
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
 p_id=>100
,p_name=>'Cobro de Cuotas'
,p_alias=>'COBRO-DE-CUOTAS'
,p_page_mode=>'MODAL'
,p_step_title=>'Cobro de Cuotas'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>1661186590416509825
,p_page_template_options=>'#DEFAULT#:js-dialog-class-t-Drawer--pullOutEnd'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(16172361133278059)
,p_plug_name=>'Cobro de Cuotas'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'CUENTAS_COBRAR_DET'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(16177124507278067)
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
 p_id=>wwv_flow_imp.id(16177581998278067)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(16177124507278067)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancel'
,p_button_position=>'CLOSE'
,p_button_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(21980144938430746)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(16177124507278067)
,p_button_name=>'COBRAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Cobrar'
,p_button_position=>'NEXT'
,p_show_processing=>'Y'
,p_button_condition=>'P100_NRO_RECIBO_GENERADO'
,p_button_condition_type=>'ITEM_IS_NULL'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(21980315071430748)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(16177124507278067)
,p_button_name=>'IMPRIMIR'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Imprimir'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:119:&SESSION.::&DEBUG.::P119_ID_RECIBO:&P100_ID_MOVIMIENTO_GENERADO.'
,p_button_condition=>'P100_NRO_RECIBO_GENERADO'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16172680165278061)
,p_name=>'P100_ID_DETALLE'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_source_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Id Detalle'
,p_source=>'ID_DETALLE'
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
 p_id=>wwv_flow_imp.id(16173035050278062)
,p_name=>'P100_ID_CXC'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_source_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_prompt=>'Id Cxc'
,p_source=>'ID_CXC'
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16173791454278065)
,p_name=>'P100_NRO_CUOTA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_source_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_prompt=>'Nro Cuota'
,p_source=>'NRO_CUOTA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16174102116278065)
,p_name=>'P100_FECHA_VENCIMIENTO'
,p_source_data_type=>'DATE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_source_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_prompt=>'Fecha Vencimiento'
,p_format_mask=>'DD/MM/YYYY'
,p_source=>'FECHA_VENCIMIENTO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16174576077278065)
,p_name=>'P100_MONTO_CUOTA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_source_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_prompt=>'Monto Cuota'
,p_source=>'MONTO_CUOTA'
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16174954951278066)
,p_name=>'P100_ESTADO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_source_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_prompt=>'Estado'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
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
 p_id=>wwv_flow_imp.id(21979177103430736)
,p_name=>'P100_ID_CAJA'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_default=>'FN_CAJA_ABIERTA_USUARIO(:APP_USER)'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_prompt=>'Caja'
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
 p_id=>wwv_flow_imp.id(21979265098430737)
,p_name=>'P100_OFICINA'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_default=>'FN_OFICINA_USUARIO_V2(:APP_USER)'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(21979353029430738)
,p_name=>'P100_ID_TALONARIO_RC'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_prompt=>'Talonario Recibo'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT MIN(ID_TALONARIO) FROM',
'  V_TALONARIOS_DISPONIBLES WHERE TIPO_COMPROBANTE=''RC'' AND ID_OFICINA  = :P100_OFICINA'))
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(21979413467430739)
,p_name=>'P100_ID_FORMA_PAGO'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_default=>'21'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(21979525735430740)
,p_name=>'P100_ID_METODO_PAGO'
,p_is_required=>true
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_default=>'1'
,p_prompt=>'Metodo Pago'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT NOMBRE d, ID_METODO_PAGO r FROM METODOS_PAGO ORDER BY 1'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(21979645947430741)
,p_name=>'P100_MONTO_PAGO'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_item_default=>':P100_MONTO_CUOTA'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_prompt=>'Monto Pago Recibido'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(21979766204430742)
,p_name=>'P100_VUELTO'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Vuelto'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(21979870137430743)
,p_name=>'P100_NRO_REFERENCIA'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_prompt=>'Nro. Referencia'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_display_when=>'P100_ID_METODO_PAGO'
,p_display_when2=>'1'
,p_display_when_type=>'VAL_OF_ITEM_IN_COND_NOT_EQ_COND2'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(21979955209430744)
,p_name=>'P100_NRO_RECIBO_GENERADO'
,p_item_sequence=>150
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_prompt=>'Nro. Recibo Generado'
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
 p_id=>wwv_flow_imp.id(21980012628430745)
,p_name=>'P100_ID_MOVIMIENTO_GENERADO'
,p_item_sequence=>160
,p_item_plug_id=>wwv_flow_imp.id(16172361133278059)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(16177690053278067)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(16177581998278067)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(16178432890278068)
,p_event_id=>wwv_flow_imp.id(16177690053278067)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(22998553238484102)
,p_name=>'Calcular Vuelto'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P100_MONTO_PAGO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(22998649508484103)
,p_event_id=>wwv_flow_imp.id(22998553238484102)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SET_VALUE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P100_VUELTO'
,p_attribute_01=>'PLSQL_EXPRESSION'
,p_attribute_04=>'GREATEST(NVL(:P100_MONTO_PAGO,0) - NVL(:P100_MONTO_CUOTA,0), 0)'
,p_attribute_07=>'P100_MONTO_PAGO,P100_MONTO_CUOTA'
,p_attribute_08=>'Y'
,p_attribute_09=>'N'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(22998793544484104)
,p_name=>'Visibilidad Nro Referencia'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P100_ID_METODO_PAGO'
,p_triggering_condition_type=>'JAVASCRIPT_EXPRESSION'
,p_triggering_expression=>'$v(''P100_ID_METODO_PAGO'') != ''1'''
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(22998897684484105)
,p_event_id=>wwv_flow_imp.id(22998793544484104)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P100_NRO_REFERENCIA'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(22998941252484106)
,p_event_id=>wwv_flow_imp.id(22998793544484104)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P100_NRO_REFERENCIA'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(22998445661484101)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cobrar cuota'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_nro_recibo VARCHAR2(20);',
'BEGIN',
'  v_nro_recibo := FN_COBRAR_CUOTA(',
'    p_id_detalle      => :P100_ID_DETALLE,',
'    p_id_caja         => :P100_ID_CAJA,',
'    p_id_talonario_rc => :P100_ID_TALONARIO_RC,',
'    p_id_forma_pago   => :P100_ID_FORMA_PAGO,',
'    p_id_metodo_pago  => :P100_ID_METODO_PAGO,',
'    p_monto_pago      => :P100_MONTO_PAGO,',
'    p_moneda          => ''PYG'',',
'    p_nro_ref         => :P100_NRO_REFERENCIA,',
'    p_usuario         => :APP_USER',
'  );',
'  :P100_NRO_RECIBO_GENERADO := v_nro_recibo;',
'',
'  SELECT ID_MOVIMIENTO INTO :P100_ID_MOVIMIENTO_GENERADO',
'    FROM MOVIMIENTOS_CAJA',
'   WHERE NRO_RECIBO = v_nro_recibo',
'     AND ID_TALONARIO_RECIBO = :P100_ID_TALONARIO_RC;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(21980144938430746)
,p_process_success_message=>'Cobro registrado. Recibo &P100_NRO_RECIBO_GENERADO.'
,p_internal_uid=>22998445661484101
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16180978099278069)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CANCEL'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>16180978099278069
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(21980496445430749)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Validar caja del dia'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_id_caja NUMBER := FN_CAJA_ABIERTA_USUARIO(:APP_USER);',
'BEGIN',
'  IF v_id_caja IS NULL THEN',
'    apex_util.redirect_url(',
'      apex_page.get_url(p_page => 65, p_clear_cache => ''65'')',
'        || ''&notification_msg='' || apex_util.url_encode(''No tenes caja abierta. Abrila para cobrar cuotas.'')',
'    );',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>21980496445430749
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(21980595209430750)
,p_process_sequence=>7
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Validar talonario RC vigente'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_cnt NUMBER;',
'BEGIN',
'  SELECT COUNT(*) INTO v_cnt',
'    FROM V_TALONARIOS_DISPONIBLES',
'   WHERE TIPO_COMPROBANTE = ''RC''',
'     AND ID_OFICINA = FN_OFICINA_USUARIO_V2(:APP_USER);',
'  IF v_cnt = 0 THEN',
'    apex_error.add_error(',
'      p_message          => ''No hay talonario de recibo (RC) vigente para tu oficina. Avisa al admin.'',',
'      p_display_location => apex_error.c_inline_in_notification);',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>21980595209430750
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16180123692278068)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(16172361133278059)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Cobro de Cuotas'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>16180123692278068
);
wwv_flow_imp.component_end;
end;
/

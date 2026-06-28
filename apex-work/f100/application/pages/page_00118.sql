prompt --application/pages/page_00118
begin
--   Manifest
--     PAGE: 00118
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
 p_id=>118
,p_name=>'Detalle Presupuesto'
,p_alias=>'DETALLE-PRESUPUESTO'
,p_page_mode=>'MODAL'
,p_step_title=>'Detalle Presupuesto'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(21978273595430727)
,p_plug_name=>'Detalle'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    l_total NUMBER := 0;',
'    l_html  CLOB := ''<table class="t-Report-report" style="width:100%;border-collapse:collapse;">''',
'                 || ''<thead><tr><th>Producto</th><th style="text-align:right;">Cantidad</th>''',
'                 || ''<th style="text-align:right;">Precio Unit.</th>''',
'                 || ''<th style="text-align:right;">Total</th></tr></thead><tbody>'';',
'  BEGIN',
'    FOR r IN (',
'      SELECT pr.NOMBRE AS producto, d.CANTIDAD, d.PRECIO_UNITARIO, d.TOTAL',
'        FROM WKSP_WORKPLACE.DETALLE_ORDEN d',
'        JOIN WKSP_WORKPLACE.PRODUCTOS     pr ON pr.ID_PRODUCTO = d.ID_PRODUCTO',
'       WHERE d.ID_ORDEN = :P118_ID_ORDEN',
'       ORDER BY d.ID_DETALLE',
'    ) LOOP',
'      l_html := l_html',
'             || ''<tr><td>'' || APEX_ESCAPE.HTML(r.producto) || ''</td>''',
'             || ''<td style="text-align:right;">'' || TO_CHAR(r.CANTIDAD,''FM999G999G990'') || ''</td>''',
'             || ''<td style="text-align:right;">'' || TO_CHAR(r.PRECIO_UNITARIO,''FM999G999G990D00'') || ''</td>''',
'             || ''<td style="text-align:right;">'' || TO_CHAR(r.TOTAL,''FM999G999G990D00'') || ''</td></tr>'';',
'      l_total := l_total + NVL(r.TOTAL,0);',
'    END LOOP;',
'    l_html := l_html || ''</tbody><tfoot><tr>''',
'                    || ''<td colspan="3" style="text-align:right;"><strong>Total</strong></td>''',
'                    || ''<td style="text-align:right;"><strong>''',
'                    || TO_CHAR(l_total,''FM999G999G990D00'') || ''</strong></td>''',
'                    || ''</tr></tfoot></table>'';',
'    RETURN l_html;',
'  END;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
,p_ajax_items_to_submit=>'P118_ID_ORDEN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(22402663833786967)
,p_plug_name=>'Detalle Presupuesto'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'ORDENES_VENTA'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(22412107152786998)
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
 p_id=>wwv_flow_imp.id(22412575068786998)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(22412107152786998)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cerrar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(21978597252430730)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(22412107152786998)
,p_button_name=>'ANULAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--danger'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Anular'
,p_button_position=>'CREATE'
,p_confirm_message=>unistr('\00BFConfirma anular este presupuesto?')
,p_confirm_style=>'danger'
,p_button_condition=>':P118_ESTADO IN (''PENDIENTE'',''APROBADO'')'
,p_button_condition2=>'PLSQL'
,p_button_condition_type=>'EXPRESSION'
,p_database_action=>'UPDATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(21978427085430729)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(22412107152786998)
,p_button_name=>'APROBAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Aprobar'
,p_button_position=>'NEXT'
,p_button_condition=>'P118_ESTADO'
,p_button_condition2=>'PENDIENTE'
,p_button_condition_type=>'VAL_OF_ITEM_IN_COND_EQ_COND2'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(21978396506430728)
,p_name=>'P118_MOTIVO'
,p_item_sequence=>30
,p_use_cache_before_default=>'NO'
,p_prompt=>unistr('Motivo de anulaci\00F3n')
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cHeight=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_help_text=>'Obligatorio cuando se anula el presupuesto'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(22403049004786968)
,p_name=>'P118_ID_ORDEN'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Id Orden'
,p_source=>'ID_ORDEN'
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
 p_id=>wwv_flow_imp.id(22403475626786974)
,p_name=>'P118_ID_PERSONA'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Nombre Cliente'
,p_source=>'ID_PERSONA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'PERSONA.NOMBRE'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_read_only_when_type=>'ALWAYS'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(22403854043786978)
,p_name=>'P118_FECHA_ORDEN'
,p_source_data_type=>'DATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Fecha Orden'
,p_source=>'FECHA_ORDEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>32
,p_cMaxlength=>255
,p_begin_on_new_line=>'N'
,p_read_only_when_type=>'ALWAYS'
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(22404268382786979)
,p_name=>'P118_ESTADO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Estado'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>20
,p_read_only_when_type=>'ALWAYS'
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
 p_id=>wwv_flow_imp.id(22404692595786979)
,p_name=>'P118_TOTAL'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Total'
,p_source=>'TOTAL'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_begin_on_new_line=>'N'
,p_read_only_when_type=>'ALWAYS'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(22405049458786980)
,p_name=>'P118_OBSERVACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Observacion'
,p_source=>'OBSERVACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_read_only_when_type=>'ALWAYS'
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
 p_id=>wwv_flow_imp.id(22405470750786981)
,p_name=>'P118_ID_OFICINA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Id Oficina'
,p_source=>'ID_OFICINA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'OFICINAS.DESCRIPCION'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_read_only_when_type=>'ALWAYS'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(22405899436786982)
,p_name=>'P118_FECHA_APROBACION'
,p_source_data_type=>'DATE'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Fecha Aprobacion'
,p_source=>'FECHA_APROBACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>32
,p_cMaxlength=>255
,p_read_only_when_type=>'ALWAYS'
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(22406265170786983)
,p_name=>'P118_USUARIO_APROBACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Usuario Aprobacion'
,p_source=>'USUARIO_APROBACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>60
,p_begin_on_new_line=>'N'
,p_read_only_when_type=>'ALWAYS'
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
 p_id=>wwv_flow_imp.id(22406601838786984)
,p_name=>'P118_FECHA_ANULACION'
,p_source_data_type=>'DATE'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Fecha Anulacion'
,p_source=>'FECHA_ANULACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>32
,p_cMaxlength=>255
,p_read_only_when_type=>'ALWAYS'
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(22407064146786985)
,p_name=>'P118_USUARIO_ANULACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Usuario Anulacion'
,p_source=>'USUARIO_ANULACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>60
,p_begin_on_new_line=>'N'
,p_read_only_when_type=>'ALWAYS'
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
 p_id=>wwv_flow_imp.id(22407457623786986)
,p_name=>'P118_MOTIVO_ANULACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Motivo Anulacion'
,p_source=>'MOTIVO_ANULACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>400
,p_cHeight=>4
,p_read_only_when_type=>'ALWAYS'
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
 p_id=>wwv_flow_imp.id(22407859777786987)
,p_name=>'P118_FECHA_VENCIMIENTO'
,p_source_data_type=>'DATE'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_item_source_plug_id=>wwv_flow_imp.id(22402663833786967)
,p_prompt=>'Fecha Vencimiento'
,p_source=>'FECHA_VENCIMIENTO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>32
,p_cMaxlength=>255
,p_begin_on_new_line=>'N'
,p_read_only_when_type=>'ALWAYS'
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
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(21978668034430731)
,p_validation_name=>'Motivo requerido al anular'
,p_validation_sequence=>10
,p_validation=>':P118_MOTIVO IS NOT NULL AND LENGTH(TRIM(:P118_MOTIVO)) > 0'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>unistr('Debe ingresar el motivo de anulaci\00F3n.')
,p_when_button_pressed=>wwv_flow_imp.id(21978597252430730)
,p_associated_item=>wwv_flow_imp.id(21978396506430728)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(22412619650786998)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(22412575068786998)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(22413450791787002)
,p_event_id=>wwv_flow_imp.id(22412619650786998)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(21978769664430732)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'ProcesarCambioEstado'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
' DECLARE',
'    v_actual WKSP_WORKPLACE.ORDENES_VENTA.ESTADO%TYPE;',
'    v_target VARCHAR2(20);',
'  BEGIN',
'    v_target := CASE :REQUEST',
'                  WHEN ''APROBAR'' THEN ''APROBADO''',
'                  WHEN ''ANULAR''  THEN ''ANULADO''',
'                END;',
'    IF v_target IS NULL THEN RETURN; END IF;',
'',
'    SELECT ESTADO INTO v_actual',
'      FROM WKSP_WORKPLACE.ORDENES_VENTA',
'     WHERE ID_ORDEN = :P118_ID_ORDEN',
'       FOR UPDATE;',
'',
'    IF WKSP_WORKPLACE.FN_PUEDE_TRANSICION_OV(v_actual, v_target) <> ''S'' THEN',
'      apex_error.add_error(',
unistr('        p_message => ''Transici\00F3n inv\00E1lida: '' || v_actual || '' \2192 '' || v_target,'),
'        p_display_location => apex_error.c_inline_in_notification);',
'      RETURN;',
'    END IF;',
'',
'    UPDATE WKSP_WORKPLACE.ORDENES_VENTA',
'       SET ESTADO             = v_target,',
'           FECHA_APROBACION   = CASE WHEN v_target = ''APROBADO'' THEN WKSP_WORKPLACE.FN_AHORA     ELSE FECHA_APROBACION   END,',
'           USUARIO_APROBACION = CASE WHEN v_target = ''APROBADO'' THEN :APP_USER   ELSE USUARIO_APROBACION END,',
'           FECHA_ANULACION    = CASE WHEN v_target = ''ANULADO''  THEN WKSP_WORKPLACE.FN_AHORA     ELSE FECHA_ANULACION    END,',
'           USUARIO_ANULACION  = CASE WHEN v_target = ''ANULADO''  THEN :APP_USER   ELSE USUARIO_ANULACION  END,',
'           MOTIVO_ANULACION   = CASE WHEN v_target = ''ANULADO''  THEN :P118_MOTIVO ELSE MOTIVO_ANULACION END',
'     WHERE ID_ORDEN = :P118_ID_ORDEN;',
'',
'    apex_application.g_print_success_message :=',
'      ''Presupuesto #'' || :P118_ID_ORDEN || '' marcado como '' || v_target || ''.'';',
'  END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'APROBAR,ANULAR'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>21978769664430732
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(22415953042787008)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'APROBAR,ANULAR'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>22415953042787008
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(22415193590787006)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(22402663833786967)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Detalle Presupuesto'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>22415193590787006
);
wwv_flow_imp.component_end;
end;
/

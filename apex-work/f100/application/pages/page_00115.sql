prompt --application/pages/page_00115
begin
--   Manifest
--     PAGE: 00115
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.16'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_page.create_page(
 p_id=>115
,p_name=>'Cambio de Estado de Presupuesto'
,p_alias=>'CAMBIO-ESTADO-PRESUPUESTO'
,p_page_mode=>'MODAL'
,p_step_title=>'Cambio de Estado de Presupuesto'
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#:ui-dialog--stretch'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_rejoin_existing_sessions=>'Y'
,p_autocomplete_on_off=>'OFF'
);
-- =====================================================================
-- REGIONES
-- =====================================================================
-- Region 1: Datos del Presupuesto (form sobre tabla ORDENES_VENTA, items display-only)
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000000100)
,p_plug_name=>'Datos del Presupuesto'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'ORDENES_VENTA'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'u'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
-- Region 2: Detalle (HTML generado por PL/SQL - read-only, simple)
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000000200)
,p_plug_name=>'Detalle'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  l_total number := 0;',
'  l_align varchar2(50) := ''style="text-align:right;"'';',
'begin',
'  htp.p(''<table class="t-Report-report" style="width:100%;border-collapse:collapse;">'');',
'  htp.p(''<thead><tr>''||',
'        ''<th>Producto</th>''||',
'        ''<th ''||l_align||''>Cantidad</th>''||',
'        ''<th ''||l_align||''>Precio Unit.</th>''||',
'        ''<th ''||l_align||''>Total</th>''||',
'        ''</tr></thead><tbody>'');',
'  for r in (',
'    select pr.NOMBRE as producto,',
'           d.CANTIDAD,',
'           d.PRECIO_UNITARIO,',
'           d.TOTAL',
'      from WKSP_WORKPLACE.DETALLE_ORDEN d',
'      join WKSP_WORKPLACE.PRODUCTOS     pr on pr.ID_PRODUCTO = d.ID_PRODUCTO',
'     where d.ID_ORDEN = :P115_ID_ORDEN',
'     order by d.ID_DETALLE',
'  ) loop',
'    htp.p(''<tr>''||',
'          ''<td>''||apex_escape.html(r.producto)||''</td>''||',
'          ''<td ''||l_align||''>''||to_char(r.cantidad,''FM999G999G990'')||''</td>''||',
'          ''<td ''||l_align||''>''||to_char(r.precio_unitario,''FM999G999G990D00'')||''</td>''||',
'          ''<td ''||l_align||''>''||to_char(r.total,''FM999G999G990D00'')||''</td>''||',
'          ''</tr>'');',
'    l_total := l_total + nvl(r.total,0);',
'  end loop;',
'  htp.p(''</tbody><tfoot><tr>''||',
'        ''<td colspan="3" ''||l_align||''><strong>Total</strong></td>''||',
'        ''<td ''||l_align||''><strong>''||to_char(l_total,''FM999G999G990D00'')||''</strong></td>''||',
'        ''</tr></tfoot></table>'');',
'end;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
-- Region 3: Cambio de Estado (contenedor para item motivo)
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000000300)
,p_plug_name=>'Cambio de Estado'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>30
,p_plug_source_type=>'NATIVE_HTML'
);
-- Region 4: Buttons (button bar, region position 03)
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000000400)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>40
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
);
-- =====================================================================
-- BOTONES
-- =====================================================================
-- Boton CERRAR (siempre visible, no submit - cierra dialogo via DA)
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000000700)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000000400)
,p_button_name=>'CERRAR'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cerrar'
,p_button_position=>'CLOSE'
,p_button_alignment=>'RIGHT'
);
-- Boton ANULAR (visible si estado actual IN PENDIENTE,APROBADO)
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000000600)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(36000000000000400)
,p_button_name=>'ANULAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--danger'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Anular'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_button_condition=>':P115_ESTADO_ACTUAL IN (''PENDIENTE'',''APROBADO'')'
,p_button_condition2=>'SQL'
,p_button_condition_type=>'EXPRESSION'
,p_button_execute_validations=>'Y'
,p_confirm_message=>unistr('\00BFConfirma anular este presupuesto?')
,p_confirm_style=>'danger'
,p_database_action=>'UPDATE'
);
-- Boton APROBAR (visible solo si estado actual = PENDIENTE)
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000000500)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(36000000000000400)
,p_button_name=>'APROBAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Aprobar'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_button_condition=>'P115_ESTADO_ACTUAL'
,p_button_condition2=>'PENDIENTE'
,p_button_condition_type=>'VAL_OF_ITEM_IN_COND_EQ_COND2'
,p_button_execute_validations=>'Y'
,p_database_action=>'UPDATE'
);
-- =====================================================================
-- ITEMS
-- =====================================================================
-- P115_ID_ORDEN (hidden, key, value protected - viene por URL desde P52)
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000000800)
,p_name=>'P115_ID_ORDEN'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_use_cache_before_default=>'NO'
,p_prompt=>unistr('N\00BA Presupuesto')
,p_source=>'ID_ORDEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
-- P115_FECHA_ORDEN (display only)
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000000900)
,p_name=>'P115_FECHA_ORDEN'
,p_source_data_type=>'DATE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Fecha'
,p_source=>'FECHA_ORDEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_format_mask=>'DD/MM/YYYY'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
-- P115_ESTADO_ACTUAL (display only) - manejado por buttons via conditions
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000001000)
,p_name=>'P115_ESTADO_ACTUAL'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Estado Actual'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
-- P115_CLIENTE (display only, fetched via SQL JOIN)
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000001100)
,p_name=>'P115_CLIENTE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Cliente'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select p.PRIMER_NOMBRE || '' '' || p.PRIMER_APELLIDO || '' ('' || p.NRO_DOCUMENTO || '')''',
'  from WKSP_WORKPLACE.ORDENES_VENTA  o',
'  left join WKSP_WORKPLACE.PERSONAS  p on p.ID_PERSONA = o.ID_PERSONA',
' where o.ID_ORDEN = :P115_ID_ORDEN'))
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
-- P115_OFICINA (display only, fetched via SQL LEFT JOIN para tolerar ID_OFICINA null)
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000001200)
,p_name=>'P115_OFICINA'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Oficina'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select coalesce(f.DESCRIPCION, ''(sin oficina)'')',
'  from WKSP_WORKPLACE.ORDENES_VENTA  o',
'  left join WKSP_WORKPLACE.OFICINAS  f on f.CODIGO_OFICINA = o.ID_OFICINA',
' where o.ID_ORDEN = :P115_ID_ORDEN'))
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
-- P115_TOTAL (display only, formato moneda)
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000001300)
,p_name=>'P115_TOTAL'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Total'
,p_source=>'TOTAL'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_format_mask=>'FML999G999G999G999G990D00'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
-- P115_OBSERVACION (display only)
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000001400)
,p_name=>'P115_OBSERVACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_item_source_plug_id=>wwv_flow_imp.id(36000000000000100)
,p_use_cache_before_default=>'NO'
,p_prompt=>unistr('Observaci\00F3n')
,p_source=>'OBSERVACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
-- P115_MOTIVO (textarea, en region 3 - requerido al anular)
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000001600)
,p_name=>'P115_MOTIVO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000000300)
,p_use_cache_before_default=>'NO'
,p_prompt=>unistr('Motivo de anulaci\00F3n')
,p_source_type=>'STATIC'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>400
,p_cHeight=>3
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_help_text=>unistr('Obligatorio cuando se anula el presupuesto.')
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'counter', 'Y',
  'resizable', 'Y',
  'submit_when_enter_pressed', 'N',
  'trim_spaces', 'BOTH')).to_clob
);
-- =====================================================================
-- DYNAMIC ACTIONS - CERRAR cierra el dialogo
-- =====================================================================
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000002000)
,p_name=>'Cerrar Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(36000000000000700)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000002100)
,p_event_id=>wwv_flow_imp.id(36000000000002000)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
-- =====================================================================
-- VALIDACIONES
-- =====================================================================
-- Motivo obligatorio cuando se aprieta el boton ANULAR
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(36000000000002300)
,p_validation_sequence=>10
,p_validation_name=>'Motivo requerido al anular'
,p_validation=>':P115_MOTIVO is not null and length(trim(:P115_MOTIVO)) > 0'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>unistr('Debe ingresar el motivo de anulaci\00F3n.')
,p_when_button_pressed=>wwv_flow_imp.id(36000000000000600)
,p_associated_item=>wwv_flow_imp.id(36000000000001600)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
-- =====================================================================
-- PROCESOS
-- =====================================================================
-- BEFORE_HEADER: Form Init para cargar cabecera read-only desde SQL source
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000002400)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(36000000000000100)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Datos del Presupuesto'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>36000000000002400
);
-- AFTER_SUBMIT: Procesar cambio de estado (solo si REQUEST=APROBAR o ANULAR)
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000002500)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'ProcesarCambioEstado'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'  v_actual  WKSP_WORKPLACE.ORDENES_VENTA.ESTADO%type;',
'  v_target  varchar2(20);',
'begin',
'  v_target := case :REQUEST',
'                when ''APROBAR'' then ''APROBADO''',
'                when ''ANULAR''  then ''ANULADO''',
'              end;',
'  if v_target is null then',
'    return;',
'  end if;',
'  select ESTADO into v_actual',
'    from WKSP_WORKPLACE.ORDENES_VENTA',
'   where ID_ORDEN = :P115_ID_ORDEN',
'     for update;',
'  if WKSP_WORKPLACE.FN_PUEDE_TRANSICION_OV(v_actual, v_target) <> ''S'' then',
'    apex_error.add_error(',
unistr('      p_message => ''Transici\00F3n inv\00E1lida: '' || v_actual || '' -> '' || v_target,'),
'      p_display_location => apex_error.c_inline_in_notification);',
'    return;',
'  end if;',
'  update WKSP_WORKPLACE.ORDENES_VENTA',
'     set ESTADO             = v_target,',
'         FECHA_APROBACION   = case when v_target = ''APROBADO'' then sysdate     else FECHA_APROBACION   end,',
'         USUARIO_APROBACION = case when v_target = ''APROBADO'' then :APP_USER   else USUARIO_APROBACION end,',
'         FECHA_ANULACION    = case when v_target = ''ANULADO''  then sysdate     else FECHA_ANULACION    end,',
'         USUARIO_ANULACION  = case when v_target = ''ANULADO''  then :APP_USER   else USUARIO_ANULACION  end,',
'         MOTIVO_ANULACION   = case when v_target = ''ANULADO''  then :P115_MOTIVO else MOTIVO_ANULACION   end',
'   where ID_ORDEN = :P115_ID_ORDEN;',
'  apex_application.g_print_success_message :=',
unistr('    ''Presupuesto #'' || :P115_ID_ORDEN || '' marcado como '' || v_target || ''.'';'),
'end;'))
,p_process_when=>'APROBAR,ANULAR'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_process_success_message=>'OK'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>36000000000002500
);
-- AFTER_SUBMIT: Cerrar dialogo (con success message) tras transicion exitosa
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000002600)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_process_when=>'APROBAR,ANULAR'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>36000000000002600
);
wwv_flow_imp.component_end;
end;
/

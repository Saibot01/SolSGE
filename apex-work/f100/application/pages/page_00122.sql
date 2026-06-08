prompt --application/pages/page_00122
begin
--   Manifest
--     PAGE: 00122
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
 p_id=>122
,p_name=>'Solicitar Anulacion'
,p_alias=>'SOLICITAR-ANULACION'
,p_page_mode=>'MODAL'
,p_step_title=>'Solicitar Anulacion de Factura'
,p_autocomplete_on_off=>'OFF'
,p_step_template=>1661186590416509825
,p_page_template_options=>'#DEFAULT#'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(122100000000001)
,p_plug_name=>'Solicitud'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_plug_source_type=>'NATIVE_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(122100000000002)
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
 p_id=>wwv_flow_imp.id(122200000000001)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(122100000000002)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_button_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(122200000000002)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(122100000000002)
,p_button_name=>'SOLICITAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Solicitar Anulacion'
,p_button_position=>'NEXT'
,p_show_processing=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(122300000000001)
,p_name=>'P122_ID_COMPROBANTE'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(122100000000001)
,p_prompt=>'Id Comprobante'
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
 p_id=>wwv_flow_imp.id(122300000000002)
,p_name=>'P122_NRO_COMPROBANTE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(122100000000001)
,p_use_cache_before_default=>'NO'
,p_prompt=>'N&deg; Factura'
,p_source=>'SELECT NRO_COMPROBANTE FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'allow_html', 'Y',
  'fetch_when', 'BEFORE_HEADER',
  'show_html', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(122300000000003)
,p_name=>'P122_FECHA'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(122100000000001)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Fecha'
,p_source=>q'[SELECT TO_CHAR(FECHA,'DD/MM/YYYY') FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE]'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'allow_html', 'Y',
  'fetch_when', 'BEFORE_HEADER',
  'show_html', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(122300000000004)
,p_name=>'P122_CLIENTE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(122100000000001)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Cliente'
,p_source=>q'[SELECT TRIM(p.PRIMER_NOMBRE||' '||p.PRIMER_APELLIDO) FROM COMPROBANTES c JOIN PERSONAS p ON p.ID_PERSONA = c.ID_CLIENTE WHERE c.ID_COMPROBANTE = :P122_ID_COMPROBANTE]'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'allow_html', 'Y',
  'fetch_when', 'BEFORE_HEADER',
  'show_html', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(122300000000005)
,p_name=>'P122_TOTAL'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(122100000000001)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Total'
,p_source=>q'[SELECT TO_CHAR(TOTAL_MONEDA_LOCAL,'FM999G999G999G990')||' '||MONEDA FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE]'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'allow_html', 'Y',
  'fetch_when', 'BEFORE_HEADER',
  'show_html', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(122300000000006)
,p_name=>'P122_FORMA_PAGO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(122100000000001)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Forma de Pago'
,p_source=>q'[SELECT CASE FORMA_PAGO WHEN '1' THEN 'Credito' ELSE 'Contado' END FROM COMPROBANTES WHERE ID_COMPROBANTE = :P122_ID_COMPROBANTE]'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'allow_html', 'Y',
  'fetch_when', 'BEFORE_HEADER',
  'show_html', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(122300000000007)
,p_name=>'P122_MOTIVO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(122100000000001)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Motivo de Anulacion'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cHeight=>5
,p_cMaxlength=>500
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_is_required=>true
,p_help_text=>'Minimo 10 caracteres. Explica por que se anula la factura.'
);
wwv_flow_imp_page.create_page_da_event (
 p_id=>wwv_flow_imp.id(122400000000001)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_button_id=>wwv_flow_imp.id(122200000000001)
,p_bind_type=>'bind'
,p_bind_event_type=>'click'
,p_display_when_type=>'NEVER'
);
wwv_flow_imp_page.create_page_da_action (
 p_id=>wwv_flow_imp.id(122400000000002)
,p_event_id=>wwv_flow_imp.id(122400000000001)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_CANCEL_DIALOG'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(122500000000001)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Solicitar Anulacion'
,p_process_sql_clob=>q'[BEGIN
  PRC_SOLICITAR_ANULACION(
    p_id_comprobante => :P122_ID_COMPROBANTE,
    p_motivo         => :P122_MOTIVO,
    p_usuario        => :APP_USER
  );
END;]'
,p_process_when_button_id=>wwv_flow_imp.id(122200000000002)
,p_internal_uid=>122500000000001
,p_process_success_message=>'Solicitud de anulacion registrada. La factura quedo pendiente de aprobacion.'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(122500000000002)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_process_when_button_id=>wwv_flow_imp.id(122200000000002)
,p_internal_uid=>122500000000002
);
wwv_flow_imp.component_end;
end;
/

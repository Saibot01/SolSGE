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
,p_page_template_options=>'#DEFAULT#'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(122100000000001)
,p_plug_name=>'Solicitud'
,p_region_template_options=>'#DEFAULT#'
,p_plug_display_sequence=>10
,p_plug_source=>'<p>Indica el motivo de la anulacion de la factura.</p>'
,p_plug_source_type=>'NATIVE_HTML'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(122100000000002)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_03'
,p_plug_source_type=>'NATIVE_HTML'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(122200000000001)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(122100000000002)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
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
,p_is_persistent=>'N'
,p_protection_level=>'S'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(122300000000007)
,p_name=>'P122_MOTIVO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(122100000000001)
,p_prompt=>'Motivo de Anulacion'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cHeight=>5
,p_cMaxlength=>500
,p_is_persistent=>'N'
,p_is_required=>true
);
wwv_flow_imp_page.create_page_da_event (
 p_id=>wwv_flow_imp.id(122400000000001)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_button_id=>wwv_flow_imp.id(122200000000001)
,p_bind_type=>'bind'
,p_bind_event_type=>'click'
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

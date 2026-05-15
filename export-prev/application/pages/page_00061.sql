prompt --application/pages/page_00061
begin
--   Manifest
--     PAGE: 00061
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
 p_id=>61
,p_name=>'Cierre de Caja'
,p_alias=>'CIERRE-DE-CAJA'
,p_page_mode=>'MODAL'
,p_step_title=>'Cierre de Caja'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'16'
,p_created_on=>wwv_flow_imp.dz('20250619195841Z')
,p_last_updated_on=>wwv_flow_imp.dz('20250620111031Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13181578701363537)
,p_plug_name=>'New'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250619200130Z')
,p_updated_on=>wwv_flow_imp.dz('20250619200146Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13321324650673450)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20250619195841Z')
,p_updated_on=>wwv_flow_imp.dz('20250619195841Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(13181881987363540)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_button_name=>'Cierre'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Cierre'
,p_button_position=>'CREATE'
,p_created_on=>wwv_flow_imp.dz('20250619200237Z')
,p_updated_on=>wwv_flow_imp.dz('20250619200251Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(13181623258363538)
,p_name=>'P61_EMPLEADO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_prompt=>'Empleado'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_named_lov=>'EMPLEADOS.NOMBRE'
,p_lov_display_null=>'YES'
,p_cSize=>30
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
,p_created_on=>wwv_flow_imp.dz('20250619200130Z')
,p_updated_on=>wwv_flow_imp.dz('20250619201730Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(13181720026363539)
,p_name=>'P61_CAFA_CONF'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_prompt=>'Caja'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'        select CF.DESCRIPCION, CA.ID_CAJA from CAJA_CONF CF, CAJAS CA',
'        WHERE CF.ID_CAJA_CONF = CA.ID_CAJA_CONF',
'        AND CA.ESTADO = ''A''',
'        AND CA.ID_EMPLEADO = :P61_EMPLEADO'))
,p_lov_cascade_parent_items=>'P61_EMPLEADO'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250619200130Z')
,p_updated_on=>wwv_flow_imp.dz('20250620111031Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13181927581363541)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cerrar caja'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Begin',
'    cerrar_caja(p_id_caja => :P61_CAFA_CONF,',
'                p_usuario => :P61_EMPLEADO);',
'    COMMIT;',
'END;                '))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(13181881987363540)
,p_process_success_message=>'Caja Cerrada'
,p_internal_uid=>13181927581363541
,p_created_on=>wwv_flow_imp.dz('20250619200516Z')
,p_updated_on=>wwv_flow_imp.dz('20250619200701Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13182019412363542)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Dialog close'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>13182019412363542
,p_created_on=>wwv_flow_imp.dz('20250619200855Z')
,p_updated_on=>wwv_flow_imp.dz('20250619200855Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00102
begin
--   Manifest
--     PAGE: 00102
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
 p_id=>102
,p_name=>unistr('Restablecer Contrase\00F1a')
,p_alias=>'RESET-PASSWORD'
,p_step_title=>unistr('Restablecer Contrase\00F1a')
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_page_is_public_y_n=>'Y'
,p_deep_linking=>'Y'
,p_page_component_map=>'16'
,p_created_on=>wwv_flow_imp.dz('20260328105119Z')
,p_last_updated_on=>wwv_flow_imp.dz('20260330081456Z')
,p_created_by=>'SIS_APEX'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(19214223771556517)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20260328105119Z')
,p_updated_on=>wwv_flow_imp.dz('20260328105119Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(16597997545211747)
,p_button_sequence=>40
,p_button_name=>'BTN_GUARDAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>unistr('Establecer contrase\00F1a')
,p_grid_new_row=>'Y'
,p_created_on=>wwv_flow_imp.dz('20260328111349Z')
,p_updated_on=>wwv_flow_imp.dz('20260328111349Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16597451747211742)
,p_name=>'P102_TOKEN'
,p_item_sequence=>10
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260328110026Z')
,p_updated_on=>wwv_flow_imp.dz('20260328110026Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16597591950211743)
,p_name=>'P102_NUEVA_CONTRASENA'
,p_item_sequence=>20
,p_prompt=>unistr('Nueva contrase\00F1a')
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260328111349Z')
,p_updated_on=>wwv_flow_imp.dz('20260328111349Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16597636847211744)
,p_name=>'P102_CONFIRMAR'
,p_item_sequence=>30
,p_prompt=>unistr('Confirmar contrase\00F1a')
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260328111349Z')
,p_updated_on=>wwv_flow_imp.dz('20260328111349Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16597762312211745)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Validar Token'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_emp EMPLEADOS%ROWTYPE;',
'BEGIN',
'  IF :P102_TOKEN IS NULL THEN',
'    APEX_UTIL.REDIRECT_URL(',
'      APEX_PAGE.GET_URL(p_page => 9999)',
'    );',
'    RETURN;',
'  END IF;',
'',
'  v_emp := PKG_EMPLEADOS.validar_token(:P102_TOKEN);',
'',
'EXCEPTION',
'  WHEN OTHERS THEN',
'    APEX_UTIL.REDIRECT_URL(',
'      APEX_PAGE.GET_URL(p_page => 9999)',
'    );',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>16597762312211745
,p_created_on=>wwv_flow_imp.dz('20260328111349Z')
,p_updated_on=>wwv_flow_imp.dz('20260330081456Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16597839200211746)
,p_process_sequence=>10
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>unistr('Cambiar Contrase\00F1a')
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
unistr('  -- Validar que las contrase\00F1as coincidan'),
'  IF :P102_NUEVA_CONTRASENA IS NULL THEN',
'    APEX_ERROR.ADD_ERROR(',
unistr('      p_message          => ''Debes ingresar una contrase\00F1a.'','),
'      p_display_location => APEX_ERROR.C_INLINE_IN_NOTIFICATION',
'    );',
'    RETURN;',
'  END IF;',
'',
'  IF :P102_NUEVA_CONTRASENA != :P102_CONFIRMAR THEN',
'    APEX_ERROR.ADD_ERROR(',
unistr('      p_message          => ''Las contrase\00F1as no coinciden.'','),
'      p_display_location => APEX_ERROR.C_INLINE_IN_NOTIFICATION',
'    );',
'    RETURN;',
'  END IF;',
'',
unistr('  -- Cambiar contrase\00F1a (invalida el token autom\00E1ticamente)'),
'  PKG_EMPLEADOS.cambiar_contrasena(',
'    p_token            => :P102_TOKEN,',
'    p_nueva_contrasena => :P102_NUEVA_CONTRASENA',
'  );',
'',
unistr('  -- Redirigir al login con mensaje de \00E9xito'),
'  APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE :=',
unistr('    ''Contrase\00F1a establecida correctamente. Ya puedes iniciar sesi\00F3n.'';'),
'',
'  APEX_UTIL.REDIRECT_URL(',
unistr('    APEX_PAGE.GET_URL(p_page => 9999)  -- n\00FAmero de tu p\00E1gina de login'),
'  );',
'',
'EXCEPTION',
'  WHEN OTHERS THEN',
'    APEX_ERROR.ADD_ERROR(',
'      p_message          => SQLERRM,',
'      p_display_location => APEX_ERROR.C_INLINE_IN_NOTIFICATION',
'    );',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>16597839200211746
,p_created_on=>wwv_flow_imp.dz('20260328111349Z')
,p_updated_on=>wwv_flow_imp.dz('20260328111349Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

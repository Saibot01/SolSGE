prompt --application/pages/page_00126
begin
--   Manifest
--     PAGE: 00126
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
 p_id=>126
,p_name=>unistr('Aprobar/Rechazar Nota de Cr\00E9dito')
,p_alias=>unistr('APROBAR-RECHAZAR-NOTA-DE-CR\00C9DITO')
,p_page_mode=>'MODAL'
,p_step_title=>unistr('Aprobar/Rechazar Nota de Cr\00E9dito')
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23156727766069525)
,p_plug_name=>'Detalle de la solicitud'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23157074872069528)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(23156727766069525)
,p_button_name=>'APROBAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Aprobar'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23157155621069529)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(23156727766069525)
,p_button_name=>'RECHAZAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Rechazar'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23156898115069526)
,p_name=>'P126_ID_SOLICITUD'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(23156727766069525)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23156951721069527)
,p_name=>'P126_MOTIVO_RECHAZO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(23156727766069525)
,p_prompt=>'Motivo Rechazo'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>30
,p_cHeight=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23158000000000010)
,p_name=>'P126_FACTURA'
,p_item_sequence=>12
,p_item_plug_id=>wwv_flow_imp.id(23156727766069525)
,p_prompt=>'Factura origen'
,p_source=>'SELECT FACTURA_NRO FROM WKSP_WORKPLACE.V_SOLICITUDES_NC WHERE ID_SOLICITUD_NC = :P126_ID_SOLICITUD'
,p_source_type=>'QUERY'
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
 p_id=>wwv_flow_imp.id(23158000000000011)
,p_name=>'P126_CLIENTE'
,p_item_sequence=>13
,p_item_plug_id=>wwv_flow_imp.id(23156727766069525)
,p_prompt=>'Cliente'
,p_source=>'SELECT CLIENTE_NOMBRE FROM WKSP_WORKPLACE.V_SOLICITUDES_NC WHERE ID_SOLICITUD_NC = :P126_ID_SOLICITUD'
,p_source_type=>'QUERY'
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
 p_id=>wwv_flow_imp.id(23158000000000012)
,p_name=>'P126_MOTIVO'
,p_item_sequence=>14
,p_item_plug_id=>wwv_flow_imp.id(23156727766069525)
,p_prompt=>'Motivo'
,p_source=>'SELECT MOTIVO FROM WKSP_WORKPLACE.V_SOLICITUDES_NC WHERE ID_SOLICITUD_NC = :P126_ID_SOLICITUD'
,p_source_type=>'QUERY'
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
 p_id=>wwv_flow_imp.id(23158000000000013)
,p_name=>'P126_TIPO'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(23156727766069525)
,p_prompt=>'Tipo / Condicion'
,p_source=>unistr('SELECT CASE TIPO_NC WHEN ''T'' THEN ''Total'' WHEN ''P'' THEN ''Parcial'' END||'' \2013 ''||CASE FACTURA_FORMA_PAGO WHEN ''1'' THEN ''Cr\00E9dito'' ELSE ''Contado'' END FROM WKSP_WORKPLACE.V_SOLICITUDES_NC WHERE ID_SOLICITUD_NC = :P126_ID_SOLICITUD')
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(23158000000000020)
,p_validation_name=>unistr('Motivo rechazo \2265 10 chars')
,p_validation_sequence=>10
,p_validation=>wwv_flow_string.join(wwv_flow_t_varchar2(
'RETURN CASE',
'  WHEN :REQUEST=''RECHAZAR'' AND (:P126_MOTIVO_RECHAZO IS NULL OR LENGTH(TRIM(:P126_MOTIVO_RECHAZO)) < 10)',
'    THEN ''El motivo de rechazo debe tener al menos 10 caracteres.''',
'  ELSE NULL',
'END;'))
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_ERR_TEXT'
,p_associated_item=>wwv_flow_imp.id(23156951721069527)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23158000000000030)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Aprobar NC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_APROBAR_NOTA_CREDITO(',
'    p_id_solicitud => :P126_ID_SOLICITUD,',
'    p_usuario      => :APP_USER);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23157074872069528)
,p_process_success_message=>unistr('Nota de Cr\00E9dito emitida correctamente.')
,p_internal_uid=>23158000000000030
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23158000000000031)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Rechazar NC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_RECHAZAR_NOTA_CREDITO(',
'    p_id_solicitud   => :P126_ID_SOLICITUD,',
'    p_motivo_rechazo => :P126_MOTIVO_RECHAZO,',
'    p_usuario        => :APP_USER);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23157155621069529)
,p_process_success_message=>'Solicitud de Nota de Credito rechazada.'
,p_internal_uid=>23158000000000031
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23158000000000032)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>23158000000000032
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23158000000000040)
,p_plug_name=>unistr('Detalle de la Nota de Cr\00E9dito')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v CLOB; v_tot NUMBER := 0;',
'  FUNCTION f(n NUMBER) RETURN VARCHAR2 IS BEGIN',
'    RETURN TRANSLATE(TO_CHAR(NVL(n,0),''FM999G999G999G990''),'','',''.''); END;',
'BEGIN',
'  v := ''<table class="t-Report-report" style="width:100%"><thead><tr>''',
'    ||''<th>Producto</th><th>Cant.</th><th style="text-align:right">Precio facturado</th>''',
'    ||''<th style="text-align:right">Precio nuevo</th><th style="text-align:right">Cr&eacute;dito x u.</th>''',
'    ||''<th style="text-align:right">Subtotal</th></tr></thead><tbody>'';',
'  FOR r IN (',
'    SELECT pr.NOMBRE prod, d.CANTIDAD cant, oc.PRECIO_UNITARIO p_fac,',
'           (oc.PRECIO_UNITARIO - d.PRECIO_UNITARIO) p_nuevo, d.PRECIO_UNITARIO cred,',
'           d.CANTIDAD*d.PRECIO_UNITARIO sub',
'      FROM WKSP_WORKPLACE.SOLICITUD_NC_DETALLE d',
'      JOIN WKSP_WORKPLACE.DETALLE_COMPROBANTE oc ON oc.ID_DETALLE=d.ID_DETALLE_ORIGEN',
'      JOIN WKSP_WORKPLACE.PRODUCTOS pr ON pr.ID_PRODUCTO=d.ID_PRODUCTO',
'     WHERE d.ID_SOLICITUD_NC = :P126_ID_SOLICITUD) LOOP',
'    v := v||''<tr><td>''||r.prod||''</td><td class="u-tR">''||r.cant||''</td>''',
'      ||''<td class="u-tR">''||f(r.p_fac)||''</td><td class="u-tR">''||f(r.p_nuevo)||''</td>''',
'      ||''<td class="u-tR">''||f(r.cred)||''</td><td class="u-tR">''||f(r.sub)||''</td></tr>'';',
'    v_tot := v_tot + r.sub;',
'  END LOOP;',
'  v := v||''</tbody><tfoot><tr><th colspan="5" style="text-align:right">Total NC a acreditar</th>''',
'    ||''<th style="text-align:right">''||f(v_tot)||''</th></tr></tfoot></table>'';',
'  RETURN v;',
'END;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp.component_end;
end;
/

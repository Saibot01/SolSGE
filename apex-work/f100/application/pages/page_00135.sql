prompt --application/pages/page_00135
begin
--   Manifest
--     PAGE: 00135
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
 p_id=>135
,p_name=>'Generador de Informe de Ventas'
,p_alias=>'GENERADOR-INFORME-VENTAS'
,p_step_title=>'Generador de Informe de Ventas'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Informe de Ventas - mismo estilo que el arqueo/KuDE (scope .kude) */',
'.kude { max-width:8.5in; margin:0 auto; background:#fff;',
'   font:12px/1.35 ''Open Sans'',sans-serif; color:#222; padding:0.4in;',
'   border:1px solid #ddd; }',
'.kude .ktit { background:#1b3a5b; color:#fff; text-align:center; font-weight:bold;',
'   letter-spacing:.1em; padding:.55em; border-radius:.25em; text-transform:uppercase;',
'   margin-bottom:1em; }',
'.kude table { width:100%; border-collapse:collapse; }',
'.kude .khead td { vertical-align:top; width:50%; padding:.2em .4em; }',
'.kude .kemis b { font-size:1.15em; }',
'.kude .kbox { border:1px solid #bbb; border-radius:.35em; padding:.5em .7em; margin:1em 0; }',
'.kude .krec td { padding:.2em .5em; vertical-align:top; width:33%; }',
'.kude .klabel { color:#666; font-size:.82em; }',
'.kude table.kitems { margin-top:.3em; }',
'.kude table.kitems th { background:#eee; border:1px solid #ccc; padding:.4em; font-size:.83em; text-align:left; }',
'.kude table.kitems td { border:1px solid #ddd; padding:.35em .45em; }',
'.kude .r { text-align:right; } .kude .c { text-align:center; }',
'.kude .kleg { font-size:.78em; color:#555; text-align:center; margin-top:1.2em;',
'   border-top:1px solid #ccc; padding-top:.7em; line-height:1.4; }',
'.kude table.kbars td { border:none; padding:.22em .4em; vertical-align:middle; }',
'.kude .kb-lbl { width:30%; } .kude .kb-val { width:22%; white-space:nowrap; }',
'.kude .kb-bar { width:48%; }',
'.kude .track { background:#eef0f3; border-radius:3px; height:14px; width:100%;',
'   display:inline-block; vertical-align:middle; }',
'.kude .bar { background:#1b3a5b; height:14px; border-radius:3px; }',
'.kude .bar.ok { background:#2e7d32; } .kude .bar.warn { background:#c62828; }',
'.kude .kb-pct { font-size:.8em; margin-left:.45em; color:#444; }',
'@media print {',
'  * { -webkit-print-color-adjust:exact; print-color-adjust:exact; }',
'  .t-Header, .t-Footer, .t-Body-nav, .a-MenuBar, .t-Button,',
'  .t-Body-title, .t-BreadcrumbRegion, .js-noprint { display:none !important; }',
'  .t-Body, .t-Body-main, .t-Body-content, .t-Body-contentInner { margin:0 !important; padding:0 !important; }',
'  .kude { border:none; max-width:none; }',
'  @page { margin:1cm; }',
'}'))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000135020)
,p_plug_name=>'Informe'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_plug_display_point=>'BODY'
,p_ajax_items_to_submit=>'P135_DESDE,P135_HASTA,P135_VENDEDOR,P135_OFICINA,P135_CONDICION'
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN WKSP_WORKPLACE.FN_INFORME_VENTAS_HTML(',
'    TO_DATE(:P135_DESDE,''YYYY-MM-DD''),',
'    TO_DATE(:P135_HASTA,''YYYY-MM-DD''),',
'    :P135_VENDEDOR, :P135_OFICINA, :P135_CONDICION);',
'END;'))
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
--==================== Region Filtros (contenedor plano, se oculta al imprimir) ====
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000135010)
,p_plug_name=>'Filtros del informe'
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'BODY'
,p_region_css_classes=>'js-noprint'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000135011)
,p_name=>'P135_DESDE'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000135010)
,p_item_default=>'TO_CHAR(TRUNC(WKSP_WORKPLACE.FN_HOY,''MM''),''YYYY-MM-DD'')'
,p_item_default_type=>'PLSQL_EXPRESSION'
,p_prompt=>'Desde'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_format_mask=>'YYYY-MM-DD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as','POPUP','max_date','NONE','min_date','NONE',
  'multiple_months','N','show_on','FOCUS','show_time','N','use_defaults','Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000135012)
,p_name=>'P135_HASTA'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(36000000000135010)
,p_item_default=>'TO_CHAR(WKSP_WORKPLACE.FN_HOY,''YYYY-MM-DD'')'
,p_item_default_type=>'PLSQL_EXPRESSION'
,p_prompt=>'Hasta'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_format_mask=>'YYYY-MM-DD'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as','POPUP','max_date','NONE','min_date','NONE',
  'multiple_months','N','show_on','FOCUS','show_time','N','use_defaults','Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000135013)
,p_name=>'P135_VENDEDOR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(36000000000135010)
,p_prompt=>'Vendedor'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DISTINCT vendedor_nombre d, vendedor_cod r',
'  FROM WKSP_WORKPLACE.V_VENTAS_FACTURA ORDER BY 1'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Todos'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000135014)
,p_name=>'P135_OFICINA'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(36000000000135010)
,p_prompt=>'Sucursal'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT descripcion d, codigo_oficina r',
'  FROM WKSP_WORKPLACE.OFICINAS ORDER BY descripcion'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Todas'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000135015)
,p_name=>'P135_CONDICION'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(36000000000135010)
,p_prompt=>unistr('Condici\00F3n')
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC2:Contado;CONTADO,Credito;CREDITO'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'Todas'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000135016)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000135010)
,p_button_name=>'GENERAR'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Generar informe'
,p_button_position=>'BELOW_BOX'
,p_icon_css_classes=>'fa-refresh'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000135017)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(36000000000135010)
,p_button_name=>'IMPRIMIR'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Imprimir'
,p_button_position=>'BELOW_BOX'
,p_icon_css_classes=>'fa-print'
);
--==================== DA: Generar -> refresca el informe ====================
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000135030)
,p_name=>'Generar informe'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(36000000000135016)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000135031)
,p_event_id=>wwv_flow_imp.id(36000000000135030)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000135020)
);
--==================== DA: Imprimir -> window.print() ====================
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000135032)
,p_name=>'Imprimir'
,p_event_sequence=>20
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(36000000000135017)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000135033)
,p_event_id=>wwv_flow_imp.id(36000000000135032)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'window.print();'
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00096
begin
--   Manifest
--     PAGE: 00096
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
 p_id=>96
,p_name=>'Documento Factura'
,p_alias=>'DOCUMENTO-FACTURA'
,p_page_mode=>'MODAL'
,p_step_title=>'Documento Factura'
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* ===== KuDE - Representacion Grafica de Factura Electronica ===== */',
'html { background:#999; }',
'body { box-sizing:border-box; margin:0 auto; width:8.5in; background:#FFF;',
'       font:12px/1.35 ''Open Sans'', sans-serif; color:#222; }',
'.kude { padding:0.4in; }',
'.ktit { background:#1b3a5b; color:#fff; text-align:center; font-weight:bold;',
'        letter-spacing:.12em; padding:.55em; border-radius:.25em;',
'        text-transform:uppercase; margin-bottom:1em; }',
'table { width:100%; border-collapse:collapse; }',
'.khead td { vertical-align:top; width:50%; padding:.2em .4em; }',
'.kemis b { font-size:1.15em; }',
'.kbox { border:1px solid #bbb; border-radius:.35em; padding:.5em .7em; margin:1em 0; }',
'.krec td { padding:.2em .5em; vertical-align:top; width:33%; }',
'.klabel { color:#666; font-size:.82em; }',
'table.kitems { margin-top:.3em; }',
'table.kitems th { background:#eee; border:1px solid #ccc; padding:.4em; font-size:.83em; }',
'table.kitems td { border:1px solid #ddd; padding:.35em .45em; }',
'table.kitems tr.ksub td { background:#f6f6f6; border-top:2px solid #bbb; }',
'.r { text-align:right; } .c { text-align:center; }',
'.ktot { margin-top:.6em; }',
'.ktot td { padding:.35em .45em; border-top:1px solid #ccc; }',
'.kleg { font-size:.78em; color:#555; text-align:center; margin-top:1.2em;',
'        border-top:1px solid #ccc; padding-top:.7em; line-height:1.4; }',
'@media print {',
'  * { -webkit-print-color-adjust:exact; print-color-adjust:exact; }',
'  html { background:none; }',
'  body { box-shadow:none; margin:0; width:auto; }',
'  @page { margin:1cm; }',
'}'))
,p_page_template_options=>'#DEFAULT#:ui-dialog--stretch'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15983253910097108)
,p_plug_name=>'KuDE Factura'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RETURN WKSP_WORKPLACE.FN_KUDE_FACTURA_HTML(:P96_ID_COMPROBANTE);',
'END;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15983368763097109)
,p_name=>'P96_ID_COMPROBANTE'
,p_item_sequence=>20
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp.component_end;
end;
/

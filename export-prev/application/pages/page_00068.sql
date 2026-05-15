prompt --application/pages/page_00068
begin
--   Manifest
--     PAGE: 00068
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
 p_id=>68
,p_name=>'Compras'
,p_alias=>'COMPRAS'
,p_step_title=>'Compras'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'11'
,p_created_on=>wwv_flow_imp.dz('20250529123436Z')
,p_last_updated_on=>wwv_flow_imp.dz('20250529123436Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12816319590378893)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20250529123436Z')
,p_updated_on=>wwv_flow_imp.dz('20250529123436Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

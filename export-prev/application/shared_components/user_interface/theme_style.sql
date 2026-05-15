prompt --application/shared_components/user_interface/theme_style
begin
--   Manifest
--     THEME STYLE: 100
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_shared.create_theme_style(
 p_id=>wwv_flow_imp.id(16644324310074055)
,p_theme_id=>42
,p_name=>'Vita - Dark (RED)'
,p_is_public=>true
,p_is_accessible=>false
,p_theme_roller_input_file_urls=>'#THEME_FILES#less/theme/Vita-Dark.less'
,p_theme_roller_config=>'{"classes":[],"vars":{"@g_Accent-BG":"#811b1b","@g_Link-Base":"#ea8a8a","@g_Focus":"#c32c2c","@g_Nav-BG":"#2b2a2a","@g_Nav-FG":"#e7e7e7","@l_Button-Primary-BG":"#841818","@l_Button-Primary-Text":"#ffffff"},"customCSS":"","useCustomLess":"N"}'
,p_theme_roller_output_file_url=>'#THEME_DB_FILES#16644324310074055.css'
,p_theme_roller_read_only=>false
,p_created_on=>wwv_flow_imp.dz('20251127210643Z')
,p_updated_on=>wwv_flow_imp.dz('20251128222439Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

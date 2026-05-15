prompt --application/shared_components/plugins/template_component/multi_purpose_card
begin
--   Manifest
--     PLUGIN: MULTI_PURPOSE_CARD
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(23080471214631822055)
,p_plugin_type=>'TEMPLATE COMPONENT'
,p_theme_id=>nvl(wwv_flow_application_install.get_theme_id, '')
,p_name=>'MULTI_PURPOSE_CARD'
,p_display_name=>'MULTI PURPOSE CARD'
,p_supported_component_types=>'PARTIAL:REPORT'
,p_image_prefix => nvl(wwv_flow_application_install.get_static_plugin_file_prefix('TEMPLATE COMPONENT','MULTI_PURPOSE_CARD'),'')
,p_partial_template=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<!DOCTYPE html>',
'<html>',
'<head>',
'<style>',
'.grid-container {',
'  display: grid;',
'  grid-template-columns: repeat(auto-fill, minmax(235px, 1fr));',
'  grid-gap: 10px;',
'  padding: 3px;',
'}',
'',
'@media (max-width: 600px) {',
'      /* For screens 600px and below */',
'      .grid-container {',
'        grid-template-columns: repeat(2, 1fr);',
'      }',
'    }',
'',
'.grid-item {',
'  position: relative;',
'  display: flex;',
'  flex-direction: column;',
'  align-items: center;',
'  ',
'  color: black;',
'  border:solid 1px #BORDER_COLOR#;',
'  box-shadow: rgba(50, 50, 93, 0.25) 0px 6px 12px -2px, rgba(0, 0, 0, 0.3) 0px 3px 7px -3px;',
'  padding: 10px;',
'  text-align: center;',
'  border-radius: #RADIUS#%;',
'  transition: transform 0.4s ease-in-out;',
'}',
'',
'.grid-item:hover {',
'  transform: translateY(-5px); ',
'  transform: rotate3d(5, 5, 2, -360deg);',
'  box-shadow: rgba(50, 100, 40, 0.3) 30px 50px 25px -40px, rgba(50, 100, 40, 0.1) 0px 25px 30px 0px;',
'}',
'',
'',
'.grid-item i {',
'  font-size: 25px;',
'  margin-bottom: 8px;',
'}',
'',
'.grid-item p {',
'  margin: 0;',
'}',
'</style>',
'</head>',
'<body>',
'',
'  <a href="#LINK#">',
'    <div class="grid-item" style="background-color: #BG_COLOR#;">',
'      <img src="#IMG#" width="#IMG_WIDTH#" height="#IMG_HEIGHT#">',
'      <b>#TITLE#</b>',
'      <p>#SUB_TITLE#</p>',
'    </div>',
'  </a>    ',
'',
'</body>',
'</html>',
''))
,p_default_escape_mode=>'HTML'
,p_translate_this_template=>false
,p_api_version=>2
,p_report_body_template=>'<div class="grid-container"> #APEX$ROWS#</div>'
,p_report_row_template=>'<span #APEX$ROW_IDENTIFICATION#>#APEX$PARTIAL#</span>'
,p_report_placeholder_count=>3
,p_standard_attributes=>'REGION_TEMPLATE'
,p_substitute_attributes=>true
,p_version_scn=>39017542601723
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23080471565525822069)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_static_id=>'BG_COLOR'
,p_prompt=>'Bg Color'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>false
,p_escape_mode=>'HTML'
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23080471938233822069)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_static_id=>'BORDER_COLOR'
,p_prompt=>'Border Color'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>false
,p_escape_mode=>'HTML'
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23080472325386822070)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_static_id=>'IMG'
,p_prompt=>'Img'
,p_attribute_type=>'MEDIA'
,p_is_required=>false
,p_escape_mode=>'ATTR'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23080472702256822070)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_static_id=>'RADIUS'
,p_prompt=>'Radius'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'10'
,p_escape_mode=>'HTML'
,p_max_length=>2
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23079893384305138315)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_static_id=>'SUB_TITLE'
,p_prompt=>'Sub Title'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>false
,p_escape_mode=>'HTML'
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23079893787528138315)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_static_id=>'TITLE'
,p_prompt=>'Title'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>false
,p_escape_mode=>'HTML'
,p_column_data_types=>'VARCHAR2'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23080710765832189729)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_static_id=>'LINK'
,p_prompt=>'Link'
,p_attribute_type=>'LINK'
,p_is_required=>false
,p_escape_mode=>'ATTR'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23085792386862966734)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_static_id=>'IMG_HEIGHT'
,p_prompt=>'Img Height'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>true
,p_escape_mode=>'HTML'
,p_column_data_types=>'NUMBER'
,p_is_translatable=>false
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23085792829285966734)
,p_plugin_id=>wwv_flow_imp.id(23080471214631822055)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>9
,p_display_sequence=>90
,p_static_id=>'IMG_WIDTH'
,p_prompt=>'Img Width'
,p_attribute_type=>'SESSION STATE VALUE'
,p_is_required=>true
,p_escape_mode=>'HTML'
,p_column_data_types=>'NUMBER'
,p_is_translatable=>false
);
end;
/
begin
wwv_flow_imp.component_end;
end;
/

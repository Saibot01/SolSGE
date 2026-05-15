prompt --application/pages/page_00001
begin
--   Manifest
--     PAGE: 00001
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
 p_id=>1
,p_name=>'Home'
,p_alias=>'HOME'
,p_step_title=>'Home'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>wwv_flow_imp.id(14144931354359505)
,p_protection_level=>'C'
,p_page_component_map=>'13'
,p_created_on=>wwv_flow_imp.dz('20250521110829Z')
,p_last_updated_on=>wwv_flow_imp.dz('20250908063126Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13178111253363503)
,p_plug_name=>'kebe'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>3371237801798025892
,p_plug_display_sequence=>10
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'    ''Compras''     AS TITLE,',
'    ''#APP_FILES#ventas.png''      AS ICON,',
'    ''blue''            AS HEADER_COLOR,',
'    ''90$''             AS VALUE,',
'    ''+20%''            AS PERCENT,',
'    ''green''           AS PERCENT_COLOR,',
'    ''Que la semana pasada''  AS FOOTER',
'FROM',
'    DUAL',
'UNION',
'SELECT',
'    ''Totales''     AS TITLE,',
'    ''#APP_FILES#beneficio-financiero (1).png''      AS ICON,',
'    ''pink''            AS HEADER_COLOR,',
'    ''2,300''           AS VALUE,',
'    ''-5%''             AS PERCENT,',
'    ''red''             AS PERCENT_COLOR,',
'    ''Que el mes pasado'' AS FOOTER',
'FROM',
'    DUAL',
'UNION',
'SELECT',
'    ''Clientes''     AS TITLE,',
'    ''#APP_FILES#cliente.png''      AS ICON,',
'    ''green''           AS HEADER_COLOR,',
'    ''5,200''           AS VALUE,',
'    ''+20%''            AS PERCENT,',
'    ''green''           AS PERCENT_COLOR,',
'    ''Que ayer''  AS FOOTER',
'FROM',
'    DUAL',
'UNION',
'SELECT',
'    ''Ventas''           AS TITLE,',
'    ''#APP_FILES#tienda-online.png''      AS ICON,',
'    ''orange''          AS HEADER_COLOR,',
'    ''$123,000''        AS VALUE,',
'    ''+8%''             AS PERCENT,',
'    ''green''           AS PERCENT_COLOR,',
'    ''Que la semana pasada''  AS FOOTER',
'FROM',
'    DUAL'))
,p_template_component_type=>'REPORT'
,p_lazy_loading=>false
,p_plug_source_type=>'TMPL_KEBE_DASHBOARD'
,p_plug_query_num_rows=>15
,p_plug_query_num_rows_type=>'SET'
,p_show_total_row_count=>false
,p_landmark_type=>'region'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'FOOTER', 'FOOTER',
  'IMAGE_COLOR', 'HEADER_COLOR',
  'IMAGE_URL', 'ICON',
  'PERCENT', 'PERCENT',
  'PERCENT_COLOR', 'PERCENT_COLOR',
  'TITLE', 'TITLE',
  'VALUE', 'VALUE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250602163237Z')
,p_updated_on=>wwv_flow_imp.dz('20250602164737Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13178213993363504)
,p_name=>'TITLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TITLE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>10
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250602163237Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13178304322363505)
,p_name=>'ICON'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ICON'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>20
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250602163237Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13178415214363506)
,p_name=>'HEADER_COLOR'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'HEADER_COLOR'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>30
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250602163237Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13178562469363507)
,p_name=>'VALUE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'VALUE'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>40
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250602163237Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13178656634363508)
,p_name=>'PERCENT'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PERCENT'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>50
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250602163237Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13178769455363509)
,p_name=>'PERCENT_COLOR'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PERCENT_COLOR'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>60
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250602163237Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13178826427363510)
,p_name=>'FOOTER'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'FOOTER'
,p_data_type=>'VARCHAR2'
,p_display_sequence=>70
,p_is_group=>false
,p_use_as_row_header=>false
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250602163237Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

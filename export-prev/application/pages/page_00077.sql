prompt --application/pages/page_00077
begin
--   Manifest
--     PAGE: 00077
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
 p_id=>77
,p_name=>'Recursos'
,p_alias=>'RECURSOS'
,p_step_title=>'Recursos'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'21'
,p_created_on=>wwv_flow_imp.dz('20250912205327Z')
,p_last_updated_on=>wwv_flow_imp.dz('20250912234427Z')
,p_created_by=>'SIS_APEX'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14296560241158718)
,p_plug_name=>'Recursos'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'TABLE'
,p_query_table=>'RECURSOS'
,p_include_rowid_column=>false
,p_plug_source_type=>'NATIVE_IG'
,p_prn_page_header=>'Recursos'
,p_created_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_on=>wwv_flow_imp.dz('20250912234427Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14297884447158719)
,p_name=>'APEX$LINK'
,p_source_type=>'NONE'
,p_item_type=>'NATIVE_LINK'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>10
,p_value_alignment=>'CENTER'
,p_link_target=>'f?p=&APP_ID.:78:&APP_SESSION.::&DEBUG.:RP,78:P78_ID_RECURSO:\&ID_RECURSO.\'
,p_link_text=>'<span role="img" aria-label="Edit" class="fa fa-edit" title="Edit"></span>'
,p_enable_hide=>true
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14298836469158720)
,p_name=>'ID_RECURSO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_RECURSO'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>20
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_enable_filter=>false
,p_enable_hide=>true
,p_is_primary_key=>true
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14299851020158721)
,p_name=>'APP_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'APP_ID'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'App ID'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>30
,p_value_alignment=>'RIGHT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_is_required=>true
,p_enable_filter=>true
,p_filter_is_required=>false
,p_filter_lov_type=>'NONE'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250912234427Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14300856815158721)
,p_name=>'PAGE_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PAGE_ID'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_POPUP_LOV'
,p_heading=>'Pagina'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>40
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
,p_is_required=>true
,p_lov_type=>'SHARED'
,p_lov_id=>wwv_flow_imp.id(14307748367169201)
,p_lov_display_extra=>true
,p_lov_display_null=>true
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'LOV'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250912234427Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14301800539158722)
,p_name=>'COMPONENT_STATIC_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'COMPONENT_STATIC_ID'
,p_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_POPUP_LOV'
,p_heading=>'Componente'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>50
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
,p_is_required=>false
,p_max_length=>200
,p_lov_type=>'SQL_QUERY'
,p_lov_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT label d, comp_key r',
'FROM (',
unistr('  SELECT ''[''||region_name||''] Regi\00F3n'' AS label, ''REG:''||region_name AS comp_key'),
'  FROM apex_application_page_regions',
'  WHERE application_id = :APP_ID',
'      AND page_id        = :PAGE_ID',
'    AND region_name    IS NOT NULL',
'  UNION ALL',
unistr('  SELECT ''[''||button_name||''] Bot\00F3n'', ''BTN:''||button_name'),
'  FROM apex_application_page_buttons',
'  WHERE application_id = :APP_ID',
'      AND page_id        = :PAGE_ID',
'    AND button_name    IS NOT NULL',
'  UNION ALL',
unistr('  SELECT ''[''||item_name||''] \00CDtem'', ''ITEM:''||item_name'),
'  FROM apex_application_page_items',
'  WHERE application_id = :APP_ID',
'      AND page_id        = :PAGE_ID',
'    AND item_name      IS NOT NULL',
')',
'ORDER BY 1',
''))
,p_lov_display_extra=>true
,p_lov_display_null=>true
,p_lov_cascade_parent_items=>'PAGE_ID'
,p_ajax_optimize_refresh=>true
,p_filter_is_required=>false
,p_use_as_row_header=>false
,p_enable_hide=>true
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250912234427Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14302882789158722)
,p_name=>'ID_PRIV_REQUERIDO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRIV_REQUERIDO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_SELECT_LIST'
,p_heading=>'Privilegio Requerido'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>60
,p_value_alignment=>'LEFT'
,p_is_required=>true
,p_lov_type=>'SHARED'
,p_lov_id=>wwv_flow_imp.id(14274155546125607)
,p_lov_display_extra=>true
,p_lov_display_null=>true
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_lov_type=>'NONE'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250912234427Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14303853360158722)
,p_name=>'ACTIVO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ACTIVO'
,p_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_SELECT_LIST'
,p_heading=>'Activo'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>70
,p_value_alignment=>'LEFT'
,p_is_required=>false
,p_lov_type=>'STATIC'
,p_lov_source=>'STATIC:Activo;S,Inactivo;N'
,p_lov_display_extra=>true
,p_lov_display_null=>true
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'LOV'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250912222934Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(14297029421158718)
,p_internal_uid=>14297029421158718
,p_is_editable=>false
,p_lazy_loading=>false
,p_requires_filter=>false
,p_select_first_row=>true
,p_fixed_row_height=>true
,p_pagination_type=>'SCROLL'
,p_show_total_row_count=>true
,p_show_toolbar=>true
,p_enable_save_public_report=>false
,p_enable_subscriptions=>true
,p_enable_flashback=>true
,p_define_chart_view=>true
,p_enable_download=>true
,p_enable_mail_download=>true
,p_fixed_header=>'PAGE'
,p_show_icon_view=>false
,p_show_detail_view=>false
,p_updated_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(14297473827158719)
,p_interactive_grid_id=>wwv_flow_imp.id(14297029421158718)
,p_static_id=>'142975'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(14297694408158719)
,p_report_id=>wwv_flow_imp.id(14297473827158719)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14298206688158720)
,p_view_id=>wwv_flow_imp.id(14297694408158719)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(14297884447158719)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14299277100158720)
,p_view_id=>wwv_flow_imp.id(14297694408158719)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(14298836469158720)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14300226974158721)
,p_view_id=>wwv_flow_imp.id(14297694408158719)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(14299851020158721)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14301253382158721)
,p_view_id=>wwv_flow_imp.id(14297694408158719)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(14300856815158721)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14302247032158722)
,p_view_id=>wwv_flow_imp.id(14297694408158719)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(14301800539158722)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14303232226158722)
,p_view_id=>wwv_flow_imp.id(14297694408158719)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(14302882789158722)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14304212958158723)
,p_view_id=>wwv_flow_imp.id(14297694408158719)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(14303853360158722)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14306891466158725)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_on=>wwv_flow_imp.dz('20250912205327Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14305249422158724)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14296560241158718)
,p_button_name=>'CREATE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'EDIT'
,p_button_redirect_url=>'f?p=&APP_ID.:78:&APP_SESSION.::&DEBUG.:78::'
,p_created_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_on=>wwv_flow_imp.dz('20250912223007Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14305592029158724)
,p_name=>'Edit Report - Dialog Closed'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(14296560241158718)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
,p_created_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_on=>wwv_flow_imp.dz('20250912205327Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14306027490158725)
,p_event_id=>wwv_flow_imp.id(14305592029158724)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14296560241158718)
,p_created_on=>wwv_flow_imp.dz('20250912205327Z')
,p_updated_on=>wwv_flow_imp.dz('20250912205327Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

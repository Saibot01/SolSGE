prompt --application/pages/page_00099
begin
--   Manifest
--     PAGE: 00099
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
 p_id=>99
,p_name=>'Detalle de Cuotas'
,p_alias=>'DETALLE-DE-CUOTAS'
,p_step_title=>'Detalle de Cuotas'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'21'
,p_created_on=>wwv_flow_imp.dz('20251105112000Z')
,p_last_updated_on=>wwv_flow_imp.dz('20251107054440Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(16181542576278069)
,p_plug_name=>'Detalle de Cuotas'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ID_DETALLE,',
'       ID_CXC,',
'       NRO_CUOTA,',
'       FECHA_VENCIMIENTO,',
'       MONTO_CUOTA,',
'       ESTADO',
'  from CUENTAS_COBRAR_DET',
'  where id_cxc = :P99_ID_CXC'))
,p_plug_source_type=>'NATIVE_IG'
,p_ajax_items_to_submit=>'P99_ID_CXC'
,p_prn_page_header=>'Detalle de Cuotas'
,p_created_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_on=>wwv_flow_imp.dz('20251107054440Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16182843047278070)
,p_name=>'APEX$LINK'
,p_source_type=>'NONE'
,p_item_type=>'NATIVE_LINK'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>10
,p_value_alignment=>'CENTER'
,p_link_target=>'f?p=&APP_ID.:100:&APP_SESSION.::&DEBUG.:RP,100:P100_ID_DETALLE:\&ID_DETALLE.\'
,p_link_text=>'<span role="img" aria-label="Cobro" class="fa fa-money" title="Cobrar"></span>'
,p_use_as_row_header=>false
,p_enable_hide=>true
,p_escape_on_http_output=>true
,p_updated_on=>wwv_flow_imp.dz('20251105112514Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16183880397278071)
,p_name=>'ID_DETALLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_DETALLE'
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
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16184857843278071)
,p_name=>'ID_CXC'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_CXC'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_filter_is_required=>false
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20251107054440Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16185853308278072)
,p_name=>'NRO_CUOTA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'NRO_CUOTA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Nro Cuota'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>40
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
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16186816978278072)
,p_name=>'FECHA_VENCIMIENTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'FECHA_VENCIMIENTO'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DATE_PICKER_APEX'
,p_heading=>'Fecha Vencimiento'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>50
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'appearance_and_behavior', 'MONTH-PICKER:YEAR-PICKER:TODAY-BUTTON',
  'days_outside_month', 'VISIBLE',
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_on', 'FOCUS',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
,p_is_required=>true
,p_enable_filter=>true
,p_filter_is_required=>false
,p_filter_date_ranges=>'ALL'
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16187856764278072)
,p_name=>'MONTO_CUOTA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'MONTO_CUOTA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Monto Cuota'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>60
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
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16188804669278073)
,p_name=>'ESTADO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ESTADO'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Estado'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>70
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>20
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'DISTINCT'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(16182010218278069)
,p_internal_uid=>16182010218278069
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
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(16182440800278070)
,p_interactive_grid_id=>wwv_flow_imp.id(16182010218278069)
,p_static_id=>'161825'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(16182673596278070)
,p_report_id=>wwv_flow_imp.id(16182440800278070)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16183282939278070)
,p_view_id=>wwv_flow_imp.id(16182673596278070)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(16182843047278070)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16184272246278071)
,p_view_id=>wwv_flow_imp.id(16182673596278070)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(16183880397278071)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16185224377278071)
,p_view_id=>wwv_flow_imp.id(16182673596278070)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(16184857843278071)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16186287069278072)
,p_view_id=>wwv_flow_imp.id(16182673596278070)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(16185853308278072)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16187201509278072)
,p_view_id=>wwv_flow_imp.id(16182673596278070)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(16186816978278072)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16188277910278072)
,p_view_id=>wwv_flow_imp.id(16182673596278070)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(16187856764278072)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16189265156278073)
,p_view_id=>wwv_flow_imp.id(16182673596278070)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(16188804669278073)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(16190255441278073)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(16181542576278069)
,p_button_name=>'CREATE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Create'
,p_button_position=>'EDIT'
,p_button_redirect_url=>'f?p=&APP_ID.:100:&APP_SESSION.::&DEBUG.:100::'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_on=>wwv_flow_imp.dz('20251105112514Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15983639256097112)
,p_name=>'P99_ID_CXC'
,p_item_sequence=>10
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251105112107Z')
,p_updated_on=>wwv_flow_imp.dz('20251105112107Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(16190576270278073)
,p_name=>'Edit Report - Dialog Closed'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(16181542576278069)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
,p_created_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(16191008537278074)
,p_event_id=>wwv_flow_imp.id(16190576270278073)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(16181542576278069)
,p_created_on=>wwv_flow_imp.dz('20251105112000Z')
,p_updated_on=>wwv_flow_imp.dz('20251105112000Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

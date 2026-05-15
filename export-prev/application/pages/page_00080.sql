prompt --application/pages/page_00080
begin
--   Manifest
--     PAGE: 00080
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
 p_id=>80
,p_name=>'Revision'
,p_alias=>'REVISION1'
,p_step_title=>'Revision'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'21'
,p_created_on=>wwv_flow_imp.dz('20251010142933Z')
,p_last_updated_on=>wwv_flow_imp.dz('20251010172251Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15360677152775388)
,p_plug_name=>'Revision'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ID_INVENTARIO,',
'       NRO_DOCUMENTO,',
'       ID_OFICINA,',
'       FECHA_INVENTARIO,',
'       ESTADO,',
'       OBSERVACION,',
'       USUARIO_CREADOR,',
'       FECHA_CREACION,',
'       USUARIO_ENVIO,',
'       FECHA_ENVIO,',
'       USUARIO_APROBACION,',
'       FECHA_APROBACION,',
'       USUARIO_POSTEO,',
'       FECHA_POSTEO,',
'       USUARIO_RECHAZO,',
'       FECHA_RECHAZO',
'  from INVENTARIO',
'  WHERE ESTADO = ''ENVIADO'''))
,p_plug_source_type=>'NATIVE_IG'
,p_prn_page_header=>'Revision'
,p_created_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_on=>wwv_flow_imp.dz('20251010172251Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15361942899775389)
,p_name=>'APEX$LINK'
,p_source_type=>'NONE'
,p_item_type=>'NATIVE_LINK'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>10
,p_value_alignment=>'CENTER'
,p_link_target=>'f?p=&APP_ID.:85:&APP_SESSION.::&DEBUG.:RP,85:P85_ID_INVENTARIO:\&ID_INVENTARIO.\'
,p_link_text=>'<span role="img" aria-label="Revision" class="fa fa-edit" title="Revision"></span>'
,p_use_as_row_header=>false
,p_enable_hide=>true
,p_escape_on_http_output=>true
,p_updated_on=>wwv_flow_imp.dz('20251010171256Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15362987595775390)
,p_name=>'ID_INVENTARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_INVENTARIO'
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15363954815775390)
,p_name=>'NRO_DOCUMENTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'NRO_DOCUMENTO'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Nro Documento'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>30
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>true
,p_max_length=>30
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15364940450775390)
,p_name=>'ID_OFICINA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_OFICINA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_SELECT_LIST'
,p_heading=>'Id Oficina'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>40
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'execute_validations', 'Y',
  'page_action_on_selection', 'NONE')).to_clob
,p_is_required=>true
,p_lov_type=>'SHARED'
,p_lov_id=>wwv_flow_imp.id(8245359747955872)
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15365998080775391)
,p_name=>'FECHA_INVENTARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'FECHA_INVENTARIO'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DATE_PICKER_APEX'
,p_heading=>'Fecha Inventario'
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15366949753775391)
,p_name=>'ESTADO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ESTADO'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Estado'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>60
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>true
,p_max_length=>15
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15367999794775392)
,p_name=>'OBSERVACION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'OBSERVACION'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXTAREA'
,p_heading=>'Observacion'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>70
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>4000
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'NONE'
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_enable_control_break=>false
,p_enable_hide=>true
,p_enable_pivot=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15368983326775392)
,p_name=>'USUARIO_CREADOR'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'USUARIO_CREADOR'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Usuario Creador'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>80
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>100
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15369969098775392)
,p_name=>'FECHA_CREACION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'FECHA_CREACION'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DATE_PICKER_APEX'
,p_heading=>'Fecha Creacion'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>90
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15370930589775393)
,p_name=>'USUARIO_ENVIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'USUARIO_ENVIO'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Usuario Envio'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>100
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>100
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15371989959775393)
,p_name=>'FECHA_ENVIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'FECHA_ENVIO'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DATE_PICKER_APEX'
,p_heading=>'Fecha Envio'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>110
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
,p_is_required=>false
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15372910919775393)
,p_name=>'USUARIO_APROBACION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'USUARIO_APROBACION'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Usuario Aprobacion'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>120
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>100
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15373953291775394)
,p_name=>'FECHA_APROBACION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'FECHA_APROBACION'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DATE_PICKER_APEX'
,p_heading=>'Fecha Aprobacion'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>130
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
,p_is_required=>false
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15374929888775394)
,p_name=>'USUARIO_POSTEO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'USUARIO_POSTEO'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Usuario Posteo'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>140
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>100
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15375929121775395)
,p_name=>'FECHA_POSTEO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'FECHA_POSTEO'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DATE_PICKER_APEX'
,p_heading=>'Fecha Posteo'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>150
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
,p_is_required=>false
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15376975470775395)
,p_name=>'USUARIO_RECHAZO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'USUARIO_RECHAZO'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Usuario Rechazo'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>160
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>100
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(15377967030775395)
,p_name=>'FECHA_RECHAZO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'FECHA_RECHAZO'
,p_data_type=>'DATE'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DATE_PICKER_APEX'
,p_heading=>'Fecha Rechazo'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>170
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
,p_is_required=>false
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(15361191563775388)
,p_internal_uid=>15361191563775388
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
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(15361582564775389)
,p_interactive_grid_id=>wwv_flow_imp.id(15361191563775388)
,p_static_id=>'153616'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(15361753849775389)
,p_report_id=>wwv_flow_imp.id(15361582564775389)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15362357772775389)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(15361942899775389)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15363305365775390)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(15362987595775390)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15364387286775390)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(15363954815775390)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15365372648775391)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(15364940450775390)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15366376186775391)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(15365998080775391)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15367304274775391)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(15366949753775391)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15368353496775392)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(15367999794775392)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15369377873775392)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>8
,p_column_id=>wwv_flow_imp.id(15368983326775392)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15370318121775392)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>9
,p_column_id=>wwv_flow_imp.id(15369969098775392)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15371339281775393)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>10
,p_column_id=>wwv_flow_imp.id(15370930589775393)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15372361766775393)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>11
,p_column_id=>wwv_flow_imp.id(15371989959775393)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15373390369775393)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>12
,p_column_id=>wwv_flow_imp.id(15372910919775393)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15374310564775394)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>13
,p_column_id=>wwv_flow_imp.id(15373953291775394)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15375389129775394)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>14
,p_column_id=>wwv_flow_imp.id(15374929888775394)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15376371450775395)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>15
,p_column_id=>wwv_flow_imp.id(15375929121775395)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15377375988775395)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>16
,p_column_id=>wwv_flow_imp.id(15376975470775395)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15378364372775395)
,p_view_id=>wwv_flow_imp.id(15361753849775389)
,p_display_seq=>17
,p_column_id=>wwv_flow_imp.id(15377967030775395)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(15380943880775396)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(15379380880775396)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(15360677152775388)
,p_button_name=>'CREATE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Create'
,p_button_position=>'EDIT'
,p_button_redirect_url=>'f?p=&APP_ID.:85:&APP_SESSION.::&DEBUG.:85::'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_on=>wwv_flow_imp.dz('20251010171312Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15379638321775396)
,p_name=>'Edit Report - Dialog Closed'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(15360677152775388)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
,p_created_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15380129890775396)
,p_event_id=>wwv_flow_imp.id(15379638321775396)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(15360677152775388)
,p_created_on=>wwv_flow_imp.dz('20251010142933Z')
,p_updated_on=>wwv_flow_imp.dz('20251010142933Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

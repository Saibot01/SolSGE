prompt --application/pages/page_00084
begin
--   Manifest
--     PAGE: 00084
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
 p_id=>84
,p_name=>'Inventario MD'
,p_alias=>'INVENTARIO-MD'
,p_page_mode=>'MODAL'
,p_step_title=>'Inventario MD'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#:ui-dialog--stretch'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
,p_created_on=>wwv_flow_imp.dz('20250930110303Z')
,p_last_updated_on=>wwv_flow_imp.dz('20251010143151Z')
,p_created_by=>'SIS_APEX'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14752711635921158)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#:t-ButtonRegion--noPadding:t-ButtonRegion--noUI'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_03'
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930110303Z')
,p_updated_on=>wwv_flow_imp.dz('20251009184916Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14753551749921162)
,p_plug_name=>'Inventario MD'
,p_title=>'Cabecera'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_query_type=>'TABLE'
,p_query_table=>'INVENTARIO'
,p_include_rowid_column=>false
,p_is_editable=>false
,p_plug_source_type=>'NATIVE_FORM'
,p_ajax_items_to_submit=>'P84_ID_INVENTARIO'
,p_plug_display_condition_type=>'ITEM_IS_NULL'
,p_plug_display_when_condition=>'P84_ID_INVENTARIO'
,p_created_on=>wwv_flow_imp.dz('20250930110303Z')
,p_updated_on=>wwv_flow_imp.dz('20251004001621Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13349996967104017)
,p_plug_name=>'Inventario DE'
,p_parent_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>220
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT seq_id,',
'       n001 AS id_producto,',
'       c001 AS nombre,',
'       n002 AS stock_sistema,',
'       n003 AS cantidad_fisica,',
'       c002 AS observacion,',
'       c008 AS row_status',
'  FROM apex_collections',
' WHERE collection_name = ''COL_INV_DETALLE''',
''))
,p_plug_source_type=>'NATIVE_IG'
,p_prn_units=>'MILLIMETERS'
,p_prn_paper_size=>'A4'
,p_prn_width=>297
,p_prn_height=>210
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header_font_color=>'#000000'
,p_prn_page_header_font_family=>'Helvetica'
,p_prn_page_header_font_weight=>'normal'
,p_prn_page_header_font_size=>'12'
,p_prn_page_footer_font_color=>'#000000'
,p_prn_page_footer_font_family=>'Helvetica'
,p_prn_page_footer_font_weight=>'normal'
,p_prn_page_footer_font_size=>'12'
,p_prn_header_bg_color=>'#EEEEEE'
,p_prn_header_font_color=>'#000000'
,p_prn_header_font_family=>'Helvetica'
,p_prn_header_font_weight=>'bold'
,p_prn_header_font_size=>'10'
,p_prn_body_bg_color=>'#FFFFFF'
,p_prn_body_font_color=>'#000000'
,p_prn_body_font_family=>'Helvetica'
,p_prn_body_font_weight=>'normal'
,p_prn_body_font_size=>'10'
,p_prn_border_width=>.5
,p_prn_page_header_alignment=>'CENTER'
,p_prn_page_footer_alignment=>'CENTER'
,p_prn_border_color=>'#666666'
,p_created_on=>wwv_flow_imp.dz('20251009175633Z')
,p_updated_on=>wwv_flow_imp.dz('20251009191753Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13350223213104020)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Id Producto'
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
,p_is_primary_key=>true
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20251009175649Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13350350141104021)
,p_name=>'STOCK_SISTEMA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'STOCK_SISTEMA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>60
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_filter_is_required=>false
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20251009191753Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13350498870104022)
,p_name=>'CANTIDAD_FISICA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD_FISICA'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cantidad Fisica'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>70
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
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20251009191221Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13350600891104024)
,p_name=>'OBSERVACION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'OBSERVACION'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>80
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_filter_is_required=>false
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20251009191753Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13350735630104025)
,p_name=>'APEX$ROW_ACTION'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_display_sequence=>20
,p_updated_on=>wwv_flow_imp.dz('20251009175633Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13350811217104026)
,p_name=>'APEX$ROW_SELECTOR'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
,p_updated_on=>wwv_flow_imp.dz('20251009175633Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13351489226104032)
,p_name=>'SEQ_ID'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'SEQ_ID'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>90
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_filter_is_required=>false
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20251009183343Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13351523988104033)
,p_name=>'NOMBRE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'NOMBRE'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXTAREA'
,p_heading=>'Nombre'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>50
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>32767
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_lov_type=>'NONE'
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20251009191221Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13352039107104038)
,p_name=>'ROW_STATUS'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ROW_STATUS'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>110
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_filter_is_required=>false
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20251009191753Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(13350021450104018)
,p_internal_uid=>13350021450104018
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_add_row_if_empty=>true
,p_submit_checked_rows=>false
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
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>true
,p_fixed_header=>'PAGE'
,p_show_icon_view=>false
,p_show_detail_view=>false
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function(config){',
'    config.defaultGridViewOptions = {',
'        footer: false',
'    }',
'    return config;',
'}'))
,p_updated_on=>wwv_flow_imp.dz('20251009191221Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(15193145517377358)
,p_interactive_grid_id=>wwv_flow_imp.id(13350021450104018)
,p_static_id=>'151932'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20251009191221Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(15193398816377358)
,p_report_id=>wwv_flow_imp.id(15193145517377358)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15194756182377361)
,p_view_id=>wwv_flow_imp.id(15193398816377358)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(13350223213104020)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15195683565377362)
,p_view_id=>wwv_flow_imp.id(15193398816377358)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(13350350141104021)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15196515633377363)
,p_view_id=>wwv_flow_imp.id(15193398816377358)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(13350498870104022)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15198354917377366)
,p_view_id=>wwv_flow_imp.id(15193398816377358)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(13350600891104024)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15199290219377367)
,p_view_id=>wwv_flow_imp.id(15193398816377358)
,p_display_seq=>0
,p_column_id=>wwv_flow_imp.id(13350735630104025)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15204472856538666)
,p_view_id=>wwv_flow_imp.id(15193398816377358)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(13351489226104032)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15205310074538667)
,p_view_id=>wwv_flow_imp.id(15193398816377358)
,p_display_seq=>8
,p_column_id=>wwv_flow_imp.id(13351523988104033)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(15223794586832154)
,p_view_id=>wwv_flow_imp.id(15193398816377358)
,p_display_seq=>11
,p_column_id=>wwv_flow_imp.id(13352039107104038)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14772647860921552)
,p_plug_name=>'Inventario - Detalle'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>40
,p_query_type=>'TABLE'
,p_query_table=>'INVENTARIO_DETALLE'
,p_query_where=>wwv_flow_string.join(wwv_flow_t_varchar2(
'ID_INVENTARIO = :P84_ID_INVENTARIO',
'AND (',
'      :P84_ESTADO <> ''BORRADOR''',
'   OR ID_PRODUCTO IN (',
'        SELECT p.ID_PRODUCTO',
'          FROM PRODUCTOS p',
'          LEFT JOIN STOCK_PRODUCTO s',
'                 ON s.ID_PRODUCTO = p.ID_PRODUCTO',
'                AND s.ID_OFICINA  = :P84_ID_OFICINA',
'         WHERE NVL(p.ACTIVO,''S'') = ''S''',
'           AND (:P84_FILTRO_CATEGORIA IS NULL OR p.ID_CATEGORIA = :P84_FILTRO_CATEGORIA)',
'           AND (:P84_FILTRO_MARCA    IS NULL OR p.ID_MARCA     = :P84_FILTRO_MARCA)',
'           AND ( :P84_SOLO_STOCK = ''N'' OR NVL(s.CANTIDAD,0) > 0 )',
'      )',
')',
''))
,p_include_rowid_column=>false
,p_plug_source_type=>'NATIVE_IG'
,p_ajax_items_to_submit=>'P84_ID_INVENTARIO,P84_ESTADO,P84_ID_OFICINA,P84_FILTRO_CATEGORIA,P84_FILTRO_MARCA,P84_SOLO_STOCK'
,p_plug_read_only_when_type=>'VAL_OF_ITEM_IN_COND_NOT_EQ_COND2'
,p_plug_read_only_when=>'P84_ESTADO'
,p_plug_read_only_when2=>'BORRADOR'
,p_prn_page_header=>'Inventario - Detalle'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_on=>wwv_flow_imp.dz('20251009190140Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14773816964921553)
,p_name=>'APEX$ROW_SELECTOR'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
,p_enable_hide=>true
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14774379166921553)
,p_name=>'APEX$ROW_ACTION'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_label=>'Actions'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>20
,p_value_alignment=>'CENTER'
,p_enable_hide=>true
,p_is_primary_key=>false
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14775345202921554)
,p_name=>'ID_INVENTARIO_DETALLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_INVENTARIO_DETALLE'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_enable_filter=>false
,p_enable_hide=>true
,p_is_primary_key=>true
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14776325080921554)
,p_name=>'ID_INVENTARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_INVENTARIO'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_is_primary_key=>false
,p_default_type=>'ITEM'
,p_default_expression=>'P84_ID_INVENTARIO'
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20250930121503Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14777338653921555)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_SELECT_LIST'
,p_heading=>'Id Producto'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>50
,p_value_alignment=>'LEFT'
,p_is_required=>true
,p_lov_type=>'SQL_QUERY'
,p_lov_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT p.NOMBRE||NVL2(p.MODELO,'' - ''||p.MODELO,'''') d,',
'       p.ID_PRODUCTO r',
'  FROM PRODUCTOS p',
'  LEFT JOIN STOCK_PRODUCTO s',
'         ON s.ID_PRODUCTO = p.ID_PRODUCTO',
'        AND s.ID_OFICINA  = :P84_ID_OFICINA',
' WHERE NVL(p.ACTIVO,''S'')=''S''',
'   AND (:P84_FILTRO_CATEGORIA IS NULL OR p.ID_CATEGORIA = :P84_FILTRO_CATEGORIA)',
'   AND (:P84_FILTRO_MARCA    IS NULL OR p.ID_MARCA     = :P84_FILTRO_MARCA)',
'   AND ( :P84_SOLO_STOCK = ''N'' OR NVL(s.CANTIDAD,0) > 0 )',
' ORDER BY 1',
''))
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
,p_updated_on=>wwv_flow_imp.dz('20251009171550Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14778323101921555)
,p_name=>'STOCK_SISTEMA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'STOCK_SISTEMA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Stock Sistema'
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
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14779314071921556)
,p_name=>'CANTIDAD_FISICA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD_FISICA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cantidad Fisica'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>70
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
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14780373962921556)
,p_name=>'DIFERENCIA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'DIFERENCIA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Diferencia'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>80
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
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14781371941921556)
,p_name=>'OBSERVACION'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'OBSERVACION'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXTAREA'
,p_heading=>'Observacion'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>90
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>1000
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
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(14773084112921552)
,p_internal_uid=>14773084112921552
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_add_row_if_empty=>true
,p_submit_checked_rows=>false
,p_lazy_loading=>false
,p_requires_filter=>false
,p_select_first_row=>true
,p_fixed_row_height=>true
,p_pagination_type=>'SCROLL'
,p_show_total_row_count=>true
,p_show_toolbar=>true
,p_toolbar_buttons=>'SEARCH_COLUMN:SEARCH_FIELD:ACTIONS_MENU:RESET'
,p_enable_save_public_report=>false
,p_enable_subscriptions=>true
,p_enable_flashback=>true
,p_define_chart_view=>true
,p_enable_download=>true
,p_enable_mail_download=>true
,p_fixed_header=>'REGION'
,p_fixed_header_max_height=>300
,p_show_icon_view=>false
,p_show_detail_view=>false
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(14773410161921553)
,p_interactive_grid_id=>wwv_flow_imp.id(14773084112921552)
,p_static_id=>'147735'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(14773650739921553)
,p_report_id=>wwv_flow_imp.id(14773410161921553)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14774748309921553)
,p_view_id=>wwv_flow_imp.id(14773650739921553)
,p_display_seq=>0
,p_column_id=>wwv_flow_imp.id(14774379166921553)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14775754373921554)
,p_view_id=>wwv_flow_imp.id(14773650739921553)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(14775345202921554)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14776719053921554)
,p_view_id=>wwv_flow_imp.id(14773650739921553)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(14776325080921554)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14777750749921555)
,p_view_id=>wwv_flow_imp.id(14773650739921553)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(14777338653921555)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14778793898921555)
,p_view_id=>wwv_flow_imp.id(14773650739921553)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(14778323101921555)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14779710322921556)
,p_view_id=>wwv_flow_imp.id(14773650739921553)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(14779314071921556)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14780777691921556)
,p_view_id=>wwv_flow_imp.id(14773650739921553)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(14780373962921556)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(14781756000921556)
,p_view_id=>wwv_flow_imp.id(14773650739921553)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(14781371941921556)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14818371867450408)
,p_button_sequence=>210
,p_button_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_button_name=>'PRECARGAR'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Precargar'
,p_warn_on_unsaved_changes=>null
,p_confirm_message=>'Desea precargar los registros?'
,p_button_condition=>'P84_ESTADO'
,p_button_condition2=>'BORRADOR'
,p_button_condition_type=>'VAL_OF_ITEM_IN_COND_EQ_COND2'
,p_grid_new_row=>'Y'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251001071835Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(9718167658137629)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14752711635921158)
,p_button_name=>'Cancel'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009184916Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14819103513450416)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14752711635921158)
,p_button_name=>'INICIAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Iniciar inventario'
,p_button_position=>'CREATE'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20251001190740Z')
,p_updated_on=>wwv_flow_imp.dz('20251009184916Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14753170785921159)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14752711635921158)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Guardar'
,p_button_position=>'EDIT'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20250930110303Z')
,p_updated_on=>wwv_flow_imp.dz('20251009185422Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(13349738830104015)
,p_button_sequence=>220
,p_button_plug_id=>wwv_flow_imp.id(14752711635921158)
,p_button_name=>'Inicair_Inventario'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Iniciar Inventario'
,p_button_position=>'NEXT'
,p_button_condition=>'P84_ID_INVENTARIO'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
,p_created_on=>wwv_flow_imp.dz('20251009153313Z')
,p_updated_on=>wwv_flow_imp.dz('20251009184916Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9718360791137631)
,p_name=>'P84_ID_INVENTARIO'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'ID_INVENTARIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20250930112051Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9718492202137632)
,p_name=>'P84_NRO_DOCUMENTO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_prompt=>'Nro Documento'
,p_source=>'NRO_DOCUMENTO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251001074736Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9718580806137633)
,p_name=>'P84_ID_OFICINA'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_prompt=>'Oficina'
,p_source=>'ID_OFICINA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'OFICINAS.DESCRIPCION'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009152358Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9718626736137634)
,p_name=>'P84_FECHA_INVENTARIO'
,p_source_data_type=>'DATE'
,p_is_required=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT CURRENT_TIMESTAMP AT TIME ZONE ''America/Asuncion'' AS fecha_paraguay',
'FROM dual;',
''))
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Fecha Inventario'
,p_source=>'FECHA_INVENTARIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150245Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9718753732137635)
,p_name=>'P84_ESTADO'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_default=>'BORRADOR'
,p_prompt=>'Estado'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:BORRADOR;BORRADOR,ENVIADO;ENVIADO,APROBADO;APROBADO,POSTEADO;POSTEADO,RECHAZADO;RECHAZADO'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_display_when=>'P84_ID_INVENTARIO'
,p_display_when_type=>'ITEM_IS_NULL'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150010Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9718836633137636)
,p_name=>'P84_OBSERVACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>170
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_prompt=>'Observacion'
,p_source=>'OBSERVACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>30
,p_cMaxlength=>4000
,p_cHeight=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20250930124145Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9718914580137637)
,p_name=>'P84_USUARIO_CREADOR'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_is_query_only=>true
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_default=>'&APP_USER.'
,p_prompt=>'Usuario Creador'
,p_source=>'USUARIO_CREADOR'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_cMaxlength=>100
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251010143151Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719015350137638)
,p_name=>'P84_FECHA_CREACION'
,p_source_data_type=>'DATE'
,p_is_required=>true
,p_is_query_only=>true
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT CURRENT_TIMESTAMP AT TIME ZONE ''America/Asuncion'' AS fecha_paraguay',
'FROM dual;',
''))
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Fecha Creacion'
,p_source=>'FECHA_CREACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719140453137639)
,p_name=>'P84_USUARIO_ENVIO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'USUARIO_ENVIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719269117137640)
,p_name=>'P84_FECHA_ENVIO'
,p_source_data_type=>'DATE'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'FECHA_ENVIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719399621137641)
,p_name=>'P84_USUARIO_APROBACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'USUARIO_APROBACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719472969137642)
,p_name=>'P84_FECHA_APROBACION'
,p_source_data_type=>'DATE'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'FECHA_APROBACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719570369137643)
,p_name=>'P84_USUARIO_POSTEO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'USUARIO_POSTEO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719658983137644)
,p_name=>'P84_FECHA_POSTEO'
,p_source_data_type=>'DATE'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'FECHA_POSTEO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719784359137645)
,p_name=>'P84_USUARIO_RECHAZO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>150
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'USUARIO_RECHAZO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9719891441137646)
,p_name=>'P84_FECHA_RECHAZO'
,p_source_data_type=>'DATE'
,p_item_sequence=>160
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_item_source_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_source=>'FECHA_RECHAZO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251009150350Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9720182922137649)
,p_name=>'P84_FILTRO_CATEGORIA'
,p_item_sequence=>180
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_prompt=>'Filtro Categoria'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT NOMBRE d, ID_CATEGORIA r',
'  FROM CATEGORIAS_PRODUCTOS',
' ORDER BY 1',
''))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251001052536Z')
,p_updated_on=>wwv_flow_imp.dz('20251001052536Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(9720283716137650)
,p_name=>'P84_FILTRO_MARCA'
,p_item_sequence=>190
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_prompt=>'Filtro Marca'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT NOMBRE d, ID_MARCA r',
'  FROM MARCAS',
' ORDER BY 1',
''))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251001052536Z')
,p_updated_on=>wwv_flow_imp.dz('20251001071835Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14817675891450401)
,p_name=>'P84_SOLO_STOCK'
,p_item_sequence=>200
,p_item_plug_id=>wwv_flow_imp.id(14753551749921162)
,p_prompt=>'Solo Stock'
,p_source=>'S'
,p_source_type=>'STATIC'
,p_display_as=>'NATIVE_YES_NO'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'use_defaults', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251001052536Z')
,p_updated_on=>wwv_flow_imp.dz('20251001071835Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14817765118450402)
,p_name=>'REFRESCAR IG'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P84_FILTRO_CATEGORIA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009171100Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14817834805450403)
,p_event_id=>wwv_flow_imp.id(14817765118450402)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'REFRESH'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14772647860921552)
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009171100Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14817920138450404)
,p_name=>'REFRESCAR IG M'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P84_FILTRO_MARCA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009171100Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14818017005450405)
,p_event_id=>wwv_flow_imp.id(14817920138450404)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'REFRESH'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14772647860921552)
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009171100Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14818188455450406)
,p_name=>'REGRESCAR IG'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P84_SOLO_STOCK'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009171100Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14818285787450407)
,p_event_id=>wwv_flow_imp.id(14818188455450406)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'REFRESH'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14772647860921552)
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009171100Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14818430227450409)
,p_name=>'PRECARGAR'
,p_event_sequence=>40
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(14818371867450408)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009191221Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14818580978450410)
,p_event_id=>wwv_flow_imp.id(14818430227450409)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'Insert'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  INSERT INTO INVENTARIO_DETALLE (ID_INVENTARIO, ID_PRODUCTO, CANTIDAD_FISICA, OBSERVACION)',
'  SELECT :P84_ID_INVENTARIO,',
'         p.ID_PRODUCTO,',
'         0,',
'         NULL',
'    FROM PRODUCTOS p',
'    LEFT JOIN STOCK_PRODUCTO s',
'           ON s.ID_PRODUCTO = p.ID_PRODUCTO',
'          AND s.ID_OFICINA  = :P84_ID_OFICINA',
'    LEFT JOIN INVENTARIO_DETALLE d',
'           ON d.ID_INVENTARIO = :P84_ID_INVENTARIO',
'          AND d.ID_PRODUCTO   = p.ID_PRODUCTO',
'   WHERE d.ID_INVENTARIO_DETALLE IS NULL',
'     AND NVL(p.ACTIVO,''S'') = ''S''',
'     AND (:P84_FILTRO_CATEGORIA IS NULL OR p.ID_CATEGORIA = :P84_FILTRO_CATEGORIA)',
'     AND (:P84_FILTRO_MARCA    IS NULL OR p.ID_MARCA     = :P84_FILTRO_MARCA)',
'     AND ( :P84_SOLO_STOCK = ''N'' OR NVL(s.CANTIDAD,0) > 0 );',
'',
unistr('  -- Opcional, pero \00FAtil en DA/AJAX para que el IG vea de inmediato los inserts:'),
'  COMMIT;',
'',
unistr('  APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE := ''L\00EDneas precargadas seg\00FAn filtros.'';'),
'  EXCEPTION',
'    WHEN OTHERS THEN',
'        APEX_ERROR.ADD_ERROR (',
'            p_message => ''Error al precargar los productos: '' || SQLERRM,',
'            p_display_location => APEX_ERROR.C_ON_ERROR_PAGE',
'        );',
'END;'))
,p_attribute_02=>'P84_ID_INVENTARIO, P84_ID_OFICINA, P84_FILTRO_CATEGORIA, P84_FILTRO_MARCA, P84_SOLO_STOCK'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_build_option_id=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009182326Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13351385864104031)
,p_event_id=>wwv_flow_imp.id(14818430227450409)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_name=>'Inserta en coleccion'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  apex_collection.create_or_truncate_collection(''COL_INV_DETALLE'');',
'',
'  FOR r IN (',
'    SELECT p.id_producto,',
'           p.nombre,',
'           NVL(s.cantidad,0) AS stock',
'      FROM productos p',
'      LEFT JOIN stock_producto s',
'             ON s.id_producto = p.id_producto',
'            AND s.id_oficina = :P84_ID_OFICINA',
'     WHERE NVL(p.activo,''S'') = ''S''',
'       AND (:P84_FILTRO_CATEGORIA IS NULL OR p.id_categoria = :P84_FILTRO_CATEGORIA)',
'       AND (:P84_FILTRO_MARCA    IS NULL OR p.id_marca     = :P84_FILTRO_MARCA)',
'       AND (:P84_SOLO_STOCK = ''N'' OR NVL(s.cantidad,0) > 0)',
'  ) LOOP',
'    apex_collection.add_member(',
'      p_collection_name => ''COL_INV_DETALLE'',',
'      p_n001 => r.id_producto,',
'      p_c001 => r.nombre,',
'      p_n002 => r.stock,',
unistr('      p_n003 => 0,      -- cantidad f\00EDsica'),
unistr('      p_c002 => NULL,   -- observaci\00F3n'),
'      p_c008 => ''C''     -- status: C = creado',
'    );',
'  END LOOP;',
'END;',
''))
,p_attribute_02=>'P84_FILTRO_CATEGORIA,P84_FILTRO_MARCA,P84_SOLO_STOCK,P84_ID_OFICINA'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20251009182326Z')
,p_updated_on=>wwv_flow_imp.dz('20251009191221Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14818669037450411)
,p_event_id=>wwv_flow_imp.id(14818430227450409)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_name=>'refresh'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(13349996967104017)
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20251001071835Z')
,p_updated_on=>wwv_flow_imp.dz('20251009182326Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14818777869450412)
,p_name=>'New'
,p_event_sequence=>50
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P84_ESTADO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20251001072017Z')
,p_updated_on=>wwv_flow_imp.dz('20251001072017Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14818830218450413)
,p_event_id=>wwv_flow_imp.id(14818777869450412)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14772647860921552)
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20251001072017Z')
,p_updated_on=>wwv_flow_imp.dz('20251001072017Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(14782333294921557)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(14772647860921552)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Inventario - Detalle - Save Interactive Grid Data'
,p_attribute_01=>'PLSQL_CODE'
,p_attribute_04=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    case:APEX$ROW_STATUS',
'        WHEN ''C'' THEN',
'            INSERT INTO DETALLE_ORDEN(ID_ORDEN,ID_PRODUCTO,CANTIDAD,PRECIO_UNITARIO,TOTAL)',
'            VALUES (:P54_ID_ORDEN,:ID_PRODUCTO,:CANTIDAD,:PRECIO_UNITARIO,:TOTAL);',
'        WHEN ''U'' THEN',
'            UPDATE DETALLE_ORDEN',
'            SET ID_PRODUCTO = :ID_PRODUCTO,',
'                CANTIDAD = :CANTIDAD,',
'                PRECIO_UNITARIO = :PRECIO_UNITARIO,',
'                TOTAL = :TOTAL',
'            WHERE ID_ORDEN = :P54_ID_ORDEN;',
'        WHEN ''D'' THEN',
'            DELETE DETALLE_ORDEN WHERE ID_ORDEN = :ID_ORDEN;',
'    END CASE;',
'END;'))
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(14753170785921159)
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_internal_uid=>14782333294921557
,p_created_on=>wwv_flow_imp.dz('20250930110307Z')
,p_updated_on=>wwv_flow_imp.dz('20251009183110Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13350915027104027)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(13349996967104017)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Inventario DE - Save Interactive Grid Data'
,p_attribute_01=>'PLSQL_CODE'
,p_attribute_04=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_rec apex_collections%ROWTYPE;  -- tipo basado en la tabla de vistas',
'BEGIN',
'  FOR l_rec IN (SELECT * FROM apex_collections',
'                  WHERE collection_name = ''COL_INV_DETALLE'') LOOP',
'',
unistr('    -- Us\00E1s los campos n001, c001, n002, etc. seg\00FAn lo definiste'),
unistr('    CASE l_rec.c008  -- supongamos que guardaste el status aqu\00ED: ''C'',''U'',''D'''),
'      WHEN ''C'' THEN',
'        INSERT INTO inventario_detalle (',
'          id_inventario,',
'          id_producto,',
'          stock_sistema,',
'          cantidad_fisica,',
'          observacion,',
'          id_sector,',
'          id_ubicacion',
'        )',
'        VALUES (',
'          :P84_ID_INVENTARIO,',
'          l_rec.n001,',
'          l_rec.n002,',
'          l_rec.n003,',
'          l_rec.c002,',
'          l_rec.n004,',
'          l_rec.n005',
'        );',
'',
'      WHEN ''U'' THEN',
'        UPDATE inventario_detalle',
'             SET cantidad_fisica = l_rec.n003,',
'               observacion     = l_rec.c002,',
'               id_sector       = l_rec.n004,',
'               id_ubicacion    = l_rec.n005',
'         WHERE id_inventario = :P84_ID_INVENTARIO',
'           AND id_producto   = l_rec.n001;',
'',
'      WHEN ''D'' THEN',
'        DELETE FROM inventario_detalle',
'         WHERE id_inventario = :P84_ID_INVENTARIO',
'           AND id_producto   = l_rec.n001;',
'    END CASE;',
'    INSERT INTO inventario_detalle (',
'          id_inventario,',
'          id_producto,',
'          stock_sistema,',
'          cantidad_fisica,',
'          observacion,',
'          id_sector,',
'          id_ubicacion',
'        )',
'        VALUES (',
'          :P84_ID_INVENTARIO,',
'          l_rec.n001,',
'          l_rec.n002,',
'          l_rec.n003,',
'          l_rec.c002,',
'          l_rec.n004,',
'          l_rec.n005',
'        );',
'  END LOOP;',
'',
'  COMMIT;',
'END;',
''))
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_process_error_message=>'ERR'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(13349738830104015)
,p_process_success_message=>'Guardando Detalle'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_internal_uid=>13350915027104027
,p_created_on=>wwv_flow_imp.dz('20251009175633Z')
,p_updated_on=>wwv_flow_imp.dz('20251009191221Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13349834081104016)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(14753551749921162)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Inventario'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(13349738830104015)
,p_process_success_message=>'AA'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_internal_uid=>13349834081104016
,p_created_on=>wwv_flow_imp.dz('20251009153411Z')
,p_updated_on=>wwv_flow_imp.dz('20251009191722Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13349640609104014)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>13349640609104014
,p_created_on=>wwv_flow_imp.dz('20251009152944Z')
,p_updated_on=>wwv_flow_imp.dz('20251009185640Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(9718299941137630)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(14753551749921162)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Inventario MD'
,p_internal_uid=>9718299941137630
,p_created_on=>wwv_flow_imp.dz('20250930112051Z')
,p_updated_on=>wwv_flow_imp.dz('20251001090824Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13351214969104030)
,p_process_sequence=>30
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Crear Coleccion'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  IF NOT apex_collection.collection_exists(''COL_INV_DETALLE'') THEN',
'    apex_collection.create_collection(''COL_INV_DETALLE'');',
'  ELSE',
'    apex_collection.truncate_collection(''COL_INV_DETALLE'');',
'  END IF;',
'END;',
''))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>13351214969104030
,p_created_on=>wwv_flow_imp.dz('20251009182326Z')
,p_updated_on=>wwv_flow_imp.dz('20251009183110Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13352145402104039)
,p_process_sequence=>10
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_region_id=>wwv_flow_imp.id(14753551749921162)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Cabecera'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>13352145402104039
,p_created_on=>wwv_flow_imp.dz('20251009191543Z')
,p_updated_on=>wwv_flow_imp.dz('20251010003929Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13351970876104037)
,p_process_sequence=>20
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Inserta Detalle'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_rec apex_collections%ROWTYPE;',
'BEGIN',
'  FOR l_rec IN (SELECT * FROM apex_collections',
'                 WHERE collection_name = ''COL_INV_DETALLE'') LOOP',
'',
'    CASE l_rec.c008',
'      WHEN ''C'' THEN',
'        INSERT INTO inventario_detalle (',
'          id_inventario,',
'          id_producto,',
'          stock_sistema,',
'          cantidad_fisica,',
'          observacion',
'        )',
'        VALUES (',
'          :P84_ID_INVENTARIO,',
'          l_rec.n001,',
'          l_rec.n002,',
'          l_rec.n003,',
'          l_rec.c002',
'        );',
'',
'      WHEN ''U'' THEN',
'        UPDATE inventario_detalle',
'           SET cantidad_fisica = l_rec.n003,',
'               observacion     = l_rec.c002',
'         WHERE id_inventario = :P84_ID_INVENTARIO',
'           AND id_producto   = l_rec.n001;',
'',
'      WHEN ''D'' THEN',
'        DELETE FROM inventario_detalle',
'         WHERE id_inventario = :P84_ID_INVENTARIO',
'           AND id_producto   = l_rec.n001;',
'    END CASE;',
'',
'  END LOOP;',
'  COMMIT;',
'END;',
''))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_success_message=>'Inventario Generado'
,p_internal_uid=>13351970876104037
,p_created_on=>wwv_flow_imp.dz('20251009191221Z')
,p_updated_on=>wwv_flow_imp.dz('20251010003929Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00054
begin
--   Manifest
--     PAGE: 00054
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
 p_id=>54
,p_name=>'Orden de Venta'
,p_alias=>'ORDEN-DE-VENTA1'
,p_step_title=>'Orden de Venta'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function recalculaImporte() {',
'    var model = apex.region("Detalle_Ventas").widget().interactiveGrid("getCurrentView").model;',
'    var col_gl_amount = model.getFieldKey("TOTAL");',
'    var n_total = 0;',
'',
'    model.forEach(function(igrow) {',
'        var raw_value = igrow[col_gl_amount];',
'',
'        if (raw_value !== null && raw_value !== undefined) {',
unistr('            // Elimina s\00EDmbolo de moneda y formato'),
'            var clean_value = raw_value',
'                .toString()',
'                .replace(/[^0-9,.-]/g, '''')',
'                .replace(/\./g, '''')',
'                .replace('','', ''.'');',
'',
'            var n_dist_amount = parseFloat(clean_value);',
'',
'            if (!isNaN(n_dist_amount)) {',
'                n_total += n_dist_amount;',
'                console.log("N_DIST_AMOUNT: " + n_dist_amount);',
'            }',
'        }',
'    });',
'',
'    console.log("n_total: " + n_total);',
'    apex.item(''P54_TOTAL'').setValue(Math.round(n_total));',
'',
'    //apex.item(''P54_TOTAL'').setValue(n_total.toFixed(2));',
'}',
'',
'',
'',
'/*function recalculaImporte(){',
' ',
'var model = apex.region("Detalle_Ventas").widget().interactiveGrid("getCurrentView").model;',
'var n_dist_amount, n_total;',
'//var iva = 0;',
'var col_gl_amount = model.getFieldKey("PRECIO_UNITARIO");',
'console.log("PRECIO_UNITARIO: "+col_gl_amount)',
'model.forEach(function(igrow){   ',
'        n_dist_amount = parseInt(igrow[col_gl_amount]);',
'            if (!isNaN(n_dist_amount)) {',
'                         n_total += n_dist_amount;',
'                         console.log("N_DIST_AMMOUNT: "+n_dist_amount);',
'',
'            }',
'  });',
'     ',
'console.log("n_total: "+n_total);',
'apex.item(''P54_TOTAL'').setValue(n_total);',
'',
'}*/'))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'02'
,p_created_on=>wwv_flow_imp.dz('20250508000654Z')
,p_last_updated_on=>wwv_flow_imp.dz('20251123185241Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11880079139947272)
,p_plug_name=>'Orden de Venta'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'ORDENES_VENTA'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
,p_created_on=>wwv_flow_imp.dz('20250508000654Z')
,p_updated_on=>wwv_flow_imp.dz('20250527135842Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11735397033125021)
,p_plug_name=>'Cabecera'
,p_parent_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508001115Z')
,p_updated_on=>wwv_flow_imp.dz('20250527135841Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11735508211125023)
,p_plug_name=>'Pie'
,p_parent_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>70
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508001115Z')
,p_updated_on=>wwv_flow_imp.dz('20250527135841Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11738175220125049)
,p_plug_name=>'Productos'
,p_parent_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>60
,p_location=>null
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508134653Z')
,p_updated_on=>wwv_flow_imp.dz('20250527135841Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11937687366860014)
,p_plug_name=>'Detalle Ventas'
,p_region_name=>'Detalle_Ventas'
,p_parent_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>50
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select DE.ID_DETALLE,',
'       DE.ID_ORDEN,',
'       DE.ID_PRODUCTO,',
'       DE.CANTIDAD,',
'       DE.PRECIO_UNITARIO,',
'       DE.TOTAL',
'  from DETALLE_ORDEN DE, PRECIO_POR_CATEGORIA CA',
' where DE.ID_PRODUCTO = CA.ID_PRODUCTO',
' AND ID_ORDEN = :P54_ID_ORDEN'))
,p_plug_source_type=>'NATIVE_IG'
,p_ajax_items_to_submit=>'P54_ID_ORDEN'
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
,p_created_on=>wwv_flow_imp.dz('20250509125447Z')
,p_updated_on=>wwv_flow_imp.dz('20250527135841Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(11937991701860017)
,p_name=>'ID_DETALLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_DETALLE'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20250509125447Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(11938055398860018)
,p_name=>'ID_ORDEN'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_ORDEN'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_filter_is_required=>false
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_default_type=>'ITEM'
,p_default_expression=>'P54_ID_ORDEN'
,p_duplicate_value=>true
,p_include_in_export=>false
,p_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_display_condition=>'P54_ID_ORDEN'
,p_updated_on=>wwv_flow_imp.dz('20250509125547Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(11938135673860019)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_POPUP_LOV'
,p_heading=>'Producto'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>50
,p_value_alignment=>'CENTER'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
,p_is_required=>true
,p_lov_type=>'SQL_QUERY'
,p_lov_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select pro.nombre, pro.id_producto ',
'from productos pro, precio_por_categoria  cat',
'    where pro.id_producto = cat.id_producto',
'    and cat.CATEGORIA_CLIENTE = :P54_TIP_CLIENTE;'))
,p_lov_display_extra=>true
,p_lov_display_null=>true
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
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250509132916Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(11938212017860020)
,p_name=>'CANTIDAD'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cantidad'
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
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250509125447Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(11938307526860021)
,p_name=>'PRECIO_UNITARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PRECIO_UNITARIO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Precio Unitario'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>70
,p_value_alignment=>'RIGHT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_is_required=>false
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
,p_updated_on=>wwv_flow_imp.dz('20250509125447Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(11938461766860022)
,p_name=>'APEX$ROW_ACTION'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_display_sequence=>20
,p_updated_on=>wwv_flow_imp.dz('20250509125447Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(11938597088860023)
,p_name=>'APEX$ROW_SELECTOR'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
,p_updated_on=>wwv_flow_imp.dz('20250509125447Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12005416807524723)
,p_name=>'TOTAL'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TOTAL'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Total'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>80
,p_value_alignment=>'RIGHT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_is_required=>false
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
,p_updated_on=>wwv_flow_imp.dz('20250521111213Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(11937810916860016)
,p_internal_uid=>11937810916860016
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
,p_updated_on=>wwv_flow_imp.dz('20250521111213Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(11960145040194558)
,p_interactive_grid_id=>wwv_flow_imp.id(11937810916860016)
,p_static_id=>'119602'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20250521111213Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(11960360090194559)
,p_report_id=>wwv_flow_imp.id(11960145040194558)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(11960832904194561)
,p_view_id=>wwv_flow_imp.id(11960360090194559)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(11937991701860017)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(11961781329194564)
,p_view_id=>wwv_flow_imp.id(11960360090194559)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(11938055398860018)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(11962616875194566)
,p_view_id=>wwv_flow_imp.id(11960360090194559)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(11938135673860019)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(11963575232194568)
,p_view_id=>wwv_flow_imp.id(11960360090194559)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(11938212017860020)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(11964434934194569)
,p_view_id=>wwv_flow_imp.id(11960360090194559)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(11938307526860021)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(11965301543194571)
,p_view_id=>wwv_flow_imp.id(11960360090194559)
,p_display_seq=>0
,p_column_id=>wwv_flow_imp.id(11938461766860022)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12516363481259167)
,p_view_id=>wwv_flow_imp.id(11960360090194559)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(12005416807524723)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(11884556427947278)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>20
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185241Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(15984092643097116)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(11735397033125021)
,p_button_name=>'CLIENTE'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'+ Cliente'
,p_button_redirect_url=>'f?p=&APP_ID.:91:&SESSION.::&DEBUG.:RP,54::'
,p_grid_new_row=>'N'
,p_grid_new_column=>'Y'
,p_created_on=>wwv_flow_imp.dz('20251123185025Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185047Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11936775803860005)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(11738175220125049)
,p_button_name=>'Agregar'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Agregar'
,p_warn_on_unsaved_changes=>null
,p_grid_new_row=>'Y'
,p_grid_column_span=>2
,p_created_on=>wwv_flow_imp.dz('20250508135954Z')
,p_updated_on=>wwv_flow_imp.dz('20250508142726Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11884940051947278)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(11884556427947278)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancel'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185241Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11886330571947279)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(11884556427947278)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Delete'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>'P54_ID_ORDEN'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185241Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11886756685947280)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(11884556427947278)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Actualizar'
,p_button_position=>'NEXT'
,p_button_condition=>'P54_ID_ORDEN'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185241Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(11887183878947280)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(11884556427947278)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'NEXT'
,p_button_condition=>'P54_ID_ORDEN'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185241Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11738215192125050)
,p_name=>'P54_PRODUCTO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(11738175220125049)
,p_prompt=>'Producto'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select pro.nombre, pro.id_producto from productos pro, precio_por_categoria cat',
'    where pro.id_producto = cat.id_producto',
'    and CATEGORIA_CLIENTE = :P54_TIP_CLIENTE;'))
,p_lov_display_null=>'YES'
,p_cSize=>30
,p_colspan=>6
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508134653Z')
,p_updated_on=>wwv_flow_imp.dz('20250509132655Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11880467286947273)
,p_name=>'P54_ID_ORDEN'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_item_source_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Id Orden'
,p_source=>'ID_ORDEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508000654Z')
,p_updated_on=>wwv_flow_imp.dz('20250508000655Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11880806631947274)
,p_name=>'P54_ID_PERSONA'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(11735397033125021)
,p_item_source_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_prompt=>'Cliente'
,p_source=>'ID_PERSONA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'    SELECT PE.PRIMER_NOMBRE ||'' ''||PE.SEGUNDO_NOMBRE||'' ''||PE.PRIMER_APELLIDO||'' ''||PE.SEGUNDO_APELLIDO|| '' - ''||PE.NRO_DOCUMENTO AS CLIENTE,CL.ID_PERSONA FROM PERSONAS PE, CLIENTES CL',
'    WHERE PE.ID_PERSONA = CL.ID_PERSONA'))
,p_lov_display_null=>'YES'
,p_cSize=>30
,p_colspan=>4
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'case_sensitive', 'N',
  'display_as', 'POPUP',
  'fetch_on_search', 'N',
  'initial_fetch', 'FIRST_ROWSET',
  'manual_entry', 'N',
  'match_type', 'CONTAINS',
  'min_chars', '0')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508000654Z')
,p_updated_on=>wwv_flow_imp.dz('20250509180230Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11881270955947275)
,p_name=>'P54_FECHA_ORDEN'
,p_source_data_type=>'DATE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(11735397033125021)
,p_item_source_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT CURRENT_TIMESTAMP AT TIME ZONE ''America/Argentina/Buenos_Aires'' AS FECHA_HORA_ARG',
'FROM dual;',
''))
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Fecha'
,p_source=>'FECHA_ORDEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_colspan=>4
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
,p_created_on=>wwv_flow_imp.dz('20250508000654Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185025Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11881613602947275)
,p_name=>'P54_ESTADO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(11735397033125021)
,p_item_source_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_item_default=>'Pendiente'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508000654Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185025Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11882046773947275)
,p_name=>'P54_TOTAL'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(11735508211125023)
,p_item_source_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_prompt=>'Total'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_tag_css_classes=>'style="font-size:35px;text-align:right;font-weight:bold;"'
,p_grid_column=>9
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508000654Z')
,p_updated_on=>wwv_flow_imp.dz('20250509193307Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11882467038947275)
,p_name=>'P54_OBSERVACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(11735508211125023)
,p_item_source_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_prompt=>'Observacion'
,p_source=>'OBSERVACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508000654Z')
,p_updated_on=>wwv_flow_imp.dz('20250508130539Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11936378381860001)
,p_name=>'P54_CANTIDAD'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(11738175220125049)
,p_prompt=>'Cantidad'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_colspan=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508134653Z')
,p_updated_on=>wwv_flow_imp.dz('20250508134653Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11936413825860002)
,p_name=>'P54_PRE_UNITARIO'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(11738175220125049)
,p_prompt=>'Pre Unitario'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_tag_attributes=>'disabled="disabled"'
,p_begin_on_new_line=>'N'
,p_colspan=>4
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250508134653Z')
,p_updated_on=>wwv_flow_imp.dz('20250509190846Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(11940497434860042)
,p_name=>'P54_TIP_CLIENTE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_prompt=>'Tipo Cliente'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250509132655Z')
,p_updated_on=>wwv_flow_imp.dz('20250509163149Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12005610111524725)
,p_name=>'P54_ID_OFICINA'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(11735397033125021)
,p_item_source_plug_id=>wwv_flow_imp.id(11880079139947272)
,p_prompt=>'Oficina'
,p_source=>'ID_OFICINA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select descripcion, codigo_oficina from OFICINAS'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250527135841Z')
,p_updated_on=>wwv_flow_imp.dz('20251123185025Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11885015507947278)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(11884940051947278)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20250508000655Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11885847564947279)
,p_event_id=>wwv_flow_imp.id(11885015507947278)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20250508000655Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11737530059125043)
,p_name=>'Tipo Cliente'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P54_ID_PERSONA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250508125113Z')
,p_updated_on=>wwv_flow_imp.dz('20250509163149Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11737699605125044)
,p_event_id=>wwv_flow_imp.id(11737530059125043)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT CATEGORIA_CLIENTE ',
'    INTO :P54_TIP_CLIENTE',
'FROM  CLIENTES CL',
'    WHERE CL.ID_PERSONA = :P54_ID_PERSONA;'))
,p_attribute_02=>'P54_ID_PERSONA'
,p_attribute_03=>'P54_TIP_CLIENTE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250508125113Z')
,p_updated_on=>wwv_flow_imp.dz('20250509163149Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11938826428860026)
,p_event_id=>wwv_flow_imp.id(11737530059125043)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P54_TIP_CLIENTE'
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20250509125634Z')
,p_updated_on=>wwv_flow_imp.dz('20250509163149Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11936509317860003)
,p_name=>'Carga de Productos'
,p_event_sequence=>50
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P54_PRODUCTO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250508135341Z')
,p_updated_on=>wwv_flow_imp.dz('20250509130427Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11936669903860004)
,p_event_id=>wwv_flow_imp.id(11936509317860003)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select 1, cat.precio ',
'into :P54_CANTIDAD,:P54_PRE_UNITARIO',
'from productos pro, precio_por_categoria cat',
'    where pro.id_producto = cat.id_producto',
'    --and CATEGORIA_CLIENTE = :P54_TIP_CLIENTE',
'    and pro.id_producto = :P54_PRODUCTO;'))
,p_attribute_02=>'P54_PRODUCTO'
,p_attribute_03=>'P54_CANTIDAD,P54_PRE_UNITARIO'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250508135341Z')
,p_updated_on=>wwv_flow_imp.dz('20250509130427Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11936802538860006)
,p_name=>'Insertar Detalle'
,p_event_sequence=>60
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(11936775803860005)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
,p_created_on=>wwv_flow_imp.dz('20250508140623Z')
,p_updated_on=>wwv_flow_imp.dz('20250508140623Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11936948840860007)
,p_event_id=>wwv_flow_imp.id(11936802538860006)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'insert into DETALLE_ORDEN(id_orden, id_producto, cantidad, precio_unitario)',
'values (:P54_ID_ORDEN,:P54_PRODUCTO,:P54_CANTIDAD,:P54_PRE_UNITARIO);'))
,p_attribute_02=>'P54_ID_ORDEN,P54_PRODUCTO,P54_CANTIDAD,P54_PRE_UNITARIO'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250508140623Z')
,p_updated_on=>wwv_flow_imp.dz('20250508140623Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11937034738860008)
,p_event_id=>wwv_flow_imp.id(11936802538860006)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    v_total number;',
'    BEGIN',
'    SELECT SUM(PRECIO_UNITARIO) ',
'        INTO v_total',
'        FROM DETALLE_ORDEN',
'        WHERE ID_ORDEN = :P54_ID_ORDEN;',
'',
'        :P54_TOTAL := v_total;',
'    END;'))
,p_attribute_02=>'P54_ID_ORDEN'
,p_attribute_03=>'P54_TOTAL'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250508140623Z')
,p_updated_on=>wwv_flow_imp.dz('20250508140623Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11937180583860009)
,p_event_id=>wwv_flow_imp.id(11936802538860006)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P54_TOTAL'
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20250508140623Z')
,p_updated_on=>wwv_flow_imp.dz('20250508140623Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11940500984860043)
,p_name=>'Carga de Productoss'
,p_event_sequence=>70
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(11937687366860014)
,p_triggering_element=>'ID_PRODUCTO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250509133456Z')
,p_updated_on=>wwv_flow_imp.dz('20250529145032Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11940694518860044)
,p_event_id=>wwv_flow_imp.id(11940500984860043)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select 1, cat.precio,cat.precio  ',
'into :CANTIDAD,:PRECIO_UNITARIO, :TOTAL',
'from productos pro, precio_por_categoria cat',
'    where pro.id_producto = cat.id_producto',
'    AND CAT.CATEGORIA_CLIENTE = :P54_TIP_CLIENTE',
'    and pro.id_producto = :ID_PRODUCTO;'))
,p_attribute_02=>'ID_PRODUCTO'
,p_attribute_03=>'CANTIDAD,PRECIO_UNITARIO'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250509133456Z')
,p_updated_on=>wwv_flow_imp.dz('20250529145032Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12939315090107105)
,p_event_id=>wwv_flow_imp.id(11940500984860043)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
,p_created_on=>wwv_flow_imp.dz('20250529145032Z')
,p_updated_on=>wwv_flow_imp.dz('20250529145032Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11940930376860047)
,p_name=>'New'
,p_event_sequence=>80
,p_bind_type=>'bind'
,p_bind_event_type=>'apexbeforepagesubmit'
,p_created_on=>wwv_flow_imp.dz('20250509183229Z')
,p_updated_on=>wwv_flow_imp.dz('20250509190846Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11941046197860048)
,p_event_id=>wwv_flow_imp.id(11940930376860047)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'$(''#P54_TOTAL'').removeAttr("disabled");'
,p_created_on=>wwv_flow_imp.dz('20250509183229Z')
,p_updated_on=>wwv_flow_imp.dz('20250509190846Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(11941183824860049)
,p_name=>'Totalizador'
,p_event_sequence=>90
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(11937687366860014)
,p_triggering_element=>'CANTIDAD,PRECIO_UNITARIO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250509190846Z')
,p_updated_on=>wwv_flow_imp.dz('20250521111213Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(11941267057860050)
,p_event_id=>wwv_flow_imp.id(11941183824860049)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
,p_created_on=>wwv_flow_imp.dz('20250509190846Z')
,p_updated_on=>wwv_flow_imp.dz('20250509192505Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12005584861524724)
,p_event_id=>wwv_flow_imp.id(11941183824860049)
,p_event_result=>'TRUE'
,p_action_sequence=>40
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>':TOTAL := :CANTIDAD * :PRECIO_UNITARIO;'
,p_attribute_02=>'CANTIDAD,PRECIO_UNITARIO'
,p_attribute_03=>'TOTAL'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250521111213Z')
,p_updated_on=>wwv_flow_imp.dz('20250521111213Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12003374641524702)
,p_name=>'Recalcular Total IG'
,p_event_sequence=>100
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(11937687366860014)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250509193055Z')
,p_updated_on=>wwv_flow_imp.dz('20250509193055Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12003449913524703)
,p_event_id=>wwv_flow_imp.id(12003374641524702)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
,p_created_on=>wwv_flow_imp.dz('20250509193055Z')
,p_updated_on=>wwv_flow_imp.dz('20250509193055Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11938736721860025)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Eliminar Lineas'
,p_process_sql_clob=>'delete from DETALLE_ORDEN where id_orden = :P54_ID_ORDEN;'
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(11886330571947279)
,p_internal_uid=>11938736721860025
,p_created_on=>wwv_flow_imp.dz('20250509125447Z')
,p_updated_on=>wwv_flow_imp.dz('20250509125447Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11887912180947281)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(11880079139947272)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Orden de Venta'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>11887912180947281
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20250509125447Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11938657497860024)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(11937687366860014)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Detalle Factura - Save Interactive Grid Data'
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
,p_internal_uid=>11938657497860024
,p_created_on=>wwv_flow_imp.dz('20250509125447Z')
,p_updated_on=>wwv_flow_imp.dz('20250529124035Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11888358961947281)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>11888358961947281
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20250509125447Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11887519818947280)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(11880079139947272)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Orden de Venta'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>11887519818947280
,p_created_on=>wwv_flow_imp.dz('20250508000655Z')
,p_updated_on=>wwv_flow_imp.dz('20250508000655Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(11737888500125046)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Indicaciones Inicial'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'apex_application.g_print_success_message := ',
'    ''<div style="text-align: center;">',
'        <span style="color: black;">',
'            <strong>Para ingresar productos, debe seleccionar un cliente.</strong>',
'        </span>',
'    </div>'';',
''))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>11737888500125046
,p_created_on=>wwv_flow_imp.dz('20250508130025Z')
,p_updated_on=>wwv_flow_imp.dz('20250508130243Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

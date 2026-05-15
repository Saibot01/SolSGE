prompt --application/pages/page_00072
begin
--   Manifest
--     PAGE: 00072
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
 p_id=>72
,p_name=>'Orden de Compra'
,p_alias=>'ORDEN-DE-COMPRA'
,p_page_mode=>'MODAL'
,p_step_title=>'Orden de Compra'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function recalculaImporte() {',
'    var model = apex.region("Detalle_Orden_Compra").widget().interactiveGrid("getCurrentView").model;',
'    var col_gl_amount = model.getFieldKey("TOTAL_DETALLE");',
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
'    apex.item(''P72_TOTAL_ORDEN'').setValue(Math.round(n_total));',
'',
'    //apex.item(''P54_TOTAL'').setValue(n_total.toFixed(2));',
'}',
''))
,p_step_template=>2100407606326202693
,p_page_template_options=>'#DEFAULT#:ui-dialog--stretch'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12892991332928779)
,p_plug_name=>'Orden de Compra'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'ORDENES_COMPRA'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12857379693396833)
,p_plug_name=>'Cabecera'
,p_parent_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>90
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12857408016396834)
,p_plug_name=>'Detalle'
,p_parent_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_region_css_classes=>'ig-detalle'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>100
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12857668087396836)
,p_plug_name=>'Detalle_Orden_Compra'
,p_region_name=>'Detalle_Orden_Compra'
,p_parent_plug_id=>wwv_flow_imp.id(12857408016396834)
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select ID_DETALLE_OC,',
'       ID_ORDEN_COMPRA,',
'       ID_PRODUCTO,',
'       CANTIDAD,',
'       PRECIO_UNITARIO,',
'       TOTAL_DETALLE',
'  from DETALLE_ORDEN_COMPRA',
'  WHERE ID_ORDEN_COMPRA = :P72_ID_ORDEN_COMPRA;'))
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
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12857820966396838)
,p_name=>'ID_DETALLE_OC'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_DETALLE_OC'
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
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12857998459396839)
,p_name=>'ID_ORDEN_COMPRA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_ORDEN_COMPRA'
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
,p_duplicate_value=>true
,p_include_in_export=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12858024446396840)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_POPUP_LOV'
,p_heading=>'Producto'
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
,p_is_required=>true
,p_lov_type=>'SHARED'
,p_lov_id=>wwv_flow_imp.id(16414606219603120)
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
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12858149487396841)
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
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12858206654396842)
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
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12858399083396843)
,p_name=>'TOTAL_DETALLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TOTAL_DETALLE'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Total Detalle'
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
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12858498692396844)
,p_name=>'APEX$ROW_ACTION'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_display_sequence=>20
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12858515429396845)
,p_name=>'APEX$ROW_SELECTOR'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(12857778307396837)
,p_internal_uid=>12857778307396837
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
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(12925206653948399)
,p_interactive_grid_id=>wwv_flow_imp.id(12857778307396837)
,p_static_id=>'129253'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(12925488592948399)
,p_report_id=>wwv_flow_imp.id(12925206653948399)
,p_view_type=>'GRID'
,p_stretch_columns=>true
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12925935125948400)
,p_view_id=>wwv_flow_imp.id(12925488592948399)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(12857820966396838)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12926838919948401)
,p_view_id=>wwv_flow_imp.id(12925488592948399)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(12857998459396839)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12927767970948402)
,p_view_id=>wwv_flow_imp.id(12925488592948399)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(12858024446396840)
,p_is_visible=>true
,p_is_frozen=>false
,p_width=>978.5
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12928628460948403)
,p_view_id=>wwv_flow_imp.id(12925488592948399)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(12858149487396841)
,p_is_visible=>true
,p_is_frozen=>false
,p_width=>183
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12929573759948405)
,p_view_id=>wwv_flow_imp.id(12925488592948399)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(12858206654396842)
,p_is_visible=>true
,p_is_frozen=>false
,p_width=>199.5
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12930405041948406)
,p_view_id=>wwv_flow_imp.id(12925488592948399)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(12858399083396843)
,p_is_visible=>true
,p_is_frozen=>false
,p_width=>306
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12932477704964492)
,p_view_id=>wwv_flow_imp.id(12925488592948399)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(12858498692396844)
,p_is_visible=>true
,p_is_frozen=>true
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12857570897396835)
,p_plug_name=>'Totalizador'
,p_parent_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>110
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12898882718928784)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_03'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12899200967928784)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(12898882718928784)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12900632900928785)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(12898882718928784)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Eliminar'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>'P72_ID_ORDEN_COMPRA'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12901022592928785)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(12898882718928784)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Guardar'
,p_button_position=>'NEXT'
,p_button_condition=>'P72_ID_ORDEN_COMPRA'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12901430655928785)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(12898882718928784)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'NEXT'
,p_button_condition=>'P72_ID_ORDEN_COMPRA'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12893222001928779)
,p_name=>'P72_ID_ORDEN_COMPRA'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_item_source_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_source=>'ID_ORDEN_COMPRA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12893653577928780)
,p_name=>'P72_ID_PROVEEDOR'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(12857379693396833)
,p_item_source_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_prompt=>'Proveedor'
,p_source=>'ID_PROVEEDOR'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'PROVEEDORES.NOMBRE'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ',
'  p.primer_nombre || '' '' || p.primer_apellido  AS display_value,',
'  pr.id_persona                             AS return_value',
'FROM proveedores pr',
'JOIN personas p ',
'     ON p.id_persona = pr.id_persona',
'ORDER BY p.primer_nombre, p.primer_apellido;',
''))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12894094876928781)
,p_name=>'P72_FECHA_ORDEN'
,p_source_data_type=>'DATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(12857379693396833)
,p_item_source_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT CURRENT_TIMESTAMP AT TIME ZONE ''America/Argentina/Buenos_Aires'' AS FECHA_HORA_ARG',
'FROM dual;'))
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Fecha Orden'
,p_source=>'FECHA_ORDEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>32
,p_cMaxlength=>255
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12894407915928782)
,p_name=>'P72_ESTADO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(12857379693396833)
,p_item_source_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_item_default=>'B'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12894828508928782)
,p_name=>'P72_OBSERVACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(12857379693396833)
,p_item_source_plug_id=>wwv_flow_imp.id(12892991332928779)
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12895638671928782)
,p_name=>'P72_ID_OFICINA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(12857379693396833)
,p_item_source_plug_id=>wwv_flow_imp.id(12892991332928779)
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
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12896012610928783)
,p_name=>'P72_TOTAL_ORDEN'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(12857570897396835)
,p_item_source_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_prompt=>'Total Orden'
,p_source=>'TOTAL_ORDEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12939546869107107)
,p_name=>'P72_ID_EMPLEADO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(12857379693396833)
,p_item_source_plug_id=>wwv_flow_imp.id(12892991332928779)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_EMPLEADO',
'FROM EMPLEADOS',
'WHERE UPPER(CODIGO_USUARIO) = UPPER(:APP_USER)'))
,p_item_default_type=>'SQL_QUERY'
,p_source=>'ID_EMPLEADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14819631506450421)
,p_name=>'P72_COD_USUARIO'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(12857379693396833)
,p_item_default=>':APP_USER'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_prompt=>'Usuario'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12899313531928784)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(12899200967928784)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12900124184928785)
,p_event_id=>wwv_flow_imp.id(12899313531928784)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12858721176396847)
,p_name=>'Carga de Productos'
,p_event_sequence=>20
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(12857668087396836)
,p_triggering_element=>'ID_PRODUCTO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12858817522396848)
,p_event_id=>wwv_flow_imp.id(12858721176396847)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/*select 1, cat.precio, cat.precio ',
'into :CANTIDAD,:PRECIO_UNITARIO, :TOTAL_DETALLE',
'from productos pro, PRODUCTO_PROVEEDORES  cat',
'    where pro.id_producto = cat.id_producto',
'    and cat.ID_PERSONA = :P72_ID_PROVEEDOR',
'    and pro.id_producto = :ID_PRODUCTO;*/',
'',
'SELECT 1, vv.PRECIO, vv.PRECIO',
'INTO   :CANTIDAD, :PRECIO_UNITARIO, :TOTAL_DETALLE',
'FROM   V_PRODUCTO_PROVEEDOR_VIGENTE vv',
'WHERE  vv.ID_PERSONA  = :P72_ID_PROVEEDOR',
'  AND  vv.ID_PRODUCTO = :ID_PRODUCTO',
'  AND  vv.VIGENCIA    = ''VIGENTE'';'))
,p_attribute_02=>'ID_PRODUCTO, P72_ID_PROVEEDOR'
,p_attribute_03=>'CANTIDAD,PRECIO_UNITARIO,TOTAL_DETALLE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12939124868107103)
,p_event_id=>wwv_flow_imp.id(12858721176396847)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12858910910396849)
,p_name=>'Totalizador'
,p_event_sequence=>30
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(12857668087396836)
,p_bind_type=>'bind'
,p_execution_type=>'DEBOUNCE'
,p_execution_time=>500
,p_execution_immediate=>false
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12939249793107104)
,p_event_id=>wwv_flow_imp.id(12858910910396849)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12859004555396850)
,p_event_id=>wwv_flow_imp.id(12858910910396849)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>':TOTAL_DETALLE := :CANTIDAD * :PRECIO_UNITARIO;'
,p_attribute_02=>'CANTIDAD,PRECIO_UNITARIO'
,p_attribute_03=>'TOTAL_DETALLE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12938964380107101)
,p_name=>'Recalcular Total IG'
,p_event_sequence=>40
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(12857668087396836)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'NATIVE_IG|REGION TYPE|interactivegridselectionchange'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12939063483107102)
,p_event_id=>wwv_flow_imp.id(12938964380107101)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14819706490450422)
,p_name=>'New'
,p_event_sequence=>50
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P72_ID_EMPLEADO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14819827642450423)
,p_event_id=>wwv_flow_imp.id(14819706490450422)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_name=>'COD_USUARIO'
,p_action=>'NATIVE_SET_VALUE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P72_COD_USUARIO'
,p_attribute_01=>'SQL_STATEMENT'
,p_attribute_03=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select CODIGO_USUARIO',
'from EMPLEADOS',
'where ID_EMPLEADO = :P72_ID_EMPLEADO'))
,p_attribute_07=>'P72_ID_EMPLEADO'
,p_attribute_08=>'Y'
,p_attribute_09=>'N'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14820123896450426)
,p_name=>'REFRESCAR'
,p_event_sequence=>60
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P72_ID_PROVEEDOR'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14820254359450427)
,p_event_id=>wwv_flow_imp.id(14820123896450426)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'REFRESH'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(12857668087396836)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20237728863558348)
,p_process_sequence=>1
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'CHK_LIMITE_MONTO_MENSUAL'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_limite     NUMBER;',
'  l_acumulado  NUMBER;',
'  l_disponible NUMBER;',
'  l_total_oc   NUMBER := NVL(:P72_TOTAL_ORDEN, 0);',
'BEGIN',
'  l_limite := FN_GET_LIMITE_OC_MENSUAL(',
'    TO_CHAR(SYSDATE, ''MM''),',
'    TO_CHAR(SYSDATE, ''YYYY'')',
'  );',
'',
unistr('  -- Sin l\00EDmite configurado \2192 no validar'),
'  IF l_limite IS NULL THEN',
'    RETURN;',
'  END IF;',
'',
'  -- Acumulado del mes, excluye anuladas y la OC actual',
'  SELECT NVL(SUM(TOTAL_ORDEN), 0)',
'  INTO   l_acumulado',
'  FROM   ORDENES_COMPRA',
'  WHERE  TRUNC(FECHA_ORDEN, ''MM'') = TRUNC(SYSDATE, ''MM'')',
'    AND  ESTADO != ''A''',
'    AND  ID_ORDEN_COMPRA != NVL(:P72_ID_ORDEN_COMPRA, -1);',
'',
'  l_disponible := l_limite - l_acumulado;',
'',
'  IF (l_acumulado + l_total_oc) > l_limite THEN',
'    APEX_ERROR.ADD_ERROR(',
unistr('      P_MESSAGE          => ''L\00EDmite mensual de OC superado.''          ||'),
unistr('                            '' L\00EDmite: $''      || TO_CHAR(l_limite,    ''FM999G999G990'') ||'),
'                            '' | Acumulado: $'' || TO_CHAR(l_acumulado, ''FM999G999G990'') ||',
'                            '' | Esta OC: $''   || TO_CHAR(l_total_oc,  ''FM999G999G990'') ||',
'                            '' | Disponible: $''|| TO_CHAR(l_disponible,''FM999G999G990''),',
'      P_DISPLAY_LOCATION => APEX_ERROR.C_INLINE_IN_NOTIFICATION',
'    );',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(12901430655928785)
,p_internal_uid=>20237728863558348
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12902279129928785)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(12892991332928779)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Orden de Compra'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>12902279129928785
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12858658201396846)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(12857668087396836)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Detalle_Orden_Compra - Save Interactive Grid Data'
,p_attribute_01=>'PLSQL_CODE'
,p_attribute_04=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    case:APEX$ROW_STATUS',
'        WHEN ''C'' THEN',
'            INSERT INTO DETALLE_ORDEN_COMPRA(ID_ORDEN_COMPRA,ID_PRODUCTO,CANTIDAD,PRECIO_UNITARIO,TOTAL_DETALLE)',
'            VALUES (:P72_ID_ORDEN_COMPRA,:ID_PRODUCTO,:CANTIDAD,:PRECIO_UNITARIO,:TOTAL_DETALLE);',
'        WHEN ''U'' THEN',
'            UPDATE DETALLE_ORDEN_COMPRA',
'            SET ID_PRODUCTO = :ID_PRODUCTO,',
'                CANTIDAD = :CANTIDAD,',
'                PRECIO_UNITARIO = :PRECIO_UNITARIO,',
'                TOTAL_DETALLE = :TOTAL_DETALLE',
'            WHERE ID_ORDEN_COMPRA = :P72_ID_ORDEN_COMPRA;',
'        WHEN ''D'' THEN',
'            DELETE DETALLE_ORDEN_COMPRA WHERE ID_DETALLE_OC = :ID_DETALLE_OC;',
'    END CASE;',
'END;'))
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>12858658201396846
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12902660782928785)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>12902660782928785
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12901868074928785)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(12892991332928779)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Orden de Compra'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>12901868074928785
);
wwv_flow_imp.component_end;
end;
/

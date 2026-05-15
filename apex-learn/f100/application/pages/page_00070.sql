prompt --application/pages/page_00070
begin
--   Manifest
--     PAGE: 00070
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
 p_id=>70
,p_name=>'Proceso de Compras'
,p_alias=>'ORDEN-DE-COMPRAS'
,p_page_mode=>'MODAL'
,p_step_title=>'Proceso de Compras'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function recalculaImporte() {',
'    var model = apex.region("Detalle_Compra").widget().interactiveGrid("getCurrentView").model;',
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
'    apex.item(''P70_TOTAL_COMPROBANTE'').setValue(Math.round(n_total));',
'',
'    //apex.item(''P54_TOTAL'').setValue(n_total.toFixed(2));',
'}',
'function applyMask(input) {',
unistr('    // Solo n\00FAmeros'),
'    let value = input.value.replace(/\D/g, '''');',
'',
unistr('    // Limitar a 13 d\00EDgitos m\00E1ximo (3+3+7)'),
'    value = value.substring(0, 13);',
'',
unistr('    // Aplicar m\00E1scara 000-000-0000000'),
'    if (value.length > 6) {',
'        value = value.substring(0, 3) + ''-'' + value.substring(3, 6) + ''-'' + value.substring(6);',
'    } else if (value.length > 3) {',
'        value = value.substring(0, 3) + ''-'' + value.substring(3);',
'    }',
'',
'    input.value = value;',
'}',
''))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.campo-grande-negrita input {',
'  font-size: 24px;',
'  font-weight: bold;',
'}'))
,p_page_template_options=>'#DEFAULT#:ui-dialog--stretch'
,p_dialog_chained=>'N'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'02'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12817469420386513)
,p_plug_name=>'Proceso de Compras'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'COMPROBANTES_PROVEEDOR'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12856286435396822)
,p_plug_name=>'Cabecera'
,p_parent_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>160
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12856338085396823)
,p_plug_name=>'Detalle'
,p_parent_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>170
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13113560524342804)
,p_plug_name=>'Detalle_Compra'
,p_region_name=>'Detalle_Compra'
,p_parent_plug_id=>wwv_flow_imp.id(12856338085396823)
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_plug_display_point=>'SUB_REGIONS'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select DET.ID_ORDEN_COMPRA,DET.ID_PRODUCTO, PR.NOMBRE, DET.CANTIDAD, DET.PRECIO_UNITARIO,DET.TOTAL_DETALLE ',
'from ORDENES_COMPRA CAB, DETALLE_ORDEN_COMPRA DET, PRODUCTOS PR',
'WHERE CAB.ID_ORDEN_COMPRA = DET.ID_ORDEN_COMPRA',
'AND PR.ID_PRODUCTO = DET.ID_PRODUCTO',
'AND DET.ID_ORDEN_COMPRA = :P70_ID_ORDEN_COMPRA;'))
,p_plug_source_type=>'NATIVE_IG'
,p_ajax_items_to_submit=>'P70_ID_ORDEN_COMPRA'
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
 p_id=>wwv_flow_imp.id(13113769565342806)
,p_name=>'APEX$ROW_SELECTOR'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13113803778342807)
,p_name=>'APEX$ROW_ACTION'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_display_sequence=>20
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13113906353342808)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Producto'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>30
,p_value_alignment=>'CENTER'
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
 p_id=>wwv_flow_imp.id(13114074093342809)
,p_name=>'NOMBRE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'NOMBRE'
,p_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Nombre'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>40
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>true
,p_max_length=>255
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
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13114131982342810)
,p_name=>'CANTIDAD'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cantidad'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>50
,p_value_alignment=>'CENTER'
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
 p_id=>wwv_flow_imp.id(13114252164342811)
,p_name=>'PRECIO_UNITARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PRECIO_UNITARIO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Precio Unitario'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>60
,p_value_alignment=>'CENTER'
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
 p_id=>wwv_flow_imp.id(13114343972342812)
,p_name=>'ID_ORDEN_COMPRA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_ORDEN_COMPRA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>70
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>true
,p_duplicate_value=>true
,p_include_in_export=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13114437524342813)
,p_name=>'TOTAL_DETALLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TOTAL_DETALLE'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Total Detalle'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>80
,p_value_alignment=>'CENTER'
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
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(13113682548342805)
,p_internal_uid=>13113682548342805
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
 p_id=>wwv_flow_imp.id(13129054377331468)
,p_interactive_grid_id=>wwv_flow_imp.id(13113682548342805)
,p_static_id=>'131291'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(13129274609331469)
,p_report_id=>wwv_flow_imp.id(13129054377331468)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13130177349331471)
,p_view_id=>wwv_flow_imp.id(13129274609331469)
,p_display_seq=>0
,p_column_id=>wwv_flow_imp.id(13113803778342807)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13131082702331472)
,p_view_id=>wwv_flow_imp.id(13129274609331469)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(13113906353342808)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13131919271331473)
,p_view_id=>wwv_flow_imp.id(13129274609331469)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(13114074093342809)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13132823203331474)
,p_view_id=>wwv_flow_imp.id(13129274609331469)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(13114131982342810)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13133793865331475)
,p_view_id=>wwv_flow_imp.id(13129274609331469)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(13114252164342811)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13134684773331476)
,p_view_id=>wwv_flow_imp.id(13129274609331469)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(13114343972342812)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13135592660331477)
,p_view_id=>wwv_flow_imp.id(13129274609331469)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(13114437524342813)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12856464709396824)
,p_plug_name=>'Totalizador'
,p_parent_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>180
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12828626186386518)
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
 p_id=>wwv_flow_imp.id(12829002053386519)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(12828626186386518)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancel'
,p_button_position=>'CLOSE'
,p_button_alignment=>'RIGHT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12830447368386519)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(12828626186386518)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Delete'
,p_button_position=>'DELETE'
,p_button_alignment=>'RIGHT'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>'P70_ID_COMPROBANTE'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12830832716386519)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(12828626186386518)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Apply Changes'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_button_condition=>'P70_ID_COMPROBANTE'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12831283289386520)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(12828626186386518)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Create'
,p_button_position=>'NEXT'
,p_button_alignment=>'RIGHT'
,p_button_condition=>'P70_ID_COMPROBANTE'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12817801655386514)
,p_name=>'P70_ID_COMPROBANTE'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Id Comprobante'
,p_source=>'ID_COMPROBANTE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12818276528386514)
,p_name=>'P70_TIPO_COMPROBANTE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Tipo Comprobante'
,p_source=>'TIPO_COMPROBANTE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:FA;FA'
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
 p_id=>wwv_flow_imp.id(12818640981386514)
,p_name=>'P70_ID_PROVEEDOR'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Proveedor'
,p_source=>'ID_PROVEEDOR'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
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
,p_cSize=>30
,p_begin_on_new_line=>'N'
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12819012850386514)
,p_name=>'P70_FECHA_EMISION'
,p_source_data_type=>'DATE'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Fecha Emision'
,p_source=>'FECHA_EMISION'
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
 p_id=>wwv_flow_imp.id(12819437179386514)
,p_name=>'P70_NRO_COMPROBANTE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Nro Comprobante'
,p_source=>'NRO_COMPROBANTE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>50
,p_tag_attributes=>'oninput="applyMask(this)"'
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
 p_id=>wwv_flow_imp.id(12819813318386515)
,p_name=>'P70_NRO_TIMBRADO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Nro Timbrado'
,p_source=>'NRO_TIMBRADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>20
,p_begin_on_new_line=>'N'
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
 p_id=>wwv_flow_imp.id(12820244208386515)
,p_name=>'P70_FECHA_INICIO_TIMBRADO'
,p_source_data_type=>'DATE'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Fecha Inicio Timbrado'
,p_source=>'FECHA_INICIO_TIMBRADO'
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
 p_id=>wwv_flow_imp.id(12820678233386515)
,p_name=>'P70_FECHA_FIN_TIMBRADO'
,p_source_data_type=>'DATE'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Fecha Fin Timbrado'
,p_source=>'FECHA_FIN_TIMBRADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>32
,p_cMaxlength=>255
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
 p_id=>wwv_flow_imp.id(12821087087386515)
,p_name=>'P70_MONEDA'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(12856464709396824)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Moneda'
,p_source=>'MONEDA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>10
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12821426314386515)
,p_name=>'P70_TIPO_CAMBIO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(12856464709396824)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Tipo Cambio'
,p_source=>'TIPO_CAMBIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_begin_on_new_line=>'N'
,p_begin_on_new_field=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12821886557386515)
,p_name=>'P70_TOTAL_COMPROBANTE'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(12856464709396824)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Total Comprobante'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL_COMPROBANTE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_grid_column=>9
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12822287091386516)
,p_name=>'P70_ID_OFICINA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12822604680386516)
,p_name=>'P70_ID_ORDEN_COMPRA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_prompt=>'Orden Compra'
,p_source=>'ID_ORDEN_COMPRA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_lov=>'select id_orden_compra, id_orden_compra as orden from ORDENES_COMPRA where estado = ''P'''
,p_lov_display_null=>'YES'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12823381781386516)
,p_name=>'P70_ID_FAC_ORIGEN'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(12856464709396824)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
,p_source=>'ID_FAC_ORIGEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12823779520386516)
,p_name=>'P70_OBSERVACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>150
,p_item_plug_id=>wwv_flow_imp.id(12856286435396822)
,p_item_source_plug_id=>wwv_flow_imp.id(12817469420386513)
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
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12829153714386519)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(12829002053386519)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12829951557386519)
,p_event_id=>wwv_flow_imp.id(12829153714386519)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12943606605107148)
,p_name=>'Carga de Detalle por Orden'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P70_ID_ORDEN_COMPRA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12943723368107149)
,p_event_id=>wwv_flow_imp.id(12943606605107148)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(13113560524342804)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(16598047857211748)
,p_name=>'Carga de ID proveedor'
,p_event_sequence=>40
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P70_ID_ORDEN_COMPRA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(16598115173211749)
,p_event_id=>wwv_flow_imp.id(16598047857211748)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'SET PROVEEDOR'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT OC.ID_PROVEEDOR --p.primer_nombre || '' '' || p.primer_apellido',
'INTO :P70_ID_PROVEEDOR',
'FROM ordenes_compra oc',
'JOIN personas p',
'  ON p.ID_PERSONA = oc.ID_PROVEEDOR',
'WHERE oc.ID_ORDEN_COMPRA = :P70_ID_ORDEN_COMPRA;'))
,p_attribute_02=>'P70_ID_ORDEN_COMPRA'
,p_attribute_03=>'P70_ID_PROVEEDOR'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(13114568324342814)
,p_name=>'TOTAL_IG'
,p_event_sequence=>50
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(13113560524342804)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'NATIVE_IG|REGION TYPE|interactivegridselectionchange'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13114604343342815)
,p_event_id=>wwv_flow_imp.id(13114568324342814)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(13114700466342816)
,p_name=>'New_2'
,p_event_sequence=>60
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(13113560524342804)
,p_triggering_element=>'CANTIDAD,PRECIO_UNITARIO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13114848316342817)
,p_event_id=>wwv_flow_imp.id(13114700466342816)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12832039351386520)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(12817469420386513)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Orden de Compras'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>12832039351386520
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13115355328342822)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Detalle Factura Cursor'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    CURSOR CUR_DETALLE IS',
'        SELECT DET.ID_ORDEN_COMPRA,',
'               DET.ID_PRODUCTO,',
'               DET.CANTIDAD,',
'               DET.PRECIO_UNITARIO,',
'               DET.TOTAL_DETALLE',
'        FROM ORDENES_COMPRA CAB,',
'             DETALLE_ORDEN_COMPRA DET,',
'             PRODUCTOS PR',
'        WHERE CAB.ID_ORDEN_COMPRA = DET.ID_ORDEN_COMPRA',
'          AND PR.ID_PRODUCTO = DET.ID_PRODUCTO',
'          AND DET.ID_ORDEN_COMPRA = :P70_ID_ORDEN_COMPRA;',
'',
'    REG_DET CUR_DETALLE%ROWTYPE;',
'BEGIN',
'    OPEN CUR_DETALLE;',
'    LOOP',
'        FETCH CUR_DETALLE INTO REG_DET;',
'        EXIT WHEN CUR_DETALLE%NOTFOUND;',
'',
'        INSERT INTO DETALLE_COMPROBANTE_PROV (',
'            ID_COMPROBANTE,',
'            ID_PRODUCTO,',
'            CANTIDAD,',
'            PRECIO_UNITARIO,',
'            TOTAL',
'        ) VALUES (',
unistr('            :P70_ID_COMPROBANTE, -- este debe estar definido en la p\00E1gina'),
'            REG_DET.ID_PRODUCTO,',
'            REG_DET.CANTIDAD,',
'            REG_DET.PRECIO_UNITARIO,',
'            REG_DET.TOTAL_DETALLE',
'        );',
'',
'    END LOOP;',
'    CLOSE CUR_DETALLE;',
'',
'    apex_application.g_print_success_message := ',
unistr('        ''Se gener\00F3 el comprobante correctamente a partir de la orden N\00B0 '' || :P70_ID_ORDEN_COMPRA;'),
'END;',
''))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(12831283289386520)
,p_internal_uid=>13115355328342822
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13113340764342802)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(13113560524342804)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Detalle_Compra - Save Interactive Grid Data'
,p_attribute_01=>'PLSQL_CODE'
,p_attribute_04=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'    case:APEX$ROW_STATUS',
'        WHEN ''C'' THEN',
'            INSERT INTO DETALLE_COMPROBANTE_PROV(ID_COMPROBANTE,ID_PRODUCTO,CANTIDAD,PRECIO_UNITARIO,TOTAL)',
'            VALUES (:P70_ID_COMPROBANTE,:ID_PRODUCTO,:CANTIDAD,:PRECIO_UNITARIO,:TOTAL_DETALLE);',
'        WHEN ''U'' THEN',
'            UPDATE DETALLE_COMPROBANTE_PROV',
'            SET ID_PRODUCTO = :ID_PRODUCTO,',
'                CANTIDAD = :CANTIDAD,',
'                PRECIO_UNITARIO = :PRECIO_UNITARIO,',
'                TOTAL = :TOTAL_DETALLE',
'            WHERE ID_COMPROBANTE = :P70_ID_COMPROBANTE;',
'        WHEN ''D'' THEN',
'            DELETE DETALLE_COMPROBANTE_PROV WHERE ID_COMPROBANTE = :P70_ID_COMPROBANTE;',
'    END CASE;',
'END;'))
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(12831283289386520)
,p_internal_uid=>13113340764342802
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13115418544342823)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Actualiza Factura'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
' UPDATE TALONARIOS',
'    SET NRO_ACTUAL = NRO_ACTUAL +1',
'    WHERE TIPO_COMPROBANTE = :P70_TIPO_COMPROBANTE;',
'    COMMIT;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>13115418544342823
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12832485573386520)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>12832485573386520
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12831697437386520)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(12817469420386513)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Orden de Compras'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>12831697437386520
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12943058829107142)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Carga de Comprobante'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT FN_OBTENER_COMPROBANTE(:P70_ID_OFICINA, :P70_TIPO_COMPROBANTE) ',
'INTO :P70_NRO_COMPROBANTE FROM DUAL;'))
,p_process_clob_language=>'PLSQL'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_internal_uid=>12943058829107142
);
wwv_flow_imp.component_end;
end;
/

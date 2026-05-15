prompt --application/pages/page_00112
begin
--   Manifest
--     PAGE: 00112
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
 p_id=>112
,p_name=>'Detalle Orden de Compra'
,p_alias=>'DETALLE-ORDEN-DE-COMPRA'
,p_page_mode=>'MODAL'
,p_step_title=>'Detalle Orden de Compra'
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
,p_page_component_map=>'21'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(33461481782174084)
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
 p_id=>wwv_flow_imp.id(20606135621469410)
,p_plug_name=>'Recepcion'
,p_parent_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(33425870142642138)
,p_plug_name=>'Cabecera'
,p_parent_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>90
,p_location=>null
,p_plug_read_only_when_type=>'ALWAYS'
,p_ai_enabled=>false
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(33425898465642139)
,p_plug_name=>'Detalle'
,p_parent_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_region_css_classes=>'ig-detalle'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>100
,p_location=>null
,p_ai_enabled=>false
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(33426158536642141)
,p_plug_name=>'Detalle_Orden_Compra'
,p_region_name=>'Detalle_Orden_Compra'
,p_parent_plug_id=>wwv_flow_imp.id(33425898465642139)
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
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
'  WHERE ID_ORDEN_COMPRA = :P112_ID_ORDEN_COMPRA;'))
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
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(20605336679469402)
,p_name=>'ID_DETALLE_OC'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_DETALLE_OC'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>10
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
 p_id=>wwv_flow_imp.id(20605496419469403)
,p_name=>'ID_ORDEN_COMPRA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_ORDEN_COMPRA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>20
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
 p_id=>wwv_flow_imp.id(20605581588469404)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_SELECT_LIST'
,p_heading=>'Producto'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>30
,p_value_alignment=>'LEFT'
,p_is_required=>true
,p_lov_type=>'SHARED'
,p_lov_id=>wwv_flow_imp.id(11765368439189441)
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
 p_id=>wwv_flow_imp.id(20605634840469405)
,p_name=>'CANTIDAD'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cantidad'
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
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(20605793350469406)
,p_name=>'PRECIO_UNITARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PRECIO_UNITARIO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Precio Unitario'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>50
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
 p_id=>wwv_flow_imp.id(20605869698469407)
,p_name=>'TOTAL_DETALLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TOTAL_DETALLE'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Total Detalle'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>60
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
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(20605292104469401)
,p_internal_uid=>20605292104469401
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
,p_download_formats=>'CSV:HTML:XLSX:PDF'
,p_enable_mail_download=>true
,p_fixed_header=>'PAGE'
,p_show_icon_view=>false
,p_show_detail_view=>false
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(20611161273470301)
,p_interactive_grid_id=>wwv_flow_imp.id(20605292104469401)
,p_static_id=>'206112'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(20611378194470301)
,p_report_id=>wwv_flow_imp.id(20611161273470301)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(20611801053470303)
,p_view_id=>wwv_flow_imp.id(20611378194470301)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(20605336679469402)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(20612728248470305)
,p_view_id=>wwv_flow_imp.id(20611378194470301)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(20605496419469403)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(20613670115470307)
,p_view_id=>wwv_flow_imp.id(20611378194470301)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(20605581588469404)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(20614590108470309)
,p_view_id=>wwv_flow_imp.id(20611378194470301)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(20605634840469405)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(20615416410470310)
,p_view_id=>wwv_flow_imp.id(20611378194470301)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(20605793350469406)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(20616342506470311)
,p_view_id=>wwv_flow_imp.id(20611378194470301)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(20605869698469407)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(33426061346642140)
,p_plug_name=>'Totalizador'
,p_parent_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>110
,p_location=>null
,p_ai_enabled=>false
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(33467373168174089)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>20
,p_plug_display_point=>'REGION_POSITION_03'
,p_ai_enabled=>false
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20581234037245327)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(33467373168174089)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20581615034245327)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(33467373168174089)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Eliminar'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition_type=>'NEVER'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20606293797469411)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(33467373168174089)
,p_button_name=>'RECHAZAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>unistr('\2716 Rechazar')
,p_button_position=>'NEXT'
,p_button_condition=>'P112_ESTADO'
,p_button_condition2=>'B'
,p_button_condition_type=>'VAL_OF_ITEM_IN_COND_EQ_COND2'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20606349507469412)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(33467373168174089)
,p_button_name=>'APROBAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>unistr('\2714 Aprobar')
,p_button_position=>'NEXT'
,p_button_condition=>'P112_ESTADO'
,p_button_condition2=>'B'
,p_button_condition_type=>'VAL_OF_ITEM_IN_COND_EQ_COND2'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20582085503245327)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(33467373168174089)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Guardar'
,p_button_position=>'NEXT'
,p_button_condition_type=>'NEVER'
,p_database_action=>'UPDATE'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(20582498439245328)
,p_button_sequence=>50
,p_button_plug_id=>wwv_flow_imp.id(33467373168174089)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'NEXT'
,p_button_condition_type=>'NEVER'
,p_database_action=>'INSERT'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20485024559037141)
,p_name=>'P112_ID_APROBADOR'
,p_source_data_type=>'NUMBER'
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(20606135621469410)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_EMPLEADO ',
'FROM EMPLEADOS',
'WHERE CODIGO_USUARIO = :APP_USER'))
,p_item_default_type=>'SQL_QUERY'
,p_source=>'ID_APROBADOR'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20485134289037142)
,p_name=>'P112_FECHA_APROBACION'
,p_source_data_type=>'DATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(20606135621469410)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_item_default=>'SYSDATE'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_prompt=>unistr('Fecha Aprobaci\00F3n')
,p_source=>'FECHA_APROBACION'
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
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20485241888037143)
,p_name=>'P112_MOTIVO_RECHAZO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(20606135621469410)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_prompt=>'Motivo'
,p_source=>'MOTIVO_RECHAZO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>30
,p_cMaxlength=>500
,p_cHeight=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20606002127469409)
,p_name=>'P112_CODIGO_USUARIO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(20606135621469410)
,p_item_default=>':APP_USER'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_prompt=>'Codigo Usuario'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_read_only_when_type=>'ALWAYS'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33462257213174089)
,p_name=>'P112_ID_ORDEN_COMPRA'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_source=>'ID_ORDEN_COMPRA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33464496377174095)
,p_name=>'P112_ID_PROVEEDOR'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(33425870142642138)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
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
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33464937676174096)
,p_name=>'P112_FECHA_ORDEN'
,p_source_data_type=>'DATE'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(33425870142642138)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
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
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33465250715174097)
,p_name=>'P112_ESTADO'
,p_source_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(33425870142642138)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
,p_prompt=>'Estado'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'ORDEN.COMPRA.ESTADO'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('SELECT ''Borrador (pendiente aprobaci\00F3n)'' AS DISPLAY_VALUE, ''B'' AS RETURN_VALUE FROM DUAL UNION ALL'),
'SELECT ''Rechazada''                       AS DISPLAY_VALUE, ''X'' AS RETURN_VALUE FROM DUAL UNION ALL',
unistr('SELECT ''Pendiente recepci\00F3n''             AS DISPLAY_VALUE, ''P'' AS RETURN_VALUE FROM DUAL UNION ALL'),
unistr('SELECT ''Recepci\00F3n parcial''               AS DISPLAY_VALUE, ''R'' AS RETURN_VALUE FROM DUAL UNION ALL'),
'SELECT ''Completada''                      AS DISPLAY_VALUE, ''C'' AS RETURN_VALUE FROM DUAL UNION ALL',
'SELECT ''Anulada''                         AS DISPLAY_VALUE, ''A'' AS RETURN_VALUE FROM DUAL'))
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_read_only_when_type=>'ALWAYS'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33465671308174097)
,p_name=>'P112_OBSERVACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(33425870142642138)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
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
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33466481471174097)
,p_name=>'P112_ID_OFICINA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(33425870142642138)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
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
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33476277548174109)
,p_name=>'P112_TOTAL_ORDEN'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(33426061346642140)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
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
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(33510389668352422)
,p_name=>'P112_ID_EMPLEADO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>70
,p_item_plug_id=>wwv_flow_imp.id(33425870142642138)
,p_item_source_plug_id=>wwv_flow_imp.id(33461481782174084)
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
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(35390474305695736)
,p_name=>'P112_COD_USUARIO'
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(33425870142642138)
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
,p_ai_enabled=>false
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(20584720494245338)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(20581234037245327)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20585248984245338)
,p_event_id=>wwv_flow_imp.id(20584720494245338)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(20585643614245338)
,p_name=>'Carga de Productos'
,p_event_sequence=>20
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(33426158536642141)
,p_triggering_element=>'ID_PRODUCTO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20586164527245339)
,p_event_id=>wwv_flow_imp.id(20585643614245338)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/*select 1, cat.precio, cat.precio ',
'into :CANTIDAD,:PRECIO_UNITARIO, :TOTAL_DETALLE',
'from productos pro, PRODUCTO_PROVEEDORES  cat',
'    where pro.id_producto = cat.id_producto',
'    and cat.ID_PERSONA = :P112_ID_PROVEEDOR',
'    and pro.id_producto = :ID_PRODUCTO;*/',
'',
'SELECT 1, vv.PRECIO, vv.PRECIO',
'INTO   :CANTIDAD, :PRECIO_UNITARIO, :TOTAL_DETALLE',
'FROM   V_PRODUCTO_PROVEEDOR_VIGENTE vv',
'WHERE  vv.ID_PERSONA  = :P112_ID_PROVEEDOR',
'  AND  vv.ID_PRODUCTO = :ID_PRODUCTO',
'  AND  vv.VIGENCIA    = ''VIGENTE'';'))
,p_attribute_02=>'ID_PRODUCTO, P112_ID_PROVEEDOR'
,p_attribute_03=>'CANTIDAD,PRECIO_UNITARIO,TOTAL_DETALLE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20586699485245339)
,p_event_id=>wwv_flow_imp.id(20585643614245338)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(20587996160245339)
,p_name=>'Totalizador'
,p_event_sequence=>30
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(33426158536642141)
,p_bind_type=>'bind'
,p_execution_type=>'DEBOUNCE'
,p_execution_time=>500
,p_execution_immediate=>false
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20588933646245340)
,p_event_id=>wwv_flow_imp.id(20587996160245339)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20588409926245340)
,p_event_id=>wwv_flow_imp.id(20587996160245339)
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
 p_id=>wwv_flow_imp.id(20587023348245339)
,p_name=>'Recalcular Total IG'
,p_event_sequence=>40
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(33426158536642141)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'NATIVE_IG|REGION TYPE|interactivegridselectionchange'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20587524436245339)
,p_event_id=>wwv_flow_imp.id(20587023348245339)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(20583839281245337)
,p_name=>'New'
,p_event_sequence=>50
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P112_ID_EMPLEADO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20584336243245338)
,p_event_id=>wwv_flow_imp.id(20583839281245337)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_name=>'COD_USUARIO'
,p_action=>'NATIVE_SET_VALUE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P112_COD_USUARIO'
,p_attribute_01=>'SQL_STATEMENT'
,p_attribute_03=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select CODIGO_USUARIO',
'from EMPLEADOS',
'where ID_EMPLEADO = :P112_ID_EMPLEADO'))
,p_attribute_07=>'P112_ID_EMPLEADO'
,p_attribute_08=>'Y'
,p_attribute_09=>'N'
,p_wait_for_result=>'Y'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(20589331238245340)
,p_name=>'REFRESCAR'
,p_event_sequence=>60
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P112_ID_PROVEEDOR'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(20589899482245340)
,p_event_id=>wwv_flow_imp.id(20589331238245340)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_name=>'REFRESH'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(33426158536642141)
,p_attribute_01=>'N'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20606517262469414)
,p_process_sequence=>1
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRC_VAL_NO_PROPIA_OC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_aprobador NUMBER;',
'BEGIN',
'  SELECT ID_EMPLEADO INTO l_aprobador',
'  FROM   EMPLEADOS',
'  WHERE  CODIGO_USUARIO = :APP_USER;',
'',
'  IF l_aprobador = :P112_ID_EMPLEADO THEN',
'    APEX_ERROR.ADD_ERROR(',
'      P_MESSAGE          => ''No puede aprobar o rechazar una orden de compra propia.'',',
'      P_DISPLAY_LOCATION => APEX_ERROR.C_INLINE_IN_NOTIFICATION',
'    );',
'  END IF;',
'EXCEPTION',
'  WHEN NO_DATA_FOUND THEN NULL;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(20606349507469412)
,p_internal_uid=>20606517262469414
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20606640874469415)
,p_process_sequence=>2
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRC_VAL_NO_PROPIA_OC_1'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_aprobador NUMBER;',
'BEGIN',
'  SELECT ID_EMPLEADO INTO l_aprobador',
'  FROM   EMPLEADOS',
'  WHERE  CODIGO_USUARIO = :APP_USER;',
'',
'  IF l_aprobador = :P112_ID_EMPLEADO THEN',
'    APEX_ERROR.ADD_ERROR(',
'      P_MESSAGE          => ''No puede aprobar o rechazar una orden de compra propia.'',',
'      P_DISPLAY_LOCATION => APEX_ERROR.C_INLINE_IN_NOTIFICATION',
'    );',
'  END IF;',
'EXCEPTION',
'  WHEN NO_DATA_FOUND THEN NULL;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(20606293797469411)
,p_internal_uid=>20606640874469415
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20606788406469416)
,p_process_sequence=>3
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRC_VAL_MOTIVO_RECHAZO'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  IF :P112_MOTIVO_RECHAZO IS NULL THEN',
'    APEX_ERROR.ADD_ERROR(',
'      P_MESSAGE          => ''El motivo de rechazo es obligatorio.'',',
'      P_DISPLAY_LOCATION => APEX_ERROR.C_INLINE_WITH_FIELD_AND_NOTIF,',
'      P_PAGE_ITEM_NAME   => ''P112_MOTIVO_RECHAZO''',
'    );',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(20606293797469411)
,p_internal_uid=>20606788406469416
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20606858657469417)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRC_APROBAR_OC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id_aprobador NUMBER;',
'BEGIN',
'  SELECT ID_EMPLEADO INTO l_id_aprobador',
'  FROM   EMPLEADOS',
'  WHERE  CODIGO_USUARIO = :APP_USER;',
'',
'  UPDATE ORDENES_COMPRA SET',
'    ESTADO           = ''P'',',
'    ID_APROBADOR     = l_id_aprobador,',
'    FECHA_APROBACION = SYSDATE',
'  WHERE ID_ORDEN_COMPRA = :P112_ID_ORDEN_COMPRA',
'    AND ESTADO          = ''B'';',
'',
'  IF SQL%ROWCOUNT = 0 THEN',
'    RAISE_APPLICATION_ERROR(-20001, ',
unistr('      ''La orden ya fue procesada o no est\00E1 disponible.'');'),
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(20606349507469412)
,p_internal_uid=>20606858657469417
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20606991300469418)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PRC_RECHAZAR_OC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_id_aprobador NUMBER;',
'BEGIN',
'  SELECT ID_EMPLEADO INTO l_id_aprobador',
'  FROM   EMPLEADOS',
'  WHERE  CODIGO_USUARIO = :APP_USER;',
'',
'  UPDATE ORDENES_COMPRA SET',
'    ESTADO           = ''X'',',
'    ID_APROBADOR     = l_id_aprobador,',
'    FECHA_APROBACION = SYSDATE,',
'    MOTIVO_RECHAZO   = :P112_MOTIVO_RECHAZO',
'  WHERE ID_ORDEN_COMPRA = :P112_ID_ORDEN_COMPRA',
'    AND ESTADO          = ''B'';',
'',
'  IF SQL%ROWCOUNT = 0 THEN',
'    RAISE_APPLICATION_ERROR(-20001, ',
unistr('      ''La orden ya fue procesada o no est\00E1 disponible.'');'),
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(20606293797469411)
,p_internal_uid=>20606991300469418
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20583019727245336)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>20583019727245336
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20569702438245314)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(33461481782174084)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Orden de Compra'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>20569702438245314
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00067
begin
--   Manifest
--     PAGE: 00067
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
 p_id=>67
,p_name=>'Proceso Ventas'
,p_alias=>'PROCESO-VENTAS'
,p_step_title=>'Proceso Ventas'
,p_autocomplete_on_off=>'OFF'
,p_javascript_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function recalculaImporte() {',
'    var model = apex.region("Detalle_V").widget().interactiveGrid("getCurrentView").model;',
'    var col_gl_amount = model.getFieldKey("TOTAL");',
'    var col_iva = model.getFieldKey("IVA_CALCULADO");',
'    var col_porcentaje = model.getFieldKey("PORCENTAJE");',
'',
'    var total_iva_5 = 0;',
'    var total_iva_10 = 0;',
'    var total_general = 0;',
'',
'    model.forEach(function(row) {',
'        var raw_total = row[col_gl_amount];',
'        var raw_iva = row[col_iva];',
'        var raw_porcentaje = row[col_porcentaje];',
'',
'        if (raw_total !== null && raw_total !== undefined) {',
'            var clean_total = raw_total',
'                .toString()',
'                .replace(/[^0-9,.-]/g, '''')',
'                .replace(/\./g, '''')',
'                .replace('','', ''.'');',
'',
'            var total = parseFloat(clean_total);',
'            var iva = parseFloat(raw_iva);',
'            var porcentaje = parseFloat(raw_porcentaje);',
'',
'            if (!isNaN(total)) {',
'                total_general += total;',
'            }',
'',
'            if (!isNaN(iva) && !isNaN(porcentaje)) {',
'                if (porcentaje === 5) {',
'                    total_iva_5 += iva;',
'                } else if (porcentaje === 10) {',
'                    total_iva_10 += iva;',
'                }',
'            }',
'',
'            console.log("Total: " + total);',
'            console.log("IVA: " + iva + " | %: " + porcentaje);',
'        }',
'    });',
'',
'    // Seteo en los items APEX',
'    apex.item(''P67_TOTAL_IVA_5'').setValue(Math.round(total_iva_5));',
'    apex.item(''P67_TOTAL_IVA_10'').setValue(Math.round(total_iva_10));',
'    apex.item(''P67_TOTAL_IVA'').setValue(Math.round(total_iva_5 + total_iva_10));',
'    apex.item(''P67_TOTAL_MONEDA_LOCAL'').setValue(Math.round(total_general));',
'}',
''))
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.campo-grande-negrita input {',
'  font-size: 24px;',
'  font-weight: bold;',
'}',
''))
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'02'
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_last_updated_on=>wwv_flow_imp.dz('20251204070357Z')
,p_created_by=>'WILLIAN'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12776927328370633)
,p_plug_name=>'Proceso Ventas'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_query_type=>'TABLE'
,p_query_table=>'COMPROBANTES'
,p_include_rowid_column=>false
,p_is_editable=>true
,p_edit_operations=>'i:u:d'
,p_lost_update_check_type=>'VALUES'
,p_plug_source_type=>'NATIVE_FORM'
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102201041Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12007879735524747)
,p_plug_name=>'Cabecera'
,p_parent_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>30
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123823Z')
,p_updated_on=>wwv_flow_imp.dz('20250601154011Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12007971917524748)
,p_plug_name=>'Detalle'
,p_parent_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>40
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123823Z')
,p_updated_on=>wwv_flow_imp.dz('20250601154011Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12008123551524750)
,p_plug_name=>'Detalle_Venta'
,p_region_name=>'Detalle_Venta'
,p_parent_plug_id=>wwv_flow_imp.id(12007971917524748)
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>10
,p_plug_display_point=>'SUB_REGIONS'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ',
'  ven.id_orden,',
'  pr.nombre,',
'  det.cantidad,',
'  det.precio_unitario,',
'  det.total',
'FROM detalle_orden det, ordenes_venta ven, productos pr',
'   WHERE ven.id_orden = det.id_orden',
'  AND det.id_producto = pr.id_producto',
'  AND VEN.ID_ORDEN = :P67_ID_ORDEN_VENTA;',
''))
,p_plug_source_type=>'NATIVE_IG'
,p_ajax_items_to_submit=>'P67_ID_ORDEN_VENTA'
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
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20250529123823Z')
,p_updated_on=>wwv_flow_imp.dz('20250602151148Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12855989535396819)
,p_name=>'CANTIDAD'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cantidad'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>40
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
,p_updated_on=>wwv_flow_imp.dz('20250601153141Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12856080733396820)
,p_name=>'PRECIO_UNITARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PRECIO_UNITARIO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Precio Unitario'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>50
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
,p_updated_on=>wwv_flow_imp.dz('20250601171605Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12856161679396821)
,p_name=>'TOTAL'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TOTAL'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Total'
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
,p_updated_on=>wwv_flow_imp.dz('20250601171605Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12940926604107121)
,p_name=>'APEX$ROW_ACTION'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_display_sequence=>20
,p_updated_on=>wwv_flow_imp.dz('20250601152853Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12941023211107122)
,p_name=>'APEX$ROW_SELECTOR'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
,p_updated_on=>wwv_flow_imp.dz('20250601152853Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12941203284107124)
,p_name=>'PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'NOMBRE'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_POPUP_LOV'
,p_heading=>'Producto'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>30
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
,p_max_length=>255
,p_lov_type=>'SQL_QUERY'
,p_lov_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select pro.nombre, pro.id_producto ',
'from productos pro, precio_por_categoria  cat',
'    where pro.id_producto = cat.id_producto',
'    and cat.CATEGORIA_CLIENTE = :P67_TIP_CLIENTE;'))
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
,p_updated_on=>wwv_flow_imp.dz('20250602151054Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(12941348441107125)
,p_name=>'ID_ORDEN'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_ORDEN'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
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
,p_enable_sort_group=>false
,p_enable_hide=>true
,p_is_primary_key=>true
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20250601181211Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(12854132617396801)
,p_internal_uid=>12854132617396801
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
,p_updated_on=>wwv_flow_imp.dz('20250601153141Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(12866050417401613)
,p_interactive_grid_id=>wwv_flow_imp.id(12854132617396801)
,p_static_id=>'128661'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20250601152940Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(12866247357401613)
,p_report_id=>wwv_flow_imp.id(12866050417401613)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12869444364401617)
,p_view_id=>wwv_flow_imp.id(12866247357401613)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(12855989535396819)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12870331120401618)
,p_view_id=>wwv_flow_imp.id(12866247357401613)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(12856080733396820)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(12875716464418262)
,p_view_id=>wwv_flow_imp.id(12866247357401613)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(12856161679396821)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13056547539344618)
,p_view_id=>wwv_flow_imp.id(12866247357401613)
,p_display_seq=>0
,p_column_id=>wwv_flow_imp.id(12940926604107121)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13057838234344620)
,p_view_id=>wwv_flow_imp.id(12866247357401613)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(12941203284107124)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13062505744349272)
,p_view_id=>wwv_flow_imp.id(12866247357401613)
,p_display_seq=>8
,p_column_id=>wwv_flow_imp.id(12941348441107125)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13115576183342824)
,p_plug_name=>'Detalle_V'
,p_region_name=>'Detalle_V'
,p_parent_plug_id=>wwv_flow_imp.id(12007971917524748)
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_plug_display_point=>'SUB_REGIONS'
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ',
'  ven.id_orden,',
'  pr.ID_PRODUCTO,',
'  pr.nombre,',
'  det.cantidad,',
'  det.precio_unitario,',
'  det.total,',
'  ti.descripcion AS iva,',
'  ti.porcentaje,',
'  ROUND((det.total * ti.porcentaje) / (100 + ti.porcentaje), 0) AS iva_calculado',
'FROM detalle_orden det',
'JOIN ordenes_venta ven ON ven.id_orden = det.id_orden',
'JOIN productos pr ON pr.id_producto = det.id_producto',
'LEFT JOIN tipo_iva ti ON ti.id_tipo_iva = pr.id_tipo_iva',
'WHERE det.id_orden = :P67_ID_ORDEN_VENTA;'))
,p_plug_source_type=>'NATIVE_IG'
,p_ajax_items_to_submit=>'P67_ID_ORDEN_VENTA'
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
,p_created_on=>wwv_flow_imp.dz('20250602150452Z')
,p_updated_on=>wwv_flow_imp.dz('20250619234112Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'TCASCO'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13115704241342826)
,p_name=>'ID_ORDEN'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_ORDEN'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Id Orden'
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
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250602150849Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13115848780342827)
,p_name=>'NOMBRE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'NOMBRE'
,p_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Nombre'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>50
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
,p_filter_lov_type=>'LOV'
,p_use_as_row_header=>false
,p_enable_sort_group=>true
,p_enable_control_break=>true
,p_enable_hide=>true
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>true
,p_updated_on=>wwv_flow_imp.dz('20250602151247Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13115953233342828)
,p_name=>'CANTIDAD'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cantidad'
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
,p_updated_on=>wwv_flow_imp.dz('20250602151247Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13116001580342829)
,p_name=>'PRECIO_UNITARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PRECIO_UNITARIO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Precio Unitario'
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
,p_updated_on=>wwv_flow_imp.dz('20250602151247Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13116116227342830)
,p_name=>'TOTAL'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'TOTAL'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Total'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>120
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
,p_updated_on=>wwv_flow_imp.dz('20250619233921Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13116209340342831)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_POPUP_LOV'
,p_heading=>'Producto'
,p_heading_alignment=>'CENTER'
,p_display_sequence=>40
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
'    and cat.CATEGORIA_CLIENTE = :P67_TIP_CLIENTE;'))
,p_lov_display_extra=>true
,p_lov_display_null=>true
,p_enable_filter=>true
,p_filter_operators=>'C:S:CASE_INSENSITIVE:REGEXP'
,p_filter_is_required=>false
,p_filter_text_case=>'MIXED'
,p_filter_exact_match=>true
,p_filter_lov_type=>'LOV'
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_enable_hide=>true
,p_is_primary_key=>true
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20250619205416Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13116693028342835)
,p_name=>'APEX$ROW_ACTION'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_display_sequence=>20
,p_updated_on=>wwv_flow_imp.dz('20250602150849Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13116722980342836)
,p_name=>'APEX$ROW_SELECTOR'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
,p_updated_on=>wwv_flow_imp.dz('20250602150849Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13182516321363547)
,p_name=>'IVA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'IVA'
,p_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Iva'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>100
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>false
,p_max_length=>50
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
,p_updated_on=>wwv_flow_imp.dz('20250619233921Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13182659561363548)
,p_name=>'PORCENTAJE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PORCENTAJE'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Porcentaje'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>90
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
,p_updated_on=>wwv_flow_imp.dz('20250619233921Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(13182763481363549)
,p_name=>'IVA_CALCULADO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'IVA_CALCULADO'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Iva Calculado'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>110
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
,p_updated_on=>wwv_flow_imp.dz('20250619233921Z')
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(13115666318342825)
,p_internal_uid=>13115666318342825
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
,p_updated_on=>wwv_flow_imp.dz('20250619234112Z')
,p_updated_by=>'TCASCO'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(13148657267840543)
,p_interactive_grid_id=>wwv_flow_imp.id(13115666318342825)
,p_static_id=>'131487'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20250619234112Z')
,p_updated_by=>'TCASCO'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(13148811384840543)
,p_report_id=>wwv_flow_imp.id(13148657267840543)
,p_view_type=>'GRID'
,p_stretch_columns=>true
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13149397558840544)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(13115704241342826)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13150296945840545)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(13115848780342827)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13151415940840547)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(13115953233342828)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13152317727840548)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(13116001580342829)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13153290277840549)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>10
,p_column_id=>wwv_flow_imp.id(13116116227342830)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13155470375856866)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(13116209340342831)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13162456138864199)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(13116693028342835)
,p_is_visible=>true
,p_is_frozen=>true
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13340387163007006)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>8
,p_column_id=>wwv_flow_imp.id(13182516321363547)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13341270048007008)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(13182659561363548)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(13342142315007010)
,p_view_id=>wwv_flow_imp.id(13148811384840543)
,p_display_seq=>9
,p_column_id=>wwv_flow_imp.id(13182763481363549)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12008074369524749)
,p_plug_name=>'Totalizador'
,p_parent_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123823Z')
,p_updated_on=>wwv_flow_imp.dz('20250601154011Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(12788816961370639)
,p_plug_name=>'Buttons'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>2126429139436695430
,p_plug_display_sequence=>20
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'TEXT',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102112357Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(15463718056249330)
,p_button_sequence=>70
,p_button_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_button_name=>'Cliente'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--iconLeft'
,p_button_template_id=>2082829544945815391
,p_button_is_hot=>'Y'
,p_button_image_alt=>'+ Cliente'
,p_button_redirect_url=>'f?p=&APP_ID.:91:&SESSION.::&DEBUG.:CR,67::'
,p_icon_css_classes=>'fa-user-md'
,p_grid_new_row=>'N'
,p_grid_column=>4
,p_created_on=>wwv_flow_imp.dz('20251102103408Z')
,p_updated_on=>wwv_flow_imp.dz('20251123184747Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12789213733370640)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(12788816961370639)
,p_button_name=>'CANCEL'
,p_button_action=>'DEFINED_BY_DA'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Cancelar'
,p_button_position=>'CLOSE'
,p_warn_on_unsaved_changes=>null
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251122134540Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12790634805370640)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(12788816961370639)
,p_button_name=>'DELETE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Eliminar'
,p_button_position=>'DELETE'
,p_button_execute_validations=>'N'
,p_confirm_message=>'&APP_TEXT$DELETE_MSG!RAW.'
,p_confirm_style=>'danger'
,p_button_condition=>'P67_ID_COMPROBANTE'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'DELETE'
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251122134540Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12791039185370640)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(12788816961370639)
,p_button_name=>'SAVE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Actualizar'
,p_button_position=>'NEXT'
,p_button_condition=>'P67_ID_COMPROBANTE'
,p_button_condition_type=>'ITEM_IS_NOT_NULL'
,p_database_action=>'UPDATE'
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102190423Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(12791467411370641)
,p_button_sequence=>40
,p_button_plug_id=>wwv_flow_imp.id(12788816961370639)
,p_button_name=>'CREATE'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Crear'
,p_button_position=>'NEXT'
,p_button_condition=>'P67_ID_COMPROBANTE'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_database_action=>'INSERT'
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251122134540Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12777329510370634)
,p_name=>'P67_ID_COMPROBANTE'
,p_source_data_type=>'NUMBER'
,p_is_primary_key=>true
,p_is_query_only=>true
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
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
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20250529123313Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12777738763370634)
,p_name=>'P67_ID_CLIENTE'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Cliente'
,p_source=>'ID_CLIENTE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_lov_language=>'PLSQL'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'    SELECT PE.PRIMER_NOMBRE ||'' ''||PE.SEGUNDO_NOMBRE||'' ''||PE.PRIMER_APELLIDO ||'' ''||PE.SEGUNDO_APELLIDO,  CL.ID_PERSONA FROM CLIENTES CL, PERSONAS PE',
'    WHERE PE.ID_PERSONA = CL.ID_PERSONA'))
,p_lov_display_null=>'YES'
,p_cSize=>30
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
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12778106097370635)
,p_name=>'P67_ID_OFICINA'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Oficina'
,p_source=>'ID_OFICINA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'select descripcion, codigo_oficina from OFICINAS'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12778583306370635)
,p_name=>'P67_ID_ORDEN_VENTA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>unistr('N\00B0 Orden Venta')
,p_source=>'ID_ORDEN_VENTA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT id_orden, id_orden as orden',
'FROM ORDENES_VENTA',
'WHERE ESTADO = ''Pendiente''',
''))
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
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12778956980370635)
,p_name=>'P67_TIPO_COMPROBANTE'
,p_source_data_type=>'VARCHAR2'
,p_is_required=>true
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Tipo Comprobante'
,p_source=>'TIPO_COMPROBANTE'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>1
,p_begin_on_new_line=>'N'
,p_field_template=>1609122147107268652
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12779329267370635)
,p_name=>'P67_ID_FAC_ORIGEN'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Factura Origen'
,p_source=>'ID_FAC_ORIGEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_begin_on_new_field=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102201041Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12779771922370636)
,p_name=>'P67_FECHA'
,p_source_data_type=>'DATE'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT CURRENT_TIMESTAMP AT TIME ZONE ''America/Argentina/Buenos_Aires'' AS FECHA_HORA_ARG',
'FROM dual;',
''))
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Fecha'
,p_source=>'FECHA'
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
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12780133555370636)
,p_name=>'P67_TOTAL_MONEDA_LOCAL'
,p_source_data_type=>'NUMBER'
,p_is_required=>true
,p_item_sequence=>80
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Total Moneda Local'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL_MONEDA_LOCAL'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_field_template=>1609122147107268652
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102111125Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12780586739370636)
,p_name=>'P67_MONEDA'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>90
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Moneda'
,p_source=>'MONEDA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select descripcion, codigo_moneda from MONEDAS',
'order by codigo_moneda asc;'))
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20250619204652Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12780937466370636)
,p_name=>'P67_TIPO_CAMBIO'
,p_item_sequence=>130
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_use_cache_before_default=>'NO'
,p_prompt=>'Cambio'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_display_when=>'P67_MONEDA'
,p_display_when2=>'1'
,p_display_when_type=>'VAL_OF_ITEM_IN_COND_NOT_EQ_COND2'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251204070357Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12781392519370636)
,p_name=>'P67_TOTAL_MONEDA_ORIGEN'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Total Moneda Origen'
,p_format_mask=>'$999G999G990D00'
,p_source=>'TOTAL_MONEDA_ORIGEN'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_begin_on_new_line=>'N'
,p_colspan=>3
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102105931Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12781756695370636)
,p_name=>'P67_FORMA_PAGO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>100
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Forma de Pago'
,p_source=>'FORMA_PAGO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov_language=>'PLSQL'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'SELECT DESCRIPCION, ID_FORMA_PAGO FROM FORMAS_PAGO',
'WHERE ACTIVO = ''S'''))
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12782113067370637)
,p_name=>'P67_ESTADO'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>120
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Estado'
,p_source=>'ESTADO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'STATIC:Anular;N,Activo;A'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_display_when=>'P67_ID_COMPROBANTE'
,p_display_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12782560447370637)
,p_name=>'P67_OBSERVACION'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>140
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Observacion'
,p_source=>'OBSERVACION'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>32
,p_cMaxlength=>255
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12782972964370637)
,p_name=>'P67_ID_TALONARIO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Talonario'
,p_source=>'ID_TALONARIO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_named_lov=>'TALONARIOS.TIPO_COMPROBANTE'
,p_lov_display_null=>'YES'
,p_cHeight=>1
,p_colspan=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20250618111850Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12783656515370637)
,p_name=>'P67_NRO_COMPROBANTE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Nro Comprobante'
,p_source=>'NRO_COMPROBANTE'
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
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20250529123856Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12939615576107108)
,p_name=>'P67_ID_PLAN_CUOTA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>110
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Plan Cuota'
,p_source=>'ID_PLAN_CUOTA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_POPUP_LOV'
,p_lov_language=>'PLSQL'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'',
'    SELECT descripcion, id_plan_cuota FROM PLANES_CUOTA',
'    where activo = ''S'''))
,p_lov_display_null=>'YES'
,p_cSize=>30
,p_colspan=>5
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
,p_created_on=>wwv_flow_imp.dz('20250601145226Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12939796034107109)
,p_name=>'P67_TOTAL_EXENTA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>150
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Total Exenta'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL_EXENTA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250601145226Z')
,p_updated_on=>wwv_flow_imp.dz('20251102105931Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12939802909107110)
,p_name=>'P67_TOTAL_GRAVADA_5'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>160
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Total Gravada 5'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL_GRAVADA_5'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250601145226Z')
,p_updated_on=>wwv_flow_imp.dz('20251102105931Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12939986345107111)
,p_name=>'P67_TOTAL_GRAVADA_10'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>170
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Total Gravada 10'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL_GRAVADA_10'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250601145226Z')
,p_updated_on=>wwv_flow_imp.dz('20251102105931Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12940027763107112)
,p_name=>'P67_TOTAL_IVA_5'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>180
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Total Iva 5'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL_IVA_5'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250601145226Z')
,p_updated_on=>wwv_flow_imp.dz('20251102105931Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12940100311107113)
,p_name=>'P67_TOTAL_IVA_10'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>200
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Total Iva 10'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL_IVA_10'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250601145226Z')
,p_updated_on=>wwv_flow_imp.dz('20251122134540Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12940258645107114)
,p_name=>'P67_TOTAL_IVA'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>220
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Total Iva'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_source=>'TOTAL_IVA'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250601145226Z')
,p_updated_on=>wwv_flow_imp.dz('20251122134540Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12941663587107128)
,p_name=>'P67_TIP_CLIENTE'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250601154011Z')
,p_updated_on=>wwv_flow_imp.dz('20250620213927Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(12942864877107140)
,p_name=>'P67_NEW'
,p_item_sequence=>150
,p_item_plug_id=>wwv_flow_imp.id(12007879735524747)
,p_item_default=>'Valor recibido: &P67_ID_ORDEN_VENTA.'
,p_prompt=>'New'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_display_when=>'P67_ID_ORDEN_VENTA'
,p_display_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250601181343Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200746Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15464300169249336)
,p_name=>'P67_METODO_PAGO'
,p_item_sequence=>190
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_prompt=>'Metodos de Pago'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT DESCRIPCION, ID_METODO_PAGO FROM METODOS_PAGO'
,p_cHeight=>1
,p_begin_on_new_line=>'N'
,p_begin_on_new_field=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251102105931Z')
,p_updated_on=>wwv_flow_imp.dz('20251122134540Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15464450617249337)
,p_name=>'P67_MONTO_PAGO'
,p_item_sequence=>210
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_prompt=>'Monto Ingresado'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_begin_on_new_field=>'N'
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251102105931Z')
,p_updated_on=>wwv_flow_imp.dz('20251122134540Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15464591449249338)
,p_name=>'P67_VUELTO'
,p_item_sequence=>230
,p_item_plug_id=>wwv_flow_imp.id(12008074369524749)
,p_prompt=>'Vuelto'
,p_format_mask=>'999G999G999G999G999G999G990'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_begin_on_new_line=>'N'
,p_begin_on_new_field=>'N'
,p_field_template=>1609121967514267634
,p_item_css_classes=>'campo-grande-negrita'
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251102105931Z')
,p_updated_on=>wwv_flow_imp.dz('20251122134540Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(15982936729097105)
,p_name=>'P67_ID_METODO_PAGO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_item_source_plug_id=>wwv_flow_imp.id(12776927328370633)
,p_prompt=>'Id Metodo Pago'
,p_source=>'ID_METODO_PAGO'
,p_source_type=>'REGION_SOURCE_COLUMN'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'left',
  'virtual_keyboard', 'decimal')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251102201041Z')
,p_updated_on=>wwv_flow_imp.dz('20251102201041Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(15464606428249339)
,p_validation_name=>'New'
,p_validation_sequence=>10
,p_validation=>':P67_VUELTO < 0'
,p_validation2=>'PLSQL'
,p_validation_type=>'EXPRESSION'
,p_error_message=>'Cambio no puede ser Negativo'
,p_associated_item=>wwv_flow_imp.id(15464591449249338)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_created_on=>wwv_flow_imp.dz('20251102110647Z')
,p_updated_on=>wwv_flow_imp.dz('20251102112913Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12789366170370640)
,p_name=>'Cancel Dialog'
,p_event_sequence=>10
,p_triggering_element_type=>'BUTTON'
,p_triggering_button_id=>wwv_flow_imp.id(12789213733370640)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'click'
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20250529123313Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12790190088370640)
,p_event_id=>wwv_flow_imp.id(12789366170370640)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_DIALOG_CANCEL'
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20250529123313Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12940442582107116)
,p_name=>'Rellena Campos'
,p_event_sequence=>20
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P67_ID_TALONARIO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250601150423Z')
,p_updated_on=>wwv_flow_imp.dz('20251102185331Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12940532121107117)
,p_event_id=>wwv_flow_imp.id(12940442582107116)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select id_oficina, tipo_comprobante',
'into :P67_ID_OFICINA, :P67_TIPO_COMPROBANTE',
'from TALONARIOS',
'WHERE ID_TALONARIO = :P67_ID_TALONARIO;'))
,p_attribute_02=>'P67_ID_TALONARIO'
,p_attribute_03=>'P67_ID_OFICINA,P67_TIPO_COMPROBANTE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250601150423Z')
,p_updated_on=>wwv_flow_imp.dz('20251102185331Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12940735358107119)
,p_event_id=>wwv_flow_imp.id(12940442582107116)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT FN_OBTENER_COMPROBANTE(:P67_ID_OFICINA, :P67_TIPO_COMPROBANTE) ',
'INTO :P67_NRO_COMPROBANTE FROM DUAL;'))
,p_attribute_02=>'P67_ID_OFICINA,P67_TIPO_COMPROBANTE'
,p_attribute_03=>'P67_NRO_COMPROBANTE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250601151046Z')
,p_updated_on=>wwv_flow_imp.dz('20250601151555Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12940618348107118)
,p_event_id=>wwv_flow_imp.id(12940442582107116)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_ID_OFICINA,P67_TIPO_COMPROBANTE,P67_NRO_COMPROBANTE'
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20250601150455Z')
,p_updated_on=>wwv_flow_imp.dz('20250601151618Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12941442504107126)
,p_name=>'Carga de Detalle'
,p_event_sequence=>30
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P67_ID_ORDEN_VENTA'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250601153054Z')
,p_updated_on=>wwv_flow_imp.dz('20250602151148Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12942919936107141)
,p_event_id=>wwv_flow_imp.id(12941442504107126)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(13115576183342824)
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20250601181852Z')
,p_updated_on=>wwv_flow_imp.dz('20250602151148Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12941585925107127)
,p_event_id=>wwv_flow_imp.id(12941442504107126)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_NEW'
,p_attribute_01=>'N'
,p_client_condition_type=>'NOT_NULL'
,p_client_condition_element=>'P67_ID_ORDEN_VENTA'
,p_created_on=>wwv_flow_imp.dz('20250601153054Z')
,p_updated_on=>wwv_flow_imp.dz('20250602150452Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12941752126107129)
,p_name=>'Tipo Cliente'
,p_event_sequence=>40
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P67_ID_CLIENTE'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250601154012Z')
,p_updated_on=>wwv_flow_imp.dz('20250601154012Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12941866047107130)
,p_event_id=>wwv_flow_imp.id(12941752126107129)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT CATEGORIA_CLIENTE ',
'    INTO :P67_TIP_CLIENTE',
'FROM  CLIENTES CL',
'    WHERE CL.ID_PERSONA = :P67_ID_CLIENTE;'))
,p_attribute_02=>'P67_ID_CLIENTE'
,p_attribute_03=>'P67_TIP_CLIENTE'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250601154012Z')
,p_updated_on=>wwv_flow_imp.dz('20250601154012Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12942195747107133)
,p_event_id=>wwv_flow_imp.id(12941752126107129)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_TIP_CLIENTE'
,p_attribute_01=>'N'
,p_created_on=>wwv_flow_imp.dz('20250601154012Z')
,p_updated_on=>wwv_flow_imp.dz('20250601154012Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12941944195107131)
,p_name=>'Carga de Productos'
,p_event_sequence=>50
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(12008123551524750)
,p_triggering_element=>'PRODUCTO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250601154012Z')
,p_updated_on=>wwv_flow_imp.dz('20250601171645Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12942021495107132)
,p_event_id=>wwv_flow_imp.id(12941944195107131)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select 1, cat.precio,cat.precio',
'into :CANTIDAD,:PRECIO_UNITARIO, :TOTAL',
'from productos pro, precio_por_categoria cat',
'    where pro.id_producto = cat.id_producto',
'    AND CAT.CATEGORIA_CLIENTE = :P67_TIP_CLIENTE',
'    and pro.id_producto = :PRODUCTO;'))
,p_attribute_02=>'PRODUCTO'
,p_attribute_03=>'CANTIDAD,PRECIO_UNITARIO,TOTAL'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250601154012Z')
,p_updated_on=>wwv_flow_imp.dz('20250601171645Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12942482629107136)
,p_event_id=>wwv_flow_imp.id(12941944195107131)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
,p_created_on=>wwv_flow_imp.dz('20250601154309Z')
,p_updated_on=>wwv_flow_imp.dz('20250601171047Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12942243687107134)
,p_name=>'Totalizador'
,p_event_sequence=>60
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(12008123551524750)
,p_triggering_element=>'CANTIDAD,PRECIO_UNITARIO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250601154125Z')
,p_updated_on=>wwv_flow_imp.dz('20250601171744Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12942567966107137)
,p_event_id=>wwv_flow_imp.id(12942243687107134)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
,p_created_on=>wwv_flow_imp.dz('20250601154309Z')
,p_updated_on=>wwv_flow_imp.dz('20250601154309Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12942343183107135)
,p_event_id=>wwv_flow_imp.id(12942243687107134)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>':TOTAL := :CANTIDAD * :PRECIO_UNITARIO;'
,p_attribute_02=>'CANTIDAD,PRECIO_UNITARIO'
,p_attribute_03=>'TOTAL'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250601154125Z')
,p_updated_on=>wwv_flow_imp.dz('20250601171744Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(12942665835107138)
,p_name=>'Total IG'
,p_event_sequence=>70
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(13115576183342824)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'NATIVE_IG|REGION TYPE|interactivegridselectionchange'
,p_created_on=>wwv_flow_imp.dz('20250601154413Z')
,p_updated_on=>wwv_flow_imp.dz('20250618111946Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(12942718970107139)
,p_event_id=>wwv_flow_imp.id(12942665835107138)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
,p_created_on=>wwv_flow_imp.dz('20250601154414Z')
,p_updated_on=>wwv_flow_imp.dz('20250618111946Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(13116948466342838)
,p_name=>'New'
,p_event_sequence=>80
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(13115576183342824)
,p_triggering_element=>'ID_PRODUCTO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250602151506Z')
,p_updated_on=>wwv_flow_imp.dz('20250618112025Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13117060433342839)
,p_event_id=>wwv_flow_imp.id(13116948466342838)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select 1, cat.precio,cat.precio',
'into :CANTIDAD,:PRECIO_UNITARIO, :TOTAL',
'from productos pro, precio_por_categoria cat',
'    where pro.id_producto = cat.id_producto',
'    AND CAT.CATEGORIA_CLIENTE = :P67_TIP_CLIENTE',
'    and pro.id_producto = :ID_PRODUCTO;'))
,p_attribute_02=>'ID_PRODUCTO'
,p_attribute_03=>'CANTIDAD,PRECIO_UNITARIO,TOTAL'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250602151506Z')
,p_updated_on=>wwv_flow_imp.dz('20250602152154Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13179737375363519)
,p_event_id=>wwv_flow_imp.id(13116948466342838)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
,p_created_on=>wwv_flow_imp.dz('20250618112025Z')
,p_updated_on=>wwv_flow_imp.dz('20250618112025Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(13117147310342840)
,p_name=>'New_1'
,p_event_sequence=>90
,p_triggering_element_type=>'COLUMN'
,p_triggering_region_id=>wwv_flow_imp.id(13115576183342824)
,p_triggering_element=>'CANTIDAD,PRECIO_UNITARIO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250602152340Z')
,p_updated_on=>wwv_flow_imp.dz('20250618112051Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13179806125363520)
,p_event_id=>wwv_flow_imp.id(13117147310342840)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'recalculaImporte();'
,p_created_on=>wwv_flow_imp.dz('20250618112051Z')
,p_updated_on=>wwv_flow_imp.dz('20250618112051Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13117285545342841)
,p_event_id=>wwv_flow_imp.id(13117147310342840)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>':TOTAL := :CANTIDAD * :PRECIO_UNITARIO;'
,p_attribute_02=>'CANTIDAD,PRECIO_UNITARIO'
,p_attribute_03=>'TOTAL'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250602152340Z')
,p_updated_on=>wwv_flow_imp.dz('20250618112051Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(13182137220363543)
,p_name=>'New_2'
,p_event_sequence=>100
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P67_MONEDA'
,p_condition_element=>'P67_MONEDA'
,p_triggering_condition_type=>'NOT_EQUALS'
,p_triggering_expression=>'1'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250619204141Z')
,p_updated_on=>wwv_flow_imp.dz('20251122135344Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13182278455363544)
,p_event_id=>wwv_flow_imp.id(13182137220363543)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_TIPO_CAMBIO'
,p_created_on=>wwv_flow_imp.dz('20250619204141Z')
,p_updated_on=>wwv_flow_imp.dz('20250619204141Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13182479635363546)
,p_event_id=>wwv_flow_imp.id(13182137220363543)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_TIPO_CAMBIO'
,p_created_on=>wwv_flow_imp.dz('20250619204141Z')
,p_updated_on=>wwv_flow_imp.dz('20250619204141Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13182854324363550)
,p_event_id=>wwv_flow_imp.id(13182137220363543)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_TOTAL_MONEDA_ORIGEN'
,p_created_on=>wwv_flow_imp.dz('20250619235721Z')
,p_updated_on=>wwv_flow_imp.dz('20250619235721Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13348345183104001)
,p_event_id=>wwv_flow_imp.id(13182137220363543)
,p_event_result=>'FALSE'
,p_action_sequence=>20
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_TOTAL_MONEDA_ORIGEN'
,p_created_on=>wwv_flow_imp.dz('20250619235721Z')
,p_updated_on=>wwv_flow_imp.dz('20250619235721Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14820716052450432)
,p_event_id=>wwv_flow_imp.id(13182137220363543)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'Y'
,p_name=>'set cambios'
,p_action=>'NATIVE_SET_VALUE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_TIPO_CAMBIO'
,p_attribute_01=>'SQL_STATEMENT'
,p_attribute_03=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT TRUNC(tipo_compra)',
'FROM TIPOS_CAMBIO',
'WHERE fuente = ''BCP''',
'  AND COD_MONEDA_COTIZADA = 1',
'ORDER BY FECHA_UPDATED DESC',
'FETCH FIRST 1 ROWS ONLY;',
''))
,p_attribute_08=>'Y'
,p_attribute_09=>'N'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20251122133739Z')
,p_updated_on=>wwv_flow_imp.dz('20251122135216Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14820897187450433)
,p_event_id=>wwv_flow_imp.id(13182137220363543)
,p_event_result=>'FALSE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_CLEAR'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_TIPO_CAMBIO'
,p_created_on=>wwv_flow_imp.dz('20251122135344Z')
,p_updated_on=>wwv_flow_imp.dz('20251122135344Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(13348467461104002)
,p_name=>'Cambio divisa'
,p_event_sequence=>110
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P67_TIPO_CAMBIO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20250620000103Z')
,p_updated_on=>wwv_flow_imp.dz('20251122142300Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(13348506980104003)
,p_event_id=>wwv_flow_imp.id(13348467461104002)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_local NUMBER;',
'  v_tc    NUMBER;',
'BEGIN',
'  -- Convertir limpiando puntos y comas (miles o decimales)',
'  v_local := TO_NUMBER(REPLACE(REPLACE(:P67_TOTAL_MONEDA_LOCAL, ''.'', ''''), '','', ''''));',
'  v_tc    := TO_NUMBER(REPLACE(REPLACE(:P67_TIPO_CAMBIO, ''.'', ''''), '','', ''''));',
'',
'  IF v_local IS NULL OR v_tc IS NULL OR v_tc = 0 THEN',
'    :P67_TOTAL_MONEDA_ORIGEN := NULL;',
'  ELSE',
'    :P67_TOTAL_MONEDA_ORIGEN := ROUND(v_local / v_tc, 2);',
'  END IF;',
'END;',
''))
,p_attribute_02=>'P67_TOTAL_MONEDA_LOCAL,P67_TIPO_CAMBIO'
,p_attribute_03=>'P67_TOTAL_MONEDA_ORIGEN'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250620000103Z')
,p_updated_on=>wwv_flow_imp.dz('20251122142300Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15463820690249331)
,p_name=>'Plan Cuota'
,p_event_sequence=>120
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P67_FORMA_PAGO'
,p_condition_element=>'P67_FORMA_PAGO'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'1'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20251102104028Z')
,p_updated_on=>wwv_flow_imp.dz('20251102105111Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15464021629249333)
,p_event_id=>wwv_flow_imp.id(15463820690249331)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_ID_PLAN_CUOTA'
,p_created_on=>wwv_flow_imp.dz('20251102104108Z')
,p_updated_on=>wwv_flow_imp.dz('20251102104859Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15464108045249334)
,p_event_id=>wwv_flow_imp.id(15463820690249331)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_ID_PLAN_CUOTA'
,p_created_on=>wwv_flow_imp.dz('20251102104251Z')
,p_updated_on=>wwv_flow_imp.dz('20251102104859Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15464724165249340)
,p_name=>'Calcula Monto'
,p_event_sequence=>130
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P67_MONTO_PAGO'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20251102110647Z')
,p_updated_on=>wwv_flow_imp.dz('20251102111353Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15464872980249341)
,p_event_id=>wwv_flow_imp.id(15464724165249340)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
':P67_VUELTO := ',
'    TO_NUMBER(REPLACE(:P67_MONTO_PAGO, ''.'', '''')) ',
'  - TO_NUMBER(REPLACE(:P67_TOTAL_MONEDA_LOCAL, ''.'', ''''));',
''))
,p_attribute_02=>'P67_TOTAL_MONEDA_LOCAL,P67_MONTO_PAGO'
,p_attribute_03=>'P67_VUELTO'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20251102110647Z')
,p_updated_on=>wwv_flow_imp.dz('20251102111353Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(15982572038097101)
,p_name=>'Factura Origen'
,p_event_sequence=>140
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P67_ID_TALONARIO'
,p_condition_element=>'P67_ID_TALONARIO'
,p_triggering_condition_type=>'EQUALS'
,p_triggering_expression=>'21'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
,p_created_on=>wwv_flow_imp.dz('20251102185701Z')
,p_updated_on=>wwv_flow_imp.dz('20251102201417Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15982798829097103)
,p_event_id=>wwv_flow_imp.id(15982572038097101)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_IF_FAC_ORIGEN'
,p_created_on=>wwv_flow_imp.dz('20251102185701Z')
,p_updated_on=>wwv_flow_imp.dz('20251102185701Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15982866685097104)
,p_event_id=>wwv_flow_imp.id(15982572038097101)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_EXECUTE_PLSQL_CODE'
,p_attribute_01=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select nro_comprobante ',
'into :P67_ID_FAC_ORIGEN',
'from COMPROBANTES',
'where id_comprobante = :P67_ID_COMPROBANTE;'))
,p_attribute_02=>'P67_ID_COMPROBANTE'
,p_attribute_03=>'P67_ID_FAC_ORIGEN'
,p_attribute_04=>'N'
,p_attribute_05=>'PLSQL'
,p_wait_for_result=>'Y'
,p_created_on=>wwv_flow_imp.dz('20251102190217Z')
,p_updated_on=>wwv_flow_imp.dz('20251102200856Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15983166713097107)
,p_event_id=>wwv_flow_imp.id(15982572038097101)
,p_event_result=>'FALSE'
,p_action_sequence=>10
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_HIDE'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_ID_FAC_ORIGEN'
,p_created_on=>wwv_flow_imp.dz('20251102201417Z')
,p_updated_on=>wwv_flow_imp.dz('20251102201417Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15982628240097102)
,p_event_id=>wwv_flow_imp.id(15982572038097101)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_IF_FAC_ORIGEN'
,p_created_on=>wwv_flow_imp.dz('20251102185701Z')
,p_updated_on=>wwv_flow_imp.dz('20251102190217Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(15983043835097106)
,p_event_id=>wwv_flow_imp.id(15982572038097101)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'Y'
,p_action=>'NATIVE_SHOW'
,p_affected_elements_type=>'ITEM'
,p_affected_elements=>'P67_ID_FAC_ORIGEN'
,p_created_on=>wwv_flow_imp.dz('20251102201417Z')
,p_updated_on=>wwv_flow_imp.dz('20251102201417Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12792268806370641)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(12776927328370633)
,p_process_type=>'NATIVE_FORM_DML'
,p_process_name=>'Process form Proceso Ventas'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>12792268806370641
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20250529123313Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13117457362342843)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Detalle Factura Cursor'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    CURSOR CUR_DETALLE IS',
'        SELECT ',
'          ven.id_orden,',
'          pr.ID_PRODUCTO,',
'          pr.nombre,',
'          det.cantidad,',
'          det.precio_unitario,',
'          det.total,',
'          ti.descripcion AS iva,',
'          ti.porcentaje,',
'          ROUND((det.total * ti.porcentaje) / (100 + ti.porcentaje), 0) AS iva_calculado',
'        FROM detalle_orden det',
'        JOIN ordenes_venta ven ON ven.id_orden = det.id_orden',
'        JOIN productos pr ON pr.id_producto = det.id_producto',
'        LEFT JOIN tipo_iva ti ON ti.id_tipo_iva = pr.id_tipo_iva',
'        WHERE det.id_orden = :P67_ID_ORDEN_VENTA;',
'',
'    REG_DET CUR_DETALLE%ROWTYPE;',
'BEGIN',
'    OPEN CUR_DETALLE;',
'    LOOP',
'        FETCH CUR_DETALLE INTO REG_DET;',
'        EXIT WHEN CUR_DETALLE%NOTFOUND;',
'',
'        INSERT INTO DETALLE_COMPROBANTE (',
'            ID_COMPROBANTE,',
'            ID_PRODUCTO,',
'            CANTIDAD,',
'            PRECIO_UNITARIO,',
'            TOTAL_LINEA,',
'            MONTO_IVA,',
'            PORCENTAJE_IVA',
'        ) VALUES (',
unistr('            :P67_ID_COMPROBANTE, -- este debe estar definido en la p\00E1gina'),
'            REG_DET.ID_PRODUCTO,',
'            REG_DET.CANTIDAD,',
'            REG_DET.PRECIO_UNITARIO,',
'            REG_DET.TOTAL,',
'            REG_DET.IVA_CALCULADO,',
'            REG_DET.PORCENTAJE',
'        );',
'',
'    END LOOP;',
'    CLOSE CUR_DETALLE;',
'',
'    apex_application.g_print_success_message :=',
unistr('        ''Se gener\00F3 el comprobante correctamente a partir de la orden de venta N\00B0 '' || :P67_ID_ORDEN_VENTA;'),
'END;',
''))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(12791467411370641)
,p_internal_uid=>13117457362342843
,p_created_on=>wwv_flow_imp.dz('20250602160335Z')
,p_updated_on=>wwv_flow_imp.dz('20250620112626Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13116846885342837)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(13115576183342824)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Detalle_V - Save Interactive Grid Data'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(12791467411370641)
,p_internal_uid=>13116846885342837
,p_created_on=>wwv_flow_imp.dz('20250602150849Z')
,p_updated_on=>wwv_flow_imp.dz('20250602160346Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12941104366107123)
,p_process_sequence=>40
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(12008123551524750)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Detalle_Venta - Save Interactive Grid Data'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_required_patch=>wwv_flow_imp.id(7705349298831252)
,p_internal_uid=>12941104366107123
,p_created_on=>wwv_flow_imp.dz('20250601152853Z')
,p_updated_on=>wwv_flow_imp.dz('20250602160335Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13117395752342842)
,p_process_sequence=>50
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Actualiza Factura'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
' UPDATE TALONARIOS',
'    SET NRO_ACTUAL = NRO_ACTUAL +1',
'    WHERE TIPO_COMPROBANTE = :P67_TIPO_COMPROBANTE;',
'    COMMIT;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>13117395752342842
,p_created_on=>wwv_flow_imp.dz('20250602160335Z')
,p_updated_on=>wwv_flow_imp.dz('20250602160335Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12792603198370641)
,p_process_sequence=>60
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_SESSION_STATE'
,p_process_name=>'Close Dialog'
,p_attribute_01=>'CLEAR_CACHE_CURRENT_PAGE'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when=>'CREATE,SAVE,DELETE'
,p_process_when_type=>'REQUEST_IN_CONDITION'
,p_internal_uid=>12792603198370641
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20251102113153Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(12791846761370641)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_region_id=>wwv_flow_imp.id(12776927328370633)
,p_process_type=>'NATIVE_FORM_INIT'
,p_process_name=>'Initialize form Proceso Ventas'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>12791846761370641
,p_created_on=>wwv_flow_imp.dz('20250529123313Z')
,p_updated_on=>wwv_flow_imp.dz('20250529123313Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(15465358937249346)
,p_process_sequence=>20
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Validacion de Caja'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    v_estado varchar2(1);',
'',
'    BEGIN',
'        SELECT CA.ESTADO ',
'        INTO v_estado',
'        FROM CAJAS CA, EMPLEADOS EP',
'        WHERE EP.ID_EMPLEADO = CA.ID_EMPLEADO',
'        --AND EP.CODIGO_USUARIO = &APP_USER',
'        AND CA.ESTADO = ''A'';',
'         EXCEPTION',
'            WHEN NO_DATA_FOUND THEN',
'            apex_application.g_print_success_message := ''<span style="color: BLACK;"La caja no se encuentra Habilitada<br> </span>'';',
'            RAISE_APPLICATION_ERROR(-20000, ''Caja No Habilitada'');',
'    END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>15465358937249346
,p_created_on=>wwv_flow_imp.dz('20251102114348Z')
,p_updated_on=>wwv_flow_imp.dz('20251102114348Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

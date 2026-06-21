prompt --application/pages/page_00125
begin
--   Manifest
--     PAGE: 00125
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.17'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_page.create_page(
 p_id=>125
,p_name=>unistr('Solicitar Nota de Cr\00E9dito')
,p_alias=>unistr('SOLICITAR-NOTA-DE-CR\00C9DITO')
,p_page_mode=>'MODAL'
,p_step_title=>unistr('Solicitar Nota de Cr\00E9dito')
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'25'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23154688240069504)
,p_plug_name=>'Datos de la factura'
,p_title=>'Datos de la factura'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23154726881069505)
,p_plug_name=>unistr('L\00EDneas a acreditar')
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>20
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT dc.ID_DETALLE AS ID_DETALLE_ORIGEN, dc.ID_PRODUCTO,',
'           pr.NOMBRE AS PRODUCTO, dc.CANTIDAD AS CANT_FACTURADA,',
'           WKSP_WORKPLACE.FN_CANT_ACREDITABLE(dc.ID_DETALLE) AS CANT_ACREDITABLE,',
'           dc.PRECIO_UNITARIO, dc.PORCENTAJE_IVA, 0 AS CANT_ACREDITAR,',
'           dc.PRECIO_UNITARIO AS PRECIO_NUEVO',
'      FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE dc',
'      JOIN WKSP_WORKPLACE.PRODUCTOS pr ON pr.ID_PRODUCTO = dc.ID_PRODUCTO',
'     WHERE dc.ID_COMPROBANTE = :P125_ID_FACTURA'))
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
 p_id=>wwv_flow_imp.id(23154908658069507)
,p_name=>'ID_DETALLE_ORIGEN'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_DETALLE_ORIGEN'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Id Detalle Origen'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>10
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
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(23155078391069508)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Id Producto'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>20
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
 p_id=>wwv_flow_imp.id(23155141404069509)
,p_name=>'PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PRODUCTO'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_TEXT_FIELD'
,p_heading=>'Producto'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>30
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
 p_id=>wwv_flow_imp.id(23155220420069510)
,p_name=>'CANT_FACTURADA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANT_FACTURADA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cant Facturada'
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
 p_id=>wwv_flow_imp.id(23155359771069511)
,p_name=>'CANT_ACREDITABLE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANT_ACREDITABLE'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cant Acreditable'
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
 p_id=>wwv_flow_imp.id(23155476950069512)
,p_name=>'PRECIO_UNITARIO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PRECIO_UNITARIO'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Precio Facturado'
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
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(23155569789069513)
,p_name=>'PORCENTAJE_IVA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PORCENTAJE_IVA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>true
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Porcentaje Iva'
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
 p_id=>wwv_flow_imp.id(23155612930069514)
,p_name=>'CANT_ACREDITAR'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANT_ACREDITAR'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cant Acreditar'
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
 p_id=>wwv_flow_imp.id(23270000000000060)
,p_name=>'PRECIO_NUEVO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'PRECIO_NUEVO'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Precio Nuevo x Unidad'
,p_heading_alignment=>'RIGHT'
,p_display_sequence=>65
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
 p_id=>wwv_flow_imp.id(23154893570069506)
,p_internal_uid=>23154893570069506
,p_is_editable=>true
,p_edit_operations=>'u'
,p_lazy_loading=>false
,p_requires_filter=>false
,p_select_first_row=>true
,p_fixed_row_height=>true
,p_pagination_type=>'SCROLL'
,p_show_total_row_count=>true
,p_show_toolbar=>false
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
 p_id=>wwv_flow_imp.id(23253501509239193)
,p_interactive_grid_id=>wwv_flow_imp.id(23154893570069506)
,p_static_id=>'232536'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(23253763697239194)
,p_report_id=>wwv_flow_imp.id(23253501509239193)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>true
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23254110239239200)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(23154908658069507)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23255002331239204)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(23155078391069508)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23255993032239207)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(23155141404069509)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23256857658239210)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(23155220420069510)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23257767443239213)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(23155359771069511)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23258685509239216)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(23155476950069512)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23259551683239219)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(23155569789069513)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23260446802239222)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>8
,p_column_id=>wwv_flow_imp.id(23155612930069514)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(23270000000000061)
,p_view_id=>wwv_flow_imp.id(23253763697239194)
,p_display_seq=>9
,p_column_id=>wwv_flow_imp.id(23270000000000060)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(23270000000000040)
,p_plug_name=>'Aviso NC'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>5
,p_location=>null
,p_function_body_language=>'PLSQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v VARCHAR2(1000);',
'BEGIN',
'  v := WKSP_WORKPLACE.FN_NC_AVISO(:P125_ID_FACTURA);',
'  IF v IS NULL THEN RETURN NULL; END IF;',
'  RETURN ''<div style="padding:.6em .8em;border-left:4px solid #c89b00;''',
'      ||''background:#fff8e1;border-radius:4px;">''',
'      ||''<b>Aviso:</b> ''||v||''</div>'';',
'END;'))
,p_lazy_loading=>false
,p_plug_source_type=>'NATIVE_DYNAMIC_CONTENT'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(23156672094069524)
,p_button_sequence=>30
,p_button_name=>'SOLICITAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Solicitar'
,p_button_condition=>'P125_BLOQUEO'
,p_button_condition_type=>'ITEM_IS_NULL'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23155726986069515)
,p_name=>'P125_ID_FACTURA'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23155879908069516)
,p_name=>'P125_COD_MOTIVO'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_prompt=>'Cod Motivo'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>'SELECT DESCRIPCION d, COD_MOTIVO r FROM WKSP_WORKPLACE.MOTIVOS_NOTA_CREDITO WHERE ACTIVO=''S'' ORDER BY COD_MOTIVO'
,p_lov_display_null=>'YES'
,p_lov_null_text=>'- Seleccione un motivo -'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23155959554069517)
,p_name=>'P125_TIPO_NC'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_item_default=>'T'
,p_prompt=>'Tipo Nc'
,p_display_as=>'NATIVE_RADIOGROUP'
,p_lov=>'STATIC:Total;T,Parcial;P'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'YES'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_of_columns', '1',
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23156062928069518)
,p_name=>'P125_OBSERVACION'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_prompt=>'Observacion'
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>30
,p_cHeight=>5
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23270000000000001)
,p_name=>'P125_ID_SOLICITUD'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23270000000000002)
,p_name=>'P125_BLOQUEO'
,p_item_sequence=>4
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_prompt=>'No se puede emitir NC'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_display_when=>'P125_BLOQUEO'
,p_display_when_type=>'ITEM_IS_NOT_NULL'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23270000000000004)
,p_name=>'P125_FACTURA'
,p_item_sequence=>11
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_prompt=>'Factura'
,p_source=>'SELECT NRO_COMPROBANTE FROM WKSP_WORKPLACE.COMPROBANTES WHERE ID_COMPROBANTE = :P125_ID_FACTURA'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23270000000000005)
,p_name=>'P125_FECHA'
,p_item_sequence=>12
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_prompt=>'Fecha'
,p_source=>'SELECT TO_CHAR(FECHA,''DD/MM/YYYY'') FROM WKSP_WORKPLACE.COMPROBANTES WHERE ID_COMPROBANTE = :P125_ID_FACTURA'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23270000000000006)
,p_name=>'P125_CLIENTE'
,p_item_sequence=>13
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_prompt=>'Cliente'
,p_source=>'SELECT TRIM(p.PRIMER_NOMBRE||'' ''||p.PRIMER_APELLIDO) FROM WKSP_WORKPLACE.COMPROBANTES c JOIN WKSP_WORKPLACE.PERSONAS p ON p.ID_PERSONA=c.ID_CLIENTE WHERE c.ID_COMPROBANTE = :P125_ID_FACTURA'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(23270000000000007)
,p_name=>'P125_TOTAL'
,p_item_sequence=>14
,p_item_plug_id=>wwv_flow_imp.id(23154688240069504)
,p_prompt=>'Total factura'
,p_source=>'SELECT TO_CHAR(TOTAL_MONEDA_LOCAL,''FM999G999G999G990'') FROM WKSP_WORKPLACE.COMPROBANTES WHERE ID_COMPROBANTE = :P125_ID_FACTURA'
,p_source_type=>'QUERY'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23270000000000020)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Crear solicitud NC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_SOLICITAR_NOTA_CREDITO(',
'    p_id_factura   => :P125_ID_FACTURA,',
'    p_cod_motivo   => :P125_COD_MOTIVO,',
'    p_tipo_nc      => :P125_TIPO_NC,',
'    p_observacion  => :P125_OBSERVACION,',
'    p_usuario      => :APP_USER,',
'    p_id_solicitud => :P125_ID_SOLICITUD);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23156672094069524)
,p_internal_uid=>23270000000000020
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23270000000000021)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(23154726881069505)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Guardar lineas NC (parcial)'
,p_attribute_01=>'PLSQL_CODE'
,p_attribute_04=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  if :P125_TIPO_NC <> ''P'' then return; end if;',
'  declare',
'    v_prod number; v_iva number; v_precio_fac number; v_precio_nuevo number;',
'    v_credito number; v_es_devol boolean;',
'  begin',
'    select ID_PRODUCTO, PORCENTAJE_IVA, PRECIO_UNITARIO',
'      into v_prod, v_iva, v_precio_fac',
'      from WKSP_WORKPLACE.DETALLE_COMPROBANTE where ID_DETALLE = :ID_DETALLE_ORIGEN;',
'    v_es_devol := :P125_COD_MOTIVO in (1,2);   -- Devolucion: acredita valor completo',
'    v_precio_nuevo := NVL(:PRECIO_NUEVO, v_precio_fac);',
'    if NVL(:CANT_ACREDITAR,0) <= 0 then',
'      -- en descuento/ajuste, si toco el precio sin cantidad, avisar claro',
'      if not v_es_devol and v_precio_nuevo < v_precio_fac then',
'        raise_application_error(-20990, ''Pusiste un precio nuevo pero falta la Cantidad a Acreditar en una linea.'');',
'      end if;',
'      return;',
'    end if;',
'    if :CANT_ACREDITAR > WKSP_WORKPLACE.FN_CANT_ACREDITABLE(:ID_DETALLE_ORIGEN) then',
'      raise_application_error(-20977, ''La cantidad a acreditar excede lo disponible en la linea.'');',
'    end if;',
'    if v_es_devol then',
'      v_credito := v_precio_fac;   -- devolucion: valor completo, no usa Precio Nuevo',
'    else',
'      if v_precio_nuevo < 0 or v_precio_nuevo > v_precio_fac then',
'        raise_application_error(-20989, ''El precio nuevo (''||v_precio_nuevo||'') debe estar entre 0 y el precio facturado (''||v_precio_fac||'').'');',
'      end if;',
'      if v_precio_nuevo >= v_precio_fac then',
'        raise_application_error(-20990, ''Para un descuento/ajuste ingresa un Precio Nuevo MENOR al facturado (linea con cantidad '' || :CANT_ACREDITAR || '').'');',
'      end if;',
'      v_credito := v_precio_fac - v_precio_nuevo;',
'    end if;',
'    if v_credito > 0 then',
'      insert into WKSP_WORKPLACE.SOLICITUD_NC_DETALLE',
'        (ID_SOLICITUD_NC, ID_DETALLE_ORIGEN, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, PORCENTAJE_IVA)',
'      values (:P125_ID_SOLICITUD, :ID_DETALLE_ORIGEN, v_prod, :CANT_ACREDITAR, v_credito, v_iva);',
'    end if;',
'  end;',
'end;'))
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23156672094069524)
,p_internal_uid=>23270000000000021
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23270000000000050)
,p_process_sequence=>30
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Validar lineas de la solicitud'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  WKSP_WORKPLACE.PRC_VALIDAR_SOLICITUD_NC(:P125_ID_SOLICITUD);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23156672094069524)
,p_internal_uid=>23270000000000050
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23270000000000030)
,p_process_sequence=>90
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Close Dialog'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(23156672094069524)
,p_internal_uid=>23270000000000030
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(23270000000000010)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Pre-check elegibilidad NC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  :P125_BLOQUEO := WKSP_WORKPLACE.FN_NC_ELEGIBLE(:P125_ID_FACTURA);',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>23270000000000010
);
wwv_flow_imp.component_end;
end;
/

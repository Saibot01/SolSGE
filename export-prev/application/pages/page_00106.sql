prompt --application/pages/page_00106
begin
--   Manifest
--     PAGE: 00106
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
 p_id=>106
,p_name=>unistr('Recepci\00F3n de Orden de Compra')
,p_alias=>unistr('RECEPCI\00D3N-DE-ORDEN-DE-COMPRA')
,p_page_mode=>'MODAL'
,p_step_title=>unistr('Recepci\00F3n de Orden de Compra')
,p_autocomplete_on_off=>'OFF'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'.col-oculta {',
'  display: none !important;',
'}',
''))
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'21'
,p_created_on=>wwv_flow_imp.dz('20251127042401Z')
,p_last_updated_on=>wwv_flow_imp.dz('20260427082749Z')
,p_created_by=>'SIS_APEX'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14820944924450434)
,p_plug_name=>'Region 1'
,p_title=>'Datos de la Orden de Compra'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127043800Z')
,p_updated_on=>wwv_flow_imp.dz('20251127043800Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14821899402450443)
,p_plug_name=>unistr('Recepci\00F3n')
,p_title=>unistr('Recepci\00F3n')
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>50
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_on=>wwv_flow_imp.dz('20260427082749Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14822380992450448)
,p_plug_name=>'Detalle de orden'
,p_title=>unistr('Detalle de orden - Recepci\00F3n')
,p_region_name=>'IG_DETALLE_OC'
,p_region_template_options=>'#DEFAULT#:t-IRR-region--hideHeader js-addHiddenHeadingRoleDesc'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2100526641005906379
,p_plug_display_sequence=>60
,p_query_type=>'SQL'
,p_plug_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'  doc.ID_DETALLE_OC,',
'  doc.ID_PRODUCTO,',
'  p.NOMBRE                          AS NOMBRE_PRODUCTO,',
'  doc.CANTIDAD                           AS CANTIDAD_PEDIDA,',
'',
'  NVL((',
'    SELECT SUM(dr.CANTIDAD_RECIBIDA)',
'      FROM DETALLE_RECEPCION_COMPRA dr',
'      JOIN RECEPCIONES_COMPRA r',
'        ON r.ID_RECEPCION = dr.ID_RECEPCION',
'     WHERE r.ID_ORDEN_COMPRA = doc.ID_ORDEN_COMPRA',
'       AND dr.ID_DETALLE_OC   = doc.ID_DETALLE_OC',
'  ), 0)                                   AS CANTIDAD_RECIBIDA_ACUM,',
'',
'  doc.CANTIDAD',
'    - NVL((',
'      SELECT SUM(dr.CANTIDAD_RECIBIDA)',
'        FROM DETALLE_RECEPCION_COMPRA dr',
'        JOIN RECEPCIONES_COMPRA r',
'          ON r.ID_RECEPCION = dr.ID_RECEPCION',
'       WHERE r.ID_ORDEN_COMPRA = doc.ID_ORDEN_COMPRA',
'         AND dr.ID_DETALLE_OC   = doc.ID_DETALLE_OC',
'    ), 0)                                 AS CANTIDAD_PENDIENTE,',
'',
'  0                                       AS CANTIDAD_A_RECIBIR',
'',
'FROM DETALLE_ORDEN_COMPRA doc',
'JOIN PRODUCTOS p',
'  ON p.ID_PRODUCTO = doc.ID_PRODUCTO',
'WHERE doc.ID_ORDEN_COMPRA = :P120_ID_ORDEN_COMPRA;',
''))
,p_plug_source_type=>'NATIVE_IG'
,p_prn_units=>'MILLIMETERS'
,p_prn_paper_size=>'A4'
,p_prn_width=>297
,p_prn_height=>210
,p_prn_orientation=>'HORIZONTAL'
,p_prn_page_header=>unistr('Detalle de orden - Recepci\00F3n')
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
,p_created_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_on=>wwv_flow_imp.dz('20260427082749Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(14822574755450450)
,p_name=>'ID_DETALLE_OC'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_DETALLE_OC'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>30
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>true
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16593346940211701)
,p_name=>'ID_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'ID_PRODUCTO'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_HIDDEN'
,p_display_sequence=>40
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_use_as_row_header=>false
,p_enable_sort_group=>false
,p_is_primary_key=>false
,p_duplicate_value=>true
,p_include_in_export=>false
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16593443066211702)
,p_name=>'NOMBRE_PRODUCTO'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'NOMBRE_PRODUCTO'
,p_data_type=>'VARCHAR2'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_TEXTAREA'
,p_heading=>'Nombre Producto'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>50
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'auto_height', 'N',
  'character_counter', 'N',
  'resizable', 'Y',
  'trim_spaces', 'BOTH')).to_clob
,p_is_required=>true
,p_max_length=>500
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
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16593555148211703)
,p_name=>'CANTIDAD_PEDIDA'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD_PEDIDA'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DISPLAY_ONLY'
,p_heading=>'Cantidad Pedida'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>60
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN')).to_clob
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
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16593622165211704)
,p_name=>'CANTIDAD_RECIBIDA_ACUM'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD_RECIBIDA_ACUM'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DISPLAY_ONLY'
,p_heading=>'Cantidad Recibida Acum'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>70
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN')).to_clob
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
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16593745689211705)
,p_name=>'CANTIDAD_PENDIENTE'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD_PENDIENTE'
,p_data_type=>'NUMBER'
,p_session_state_data_type=>'VARCHAR2'
,p_is_query_only=>false
,p_item_type=>'NATIVE_DISPLAY_ONLY'
,p_heading=>'Cantidad Pendiente'
,p_heading_alignment=>'LEFT'
,p_display_sequence=>80
,p_value_alignment=>'LEFT'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN')).to_clob
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
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16593805398211706)
,p_name=>'CANTIDAD_A_RECIBIR'
,p_source_type=>'DB_COLUMN'
,p_source_expression=>'CANTIDAD_A_RECIBIR'
,p_data_type=>'NUMBER'
,p_is_query_only=>false
,p_item_type=>'NATIVE_NUMBER_FIELD'
,p_heading=>'Cantidad A Recibir'
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
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16593992517211707)
,p_name=>'APEX$ROW_ACTION'
,p_item_type=>'NATIVE_ROW_ACTION'
,p_display_sequence=>20
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_region_column(
 p_id=>wwv_flow_imp.id(16594046441211708)
,p_name=>'APEX$ROW_SELECTOR'
,p_item_type=>'NATIVE_ROW_SELECTOR'
,p_display_sequence=>10
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'enable_multi_select', 'Y',
  'hide_control', 'N',
  'show_select_all', 'Y')).to_clob
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_interactive_grid(
 p_id=>wwv_flow_imp.id(14822452313450449)
,p_internal_uid=>14822452313450449
,p_is_editable=>true
,p_edit_operations=>'u'
,p_lost_update_check_type=>'VALUES'
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
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_ig_report(
 p_id=>wwv_flow_imp.id(16601376787300243)
,p_interactive_grid_id=>wwv_flow_imp.id(14822452313450449)
,p_static_id=>'166014'
,p_type=>'PRIMARY'
,p_default_view=>'GRID'
,p_show_row_number=>false
,p_settings_area_expanded=>true
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_ig_report_view(
 p_id=>wwv_flow_imp.id(16601510055300243)
,p_report_id=>wwv_flow_imp.id(16601376787300243)
,p_view_type=>'GRID'
,p_srv_exclude_null_values=>false
,p_srv_only_display_columns=>true
,p_edit_mode=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16602049896300247)
,p_view_id=>wwv_flow_imp.id(16601510055300243)
,p_display_seq=>1
,p_column_id=>wwv_flow_imp.id(14822574755450450)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16602904143300249)
,p_view_id=>wwv_flow_imp.id(16601510055300243)
,p_display_seq=>2
,p_column_id=>wwv_flow_imp.id(16593346940211701)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16603888558300251)
,p_view_id=>wwv_flow_imp.id(16601510055300243)
,p_display_seq=>3
,p_column_id=>wwv_flow_imp.id(16593443066211702)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16604767280300252)
,p_view_id=>wwv_flow_imp.id(16601510055300243)
,p_display_seq=>4
,p_column_id=>wwv_flow_imp.id(16593555148211703)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16605651835300254)
,p_view_id=>wwv_flow_imp.id(16601510055300243)
,p_display_seq=>5
,p_column_id=>wwv_flow_imp.id(16593622165211704)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16606550308300255)
,p_view_id=>wwv_flow_imp.id(16601510055300243)
,p_display_seq=>6
,p_column_id=>wwv_flow_imp.id(16593745689211705)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16607441878300256)
,p_view_id=>wwv_flow_imp.id(16601510055300243)
,p_display_seq=>7
,p_column_id=>wwv_flow_imp.id(16593805398211706)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_ig_report_column(
 p_id=>wwv_flow_imp.id(16608307230300258)
,p_view_id=>wwv_flow_imp.id(16601510055300243)
,p_display_seq=>0
,p_column_id=>wwv_flow_imp.id(16593992517211707)
,p_is_visible=>true
,p_is_frozen=>false
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(16589820606057879)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20251127042401Z')
,p_updated_on=>wwv_flow_imp.dz('20251127042401Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(16594704229211715)
,p_name=>'Detalle'
,p_title=>'Detalle de Orden'
,p_template=>4072358936313175081
,p_display_sequence=>70
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--altRowsDefault:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'  -- F02: ID_DETALLE_OC sigue siendo necesario ',
'  -- para el FK en DETALLE_RECEPCION_COMPRA',
'  APEX_ITEM.HIDDEN(2, doc.ID_DETALLE_OC)            AS F02,',
'',
'  -- F03: ID_PRODUCTO',
'  APEX_ITEM.HIDDEN(3, dcp.ID_PRODUCTO)              AS F03,',
'',
'  pr.NOMBRE                                         AS NOMBRE_PRODUCTO,',
'',
unistr('  -- \2705 Cantidad seg\00FAn FACTURA (no seg\00FAn OC)'),
'  dcp.CANTIDAD                                      AS CANTIDAD_PEDIDA,',
'',
unistr('  -- \2705 Acumulado recibido filtrando por COMPROBANTE'),
'  NVL((',
'    SELECT SUM(dr.CANTIDAD_RECIBIDA)',
'      FROM DETALLE_RECEPCION_COMPRA dr',
'      JOIN RECEPCIONES_COMPRA r',
'        ON r.ID_RECEPCION = dr.ID_RECEPCION',
unistr('     WHERE r.ID_COMPROBANTE = dcp.ID_COMPROBANTE    -- \2190 cambio clave'),
'       AND dr.ID_DETALLE_OC = doc.ID_DETALLE_OC',
'  ), 0)                                             AS CANTIDAD_RECIBIDA_ACUM,',
'',
unistr('  -- \2705 Pendiente contra factura'),
'  dcp.CANTIDAD - NVL((',
'    SELECT SUM(dr.CANTIDAD_RECIBIDA)',
'      FROM DETALLE_RECEPCION_COMPRA dr',
'      JOIN RECEPCIONES_COMPRA r',
'        ON r.ID_RECEPCION = dr.ID_RECEPCION',
'     WHERE r.ID_COMPROBANTE = dcp.ID_COMPROBANTE',
'       AND dr.ID_DETALLE_OC = doc.ID_DETALLE_OC',
'  ), 0)                                             AS CANTIDAD_PENDIENTE,',
'',
unistr('  -- F04: hidden para validaci\00F3n (pendiente)'),
'  APEX_ITEM.HIDDEN(',
'    4,',
'    dcp.CANTIDAD - NVL((',
'      SELECT SUM(dr.CANTIDAD_RECIBIDA)',
'        FROM DETALLE_RECEPCION_COMPRA dr',
'        JOIN RECEPCIONES_COMPRA r',
'          ON r.ID_RECEPCION = dr.ID_RECEPCION',
'       WHERE r.ID_COMPROBANTE = dcp.ID_COMPROBANTE',
'         AND dr.ID_DETALLE_OC = doc.ID_DETALLE_OC',
'    ), 0)',
'  )                                                 AS F04,',
'',
'  -- F01: campo editable',
'  APEX_ITEM.TEXT(',
'    p_idx       => 1,',
'    p_value     => 0,',
'    p_size      => 10,',
'    p_maxlength => 12',
'  )                                                 AS CANTIDAD_A_RECIBIR',
'',
unistr('-- \2705 Base ahora es la FACTURA'),
'FROM DETALLE_COMPROBANTE_PROV dcp',
'JOIN DETALLE_ORDEN_COMPRA doc',
'  ON doc.ID_ORDEN_COMPRA = :P106_ID_ORDEN_COMPRA',
' AND doc.ID_PRODUCTO     = dcp.ID_PRODUCTO          -- link por producto',
'JOIN PRODUCTOS pr',
'  ON pr.ID_PRODUCTO = dcp.ID_PRODUCTO',
unistr('WHERE dcp.ID_COMPROBANTE = :P106_ID_COMPROBANTE     -- \2190 filtro principal'),
unistr('  AND dcp.CANTIDAD - NVL((                          -- \2190 solo pendientes'),
'    SELECT SUM(dr.CANTIDAD_RECIBIDA)',
'      FROM DETALLE_RECEPCION_COMPRA dr',
'      JOIN RECEPCIONES_COMPRA r',
'        ON r.ID_RECEPCION = dr.ID_RECEPCION',
'     WHERE r.ID_COMPROBANTE = dcp.ID_COMPROBANTE',
'       AND dr.ID_DETALLE_OC = doc.ID_DETALLE_OC',
'  ), 0) > 0;'))
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
,p_created_on=>wwv_flow_imp.dz('20251127054338Z')
,p_updated_on=>wwv_flow_imp.dz('20260427082749Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16594827927211716)
,p_query_column_id=>1
,p_column_alias=>'F02'
,p_column_display_sequence=>10
,p_column_css_class=>'col-oculta'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20251128224328Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16594920008211717)
,p_query_column_id=>2
,p_column_alias=>'F03'
,p_column_display_sequence=>20
,p_column_css_class=>'col-oculta'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20251128224328Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16595014278211718)
,p_query_column_id=>3
,p_column_alias=>'NOMBRE_PRODUCTO'
,p_column_display_sequence=>30
,p_column_heading=>'Producto'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20251127101202Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16595106936211719)
,p_query_column_id=>4
,p_column_alias=>'CANTIDAD_PEDIDA'
,p_column_display_sequence=>40
,p_column_heading=>'Cantidad Pedida'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20251127054339Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16595240873211720)
,p_query_column_id=>5
,p_column_alias=>'CANTIDAD_RECIBIDA_ACUM'
,p_column_display_sequence=>50
,p_column_heading=>'Cantidad Recibida'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20251127101202Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16595355559211721)
,p_query_column_id=>6
,p_column_alias=>'CANTIDAD_PENDIENTE'
,p_column_display_sequence=>60
,p_column_heading=>'Cantidad Pendiente'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_disable_sort_column=>'N'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20251127054339Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16595784055211725)
,p_query_column_id=>7
,p_column_alias=>'F04'
,p_column_display_sequence=>80
,p_column_css_class=>'col-oculta'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20251128224328Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(16595417189211722)
,p_query_column_id=>8
,p_column_alias=>'CANTIDAD_A_RECIBIR'
,p_column_display_sequence=>70
,p_column_heading=>'Cantidad a Recibir'
,p_heading_alignment=>'LEFT'
,p_disable_sort_column=>'N'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20251127101202Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(16594209691211710)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(16594704229211715)
,p_button_name=>'BT_GUARDAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>unistr('Guardar recepci\00F3n')
,p_button_position=>'CHANGE'
,p_created_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_on=>wwv_flow_imp.dz('20251127105755Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(16596069967211728)
,p_branch_name=>'BR_VOLVER_MISMA_PAGINA'
,p_branch_action=>'f?p=&APP_ID.:106:&SESSION.::&DEBUG.::P106_ID_ORDEN_COMPRA:&P106_ID_ORDEN_COMPRA.&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_when_button_id=>wwv_flow_imp.id(16594209691211710)
,p_branch_sequence=>10
,p_created_on=>wwv_flow_imp.dz('20251127061658Z')
,p_updated_on=>wwv_flow_imp.dz('20251127061658Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14821009329450435)
,p_name=>'P106_ID_ORDEN_COMPRA'
,p_item_sequence=>30
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127043800Z')
,p_updated_on=>wwv_flow_imp.dz('20251127043800Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14821265045450437)
,p_name=>'P106_OC_NUMERO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(14820944924450434)
,p_prompt=>'Nro de Orden'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127043800Z')
,p_updated_on=>wwv_flow_imp.dz('20260324105003Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14821311690450438)
,p_name=>'P106_OC_PROVEEDOR'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(14820944924450434)
,p_prompt=>'Proveedor'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127043800Z')
,p_updated_on=>wwv_flow_imp.dz('20260324105136Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14821491048450439)
,p_name=>'P106_OC_FECHA'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(14820944924450434)
,p_prompt=>'Fecha'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_begin_on_new_field=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127043800Z')
,p_updated_on=>wwv_flow_imp.dz('20260324105136Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14821511996450440)
,p_name=>'P106_ESTADO'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(14820944924450434)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127043800Z')
,p_updated_on=>wwv_flow_imp.dz('20260324093110Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14821696302450441)
,p_name=>'P106_OC_TOTAL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(14820944924450434)
,p_prompt=>'Total'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_begin_on_new_line=>'N'
,p_begin_on_new_field=>'N'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127043800Z')
,p_updated_on=>wwv_flow_imp.dz('20260324105136Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14821960668450444)
,p_name=>'P106_ID_RECEPCION'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(14821899402450443)
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14822058632450445)
,p_name=>'P106_REC_FECHA'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(14821899402450443)
,p_item_default=>'SYSDATE'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_prompt=>'Fecha de Recepcion'
,p_display_as=>'NATIVE_DATE_PICKER_APEX'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_as', 'POPUP',
  'max_date', 'NONE',
  'min_date', 'NONE',
  'multiple_months', 'N',
  'show_time', 'N',
  'use_defaults', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_on=>wwv_flow_imp.dz('20251127101202Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14822178448450446)
,p_name=>'P106_REC_OBS'
,p_item_sequence=>30
,p_item_plug_id=>wwv_flow_imp.id(14821899402450443)
,p_prompt=>unistr('Observaci\00F3n ')
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
,p_created_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_on=>wwv_flow_imp.dz('20251127101202Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14822268551450447)
,p_name=>'P106_REC_ID_EMPLEADO'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(14821899402450443)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_EMPLEADO ',
'FROM EMPLEADOS',
'WHERE CODIGO_USUARIO = :APP_USER'))
,p_item_default_type=>'SQL_QUERY'
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_on=>wwv_flow_imp.dz('20260324092451Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16597130929211739)
,p_name=>'P106_COD_USUARIO'
,p_item_sequence=>50
,p_item_plug_id=>wwv_flow_imp.id(14821899402450443)
,p_item_default=>':APP_USER'
,p_item_default_type=>'EXPRESSION'
,p_item_default_language=>'PLSQL'
,p_prompt=>'Usuario'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260324091655Z')
,p_updated_on=>wwv_flow_imp.dz('20260324092559Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(16597258234211740)
,p_name=>'P106_ESTADO_TEXTO'
,p_item_sequence=>60
,p_item_plug_id=>wwv_flow_imp.id(14820944924450434)
,p_prompt=>'Estado'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260324093110Z')
,p_updated_on=>wwv_flow_imp.dz('20260324105136Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20233719292558308)
,p_name=>'P106_ID_COMPROBANTE'
,p_item_sequence=>40
,p_display_as=>'NATIVE_HIDDEN'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20260427082749Z')
,p_updated_on=>wwv_flow_imp.dz('20260427082749Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(16595835231211726)
,p_validation_name=>'VAL_AL_MENOS_UNA_CANTIDAD'
,p_validation_sequence=>5
,p_validation=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_count  PLS_INTEGER;',
'  l_val    VARCHAR2(4000);',
'BEGIN',
'  -- Si no hay G_F01, consideramos que no hay datos',
'  l_count := NVL(APEX_APPLICATION.G_F01.COUNT, 0);',
'',
'  IF l_count = 0 THEN',
'    RETURN FALSE;',
'  END IF;',
'',
'  FOR i IN 1 .. l_count LOOP',
'    l_val := TRIM(APEX_APPLICATION.G_F01(i));',
'',
unistr('    -- Si el usuario escribi\00F3 algo que no sea vac\00EDo ni "0"'),
'    IF l_val IS NOT NULL AND l_val <> ''0'' THEN',
'      RETURN TRUE;',
'    END IF;',
'  END LOOP;',
'',
unistr('  -- Si llegamos hasta ac\00E1, todas las filas son NULL o "0"'),
'  RETURN FALSE;',
'',
'EXCEPTION',
'  WHEN OTHERS THEN',
unistr('    -- Si algo raro pasa, por seguridad consideramos que la validaci\00F3n falla'),
'    RETURN FALSE;',
'END;'))
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_BOOLEAN'
,p_error_message=>'Debes ingresar al menos una cantidad a recibir mayor a cero.'
,p_when_button_pressed=>wwv_flow_imp.id(16594209691211710)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
,p_created_on=>wwv_flow_imp.dz('20251127060901Z')
,p_updated_on=>wwv_flow_imp.dz('20251127112303Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_validation(
 p_id=>wwv_flow_imp.id(16595927755211727)
,p_validation_name=>'VAL_CANTIDAD_NO_SUPERA_PENDIENTE'
,p_validation_sequence=>8
,p_validation=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  l_count   PLS_INTEGER;',
'  l_raw     VARCHAR2(4000);',
'  l_cant    NUMBER;',
'  l_pend    NUMBER;',
'BEGIN',
unistr('  -- Si no hay filas en F01, no validamos nada (la otra validaci\00F3n se encarga del "todo cero")'),
'  l_count := NVL(APEX_APPLICATION.G_F01.COUNT, 0);',
'',
'  IF l_count = 0 THEN',
'    RETURN TRUE;',
'  END IF;',
'',
'  FOR i IN 1 .. l_count LOOP',
unistr('    -- Si no hay pendiente para este \00EDndice, salimos del loop por seguridad'),
'    IF APEX_APPLICATION.G_F04.COUNT < i THEN',
'      EXIT;',
'    END IF;',
'',
'    l_raw := TRIM(APEX_APPLICATION.G_F01(i));',
'',
unistr('    -- Si est\00E1 vac\00EDo, lo tratamos como 0'),
'    IF l_raw IS NULL THEN',
'      l_cant := 0;',
'    ELSE',
unistr('      -- Intentamos convertir a n\00FAmero'),
'      BEGIN',
'        l_cant := TO_NUMBER(l_raw);',
'      EXCEPTION',
'        WHEN OTHERS THEN',
unistr('          -- Si no es n\00FAmero v\00E1lido, la validaci\00F3n falla'),
'          RETURN FALSE;',
'      END;',
'    END IF;',
'',
'    -- Pendiente (F04 viene del hidden que armamos)',
'    l_pend := NVL(TO_NUMBER(APEX_APPLICATION.G_F04(i)), 0);',
'',
'    -- No permitir negativos ni superar pendiente',
'    IF l_cant < 0 THEN',
'      RETURN FALSE;',
'    ELSIF l_cant > l_pend THEN',
'      RETURN FALSE;',
'    END IF;',
'  END LOOP;',
'',
'  RETURN TRUE;',
'END;'))
,p_validation2=>'PLSQL'
,p_validation_type=>'FUNC_BODY_RETURNING_BOOLEAN'
,p_error_message=>unistr('La cantidad a recibir debe ser num\00E9rica, no negativa y no puede superar la cantidad pendiente.')
,p_when_button_pressed=>wwv_flow_imp.id(16594209691211710)
,p_error_display_location=>'INLINE_WITH_FIELD_AND_NOTIFICATION'
,p_created_on=>wwv_flow_imp.dz('20251127061159Z')
,p_updated_on=>wwv_flow_imp.dz('20251127112303Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16594181858211709)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_region_id=>wwv_flow_imp.id(14822380992450448)
,p_process_type=>'NATIVE_IG_DML'
,p_process_name=>'Detalle de orden - Save Interactive Grid Data'
,p_attribute_01=>'REGION_SOURCE'
,p_attribute_05=>'Y'
,p_attribute_06=>'Y'
,p_attribute_08=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>16594181858211709
,p_created_on=>wwv_flow_imp.dz('20251127050425Z')
,p_updated_on=>wwv_flow_imp.dz('20251127050425Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(14821769507450442)
,p_process_sequence=>10
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'CARGAR_DATOS_OC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_nombre_proveedor PERSONAS.PRIMER_NOMBRE%TYPE;',
'BEGIN',
'  -- Datos de la OC',
'  SELECT oc.ID_ORDEN_COMPRA,',
'         oc.FECHA_ORDEN,',
'         oc.ESTADO,',
'         oc.TOTAL_ORDEN,',
'         p.PRIMER_NOMBRE || '' '' || p.PRIMER_APELLIDO,',
'         CASE oc.ESTADO',
'              WHEN ''P'' THEN ''Pendiente''',
unistr('              WHEN ''R'' THEN ''Recepci\00F3n parcial'''),
'              WHEN ''C'' THEN ''Completa''',
'              WHEN ''A'' THEN ''Anulada''',
'              ELSE ''Desconocido''',
'         END',
'    INTO :P106_OC_NUMERO,',
'         :P106_OC_FECHA,',
'         :P106_ESTADO,',
'         :P106_OC_TOTAL,',
'         v_nombre_proveedor,',
'         :P106_ESTADO_TEXTO',
'    FROM ORDENES_COMPRA oc',
'    JOIN PERSONAS p',
'      ON p.ID_PERSONA = oc.ID_PROVEEDOR',
'   WHERE oc.ID_ORDEN_COMPRA = :P106_ID_ORDEN_COMPRA;',
'',
'  :P106_OC_PROVEEDOR := v_nombre_proveedor;',
'',
unistr('  -- \2705 NUEVO: verificar que el comprobante pasado'),
unistr('  -- pertenezca a esta OC (validaci\00F3n de seguridad)'),
'  BEGIN',
'    SELECT ID_COMPROBANTE',
'      INTO :P106_ID_COMPROBANTE',
'      FROM COMPROBANTES_PROVEEDOR',
'     WHERE ID_COMPROBANTE  = :P106_ID_COMPROBANTE',
'       AND ID_ORDEN_COMPRA = :P106_ID_ORDEN_COMPRA;',
'  EXCEPTION',
'    WHEN NO_DATA_FOUND THEN',
'      RAISE_APPLICATION_ERROR(-20001,',
'        ''El comprobante no corresponde a esta Orden de Compra.'');',
'  END;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_internal_uid=>14821769507450442
,p_created_on=>wwv_flow_imp.dz('20251127043800Z')
,p_updated_on=>wwv_flow_imp.dz('20260427082749Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16594389608211711)
,p_process_sequence=>10
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'CREAR_CABECERA_RECEPCION'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_id_recepcion RECEPCIONES_COMPRA.ID_RECEPCION%TYPE;',
'BEGIN',
'  INSERT INTO RECEPCIONES_COMPRA (',
'    ID_ORDEN_COMPRA,',
unistr('    ID_COMPROBANTE,        -- \2705 NUEVO'),
'    FECHA_RECEPCION,',
'    ID_EMPLEADO,',
'    OBSERVACION',
'  ) VALUES (',
'    :P106_ID_ORDEN_COMPRA,',
unistr('    :P106_ID_COMPROBANTE,  -- \2705 NUEVO'),
'    :P106_REC_FECHA,',
'    :P106_REC_ID_EMPLEADO,',
'    :P106_REC_OBS',
'  )',
'  RETURNING ID_RECEPCION INTO v_id_recepcion;',
'  :P106_ID_RECEPCION := v_id_recepcion;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(16594209691211710)
,p_internal_uid=>16594389608211711
,p_created_on=>wwv_flow_imp.dz('20251127051243Z')
,p_updated_on=>wwv_flow_imp.dz('20260427082749Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16595566588211723)
,p_process_sequence=>20
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'PROCESAR_DETALLE_RECEPCION'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_cant_a_recibir  NUMBER;',
'  v_id_det_oc       NUMBER;',
'  v_id_producto     NUMBER;',
'BEGIN',
'  -- Si no hay filas en F01, no hacemos nada',
'  IF APEX_APPLICATION.G_F01.COUNT = 0 THEN',
'    RETURN;',
'  END IF;',
'',
'  FOR i IN 1 .. APEX_APPLICATION.G_F01.COUNT LOOP',
unistr('    -- Cantidad a recibir (puede venir vac\00EDa)'),
'    v_cant_a_recibir := NVL(TO_NUMBER(APEX_APPLICATION.G_F01(i)), 0);',
'',
unistr('    -- Si no existe \00EDndice en F02 o F03, saltamos la fila'),
'    IF APEX_APPLICATION.G_F02.COUNT < i',
'       OR APEX_APPLICATION.G_F03.COUNT < i',
'    THEN',
'      CONTINUE;',
'    END IF;',
'',
'    v_id_det_oc   := TO_NUMBER(APEX_APPLICATION.G_F02(i));',
'    v_id_producto := TO_NUMBER(APEX_APPLICATION.G_F03(i));',
'',
'    IF v_cant_a_recibir > 0 THEN',
'      INSERT INTO DETALLE_RECEPCION_COMPRA (',
'        ID_RECEPCION,',
'        ID_DETALLE_OC,',
'        ID_PRODUCTO,',
'        CANTIDAD_RECIBIDA',
'      ) VALUES (',
'        :P106_ID_RECEPCION,',
'        v_id_det_oc,',
'        v_id_producto,',
'        v_cant_a_recibir',
'      );',
'    END IF;',
'  END LOOP;',
'END;',
''))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(16594209691211710)
,p_internal_uid=>16595566588211723
,p_created_on=>wwv_flow_imp.dz('20251127055310Z')
,p_updated_on=>wwv_flow_imp.dz('20251127105755Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(16595605082211724)
,p_process_sequence=>30
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'RECALCULAR_ESTADO_OC'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'BEGIN',
'  RECALCULAR_ESTADO_OC(',
'    P_ID_OC          => :P106_ID_ORDEN_COMPRA,',
unistr('    P_ID_COMPROBANTE => :P106_ID_COMPROBANTE   -- \2705 NUEVO'),
'  );',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_process_error_message=>unistr('Error al registrar la recepci\00F3n.')
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(16594209691211710)
,p_process_success_message=>unistr('Recepci\00F3n registrada correctamente.')
,p_internal_uid=>16595605082211724
,p_created_on=>wwv_flow_imp.dz('20251127055310Z')
,p_updated_on=>wwv_flow_imp.dz('20260427082749Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

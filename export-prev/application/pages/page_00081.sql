prompt --application/pages/page_00081
begin
--   Manifest
--     PAGE: 00081
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
 p_id=>81
,p_name=>'Roles - Privilegios'
,p_alias=>'ROLES-PRIVILEGIOS'
,p_step_title=>'Roles - Privilegios'
,p_allow_duplicate_submissions=>'N'
,p_reload_on_submit=>'A'
,p_warn_on_unsaved_changes=>'N'
,p_autocomplete_on_off=>'ON'
,p_inline_css=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* Scroll Results Only in Side Column */',
'.t-Body-side {',
'    display: flex;',
'    flex-direction: column;',
'    overflow: hidden;',
'}',
'.search-results {',
'    flex: 1;',
'    overflow: auto;',
'}',
'/* Format Search Region */',
'.search-region {',
'    border-bottom: 1px solid rgba(0,0,0,.1);',
'    flex-shrink: 0;',
'}'))
,p_step_template=>2526643373347724467
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
,p_page_component_map=>'03'
,p_created_on=>wwv_flow_imp.dz('20250911112246Z')
,p_last_updated_on=>wwv_flow_imp.dz('20250911115513Z')
,p_created_by=>'SIS_APEX'
,p_last_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14246135692094633)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
,p_created_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14247651726094634)
,p_plug_name=>'Search'
,p_region_css_classes=>'search-region padding-md'
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_02'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(14248470386094635)
,p_name=>'Master Records'
,p_template=>3371237801798025892
,p_display_sequence=>20
,p_region_css_classes=>'search-results'
,p_region_template_options=>'#DEFAULT#'
,p_component_template_options=>'t-MediaList--showDesc:t-MediaList--stack'
,p_display_point=>'REGION_POSITION_02'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select "ID_ROL",',
'    null LINK_CLASS,',
'    apex_page.get_url(p_items => ''P81_ID_ROL'', p_values => "ID_ROL") LINK,',
'    null ICON_CLASS,',
'    null LINK_ATTR,',
'    null ICON_COLOR_CLASS,',
'    case when coalesce(:P81_ID_ROL,''0'') = "ID_ROL"',
'      then ''is-active'' ',
'      else '' ''',
'    end LIST_CLASS,',
'    (substr("NOMBRE_ROL", 1, 50)||( case when length("NOMBRE_ROL") > 50 then ''...'' else '''' end )) LIST_TITLE,',
'    (substr("DESCRIPCION", 1, 50)||( case when length("DESCRIPCION") > 50 then ''...'' else '''' end )) LIST_TEXT,',
'    null LIST_BADGE',
'from "ROLES" x',
'where (:P81_SEARCH is null',
'        or upper(x."NOMBRE_ROL") like ''%''||upper(:P81_SEARCH)||''%''',
'        or upper(x."DESCRIPCION") like ''%''||upper(:P81_SEARCH)||''%''',
'    )',
'order by "NOMBRE_ROL"'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P81_SEARCH'
,p_lazy_loading=>false
,p_query_row_template=>2093604263195414824
,p_query_num_rows=>1000
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'<div class="u-tC">No data found.</div>'
,p_query_row_count_max=>500
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
,p_created_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14249194353094636)
,p_query_column_id=>1
,p_column_alias=>'ID_ROL'
,p_column_display_sequence=>1
,p_column_heading=>'ID_ROL'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14249593569094637)
,p_query_column_id=>2
,p_column_alias=>'LINK_CLASS'
,p_column_display_sequence=>2
,p_column_heading=>'LINK_CLASS'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14249929679094637)
,p_query_column_id=>3
,p_column_alias=>'LINK'
,p_column_display_sequence=>3
,p_column_heading=>'LINK'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14250382035094637)
,p_query_column_id=>4
,p_column_alias=>'ICON_CLASS'
,p_column_display_sequence=>4
,p_column_heading=>'ICON_CLASS'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14250746404094637)
,p_query_column_id=>5
,p_column_alias=>'LINK_ATTR'
,p_column_display_sequence=>5
,p_column_heading=>'LINK_ATTR'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14251179517094637)
,p_query_column_id=>6
,p_column_alias=>'ICON_COLOR_CLASS'
,p_column_display_sequence=>6
,p_column_heading=>'ICON_COLOR_CLASS'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14251563419094638)
,p_query_column_id=>7
,p_column_alias=>'LIST_CLASS'
,p_column_display_sequence=>7
,p_column_heading=>'LIST_CLASS'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14251968517094638)
,p_query_column_id=>8
,p_column_alias=>'LIST_TITLE'
,p_column_display_sequence=>8
,p_column_heading=>'LIST_TITLE'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14252329161094638)
,p_query_column_id=>9
,p_column_alias=>'LIST_TEXT'
,p_column_display_sequence=>9
,p_column_heading=>'LIST_TEXT'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14252748846094638)
,p_query_column_id=>10
,p_column_alias=>'LIST_BADGE'
,p_column_display_sequence=>10
,p_column_heading=>'LIST_BADGE'
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(14253125526094846)
,p_name=>'Roles'
,p_template=>4072358936313175081
,p_display_sequence=>10
,p_region_css_classes=>'js-master-region'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-AVPList--leftAligned'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'TABLE'
,p_query_table=>'ROLES'
,p_query_where=>'"ID_ROL" = :P81_ID_ROL'
,p_include_rowid_column=>false
,p_display_when_condition=>'P81_ID_ROL'
,p_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2100515439059797523
,p_query_num_rows=>15
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No Record Selected'
,p_query_row_count_max=>500
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250911112248Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112248Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14253701436094847)
,p_query_column_id=>1
,p_column_alias=>'ID_ROL'
,p_column_display_sequence=>1
,p_column_heading=>'Id Rol'
,p_heading_alignment=>'LEFT'
,p_hidden_column=>'Y'
,p_display_when_cond_type=>'EXISTS'
,p_display_when_condition=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select 1 from "ROLES"',
'where "ID_ROL" is not null',
'and "ID_ROL" = :P81_ID_ROL'))
,p_updated_on=>wwv_flow_imp.dz('20250911112248Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14254133733094847)
,p_query_column_id=>2
,p_column_alias=>'DESCRIPCION'
,p_column_display_sequence=>2
,p_column_heading=>'Descripcion'
,p_heading_alignment=>'LEFT'
,p_display_when_cond_type=>'EXISTS'
,p_display_when_condition=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select 1 from "ROLES"',
'where "DESCRIPCION" is not null',
'and "ID_ROL" = :P81_ID_ROL'))
,p_updated_on=>wwv_flow_imp.dz('20250911112248Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14254580706094847)
,p_query_column_id=>3
,p_column_alias=>'NOMBRE_ROL'
,p_column_display_sequence=>3
,p_column_heading=>'Nombre Rol'
,p_heading_alignment=>'LEFT'
,p_display_when_cond_type=>'EXISTS'
,p_display_when_condition=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select 1 from "ROLES"',
'where "NOMBRE_ROL" is not null',
'and "ID_ROL" = :P81_ID_ROL'))
,p_updated_on=>wwv_flow_imp.dz('20250911112248Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14257429903094849)
,p_plug_name=>'Region Display Selector'
,p_region_css_classes=>'js-detail-rds'
,p_region_template_options=>'#DEFAULT#:margin-bottom-md'
,p_escape_on_http_output=>'Y'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>20
,p_include_in_reg_disp_sel_yn=>'Y'
,p_query_type=>'SQL'
,p_plug_source_type=>'NATIVE_DISPLAY_SELECTOR'
,p_plug_query_num_rows=>15
,p_plug_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_plug_display_when_condition=>'P81_ID_ROL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'display_region_icons', 'N',
  'include_show_all', 'Y',
  'rds_mode', 'STANDARD',
  'remember_selection', 'N')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250911112248Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112248Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(14257869509094849)
,p_name=>'Roles Privilegios'
,p_template=>4072358936313175081
,p_display_sequence=>30
,p_include_in_reg_disp_sel_yn=>'Y'
,p_region_css_classes=>'js-detail-region'
,p_region_template_options=>'#DEFAULT#:t-Region--noPadding:t-Region--scrollBody'
,p_component_template_options=>'t-Report--stretch:#DEFAULT#:t-Report--altRowsDefault:t-Report--rowHighlight:t-Report--inline'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'TABLE'
,p_query_table=>'ROLES_PRIVILEGIOS'
,p_query_where=>'ID_ROL = :P81_ID_ROL'
,p_include_rowid_column=>true
,p_display_when_condition=>'P81_ID_ROL'
,p_display_condition_type=>'ITEM_IS_NOT_NULL'
,p_ajax_enabled=>'Y'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>100
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>'No data found.'
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_query_row_count_max=>5000
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'Y'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911115438Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(9718006281137628)
,p_query_column_id=>1
,p_column_alias=>'ROWID'
,p_column_display_sequence=>13
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_updated_on=>wwv_flow_imp.dz('20250911114238Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14258913843094954)
,p_query_column_id=>2
,p_column_alias=>'ID_ROL'
,p_column_display_sequence=>2
,p_hidden_column=>'Y'
,p_derived_column=>'N'
,p_updated_on=>wwv_flow_imp.dz('20250911114023Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(14259395680094954)
,p_query_column_id=>3
,p_column_alias=>'ID_PRIV'
,p_column_display_sequence=>3
,p_column_heading=>'Privilegios Asignados'
,p_heading_alignment=>'LEFT'
,p_display_as=>'TEXT_FROM_LOV_ESC'
,p_named_lov=>wwv_flow_imp.id(14274155546125607)
,p_derived_column=>'N'
,p_include_in_export=>'Y'
,p_updated_on=>wwv_flow_imp.dz('20250911115438Z')
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(14270438302094973)
,p_plug_name=>'No Record Selected'
,p_region_template_options=>'#DEFAULT#'
,p_plug_template=>4501440665235496320
,p_plug_display_sequence=>70
,p_plug_source=>'No Record Selected'
,p_plug_display_condition_type=>'ITEM_IS_NULL'
,p_plug_display_when_condition=>'P81_ID_ROL'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML',
  'show_line_breaks', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14261336991094955)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14257869509094849)
,p_button_name=>'POP_ROLES_PRIVILEGIOS'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--noUI'
,p_button_template_id=>2349107722467437027
,p_button_image_alt=>'Add Roles Privilegios'
,p_button_position=>'EDIT'
,p_button_redirect_url=>'f?p=&APP_ID.:83:&APP_SESSION.::&DEBUG.:RP,83:P83_ID_ROL:&P81_ID_ROL.'
,p_icon_css_classes=>'fa-plus'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(14246937338094634)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(14246135692094633)
,p_button_name=>'RESET'
,p_button_action=>'REDIRECT_PAGE'
,p_button_template_options=>'#DEFAULT#:t-Button--noUI:t-Button--iconLeft:t-Button--gapRight'
,p_button_template_id=>2082829544945815391
,p_button_image_alt=>'Reset'
,p_button_position=>'NEXT'
,p_button_redirect_url=>'f?p=&APP_ID.:81:&APP_SESSION.:RESET:&DEBUG.:RP,81::'
,p_icon_css_classes=>'fa-undo-alt'
,p_created_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14248198127094635)
,p_name=>'P81_SEARCH'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(14247651726094634)
,p_prompt=>'Search'
,p_placeholder=>'Search...'
,p_display_as=>'NATIVE_TEXT_FIELD'
,p_cSize=>30
,p_label_alignment=>'RIGHT'
,p_field_template=>2040785906935475274
,p_item_icon_css_classes=>'fa-search'
,p_item_template_options=>'#DEFAULT#:t-Form-fieldContainer--large:t-Form-fieldContainer--postTextBlock'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'disabled', 'N',
  'send_on_page_submit', 'N',
  'submit_when_enter_pressed', 'N',
  'subtype', 'TEXT',
  'trim_spaces', 'BOTH')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250911112246Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112246Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(14257134969094849)
,p_name=>'P81_ID_ROL'
,p_item_sequence=>40
,p_item_plug_id=>wwv_flow_imp.id(14253125526094846)
,p_display_as=>'NATIVE_HIDDEN'
,p_label_alignment=>'RIGHT'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
,p_created_on=>wwv_flow_imp.dz('20250911112248Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112248Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14271263474094974)
,p_name=>'Dialog Closed'
,p_event_sequence=>10
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(14253125526094846)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14271850698094974)
,p_event_id=>wwv_flow_imp.id(14271263474094974)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14253125526094846)
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14272380578094974)
,p_event_id=>wwv_flow_imp.id(14271263474094974)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'apex.message.showPageSuccess(''Roles row(s) updated.'');'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14257985770094849)
,p_name=>'Dialog Closed'
,p_event_sequence=>40
,p_triggering_element_type=>'REGION'
,p_triggering_region_id=>wwv_flow_imp.id(14257869509094849)
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'apexafterclosedialog'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14262047184094955)
,p_event_id=>wwv_flow_imp.id(14257985770094849)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14257869509094849)
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14262583962094955)
,p_event_id=>wwv_flow_imp.id(14257985770094849)
,p_event_result=>'TRUE'
,p_action_sequence=>20
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_JAVASCRIPT_CODE'
,p_attribute_01=>'apex.message.showPageSuccess(''Roles Privilegios row(s) updated.'');'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(14271395362094974)
,p_name=>'Perform Search'
,p_event_sequence=>150
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P81_SEARCH'
,p_triggering_condition_type=>'JAVASCRIPT_EXPRESSION'
,p_triggering_expression=>'this.browserEvent.which === apex.jQuery.ui.keyCode.ENTER'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'keypress'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14273122818094974)
,p_event_id=>wwv_flow_imp.id(14271395362094974)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(14248470386094635)
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(14273682230094974)
,p_event_id=>wwv_flow_imp.id(14271395362094974)
,p_event_result=>'TRUE'
,p_action_sequence=>30
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_CANCEL_EVENT'
,p_created_on=>wwv_flow_imp.dz('20250911112249Z')
,p_updated_on=>wwv_flow_imp.dz('20250911112249Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

prompt --application/pages/page_00147
begin
--   Manifest
--     PAGE: 00147
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
 p_id=>147
,p_name=>'Generar Orden de Pago'
,p_alias=>'GENERAR-ORDEN-DE-PAGO'
,p_step_title=>'Generar Orden de Pago'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_protection_level=>'C'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(36000000000147010)
,p_plug_name=>'Proveedor'
,p_region_template_options=>'#DEFAULT#:t-Form--stretchInputs'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
);
wwv_flow_imp_page.create_report_region(
 p_id=>wwv_flow_imp.id(36000000000147030)
,p_name=>'Cuentas por Pagar pendientes'
,p_template=>4072358936313175081
,p_display_sequence=>20
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_component_template_options=>'#DEFAULT#:t-Report--stretch:t-Report--rowHighlight'
,p_source_type=>'NATIVE_SQL_REPORT'
,p_query_type=>'SQL'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'  APEX_ITEM.HIDDEN(1, id_cxp)                        AS F01,',
'  nro_comprobante                                    AS COMPROBANTE,',
'  TO_CHAR(fecha_vencimiento, ''DD/MM/YYYY'')          AS VENCIMIENTO,',
'  dias_atraso                                        AS DIAS_ATRASO,',
'  saldo                                              AS SALDO,',
'  APEX_ITEM.TEXT(',
'    p_idx       => 2,',
'    p_value     => NULL,',
'    p_size      => 14,',
'    p_maxlength => 14,',
'    p_attributes=> ''style="text-align:right"''',
'  )                                                  AS MONTO_A_PAGAR',
'FROM WKSP_WORKPLACE.V_CXP_DEUDA',
'WHERE id_proveedor = :P147_ID_PROVEEDOR',
'  AND saldo > 0',
'  AND estado <> ''PAGADA''',
'ORDER BY fecha_vencimiento'))
,p_ajax_enabled=>'Y'
,p_ajax_items_to_submit=>'P147_ID_PROVEEDOR'
,p_lazy_loading=>false
,p_query_row_template=>2538654340625403440
,p_query_num_rows=>50
,p_query_options=>'DERIVED_REPORT_COLUMNS'
,p_query_no_data_found=>unistr('Eleg\00ED un proveedor con deuda pendiente.')
,p_query_num_rows_type=>'NEXT_PREVIOUS_LINKS'
,p_pagination_display_position=>'BOTTOM_RIGHT'
,p_csv_output=>'N'
,p_prn_output=>'N'
,p_sort_null=>'L'
,p_plug_query_strip_html=>'N'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000147031)
,p_query_column_id=>1
,p_column_alias=>'F01'
,p_column_display_sequence=>1
,p_column_css_class=>'col-oculta'
,p_heading_alignment=>'LEFT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000147032)
,p_query_column_id=>2
,p_column_alias=>'COMPROBANTE'
,p_column_display_sequence=>2
,p_column_heading=>'Comprobante'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000147033)
,p_query_column_id=>3
,p_column_alias=>'VENCIMIENTO'
,p_column_display_sequence=>3
,p_column_heading=>'Vencimiento'
,p_heading_alignment=>'LEFT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000147034)
,p_query_column_id=>4
,p_column_alias=>'DIAS_ATRASO'
,p_column_display_sequence=>4
,p_column_heading=>unistr('D\00EDas atraso')
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000147035)
,p_query_column_id=>5
,p_column_alias=>'SALDO'
,p_column_display_sequence=>5
,p_column_heading=>'Saldo'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_column_format=>'FML999G999G999G990'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_report_columns(
 p_id=>wwv_flow_imp.id(36000000000147036)
,p_query_column_id=>6
,p_column_alias=>'MONTO_A_PAGAR'
,p_column_display_sequence=>6
,p_column_heading=>'Monto a pagar'
,p_column_alignment=>'RIGHT'
,p_heading_alignment=>'RIGHT'
,p_display_as=>'WITHOUT_MODIFICATION'
,p_derived_column=>'N'
,p_include_in_export=>'Y'
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(36000000000147020)
,p_button_sequence=>10
,p_button_plug_id=>wwv_flow_imp.id(36000000000147030)
,p_button_name=>'GENERAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Generar Orden de Pago'
,p_button_position=>'CHANGE'
,p_icon_css_classes=>'fa-money'
);
wwv_flow_imp_page.create_page_branch(
 p_id=>wwv_flow_imp.id(36000000000147040)
,p_branch_name=>'BR_A_ORDENES_PAGO'
,p_branch_action=>'f?p=&APP_ID.:148:&SESSION.::&DEBUG.:::&success_msg=#SUCCESS_MSG#'
,p_branch_point=>'AFTER_PROCESSING'
,p_branch_type=>'REDIRECT_URL'
,p_branch_when_button_id=>wwv_flow_imp.id(36000000000147020)
,p_branch_sequence=>10
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000147050)
,p_name=>'P147_ID_PROVEEDOR'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(36000000000147010)
,p_prompt=>'Proveedor'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT DISTINCT proveedor d, id_proveedor r',
'  FROM WKSP_WORKPLACE.V_CXP_DEUDA',
' WHERE saldo > 0 AND estado <> ''PAGADA''',
' ORDER BY 1'))
,p_lov_display_null=>'YES'
,p_lov_null_text=>unistr('- eleg\00ED un proveedor -')
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000147051)
,p_name=>'P147_OBSERVACION'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(36000000000147010)
,p_prompt=>unistr('Observaci\00F3n')
,p_display_as=>'NATIVE_TEXTAREA'
,p_cSize=>60
,p_cMaxlength=>255
,p_cHeight=>2
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
);
wwv_flow_imp_page.create_page_da_event(
 p_id=>wwv_flow_imp.id(36000000000147060)
,p_name=>'Cambio de Proveedor - Refrescar'
,p_event_sequence=>10
,p_triggering_element_type=>'ITEM'
,p_triggering_element=>'P147_ID_PROVEEDOR'
,p_bind_type=>'bind'
,p_execution_type=>'IMMEDIATE'
,p_bind_event_type=>'change'
);
wwv_flow_imp_page.create_page_da_action(
 p_id=>wwv_flow_imp.id(36000000000147061)
,p_event_id=>wwv_flow_imp.id(36000000000147060)
,p_event_result=>'TRUE'
,p_action_sequence=>10
,p_execute_on_page_init=>'N'
,p_action=>'NATIVE_REFRESH'
,p_affected_elements_type=>'REGION'
,p_affected_region_id=>wwv_flow_imp.id(36000000000147030)
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(36000000000147070)
,p_process_sequence=>10
,p_process_point=>'ON_SUBMIT_BEFORE_COMPUTATION'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'GENERAR_ORDEN_PAGO'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_ids   SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();',
'  v_monts SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST();',
'  v_monto NUMBER;',
'  v_op    NUMBER;',
'BEGIN',
'  IF NVL(APEX_APPLICATION.G_F01.COUNT,0) = 0 THEN',
'    RAISE_APPLICATION_ERROR(-20935, ''No hay cuentas por pagar para el proveedor.'');',
'  END IF;',
'  FOR i IN 1 .. APEX_APPLICATION.G_F01.COUNT LOOP',
'    IF APEX_APPLICATION.G_F02.COUNT < i THEN CONTINUE; END IF;',
'    v_monto := NVL(TO_NUMBER(REPLACE(REPLACE(TRIM(APEX_APPLICATION.G_F02(i)),''.'',''''),'','','''')), 0);',
'    IF v_monto > 0 THEN',
'      v_ids.EXTEND;   v_ids(v_ids.COUNT)     := TO_NUMBER(APEX_APPLICATION.G_F01(i));',
'      v_monts.EXTEND; v_monts(v_monts.COUNT) := v_monto;',
'    END IF;',
'  END LOOP;',
'  IF v_ids.COUNT = 0 THEN',
'    RAISE_APPLICATION_ERROR(-20935, ''Ingrese al menos un monto a pagar.'');',
'  END IF;',
'  WKSP_WORKPLACE.PRC_GENERAR_ORDEN_PAGO(',
'    p_id_proveedor  => :P147_ID_PROVEEDOR,',
'    p_ids_cxp       => v_ids,',
'    p_montos        => v_monts,',
'    p_observacion   => :P147_OBSERVACION,',
'    p_usuario       => :APP_USER,',
'    p_id_orden_pago => v_op);',
'  apex_application.g_print_success_message :=',
'    ''Orden de pago Nro ''||v_op||'' generada (BORRADOR). Confirmela para ejecutar el pago.'';',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(36000000000147020)
,p_internal_uid=>36000000000147070
);
wwv_flow_imp.component_end;
end;
/

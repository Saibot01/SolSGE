prompt --application/pages/page_00061
begin
--   Manifest
--     PAGE: 00061
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
 p_id=>61
,p_name=>'Cierre de Caja'
,p_alias=>'CIERRE-DE-CAJA'
,p_page_mode=>'MODAL'
,p_step_title=>'Cierre de Caja'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13181578701363537)
,p_plug_name=>'New'
,p_region_template_options=>'#DEFAULT#:t-Region--removeHeader js-removeLandmark:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(13321324650673450)
,p_plug_name=>'Breadcrumb'
,p_region_template_options=>'#DEFAULT#:t-BreadcrumbRegion--useBreadcrumbTitle'
,p_component_template_options=>'#DEFAULT#'
,p_plug_template=>2531463326621247859
,p_plug_display_sequence=>10
,p_plug_display_point=>'REGION_POSITION_01'
,p_menu_id=>wwv_flow_imp.id(7705913887831249)
,p_plug_source_type=>'NATIVE_BREADCRUMB'
,p_menu_template_id=>4072363345357175094
);
wwv_flow_imp_page.create_page_button(
 p_id=>wwv_flow_imp.id(13181881987363540)
,p_button_sequence=>30
,p_button_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_button_name=>'Cierre'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#:t-Button--success'
,p_button_template_id=>4072362960822175091
,p_button_is_hot=>'Y'
,p_button_image_alt=>'Cierre'
,p_button_position=>'CREATE'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(13181623258363538)
,p_name=>'P61_EMPLEADO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_EMPLEADO FROM WKSP_WORKPLACE.EMPLEADOS',
'WHERE UPPER(CODIGO_USUARIO) = UPPER(V(''APP_USER''))'))
,p_item_default_type=>'SQL_QUERY'
,p_display_as=>'NATIVE_HIDDEN'
,p_is_persistent=>'N'
,p_protection_level=>'S'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'value_protected', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(13181623259100000)
,p_name=>'P61_EMPLEADO_NOMBRE'
,p_source_data_type=>'VARCHAR2'
,p_item_sequence=>15
,p_item_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT NOMBRE FROM WKSP_WORKPLACE.EMPLEADOS',
'WHERE UPPER(CODIGO_USUARIO) = UPPER(V(''APP_USER''))'))
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Empleado'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'Y',
  'show_line_breaks', 'Y')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(13181720026363539)
,p_name=>'P61_CAFA_CONF'
,p_item_sequence=>20
,p_item_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_prompt=>'Caja'
,p_display_as=>'NATIVE_SELECT_LIST'
,p_lov=>wwv_flow_string.join(wwv_flow_t_varchar2(
'        select CF.DESCRIPCION, CA.ID_CAJA from CAJA_CONF CF, CAJAS CA',
'        WHERE CF.ID_CAJA_CONF = CA.ID_CAJA_CONF',
'        AND CA.ESTADO = ''A''',
'        AND CA.ID_EMPLEADO = :P61_EMPLEADO'))
,p_lov_cascade_parent_items=>'P61_EMPLEADO'
,p_ajax_optimize_refresh=>'Y'
,p_cHeight=>1
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_lov_display_extra=>'NO'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'page_action_on_selection', 'NONE')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000061010)
,p_name=>'P61_SALDO_ESPERADO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>25
,p_item_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_item_default=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT SUM(v.SALDO_ESPERADO)',
'  FROM WKSP_WORKPLACE.V_CAJA_SALDO v',
'  JOIN WKSP_WORKPLACE.CAJAS c     ON c.ID_CAJA = v.ID_CAJA',
'  JOIN WKSP_WORKPLACE.EMPLEADOS e ON e.ID_EMPLEADO = c.ID_EMPLEADO',
' WHERE UPPER(e.CODIGO_USUARIO) = UPPER(V(''APP_USER''))',
'   AND c.ESTADO = ''A'''))
,p_item_default_type=>'SQL_QUERY'
,p_prompt=>'Saldo esperado (sistema)'
,p_format_mask=>'999G999G999G990'
,p_display_as=>'NATIVE_DISPLAY_ONLY'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'based_on', 'VALUE',
  'format', 'PLAIN',
  'send_on_page_submit', 'N')).to_clob
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(36000000000061020)
,p_name=>'P61_MONTO_DECLARADO'
,p_source_data_type=>'NUMBER'
,p_item_sequence=>27
,p_item_plug_id=>wwv_flow_imp.id(13181578701363537)
,p_prompt=>'Efectivo contado (declarado)'
,p_format_mask=>'999G999G999G990'
,p_display_as=>'NATIVE_NUMBER_FIELD'
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_is_persistent=>'N'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'number_alignment', 'right',
  'virtual_keyboard', 'decimal')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13181927581363541)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Cerrar caja'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    v_decl NUMBER;',
'BEGIN',
'    -- Guardar el efectivo contado antes de cerrar; CERRAR_CAJA v3 calcula',
'    -- MONTO_DIFERENCIA = declarado - esperado por moneda.',
'    -- El item guarda string formateado (215.000) -> parsear quitando . y ,',
'    -- (mismo patron que los totales de P67, ver CLAUDE.md).',
'    IF :P61_MONTO_DECLARADO IS NOT NULL THEN',
'        v_decl := TO_NUMBER(REPLACE(REPLACE(:P61_MONTO_DECLARADO, ''.'', ''''), '','', ''''));',
'        UPDATE WKSP_WORKPLACE.CAJA_MONEDAS',
'           SET MONTO_DECLARADO = v_decl',
'         WHERE ID_CAJA = :P61_CAFA_CONF;',
'    END IF;',
'    WKSP_WORKPLACE.cerrar_caja(p_id_caja => :P61_CAFA_CONF,',
'                              p_usuario => V(''APP_USER''));',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(13181881987363540)
,p_process_success_message=>'Caja cerrada. Pod&eacute;s ver el arqueo desde la pantalla de Estado de Caja.'
,p_internal_uid=>13181927581363541
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13182019412363542)
,p_process_sequence=>20
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_CLOSE_WINDOW'
,p_process_name=>'Dialog close'
,p_attribute_02=>'Y'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>13182019412363542
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(13182019413100000)
,p_process_sequence=>5
,p_process_point=>'BEFORE_HEADER'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Validar caja abierta'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'  v_id_caja NUMBER;',
'BEGIN',
'  v_id_caja := WKSP_WORKPLACE.FN_CAJA_ABIERTA_USUARIO(V(''APP_USER''));',
'  IF v_id_caja IS NULL THEN',
'    apex_error.add_error(',
'      p_message => ''No tenes ninguna caja abierta para cerrar.'',',
'      p_display_location => apex_error.c_inline_in_notification);',
'  END IF;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_internal_uid=>13182019413100000
);
wwv_flow_imp.component_end;
end;
/

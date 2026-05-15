prompt --application/pages/page_00104
begin
--   Manifest
--     PAGE: 00104
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
 p_id=>104
,p_name=>'Carga Masiva Producto-Proveedor'
,p_alias=>'CARGA-MASIVA-PRODUCTO-PROVEEDOR'
,p_page_mode=>'MODAL'
,p_step_title=>'Carga Masiva Producto-Proveedor'
,p_autocomplete_on_off=>'OFF'
,p_page_template_options=>'#DEFAULT#'
,p_required_role=>'MUST_NOT_BE_PUBLIC_USER'
,p_dialog_resizable=>'Y'
,p_protection_level=>'C'
,p_page_component_map=>'16'
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(20236276813558333)
,p_plug_name=>'Instrucciones'
,p_title=>'Instrucciones'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>10
,p_location=>null
,p_plug_source=>unistr('<div class="t-Alert t-Alert--info"><h3>C\00F3mo realizar una carga masiva</h3><ol><li>Prepare un archivo CSV con las columnas (en orden): ID_PRODUCTO, ID_PERSONA, CODIGO_REFERENCIA, PRECIO, FECHA_INICIO, FECHA_FIN, ESTADO</li><li>Seleccione el archivo en')
||unistr(' el campo de abajo</li><li>Presione "Procesar Carga"</li><li>Revise el resultado: registros exitosos y con errores</li></ol><p><strong>Formato de fechas:</strong> DD/MM/YYYY</p><p><strong>Estados v\00E1lidos:</strong> ACTIVO, INACTIVO, SUSPENDIDO</p><p><')
||'strong>Encabezado:</strong> la primera fila debe contener los nombres de las columnas (se saltea).</p></div>'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(20236341923558334)
,p_plug_name=>'Procesar Archivo'
,p_title=>'Procesar Archivo CSV'
,p_region_template_options=>'#DEFAULT#:t-Region--scrollBody'
,p_plug_template=>4072358936313175081
,p_plug_display_sequence=>20
,p_location=>null
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'expand_shortcuts', 'N',
  'output_as', 'HTML')).to_clob
);
wwv_flow_imp_page.create_page_plug(
 p_id=>wwv_flow_imp.id(20377121833516317)
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
 p_id=>wwv_flow_imp.id(20236566353558336)
,p_button_sequence=>20
,p_button_plug_id=>wwv_flow_imp.id(20236341923558334)
,p_button_name=>'PROCESAR'
,p_button_action=>'SUBMIT'
,p_button_template_options=>'#DEFAULT#'
,p_button_template_id=>4072362960822175091
,p_button_image_alt=>'Procesar Carga'
,p_grid_new_row=>'Y'
);
wwv_flow_imp_page.create_page_item(
 p_id=>wwv_flow_imp.id(20236405388558335)
,p_name=>'P104_ARCHIVO'
,p_item_sequence=>10
,p_item_plug_id=>wwv_flow_imp.id(20236341923558334)
,p_prompt=>'Archivo CSV'
,p_display_as=>'NATIVE_FILE'
,p_cSize=>30
,p_field_template=>1609121967514267634
,p_item_template_options=>'#DEFAULT#'
,p_attributes=>wwv_flow_t_plugin_attributes(wwv_flow_t_varchar2(
  'allow_multiple_files', 'N',
  'display_as', 'INLINE',
  'purge_file_at', 'SESSION',
  'storage_type', 'APEX_APPLICATION_TEMP_FILES')).to_clob
);
wwv_flow_imp_page.create_page_process(
 p_id=>wwv_flow_imp.id(20236688371558337)
,p_process_sequence=>10
,p_process_point=>'AFTER_SUBMIT'
,p_process_type=>'NATIVE_PLSQL'
,p_process_name=>'Procesar CSV'
,p_process_sql_clob=>wwv_flow_string.join(wwv_flow_t_varchar2(
'DECLARE',
'    v_id_carga      NUMBER := SEQ_CARGA_MASIVA_PP.NEXTVAL;',
'    v_exitosos      NUMBER := 0;',
'    v_errores       NUMBER := 0;',
'    v_blob          BLOB;',
'    v_nombre        VARCHAR2(255);',
'    v_error_msg     VARCHAR2(500);',
'BEGIN',
'    SELECT BLOB_CONTENT, FILENAME INTO v_blob, v_nombre',
'      FROM APEX_APPLICATION_TEMP_FILES',
'     WHERE NAME = :P104_ARCHIVO',
'     FETCH FIRST 1 ROW ONLY;',
'',
'    INSERT INTO CARGA_MASIVA_PP (ID_CARGA, USUARIO_CARGA, NOMBRE_ARCHIVO, ESTADO_CARGA)',
'    VALUES (v_id_carga, NVL(V(''APP_USER''), USER), v_nombre, ''PROCESANDO'');',
'',
'    FOR rec IN (',
'        SELECT LINE_NUMBER,',
'               COL001 AS ID_PRODUCTO, COL002 AS ID_PERSONA,',
'               COL003 AS CODIGO_REFERENCIA, COL004 AS PRECIO,',
'               COL005 AS FECHA_INICIO, COL006 AS FECHA_FIN, COL007 AS ESTADO',
'          FROM TABLE(APEX_DATA_PARSER.PARSE(',
'                 p_content => v_blob,',
'                 p_file_type => APEX_DATA_PARSER.c_file_type_csv,',
'                 p_skip_rows => 1))',
'    )',
'    LOOP',
'        BEGIN',
'            INSERT INTO PRODUCTO_PROVEEDORES',
'                (ID_PRODUCTO, ID_PERSONA, CODIGO_REFERENCIA, PRECIO,',
'                 FECHA_INICIO, FECHA_FIN, ESTADO, FECHA_CREACION, USUARIO_CREACION)',
'            VALUES',
'                (TO_NUMBER(rec.ID_PRODUCTO),',
'                 TO_NUMBER(rec.ID_PERSONA),',
'                 rec.CODIGO_REFERENCIA,',
'                 TO_NUMBER(rec.PRECIO),',
'                 NVL(TO_DATE(rec.FECHA_INICIO, ''DD/MM/YYYY''), TRUNC(SYSDATE)),',
'                 CASE WHEN rec.FECHA_FIN IS NOT NULL THEN TO_DATE(rec.FECHA_FIN, ''DD/MM/YYYY'') ELSE NULL END,',
'                 NVL(rec.ESTADO, ''ACTIVO''),',
'                 SYSDATE,',
'                 NVL(V(''APP_USER''), USER));',
'',
'            v_exitosos := v_exitosos + 1;',
'',
'            INSERT INTO DETALLE_CARGA_MASIVA_PP',
'                (ID_DETALLE, ID_CARGA, FILA_NUMERO, ID_PRODUCTO, ID_PERSONA,',
'                 PRECIO, ESTADO_PROCESAMIENTO)',
'            VALUES',
'                (SEQ_DETALLE_CARGA_PP.NEXTVAL, v_id_carga, rec.LINE_NUMBER,',
'                 TO_NUMBER(rec.ID_PRODUCTO), TO_NUMBER(rec.ID_PERSONA),',
'                 TO_NUMBER(rec.PRECIO), ''EXITOSO'');',
'',
'        EXCEPTION WHEN OTHERS THEN',
'            v_error_msg := SUBSTR(SQLERRM, 1, 500);',
'            v_errores := v_errores + 1;',
'            INSERT INTO DETALLE_CARGA_MASIVA_PP',
'                (ID_DETALLE, ID_CARGA, FILA_NUMERO,',
'                 ESTADO_PROCESAMIENTO, MENSAJE_ERROR)',
'            VALUES',
'                (SEQ_DETALLE_CARGA_PP.NEXTVAL, v_id_carga, rec.LINE_NUMBER,',
'                 ''ERROR'', v_error_msg);',
'        END;',
'    END LOOP;',
'',
'    UPDATE CARGA_MASIVA_PP',
'       SET REGISTROS_TOTALES = v_exitosos + v_errores,',
'           REGISTROS_EXITOSOS = v_exitosos,',
'           REGISTROS_ERROR = v_errores,',
'           ESTADO_CARGA = ''COMPLETADO'',',
'           FECHA_FINALIZACION = SYSDATE',
'     WHERE ID_CARGA = v_id_carga;',
'',
'    DELETE FROM APEX_APPLICATION_TEMP_FILES WHERE NAME = :P104_ARCHIVO;',
'    COMMIT;',
'',
'    apex_application.g_print_success_message :=',
'        ''Carga completada. Exitosos: '' || v_exitosos || '' | Errores: '' || v_errores;',
'END;'))
,p_process_clob_language=>'PLSQL'
,p_error_display_location=>'INLINE_IN_NOTIFICATION'
,p_process_when_button_id=>wwv_flow_imp.id(20236566353558336)
,p_internal_uid=>20236688371558337
);
wwv_flow_imp.component_end;
end;
/

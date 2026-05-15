prompt --application/shared_components/user_interface/lovs/orden_compra_estado
begin
--   Manifest
--     ORDEN.COMPRA.ESTADO
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_shared.create_list_of_values(
 p_id=>wwv_flow_imp.id(20547606844078370)
,p_lov_name=>'ORDEN.COMPRA.ESTADO'
,p_lov_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('SELECT ''Borrador (pendiente aprobaci\00F3n)'' AS DISPLAY_VALUE, ''B'' AS RETURN_VALUE FROM DUAL UNION ALL'),
'SELECT ''Rechazada''                       AS DISPLAY_VALUE, ''X'' AS RETURN_VALUE FROM DUAL UNION ALL',
unistr('SELECT ''Pendiente recepci\00F3n''             AS DISPLAY_VALUE, ''P'' AS RETURN_VALUE FROM DUAL UNION ALL'),
unistr('SELECT ''Recepci\00F3n parcial''               AS DISPLAY_VALUE, ''R'' AS RETURN_VALUE FROM DUAL UNION ALL'),
'SELECT ''Completada''                      AS DISPLAY_VALUE, ''C'' AS RETURN_VALUE FROM DUAL UNION ALL',
'SELECT ''Anulada''                         AS DISPLAY_VALUE, ''A'' AS RETURN_VALUE FROM DUAL'))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'RETURN_VALUE'
,p_display_column_name=>'DISPLAY_VALUE'
,p_default_sort_column_name=>'DISPLAY_VALUE'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39028487389336
,p_created_on=>wwv_flow_imp.dz('20260513184437Z')
,p_updated_on=>wwv_flow_imp.dz('20260513184437Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

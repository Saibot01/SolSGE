prompt --application/shared_components/user_interface/lovs/paginas
begin
--   Manifest
--     PAGINAS
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
 p_id=>wwv_flow_imp.id(14307748367169201)
,p_lov_name=>'PAGINAS'
,p_lov_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT page_id || '' - '' || page_name d, page_id r',
'FROM apex_application_pages',
'WHERE application_id = :APP_ID',
'ORDER BY page_id',
''))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'R'
,p_display_column_name=>'D'
,p_version_scn=>39020676987891
,p_created_on=>wwv_flow_imp.dz('20250912205512Z')
,p_updated_on=>wwv_flow_imp.dz('20250912205512Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

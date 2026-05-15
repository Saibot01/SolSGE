prompt --application/shared_components/user_interface/lovs/privilegios
begin
--   Manifest
--     PRIVILEGIOS
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
 p_id=>wwv_flow_imp.id(14274155546125607)
,p_lov_name=>'PRIVILEGIOS'
,p_lov_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
unistr('SELECT codigo || '' \2014 '' || nombre d, id_priv r'),
'FROM privilegios',
'WHERE activo = ''S''',
'ORDER BY codigo',
''))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'R'
,p_display_column_name=>'D'
,p_group_sort_direction=>'ASC'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39020634237934
);
wwv_flow_imp.component_end;
end;
/

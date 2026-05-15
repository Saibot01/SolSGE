prompt --application/shared_components/user_interface/lovs/departamentos_descripcion_002
begin
--   Manifest
--     DEPARTAMENTOS_DESCRIPCION
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
 p_id=>wwv_flow_imp.id(9560460040296102)
,p_lov_name=>'DEPARTAMENTOS_DESCRIPCION'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'DEPARTAMENTOS'
,p_return_column_name=>'CODIGO_DEPARTAMENTO'
,p_display_column_name=>'DESCRIPCION'
,p_default_sort_column_name=>'DESCRIPCION'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39016125594267
,p_created_on=>wwv_flow_imp.dz('20250411043823Z')
,p_updated_on=>wwv_flow_imp.dz('20250411043823Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

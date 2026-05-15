prompt --application/shared_components/user_interface/lovs/ciudades_descripcion
begin
--   Manifest
--     CIUDADES.DESCRIPCION
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
 p_id=>wwv_flow_imp.id(8271971343904544)
,p_lov_name=>'CIUDADES.DESCRIPCION'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'CIUDADES'
,p_return_column_name=>'CODIGO_CIUDAD'
,p_display_column_name=>'DESCRIPCION'
,p_default_sort_column_name=>'DESCRIPCION'
,p_default_sort_direction=>'ASC'
,p_version_scn=>1
);
wwv_flow_imp.component_end;
end;
/

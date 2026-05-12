prompt --application/shared_components/user_interface/lovs/marcas_nombre
begin
--   Manifest
--     MARCAS.NOMBRE
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
 p_id=>wwv_flow_imp.id(11731866542122404)
,p_lov_name=>'MARCAS.NOMBRE'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'MARCAS'
,p_return_column_name=>'ID_MARCA'
,p_display_column_name=>'NOMBRE'
,p_default_sort_column_name=>'NOMBRE'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39016810856983
,p_created_on=>wwv_flow_imp.dz('20250507104246Z')
,p_updated_on=>wwv_flow_imp.dz('20250507104246Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

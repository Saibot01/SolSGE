prompt --application/shared_components/user_interface/lovs/roles_descripcion
begin
--   Manifest
--     ROLES.DESCRIPCION
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
 p_id=>wwv_flow_imp.id(8200076655452666)
,p_lov_name=>'ROLES.DESCRIPCION'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'ROLES'
,p_return_column_name=>'ID_ROL'
,p_display_column_name=>'NOMBRE_ROL'
,p_group_sort_direction=>'ASC'
,p_default_sort_column_name=>'ID_ROL'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39011082233173
,p_created_on=>wwv_flow_imp.dz('20240613200015Z')
,p_updated_on=>wwv_flow_imp.dz('20241003062654Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9468917203652253)
,p_query_column_name=>'DESCRIPCION'
,p_heading=>'Descripcion'
,p_display_sequence=>10
,p_data_type=>'VARCHAR2'
,p_created_on=>wwv_flow_imp.dz('20241003062654Z')
,p_updated_on=>wwv_flow_imp.dz('20241003062654Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9469392075652252)
,p_query_column_name=>'ID_ROL'
,p_display_sequence=>10
,p_data_type=>'NUMBER'
,p_is_visible=>'N'
,p_is_searchable=>'N'
,p_created_on=>wwv_flow_imp.dz('20241003062654Z')
,p_updated_on=>wwv_flow_imp.dz('20241003062654Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9469724605652252)
,p_query_column_name=>'NOMBRE_ROL'
,p_heading=>'Nombre Rol'
,p_display_sequence=>20
,p_data_type=>'VARCHAR2'
,p_created_on=>wwv_flow_imp.dz('20241003062654Z')
,p_updated_on=>wwv_flow_imp.dz('20241003062654Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

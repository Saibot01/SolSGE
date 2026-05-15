prompt --application/shared_components/user_interface/lovs/cuentas_cobrar_estado
begin
--   Manifest
--     CUENTAS_COBRAR.ESTADO
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
 p_id=>wwv_flow_imp.id(16173138010278063)
,p_lov_name=>'CUENTAS_COBRAR.ESTADO'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'CUENTAS_COBRAR'
,p_return_column_name=>'ID_CXC'
,p_display_column_name=>'ESTADO'
,p_default_sort_column_name=>'ESTADO'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39022415720973
);
wwv_flow_imp.component_end;
end;
/

prompt --application/shared_components/user_interface/lovs/privilegios_codigo
begin
--   Manifest
--     PRIVILEGIOS.CODIGO
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
 p_id=>wwv_flow_imp.id(14221605211057287)
,p_lov_name=>'PRIVILEGIOS.CODIGO'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'PRIVILEGIOS'
,p_return_column_name=>'ID_PRIV'
,p_display_column_name=>'CODIGO'
,p_default_sort_column_name=>'CODIGO'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39020633635585
);
wwv_flow_imp.component_end;
end;
/

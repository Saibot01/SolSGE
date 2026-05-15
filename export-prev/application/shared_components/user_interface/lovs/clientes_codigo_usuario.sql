prompt --application/shared_components/user_interface/lovs/clientes_codigo_usuario
begin
--   Manifest
--     CLIENTES.CODIGO_USUARIO
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
 p_id=>wwv_flow_imp.id(11876156031937503)
,p_lov_name=>'CLIENTES.CODIGO_USUARIO'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'CLIENTES'
,p_return_column_name=>'ID_PERSONA'
,p_display_column_name=>'CODIGO_USUARIO'
,p_default_sort_column_name=>'CODIGO_USUARIO'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39016828366252
,p_created_on=>wwv_flow_imp.dz('20250508000517Z')
,p_updated_on=>wwv_flow_imp.dz('20250508000517Z')
,p_created_by=>'WILLIAN'
,p_updated_by=>'WILLIAN'
);
wwv_flow_imp.component_end;
end;
/

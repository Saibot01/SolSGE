prompt --application/shared_components/user_interface/lovs/personas_nro_documento
begin
--   Manifest
--     PERSONAS.NRO_DOCUMENTO
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
 p_id=>wwv_flow_imp.id(8198960032452668)
,p_lov_name=>'PERSONAS.NRO_DOCUMENTO'
,p_lov_query=>'select id_persona AS return_value, nro_documento AS display_value from PERSONAS;'
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'RETURN_VALUE'
,p_display_column_name=>'DISPLAY_VALUE'
,p_group_sort_direction=>'ASC'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39016075434622
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9085369221741110)
,p_query_column_name=>'DISPLAY_VALUE'
,p_display_sequence=>10
,p_data_type=>'VARCHAR2'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9086101895741110)
,p_query_column_name=>'RETURN_VALUE'
,p_display_sequence=>10
,p_data_type=>'NUMBER'
,p_is_visible=>'N'
,p_is_searchable=>'N'
);
wwv_flow_imp.component_end;
end;
/

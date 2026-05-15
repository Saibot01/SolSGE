prompt --application/shared_components/user_interface/lovs/personas_nro_documento_1
begin
--   Manifest
--     PERSONAS.NRO_DOCUMENTO_1
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
 p_id=>wwv_flow_imp.id(9739886888480172)
,p_lov_name=>'PERSONAS.NRO_DOCUMENTO_1'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'PERSONAS'
,p_return_column_name=>'ID_PERSONA'
,p_display_column_name=>'NRO_DOCUMENTO'
,p_default_sort_column_name=>'NRO_DOCUMENTO'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39016142453134
);
wwv_flow_imp.component_end;
end;
/

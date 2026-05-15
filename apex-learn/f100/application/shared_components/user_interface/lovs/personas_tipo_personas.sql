prompt --application/shared_components/user_interface/lovs/personas_tipo_personas
begin
--   Manifest
--     PERSONAS.TIPO_PERSONAS
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
 p_id=>wwv_flow_imp.id(9865384577955740)
,p_lov_name=>'PERSONAS.TIPO_PERSONAS'
,p_lov_query=>'.'||wwv_flow_imp.id(9865384577955740)||'.'
,p_location=>'STATIC'
,p_version_scn=>39011248782681
);
wwv_flow_imp_shared.create_static_lov_data(
 p_id=>wwv_flow_imp.id(9865610198955740)
,p_lov_disp_sequence=>1
,p_lov_disp_value=>'Fisica'
,p_lov_return_value=>'F'
);
wwv_flow_imp_shared.create_static_lov_data(
 p_id=>wwv_flow_imp.id(9866045019955740)
,p_lov_disp_sequence=>2
,p_lov_disp_value=>'Juridica'
,p_lov_return_value=>'J'
);
wwv_flow_imp.component_end;
end;
/

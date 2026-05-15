prompt --application/shared_components/user_interface/lovs/personas_estado_civil
begin
--   Manifest
--     PERSONAS.ESTADO_CIVIL
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
 p_id=>wwv_flow_imp.id(9869190961536364)
,p_lov_name=>'PERSONAS.ESTADO_CIVIL'
,p_lov_query=>'.'||wwv_flow_imp.id(9869190961536364)||'.'
,p_location=>'STATIC'
,p_version_scn=>39011250084240
);
wwv_flow_imp_shared.create_static_lov_data(
 p_id=>wwv_flow_imp.id(9869409245536364)
,p_lov_disp_sequence=>1
,p_lov_disp_value=>'Soltero'
,p_lov_return_value=>'Soltero'
);
wwv_flow_imp_shared.create_static_lov_data(
 p_id=>wwv_flow_imp.id(9869854652536363)
,p_lov_disp_sequence=>2
,p_lov_disp_value=>'Casado'
,p_lov_return_value=>'Casado'
);
wwv_flow_imp.component_end;
end;
/

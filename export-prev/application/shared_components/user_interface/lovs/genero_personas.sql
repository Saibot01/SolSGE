prompt --application/shared_components/user_interface/lovs/genero_personas
begin
--   Manifest
--     GENERO.PERSONAS
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
 p_id=>wwv_flow_imp.id(9862450697075304)
,p_lov_name=>'GENERO.PERSONAS'
,p_lov_query=>'.'||wwv_flow_imp.id(9862450697075304)||'.'
,p_location=>'STATIC'
,p_version_scn=>39011248383820
,p_created_on=>wwv_flow_imp.dz('20241009054304Z')
,p_updated_on=>wwv_flow_imp.dz('20241009054304Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_static_lov_data(
 p_id=>wwv_flow_imp.id(9862736885075289)
,p_lov_disp_sequence=>1
,p_lov_disp_value=>'Femenino'
,p_lov_return_value=>'F'
);
wwv_flow_imp_shared.create_static_lov_data(
 p_id=>wwv_flow_imp.id(9863151162075287)
,p_lov_disp_sequence=>2
,p_lov_disp_value=>'Masculino'
,p_lov_return_value=>'M'
);
wwv_flow_imp.component_end;
end;
/

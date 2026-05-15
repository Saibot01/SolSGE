prompt --application/shared_components/user_interface/lovs/proveedores_nombre
begin
--   Manifest
--     PROVEEDORES.NOMBRE
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
 p_id=>wwv_flow_imp.id(16407555954331446)
,p_lov_name=>'PROVEEDORES.NOMBRE'
,p_lov_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ',
'  p.primer_nombre || '' '' || p.primer_apellido  AS display_value,',
'  pr.id_persona                             AS return_value',
'FROM proveedores pr',
'JOIN personas p ',
'     ON p.id_persona = pr.id_persona',
'ORDER BY p.primer_nombre, p.primer_apellido;',
''))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'RETURN_VALUE'
,p_display_column_name=>'DISPLAY_VALUE'
,p_version_scn=>39022934645296
,p_created_on=>wwv_flow_imp.dz('20251121055653Z')
,p_updated_on=>wwv_flow_imp.dz('20251121055653Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

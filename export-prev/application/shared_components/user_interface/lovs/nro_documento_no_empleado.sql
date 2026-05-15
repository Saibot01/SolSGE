prompt --application/shared_components/user_interface/lovs/nro_documento_no_empleado
begin
--   Manifest
--     NRO_DOCUMENTO_NO_EMPLEADO
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
 p_id=>wwv_flow_imp.id(9793773505161707)
,p_lov_name=>'NRO_DOCUMENTO_NO_EMPLEADO'
,p_lov_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ID_PERSONA,',
'       NRO_DOCUMENTO ,',
'       primer_nombre || '' '' || NVL(segundo_nombre, '''') || '' '' || primer_apellido || '' '' || NVL(segundo_apellido, '''') AS nombre_completo',
'FROM PERSONAS',
'WHERE ID_PERSONA NOT IN (',
'  SELECT ID_PERSONA FROM EMPLEADOS WHERE ID_PERSONA IS NOT NULL',
')'))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'ID_PERSONA'
,p_display_column_name=>'NRO_DOCUMENTO'
,p_group_sort_direction=>'ASC'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39016147982876
,p_created_on=>wwv_flow_imp.dz('20250411234239Z')
,p_updated_on=>wwv_flow_imp.dz('20250411234849Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9794418840161709)
,p_query_column_name=>'ID_PERSONA'
,p_heading=>'Id Persona'
,p_display_sequence=>10
,p_data_type=>'NUMBER'
,p_created_on=>wwv_flow_imp.dz('20250411234239Z')
,p_updated_on=>wwv_flow_imp.dz('20250411234849Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9794815816161709)
,p_query_column_name=>'NRO_DOCUMENTO'
,p_heading=>'Nro Documento'
,p_display_sequence=>20
,p_data_type=>'VARCHAR2'
,p_created_on=>wwv_flow_imp.dz('20250411234239Z')
,p_updated_on=>wwv_flow_imp.dz('20250411234849Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9794078939161708)
,p_query_column_name=>'NOMBRE_COMPLETO'
,p_heading=>'Nombre Completo'
,p_display_sequence=>30
,p_data_type=>'VARCHAR2'
,p_created_on=>wwv_flow_imp.dz('20250411234239Z')
,p_updated_on=>wwv_flow_imp.dz('20250411234849Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

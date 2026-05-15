prompt --application/shared_components/user_interface/lovs/lov_personas_clientes
begin
--   Manifest
--     LOV_PERSONAS_CLIENTES
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
 p_id=>wwv_flow_imp.id(9071179770229504)
,p_lov_name=>'LOV_PERSONAS_CLIENTES'
,p_lov_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT ',
'  p.nro_documento AS display_value,',
'  p.id_persona AS return_value,',
'  p.primer_nombre || '' '' || NVL(p.segundo_nombre, '''') || '' '' || p.primer_apellido || '' '' || NVL(p.segundo_apellido, '''') AS NOMBRE_COMPLETO,',
'  p.correo',
'FROM personas p'))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'RETURN_VALUE'
,p_display_column_name=>'DISPLAY_VALUE'
,p_group_sort_direction=>'ASC'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39016139655279
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9075994573402087)
,p_query_column_name=>'RETURN_VALUE'
,p_display_sequence=>10
,p_data_type=>'NUMBER'
,p_is_visible=>'N'
,p_is_searchable=>'N'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9111814547391636)
,p_query_column_name=>'NOMBRE_COMPLETO'
,p_heading=>'Nombre Completo'
,p_display_sequence=>10
,p_data_type=>'VARCHAR2'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9076388704402088)
,p_query_column_name=>'DISPLAY_VALUE'
,p_heading=>'Display Value'
,p_display_sequence=>20
,p_data_type=>'VARCHAR2'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(9104426357335316)
,p_query_column_name=>'CORREO'
,p_heading=>'Correo'
,p_display_sequence=>40
,p_data_type=>'VARCHAR2'
);
wwv_flow_imp.component_end;
end;
/

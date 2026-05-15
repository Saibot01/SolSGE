prompt --application/shared_components/user_interface/lovs/caja_conf_descripcion
begin
--   Manifest
--     CAJA_CONF.DESCRIPCION
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
 p_id=>wwv_flow_imp.id(12751376604199345)
,p_lov_name=>'CAJA_CONF.DESCRIPCION'
,p_source_type=>'TABLE'
,p_location=>'LOCAL'
,p_query_table=>'CAJA_CONF'
,p_return_column_name=>'ID_CAJA_CONF'
,p_display_column_name=>'DESCRIPCION'
,p_default_sort_column_name=>'DESCRIPCION'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39017434676581
);
wwv_flow_imp.component_end;
end;
/

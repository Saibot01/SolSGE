prompt --application/shared_components/user_interface/lovs/productos_proveedor_precio
begin
--   Manifest
--     PRODUCTOS.PROVEEDOR.PRECIO
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
 p_id=>wwv_flow_imp.id(16414606219603120)
,p_lov_name=>'PRODUCTOS.PROVEEDOR.PRECIO'
,p_lov_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select pro.nombre, pro.id_producto, per.primer_nombre||'' ''||per.primer_apellido as Proveedor, CAT.PRECIO',
'from productos pro, PRODUCTO_PROVEEDORES  cat, personas per',
'    where pro.id_producto = cat.id_producto',
'    and per.id_persona = cat.ID_PERSONA',
'    and cat.ID_PERSONA = NVL(:P72_ID_PROVEEDOR,cat.ID_PERSONA);'))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'ID_PRODUCTO'
,p_display_column_name=>'NOMBRE'
,p_group_sort_direction=>'ASC'
,p_default_sort_column_name=>'NOMBRE'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39022939245471
,p_created_on=>wwv_flow_imp.dz('20251121092849Z')
,p_updated_on=>wwv_flow_imp.dz('20251121092948Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(16415151760609025)
,p_query_column_name=>'ID_PRODUCTO'
,p_display_sequence=>10
,p_data_type=>'NUMBER'
,p_is_visible=>'N'
,p_is_searchable=>'N'
,p_created_on=>wwv_flow_imp.dz('20251121092948Z')
,p_updated_on=>wwv_flow_imp.dz('20251121092948Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(16415540406609025)
,p_query_column_name=>'NOMBRE'
,p_heading=>'Nombre'
,p_display_sequence=>20
,p_data_type=>'VARCHAR2'
,p_created_on=>wwv_flow_imp.dz('20251121092948Z')
,p_updated_on=>wwv_flow_imp.dz('20251121092948Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(16415981507609026)
,p_query_column_name=>'PROVEEDOR'
,p_heading=>'Proveedor'
,p_display_sequence=>30
,p_data_type=>'VARCHAR2'
,p_created_on=>wwv_flow_imp.dz('20251121092948Z')
,p_updated_on=>wwv_flow_imp.dz('20251121092948Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(16416346364609026)
,p_query_column_name=>'PRECIO'
,p_heading=>'Precio'
,p_display_sequence=>40
,p_data_type=>'NUMBER'
,p_created_on=>wwv_flow_imp.dz('20251121092948Z')
,p_updated_on=>wwv_flow_imp.dz('20251121092948Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

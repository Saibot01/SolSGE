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
'/*select pro.nombre, pro.id_producto, per.primer_nombre||'' ''||per.primer_apellido as Proveedor, CAT.PRECIO',
'from productos pro, PRODUCTO_PROVEEDORES  cat, personas per',
'    where pro.id_producto = cat.id_producto',
'    and per.id_persona = cat.ID_PERSONA',
'    and cat.ID_PERSONA = NVL(:P72_ID_PROVEEDOR,cat.ID_PERSONA);*/',
'SELECT ',
'  vv.PRODUCTO_NOMBRE                       AS PRODUCTO,',
'  vv.ID_PRODUCTO                           AS RETURN_VALUE,',
'  vv.PROVEEDOR_NOMBRE                      AS PROVEEDOR,',
'  vv.PRECIO                                AS PRECIO_PROVEEDOR,',
'  vmin.PRECIO                              AS PRECIO_MINIMO,',
'  /*CASE ',
'    WHEN vmin.PROVEEDOR_NOMBRE = vv.PROVEEDOR_NOMBRE ',
unistr('    THEN ''\2713 ''||vmin.PROVEEDOR_NOMBRE'),
'    ELSE vmin.PROVEEDOR_NOMBRE',
'  END                                      AS PROV_MAS_BARATO,*/',
'  ROUND(vv.PRECIO - vmin.PRECIO, 2)       AS DIFERENCIA',
'FROM V_PRODUCTO_PROVEEDOR_VIGENTE vv',
'JOIN V_COMPARATIVA_PRECIO_PROVEEDORES vmin ',
'  ON  vmin.ID_PRODUCTO    = vv.ID_PRODUCTO',
'  AND vmin.RANKING_PRECIO = 1',
'WHERE vv.ID_PERSONA = NVL(:P72_ID_PROVEEDOR, vv.ID_PERSONA)',
'  AND vv.VIGENCIA   = ''VIGENTE''',
'ORDER BY vv.PRODUCTO_NOMBRE'))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'RETURN_VALUE'
,p_display_column_name=>'PRODUCTO'
,p_group_sort_direction=>'ASC'
,p_default_sort_direction=>'ASC'
,p_version_scn=>39028467507936
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(20464523001931060)
,p_query_column_name=>'PRODUCTO'
,p_heading=>'Producto'
,p_display_sequence=>10
,p_data_type=>'VARCHAR2'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(20476028939117068)
,p_query_column_name=>'PROVEEDOR'
,p_heading=>'Proveedor'
,p_display_sequence=>10
,p_data_type=>'VARCHAR2'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(20464925812931060)
,p_query_column_name=>'PRECIO_PROVEEDOR'
,p_heading=>'Precio'
,p_display_sequence=>20
,p_data_type=>'NUMBER'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(20465330984931061)
,p_query_column_name=>'PRECIO_MINIMO'
,p_heading=>'Precio/Minimo'
,p_display_sequence=>30
,p_data_type=>'NUMBER'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(20466178952931061)
,p_query_column_name=>'DIFERENCIA'
,p_heading=>'Diferencia'
,p_display_sequence=>50
,p_data_type=>'NUMBER'
);
wwv_flow_imp_shared.create_list_of_values_cols(
 p_id=>wwv_flow_imp.id(20466513387931061)
,p_query_column_name=>'RETURN_VALUE'
,p_display_sequence=>60
,p_data_type=>'NUMBER'
,p_is_visible=>'N'
);
wwv_flow_imp.component_end;
end;
/

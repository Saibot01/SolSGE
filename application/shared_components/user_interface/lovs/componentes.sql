prompt --application/shared_components/user_interface/lovs/componentes
begin
--   Manifest
--     COMPONENTES
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
 p_id=>wwv_flow_imp.id(14309889205348202)
,p_lov_name=>'COMPONENTES'
,p_lov_query=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT label d, comp_key r',
'FROM (',
'  -- Regiones',
unistr('  SELECT ''[''||region_name||''] Regi\00F3n'' AS label,'),
'         ''REG:''||region_name          AS comp_key',
'  FROM apex_application_page_regions',
'  WHERE application_id = :APP_ID',
'    AND page_id        = :PAGE_ID',
'    AND region_name    IS NOT NULL',
'',
'  UNION ALL',
'',
'  -- Botones',
unistr('  SELECT ''[''||button_name||''] Bot\00F3n'' AS label,'),
'         ''BTN:''||button_name         AS comp_key',
'  FROM apex_application_page_buttons',
'  WHERE application_id = :APP_ID',
'    AND page_id        = :PAGE_ID',
'    AND button_name    IS NOT NULL',
'',
'  UNION ALL',
'',
unistr('  -- \00CDtems'),
unistr('  SELECT ''[''||item_name||''] \00CDtem''    AS label,'),
'         ''ITEM:''||item_name          AS comp_key',
'  FROM apex_application_page_items',
'  WHERE application_id = :APP_ID',
'    AND page_id        = :PAGE_ID',
'    AND item_name      IS NOT NULL',
')',
'ORDER BY 1',
''))
,p_source_type=>'SQL'
,p_location=>'LOCAL'
,p_return_column_name=>'R'
,p_display_column_name=>'D'
,p_version_scn=>39020677653435
,p_created_on=>wwv_flow_imp.dz('20250912212502Z')
,p_updated_on=>wwv_flow_imp.dz('20250912212502Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'SIS_APEX'
);
wwv_flow_imp.component_end;
end;
/

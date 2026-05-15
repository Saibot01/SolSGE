prompt --application/deployment/definition
begin
--   Manifest
--     INSTALL: 100
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_shared.create_install(
 p_id=>wwv_flow_imp.id(8109038481455350)
);
wwv_flow_imp.component_end;
end;
/

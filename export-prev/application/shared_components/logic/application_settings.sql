prompt --application/shared_components/logic/application_settings
begin
--   Manifest
--     APPLICATION SETTINGS: 100
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_shared.create_app_setting(
 p_id=>wwv_flow_imp.id(8000362412830896)
,p_name=>'ACCESS_CONTROL_SCOPE'
,p_value=>'ACL_ONLY'
,p_is_required=>'N'
,p_valid_values=>'ACL_ONLY, ALL_USERS'
,p_on_upgrade_keep_value=>true
,p_required_patch=>wwv_flow_imp.id(7997625436830901)
,p_comments=>'The default access level given to authenticated users who are not in the access control list'
,p_version_scn=>39016148187932
,p_created_on=>wwv_flow_imp.dz('20240606062353Z')
,p_updated_on=>wwv_flow_imp.dz('20250412000018Z')
,p_created_by=>'SIS_APEX'
,p_updated_by=>'TCASCO'
);
wwv_flow_imp.component_end;
end;
/

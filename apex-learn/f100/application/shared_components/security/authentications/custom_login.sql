prompt --application/shared_components/security/authentications/custom_login
begin
--   Manifest
--     AUTHENTICATION: Custom_login
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_shared.create_authentication(
 p_id=>wwv_flow_imp.id(10305647656027707)
,p_name=>'Custom_login'
,p_scheme_type=>'NATIVE_CUSTOM'
,p_attribute_03=>'AUT_PKG.AUTENTICACION_LOGIN'
,p_attribute_05=>'N'
,p_invalid_session_type=>'LOGIN'
,p_use_secure_cookie_yn=>'N'
,p_ras_mode=>0
,p_version_scn=>39015609427875
);
wwv_flow_imp.component_end;
end;
/

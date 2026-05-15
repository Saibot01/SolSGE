prompt --application/shared_components/security/authorizations/auth_page_by_priv
begin
--   Manifest
--     SECURITY SCHEME: AUTH_PAGE_BY_PRIV
--   Manifest End
wwv_flow_imp.component_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.15'
,p_default_workspace_id=>7697821598969118
,p_default_application_id=>100
,p_default_id_offset=>0
,p_default_owner=>'WKSP_WORKPLACE'
);
wwv_flow_imp_shared.create_security_scheme(
 p_id=>wwv_flow_imp.id(14144931354359505)
,p_name=>'AUTH_PAGE_BY_PRIV'
,p_scheme_type=>'NATIVE_FUNCTION_BODY'
,p_attribute_01=>'RETURN security_pkg.can_access(:APP_ID, :APP_USER, :APP_PAGE_ID, NULL);'
,p_error_message=>'No cuenta con los permisos necesarios para acceder a este modulo. Contacte con el administrador del sistema'
,p_version_scn=>39027535884097
,p_caching=>'BY_USER_BY_PAGE_VIEW'
,p_comments=>'Autorizacion Custom'
);
wwv_flow_imp.component_end;
end;
/

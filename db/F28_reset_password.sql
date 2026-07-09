--------------------------------------------------------------------------------
-- F28_reset_password.sql
-- Restablecimiento de contraseña (F28) — vía ADMINISTRADOR (sin dependencia de correo).
--
-- Contexto: el backend de reset ya existía casi completo (PKG_EMPLEADOS.validar_token,
--   cambiar_contrasena, y la página pública P102 "Restablecer Contraseña"). Faltaba un
--   procedimiento que, para un empleado EXISTENTE, re-emita un token y devuelva el enlace.
--
-- Estado de los canales de correo (verificado 2026-07-09):
--   * SendGrid  -> la cuenta responde 401 "Maximum credits exceeded" (sin créditos).
--   * Gmail SMTP-> APEX_MAIL nunca entregó (apex_mail_log=0; cola atascada desde marzo).
--   Decisión del PO: seguir SIN correo. El reset lo resuelve el ADMIN desde Empleados (P20),
--   que recibe el enlace en pantalla y se lo pasa al empleado. El autoservicio desde el login
--   queda para cuando haya un canal de correo operativo.
--
-- Este script:
--   1) Agrega el ACE de red api.sendgrid.com para WKSP_WORKPLACE (Paso 0, deja lista la red
--      para cuando SendGrid tenga créditos; ya está probada la conectividad).
--   2) Crea el paquete PKG_RESET_PWD.resetear_por_admin: genera token, desbloquea la cuenta
--      (INTENTOS_FALLIDOS=0) y devuelve el enlace a P102. NO envía correo (best-effort futuro).
--
-- Reutiliza (sin tocar): PKG_EMPLEADOS.validar_token / cambiar_contrasena, página P102.
-- Errores reservados: -20006 .. -20009 (familia de PKG_EMPLEADOS).
-- Idempotente. Ejecutar como ADMIN:  sql -S -name tesis_db @db/F28_reset_password.sql
--------------------------------------------------------------------------------
SET DEFINE OFF
SET SERVEROUTPUT ON

--------------------------------------------------------------------------------
-- 1) ACE de red para SendGrid (WKSP_WORKPLACE).  APPEND_HOST_ACE es acumulativo:
--    re-ejecutar con el mismo principal/host solo actualiza, no duplica.
--    (En Autonomous DB no se especifican puertos para HTTPS saliente.)
--------------------------------------------------------------------------------
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => 'api.sendgrid.com',
    ace  => xs$ace_type(
              privilege_list => xs$name_list('connect','resolve'),
              principal_name => 'WKSP_WORKPLACE',
              principal_type => xs_acl.ptype_db));
  DBMS_OUTPUT.PUT_LINE('ACE api.sendgrid.com -> WKSP_WORKPLACE OK');
END;
/

--------------------------------------------------------------------------------
-- 2) Paquete de reset por administrador
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE WKSP_WORKPLACE.PKG_RESET_PWD AS

  -- Genera un token de reset para un empleado existente, DESBLOQUEA la cuenta
  -- (INTENTOS_FALLIDOS = 0) y devuelve el enlace a la página P102.
  -- NO envía correo: el admin entrega el enlace manualmente (mientras no haya canal).
  --   p_id_empleado : PK del empleado a resetear.
  --   p_url_reset   : URL base de la página de reset (P102 / ords .../reset-password).
  --   p_link_out    : (OUT) enlace completo con el token, para mostrar en pantalla.
  PROCEDURE resetear_por_admin(
    p_id_empleado IN  WKSP_WORKPLACE.EMPLEADOS.ID_EMPLEADO%TYPE,
    p_url_reset   IN  VARCHAR2,
    p_link_out    OUT VARCHAR2
  );

  -- Autoservicio desde el login (Opción A): el usuario pide reset con su código de usuario.
  -- Busca el empleado ACTIVO por CODIGO_USUARIO, genera token y ENVÍA el enlace a P102
  -- al correo REGISTRADO del empleado (nunca a una dirección tecleada por quien pide).
  -- El envío es best-effort: si el canal de correo falla NO rompe el flujo (hoy sin canal).
  -- Anti-enumeración: si el usuario no existe/está inactivo, termina en silencio.
  --   p_usuario   : código de usuario tal como se teclea en el login.
  --   p_url_reset : URL base de la página de reset (P102 / ords .../reset-password).
  PROCEDURE solicitar_reset(
    p_usuario   IN VARCHAR2,
    p_url_reset IN VARCHAR2
  );

END PKG_RESET_PWD;
/

CREATE OR REPLACE PACKAGE BODY WKSP_WORKPLACE.PKG_RESET_PWD AS

  -- Token SHA-256 de 64 caracteres hex (mismo formato que espera validar_token: >= 64).
  FUNCTION f_generar_token RETURN VARCHAR2 IS
    v_hash VARCHAR2(64);
    v_seed VARCHAR2(200);
  BEGIN
    v_seed := DBMS_RANDOM.STRING('x', 32) ||
              TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF9');
    SELECT STANDARD_HASH(v_seed, 'SHA256') INTO v_hash FROM DUAL;
    RETURN v_hash;
  END f_generar_token;

  -- Envío de correo vía SendGrid REST (copia de PKG_EMPLEADOS.p_enviar_correo).
  -- Lee credenciales de APP_CONFIG. Lanza -20005 si el envío falla.
  -- NOTA: hoy SendGrid está sin créditos → esto fallará; solicitar_reset lo llama en un
  -- bloque best-effort. Para destrabar: recargar SENDGRID_API_KEY, o migrar a APEX_MAIL
  -- (SMTP Gmail ya configurado a nivel instancia).
  PROCEDURE p_enviar_correo(
    p_to        IN VARCHAR2,
    p_subject   IN VARCHAR2,
    p_body_html IN CLOB,
    p_body_txt  IN CLOB
  ) IS
    v_api_key   VARCHAR2(4000);
    v_mail_from VARCHAR2(200);
    v_html      CLOB;
    v_txt       CLOB;
    v_body      CLOB;
    v_response  CLOB;

    FUNCTION f_escape_json(p_text IN CLOB) RETURN CLOB IS
      v_out CLOB;
    BEGIN
      v_out := REPLACE(p_text, '\',  '\\');
      v_out := REPLACE(v_out,  '"',  '\"');
      v_out := REPLACE(v_out,  CHR(13)||CHR(10), '\n');
      v_out := REPLACE(v_out,  CHR(10), '\n');
      v_out := REPLACE(v_out,  CHR(13), '\n');
      v_out := REPLACE(v_out,  CHR(9),  '\t');
      RETURN v_out;
    END f_escape_json;
  BEGIN
    SELECT VALOR INTO v_api_key   FROM APP_CONFIG WHERE CLAVE = 'SENDGRID_API_KEY';
    SELECT VALOR INTO v_mail_from FROM APP_CONFIG WHERE CLAVE = 'MAIL_FROM';

    v_html := f_escape_json(p_body_html);
    v_txt  := f_escape_json(p_body_txt);

    v_body :=
      '{"personalizations":[{"to":[{"email":"' || p_to || '"}]}],' ||
      '"from":{"email":"' || v_mail_from || '"},' ||
      '"subject":"' || p_subject || '",' ||
      '"content":[' ||
        '{"type":"text/plain","value":"' || v_txt  || '"},' ||
        '{"type":"text/html","value":"'  || v_html || '"}' ||
      ']}';

    APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).NAME  := 'Authorization';
    APEX_WEB_SERVICE.G_REQUEST_HEADERS(1).VALUE := 'Bearer ' || v_api_key;
    APEX_WEB_SERVICE.G_REQUEST_HEADERS(2).NAME  := 'Content-Type';
    APEX_WEB_SERVICE.G_REQUEST_HEADERS(2).VALUE := 'application/json';

    v_response := APEX_WEB_SERVICE.MAKE_REST_REQUEST(
      p_url         => 'https://api.sendgrid.com/v3/mail/send',
      p_http_method => 'POST',
      p_body        => v_body);

    IF APEX_WEB_SERVICE.G_STATUS_CODE NOT IN (200, 202) THEN
      RAISE_APPLICATION_ERROR(-20005,
        'SendGrid error ' || APEX_WEB_SERVICE.G_STATUS_CODE || ': ' || v_response);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20005, 'Error al enviar correo via SendGrid: ' || SQLERRM);
  END p_enviar_correo;

  PROCEDURE resetear_por_admin(
    p_id_empleado IN  WKSP_WORKPLACE.EMPLEADOS.ID_EMPLEADO%TYPE,
    p_url_reset   IN  VARCHAR2,
    p_link_out    OUT VARCHAR2
  ) IS
    v_token  VARCHAR2(64);
    v_activo WKSP_WORKPLACE.EMPLEADOS.ACTIVO%TYPE;
  BEGIN
    -- Validar que el empleado exista y esté activo (si está inactivo no puede loguear).
    BEGIN
      SELECT ACTIVO INTO v_activo
        FROM WKSP_WORKPLACE.EMPLEADOS
       WHERE ID_EMPLEADO = p_id_empleado;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, 'El empleado no existe.');
    END;

    IF v_activo <> 'S' THEN
      RAISE_APPLICATION_ERROR(-20007, 'La cuenta del empleado está inactiva; actívala antes de restablecer.');
    END IF;

    -- Generar token, fijar expiración (24 h) y DESBLOQUEAR la cuenta.
    -- Se mantiene SYSTIMESTAMP (UTC): es la excepción documentada para tokens de auth,
    -- y PKG_EMPLEADOS.validar_token compara contra SYSTIMESTAMP.
    v_token := f_generar_token();

    UPDATE WKSP_WORKPLACE.EMPLEADOS
       SET TOKEN_RESET       = v_token,
           TOKEN_EXPIRACION  = SYSTIMESTAMP + INTERVAL '24' HOUR,
           INTENTOS_FALLIDOS = 0
     WHERE ID_EMPLEADO = p_id_empleado;

    p_link_out := p_url_reset || '?P102_TOKEN=' || v_token;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END resetear_por_admin;

  PROCEDURE solicitar_reset(
    p_usuario   IN VARCHAR2,
    p_url_reset IN VARCHAR2
  ) IS
    v_id     WKSP_WORKPLACE.EMPLEADOS.ID_EMPLEADO%TYPE;
    v_correo WKSP_WORKPLACE.EMPLEADOS.CORREO%TYPE;
    v_nombre WKSP_WORKPLACE.EMPLEADOS.NOMBRE%TYPE;
    v_codigo WKSP_WORKPLACE.EMPLEADOS.CODIGO_USUARIO%TYPE;
    v_token  VARCHAR2(64);
    v_link   VARCHAR2(2000);
    v_html   CLOB;
    v_txt    CLOB;
  BEGIN
    IF p_usuario IS NULL OR TRIM(p_usuario) IS NULL THEN
      RAISE_APPLICATION_ERROR(-20008, 'Ingresa tu usuario y volve a intentar.');
    END IF;

    -- Buscar empleado ACTIVO por código de usuario.
    BEGIN
      SELECT ID_EMPLEADO, CORREO, NOMBRE, CODIGO_USUARIO
        INTO v_id, v_correo, v_nombre, v_codigo
        FROM WKSP_WORKPLACE.EMPLEADOS
       WHERE CODIGO_USUARIO = UPPER(TRIM(p_usuario))
         AND ACTIVO = 'S';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN;  -- Anti-enumeracion: no revelar si el usuario existe.
    END;

    -- Generar token y fijar expiracion (24 h). SYSTIMESTAMP: excepcion UTC para tokens de auth.
    v_token := f_generar_token();
    UPDATE WKSP_WORKPLACE.EMPLEADOS
       SET TOKEN_RESET      = v_token,
           TOKEN_EXPIRACION = SYSTIMESTAMP + INTERVAL '24' HOUR
     WHERE ID_EMPLEADO = v_id;
    COMMIT;

    v_link := p_url_reset || '?P102_TOKEN=' || v_token;

    -- Enviar el enlace al correo REGISTRADO del empleado (best-effort).
    IF v_correo IS NOT NULL THEN
      v_html :=
        '<html><body style="font-family:Arial,sans-serif;color:#333;max-width:600px;margin:auto">' ||
        '<h2 style="color:#1a4a7a">Restablecer contrasena</h2>' ||
        '<p>Hola <strong>' || APEX_ESCAPE.HTML(v_nombre) || '</strong>,</p>' ||
        '<p>Recibimos una solicitud para restablecer la contrasena de tu cuenta (' ||
          APEX_ESCAPE.HTML(v_codigo) || ').</p>' ||
        '<p style="text-align:center"><a href="' || v_link || '" ' ||
          'style="background:#1a4a7a;color:#fff;padding:12px 28px;text-decoration:none;border-radius:6px;display:inline-block">' ||
          'Establecer nueva contrasena</a></p>' ||
        '<p style="color:#888;font-size:12px">El enlace expira en 24 horas. ' ||
          'Si no solicitaste esto, ignora este correo.</p>' ||
        '</body></html>';
      v_txt :=
        'Hola ' || v_nombre || CHR(10) ||
        'Recibimos una solicitud para restablecer tu contrasena.' || CHR(10) ||
        'Enlace (expira en 24h):' || CHR(10) || v_link || CHR(10) || CHR(10) ||
        'Si no solicitaste esto, ignora este correo.';
      BEGIN
        p_enviar_correo(
          p_to        => v_correo,
          p_subject   => 'Restablecer tu contrasena',
          p_body_html => v_html,
          p_body_txt  => v_txt);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;  -- best-effort: hoy sin canal de correo, no rompe el flujo.
      END;
    END IF;
  END solicitar_reset;

END PKG_RESET_PWD;
/

--------------------------------------------------------------------------------
-- 3) Verificación
--------------------------------------------------------------------------------
PROMPT === Estado de objetos ===
SELECT object_name, object_type, status
  FROM all_objects
 WHERE owner='WKSP_WORKPLACE' AND object_name='PKG_RESET_PWD'
 ORDER BY object_type;

PROMPT === ACE de red WKSP_WORKPLACE ===
SELECT host, privilege FROM dba_host_aces
 WHERE principal='WKSP_WORKPLACE' AND host='api.sendgrid.com'
 ORDER BY privilege;

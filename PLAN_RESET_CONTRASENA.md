# PLAN_RESET_CONTRASENA.md — Restablecimiento de contraseña (F28)

Feature de **seguridad**: habilitar el restablecimiento de contraseña por dos vías
—autoservicio del usuario desde el login y acción del administrador desde Empleados—
reutilizando el backend de tokens y la página P102 que **ya existen** en el sistema.

- **App:** 100 (`f100`, alias `solsge`) · Workspace `WKSP_WORKPLACE`.
- **Esquema del backend:** `WKSP_WORKPLACE` (paquete `PKG_EMPLEADOS`).
- **Errores reservados:** `-20006 .. -20009` (contiguos a la familia existente de `PKG_EMPLEADOS`: `-20001..-20005`).
- **Estado:** **Fase 1 (vía admin) implementada y probada el 2026-07-09.** Autoservicio desde login **diferido** (depende de correo, hoy sin canal).

---

## 0. Estado de ejecución (2026-07-09)

**Hecho:**
- **Paso 0 — ACE SendGrid:** agregado `api.sendgrid.com` (connect/resolve) para `WKSP_WORKPLACE`.
  Conectividad de red confirmada.
- **Hallazgo (bloqueador):** los DOS canales de correo están caídos hoy →
  SendGrid responde `401 Maximum credits exceeded` (cuenta sin créditos); Gmail SMTP/APEX_MAIL nunca
  entregó (`apex_mail_log`=0, cola atascada desde marzo). **Decisión PO: seguir SIN correo.**
- **Paso 1 — backend:** en vez de tocar `PKG_EMPLEADOS` (login/auth, ya probado) se creó el paquete
  **`PKG_RESET_PWD.resetear_por_admin`** (`db/F28_reset_password.sql`), que genera token, **desbloquea**
  la cuenta (`INTENTOS_FALLIDOS=0`) y **devuelve el enlace** a P102 — **sin enviar correo**. Reutiliza
  `PKG_EMPLEADOS.validar_token` + `cambiar_contrasena` + P102 intactos. Probado e2e (token 64c, desbloqueo,
  `validar_token` lo acepta).
- **Paso 3 — UI admin (P20):** botón **`RESET_PWD`** "Restablecer / Reenviar credenciales" (visible al
  editar un empleado existente) + ítem display-only **`P20_RESET_LINK`** que muestra el enlace.
  El botón es **`DEFINED_BY_DA`** con un Dynamic Action `RESET_PWD_CLICK` → acción
  **`NATIVE_EXECUTE_PLSQL_CODE`** (submit `P20_ID_EMPLEADO`, return `P20_RESET_LINK`) que llama
  `PKG_RESET_PWD.resetear_por_admin`. **Ojo (aprendido):** NO usar un proceso AFTER_SUBMIT — el modal
  P20 se abre desde P16/P19 con ClearCache=`RP` (no limpia ítems) y el ítem memory-only pierde el valor
  en el post-redirect (se veía vacío). El DA por AJAX lo resuelve: setea el ítem sin recargar y no deja
  valor stale al abrir otro empleado. Importado aislado y verificado en la app viva.

- **Paso 2 — autoservicio desde login (Opción A, 2026-07-09):** implementado **inline en P9999**, sin
  página P103 nueva (ver §5 revisado). Backend `PKG_RESET_PWD.solicitar_reset(p_usuario, p_url_reset)`:
  busca el empleado ACTIVO por `CODIGO_USUARIO`, genera token y **envía el enlace a P102 al correo
  registrado** (best-effort — si el correo falla NO rompe; anti-enumeración si el usuario no existe).
  UI: **hipervínculo de texto** "¿Olvidaste tu contraseña?" (región estática `Recuperar acceso`,
  plantilla *Blank with Attributes (No Grid)*, `<a id="forgot-link">`) — **no** un botón, estilo login
  convencional. DA `FORGOT_CLICK` disparado por selector jQuery `#forgot-link` →
  `NATIVE_EXECUTE_PLSQL_CODE` (submit `P9999_USERNAME`) llama `solicitar_reset`, luego
  `NATIVE_JAVASCRIPT_CODE` muestra `apex.message.showPageSuccess`. Importado aislado y verificado.
  Probado backend e2e (usuario válido→token 64c; inexistente→silencio). **El correo NO sale todavía**
  (canales caídos) — el flujo queda "armado" a la espera de destrabar el correo.

**Pendiente:**
- **Destrabar el correo** (única cosa que falta para que el autoservicio entregue): recargar/renovar
  `SENDGRID_API_KEY` (el ACE ya está) **o** cargar un App Password de Gmail como `SMTP_PASSWORD` de la
  instancia y migrar `p_enviar_correo` a `APEX_MAIL`. Opcional: sumar envío best-effort también a
  `resetear_por_admin` (hoy la vía admin no manda correo, muestra el link en pantalla).

---

## 1. Contexto / diagnóstico (resumen)

El backend de reset está **~90% construido y probado**:

- `PKG_EMPLEADOS.validar_token(token)` — valida longitud ≥64, expiración (24 h), `ACTIVO='S'`.
- `PKG_EMPLEADOS.cambiar_contrasena(token, nueva)` — política mínima, re-hash SHA-256+salt,
  **token de un solo uso**, resetea `INTENTOS_FALLIDOS`.
- **P102 "Restablecer Contraseña"** — página pública con deep-linking; recibe `P102_TOKEN`,
  lo valida y permite fijar la contraseña nueva. Funciona de punta a punta hoy.
- Login **P9999** (custom auth → `AUT_PKG.AUTENTICACION_LOGIN` → `PKG_EMPLEADOS.VERIFICAR_CREDENCIALES`),
  con bloqueo a los 5 intentos fallidos.

**Faltan exactamente 3 cosas** (motivo por el que la opción "no está disponible"):

1. No hay procedimiento que, para un empleado **ya existente**, genere un token nuevo y mande el link
   (`registrar_empleado` solo lo hace en el alta).
2. No hay punto de entrada en la UI: ni link "¿Olvidaste tu contraseña?" en el login, ni acción de
   "reenviar credenciales / desbloquear" en Empleados (P20).
3. **Canal de correo roto:** `p_enviar_correo` usa SendGrid REST (`api.sendgrid.com`) pero el ACL de red
   de `WKSP_WORKPLACE` solo permite `smtp.gmail.com` → `ORA-24247`. La `SENDGRID_API_KEY` y `MAIL_FROM`
   ya están cargados en `APP_CONFIG`.

**Decisión del PO:** ir por la **alternativa mínima** — agregar el ACE de `api.sendgrid.com` y conservar
el código SendGrid tal cual (no migrar a `APEX_MAIL`).

**Regla de seguridad (PO):** la página de recuperación **valida que el correo ingresado pertenezca a un
empleado activo**, y el enlace de reset se envía **siempre a la dirección guardada en `EMPLEADOS.CORREO`**,
nunca a una dirección arbitraria tecleada por quien solicita. Así, aunque alguien escriba un correo `x`,
si no coincide con el de un empleado activo no se envía nada; y si coincide, el link va al buzón real de
la empresa (que el atacante no controla).

---

## 2. Alcance

**Incluye:**
- Habilitar el envío de correo (ACE `api.sendgrid.com:443`).
- Nuevo backend `solicitar_reset` (autoservicio) y `resetear_por_admin` (admin + desbloqueo).
- Página pública **P103 "Recuperar acceso"** + link desde el login P9999.
- Botón **"Restablecer / Reenviar credenciales"** en Empleados **P20**.

**No incluye (fuera de alcance):**
- Migrar el canal de correo a `APEX_MAIL`/SMTP (queda SendGrid).
- Rate-limiting / captcha en la solicitud (se anota como mejora futura; el sistema es interno, 4 usuarios).
- Cambiar la política de contraseñas ni el hashing (SHA-256+salt se mantiene).

---

## 3. Paso 0 — Habilitar el correo (ACE SendGrid)

Ejecutar **como `ADMIN`** (conexión `tesis_db`). En Autonomous DB:

```sql
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => 'api.sendgrid.com',
    lower_port => 443,
    upper_port => 443,
    ace  => xs$ace_type(
      privilege_list => xs$name_list('http','connect','resolve'),
      principal_name => 'WKSP_WORKPLACE',
      principal_type => xs_acl.ptype_db));
END;
/
```

**Verificación:** `SELECT host, privilege FROM dba_host_aces WHERE principal='WKSP_WORKPLACE';`
debe listar ahora `api.sendgrid.com` (443) junto a `smtp.gmail.com`.

**Prueba real de envío** (bloque anónimo) llamando `PKG_EMPLEADOS.p_enviar_correo` a un correo de prueba
antes de seguir; confirmar `G_STATUS_CODE IN (200,202)`. Si SendGrid devuelve 401/403 la key está mal;
403 de red = el ACE no tomó.

> Va en `db/F28_reset_password.sql` (idempotente: `APPEND_HOST_ACE` es acumulativo pero re-ejecutable sin duplicar la ACE del mismo principal/host).

---

## 4. Paso 1 — Backend (`db/F28_reset_password.sql`)

`PKG_EMPLEADOS` **no está versionado** en `db/`; su fuente solo vive en la BD. F28 debe hacer
**`CREATE OR REPLACE`** del paquete **completo** (spec + body) agregando **dos procedimientos públicos**,
porque no se puede añadir un procedure a un package sin recompilar todo. Se parte de la fuente viva actual
(ya extraída) y se le suman las procs nuevas — el resto queda **idéntico** (no tocar `f_generar_token`,
`f_hashear`, `p_enviar_correo`, `cambiar_contrasena`, etc.).

### 4.1 `solicitar_reset` (autoservicio)

```
PROCEDURE solicitar_reset(
  p_correo    IN VARCHAR2,          -- correo ingresado en P103
  p_url_reset IN VARCHAR2
);
```

Lógica:
1. Buscar empleado **activo** por `LOWER(CORREO) = LOWER(TRIM(p_correo))` (`ACTIVO='S'`).
2. **No encontrado →** `RAISE_APPLICATION_ERROR(-20006, 'El correo no está registrado o la cuenta está inactiva.')`.
   *(El PO pidió validación explícita del correo; ver §7 la nota de anti-enumeración como alternativa.)*
3. Encontrado → `f_generar_token`, `UPDATE EMPLEADOS SET TOKEN_RESET=..., TOKEN_EXPIRACION = SYSTIMESTAMP + INTERVAL '24' HOUR`.
   **Mantener `SYSTIMESTAMP`** (no `FN_AHORA`): es la excepción UTC documentada para tokens de auth y
   `validar_token` compara contra `SYSTIMESTAMP`.
4. Armar `v_link := p_url_reset || '?P102_TOKEN=' || v_token;` y llamar `p_enviar_correo` **al correo del
   registro** (no al parámetro) con un template "Solicitud de restablecimiento".
5. `COMMIT`. Rollback + re-raise en excepción.

### 4.2 `resetear_por_admin` (admin + desbloqueo)

```
PROCEDURE resetear_por_admin(
  p_id_empleado IN EMPLEADOS.ID_EMPLEADO%TYPE,
  p_url_reset   IN VARCHAR2,
  p_link_out    OUT VARCHAR2          -- fallback: link para mostrar en pantalla
);
```

Lógica: ubica el empleado por PK; genera token + expiración; **`INTENTOS_FALLIDOS = 0`** (esto además
**desbloquea** la cuenta bloqueada por 5 intentos); envía el correo a `EMPLEADOS.CORREO`; devuelve el
`v_link` en `p_link_out` para que el admin pueda copiarlo si el correo fallara.
`-20007` si el empleado no existe / inactivo.

### 4.3 Errores

- `-20006` correo no registrado (autoservicio).
- `-20007` empleado inexistente/inactivo (admin).
- `-20008` reservado (p.ej. futuro rate-limit).
- `-20009` reservado.

### 4.4 Verificación del script
Bloque final: recompilar y `SELECT status FROM all_objects WHERE object_name='PKG_EMPLEADOS'` = VALID (spec+body);
smoke test de `solicitar_reset` con un correo real de los 4 empleados y confirmar que el token quedó seteado.

---

## 5. Paso 2 — UI autoservicio

> **NOTA (2026-07-09): reemplazado por la Opción A** — ver §0. En vez de la página nueva P103, el
> autoservicio se implementó **inline en el login P9999** (botón `FORGOT` + DA que llama
> `solicitar_reset(:P9999_USERNAME, ...)`), y `solicitar_reset` busca por **código de usuario** (no por
> correo). El diseño original con P103 de abajo queda como referencia histórica; **no** se construyó P103.

### 5.1 Página pública **P103 "Recuperar acceso"** (`recuperar-acceso`)
- `p_page_is_public_y_n=>'Y'`, sin menú, `protection_level` estándar.
- Región formulario con **`P103_CORREO`** (text field, subtype EMAIL, required, trim BOTH).
- Botón **`BTN_ENVIAR`** (SUBMIT).
- Proceso AFTER_SUBMIT `Solicitar reset`:
  ```plsql
  BEGIN
    PKG_EMPLEADOS.solicitar_reset(
      p_correo    => :P103_CORREO,
      p_url_reset => 'https://gd48788b1691042-orapdbtes.adb.sa-vinhedo-1.oraclecloudapps.com/ords/r/workplace/solsge/reset-password'
    );
    APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE :=
      'Si el correo corresponde a un usuario activo, enviamos un enlace para restablecer la contraseña.';
    APEX_UTIL.REDIRECT_URL(APEX_PAGE.GET_URL(p_page => 9999));
  EXCEPTION
    WHEN OTHERS THEN
      APEX_ERROR.ADD_ERROR(p_message => SQLERRM,
        p_display_location => APEX_ERROR.C_INLINE_IN_NOTIFICATION);
  END;
  ```
  *(La URL de reset es la misma que ya usa P20 hacia P102.)*

### 5.2 Link en el login **P9999**
- Agregar en la región `SOLSGE` (id `8001243229830884`), debajo del botón LOGIN, un
  **link/botón "¿Olvidaste tu contraseña?"** que navega a P103
  (`f?p=&APP_ID.:103:&SESSION.` vía `APEX_PAGE.GET_URL` o botón de acción Redirect a page 103).
- Re-exportar P9999 antes de editar (el PO puede haberla tocado en el Builder).

---

## 6. Paso 3 — UI administrador (Empleados **P20**)

- Nuevo botón **`RESET_PWD`** "Restablecer / Reenviar credenciales", visible solo al **editar** un
  empleado existente: `p_button_condition => 'P20_ID_EMPLEADO'`, tipo `ITEM_IS_NOT_NULL`.
- Proceso AFTER_SUBMIT `Reset admin` (`p_process_when_button_id => RESET_PWD`):
  ```plsql
  DECLARE v_link VARCHAR2(2000);
  BEGIN
    PKG_EMPLEADOS.resetear_por_admin(
      p_id_empleado => :P20_ID_EMPLEADO,
      p_url_reset   => 'https://gd48788b1691042-orapdbtes.adb.sa-vinhedo-1.oraclecloudapps.com/ords/r/workplace/solsge/reset-password',
      p_link_out    => v_link);
    APEX_APPLICATION.G_PRINT_SUCCESS_MESSAGE :=
      'Credenciales reenviadas a ' || :P20_CORREO || ' y cuenta desbloqueada.';
  END;
  ```
- No cerrar el diálogo en este request (para que se vea el mensaje). El `p_link_out` puede mostrarse
  en un ítem display-only opcional `P20_RESET_LINK` como fallback si el correo fallara.
- Re-exportar P20 antes de editar.

---

## 7. Notas / riesgos

- **Anti-enumeración (alternativa a §4.1.2):** por pedido del PO la página valida el correo y devuelve
  error si no existe → esto **revela** qué correos están registrados. Dado que es un sistema interno de
  4 usuarios el riesgo es bajo y se prioriza la claridad. Si más adelante se quiere endurecer, cambiar el
  `-20006` por un retorno silencioso con el **mismo** mensaje genérico de éxito (el flujo backend ya lo
  soporta sin cambios en la UI).
- **Token en query string** de una página pública: aceptable — es de un solo uso, SHA-256, expira en 24 h,
  y el ítem `P102_TOKEN` está `value_protected`.
- **Dependencia del correo:** si SendGrid cae, el admin igual puede resolver vía `p_link_out`. El
  autoservicio, en cambio, depende del correo (esperado).
- La `SENDGRID_API_KEY` (69 chars) parece válida; confirmar en el smoke test del Paso 0 antes de exponer la UI.

---

## 8. Entregables / archivos

- `db/F28_reset_password.sql` — ACE SendGrid + `CREATE OR REPLACE PACKAGE`/`BODY PKG_EMPLEADOS`
  (con `solicitar_reset` + `resetear_por_admin`) + verificación. **Versiona por primera vez el paquete.**
- `apex-work/f100/application/pages/page_00103.sql` + `delete_00103.sql` (P103 nueva).
- `apex-work/f100/application/pages/page_09999.sql` + `delete_09999.sql` (link login).
- `apex-work/f100/application/pages/page_00020.sql` + `delete_00020.sql` (botón admin).
- Agregar los `@@` correspondientes a `install_page.sql` (import **aislado**, cada página con su `delete_`).

## 9. Plan de pruebas (e2e)

1. Paso 0: enviar correo de prueba → 202.
2. Autoservicio: P103 con correo válido → llega mail → link abre P102 → set password → login OK.
3. Autoservicio: P103 con correo inexistente → error `-20006` (o mensaje genérico según §7).
4. Admin: P20 sobre empleado existente → "Reenviar credenciales" → mail + `INTENTOS_FALLIDOS=0`.
5. Desbloqueo: forzar 5 intentos fallidos → login bloqueado (`-20002`) → admin resetea → login OK.
6. Token: expirar/usar dos veces el mismo token → P102 rechaza y redirige al login.

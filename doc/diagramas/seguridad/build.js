// ============================================================================
// Módulo SEGURIDAD — contenido del Word de diagramas UML. Modelo aprobado.
// Todos los diagramas entran en vertical → módulo íntegro en portrait (sin rotación).
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "..", "_build", "docxlib.js"));
const { P, Field, H1, H2, H3, SubBold, bullet, num, caption, pageBreak,
        makeImg, makeCaratula, portraitSection, buildDoc } = lib;
const { PORT_PX, ACT_H } = lib.SIZES;
const { imgFit, imgFitH } = makeImg(__dirname);
const OUT = path.join(__dirname, "..", "MUESTRA_Seguridad.docx");

const specAutenticar = [
  H2("Especificación de caso de uso: Autenticarse"),
  H3("Descripción"),
  P("Permite a un usuario iniciar sesión validando su código y contraseña (almacenada como hash con salt). Tras superar el máximo de intentos fallidos la cuenta se bloquea. Al autenticarse correctamente se cargan sus roles y privilegios."),
  Field("Actor principal: ", "Usuario (cualquier empleado)."),
  Field("Entorno de invocación: ", "pantalla de inicio de sesión (PKG_EMPLEADOS.verificar_credenciales)."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Usuario ingresa su **código de usuario** y **contraseña**."),
  num("El sistema busca el usuario y valida que esté **activo** y **no bloqueado**."),
  num("El sistema valida la **contraseña** (hash + salt)."),
  num("El sistema **reinicia** los intentos fallidos y carga los **roles y privilegios** del usuario."),
  num("El acceso queda concedido."),
  SubBold("Flujos Alternativos"),
  H3("Usuario inactivo o bloqueado"),
  P("En el paso 2, si el usuario está inactivo o bloqueado, el sistema deniega el acceso."),
  H3("Credenciales inválidas"),
  P("En el paso 3, si la contraseña es incorrecta, el sistema **incrementa** los intentos fallidos y, si superan el máximo, **bloquea** la cuenta; luego muestra «usuario o contraseña incorrectos»."),
  H3("Precondiciones"),
  bullet("El usuario está registrado y activo."),
  H3("Pos-condiciones"),
  bullet("Sesión iniciada con los roles y privilegios del usuario; o intentos fallidos incrementados / cuenta bloqueada."),
];

const specRegistrar = [
  pageBreak(),
  H2("Especificación de caso de uso: Registrar usuario"),
  H3("Descripción"),
  P("Permite al Administrador dar de alta un empleado/usuario con sus datos y credenciales iniciales. El usuario nace activo y con una contraseña temporal (PKG_EMPLEADOS.registrar_empleado)."),
  Field("Actor principal: ", "Administrador."),
  Field("Entorno de invocación: ", "pantalla de administración de usuarios."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Administrador ingresa los **datos** del usuario (nombre, cargo, correo, código de usuario)."),
  num("El sistema ejecuta **registrar_empleado**: genera el hash + salt de la contraseña (temporal) y crea el empleado con **ACTIVO='S'**."),
  num("El usuario queda **registrado y activo**, con contraseña temporal a cambiar en el primer ingreso."),
  SubBold("Flujos Alternativos"),
  H3("Código de usuario duplicado"),
  P("Si el código de usuario ya existe, el sistema muestra un error y no crea el usuario."),
  H3("Precondiciones"),
  bullet("El Administrador está autenticado y con privilegio de administración."),
  H3("Pos-condiciones"),
  bullet("Usuario creado activo con credenciales iniciales."),
  H3("Puntos de Extensión"),
  bullet("Asignar roles a un usuario; Cambiar contraseña (primer ingreso)."),
];

const specAsignarRoles = [
  pageBreak(),
  H2("Especificación de caso de uso: Asignar roles a un usuario"),
  H3("Descripción"),
  P("Permite al Administrador asignar o quitar roles a un usuario (EMPLEADOS_ROLES). El acceso efectivo del usuario es la unión de los privilegios de sus roles."),
  Field("Actor principal: ", "Administrador."),
  Field("Entorno de invocación: ", "pantalla de administración de usuarios."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Administrador selecciona un **usuario**; el sistema muestra sus roles asignados y los disponibles."),
  num("El Administrador **marca/desmarca** roles y guarda."),
  num("El sistema **inserta** (EMPLEADOS_ROLES, con fecha de asignación) los roles agregados y **elimina** los quitados."),
  num("El acceso efectivo del usuario se **recalcula** de inmediato."),
  SubBold("Flujos Alternativos"),
  H3("Sin cambios"),
  P("Si no se modificó ningún rol, no se realizan cambios."),
  H3("Precondiciones"),
  bullet("El usuario y los roles existen."),
  H3("Pos-condiciones"),
  bullet("Roles del usuario actualizados; sus privilegios efectivos cambian en consecuencia."),
];

const specPrivRol = [
  pageBreak(),
  H2("Especificación de caso de uso: Administrar privilegios de un rol"),
  H3("Descripción"),
  P("Permite al Administrador definir qué privilegios tiene un rol (ROLES_PRIVILEGIOS). El cambio afecta a todos los usuarios que tienen ese rol; el control de acceso (SECURITY_PKG.can_access) usa esta configuración."),
  Field("Actor principal: ", "Administrador."),
  Field("Entorno de invocación: ", "pantalla de administración de roles."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Administrador selecciona un **rol**; el sistema muestra sus privilegios asignados y los disponibles."),
  num("El Administrador **marca/desmarca** privilegios y guarda."),
  num("El sistema **inserta/elimina** filas en ROLES_PRIVILEGIOS según corresponda."),
  num("El control de acceso pasa a considerar los nuevos privilegios del rol."),
  SubBold("Flujos Alternativos"),
  H3("Rol en uso"),
  P("El cambio afecta inmediatamente a todos los usuarios con ese rol."),
  H3("Precondiciones"),
  bullet("El rol y los privilegios existen."),
  H3("Pos-condiciones"),
  bullet("Privilegios del rol actualizados; el acceso efectivo de sus usuarios cambia."),
];

if (require.main === module) buildDoc({
  outPath: OUT,
  sections: [
    portraitSection(makeCaratula({ subtitulo: "Módulo Seguridad" }), true),

    portraitSection([
      H1("1. Casos de Uso"),
      P("Mapa general del módulo (actores y casos de uso principales) y las especificaciones de cada caso, en el formato de la plantilla, reflejando la lógica real del sistema.", { after: 60 }),
      imgFit("casos_uso_seguridad.png", PORT_PX, 1.780),
      caption("Figura 1. Diagrama de casos de uso — Módulo Seguridad."),
      pageBreak(),
      H2("1.1. Especificaciones de casos de uso"),
      ...specAutenticar, ...specRegistrar, ...specAsignarRoles, ...specPrivRol,
    ]),
    portraitSection([
      H1("2. Diagramas de Estados"),
      P("Objeto del módulo con más de un estado, indicando el evento de cada transición.", { after: 120 }),
      H2("2.1. Usuario"),
      imgFit("estados_usuario.png", PORT_PX, 1.566),
      caption("Figura 2. Estados del Usuario (EMPLEADOS.ACTIVO + bloqueo por intentos)."),
    ]),
    portraitSection([
      H1("3. Diagramas de Actividades"),
      P("Flujo de control de los procesos, con decisiones y caminos de error.", { after: 60 }),
      H2("3.1. Autenticarse"),
      imgFitH("actividad_autenticar.png", ACT_H, 0.559),
      caption("Figura 3. Actividad — Autenticarse."),
      pageBreak(),
      H2("3.2. Asignar roles a un usuario"),
      imgFitH("actividad_asignar_roles.png", ACT_H, 0.947),
      caption("Figura 4. Actividad — Asignar roles a un usuario."),
    ]),
    portraitSection([
      H1("4. Diagrama de Clases"),
      P("Entidades del módulo Seguridad y sus relaciones (modelo RBAC: usuario–rol–privilegio), obtenidas de las tablas reales.", { after: 60 }),
      imgFit("clases_seguridad.png", 470, 0.688),
      caption("Figura 5. Diagrama de clases — Módulo Seguridad."),
    ]),
    portraitSection([
      H1("5. Diagramas de Secuencia"),
      P("Derivados de los casos de uso; muestran las llamadas reales entre la página, las funciones PL/SQL y las entidades.", { after: 60 }),
      H2("5.1. Autenticarse"),
      imgFit("secuencia_autenticar.png", PORT_PX, 1.360),
      caption("Figura 6. Secuencia — Autenticarse."),
      pageBreak(),
      H2("5.2. Asignar roles a un usuario"),
      imgFit("secuencia_asignar_roles.png", PORT_PX, 1.586),
      caption("Figura 7. Secuencia — Asignar roles a un usuario."),
    ]),
  ],
});

module.exports = { especificaciones: [...specAutenticar, ...specRegistrar, ...specAsignarRoles, ...specPrivRol] };

// ============================================================================
// narrative.js — capítulos de prosa del Manual Técnico (§1–2, §5–10 + glosario).
// Describe el sistema tal como está desplegado (sin fases de implementación,
// sin rutas de archivos, sin historia). Reutiliza los helpers de docxlib.
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "..", "..", "diagramas", "_build", "docxlib.js"));
const { P, Field, H1, H2, H3, bullet, dataTable } = lib;

// mapa representativo de páginas APEX por módulo (P## → función)
const PAGINAS = {
  "Ventas": [
    ["P52 / P54", "Presupuesto/Pedido (creación y edición)"],
    ["P6", "Reporte de presupuestos"],
    ["P59", "Reservas de productos"],
    ["P30", "Ventas (bandeja)"],
  ],
  "Facturación y Caja": [
    ["P66 / P67", "Proceso de facturación"],
    ["P96", "Documento de factura (KuDE)"],
    ["P95 / P98 / P99 / P100", "Cobros y cobro de cuotas"],
    ["P119", "Documento de recibo"],
    ["P62 / P61 / P65", "Estado, cierre y apertura de caja"],
    ["P63 / P64", "Configuración de cajas"],
    ["P51 / P53", "Talonarios"],
    ["P124 / P125 / P126 / P127", "Notas de crédito (lista, solicitud, resolución, documento)"],
  ],
  "Compras y Cuentas por Pagar": [
    ["P68 / P69 / P70", "Proceso de compras"],
    ["P71 / P72 / P112", "Orden de compra y su detalle"],
    ["P97", "Documento de factura de proveedor"],
    ["P94 / P151", "Nota de crédito de proveedor y su documento"],
    ["P146 / P147", "Deuda a proveedores y generación de orden de pago"],
    ["P148 / P149 / P150", "Órdenes de pago (lista, documento, resolución)"],
    ["P41 / P42 / P43 / P44", "Proveedores y contactos"],
    ["P25 / P36 / P104", "Lista de precios por proveedor y carga masiva"],
  ],
  "Inventario": [
    ["P3 / P7", "Productos"],
    ["P47 / P50 / P88", "Stock y existencias"],
    ["P56", "Movimientos de stock"],
    ["P32 / P45", "Ajuste manual de stock"],
    ["P73 / P74 / P79 / P84", "Inventario físico (conteo, revisión)"],
    ["P37 / P39 / P40 / P46", "Marcas y categorías"],
    ["P142 / P143", "Dashboard e informe de inventario"],
  ],
  "Reportes Gerenciales": [
    ["P133 / P135", "Dashboard e informe de Ventas"],
    ["P136 / P137", "Dashboard e informe de Cobros"],
    ["P144 / P145", "Dashboard e informe de Compras"],
    ["P142 / P143", "Dashboard e informe de Inventario"],
    ["P138 / P139 / P140 / P141", "ABM de metas de cobranza y de venta"],
  ],
  "Seguridad y Personas": [
    ["P2 / P16 / P20", "Empleados (usuarios)"],
    ["P13 / P14 / P82", "Roles"],
    ["P75 / P76", "Privilegios"],
    ["P81 / P83", "Roles–Privilegios"],
    ["P11", "Empleados–Roles"],
    ["P77 / P78", "Recursos protegidos"],
    ["P4 / P19 / P48 / P91", "Clientes y alta rápida"],
    ["P9 / P10", "Personas"],
    ["P9999", "Página de login"],
  ],
  "Catálogos base y configuración": [
    ["P21 / P22", "Oficinas"],
    ["P17 / P18", "Monedas"],
    ["P57 / P60 / P89 / P90", "Métodos y formas de pago"],
    ["P23 / P24 / P26 / P27", "Departamentos y ciudades"],
    ["P101", "Cotización (tipos de cambio)"],
  ],
};

// ---- §1 Introducción -------------------------------------------------------
function cap1() {
  return [
    H1("1. Introducción"),
    H2("1.1. Propósito"),
    P("Este Manual Técnico documenta la arquitectura, el modelo de datos, la lógica de negocio, la seguridad, la integración fiscal, el despliegue y el mantenimiento del sistema Sole – Sistema de Gestión Empresarial (SOLSGE). Está dirigido al desarrollador o mantenedor responsable de operar, evolucionar o desplegar el sistema."),
    H2("1.2. Alcance"),
    P("SOLSGE es una aplicación de gestión empresarial que cubre los procesos de ventas (presupuestos y pedidos), facturación y caja, compras y cuentas por pagar, inventario, y reportes gerenciales, sobre un modelo transversal de seguridad y personas. El manual describe el sistema tal como se encuentra desplegado, no el proceso que lo produjo."),
    H2("1.3. Audiencia"),
    P("El documento asume un lector con conocimientos de Oracle Database y PL/SQL, y familiaridad con la plataforma Oracle APEX. No es un manual de usuario final: los procedimientos operativos paso a paso, orientados al usuario, se documentan en el Manual de Usuario."),
    H2("1.4. Documentos relacionados"),
    bullet("**Diagramas UML** — vista lógica del sistema (casos de uso, clases, estados, actividades y secuencia)."),
    bullet("**Anteproyecto** — objetivos, justificación y planificación del proyecto."),
    bullet("**Manual de Usuario** — guía operativa paso a paso para el usuario final."),
  ];
}

// ---- §2 Arquitectura -------------------------------------------------------
function cap2() {
  return [
    H1("2. Arquitectura del sistema"),
    H2("2.1. Stack tecnológico"),
    P("SOLSGE es una aplicación low-code construida sobre Oracle APEX, cuya lógica y datos residen íntegramente en la base de datos Oracle. Sus componentes son:"),
    bullet("**Oracle APEX 24.2** — plataforma de desarrollo y ejecución de la aplicación web (metadatos de páginas, regiones, procesos y componentes compartidos)."),
    bullet("**Oracle Autonomous Database 23ai** — motor de base de datos que aloja el esquema, los datos y toda la lógica PL/SQL."),
    bullet("**Oracle REST Data Services (ORDS)** — capa que publica la aplicación APEX por HTTP/HTTPS."),
    bullet("**Wallet SSL** — credenciales de conexión cifrada a la base de datos en la nube."),
    bullet("**Navegador web** — único requisito del lado del usuario; no se instala software cliente."),
    H2("2.2. Arquitectura en capas"),
    P("El sistema sigue el modelo de tres capas propio de APEX, todas concentradas en el servidor:"),
    bullet("**Capa de datos y lógica de negocio (PL/SQL)** — tablas, vistas, paquetes, procedimientos, funciones y triggers en el esquema WKSP_WORKPLACE. Aquí viven las reglas de negocio (facturación, cobros, stock, etc.)."),
    bullet("**Capa de aplicación (metadatos APEX)** — la definición declarativa de las páginas, procesos, validaciones y componentes compartidos, interpretada por el motor de APEX en tiempo de ejecución."),
    bullet("**Capa de presentación (navegador)** — el HTML/JavaScript/CSS que APEX genera y envía al navegador; no contiene lógica de negocio."),
    P("La ventaja del enfoque low-code es que la lógica crítica reside en la base de datos, cerca de los datos, garantizando integridad transaccional y reutilización entre pantallas, mientras que la interfaz se define de forma declarativa."),
    H2("2.3. Despliegue en la nube"),
    P("La aplicación se ejecuta sobre Oracle Cloud: la Autonomous Database aloja el esquema y APEX, y ORDS expone la aplicación por una URL. El usuario final accede por navegador, sin instalar nada. El detalle de la puesta en marcha del entorno se trata en el capítulo 8."),
  ];
}

// ---- §5 Aplicación APEX ----------------------------------------------------
function cap5() {
  const kids = [
    H1("5. Aplicación APEX"),
    H2("5.1. Identificación de la aplicación"),
    Field("Aplicación: ", "ID 100, alias f100."),
    Field("Workspace: ", "WKSP_WORKPLACE (mismo nombre que el esquema de análisis/parseo)."),
    Field("Versión de APEX: ", "24.2."),
    Field("Prefijo de imágenes (IMAGE_PREFIX): ", "CDN público de Oracle para los recursos estáticos de APEX."),
    P("Las cadenas de la interfaz, los nombres de página y los comentarios están en español, idioma que debe preservarse al mantener la aplicación."),
    H2("5.2. Mapa de páginas por módulo"),
    P("La aplicación se organiza en páginas agrupadas funcionalmente. La siguiente tabla resume, por módulo, las páginas principales y su función.", { after: 100 }),
  ];
  for (const [modulo, filas] of Object.entries(PAGINAS)) {
    kids.push(H3(modulo));
    kids.push(dataTable({ headers: ["Página(s)", "Función"], rows: filas, widths: [28, 72], fontSize: 18 }));
    kids.push(P("", { after: 100 }));
  }
  kids.push(H2("5.3. Componentes compartidos"));
  kids.push(bullet("**Listas de valores (LOV)** — catálogos reutilizados por los ítems de selección de las páginas."));
  kids.push(bullet("**Navegación (menú)** — lista jerárquica que organiza el acceso a las páginas por módulo."));
  kids.push(bullet("**Plantillas y temas** — definen la apariencia uniforme de páginas, regiones y botones."));
  kids.push(bullet("**Procesos y elementos de aplicación** — lógica y estado a nivel de sesión, compartidos entre páginas."));
  kids.push(H2("5.4. Autenticación y autorización"));
  kids.push(P("El acceso se controla mediante un esquema de autenticación propio (validación de credenciales contra la tabla de empleados) y esquemas de autorización basados en privilegios. La visibilidad de páginas, regiones y botones se condiciona al privilegio requerido, definido en el mapa de recursos. El detalle del modelo de seguridad se trata en el capítulo 6."));
  return kids;
}

// ---- §6 Seguridad ----------------------------------------------------------
function cap6() {
  return [
    H1("6. Seguridad"),
    H2("6.1. Modelo de control de acceso basado en roles (RBAC)"),
    P("El control de acceso se estructura en cuatro niveles: usuarios (empleados), roles, privilegios y recursos. Un empleado recibe uno o más roles; cada rol agrupa privilegios; y cada recurso de la aplicación (página o componente) declara el privilegio que exige."),
    bullet("**EMPLEADOS** — usuarios del sistema, subtipo de PERSONAS."),
    bullet("**ROLES** y **PRIVILEGIOS** — roles del negocio y privilegios atómicos."),
    bullet("**EMPLEADOS_ROLES** y **ROLES_PRIVILEGIOS** — asignan roles a usuarios y privilegios a roles (relaciones N:M)."),
    bullet("**RECURSOS** — mapa que asocia cada página o componente de la aplicación con el privilegio necesario para acceder."),
    P("Los privilegios efectivos de cada usuario se resuelven a través de sus roles y se consultan mediante vistas de seguridad, que las páginas usan para condicionar la visibilidad de sus elementos."),
    H2("6.2. Autenticación"),
    P("La autenticación valida las credenciales del empleado contra la base de datos. Las contraseñas se almacenan como hash con sal (no en texto plano). El sistema contempla el bloqueo del usuario por intentos fallidos y la gestión de tokens de reseteo de contraseña con vencimiento. Toda esta lógica reside en el paquete de gestión de empleados."),
    H2("6.3. Buenas prácticas aplicadas"),
    bullet("Parámetros de negocio centralizados en una tabla de configuración, no dispersos en el código."),
    bullet("Datos sensibles (contraseña) protegidos con hash y sal; los tokens tienen vencimiento."),
    bullet("Autorización declarativa por privilegio en páginas, regiones y botones, respaldada por el mapa de recursos."),
  ];
}

// ---- §7 Integración fiscal -------------------------------------------------
function cap7() {
  return [
    H1("7. Integración fiscal (SET / SIFEN)"),
    H2("7.1. Talonarios timbrados"),
    P("La emisión de comprobantes se numera mediante talonarios timbrados por la Subsecretaría de Estado de Tributación (SET). Cada comprobante lleva la numeración establecimiento–punto de expedición–número correlativo, dentro del rango y la vigencia autorizados por su timbrado."),
    P("El establecimiento y el punto de expedición no se tipean en el talonario: se derivan automáticamente de la caja configurada y de la oficina a la que pertenece, garantizando consistencia fiscal. Rige la restricción de un único talonario activo por caja y tipo de comprobante."),
    H2("7.2. Representación gráfica (KuDE) y su alcance"),
    P("Las facturas, notas de crédito y recibos se imprimen con una representación gráfica de estilo KuDE. Es importante precisar su alcance real:"),
    bullet("**No es un Documento Electrónico integrado a SIFEN**: no genera CDC ni código QR."),
    bullet("Los documentos llevan la leyenda «sin validez fiscal»: son representación gráfica y registro interno, no comprobantes electrónicos autorizados."),
    bullet("El recibo de dinero no es un Documento Electrónico SIFEN (SIFEN cubre factura, nota de crédito/débito, remisión y autofactura); reutiliza el estilo visual solo por coherencia."),
    P("En síntesis, el sistema respeta la estructura de numeración timbrada de la SET, pero la integración electrónica plena con SIFEN está fuera del alcance."),
  ];
}

// ---- §8 Despliegue ---------------------------------------------------------
function cap8() {
  return [
    H1("8. Despliegue y puesta en marcha"),
    H2("8.1. Aclaración: no es una instalación en el cliente"),
    P("Al ejecutarse en la nube, el usuario final no instala nada: accede por navegador con la URL del sistema. Este capítulo no describe una instalación por equipo, sino cómo el desarrollador o mantenedor reproduce y despliega el entorno completo desde cero (recuperación ante desastres, migración a otra cuenta de Oracle Cloud o ambiente de evaluación)."),
    H2("8.2. Requisitos del entorno"),
    bullet("**Oracle Autonomous Database 23ai** — base de datos que aloja el esquema y APEX."),
    bullet("**Oracle APEX 24.2** — instancia de APEX sobre la ADB."),
    bullet("**Wallet SSL** — credenciales de conexión (con vencimiento; debe renovarse antes de expirar)."),
    bullet("**Cliente SQL (SQLcl)** — para crear el esquema y aplicar las migraciones de la base."),
    H2("8.3. Secuencia de despliegue"),
    P("El despliegue del entorno consta de dos frentes:"),
    bullet("**Base de datos** — crear el esquema y ejecutar, en orden, las migraciones de estructura y lógica (DDL, paquetes, procedimientos, triggers y vistas). Cada migración es idempotente y cierra con un bloque de verificación."),
    bullet("**Aplicación APEX** — importar la aplicación 100 en el workspace y sus componentes compartidos (menú, plantillas, LOVs)."),
    H2("8.4. Carga inicial de datos (bootstrap)"),
    P("Sin estos datos maestros el sistema no puede operar. Se distinguen de los datos de demostración."),
    H3("Datos maestros obligatorios"),
    bullet("**Parámetros del sistema** — datos de la empresa emisora (razón social, RUC, dirección, ciudad, teléfono, actividad económica, tipo de contribuyente) y reglas de negocio (p. ej. horas límite de cancelación, días de vigencia de presupuesto, límite mensual de órdenes de compra, ventana de costeo, activación del reverso de cobro)."),
    bullet("**Seguridad** — roles, privilegios y su asignación, y al menos un usuario administrador, para poder ingresar."),
    bullet("**Estructura fiscal** — oficinas con su establecimiento SET, cajas configuradas con su punto de expedición, y talonarios timbrados; prerequisito para facturar."),
    bullet("**Catálogos de referencia** — monedas, métodos de pago, tipos de IVA y motivos de nota de crédito."),
    H3("Datos de demostración (no obligatorios)"),
    P("Los productos, metas y transacciones de ejemplo (ventas, cobros, inventario, compras) sirven para la evaluación y la defensa del proyecto; no son necesarios para operar y se cargan por separado."),
    H2("8.5. Configuración final"),
    bullet("**Zona horaria** — la base corre en UTC; la fecha/hora de negocio se resuelve a zona local (UTC−3) mediante las funciones de fecha del sistema."),
    bullet("**Conexión** — configurar el wallet SSL de la base de datos destino."),
    bullet("**Recursos estáticos** — verificar el prefijo de imágenes (IMAGE_PREFIX) de APEX."),
  ];
}

// ---- §9 Mantenimiento ------------------------------------------------------
function cap9() {
  return [
    H1("9. Mantenimiento y operación"),
    H2("9.1. Gestión de la aplicación APEX"),
    P("La aplicación se mantiene con el ciclo habitual de APEX: se exporta el componente a modificar, se edita, y se importa de nuevo al workspace. El repositorio conserva un export completo de la aplicación como línea base de referencia, y un árbol de trabajo con los parches que se importan de forma selectiva."),
    H2("9.2. Particularidades a tener en cuenta"),
    bullet("**La base corre en UTC.** Nunca debe usarse la fecha/hora del servidor para valores de negocio o auditoría: se usan las funciones de fecha local del sistema (UTC−3)."),
    bullet("**Codificación de la moneda.** Los movimientos de caja guardan la moneda como texto ('PYG') mientras los comprobantes la guardan como código; por eso los cruces con el catálogo de monedas contemplan ambas formas."),
    bullet("**Estado de los movimientos de caja.** El estado de un movimiento de caja indica si la caja está abierta o cerrada (no si el movimiento está activo o anulado); ambos representan dinero válido."),
    bullet("**Módulo de reverso de cobro.** Está oculto de forma deliberada mediante un parámetro del sistema; su backend y su histórico se conservan. No debe tratarse su ausencia en el menú como un error."),
    H2("9.3. Respaldo y restauración"),
    P("El respaldo se apoya en las capacidades de la Autonomous Database (respaldos automáticos) y en el export versionado de la aplicación APEX y de las migraciones de la base, que permiten reconstruir el sistema en un entorno nuevo siguiendo el capítulo 8."),
  ];
}

// ---- §10 Anexos (intro + errores + glosario). El Anexo A (ER) va aparte -----
function cap10() {
  const errores = [
    ["Talonario y numeración fiscal", "Talonario fuera de vigencia, timbrado no cargado, punto de expedición o establecimiento faltante, talonario duplicado por caja y tipo."],
    ["Facturación y caja", "Sin caja abierta, caja no correspondiente al día, monto insuficiente, transición de estado inválida, stock insuficiente al facturar."],
    ["Cierre y arqueo de caja", "Errores de validación del cierre y del arqueo de caja."],
    ["Interés de financiación", "Errores del cálculo y financiación de la venta a crédito."],
    ["Nota de crédito (venta)", "Factura no elegible, cantidad no acreditable, validaciones de la solicitud y su aprobación."],
    ["Cobros y cartera", "Errores del cobro de cuotas y de la cartera por cobrar."],
    ["Compras y cuentas por pagar", "Errores de recepción, registro de comprobante, generación y confirmación de orden de pago."],
    ["Nota de crédito de compra", "Factura de compra no elegible, cantidad no devolvible o acreditable, factura ya pagada."],
    ["Inventario", "Errores de ajuste, transferencia y validación del inventario físico."],
    ["Reportes", "Errores de validación de los generadores de informes gerenciales."],
  ];
  const glosario = [
    ["APEX", "Oracle Application Express, plataforma low-code de la aplicación."],
    ["ADB", "Autonomous Database, base de datos gestionada de Oracle Cloud."],
    ["ORDS", "Oracle REST Data Services, capa que publica la aplicación por HTTP."],
    ["CxC / CxP", "Cuentas por cobrar / Cuentas por pagar."],
    ["OC / OP", "Orden de compra / Orden de pago."],
    ["NC", "Nota de crédito."],
    ["KuDE", "Representación gráfica impresa de un comprobante (aquí, sin validez fiscal)."],
    ["SET", "Subsecretaría de Estado de Tributación (autoridad tributaria)."],
    ["SIFEN", "Sistema Integrado de Facturación Electrónica Nacional."],
    ["CDC", "Código de Control de un Documento Electrónico SIFEN."],
    ["Talonario", "Rango de numeración timbrado por la SET para emitir comprobantes."],
    ["RBAC", "Control de acceso basado en roles."],
    ["PYG", "Guaraní paraguayo, moneda base del sistema."],
  ];
  return [
    H1("10. Anexos"),
    P("Este capítulo reúne el material de referencia. El Anexo A (modelos entidad-relación por módulo) se presenta al final del documento, en formato apaisado."),
    H2("10.1. Catálogo de errores de negocio"),
    P("El sistema señala las violaciones de reglas de negocio con errores de aplicación en el rango −20000, agrupados por área funcional. La siguiente tabla resume esas áreas.", { after: 100 }),
    dataTable({ headers: ["Área funcional", "Situaciones señaladas"], rows: errores, widths: [30, 70], fontSize: 18 }),
    P("", { after: 120 }),
    H2("10.2. Glosario técnico"),
    dataTable({ headers: ["Término", "Significado"], rows: glosario, widths: [22, 78], fontSize: 18 }),
  ];
}

module.exports = { cap1, cap2, cap5, cap6, cap7, cap8, cap9, cap10 };

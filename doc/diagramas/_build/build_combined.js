// ============================================================================
// DOCUMENTO COMBINADO — todos los módulos, organizado POR TIPO DE DIAGRAMA.
// Estructura (verticales primero, horizontales al final → una sola rotación):
//   1. Casos de Uso   (vertical)   — por módulo: diagrama + especificaciones
//   2. Estados        (vertical)
//   3. Actividades    (vertical)
//   4. Clases         (apaisado)
//   5. Secuencia      (apaisado)
// Ejecutar: node doc/diagramas/_build/build_combined.js
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "docxlib.js"));
const { P, H1, H2, H3, caption, pageBreak, makeImg, makeCaratula, portraitSection, landscapeSection, buildDoc } = lib;
const { PORT_PX } = lib.SIZES;

const DIAG = path.join(__dirname, "..");
const OUT = path.join(DIAG, "Diagramas_UML_SOLSGE.docx");

// orden de módulos (flujo de negocio + soporte)
const M = [
  { key: "ventas",           name: "Ventas (Presupuestos)" },
  { key: "facturacion_caja", name: "Facturación + Caja" },
  { key: "compras",          name: "Compras" },
  { key: "inventario",       name: "Inventario" },
  { key: "reportes",         name: "Reportes Gerenciales" },
  { key: "seguridad",        name: "Seguridad" },
];

// manifiesto de diagramas por módulo (archivos + ratios reales)
const D = {
  ventas: {
    casosUso: ["casos_uso_ventas.png", 2.176],
    estados: [["Presupuesto", "estados_presupuesto.png", 1.267], ["Reserva de Producto", "estados_reserva.png", 1.176]],
    actividades: [["Crear presupuesto", "actividad_crear_presupuesto.png", 0.789], ["Aprobar presupuesto", "actividad_aprobar_presupuesto.png", 0.644]],
    clases: ["clases_ventas.png", 0.763],
    secuencias: [["Crear presupuesto", "secuencia_crear_presupuesto.png", 2.245], ["Aprobar presupuesto", "secuencia_aprobar_presupuesto.png", 1.597]],
  },
  facturacion_caja: {
    casosUso: ["casos_uso_facturacion.png", 1.145],
    estados: [["Factura", "estados_factura.png", 1.128], ["Cuota de Cuenta por Cobrar", "estados_cuota.png", 1.101], ["Caja", "estados_caja.png", 1.113]],
    actividades: [["Facturar contado", "actividad_facturar_contado.png", 0.429], ["Cobrar cuota", "actividad_cobrar_cuota.png", 0.373], ["Anular factura", "actividad_anular_factura.png", 0.789], ["Cerrar y arquear caja", "actividad_cerrar_caja.png", 0.559]],
    clases: ["clases_facturacion_caja.png", 1.520],
    secuencias: [["Facturar contado", "secuencia_facturar_contado.png", 1.844], ["Cobrar cuota", "secuencia_cobrar_cuota.png", 1.873], ["Anular factura", "secuencia_anular_factura.png", 1.757], ["Cerrar y arquear caja", "secuencia_cerrar_caja.png", 1.626]],
  },
  compras: {
    casosUso: ["casos_uso_compras.png", 2.583],
    estados: [["Orden de Compra", "estados_orden_compra.png", 1.106], ["Comprobante de Proveedor", "estados_comprobante_prov.png", 2.192], ["Cuenta por Pagar", "estados_cuenta_pagar.png", 1.762], ["Orden de Pago", "estados_orden_pago.png", 2.703]],
    actividades: [["Recepcionar orden de compra", "actividad_recepcionar_oc.png", 0.993], ["Generar y confirmar orden de pago", "actividad_orden_pago.png", 0.800], ["Registrar nota de crédito de compra", "actividad_nc_compra.png", 0.872]],
    clases: ["clases_compras.png", 1.152],
    secuencias: [["Recepcionar orden de compra", "secuencia_recepcionar_oc.png", 3.251], ["Registrar factura de proveedor", "secuencia_registrar_factura_prov.png", 2.212], ["Generar y confirmar orden de pago", "secuencia_orden_pago.png", 2.503], ["Registrar nota de crédito de compra", "secuencia_nc_compra.png", 1.978]],
  },
  inventario: {
    casosUso: ["casos_uso_inventario.png", 1.549],
    estados: [["Inventario físico", "estados_inventario.png", 1.101]],
    actividades: [["Realizar y aprobar inventario físico", "actividad_inventario.png", 0.982], ["Generar informe de inventario", "actividad_generar_informe.png", 1.065]],
    clases: ["clases_inventario.png", 0.833],
    secuencias: [["Actualización de stock por movimiento", "secuencia_actualizar_stock.png", 1.853], ["Realizar y aprobar inventario físico", "secuencia_inventario.png", 2.216], ["Generar informe de inventario", "secuencia_generar_informe.png", 2.647]],
  },
  reportes: {
    casosUso: ["casos_uso_reportes.png", 1.180],
    estados: [],
    actividades: [["Generar informe gerencial", "actividad_generar_informe.png", 1.004]],
    clases: ["clases_reportes.png", 2.417],
    secuencias: [["Ver dashboard gerencial", "secuencia_ver_dashboard.png", 2.244], ["Generar informe gerencial", "secuencia_generar_informe.png", 2.461]],
  },
  seguridad: {
    casosUso: ["casos_uso_seguridad.png", 1.780],
    estados: [["Usuario", "estados_usuario.png", 1.566]],
    actividades: [["Autenticarse", "actividad_autenticar.png", 0.559], ["Asignar roles a un usuario", "actividad_asignar_roles.png", 0.947]],
    clases: ["clases_seguridad.png", 0.688],
    secuencias: [["Autenticarse", "secuencia_autenticar.png", 1.360], ["Asignar roles a un usuario", "secuencia_asignar_roles.png", 1.586]],
  },
};

// helpers de imagen ligados a cada carpeta de módulo
const IMG = {}; M.forEach((m) => { IMG[m.key] = makeImg(path.join(DIAG, m.key)); });
// especificaciones exportadas por cada módulo
const SPECS = {}; M.forEach((m) => { SPECS[m.key] = require(path.join(DIAG, m.key, "build.js")).especificaciones; });

// contador global de figuras
let fig = 0;
const cap = (text) => caption("Figura " + (++fig) + ". " + text);

// --- sección 1: Casos de Uso (vertical) ------------------------------------
const secCasos = [H1("1. Casos de Uso"),
  P("Mapa general de cada módulo (actores y casos de uso) seguido de las especificaciones de sus casos principales, en el formato de la plantilla. Todo refleja la lógica real del sistema.", { after: 120 })];
M.forEach((m, i) => {
  const [file, r] = D[m.key].casosUso;
  secCasos.push(m_h2(i, m.name));
  secCasos.push(IMG[m.key].imgFit(file, PORT_PX, r));
  secCasos.push(cap("Casos de uso — Módulo " + m.name + "."));
  secCasos.push(pageBreak());
  SPECS[m.key].forEach((p) => secCasos.push(p));
  if (i < M.length - 1) secCasos.push(pageBreak());
});

// --- sección 2: Estados (vertical) -----------------------------------------
const secEstados = [H1("2. Diagramas de Estados"),
  P("Objetos con más de un estado, indicando el evento de cada transición. Los módulos sin objetos con ciclo de vida propio (Reportes) no incluyen diagramas de estados.", { after: 120 })];
M.forEach((m, i) => {
  const est = D[m.key].estados;
  secEstados.push(m_h2(i, m.name));
  if (est.length === 0) { secEstados.push(P("No aplica: este módulo no tiene objetos con más de un estado.")); }
  est.forEach(([t, file, r], j) => {
    if (j > 0) secEstados.push(pageBreak());
    secEstados.push(H3(t));
    secEstados.push(IMG[m.key].imgFit(file, PORT_PX, r));
    secEstados.push(cap("Estados — " + t + " (" + m.name + ")."));
  });
  if (i < M.length - 1) secEstados.push(pageBreak());
});

// --- sección 3: Actividades (vertical) -------------------------------------
const secAct = [H1("3. Diagramas de Actividades"),
  P("Flujo de control de los procesos transaccionales, con decisiones y caminos de error, repartidos entre el actor y el sistema.", { after: 120 })];
M.forEach((m, i) => {
  secAct.push(m_h2(i, m.name));
  D[m.key].actividades.forEach(([t, file, r], j) => {
    if (j > 0) secAct.push(pageBreak());
    secAct.push(H3(t));
    secAct.push(IMG[m.key].imgFitH(file, lib.SIZES.ACT_H, r));
    secAct.push(cap("Actividad — " + t + " (" + m.name + ")."));
  });
  if (i < M.length - 1) secAct.push(pageBreak());
});

// --- sección 4: Clases (apaisado) ------------------------------------------
const secClases = [H1("4. Diagramas de Clases"),
  P("Vista estructural de cada módulo: entidades y relaciones tipadas obtenidas de las tablas reales. Las clases en gris son clases frontera de otros módulos.", { after: 120 })];
M.forEach((m, i) => {
  const [file, r] = D[m.key].clases;
  if (i > 0) secClases.push(pageBreak());
  secClases.push(m_h2(i, m.name));
  secClases.push(IMG[m.key].imgFitBox(file, 900, 470, r));
  secClases.push(cap("Diagrama de clases — Módulo " + m.name + "."));
});

// --- sección 5: Secuencia (apaisado) ---------------------------------------
const secSec = [H1("5. Diagramas de Secuencia"),
  P("Derivados de los casos de uso; muestran las llamadas reales entre páginas, funciones/procedimientos PL/SQL, triggers y entidades.", { after: 120 })];
M.forEach((m, i) => {
  secSec.push(m_h2(i, m.name));
  D[m.key].secuencias.forEach(([t, file, r], j) => {
    if (j > 0) secSec.push(pageBreak());
    secSec.push(H3(t));
    secSec.push(IMG[m.key].imgFitBox(file, 900, 430, r));
    secSec.push(cap("Secuencia — " + t + " (" + m.name + ")."));
  });
  if (i < M.length - 1) secSec.push(pageBreak());
});

// divisor de módulo (H2 "Módulo N. Nombre")
function m_h2(i, name) { return H2("Módulo " + (i + 1) + ". " + name); }

buildDoc({
  outPath: OUT,
  sections: [
    portraitSection(makeCaratula({ subtitulo: "Sistema completo — todos los módulos" }), true),
    portraitSection(secCasos),
    portraitSection(secEstados),
    portraitSection(secAct),
    landscapeSection(secClases),
    landscapeSection(secSec),
  ],
});

// ============================================================================
// Módulo REPORTES GERENCIALES — contenido del Word de diagramas UML.
// Cross-cutting: los 4 dashboards (Ventas F18, Cobros F22, Compras F25,
// Inventario F23) + generación de informes. Actor: Gerente. Sin estados.
// Vertical: 1 Casos de Uso, 2 Estados (N/A), 3 Actividades.
// Horizontal: 4 Clases (ancho), 5 Secuencia.
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "..", "_build", "docxlib.js"));
const { P, Field, H1, H2, H3, SubBold, bullet, num, caption, pageBreak,
        makeImg, makeCaratula, portraitSection, landscapeSection, buildDoc } = lib;
const { PORT_PX, ACT_H, LAND_H_CLASS, LAND_H_SEQ } = lib.SIZES;
const { imgFit, imgFitH } = makeImg(__dirname);
const OUT = path.join(__dirname, "..", "MUESTRA_Reportes_Gerenciales.docx");

const specDashboard = [
  H2("Especificación de caso de uso: Ver dashboard gerencial"),
  H3("Descripción"),
  P("Permite al Gerente ver los tableros con indicadores (KPIs) y gráficos de cada área: Ventas (F18), Cobros (F22), Compras (F25) e Inventario (F23). Cada dashboard lee vistas que agregan los hechos transaccionales del área y, donde aplica, los comparan con las metas del período."),
  Field("Actor principal: ", "Gerente."),
  Field("Entorno de invocación: ", "dashboards gerenciales (uno por área)."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Gerente abre el **dashboard** del área (Ventas, Cobros, Compras o Inventario)."),
  num("Elige el **período** y/o la **sucursal**."),
  num("El sistema calcula los **KPIs** y grafica desde las vistas agregadas (V_VENTAS_*, V_COBROS_*, V_CMP_*, V_INV_*), comparando con METAS_VENTA / METAS_COBRANZA donde corresponde."),
  num("El Gerente interpreta los tableros (evolución, ranking, cumplimiento de meta, aging, rotación, etc.)."),
  SubBold("Flujos Alternativos"),
  H3("Sin datos en el período"),
  P("Si no hay hechos en el período elegido, los gráficos de evolución aparecen vacíos; los indicadores de snapshot (cartera, existencias) usan el estado actual."),
  H3("Precondiciones"),
  bullet("El Gerente tiene acceso a los reportes gerenciales."),
  bullet("Existen hechos transaccionales (ventas, cobros, compras, movimientos) y, si aplica, metas cargadas."),
  H3("Pos-condiciones"),
  bullet("Consulta de solo lectura; no altera datos transaccionales."),
];

const specInforme = [
  pageBreak(),
  H2("Especificación de caso de uso: Generar informe gerencial"),
  H3("Descripción"),
  P("Permite al Gerente generar informes imprimibles por filtros para cada área (ventas, cobros, compras, inventario), producidos por las funciones FN_INFORME_*_HTML sobre las mismas vistas que alimentan los dashboards."),
  Field("Actor principal: ", "Gerente."),
  Field("Entorno de invocación: ", "generadores de informe (uno por área)."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Gerente elige el **área** y los **filtros** (rango de fechas, sucursal, y la dimensión propia del área: vendedor, cobrador, proveedor, categoría)."),
  num("El sistema ejecuta la función **FN_INFORME_<área>_HTML**, que consulta las vistas agregadas."),
  num("El sistema compone el **HTML** imprimible (barras CSS, formato de impresión) y lo muestra."),
  num("El Gerente **imprime** o exporta el informe."),
  SubBold("Flujos Alternativos"),
  H3("Filtros sin resultados"),
  P("Si los filtros no arrojan datos, el informe se genera con las secciones vacías."),
  H3("Precondiciones"),
  bullet("El Gerente tiene acceso a los reportes."),
  H3("Pos-condiciones"),
  bullet("Informe generado (solo lectura)."),
];

if (require.main === module) buildDoc({
  outPath: OUT,
  sections: [
    portraitSection(makeCaratula({ subtitulo: "Módulo Reportes Gerenciales" }), true),

    // ===== BLOQUE VERTICAL =====
    portraitSection([
      H1("1. Casos de Uso"),
      P("Mapa general del módulo (actor y casos de uso principales) y sus especificaciones. Este módulo consolida los reportes gerenciales de las cuatro áreas construidas sobre los módulos transaccionales.", { after: 60 }),
      imgFit("casos_uso_reportes.png", PORT_PX, 1.180),
      caption("Figura 1. Diagrama de casos de uso — Módulo Reportes Gerenciales."),
      pageBreak(),
      H2("1.1. Especificaciones de casos de uso"),
      ...specDashboard, ...specInforme,
    ]),
    portraitSection([
      H1("2. Diagramas de Estados"),
      P("No aplica. Los reportes gerenciales son consultas de solo lectura (dashboards e informes); no hay objetos con ciclo de vida propios de este módulo. Los estados relevantes pertenecen a los objetos transaccionales de cada módulo de origen.", { after: 60 }),
    ]),
    portraitSection([
      H1("3. Diagramas de Actividades"),
      P("Flujo de control del proceso de generación de informes gerenciales.", { after: 60 }),
      H2("3.1. Generar informe gerencial"),
      imgFitH("actividad_generar_informe.png", ACT_H, 1.004),
      caption("Figura 2. Actividad — Generar informe gerencial."),
    ]),

    // ===== BLOQUE HORIZONTAL =====
    landscapeSection([
      H1("4. Diagrama de Clases"),
      P("Modelo de la capa de reportes: los dashboards y las funciones de informe consumen vistas que agregan los hechos transaccionales y los comparan con las metas. Las clases en gris son los hechos frontera de los módulos de origen.", { after: 60 }),
      imgFitH("clases_reportes.png", LAND_H_CLASS, 2.417),
      caption("Figura 3. Diagrama de clases — Módulo Reportes Gerenciales."),
    ]),
    landscapeSection([
      H1("5. Diagramas de Secuencia"),
      P("Derivados de los casos de uso; muestran las llamadas reales entre la página, las funciones de informe, las vistas y las entidades.", { after: 60 }),
      H2("5.1. Ver dashboard gerencial"),
      imgFitH("secuencia_ver_dashboard.png", LAND_H_SEQ, 2.244),
      caption("Figura 4. Secuencia — Ver dashboard gerencial."),
      pageBreak(),
      H2("5.2. Generar informe gerencial"),
      imgFitH("secuencia_generar_informe.png", LAND_H_SEQ, 2.461),
      caption("Figura 5. Secuencia — Generar informe gerencial."),
    ]),
  ],
});

module.exports = { especificaciones: [...specDashboard, ...specInforme] };

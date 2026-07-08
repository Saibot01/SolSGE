// ============================================================================
// Módulo INVENTARIO — contenido del Word de diagramas UML. Modelo aprobado.
// Incluye el proceso de inventariado físico (INVENTARIO_PKG) con su estado.
// Vertical: 1 Casos de Uso, 2 Estados, 3 Actividades, 4 Clases.
// Horizontal: 5 Secuencia (anchas).
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "..", "_build", "docxlib.js"));
const { P, Field, H1, H2, H3, SubBold, bullet, num, caption, pageBreak,
        makeImg, makeCaratula, portraitSection, landscapeSection, buildDoc } = lib;
const { PORT_PX, ACT_H, LAND_H_SEQ } = lib.SIZES;
const { imgFit, imgFitH } = makeImg(__dirname);
const OUT = path.join(__dirname, "..", "MUESTRA_Inventario.docx");

const specExistencias = [
  H2("Especificación de caso de uso: Consultar existencias"),
  H3("Descripción"),
  P("Permite consultar la cantidad disponible (on-hand) de los productos por oficina desde el reporte de existencias, junto con sus niveles mínimo y máximo. El on-hand autoritativo es STOCK_PRODUCTO.CANTIDAD."),
  Field("Actor principal: ", "Encargado de Depósito (también el Gerente)."),
  Field("Entorno de invocación: ", "reporte / página de existencias."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El usuario abre el reporte de existencias y elige la **oficina** (y opcionalmente un producto o categoría)."),
  num("El sistema muestra la **cantidad on-hand** y los niveles mínimo/máximo por producto."),
  SubBold("Flujos Alternativos"),
  H3("Producto sin existencias en la oficina"),
  P("Si el producto no tiene fila de stock en la oficina, se muestra cantidad cero."),
  H3("Precondiciones"),
  bullet("El stock inicial de los productos está cargado."),
  H3("Pos-condiciones"),
  bullet("Consulta de solo lectura; no altera el stock."),
];

const specHistorial = [
  pageBreak(),
  H2("Especificación de caso de uso: Consultar historial de movimientos de stock"),
  H3("Descripción"),
  P("Muestra el historial de movimientos (ENTRADA, SALIDA y AJUSTE) de un producto —con su referencia y fecha—, que explica cómo se llegó al on-hand actual. El historial es un registro append-only."),
  Field("Actor principal: ", "Encargado de Depósito."),
  Field("Entorno de invocación: ", "reporte de movimientos de stock."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El usuario elige un **producto** (y opcionalmente la oficina y el rango de fechas)."),
  num("El sistema lista los **movimientos** (tipo, cantidad, fecha, referencia, usuario)."),
  SubBold("Flujos Alternativos"),
  H3("Sin movimientos"),
  P("Si el producto no tuvo movimientos en el criterio, la lista aparece vacía (el on-hand puede provenir de la carga inicial, que no genera movimiento)."),
  H3("Precondiciones"),
  bullet("El producto existe."),
  H3("Pos-condiciones"),
  bullet("Consulta de solo lectura."),
];

const specRealizar = [
  pageBreak(),
  H2("Especificación de caso de uso: Realizar inventario físico"),
  H3("Descripción"),
  P("Permite al Encargado de Depósito crear un inventario de una oficina, contar físicamente la mercadería y registrar la cantidad por producto. El sistema calcula la diferencia contra el stock del sistema. Al enviarlo, queda a la espera de aprobación."),
  Field("Actor principal: ", "Encargado de Depósito."),
  Field("Entorno de invocación: ", "pantalla de inventario físico."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Encargado de Depósito **crea** un inventario de una oficina (estado BORRADOR)."),
  num("Cuenta la mercadería y **registra la cantidad física** por producto; el sistema guarda el **stock del sistema**, la **cantidad física** y la **diferencia** (INVENTARIO_DETALLE)."),
  num("**Envía** el inventario a aprobación (INVENTARIO_PKG.enviar): pasa a **ENVIADO**."),
  SubBold("Flujos Alternativos"),
  H3("Corrección en Borrador"),
  P("Mientras el inventario está en Borrador, el Encargado de Depósito puede corregir los conteos; solo al enviar queda bloqueado para aprobación."),
  H3("Precondiciones"),
  bullet("Existe stock cargado en la oficina a inventariar."),
  H3("Pos-condiciones"),
  bullet("Inventario en estado ENVIADO con las diferencias calculadas por producto."),
  H3("Puntos de Extensión"),
  bullet("Aprobar inventario."),
];

const specAprobarInv = [
  pageBreak(),
  H2("Especificación de caso de uso: Aprobar inventario"),
  H3("Descripción"),
  P("Permite al Supervisor revisar un inventario enviado y aprobarlo —lo que genera los ajustes de stock que reconcilian las existencias— o rechazarlo."),
  Field("Actor principal: ", "Supervisor."),
  Field("Entorno de invocación: ", "pantalla de aprobación de inventario."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Supervisor abre un inventario en estado **ENVIADO** y revisa las diferencias."),
  num("**Aprueba** el inventario (INVENTARIO_PKG.aprobar)."),
  num("Por cada línea con **diferencia ≠ 0**, el sistema genera un movimiento de **AJUSTE**: ENTRADA si la diferencia es positiva, SALIDA si es negativa, actualizando STOCK_PRODUCTO."),
  num("El inventario queda **APROBADO** y las existencias quedan reconciliadas."),
  SubBold("Flujos Alternativos"),
  H3("Rechazar el inventario"),
  P("El Supervisor puede rechazar el inventario (INVENTARIO_PKG.rechazar): pasa a RECHAZADO y no genera ajustes."),
  H3("Precondiciones"),
  bullet("El inventario está en estado ENVIADO."),
  H3("Pos-condiciones"),
  bullet("Al aprobar: existencias reconciliadas con movimientos de ajuste; inventario APROBADO. Al rechazar: inventario RECHAZADO sin ajustes."),
];

const specDashboard = [
  pageBreak(),
  H2("Especificación de caso de uso: Ver dashboard de inventario"),
  H3("Descripción"),
  P("Permite al Gerente ver el dashboard (reporte gerencial de inventario) con indicadores y gráficos: valorización por categoría, stock frente a mínimo/máximo y quiebres, entradas/salidas por mes, rotación, valor por sucursal y top productos."),
  Field("Actor principal: ", "Gerente."),
  Field("Entorno de invocación: ", "dashboard / reporte gerencial de inventario."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Gerente abre el dashboard y elige la **sucursal** (o todas)."),
  num("El sistema calcula los **KPIs** y grafica valorización, niveles/quiebres, rotación y flujo desde las vistas V_INV_*."),
  SubBold("Flujos Alternativos"),
  H3("Sin datos en el período"),
  P("Si no hay movimientos en el período, los gráficos de flujo/rotación aparecen vacíos; la valorización y los niveles usan el snapshot actual."),
  H3("Precondiciones"),
  bullet("El Gerente tiene acceso a los reportes gerenciales."),
  H3("Pos-condiciones"),
  bullet("Consulta de solo lectura."),
];

const specInforme = [
  pageBreak(),
  H2("Especificación de caso de uso: Generar informe de inventario"),
  H3("Descripción"),
  P("Permite al Gerente generar un informe imprimible del inventario filtrando por sucursal, categoría y rango de fechas. Combina el snapshot de stock con el flujo del rango (FN_INFORME_INVENTARIO_HTML)."),
  Field("Actor principal: ", "Gerente."),
  Field("Entorno de invocación: ", "generador de informe (reporte gerencial de inventario)."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Gerente elige los **filtros** (sucursal, categoría, rango de fechas)."),
  num("El sistema ejecuta **FN_INFORME_INVENTARIO_HTML**, que consulta las vistas de valorización, niveles y rotación."),
  num("El sistema compone el **HTML** imprimible (barras CSS, formato de impresión) y lo muestra."),
  num("El Gerente **imprime** o exporta el informe."),
  SubBold("Flujos Alternativos"),
  H3("Filtros sin resultados"),
  P("Si los filtros no arrojan datos, el informe se genera con las secciones vacías."),
  H3("Precondiciones"),
  bullet("El Gerente tiene acceso a los reportes."),
  H3("Pos-condiciones"),
  bullet("Informe generado (solo lectura); no altera el stock."),
];

if (require.main === module) buildDoc({
  outPath: OUT,
  sections: [
    portraitSection(makeCaratula({ subtitulo: "Módulo Inventario" }), true),

    // ===== BLOQUE VERTICAL =====
    portraitSection([
      H1("1. Casos de Uso"),
      P("Mapa general del módulo (actores y casos de uso principales) y las especificaciones de cada caso. El stock lo mueven otros módulos (Compras/recepción genera ENTRADA, Facturación genera SALIDA); Inventario aporta la consulta, el inventario físico (conteo y ajuste) y el reporte.", { after: 60 }),
      imgFit("casos_uso_inventario.png", PORT_PX, 1.549),
      caption("Figura 1. Diagrama de casos de uso — Módulo Inventario."),
      pageBreak(),
      H2("1.1. Especificaciones de casos de uso"),
      ...specExistencias, ...specHistorial, ...specRealizar, ...specAprobarInv, ...specDashboard, ...specInforme,
    ]),
    portraitSection([
      H1("2. Diagramas de Estados"),
      P("Objeto del módulo con más de un estado, indicando el evento de cada transición.", { after: 120 }),
      H2("2.1. Inventario físico"),
      imgFit("estados_inventario.png", PORT_PX, 1.101),
      caption("Figura 2. Estados del Inventario físico (INVENTARIO.ESTADO)."),
    ]),
    portraitSection([
      H1("3. Diagramas de Actividades"),
      P("Flujo de control de los procesos del módulo, con decisiones y caminos de error.", { after: 60 }),
      H2("3.1. Realizar y aprobar inventario físico"),
      imgFitH("actividad_inventario.png", ACT_H, 0.982),
      caption("Figura 3. Actividad — Realizar y aprobar inventario físico."),
      pageBreak(),
      H2("3.2. Generar informe de inventario"),
      imgFitH("actividad_generar_informe.png", ACT_H, 1.065),
      caption("Figura 4. Actividad — Generar informe de inventario."),
    ]),
    portraitSection([
      H1("4. Diagrama de Clases"),
      P("Entidades del módulo Inventario y sus relaciones (existencias, movimientos e inventario físico). Las clases en gris son clases frontera (dimensiones) de otros módulos.", { after: 60 }),
      imgFit("clases_inventario.png", PORT_PX, 0.833),
      caption("Figura 5. Diagrama de clases — Módulo Inventario."),
    ]),

    // ===== BLOQUE HORIZONTAL =====
    landscapeSection([
      H1("5. Diagramas de Secuencia"),
      P("Derivados de los casos de uso y del mecanismo de actualización de stock; muestran las llamadas reales entre módulos/páginas, paquetes, triggers, vistas y entidades.", { after: 60 }),
      H2("5.1. Actualización de stock por movimiento"),
      imgFitH("secuencia_actualizar_stock.png", LAND_H_SEQ, 1.853),
      caption("Figura 6. Secuencia — Actualización de stock por movimiento."),
      pageBreak(),
      H2("5.2. Realizar y aprobar inventario físico"),
      imgFitH("secuencia_inventario.png", LAND_H_SEQ, 2.216),
      caption("Figura 7. Secuencia — Realizar y aprobar inventario físico."),
      pageBreak(),
      H2("5.3. Generar informe de inventario"),
      imgFitH("secuencia_generar_informe.png", LAND_H_SEQ, 2.647),
      caption("Figura 8. Secuencia — Generar informe de inventario."),
    ]),
  ],
});

module.exports = { especificaciones: [...specExistencias, ...specHistorial, ...specRealizar, ...specAprobarInv, ...specDashboard, ...specInforme] };

// ============================================================================
// Módulo VENTAS (Presupuestos/Pedidos) — contenido del Word de diagramas UML.
// Usa ../_build/docxlib.js. Ejecutar: node doc/diagramas/ventas/build.js
// Nota: en este módulo el diagrama de CLASES es vertical (alto), así que va en
// el bloque vertical; solo las secuencias (anchas) van en el bloque horizontal.
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "..", "_build", "docxlib.js"));
const { P, Field, H1, H2, H3, SubBold, bullet, num, caption, pageBreak,
        makeImg, makeCaratula, portraitSection, landscapeSection, buildDoc } = lib;
const { PORT_PX, ACT_H, LAND_H_SEQ } = lib.SIZES;

const { imgFit, imgFitH } = makeImg(__dirname);
const OUT = path.join(__dirname, "..", "MUESTRA_Ventas.docx");

// --- especificaciones ------------------------------------------------------
const specCrear = [
  H2("Especificación de caso de uso: Crear presupuesto"),
  H3("Descripción"),
  P("Permite al Vendedor registrar un presupuesto/pedido para un cliente, eligiendo la oficina de entrega y agregando líneas de productos. El sistema valida la disponibilidad de stock por oficina (sin mostrar cantidades), calcula el precio de venta y, al guardar, genera las reservas de stock. El presupuesto nace en estado PENDIENTE. Se invoca desde la pantalla de Presupuesto (P54)."),
  Field("Actor principal: ", "Vendedor."),
  Field("Entorno de invocación: ", "pantalla P54 «Presupuesto»."),
  H3("Flujo de Eventos"),
  SubBold("Flujo Básico"),
  num("El Vendedor abre la pantalla de Presupuesto y elige el **cliente** y la **oficina de entrega**."),
  num("Por cada producto, al seleccionarlo el sistema verifica la **disponibilidad** en la oficina (FN_HAY_STOCK) y autocompleta el **precio** de venta (FN_PRECIO_VENTA)."),
  num("El Vendedor ingresa la **cantidad** de cada línea."),
  num("El Vendedor **guarda** el presupuesto."),
  num("El sistema valida, por cada línea, que haya **disponibilidad** en la oficina (bloqueante si falta)."),
  num("El sistema registra la **cabecera** (ORDENES_VENTA, estado PENDIENTE); triggers BEFORE INSERT setean la **fecha de vencimiento** (parámetro DIAS_VIGENCIA_PRESUPUESTO) y el **usuario de creación**."),
  num("El sistema registra las **líneas** (DETALLE_ORDEN); por cada una, si el presupuesto está PENDIENTE/APROBADO, genera una **reserva de stock VIGENTE** (TRG_GENERAR_RESERVA_ORDEN)."),
  num("El presupuesto queda creado en estado **PENDIENTE**."),
  SubBold("Flujos Alternativos"),
  H3("Sin disponibilidad en la oficina"),
  P("En el paso 2, si no hay stock disponible en la oficina de entrega, el sistema avisa en qué oficinas hay stock (FN_OFICINAS_CON_STOCK) y bloquea la línea; el vendedor debe corregir el producto/cantidad o la oficina. El vendedor nunca ve cantidades de stock."),
  H3("Alguna línea sin stock al guardar"),
  P("En el paso 5, si alguna línea quedó sin disponibilidad, el sistema muestra un error bloqueante y no guarda el presupuesto."),
  H3("Precondiciones"),
  bullet("El Vendedor está autenticado y con permiso de ventas."),
  bullet("Existen productos activos con precio/margen vigente y clientes registrados."),
  H3("Pos-condiciones"),
  bullet("Se registra un presupuesto (ORDENES_VENTA) en estado PENDIENTE con su detalle."),
  bullet("Se genera una reserva de stock VIGENTE por cada línea."),
  bullet("Quedan registradas la fecha de vencimiento y el usuario de creación."),
  H3("Puntos de Extensión"),
  bullet("Vencimiento automático: un job diario (JOB_VENCER_PRESUPUESTOS) pasa a VENCIDO los presupuestos PENDIENTE cuya fecha de vencimiento pasó, liberando sus reservas."),
  bullet("Aprobación: un presupuesto PENDIENTE puede procesarse mediante el caso de uso «Aprobar presupuesto»."),
];

const specAprobar = [
  pageBreak(),
  H2("Especificación de caso de uso: Aprobar presupuesto"),
  H3("Descripción"),
  P("Permite revisar un presupuesto en estado PENDIENTE o APROBADO y aprobarlo o anularlo (con motivo). El sistema valida que la transición de estado sea permitida (FN_PUEDE_TRANSICION_OV) y registra la auditoría; al anular, libera las reservas de stock. Se invoca desde la pantalla de Aprobación de Presupuestos (P117) y su detalle (P118)."),
  Field("Actores: ", "Supervisor; o el propio Vendedor previa confirmación del cliente."),
  Field("Entorno de invocación: ", "P117 (lista de aprobación) + P118 (modal de detalle)."),
  H3("Flujo de Eventos"),
  SubBold("Flujo Básico"),
  num("El Supervisor abre la **lista de aprobación** (P117), que muestra los presupuestos en estado PENDIENTE o APROBADO."),
  num("El Supervisor selecciona un presupuesto y abre su **detalle** (P118): cabecera, líneas y estado actual."),
  num("El Supervisor presiona **APROBAR**."),
  num("El sistema determina el estado destino (APROBADO) y **bloquea** el presupuesto (SELECT … FOR UPDATE)."),
  num("El sistema valida la **transición** con FN_PUEDE_TRANSICION_OV."),
  num("El sistema actualiza el estado a **APROBADO** y registra la fecha y el usuario de aprobación."),
  num("El sistema cierra el modal y **refresca** la lista."),
  SubBold("Flujos Alternativos"),
  H3("Anular presupuesto"),
  P("En el paso 3, el Supervisor ingresa un **motivo** (obligatorio) y presiona ANULAR; el destino es ANULADO. Al actualizar el estado, el trigger TRG_OV_LIBERA_RESERVA pone en ANULADA las reservas VIGENTE del presupuesto."),
  H3("Transición inválida"),
  P("En el paso 5, si la transición no está permitida (por ejemplo, un presupuesto ya FACTURADO), el sistema muestra «Transición inválida: actual → destino» y no cambia el estado."),
  H3("Precondiciones"),
  bullet("El Supervisor está autenticado y con permiso de aprobación."),
  bullet("Existe al menos un presupuesto en estado PENDIENTE o APROBADO."),
  H3("Pos-condiciones"),
  bullet("Al aprobar: el presupuesto queda APROBADO con fecha y usuario de aprobación; ya puede facturarse."),
  bullet("Al anular: el presupuesto queda ANULADO con fecha, usuario y motivo; sus reservas de stock quedan ANULADA."),
  H3("Puntos de Extensión"),
  bullet("Facturar: un presupuesto APROBADO puede facturarse (caso de uso «Facturar contado» / «Facturar a crédito»), lo que lo lleva a FACTURADO."),
];

// --- documento: VERTICAL (1-4) primero, HORIZONTAL (5) después -------------
if (require.main === module) buildDoc({
  outPath: OUT,
  sections: [
    portraitSection(makeCaratula({ subtitulo: "Módulo Ventas: Presupuestos" }), true),

    // ===== BLOQUE VERTICAL =====
    portraitSection([
      H1("1. Casos de Uso"),
      P("El diagrama de casos de uso presenta el mapa general del módulo: los actores y los casos de uso principales. A continuación se detallan las especificaciones de cada uno, en el formato de la plantilla de la cátedra, reflejando la lógica real del sistema.", { after: 60 }),
      imgFit("casos_uso_ventas.png", PORT_PX, 2.176),
      caption("Figura 1. Diagrama de casos de uso — Módulo Ventas."),
      pageBreak(),
      H2("1.1. Especificaciones de casos de uso"),
      ...specCrear,
      ...specAprobar,
    ]),
    portraitSection([
      H1("2. Diagramas de Estados"),
      P("Se incluyen los objetos del módulo con más de un estado, indicando el evento que dispara cada transición.", { after: 120 }),
      H2("2.1. Presupuesto"),
      imgFit("estados_presupuesto.png", PORT_PX, 1.267),
      caption("Figura 2. Estados del Presupuesto (ORDENES_VENTA.ESTADO)."),
      pageBreak(),
      H2("2.2. Reserva de Producto"),
      imgFit("estados_reserva.png", PORT_PX, 1.176),
      caption("Figura 3. Estados de la Reserva (RESERVAS_PRODUCTO.ESTADO)."),
    ]),
    portraitSection([
      H1("3. Diagramas de Actividades"),
      P("Muestran el flujo de control de los procesos, incluyendo las decisiones (rombos) y los caminos de error, repartidos entre el actor y el sistema.", { after: 60 }),
      H2("3.1. Crear presupuesto"),
      imgFitH("actividad_crear_presupuesto.png", ACT_H, 0.789),
      caption("Figura 4. Actividad — Crear presupuesto."),
      pageBreak(),
      H2("3.2. Aprobar presupuesto"),
      imgFitH("actividad_aprobar_presupuesto.png", ACT_H, 0.644),
      caption("Figura 5. Actividad — Aprobar presupuesto."),
    ]),
    portraitSection([
      H1("4. Diagrama de Clases"),
      P("El diagrama de clases del módulo Ventas representa las entidades del negocio y sus relaciones tipadas (composición, agregación, asociación y dependencia), obtenidas de las tablas reales de la base de datos. Las clases en gris son clases frontera de otros módulos.", { after: 60 }),
      imgFit("clases_ventas.png", 540, 0.763),
      caption("Figura 6. Diagrama de clases — Módulo Ventas."),
    ]),

    // ===== BLOQUE HORIZONTAL =====
    landscapeSection([
      H1("5. Diagramas de Secuencia"),
      P("Los diagramas de secuencia se derivan de la descripción de los casos de uso anteriores y muestran las llamadas reales entre la página (boundary), las funciones PL/SQL, los triggers y las entidades.", { after: 60 }),
      H2("5.1. Crear presupuesto"),
      imgFitH("secuencia_crear_presupuesto.png", LAND_H_SEQ, 2.245),
      caption("Figura 7. Secuencia — Crear presupuesto."),
      pageBreak(),
      H2("5.2. Aprobar presupuesto"),
      imgFitH("secuencia_aprobar_presupuesto.png", LAND_H_SEQ, 1.597),
      caption("Figura 8. Secuencia — Aprobar presupuesto."),
    ]),
  ],
});

module.exports = { especificaciones: [...specCrear, ...specAprobar] };

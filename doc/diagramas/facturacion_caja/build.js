// ============================================================================
// Módulo Facturación + Caja — contenido del Word de diagramas UML.
// Modelo "mapa general + casos principales" (aprobado por el PO 2026-07-07):
//   Sección 1 = diagrama de casos de uso (mapa) + specs de TODOS los principales.
//   Secuencia/Actividad solo para los transaccionales/complejos.
// Usa ../_build/docxlib.js. Ejecutar: node doc/diagramas/facturacion_caja/build.js
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "..", "_build", "docxlib.js"));
const { P, Field, H1, H2, H3, SubBold, bullet, num, caption, pageBreak,
        makeImg, makeCaratula, portraitSection, landscapeSection, buildDoc } = lib;
const { PORT_PX, ACT_H, LAND_H_CLASS, LAND_H_SEQ } = lib.SIZES;

const { imgFit, imgFitH } = makeImg(__dirname);
const OUT = path.join(__dirname, "..", "MUESTRA_Piloto_Facturacion_Caja.docx");

// ---------- especificaciones de casos de uso ----------
const specAbrir = [
  H2("Especificación de caso de uso: Abrir caja"),
  H3("Descripción"),
  P("Permite al Cajero abrir su caja para operar durante el día. El sistema garantiza que un empleado tenga a lo sumo una caja abierta y registra los montos de apertura por moneda."),
  Field("Actor principal: ", "Cajero."),
  Field("Entorno de invocación: ", "pantalla de apertura de caja."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Cajero solicita abrir una caja."),
  num("El sistema verifica que el empleado **no** tenga ya una caja abierta (TRG_CAJA_UNA_POR_DIA)."),
  num("El sistema registra la caja (CAJAS, ESTADO='A') con fecha y usuario de apertura y los montos de apertura por moneda (CAJA_MONEDAS)."),
  num("La caja queda **Abierta** y lista para facturar y cobrar."),
  SubBold("Flujos Alternativos"),
  H3("Ya tiene una caja abierta"),
  P("En el paso 2, si el empleado ya tiene una caja en estado 'A', el sistema aborta (−20020) y no abre otra."),
  H3("Precondiciones"),
  bullet("El Cajero está autenticado y con rol de caja."),
  bullet("Existe una caja configurada para su oficina."),
  H3("Pos-condiciones"),
  bullet("Existe una caja en estado 'A' para el cajero, con sus montos de apertura."),
  H3("Puntos de Extensión"),
  bullet("Cerrar y arquear caja: al final del día la caja se cierra con arqueo."),
];

const specContado = [
  pageBreak(),
  H2("Especificación de caso de uso: Facturar contado"),
  H3("Descripción"),
  P("Permite al Cajero emitir una factura de contado a partir de un presupuesto/pedido en estado APROBADO. El sistema reserva el número de comprobante del talonario vigente, registra la factura y su detalle, descuenta el stock de los productos vendidos y registra el ingreso en la caja abierta del cajero. Se invoca desde la pantalla de Facturación (P67)."),
  Field("Actor principal: ", "Cajero."),
  Field("Entorno de invocación: ", "pantalla P67 «Facturación», forma de pago Contado; requiere caja abierta."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Cajero abre la pantalla de Facturación. El sistema valida que exista una **caja abierta** (FN_CAJA_ABIERTA_USUARIO)."),
  num("El Cajero selecciona un presupuesto en estado **APROBADO**; el sistema carga cliente, detalle y totales."),
  num("El Cajero elige forma de pago **Contado**, ingresa el monto recibido y confirma."),
  num("El sistema valida la transición a **FACTURADO** (FN_PUEDE_TRANSICION_OV) y que el **monto** sea ≥ al total."),
  num("El sistema **reserva** el número de comprobante del talonario FA vigente (FN_OBTENER_COMPROBANTE)."),
  num("Registra la **factura** (COMPROBANTES, FA, 'A'); el presupuesto pasa a FACTURADO y se liberan sus reservas."),
  num("Por cada línea inserta el **detalle**, valida stock y genera la **salida de stock** (MOVIMIENTOS_STOCK 'SALIDA')."),
  num("Registra el **ingreso en caja** (MOVIMIENTOS_CAJA INGRESO_VENTA) y redirige al documento (KuDE, P96)."),
  SubBold("Flujos Alternativos"),
  H3("Sin caja abierta"),
  P("En el paso 1, sin caja abierta el sistema muestra un error y no permite facturar."),
  H3("Presupuesto no facturable / monto insuficiente"),
  P("En el paso 4, si el presupuesto no está APROBADO o el monto es menor al total, el sistema muestra error y cancela."),
  H3("Talonario no vigente / stock insuficiente"),
  P("En los pasos 5–7, si el talonario está fuera de vigencia (−20001/−20002) o falta stock (−20005), la transacción se aborta y no se emite la factura."),
  H3("Precondiciones"),
  bullet("Caja abierta en la oficina y talonario FA vigente."),
  bullet("Presupuesto APROBADO con stock disponible."),
  H3("Pos-condiciones"),
  bullet("Factura de contado en estado 'A' con su detalle; presupuesto FACTURADO."),
  bullet("Stock descontado y movimiento de ingreso registrado en la caja. No se genera cuenta por cobrar."),
  H3("Puntos de Extensión"),
  bullet("Impresión del documento (KuDE de la factura, P96)."),
  bullet("Anular factura: dentro de las 48 h la factura puede anularse."),
];

const specCredito = [
  pageBreak(),
  H2("Especificación de caso de uso: Facturar a crédito"),
  H3("Descripción"),
  P("Variante de la facturación en la que la venta se cobra en cuotas. Además de emitir la factura y descontar stock, el sistema financia el total con el interés del plan de cuotas (F16) y genera la cuenta por cobrar con sus cuotas."),
  Field("Actor principal: ", "Cajero."),
  Field("Entorno de invocación: ", "pantalla P67, forma de pago Crédito + plan de cuotas."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Cajero selecciona el presupuesto APROBADO, forma de pago **Crédito** y un **plan de cuotas**, y confirma (con caja abierta)."),
  num("El sistema valida la transición a FACTURADO y **reserva** el número de comprobante."),
  num("El sistema calcula el **interés de financiación** (ROUND(base×tasa/100)) y lo suma a la cabecera (F16)."),
  num("Registra la **factura** (COMPROBANTES, FA, 'A', crédito)."),
  num("El trigger **TRG_INS_CUENTAS_COBRAR** genera la **cuenta por cobrar** y las **cuotas** (la última absorbe el redondeo: factura = CxC = Σ cuotas)."),
  num("Registra el detalle y **descuenta stock** (igual que contado). **No** registra ingreso en caja (se cobrará por cuotas)."),
  SubBold("Flujos Alternativos"),
  H3("Mismas validaciones que contado"),
  P("Aplican los mismos flujos alternativos de «Facturar contado» (caja abierta, presupuesto facturable, talonario vigente, stock suficiente)."),
  H3("Precondiciones"),
  bullet("Como «Facturar contado» + un plan de cuotas seleccionado."),
  H3("Pos-condiciones"),
  bullet("Factura a crédito emitida; cuenta por cobrar con cuotas PENDIENTE; stock descontado; sin ingreso de caja."),
  H3("Puntos de Extensión"),
  bullet("Cobrar cuota: cada cuota se cobra por el caso de uso correspondiente."),
];

const specCobrar = [
  pageBreak(),
  H2("Especificación de caso de uso: Cobrar cuota"),
  H3("Descripción"),
  P("Permite al Cajero registrar el cobro de una cuota pendiente de una cuenta por cobrar (venta a crédito) y emitir el recibo correspondiente. El cobro se ejecuta atómicamente mediante FN_COBRAR_CUOTA. Requiere caja abierta y talonario de recibo (RC) vigente."),
  Field("Actor principal: ", "Cajero."),
  Field("Entorno de invocación: ", "pantalla de Cobro de Cuentas por Cobrar; emite el recibo (KuDE, P119)."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Cajero selecciona una cuota en estado **PENDIENTE** o **VENCIDA**, elige forma/método de pago, ingresa el monto y confirma."),
  num("El sistema invoca **FN_COBRAR_CUOTA**, que **bloquea** la cuota y la cabecera de la CxC (FOR UPDATE)."),
  num("Valida que la cuota sea cobrable, que el monto sea ≥ al de la cuota, que la **caja** esté abierta y que el **talonario** RC sea de la oficina de la caja."),
  num("**Reserva** el número de recibo (FN_OBTENER_COMPROBANTE) y registra el **movimiento de caja** (COBRO_CXC) con su detalle."),
  num("Marca la cuota **PAGADA** y descuenta el **saldo** de la CxC (si llega a cero, la CxC queda PAGADA)."),
  num("Devuelve el número de recibo y redirige al documento (KuDE Recibo, P119)."),
  SubBold("Flujos Alternativos"),
  H3("Cuota no cobrable / monto insuficiente"),
  P("Si la cuota ya está PAGADA (−20911) o el monto es menor al de la cuota (−20912), el sistema aborta."),
  H3("Caja cerrada / talonario inválido"),
  P("Si la caja no está abierta (−20913/−20914) o el talonario no es RC de la oficina (−20916/−20917), el sistema aborta."),
  H3("Precondiciones"),
  bullet("Caja abierta y talonario RC vigente en la oficina."),
  bullet("Existe una cuota PENDIENTE o VENCIDA."),
  H3("Pos-condiciones"),
  bullet("Cuota PAGADA; saldo de la CxC reducido; movimiento de cobro con recibo numerado."),
  H3("Puntos de Extensión"),
  bullet("Impresión del recibo (KuDE, P119)."),
  bullet("Vencimiento automático: un job diario marca VENCIDA las cuotas impagas; siguen siendo cobrables."),
];

const specAnular = [
  pageBreak(),
  H2("Especificación de caso de uso: Anular factura"),
  H3("Descripción"),
  P("Permite dejar sin efecto una factura dentro de la ventana de cancelación SIFEN (48 h). El Cajero solicita la anulación con motivo y el Supervisor la aprueba; al aprobarse se reversan stock, caja (si fue contado) y CxC (si fue crédito). Fuera de plazo corresponde emitir una Nota de Crédito."),
  Field("Actores: ", "Cajero (solicita), Supervisor (aprueba)."),
  Field("Entorno de invocación: ", "pantalla de anulación de facturas (workflow solicitud/aprobación)."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Cajero solicita anular una factura activa e ingresa el **motivo** (≥ 10 caracteres) — PRC_SOLICITAR_ANULACION."),
  num("El sistema valida ESTADO='A', la **ventana SIFEN** (48 h) y que **no** haya cuotas pagadas; marca la factura **PENDIENTE de anulación** (ESTADO='P')."),
  num("El **Supervisor** revisa y aprueba — PRC_APROBAR_ANULACION."),
  num("El sistema re-valida la ventana y las cuotas; **reversa stock** (ENTRADA por línea) y, si fue **contado**, la **caja** (EGRESO); si fue **crédito**, anula la **CxC** y sus cuotas."),
  num("Marca la factura **ANULADA** (ESTADO='N') con usuario y fecha de resolución."),
  SubBold("Flujos Alternativos"),
  H3("Fuera de plazo o con cuota pagada"),
  P("En los pasos 1–2, si pasaron las 48 h o hay cuotas cobradas, el sistema aborta (−20932/−20933/−20934): corresponde emitir una Nota de Crédito."),
  H3("Rechazo de la anulación"),
  P("El Supervisor puede rechazar la solicitud (PRC_RECHAZAR_ANULACION): la factura vuelve a 'A' con el motivo de rechazo."),
  H3("Precondiciones"),
  bullet("Factura activa emitida dentro de las últimas 48 h, sin cuotas cobradas."),
  H3("Pos-condiciones"),
  bullet("Factura ANULADA (ESTADO='N'); stock, caja y/o CxC reversados según la forma de pago."),
  H3("Puntos de Extensión"),
  bullet("Emitir Nota de Crédito: cuando la factura queda fuera del plazo de anulación."),
];

const specNC = [
  pageBreak(),
  H2("Especificación de caso de uso: Emitir Nota de Crédito"),
  H3("Descripción"),
  P("Documento fiscal que revierte total o parcialmente una factura fuera del plazo de anulación (F14). El Supervisor la solicita y la aprueba mediante un workflow; al aprobar, según el motivo, entra stock (devolución), egresa caja (si fue contado del día) o ajusta la CxC (si fue crédito). La factura original permanece activa."),
  Field("Actor principal: ", "Supervisor."),
  Field("Entorno de invocación: ", "pantallas de solicitud/aprobación/documento de NC (P124–P127)."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Supervisor solicita una NC sobre una factura, elige el **motivo** y las líneas/montos a acreditar (PRC_SOLICITAR_NOTA_CREDITO)."),
  num("El sistema valida la **elegibilidad** (FN_NC_ELEGIBLE) y la cantidad acreditable (FN_CANT_ACREDITABLE)."),
  num("El Supervisor **aprueba** la solicitud; el sistema **reserva** el número de NC (PRC_APROBAR_NOTA_CREDITO)."),
  num("Registra la **NC** (COMPROBANTES, TIPO='NC') vinculada a la factura origen (ID_COMPROBANTE_ORIGEN)."),
  num("Según el **motivo**: si es devolución, **entra stock**; efecto en **caja** (si fue contado del día) o en la **CxC** (si fue crédito)."),
  num("Emite el **documento** de la NC (KuDE, P127)."),
  SubBold("Flujos Alternativos"),
  H3("No elegible"),
  P("Si la factura no admite NC o la cantidad excede lo acreditable, el sistema muestra el motivo y no continúa."),
  H3("Rechazo"),
  P("El Supervisor puede rechazar la solicitud (PRC_RECHAZAR_NOTA_CREDITO)."),
  H3("Precondiciones"),
  bullet("Factura existente y motivo SIFEN válido."),
  H3("Pos-condiciones"),
  bullet("NC emitida (documento nuevo); efectos de stock/caja/CxC según el motivo; la factura original queda activa."),
];

const specCerrar = [
  pageBreak(),
  H2("Especificación de caso de uso: Cerrar y arquear caja"),
  H3("Descripción"),
  P("Permite al Cajero cerrar su caja al final del día comparando el saldo esperado (calculado desde los movimientos) con el efectivo contado (declarado) para obtener la diferencia (sobrante/faltante). Se invoca desde P62 (Estado de Caja) → P61 (arqueo)."),
  Field("Actor principal: ", "Cajero."),
  Field("Entorno de invocación: ", "P62 (Estado de Caja) + P61 (arqueo); documento de arqueo P132."),
  H3("Flujo de Eventos"), SubBold("Flujo Básico"),
  num("El Cajero abre el **Estado de Caja** (P62) y revisa el saldo esperado por moneda (V_CAJA_SALDO) y los movimientos."),
  num("Presiona **Cerrar**, cuenta el efectivo e ingresa el **monto declarado** (P61)."),
  num("El sistema ejecuta **CERRAR_CAJA**: marca la caja **CERRADA** (ESTADO='C') con fecha y usuario."),
  num("Por cada moneda calcula el **monto de cierre** (saldo esperado) y la **diferencia** (declarado − esperado)."),
  num("Marca los **movimientos** de la caja como cerrados y emite el **documento de arqueo** (P132)."),
  SubBold("Flujos Alternativos"),
  H3("Sin caja abierta"),
  P("En el paso 3, si no hay una caja en estado 'A', el sistema aborta (−20940)."),
  H3("Precondiciones"),
  bullet("El Cajero tiene una caja abierta."),
  H3("Pos-condiciones"),
  bullet("Caja CERRADA con monto de cierre y diferencia por moneda; documento de arqueo disponible."),
];

// ---------- documento ----------
if (require.main === module) buildDoc({
  outPath: OUT,
  sections: [
    portraitSection(makeCaratula({ subtitulo: "Módulo Facturación + Caja" }), true),

    // ===== BLOQUE VERTICAL =====
    // 1. Casos de Uso: diagrama (mapa) + especificaciones
    portraitSection([
      H1("1. Casos de Uso"),
      P("El diagrama de casos de uso presenta el mapa general del módulo: los actores y los casos de uso principales. A continuación se detallan las especificaciones de cada uno, en el formato de la plantilla de la cátedra, reflejando la lógica real del sistema.", { after: 60 }),
      imgFit("casos_uso_facturacion.png", PORT_PX, 1.145),
      caption("Figura 1. Diagrama de casos de uso — Módulo Facturación + Caja."),
      pageBreak(),
      H2("1.1. Especificaciones de casos de uso"),
      ...specAbrir, ...specContado, ...specCredito, ...specCobrar,
      ...specAnular, ...specNC, ...specCerrar,
    ]),

    // 2. Estados
    portraitSection([
      H1("2. Diagramas de Estados"),
      P("Objetos del módulo con más de un estado, indicando el evento que dispara cada transición.", { after: 120 }),
      H2("2.1. Factura"),
      imgFit("estados_factura.png", PORT_PX, 1.128),
      caption("Figura 2. Estados de la Factura (COMPROBANTES.ESTADO)."),
      pageBreak(),
      H2("2.2. Cuota de Cuenta por Cobrar"),
      imgFit("estados_cuota.png", PORT_PX, 1.101),
      caption("Figura 3. Estados de la Cuota (CUENTAS_COBRAR_DET.ESTADO)."),
      pageBreak(),
      H2("2.3. Caja"),
      imgFit("estados_caja.png", PORT_PX, 1.113),
      caption("Figura 4. Estados de la Caja (CAJAS.ESTADO)."),
    ]),

    // 3. Actividades (transaccionales)
    portraitSection([
      H1("3. Diagramas de Actividades"),
      P("Flujo de control de los procesos transaccionales, con decisiones (rombos) y caminos de error, repartidos entre el actor y el sistema.", { after: 60 }),
      H2("3.1. Facturar contado"),
      imgFitH("actividad_facturar_contado.png", ACT_H, 0.429),
      caption("Figura 5. Actividad — Facturar contado."),
      pageBreak(),
      H2("3.2. Cobrar cuota"),
      imgFitH("actividad_cobrar_cuota.png", ACT_H, 0.373),
      caption("Figura 6. Actividad — Cobrar cuota."),
      pageBreak(),
      H2("3.3. Anular factura"),
      imgFitH("actividad_anular_factura.png", ACT_H, 0.789),
      caption("Figura 7. Actividad — Anular factura."),
      pageBreak(),
      H2("3.4. Cerrar y arquear caja"),
      imgFitH("actividad_cerrar_caja.png", ACT_H, 0.559),
      caption("Figura 8. Actividad — Cerrar y arquear caja."),
    ]),

    // ===== BLOQUE HORIZONTAL =====
    // 4. Clases
    landscapeSection([
      H1("4. Diagrama de Clases"),
      P("Entidades del negocio del módulo y sus relaciones tipadas (composición, agregación, asociación y dependencia), obtenidas de las tablas reales. Las clases en gris son clases frontera de otros módulos.", { after: 60 }),
      imgFitH("clases_facturacion_caja.png", LAND_H_CLASS, 1.520),
      caption("Figura 9. Diagrama de clases — Módulo Facturación + Caja."),
    ]),

    // 5. Secuencia (transaccionales)
    landscapeSection([
      H1("5. Diagramas de Secuencia"),
      P("Derivados de los casos de uso; muestran las llamadas reales entre la página (boundary), las funciones/procedimientos PL/SQL, los triggers y las entidades.", { after: 60 }),
      H2("5.1. Facturar contado"),
      imgFitH("secuencia_facturar_contado.png", LAND_H_SEQ, 1.844),
      caption("Figura 10. Secuencia — Facturar contado."),
      pageBreak(),
      H2("5.2. Cobrar cuota"),
      imgFitH("secuencia_cobrar_cuota.png", LAND_H_SEQ, 1.873),
      caption("Figura 11. Secuencia — Cobrar cuota."),
      pageBreak(),
      H2("5.3. Anular factura"),
      imgFitH("secuencia_anular_factura.png", LAND_H_SEQ, 1.757),
      caption("Figura 12. Secuencia — Anular factura."),
      pageBreak(),
      H2("5.4. Cerrar y arquear caja"),
      imgFitH("secuencia_cerrar_caja.png", LAND_H_SEQ, 1.626),
      caption("Figura 13. Secuencia — Cerrar y arquear caja."),
    ]),
  ],
});

module.exports = { especificaciones: [...specAbrir, ...specContado, ...specCredito, ...specCobrar, ...specAnular, ...specNC, ...specCerrar] };

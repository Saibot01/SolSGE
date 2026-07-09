// ============================================================================
// Manual Técnico SolSGE — PILOTO (Módulo Facturación y Caja)
// Muestra de formato/nivel para aprobar con el alumno antes de escalar.
// Contenido: §3 Modelo de datos (ER + diccionario exhaustivo) y §4 Backend
//            del módulo, leídos de la BD real (WKSP_WORKPLACE).
// Reutiliza ../diagramas/_build/docxlib.js. Ejecutar: node doc/manual_tecnico/build.js
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "..", "diagramas", "_build", "docxlib.js"));
const { P, Field, H1, H2, H3, SubBold, bullet, num, caption, pageBreak,
        makeImg, makeCaratula, portraitSection, landscapeSection, buildDoc, dataTable } = lib;
const { PORT_PX } = lib.SIZES;

const { imgFit } = makeImg(path.join(__dirname, "er"));
const OUT = path.join(__dirname, "MUESTRA_Manual_Tecnico_Facturacion_Caja.docx");

// filas del diccionario: [columna, tipo, nulo(Sí/No), clave, descripción]
const DW = [21, 15, 7, 22, 35]; // anchos %
const dict = (headers, rows) => dataTable({ headers, rows, widths: DW, fontSize: 17 });
const HEAD = ["Columna", "Tipo", "Nulo", "Clave", "Descripción"];

// helper de sección de tabla del diccionario
const tablaDic = (nombre, proposito, rows) => [
  H3(nombre),
  P(proposito, { after: 100 }),
  dict(HEAD, rows),
  P("", { after: 120 }),
];

// ---------------------------------------------------------------------------
// DICCIONARIO — una entrada por tabla del módulo (13 tablas)
// ---------------------------------------------------------------------------
const dicComprobantes = tablaDic(
  "COMPROBANTES",
  "Cabecera de todo comprobante emitido por el sistema: factura (TIPO_COMPROBANTE='FA') y nota de crédito ('NC'). Concentra totales, IVA discriminado por tasa, condición de venta y la trazabilidad fiscal (talonario, número, motivo).",
  [
    ["ID_COMPROBANTE", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["ID_CLIENTE", "NUMBER", "No", "FK→CLIENTES", "Cliente al que se factura (CLIENTES.ID_PERSONA)."],
    ["ID_OFICINA", "NUMBER", "No", "FK→OFICINAS", "Sucursal emisora del comprobante."],
    ["ID_ORDEN_VENTA", "NUMBER", "Sí", "FK→ORDENES_VENTA", "Presupuesto/pedido de origen (NULL en NC)."],
    ["TIPO_COMPROBANTE", "CHAR(2)", "No", "—", "'FA' factura, 'NC' nota de crédito."],
    ["ID_FAC_ORIGEN", "VARCHAR2(100)", "Sí", "—", "Referencia textual a la factura de origen; el vínculo autoritativo de la NC es ID_COMPROBANTE_ORIGEN."],
    ["FECHA", "DATE", "Sí", "—", "Fecha del comprobante (default SYSDATE; ver regla de fecha en §4)."],
    ["TOTAL_MONEDA_LOCAL", "NUMBER(12,2)", "No", "—", "Total del comprobante en moneda local (PYG), IVA incluido."],
    ["MONEDA", "VARCHAR2(10)", "Sí", "—", "Código de moneda; default '1' (PYG)."],
    ["TIPO_CAMBIO", "NUMBER(12,6)", "Sí", "—", "Tipo de cambio aplicado (1 en operaciones locales)."],
    ["TOTAL_MONEDA_ORIGEN", "NUMBER(12,2)", "Sí", "—", "Total en la moneda de origen si difiere de la local."],
    ["FORMA_PAGO", "VARCHAR2(20)", "Sí", "—", "'21' contado / '1' crédito."],
    ["ESTADO", "CHAR(1)", "Sí", "—", "'A' activo, 'P' pendiente de anulación, 'N' anulado (CHECK)."],
    ["OBSERVACION", "VARCHAR2(255)", "Sí", "—", "Comentario libre."],
    ["ID_TALONARIO", "NUMBER", "Sí", "FK→TALONARIOS", "Talonario timbrado que numeró el comprobante."],
    ["NRO_COMPROBANTE", "VARCHAR2(20)", "Sí", "—", "Número fiscal formateado establecimiento-punto-número."],
    ["ID_PLAN_CUOTA", "NUMBER", "Sí", "FK→PLANES_CUOTA", "Plan de cuotas elegido (ventas a crédito)."],
    ["TOTAL_EXENTA", "NUMBER(12,2)", "Sí", "—", "Base exenta de IVA (0%)."],
    ["TOTAL_GRAVADA_5", "NUMBER(12,2)", "Sí", "—", "Base gravada al 5% (sin IVA)."],
    ["TOTAL_GRAVADA_10", "NUMBER(12,2)", "Sí", "—", "Base gravada al 10% (sin IVA)."],
    ["TOTAL_IVA_5", "NUMBER(12,2)", "Sí", "—", "IVA de las líneas al 5%."],
    ["TOTAL_IVA_10", "NUMBER(12,2)", "Sí", "—", "IVA de las líneas al 10%."],
    ["TOTAL_IVA", "NUMBER(12,2)", "Sí", "—", "IVA total (5% + 10%)."],
    ["ID_METODO_PAGO", "NUMBER", "Sí", "FK→METODOS_PAGO", "Método de pago utilizado."],
    ["MOTIVO_ANULACION", "VARCHAR2(500)", "Sí", "—", "Motivo cuando el comprobante se anula."],
    ["USUARIO_SOLICITA", "VARCHAR2(60)", "Sí", "—", "Usuario que solicita la anulación."],
    ["FECHA_SOLICITUD", "DATE", "Sí", "—", "Fecha de la solicitud de anulación."],
    ["USUARIO_APRUEBA", "VARCHAR2(60)", "Sí", "—", "Usuario que aprueba/rechaza la anulación."],
    ["FECHA_RESOLUCION", "DATE", "Sí", "—", "Fecha de resolución de la anulación."],
    ["MOTIVO_RECHAZO", "VARCHAR2(500)", "Sí", "—", "Motivo del rechazo de la solicitud."],
    ["FECHA_HORA_EMISION", "TIMESTAMP", "Sí", "—", "Sello de fecha-hora de emisión (TRG_COMPROBANTE_FECHA_HORA)."],
    ["COD_MOTIVO", "NUMBER(2)", "Sí", "FK→MOTIVOS_NOTA_CREDITO", "Motivo SIFEN de la nota de crédito."],
    ["ID_COMPROBANTE_ORIGEN", "NUMBER", "Sí", "FK→COMPROBANTES", "Factura de origen de la NC (autorreferencia)."],
    ["INTERES_FINANCIACION", "NUMBER", "Sí", "—", "Interés de financiación de la venta a crédito, IVA incluido."],
  ]);

const dicDetComprobante = tablaDic(
  "DETALLE_COMPROBANTE",
  "Líneas del comprobante (un renglón por producto vendido/acreditado). Composición de COMPROBANTES: no existe sin su cabecera.",
  [
    ["ID_DETALLE", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["ID_COMPROBANTE", "NUMBER", "No", "FK→COMPROBANTES", "Comprobante al que pertenece la línea."],
    ["ID_PRODUCTO", "NUMBER", "No", "FK→PRODUCTOS", "Producto vendido/acreditado."],
    ["CANTIDAD", "NUMBER", "No", "—", "Cantidad de unidades."],
    ["PRECIO_UNITARIO", "NUMBER(12,2)", "Sí", "—", "Precio unitario (IVA incluido)."],
    ["TOTAL_LINEA", "NUMBER(12,2)", "Sí", "—", "Importe de la línea (CANTIDAD × PRECIO_UNITARIO)."],
    ["ID_TIPO_IVA", "NUMBER", "Sí", "FK→TIPO_IVA", "Tipo de IVA de la línea (exento/5%/10%)."],
    ["MONTO_IVA", "NUMBER(12,2)", "Sí", "—", "IVA de la línea."],
    ["PORCENTAJE_IVA", "NUMBER(5,2)", "Sí", "—", "Porcentaje de IVA (referencia y cálculo rápido)."],
  ]);

const dicTalonarios = tablaDic(
  "TALONARIOS",
  "Talonarios timbrados por la SET, asignados a una caja configurada. Numeración establecimiento-punto-expedición y rango vigente. ID_OFICINA, ESTABLECIMIENTO y PUNTO_EXPEDICION son derivados por trigger desde CAJA_CONF/OFICINAS.",
  [
    ["ID_TALONARIO", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["ID_OFICINA", "NUMBER", "No", "FK→OFICINAS", "Sucursal (derivada de CAJA_CONF por trigger)."],
    ["TIPO_COMPROBANTE", "VARCHAR2(2)", "No", "—", "'FA' factura, 'NC' nota de crédito, 'RC' recibo."],
    ["ESTABLECIMIENTO", "VARCHAR2(3)", "No", "—", "Código de establecimiento SET (derivado)."],
    ["PUNTO_EXPEDICION", "VARCHAR2(3)", "No", "—", "Punto de expedición SET (derivado de CAJA_CONF)."],
    ["NRO_INICIAL", "NUMBER", "No", "—", "Primer número autorizado del rango."],
    ["NRO_FINAL", "NUMBER", "No", "—", "Último número autorizado del rango."],
    ["NRO_ACTUAL", "NUMBER", "No", "—", "Próximo número a emitir (avanza al facturar)."],
    ["TIMBRADO", "VARCHAR2(20)", "No", "—", "Número de timbrado otorgado por la SET."],
    ["FECHA_INICIO", "DATE", "No", "—", "Inicio de vigencia del timbrado."],
    ["FECHA_FIN", "DATE", "No", "—", "Fin de vigencia del timbrado."],
    ["ACTIVO", "CHAR(1)", "Sí", "—", "'S'/'N' (CHECK). Un solo talonario activo por (caja, tipo)."],
    ["ID_CAJA_CONF", "NUMBER", "No", "FK→CAJA_CONF", "Caja configurada dueña del talonario (FK regulatoria)."],
  ]);

const dicCuentasCobrar = tablaDic(
  "CUENTAS_COBRAR",
  "Cabecera de la cuenta por cobrar generada por una factura a crédito. Guarda el total financiado y el saldo pendiente. Se puebla con el trigger TRG_INS_CUENTAS_COBRAR.",
  [
    ["ID_CXC", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["ID_PERSONA", "NUMBER", "No", "FK→PERSONAS", "Deudor (cliente)."],
    ["ID_COMPROBANTE", "NUMBER", "No", "— (lógico)", "Factura que originó la deuda (vínculo lógico, sin FK física)."],
    ["TOTAL_A_PAGAR", "NUMBER(12,2)", "Sí", "—", "Monto total financiado (bienes + interés)."],
    ["SALDO", "NUMBER(12,2)", "Sí", "—", "Saldo pendiente (= Σ cuotas vigentes)."],
    ["FECHA_REGISTRO", "DATE", "Sí", "—", "Fecha de alta de la CxC (default SYSDATE)."],
    ["ESTADO", "VARCHAR2(20)", "Sí", "—", "'PENDIENTE' / 'PAGADA' / 'ANULADA' (CHECK)."],
  ]);

const dicCuentasCobrarDet = tablaDic(
  "CUENTAS_COBRAR_DET",
  "Cuotas de la cuenta por cobrar. Composición de CUENTAS_COBRAR. Cada cobro liquida una o más cuotas.",
  [
    ["ID_DETALLE", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["ID_CXC", "NUMBER", "No", "FK→CUENTAS_COBRAR", "Cuenta por cobrar a la que pertenece."],
    ["NRO_CUOTA", "NUMBER", "No", "—", "Número de cuota (1..n)."],
    ["FECHA_VENCIMIENTO", "DATE", "No", "—", "Vencimiento de la cuota."],
    ["MONTO_CUOTA", "NUMBER(12,2)", "No", "—", "Importe de la cuota (última absorbe el remanente, PYG entero)."],
    ["ESTADO", "VARCHAR2(20)", "Sí", "—", "'PENDIENTE' / 'PAGADA' / 'VENCIDA' / 'ANULADA' (CHECK)."],
  ]);

const dicCajaConf = tablaDic(
  "CAJA_CONF",
  "Configuración lógica de una caja (punto de venta). Vincula la caja física operada al día con su oficina y su punto de expedición SET.",
  [
    ["ID_CAJA_CONF", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["DESCRIPCION", "VARCHAR2(50)", "No", "—", "Nombre de la caja configurada."],
    ["ESTADO", "CHAR(1)", "Sí", "—", "'A' activa (default)."],
    ["ID_OFICINA", "NUMBER", "Sí", "FK→OFICINAS", "Sucursal a la que pertenece."],
    ["PUNTO_EXPEDICION", "VARCHAR2(3)", "Sí", "—", "Punto de expedición SET; único por oficina."],
  ]);

const dicCajas = tablaDic(
  "CAJAS",
  "Instancia de caja abierta por un empleado (sesión de caja del día). Regla: un empleado tiene a lo sumo una caja abierta (índice funcional UQ_CAJA_ABIERTA_EMP).",
  [
    ["ID_CAJA", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["ID_EMPLEADO", "NUMBER", "No", "FK→EMPLEADOS", "Empleado que opera la caja."],
    ["ESTADO", "CHAR(1)", "Sí", "—", "'A' abierta / 'C' cerrada (CHECK)."],
    ["FEC_APERTURA", "TIMESTAMP", "Sí", "—", "Momento de apertura (default SYSTIMESTAMP)."],
    ["FEC_CIERRE", "TIMESTAMP", "Sí", "—", "Momento de cierre/arqueo."],
    ["USU_APERTURA", "VARCHAR2(35)", "Sí", "—", "Usuario que abrió la caja."],
    ["USU_CIERRE", "VARCHAR2(35)", "Sí", "—", "Usuario que cerró la caja."],
    ["ID_CAJA_CONF", "NUMBER", "Sí", "FK→CAJA_CONF", "Caja configurada asociada."],
    ["ID_OFICINA", "NUMBER", "Sí", "FK→OFICINAS", "Sucursal de la caja."],
    ["OBSERVACION", "VARCHAR2(255)", "Sí", "—", "Comentario del cierre/arqueo."],
  ]);

const dicCajaMonedas = tablaDic(
  "CAJA_MONEDAS",
  "Saldos por moneda de cada caja (apertura, cierre y arqueo). PK compuesta (ID_CAJA, MONEDA). Composición de CAJAS.",
  [
    ["ID_CAJA", "NUMBER", "No", "PK, FK→CAJAS", "Caja (parte de la PK)."],
    ["MONEDA", "VARCHAR2(10)", "No", "PK, FK→MONEDAS", "Moneda (parte de la PK)."],
    ["MONTO_APERTURA", "NUMBER(12,2)", "Sí", "—", "Saldo declarado al abrir."],
    ["MONTO_CIERRE", "NUMBER(12,2)", "Sí", "—", "Saldo esperado al cerrar (calculado por CERRAR_CAJA v3)."],
    ["MONTO_DECLARADO", "NUMBER", "Sí", "—", "Efectivo contado en el arqueo."],
    ["MONTO_DIFERENCIA", "NUMBER", "Sí", "—", "Diferencia = declarado − esperado."],
    ["MONTO_CIERRE_PREV", "NUMBER", "Sí", "—", "Saldo de cierre previo conservado como respaldo."],
  ]);

const dicMovCaja = tablaDic(
  "MOVIMIENTOS_CAJA",
  "Movimientos de dinero de una caja: ingreso por venta, cobro de CxC, egreso y ajuste. También modela el recibo de dinero (numeración RC).",
  [
    ["ID_MOVIMIENTO", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["ID_CLIENTE", "NUMBER", "No", "FK→CLIENTES", "Cliente asociado al movimiento."],
    ["ID_CAJA", "NUMBER", "No", "FK→CAJAS", "Caja donde se registra."],
    ["FECHA", "TIMESTAMP", "Sí", "—", "Momento del movimiento (default SYSTIMESTAMP)."],
    ["TOTAL_MONEDA_LOCAL", "NUMBER(12,2)", "No", "—", "Importe en moneda local (PYG)."],
    ["MONEDA", "VARCHAR2(10)", "Sí", "—", "Guarda el texto 'PYG' (ver §4, inconsistencia con COMPROBANTES)."],
    ["TIPO_CAMBIO", "NUMBER(12,6)", "Sí", "—", "Tipo de cambio aplicado."],
    ["TOTAL_MONEDA_ORIGEN", "NUMBER(12,2)", "Sí", "—", "Importe en moneda de origen."],
    ["ESTADO", "CHAR(1)", "Sí", "—", "'A' caja abierta / 'C' caja cerrada — NO es activo/anulado (CHECK)."],
    ["OBSERVACION", "VARCHAR2(255)", "Sí", "—", "Comentario del movimiento."],
    ["TIPO", "VARCHAR2(20)", "No", "—", "'INGRESO_VENTA' / 'COBRO_CXC' / 'EGRESO' / 'AJUSTE' (CHECK)."],
    ["ID_COMPROBANTE", "NUMBER", "Sí", "FK→COMPROBANTES", "Factura de contado que originó el ingreso."],
    ["USUARIO", "VARCHAR2(60)", "Sí", "—", "Cobrador que registró el movimiento."],
    ["NRO_RECIBO", "VARCHAR2(20)", "Sí", "—", "Número del recibo de dinero (RC)."],
    ["ID_TALONARIO_RECIBO", "NUMBER", "Sí", "FK→TALONARIOS", "Talonario RC que numeró el recibo."],
    ["FECHA_EMISION_RECIBO", "DATE", "Sí", "—", "Fecha de emisión del recibo."],
    ["ID_CUENTA_COBRAR_DET", "NUMBER", "Sí", "FK→CUENTAS_COBRAR_DET", "Cuota cobrada (COBRO_CXC)."],
    ["ID_MOVIMIENTO_REVERSADO", "NUMBER", "Sí", "FK→MOVIMIENTOS_CAJA", "Movimiento compensado por un EGRESO de reverso."],
  ]);

const dicDetMovCaja = tablaDic(
  "DETALLE_MOVIMIENTO_CAJA",
  "Desglose del movimiento por forma/método de pago (efectivo, tarjeta, transferencia…). Composición de MOVIMIENTOS_CAJA.",
  [
    ["ID_DETALLE", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["ID_MOVIMIENTO", "NUMBER", "No", "FK→MOVIMIENTOS_CAJA", "Movimiento al que pertenece."],
    ["ID_FORMA_PAGO", "NUMBER", "No", "FK→FORMAS_PAGO", "Forma de pago (efectivo/no efectivo)."],
    ["MONTO_LOCAL", "NUMBER(12,2)", "No", "—", "Importe en moneda local."],
    ["MONTO_ORIGEN", "NUMBER(12,2)", "Sí", "—", "Importe en moneda de origen."],
    ["MONEDA", "VARCHAR2(10)", "Sí", "—", "Moneda del renglón."],
    ["TIPO_CAMBIO", "NUMBER(12,6)", "Sí", "—", "Tipo de cambio aplicado."],
    ["NRO_REFERENCIA", "VARCHAR2(50)", "Sí", "—", "Referencia de la transacción (transferencia/cheque)."],
    ["NRO_TARJETA", "VARCHAR2(50)", "Sí", "—", "Últimos dígitos/enmascarado de la tarjeta."],
    ["ID_METODO_PAGO", "NUMBER", "Sí", "FK→METODOS_PAGO", "Método de pago concreto."],
  ]);

const dicFormasPago = tablaDic(
  "FORMAS_PAGO",
  "Catálogo de formas de pago (efectivo / no efectivo). Determina si el renglón exige número de referencia.",
  [
    ["ID_FORMA_PAGO", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["DESCRIPCION", "VARCHAR2(50)", "No", "—", "Nombre de la forma de pago."],
    ["REQUIERE_REFERENCIA", "CHAR(1)", "Sí", "—", "'S' exige NRO_REFERENCIA (default 'N')."],
    ["ACTIVO", "CHAR(1)", "Sí", "—", "'S'/'N' (default 'S')."],
  ]);

const dicMetodosPago = tablaDic(
  "METODOS_PAGO",
  "Catálogo de métodos de pago concretos (Efectivo, Tarjeta, Transferencia…).",
  [
    ["ID_METODO_PAGO", "NUMBER", "No", "PK", "Identificador único (secuencia)."],
    ["NOMBRE", "VARCHAR2(50)", "No", "—", "Nombre del método de pago."],
    ["DESCRIPCION", "VARCHAR2(100)", "Sí", "—", "Detalle adicional."],
  ]);

const dicMonedas = tablaDic(
  "MONEDAS",
  "Catálogo de monedas. PYG es la moneda base (ES_LOCAL='S'). El sistema opera todo en PYG.",
  [
    ["CODIGO_MONEDA", "VARCHAR2(10)", "No", "PK", "Código de la moneda (p. ej. '1' = PYG)."],
    ["DESCRIPCION", "VARCHAR2(50)", "Sí", "—", "Nombre de la moneda."],
    ["ES_LOCAL", "CHAR(1)", "Sí", "—", "'S' para la moneda base del sistema (PYG); default 'N'."],
  ]);

// ---------------------------------------------------------------------------
buildDoc({
  outPath: OUT,
  sections: [
    // ===== PORTADA =====
    portraitSection(
      makeCaratula({
        titulo: "MANUAL TÉCNICO",
        subtitulo: "Muestra — Módulo Facturación y Caja",
        sistema: "Sole – Sistema de Gestión Empresarial",
        sigla: "SOLSGE",
        organo: "Facultad Politécnica – UNA",
        ciudad: "Asunción",
        fecha: "Julio 2026",
      }), true),

    // ===== CUERPO (vertical) =====
    portraitSection([
      P("Nota: este documento es una muestra del Manual Técnico acotada al módulo Facturación y Caja, para validar formato y nivel de detalle. El manual final incluirá los mismos capítulos para todos los módulos, más los capítulos de arquitectura, seguridad, integración fiscal, despliegue y mantenimiento.",
        { italics: true, after: 200 }),

      // ---- §3 MODELO DE DATOS ----
      H1("3. Modelo de datos"),
      P("Esta sección documenta el esquema físico del sistema: las tablas reales, sus columnas, tipos, nulabilidad y las relaciones de clave foránea, leídas directamente de la base de datos (esquema WKSP_WORKPLACE). Se presenta por módulo. El presente ejemplar corresponde al módulo Facturación y Caja."),
      P("El modelo entidad-relación de la Figura 1 es el esquema físico (tablas y FK reales); complementa la vista lógica (diagrama de clases) del libro de Diagramas UML. Las entidades en gris son entidades frontera de otros módulos, incluidas solo para mostrar las claves foráneas que cruzan el límite del módulo.", { after: 120 }),

      H2("3.1. Módulo Facturación y Caja"),
      H3("Diagrama entidad-relación"),
      imgFit("er_facturacion_caja.png", PORT_PX, 1.019),
      caption("Figura 1. Modelo entidad-relación (físico) — Módulo Facturación y Caja."),
      pageBreak(),

      H3("Diccionario de datos"),
      P("Detalle exhaustivo de cada tabla del módulo: todas sus columnas con tipo, nulabilidad, clave (PK/FK y tabla referida) y descripción. Fuente: diccionario de datos de la base (ALL_TAB_COLUMNS, ALL_CONSTRAINTS).", { after: 120 }),
      ...dicComprobantes,
      ...dicDetComprobante,
      ...dicTalonarios,
      ...dicCuentasCobrar,
      ...dicCuentasCobrarDet,
      ...dicCajaConf,
      ...dicCajas,
      ...dicCajaMonedas,
      ...dicMovCaja,
      ...dicDetMovCaja,
      ...dicFormasPago,
      ...dicMetodosPago,
      ...dicMonedas,

      H3("Restricciones e índices relevantes"),
      bullet("**UQ_CAJA_ABIERTA_EMP** (CAJAS): índice único funcional que materializa la regla «un empleado, a lo sumo una caja abierta»."),
      bullet("**UQ_TALONARIO_CAJA_TIPO_ACT** (TALONARIOS): un único talonario activo por (caja configurada, tipo de comprobante)."),
      bullet("**UQ_CAJA_CONF_OFI_PUNTO** (CAJA_CONF): dos cajas de la misma oficina no pueden compartir punto de expedición."),
      bullet("**PK_CAJA_MONEDAS** (CAJA_MONEDAS): clave primaria compuesta (ID_CAJA, MONEDA)."),
      bullet("**Restricciones CHECK de dominio**: COMPROBANTES.ESTADO ∈ {A,P,N}; MOVIMIENTOS_CAJA.TIPO ∈ {INGRESO_VENTA, COBRO_CXC, EGRESO, AJUSTE} y ESTADO ∈ {A,C}; CUENTAS_COBRAR(_DET).ESTADO; TALONARIOS.ACTIVO ∈ {S,N}."),
      bullet("**Secuencias**: cada tabla con PK numérica usa una secuencia de identidad (columna GENERATED … nextval)."),

      // ---- §4 BACKEND ----
      pageBreak(),
      H1("4. Componentes del backend (PL/SQL)"),
      P("La lógica de negocio del módulo vive en la base de datos como funciones, procedimientos, triggers y vistas. Esta sección describe cada componente y sus efectos. No se transcribe el código fuente: la definición autoritativa reside en el propio esquema de la base de datos."),

      H2("4.1. Convenciones"),
      bullet("**Catálogo de errores −20xxx por rango**: cada componente reserva un rango de RAISE_APPLICATION_ERROR. Facturación/Caja usa, entre otros: −20001/−20002 (talonario fuera de vigencia), −20005 (stock insuficiente), −20020 (caja ya abierta), −20940..−20941 (cierre de caja), −20953..−20969 (interés de financiación), −20970..−20990 (nota de crédito)."),
      bullet("**Regla de fecha/hora**: la base corre en UTC. Para toda fecha/hora de negocio o auditoría se usan **FN_HOY** (fecha) y **FN_AHORA** (fecha+hora), en zona America/Argentina/Buenos_Aires (UTC−3). Nunca SYSDATE/SYSTIMESTAMP salvo excepciones documentadas."),
      bullet("**Idempotencia de las migraciones**: los scripts de instalación del esquema son re-ejecutables y cierran con un bloque de verificación."),

      H2("4.2. Funciones"),
      Field("FN_OBTENER_COMPROBANTE — ", "reserva y devuelve el próximo número del talonario vigente del tipo pedido, avanzando NRO_ACTUAL de forma atómica. Valida vigencia (fechas) y rango."),
      Field("FN_CAJA_ABIERTA_USUARIO — ", "devuelve la caja abierta del usuario actual (o NULL); usada para validar que exista caja antes de facturar/cobrar."),
      Field("FN_PUEDE_TRANSICION_OV — ", "valida la transición de estado del presupuesto/pedido (APROBADO → FACTURADO)."),
      Field("FN_COBRAR_CUOTA — ", "registra el cobro de una o más cuotas de una CxC: crea el MOVIMIENTOS_CAJA (COBRO_CXC), marca las cuotas PAGADA, recalcula el saldo y numera el recibo."),
      Field("FN_MOTIVO_BLOQUEO_ANULACION — ", "determina si una factura puede anularse dentro de la ventana (48 h) y devuelve el motivo de bloqueo si no."),
      Field("FN_HOY / FN_AHORA — ", "fecha y fecha-hora de negocio en zona local (UTC−3)."),
      Field("Funciones de documentos (KuDE HTML) — ", "FN_KUDE_FACTURA_HTML (factura), FN_KUDE_RECIBO_HTML (recibo), FN_KUDE_NOTA_CREDITO_HTML (nota de crédito) y FN_CIERRE_CAJA_HTML (arqueo). Generan la representación gráfica; sin CDC/QR, con leyenda «sin validez fiscal» (no integradas a SIFEN). Auxiliar: FN_NUMERO_A_LETRAS."),

      H2("4.3. Procedimientos"),
      Field("CERRAR_CAJA — ", "cierra y arquea la caja: calcula el saldo esperado por moneda desde la vista V_CAJA_SALDO (join normalizado por MONEDAS), compara contra el efectivo declarado y guarda la diferencia."),
      Field("PRC_SOLICITAR/APROBAR/RECHAZAR_ANULACION — ", "flujo de anulación de factura con aprobación (dentro de las 48 h)."),
      Field("PRC_SOLICITAR/APROBAR/RECHAZAR_NOTA_CREDITO — ", "flujo de nota de crédito (camino fiscal fuera de la ventana de anulación): staging con aprobación, reserva del número de NC al aprobar, efectos en stock/caja/CxC."),

      H2("4.4. Triggers"),
      Field("TRG_INS_CUENTAS_COBRAR — ", "al insertar una factura a crédito arma la CxC y sus cuotas en enteros PYG (la última absorbe el remanente), de modo que factura = CxC.SALDO = Σ cuotas."),
      Field("TRG_CAJA_UNA_POR_DIA — ", "bloquea la apertura si el empleado ya tiene una caja con ESTADO='A' (regla «una caja abierta por empleado»)."),
      Field("TRG_TALONARIO_DERIVA_OFICINA — ", "deriva ID_OFICINA, ESTABLECIMIENTO y PUNTO_EXPEDICION del talonario desde CAJA_CONF/OFICINAS."),
      Field("TRG_COMPROBANTE_FECHA_HORA — ", "sella FECHA_HORA_EMISION con la fecha-hora local al emitir."),
      Field("TRG_FACTURA_ORDEN — ", "sincroniza el estado del presupuesto/pedido al facturar."),

      H2("4.5. Vistas"),
      Field("V_CAJA_SALDO — ", "saldo por caja y moneda (source of truth del estado de caja y del cierre); normaliza la moneda vía MONEDAS."),
      Field("V_TALONARIOS_DISPONIBLES — ", "talonarios activos y vigentes disponibles para emitir."),
      Field("V_RECIBOS_COBRO / V_RECIBOS_LISTA — ", "recibos de dinero para consulta y reimpresión."),
      Field("V_ANULACIONES_FACTURAS — ", "solicitudes de anulación y su estado."),
    ]),
  ],
});

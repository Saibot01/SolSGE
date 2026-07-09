// ============================================================================
// Manual de Usuario SolSGE — build del .docx (documento 3 de 4 del libro de tesis).
// PILOTO: portada + Introducción + Acceso al sistema + Roles + módulo Facturación y Caja.
// Reutiliza la infra aprobada del libro: ../diagramas/_build/docxlib.js
//   (portada réplica cátedra, banner UNA-FP, A4, TNR12/1.5, imgFit).
// Las capturas las provee el alumno en ./capturas/ (convención NN_modulo_tarea_SS.png).
//   Mientras un PNG no exista, el documento muestra un recuadro [FIGURA] (placeholder);
//   apenas aparece el archivo, al re-generar queda embebido. Ver ./capturas/README.md.
// Ejecutar: node doc/manual_usuario/build.js
//
// OJO (aprendido en el piloto): docx debe requerirse EXACTAMENTE como lo hace docxlib
//   (require.resolve con paths=_build → dist/index.cjs). Si se requiere el paquete por
//   otra ruta, Node carga index.umd.cjs = OTRA instancia del módulo y el Packer descarta
//   silenciosamente los Table/Paragraph "foráneos" (no renderizan). Ver la línea de `docx`.
// ============================================================================
const path = require("path");
const fs = require("fs");
const DBUILD = path.join(__dirname, "..", "diagramas", "_build");
const lib = require(path.join(DBUILD, "docxlib.js"));
const {
  P, Field, H1, H2, H3, bullet, caption, pageBreak,
  makeImg, makeCaratula, portraitSection, buildDoc, dataTable, parseRuns,
} = lib;
const { PORT_PX } = lib.SIZES;

// misma instancia de docx que docxlib (ver nota de cabecera)
const docx = require(require.resolve("docx", { paths: [DBUILD] }));
const {
  Table, TableRow, TableCell, WidthType, BorderStyle, ShadingType,
  Paragraph, TextRun, AlignmentType,
} = docx;

const CAP_DIR = path.join(__dirname, "capturas");
const { imgFit } = makeImg(CAP_DIR);
// MU_OUT permite generar a otra ruta para previsualizar sin pisar el .docx abierto en Word (EBUSY)
const OUT = process.env.MU_OUT || path.join(__dirname, "MUESTRA_Manual_Usuario.docx");

// ---------- pasos numerados que REINICIAN por procedimiento ----------
// docx continúa la numeración si todos los ítems comparten instancia. stepList() reserva
// una instancia nueva por procedimiento → cada lista arranca en 1 aunque se intercalen figuras.
let STEP_INST = 100;
function stepList() {
  STEP_INST += 1;
  const inst = STEP_INST;
  return (text) => new Paragraph({
    numbering: { reference: "pasos", level: 0, instance: inst },
    spacing: { after: 60, line: 360, lineRule: "auto" },
    children: parseRuns(text),
  });
}

// ---------- recuadro Nota / Importante ----------
function callout(kind, text) {
  const imp = kind === "Importante";
  const fill = imp ? "FDECEA" : "E8F1FB";       // salmón claro / azul claro
  const accent = imp ? "C0392B" : "2E6DA4";
  const label = imp ? "Importante: " : "Nota: ";
  const cell = new TableCell({
    shading: { type: ShadingType.CLEAR, fill },
    borders: {
      top: { style: BorderStyle.SINGLE, size: 2, color: accent },
      bottom: { style: BorderStyle.SINGLE, size: 2, color: accent },
      right: { style: BorderStyle.SINGLE, size: 2, color: accent },
      left: { style: BorderStyle.SINGLE, size: 24, color: accent },
    },
    margins: { top: 80, bottom: 80, left: 160, right: 160 },
    children: [new Paragraph({
      alignment: AlignmentType.JUSTIFIED, spacing: { after: 0, line: 300 },
      children: [new TextRun({ text: label, bold: true, color: accent }), ...parseRuns(text)],
    })],
  });
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [new TableRow({ children: [cell] })],
  });
}
const nota = (t) => callout("Nota", t);
const importante = (t) => callout("Importante", t);

// párrafo de cuerpo con **negrita** inline (P() de docxlib no parsea markdown)
const Pb = (text, opts = {}) => new Paragraph({
  spacing: { after: opts.after ?? 160, before: opts.before ?? 0, line: 360, lineRule: "auto" },
  alignment: AlignmentType.JUSTIFIED,
  children: parseRuns(text),
});

// ---------- slot de figura (imagen si existe; si no, recuadro placeholder) ----------
let FIG = 0;
function figura(file, ratio, desc) {
  FIG += 1;
  const cap = caption("Figura " + FIG + ". " + desc);
  if (fs.existsSync(path.join(CAP_DIR, file))) return [imgFit(file, PORT_PX, ratio), cap];
  const dash = (extra = {}) => ({ style: BorderStyle.DASHED, size: 6, color: "9AA5B1", ...extra });
  const box = new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [new TableRow({ children: [new TableCell({
      borders: { top: dash(), bottom: dash(), left: dash(), right: dash() },
      shading: { type: ShadingType.CLEAR, fill: "F5F7FA" },
      margins: { top: 300, bottom: 300, left: 160, right: 160 },
      children: [
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 40 },
          children: [new TextRun({ text: "[ FIGURA PENDIENTE DE CAPTURA ]", bold: true, color: "6B7683", size: 22 })] }),
        new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 0 },
          children: [new TextRun({ text: file, italics: true, color: "9AA5B1", size: 20 })] }),
      ],
    })] })],
  });
  return [box, cap];
}

// ---------- leyendas de tabla autonumeradas (evita renumerar a mano al insertar módulos) ----------
let TBL = 0;
const tablaCap = (desc) => { TBL += 1; return caption("Tabla " + TBL + ". " + desc); };

// ==========================================================================
//  1. INTRODUCCIÓN
// ==========================================================================
const intro = (() => {
  return [
    H1("1. Introducción"),
    P("Este Manual de Usuario explica cómo operar SolSGE — Sol, Sistema de Gestión Empresarial, la aplicación web de gestión de la empresa Sole Informática. Presenta las tareas del sistema paso a paso y con capturas de pantalla, de modo que cualquier usuario pueda realizarlas siguiendo la secuencia indicada."),
    H2("1.1. A quién está dirigido"),
    P("Está dirigido al usuario final que opera el sistema en su trabajo diario: vendedores, cajeros, supervisores, compradores, encargados de depósito, gerentes y administradores. No se requieren conocimientos técnicos: alcanza con saber usar un navegador de internet."),
    H2("1.2. Cómo está organizado"),
    P("El manual se organiza por módulo (Ventas, Facturación y Caja, Cobranzas, Compras, Inventario, etc.). Dentro de cada módulo, cada tarea se documenta con la misma estructura: el rol que la ejecuta, el objetivo de la tarea y los pasos numerados a seguir. Al comienzo de cada módulo, una tabla resume qué tareas puede realizar cada rol."),
    H2("1.3. Convenciones"),
    P("A lo largo del manual se usan dos tipos de recuadros para resaltar información:"),
    nota("aporta una aclaración o un dato útil para realizar mejor la tarea."),
    importante("señala una condición obligatoria o una advertencia que, de no respetarse, impide completar la tarea o produce un error."),
    P("Las opciones del menú se indican con el símbolo «→». Por ejemplo, Ventas → Caja → Apertura de Caja significa: abrir el menú Ventas, luego el submenú Caja y finalmente la opción Apertura de Caja.", { before: 80 }),
  ];
})();

// ==========================================================================
//  2. ACCESO AL SISTEMA
// ==========================================================================
const acceso = (() => {
  const s = stepList();
  const r = stepList();
  return [
    H1("2. Acceso al sistema"),
    P("SolSGE es una aplicación web: se usa desde el navegador de internet, sin instalar nada en la computadora."),
    H2("2.1. Ingresar al sistema"),
    s("Abra el navegador de internet (Google Chrome, Microsoft Edge o Firefox)."),
    s("Ingrese la dirección (URL) del sistema provista por la empresa. Se abre la pantalla de inicio de sesión."),
    s("Escriba su **usuario** y su **contraseña**."),
    s("Presione **Ingresar**. Si los datos son correctos, ingresa a la pantalla principal."),
    ...figura("02_acceso_login_01.png", 1.940, "Pantalla de inicio de sesión."),
    importante("Tras varios intentos fallidos de inicio de sesión, el sistema **bloquea** el usuario por seguridad. Para volver a ingresar, restablezca su contraseña (ver 2.2): al definir la nueva clave la cuenta se desbloquea."),
    H2("2.2. Recuperar el acceso (contraseña olvidada)"),
    P("Si olvidó su contraseña o su cuenta quedó bloqueada, puede restablecerla usted mismo desde la pantalla de inicio de sesión."),
    r("En la pantalla de inicio de sesión, escriba su **usuario**."),
    r("Haga clic en el enlace **¿Olvidaste tu contraseña?**."),
    r("El sistema envía un enlace de restablecimiento al **correo registrado** de su cuenta y muestra un mensaje de confirmación."),
    r("Abra ese correo y haga clic en el **enlace**: se abre la pantalla para definir una nueva contraseña."),
    r("Escriba y confirme su **nueva contraseña** y guárdela. Con esto la cuenta queda **desbloqueada** y ya puede iniciar sesión con la nueva clave."),
    ...figura("02_acceso_reset_01.png", 1.654, "Pantalla de restablecimiento de contraseña."),
    nota("Si no recibe el correo, revise la carpeta de correo no deseado. Como alternativa, el **Administrador** puede restablecer su contraseña desde el módulo de Empleados y entregarle el enlace directamente."),
    H2("2.3. La pantalla principal"),
    Pb("Al ingresar se muestra la pantalla principal. A la izquierda (o en la parte superior) está el **menú de navegación**, organizado por módulos; desde ahí se accede a todas las tareas. Cada usuario ve únicamente las opciones habilitadas para su rol."),
    ...figura("02_acceso_menu_01.png", 2.020, "Pantalla principal con el menú de navegación."),
    H2("2.4. Cerrar sesión"),
    Pb("Para salir de forma segura, abra el menú de su usuario (arriba a la derecha) y elija **Cerrar sesión**. Es recomendable cerrar sesión siempre que deje la computadora desatendida."),
  ];
})();

// ==========================================================================
//  3. ROLES DEL SISTEMA
// ==========================================================================
const roles = [
  H1("3. Roles del sistema"),
  P("El sistema asigna a cada usuario uno o más roles. El rol determina qué tareas puede realizar y qué opciones del menú ve. La siguiente tabla resume, de forma general, las responsabilidades de cada rol."),
  dataTable({
    headers: ["Rol", "Qué puede hacer"],
    widths: [26, 74],
    rows: [
      ["Vendedor", "Registra y gestiona presupuestos y pedidos de venta."],
      ["Cajero", "Abre y cierra su caja, factura al contado y a crédito, cobra cuotas y solicita anulaciones de factura."],
      ["Supervisor", "Aprueba o anula presupuestos, y aprueba o rechaza anulaciones de factura y notas de crédito."],
      ["Comprador", "Gestiona órdenes de compra, recepción y facturas de proveedor, y órdenes de pago."],
      ["Encargado de Depósito", "Registra movimientos de stock, transferencias y el inventario físico."],
      ["Gerente", "Consulta los reportes y dashboards gerenciales y define las metas."],
      ["Administrador", "Administra usuarios, roles y privilegios, parámetros del sistema, talonarios y configuración de cajas y oficinas."],
    ],
  }),
  tablaCap("Roles del sistema y sus responsabilidades."),
];

// ==========================================================================
//  4. VENTAS
// ==========================================================================
const ventasIntro = [
  H1("4. Ventas"),
  P("En este módulo el Vendedor registra los presupuestos (pedidos de venta) con sus productos y cantidades. Una vez aprobado, el presupuesto puede facturarse (ver el capítulo 5). Los presupuestos tienen un período de validez: al vencer, dejan de estar disponibles para facturar. La siguiente tabla indica qué tarea realiza cada rol."),
  dataTable({
    headers: ["Rol", "Tareas"],
    widths: [26, 74],
    rows: [
      ["Vendedor", "Crear un presupuesto · Consultar presupuestos y su vencimiento · Imprimir un presupuesto."],
      ["Supervisor", "Aprobar o anular un presupuesto."],
    ],
  }),
  tablaCap("Roles y tareas del módulo Ventas."),
];

const tCrearPresupuesto = (() => {
  const s = stepList();
  return [
    H2("4.1. Crear un presupuesto"),
    Field("Rol: ", "Vendedor."),
    Field("Objetivo: ", "registrar un presupuesto (pedido de venta) con el cliente y los productos solicitados."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Presupuesto**. Se muestra la lista de presupuestos."),
    ...figura("04_presupuesto_lista_01.png", 1.90, "Ventas: lista de presupuestos."),
    s("Presione **+ Presupuesto** para iniciar uno nuevo."),
    s("Seleccione el **Cliente** (o presione **+ Cliente** para registrar uno nuevo)."),
    s("Agregue los productos: elija el **Producto** y la **Cantidad**, y presione **Agregar**. Repita por cada producto. El sistema calcula el **total**."),
    s("Presione **Crear** para guardar. El presupuesto queda en estado **Pendiente** de aprobación."),
    ...figura("04_presupuesto_alta_01.png", 1.40, "Alta de presupuesto: cliente y productos."),
    nota("Mientras está **Pendiente** el presupuesto puede editarse. Una vez **Aprobado**, se factura desde el módulo Facturación y Caja (ver 5.2)."),
  ];
})();

const tAprobarPresupuesto = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("4.2. Aprobar o anular un presupuesto"),
    Field("Rol: ", "Supervisor."),
    Field("Objetivo: ", "revisar un presupuesto pendiente y aprobarlo para que pueda facturarse, o anularlo."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Aprobación de Presupuestos**. Se muestran los presupuestos pendientes."),
    s("Abra el presupuesto a resolver. Se muestra su **estado actual** y el detalle."),
    s("Presione **Aprobar** (queda disponible para facturar) o **Anular** (se descarta)."),
    ...figura("04_presupuesto_aprobar_01.png", 1.40, "Aprobar o anular un presupuesto."),
    importante("Solo los presupuestos en estado **Aprobado** pueden facturarse. Un presupuesto **Anulado** o **Vencido** ya no puede facturarse."),
  ];
})();

const tConsultarPresupuesto = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("4.3. Consultar presupuestos y su vencimiento"),
    Field("Rol: ", "Vendedor."),
    Field("Objetivo: ", "revisar el estado de los presupuestos, imprimirlos y ver los vencidos o anulados."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Presupuesto**. La lista muestra cada presupuesto con su **estado** (pendiente, aprobado, facturado, anulado o vencido) y su fecha."),
    s("Para imprimir un presupuesto, ábralo y use la opción de **documento** del presupuesto."),
    ...figura("04_presupuesto_documento_01.png", 1.05, "Documento del presupuesto."),
    s("Para ver los presupuestos **anulados o vencidos**, ingrese a **Ventas → Reportes → Presupuestos Anulados y Vencidos**."),
    ...figura("04_presupuesto_vencidos_01.png", 1.90, "Presupuestos anulados y vencidos."),
    nota("Un presupuesto **vence** al terminar su período de validez; a partir de ese momento deja de estar disponible para facturar."),
  ];
})();

// ==========================================================================
//  5. FACTURACIÓN Y CAJA
// ==========================================================================
const factCajaIntro = [
  H1("5. Facturación y Caja"),
  P("Este módulo reúne la operación diaria del cajero: la apertura de la caja al comenzar la jornada, la emisión de facturas (al contado y a crédito), la anulación de una factura, la consulta del estado de la caja y, al finalizar el día, su cierre y arqueo. La siguiente tabla indica qué tarea realiza cada rol."),
  dataTable({
    headers: ["Rol", "Tareas"],
    widths: [26, 74],
    rows: [
      ["Cajero", "Abrir caja · Facturar al contado · Facturar a crédito · Solicitar anulación de factura · Consultar el estado de caja · Cerrar y arquear la caja."],
      ["Supervisor", "Aprobar o rechazar la anulación de una factura."],
    ],
  }),
  tablaCap("Roles y tareas del módulo Facturación y Caja."),
];

const tAbrirCaja = (() => {
  const s = stepList();
  return [
    H2("5.1. Abrir la caja"),
    Field("Rol: ", "Cajero."),
    Field("Objetivo: ", "habilitar la caja al comenzar la jornada para poder facturar y cobrar."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Caja → Apertura de Caja**."),
    s("Verifique la oficina y seleccione la caja a abrir."),
    s("Ingrese el **monto de apertura** (el efectivo con el que inicia la caja) por cada moneda."),
    s("Presione **Guardar** (o **Crear**). La caja queda **Abierta** y lista para operar."),
    ...figura("05_caja_apertura_01.png", 2.009, "Apertura de caja: montos de apertura."),
    importante("Cada empleado puede tener **una sola caja abierta** a la vez. Si intenta abrir otra mientras ya tiene una abierta, el sistema no lo permite: primero debe cerrar la caja anterior."),
    nota("La facturación al contado y el cobro de cuotas requieren tener la caja abierta. Si no abrió su caja, esas tareas no estarán disponibles."),
  ];
})();

const tFacturarContado = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("5.2. Facturar al contado"),
    Field("Rol: ", "Cajero."),
    Field("Objetivo: ", "emitir una factura de contado a partir de un presupuesto aprobado y cobrar el importe en el momento."),
    importante("Para facturar debe tener su **caja abierta** (ver 5.1). El presupuesto a facturar debe estar en estado **Aprobado**."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Proceso Ventas**. Se muestra la lista de comprobantes."),
    s("Presione **Crear** para iniciar una nueva factura."),
    ...figura("05_facturacion_contado_01.png", 1.932, "Proceso Ventas: lista de comprobantes y botón Crear."),
    s("Seleccione el **cliente** y el **presupuesto aprobado** a facturar. El sistema carga el detalle de productos y los totales."),
    ...figura("05_facturacion_contado_02.png", 1.666, "Factura con el cliente y el detalle cargados."),
    s("En **Forma de Pago** elija **Contado**."),
    s("Ingrese el **Monto Ingresado** (el efectivo que entrega el cliente). El sistema calcula el **vuelto**."),
    ...figura("05_facturacion_contado_03.png", 1.435, "Forma de pago Contado: monto y vuelto."),
    s("Presione **Crear** para confirmar. El sistema emite la factura, descuenta el stock de los productos y registra el ingreso en su caja."),
    s("El sistema muestra el **documento de la factura**, listo para imprimir o guardar."),
    ...figura("05_facturacion_contado_04.png", 1.053, "Documento de la factura (KuDE)."),
    nota("El presupuesto facturado pasa a estado **Facturado** y ya no puede volver a facturarse."),
  ];
})();

const tFacturarCredito = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("5.3. Facturar a crédito"),
    Field("Rol: ", "Cajero."),
    Field("Objetivo: ", "emitir una factura cuyo importe se cobrará en cuotas."),
    P("El procedimiento es igual al de la facturación al contado (5.2), con la diferencia en la forma de pago."),
    H3("Pasos"),
    s("Realice los pasos 1 a 4 de **Facturar al contado**: entre a **Ventas → Proceso Ventas**, presione **Crear** y seleccione el cliente y el presupuesto aprobado."),
    s("En **Forma de Pago** elija **Crédito**."),
    s("Seleccione el **Plan de Cuotas** con el que se financiará la venta."),
    s("Presione **Crear** para confirmar. El sistema emite la factura, descuenta el stock y genera la **cuenta por cobrar** con sus cuotas."),
    nota("En la venta a crédito **no** se registra ingreso en la caja: el dinero se percibe luego, al cobrar cada cuota (ver el módulo Cobranzas). El total financiado puede incluir el **interés** correspondiente al plan de cuotas."),
  ];
})();

const tAnular = (() => {
  const s1 = stepList();
  const s2 = stepList();
  return [
    pageBreak(),
    H2("5.4. Anular una factura"),
    Field("Roles: ", "Cajero (solicita), Supervisor (aprueba)."),
    Field("Objetivo: ", "dejar sin efecto una factura emitida por error, dentro del plazo permitido."),
    importante("Una factura solo puede anularse dentro de las **48 horas** de emitida y siempre que **no** tenga cuotas ya cobradas. Pasado ese plazo, corresponde emitir una **Nota de Crédito** (ver el capítulo correspondiente)."),
    H3("Solicitar la anulación (Cajero)"),
    s1("En el menú, ingrese a **Ventas → Proceso Ventas**."),
    s1("Ubique la factura a anular e inicie la solicitud."),
    s1("Escriba el **motivo** de la anulación (al menos 10 caracteres) y confirme. La factura queda **Pendiente de anulación**."),
    ...figura("05_anulacion_solicitud_01.png", 1.957, "Solicitud de anulación con el motivo."),
    H3("Aprobar o rechazar (Supervisor)"),
    s2("El Supervisor ingresa a **Ventas → Anulaciones de Facturas** y abre la solicitud pendiente."),
    s2("Revisa el motivo y presiona **Aprobar** o **Rechazar**."),
    s2("Al **aprobar**, el sistema reversa el stock y, según corresponda, el ingreso de caja (si fue contado) o la cuenta por cobrar (si fue crédito); la factura queda **Anulada**."),
    ...figura("05_anulacion_aprobacion_01.png", 1.585, "Aprobación o rechazo de la anulación."),
    nota("Si el Supervisor **rechaza** la solicitud, la factura vuelve a quedar activa y no se produce ningún reverso."),
  ];
})();

const tEstadoCaja = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("5.5. Consultar el estado de la caja"),
    Field("Rol: ", "Cajero."),
    Field("Objetivo: ", "revisar en cualquier momento el saldo de la caja y los movimientos registrados."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Caja → Estado de Caja**."),
    s("Seleccione su caja. El sistema muestra el **saldo esperado por moneda** y la lista de **movimientos** (ingresos, cobros y egresos)."),
    s("Puede filtrar los movimientos por tipo para ubicarlos más rápido."),
    ...figura("05_estado_caja_01.png", 2.004, "Estado de caja: saldo por moneda y movimientos."),
    nota("Desde esta pantalla también puede iniciar el **cierre** de la caja (ver 5.6) y consultar el documento de arqueo de cierres anteriores."),
  ];
})();

const tCerrarCaja = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("5.6. Cerrar y arquear la caja"),
    Field("Rol: ", "Cajero."),
    Field("Objetivo: ", "cerrar la caja al final de la jornada comparando el saldo esperado con el efectivo contado."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Caja → Cierre de Caja** (o presione **Cerrar** desde el Estado de Caja)."),
    s("El sistema muestra el **saldo esperado** de la caja calculado a partir de los movimientos."),
    s("Cuente el efectivo disponible e ingrese el **monto declarado** (lo que realmente hay en la caja)."),
    s("Confirme el cierre. El sistema calcula la **diferencia** (declarado − esperado) y marca la caja como **Cerrada**."),
    ...figura("05_cierre_caja_01.png", 1.963, "Cierre de caja: arqueo con el monto declarado."),
    s("El sistema genera el **documento de arqueo**, listo para imprimir."),
    ...figura("05_cierre_caja_02.png", 2.035, "Documento de arqueo de caja."),
    importante("Verifique el monto declarado antes de confirmar: una vez cerrada, la caja no puede reabrirse. Una **diferencia** positiva indica sobrante y una negativa, faltante."),
  ];
})();

// ==========================================================================
//  6. COBRANZAS
// ==========================================================================
const cobranzasIntro = [
  H1("6. Cobranzas"),
  P("Este módulo permite registrar el cobro de las cuotas de las ventas a crédito y emitir el recibo correspondiente, reimprimir recibos ya emitidos y consultar las cuentas por cobrar de un cliente. La siguiente tabla indica qué tarea realiza cada rol."),
  dataTable({
    headers: ["Rol", "Tareas"],
    widths: [26, 74],
    rows: [
      ["Cajero", "Cobrar una cuota y emitir el recibo · Reimprimir un recibo · Consultar las cuentas por cobrar de un cliente."],
    ],
  }),
  tablaCap("Roles y tareas del módulo Cobranzas."),
];

const tCobrarCuota = (() => {
  const s = stepList();
  return [
    H2("6.1. Cobrar una cuota y emitir el recibo"),
    Field("Rol: ", "Cajero."),
    Field("Objetivo: ", "registrar el pago de una cuota pendiente de una venta a crédito y emitir el recibo."),
    importante("Para cobrar debe tener su **caja abierta** (ver 5.1) y un **talonario de recibo** vigente. El cobro corresponde a facturas emitidas **a crédito**."),
    H3("Pasos"),
    s("En el menú, ingrese a **Cobranzas → Cobros**. Se muestra la lista de cuentas por cobrar."),
    s("Ubique la cuenta por cobrar del cliente y ábrala. Se muestra el **Detalle de Cuotas**."),
    ...figura("06_cobros_lista_01.png", 1.90, "Cobros: lista de cuentas por cobrar."),
    s("Seleccione la **cuota pendiente** que va a cobrar. Se abre el formulario de **Cobro de Cuotas**."),
    ...figura("06_cobros_cuotas_01.png", 1.90, "Detalle de cuotas de la cuenta por cobrar."),
    s("Elija el **Método de Pago** e ingrese el **Monto Pago Recibido** (el efectivo que entrega el cliente). El sistema calcula el **vuelto**. Si corresponde, indique el **nº de referencia**."),
    s("Presione **Cobrar**. El sistema registra el cobro, marca la cuota **Pagada**, descuenta el saldo de la cuenta por cobrar y genera el **número de recibo**."),
    ...figura("06_cobros_pago_01.png", 1.40, "Cobro de cuota: método de pago y monto recibido."),
    s("Presione **Imprimir** para ver el **documento del recibo**, listo para imprimir o guardar."),
    ...figura("06_cobros_recibo_01.png", 1.05, "Documento del recibo de cobro."),
    nota("Si la cuota estaba **vencida**, igual puede cobrarse. Al cobrar la última cuota, la cuenta por cobrar queda **saldada** (Pagada)."),
  ];
})();

const tReimprimirRecibo = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("6.2. Reimprimir un recibo"),
    Field("Rol: ", "Cajero."),
    Field("Objetivo: ", "volver a imprimir un recibo de cobro ya emitido."),
    H3("Pasos"),
    s("En el menú, ingrese a **Cobranzas → Recibos de Cobro**. Se muestra la lista de recibos emitidos."),
    s("Ubique el recibo y ábralo. Se muestra el **documento del recibo**, listo para reimprimir o guardar."),
    ...figura("06_recibos_reimpresion_01.png", 1.90, "Recibos de Cobro: lista para reimprimir."),
  ];
})();

const tConsultarCxC = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("6.3. Consultar las cuentas por cobrar de un cliente"),
    Field("Rol: ", "Cajero."),
    Field("Objetivo: ", "revisar las cuotas y el saldo pendiente de un cliente."),
    H3("Pasos"),
    s("En el menú, ingrese a **Cobranzas → Cobros**."),
    s("Ubique la cuenta por cobrar del cliente en la lista."),
    s("Ábrala para ver el **Detalle de Cuotas**: número de cuota, vencimiento, monto, estado (pendiente, pagada o vencida) y el saldo pendiente."),
    ...figura("06_cuenta_cliente_01.png", 1.90, "Detalle de cuotas y saldo del cliente."),
    nota("Desde esta vista también puede iniciar el **cobro** de una cuota (ver 6.1)."),
  ];
})();

// ==========================================================================
//  7. NOTAS DE CRÉDITO
// ==========================================================================
const ncIntro = [
  H1("7. Notas de Crédito"),
  P("Una nota de crédito permite revertir total o parcialmente una factura cuando ya pasó el plazo de anulación (48 horas). A diferencia de la anulación, la factura original permanece activa y la nota de crédito es un documento nuevo. Según el motivo, al aprobarse reingresa stock (devolución), afecta la caja (si la factura fue de contado) o ajusta la cuenta por cobrar (si fue a crédito). La siguiente tabla indica qué tarea realiza cada rol."),
  dataTable({
    headers: ["Rol", "Tareas"],
    widths: [26, 74],
    rows: [
      ["Supervisor", "Solicitar una nota de crédito · Aprobar o rechazar una solicitud · Imprimir la nota de crédito."],
    ],
  }),
  tablaCap("Roles y tareas del módulo Notas de Crédito."),
];

const tSolicitarNC = (() => {
  const s = stepList();
  return [
    H2("7.1. Solicitar una nota de crédito"),
    Field("Rol: ", "Supervisor."),
    Field("Objetivo: ", "registrar una solicitud de nota de crédito sobre una factura, indicando el motivo y las líneas o importes a acreditar."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Proceso Ventas** y ubique la **factura** sobre la que emitirá la nota de crédito."),
    s("Elija la acción **Solicitar Nota de Crédito**. Se abre el formulario con los datos de la factura."),
    ...figura("07_nc_solicitar_01.png", 1.90, "Solicitud de nota de crédito desde la factura."),
    s("Seleccione el **Motivo** de la nota de crédito y el **Tipo** (total o parcial)."),
    s("Para cada línea indique lo que se acredita: en una **devolución**, la **Cantidad** devuelta; en un **descuento** o **ajuste**, el **Precio Nuevo** (el sistema acredita la diferencia)."),
    s("Si corresponde, escriba una **observación** y presione **Solicitar**. La solicitud queda **pendiente** de aprobación."),
    ...figura("07_nc_solicitar_02.png", 1.40, "Formulario de solicitud: motivo y líneas a acreditar."),
    importante("La nota de crédito **no anula** la factura: es un documento nuevo. Si la factura tiene menos de 48 horas y desea dejarla sin efecto, conviene **anularla** (ver 5.4) en lugar de emitir una nota de crédito."),
  ];
})();

const tAprobarNC = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("7.2. Aprobar o rechazar una nota de crédito"),
    Field("Rol: ", "Supervisor."),
    Field("Objetivo: ", "revisar una solicitud de nota de crédito y resolverla."),
    H3("Pasos"),
    s("En el menú, ingrese a **Ventas → Notas de Crédito**. Se muestra la lista de solicitudes y notas de crédito."),
    ...figura("07_nc_lista_01.png", 1.90, "Notas de Crédito: lista de solicitudes."),
    s("Abra la solicitud **pendiente**. Se muestra el desglose de lo que se acreditará."),
    s("Presione **Aprobar** o **Rechazar**. Al **aprobar**, el sistema reserva el número de nota de crédito y aplica los efectos según el motivo: reingreso de **stock** (devolución), **egreso de caja** (si la factura fue de contado del día) o ajuste de la **cuenta por cobrar** (si fue a crédito)."),
    ...figura("07_nc_aprobar_01.png", 1.40, "Aprobar o rechazar la nota de crédito, con el desglose."),
    nota("Si **rechaza** la solicitud, no se produce ningún efecto y la factura queda igual."),
  ];
})();

const tImprimirNC = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("7.3. Imprimir la nota de crédito"),
    Field("Rol: ", "Supervisor."),
    Field("Objetivo: ", "obtener el documento de una nota de crédito aprobada."),
    H3("Pasos"),
    s("En **Ventas → Notas de Crédito**, ubique la nota de crédito **aprobada**."),
    s("Ábrala para ver el **documento de la nota de crédito**, listo para imprimir o guardar."),
    ...figura("07_nc_documento_01.png", 1.05, "Documento de la nota de crédito."),
  ];
})();

// ==========================================================================
//  8. COMPRAS
// ==========================================================================
const comprasIntro = [
  H1("8. Compras"),
  P("Este módulo cubre el ciclo de compras: emitir una orden de compra a un proveedor, aprobarla, recepcionar la mercadería, registrar la factura del proveedor y pagarla mediante una orden de pago. También permite registrar la nota de crédito que emite el proveedor. La siguiente tabla indica qué tarea realiza cada rol."),
  dataTable({
    headers: ["Rol", "Tareas"],
    widths: [26, 74],
    rows: [
      ["Comprador", "Crear una orden de compra · Recepcionar una orden de compra · Registrar la factura del proveedor · Generar una orden de pago · Registrar una nota de crédito de proveedor."],
      ["Supervisor", "Aprobar una orden de compra · Confirmar o anular una orden de pago."],
    ],
  }),
  tablaCap("Roles y tareas del módulo Compras."),
];

const tCrearOC = (() => {
  const s = stepList();
  return [
    H2("8.1. Crear una orden de compra"),
    Field("Rol: ", "Comprador."),
    Field("Objetivo: ", "emitir una orden de compra a un proveedor con los productos a comprar."),
    H3("Pasos"),
    s("En el menú, ingrese a **Compras y Pagos → Orden de Compra**."),
    s("Seleccione el **Proveedor**."),
    s("Agregue los productos: elija el **Producto** y la **Cantidad** (y el precio, si corresponde). Repita por cada producto."),
    s("Presione **Crear**. La orden de compra queda registrada, **pendiente de aprobación**."),
    ...figura("08_oc_alta_01.png", 1.40, "Alta de una orden de compra."),
  ];
})();

const tAprobarOC = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("8.2. Aprobar una orden de compra"),
    Field("Rol: ", "Supervisor."),
    Field("Objetivo: ", "revisar y aprobar una orden de compra para que pueda recepcionarse."),
    H3("Pasos"),
    s("En el menú, ingrese a **Compras y Pagos → Aprobación de Órdenes de Compra**."),
    s("Abra la orden **pendiente** y revise el detalle."),
    s("**Apruebe** la orden (o recházela). Aprobada, queda lista para la recepción."),
    ...figura("08_oc_aprobar_01.png", 1.40, "Aprobación de una orden de compra."),
    nota("Solo las órdenes de compra **aprobadas** pueden recepcionarse."),
  ];
})();

const tRecepcionar = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("8.3. Recepcionar una orden de compra"),
    Field("Rol: ", "Comprador."),
    Field("Objetivo: ", "registrar la entrada de la mercadería recibida contra una orden de compra."),
    H3("Pasos"),
    s("En el menú, ingrese a **Compras y Pagos → Recepción de Orden de Compra**."),
    s("Seleccione la orden de compra a recepcionar."),
    s("Indique las **cantidades recibidas** por producto y confirme. El sistema **ingresa el stock** de los productos recibidos."),
    ...figura("08_oc_recepcion_01.png", 1.90, "Recepción de una orden de compra."),
    nota("La recepción puede ser **parcial**: el stock se actualiza con lo efectivamente recibido."),
  ];
})();

const tFacturaProv = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("8.4. Registrar la factura del proveedor"),
    Field("Rol: ", "Comprador."),
    Field("Objetivo: ", "registrar la factura emitida por el proveedor por la compra."),
    H3("Pasos"),
    s("En el menú, ingrese a **Compras y Pagos → Proceso de Compras**. Se muestra la lista de comprobantes de compra."),
    s("Presione **Crear** para registrar una nueva factura."),
    s("Seleccione el **Proveedor** e ingrese los datos del comprobante: **Nro. Comprobante**, **Nro. de Timbrado** con sus fechas y la **Fecha de Emisión**."),
    s("Indique la **Condición** (Contado o Crédito) y agregue los productos con su cantidad y precio."),
    s("Presione **Crear**. La factura queda registrada."),
    ...figura("08_factura_prov_01.png", 1.40, "Registro de la factura del proveedor."),
    nota("Una factura a **crédito** genera la **cuenta por pagar** correspondiente, con vencimiento según el plazo de pago del proveedor."),
  ];
})();

const tGenerarOP = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("8.5. Generar una orden de pago"),
    Field("Rol: ", "Comprador."),
    Field("Objetivo: ", "preparar el pago de una o varias facturas pendientes de un proveedor."),
    H3("Pasos"),
    s("En el menú, ingrese a **Compras y Pagos → Deuda a Proveedores**. Se muestran las facturas pendientes de pago con su saldo y vencimiento."),
    s("Seleccione las facturas a pagar e indique el importe."),
    s("Presione **Generar Orden de Pago**. La orden se crea en estado **Borrador** (todavía no baja el saldo de la deuda)."),
    ...figura("08_op_generar_01.png", 1.90, "Deuda a proveedores y generación de la orden de pago."),
  ];
})();

const tConfirmarOP = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("8.6. Confirmar o anular una orden de pago"),
    Field("Rol: ", "Supervisor."),
    Field("Objetivo: ", "ejecutar el pago de una orden de pago en borrador, o anularla."),
    H3("Pasos"),
    s("En el menú, ingrese a **Compras y Pagos → Órdenes de Pago**. Se muestra la lista de órdenes de pago."),
    s("Abra la orden en **Borrador** y elija **Resolver**. Se muestra el detalle de los comprobantes aplicados."),
    s("Para pagar, elija el **método de pago** y presione **Confirmar pago**: el sistema registra el pago y **baja el saldo** de la deuda. Para descartarla, presione **Anular** (indicando el motivo)."),
    ...figura("08_op_resolver_01.png", 1.40, "Resolver la orden de pago: confirmar o anular."),
    s("Puede imprimir el **documento de la orden de pago**."),
    ...figura("08_op_documento_01.png", 1.05, "Documento de la orden de pago."),
  ];
})();

const tNCCompra = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("8.7. Registrar una nota de crédito de proveedor"),
    Field("Rol: ", "Comprador."),
    Field("Objetivo: ", "registrar una nota de crédito emitida por el proveedor sobre una factura de compra."),
    H3("Pasos"),
    s("En el menú, ingrese a **Compras y Pagos → Nota de Credito Proveedor**."),
    s("Seleccione la **factura** de compra de origen y el **motivo** de la nota de crédito."),
    s("Indique las líneas o cantidades a acreditar y registre. El sistema **baja la cuenta por pagar** y, si el motivo es una **devolución**, **descuenta el stock** correspondiente."),
    ...figura("08_nc_compra_01.png", 1.40, "Registro de una nota de crédito de proveedor."),
    nota("La nota de crédito la **emite el proveedor**; el sistema solo la **captura** (no genera un documento propio)."),
  ];
})();

// ==========================================================================
//  9. INVENTARIO
// ==========================================================================
const inventarioIntro = [
  H1("9. Inventario"),
  P("Este módulo permite consultar las existencias de productos y el historial de movimientos de stock, y realizar el inventario físico (conteo) con su posterior aprobación para ajustar el stock del sistema. La siguiente tabla indica qué tarea realiza cada rol."),
  dataTable({
    headers: ["Rol", "Tareas"],
    widths: [26, 74],
    rows: [
      ["Encargado de Depósito", "Consultar existencias · Consultar el historial de movimientos · Realizar un inventario físico."],
      ["Supervisor", "Aprobar un inventario físico."],
    ],
  }),
  tablaCap("Roles y tareas del módulo Inventario."),
];

const tExistencias = (() => {
  const s = stepList();
  return [
    H2("9.1. Consultar existencias"),
    Field("Rol: ", "Encargado de Depósito."),
    Field("Objetivo: ", "ver el stock disponible de los productos por oficina."),
    H3("Pasos"),
    s("En el menú, ingrese a **Productos e Inventario → Reporte Inventario → Existencias**."),
    s("Si lo necesita, filtre por **Oficina** (u otros filtros disponibles)."),
    s("Consulte la lista de productos con su **cantidad en existencia**."),
    ...figura("09_existencias_01.png", 1.90, "Existencias: stock por producto."),
  ];
})();

const tMovimientos = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("9.2. Consultar el historial de movimientos de stock"),
    Field("Rol: ", "Encargado de Depósito."),
    Field("Objetivo: ", "revisar las entradas y salidas de stock de los productos."),
    H3("Pasos"),
    s("En el menú, ingrese a **Productos e Inventario → Reporte Inventario → Movimiento de Stock**."),
    s("Consulte los movimientos con su **fecha**, **tipo** (entrada o salida) y **cantidad**. Puede filtrar por producto o período."),
    ...figura("09_movimientos_01.png", 1.90, "Historial de movimientos de stock."),
    nota("Los movimientos reflejan las **ventas** (salidas), las **recepciones** de compra (entradas), las **transferencias** entre depósitos y los **ajustes** de inventario."),
  ];
})();

const tInventarioFisico = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("9.3. Realizar un inventario físico"),
    Field("Rol: ", "Encargado de Depósito."),
    Field("Objetivo: ", "registrar el conteo real de los productos para compararlo con el stock del sistema."),
    H3("Pasos"),
    s("En el menú, ingrese a **Productos e Inventario → Proceso de Inventario** y **Cree** un nuevo proceso de inventario, indicando el alcance (por ejemplo, la oficina)."),
    s("Ingrese a **Conteo Físico** y registre la **cantidad contada** de cada producto."),
    s("Guarde el conteo. El sistema calcula la **diferencia** contra el stock registrado."),
    ...figura("09_conteo_01.png", 1.90, "Conteo físico de productos."),
    nota("El **ajuste** de stock se aplica recién cuando el inventario se **aprueba** (ver 9.4)."),
  ];
})();

const tAprobarInventario = (() => {
  const s = stepList();
  return [
    pageBreak(),
    H2("9.4. Aprobar un inventario físico"),
    Field("Rol: ", "Supervisor."),
    Field("Objetivo: ", "revisar las diferencias del conteo y aprobar el ajuste de stock."),
    H3("Pasos"),
    s("En el menú, ingrese a **Productos e Inventario → Revisión**."),
    s("Abra el inventario a revisar y compare las **cantidades contadas** con las del sistema."),
    s("**Apruebe** el inventario. El sistema **ajusta el stock** para que coincida con lo contado."),
    ...figura("09_revision_01.png", 1.90, "Revisión y aprobación del inventario físico."),
  ];
})();

// ==========================================================================
//  ENSAMBLADO
// ==========================================================================
if (require.main === module) buildDoc({
  outPath: OUT,
  sections: [
    portraitSection(makeCaratula({
      titulo: "MANUAL DE USUARIO",
    }), true),

    portraitSection([
      ...intro,
      pageBreak(), ...acceso,
      pageBreak(), ...roles,
      pageBreak(),
      ...ventasIntro,
      ...tCrearPresupuesto,
      ...tAprobarPresupuesto,
      ...tConsultarPresupuesto,
      pageBreak(),
      ...factCajaIntro,
      ...tAbrirCaja,
      ...tFacturarContado,
      ...tFacturarCredito,
      ...tAnular,
      ...tEstadoCaja,
      ...tCerrarCaja,
      pageBreak(),
      ...cobranzasIntro,
      ...tCobrarCuota,
      ...tReimprimirRecibo,
      ...tConsultarCxC,
      pageBreak(),
      ...ncIntro,
      ...tSolicitarNC,
      ...tAprobarNC,
      ...tImprimirNC,
      pageBreak(),
      ...comprasIntro,
      ...tCrearOC,
      ...tAprobarOC,
      ...tRecepcionar,
      ...tFacturaProv,
      ...tGenerarOP,
      ...tConfirmarOP,
      ...tNCCompra,
      pageBreak(),
      ...inventarioIntro,
      ...tExistencias,
      ...tMovimientos,
      ...tInventarioFisico,
      ...tAprobarInventario,
    ]),
  ],
});

module.exports = { intro, acceso, roles, ventasIntro, factCajaIntro, cobranzasIntro, ncIntro, comprasIntro, inventarioIntro };

// ============================================================================
// backend.js — inventario de componentes PL/SQL (BD real) agrupados por módulo.
// Cada objeto se asigna a un módulo con una descripción concisa de su efecto.
// Grupos: Paquetes, Funciones, Procedimientos, Triggers, Vistas.
// ============================================================================
module.exports = {
  ventas: {
    "Funciones": [
      ["FN_PRECIO_VENTA", "resuelve el precio de venta vigente de un producto."],
      ["FN_OBTENER_PRECIO_VIGENTE", "devuelve el precio vigente por producto y fecha."],
      ["FUN_OBT_PRE_CLIENTE", "obtiene el precio aplicable según la categoría del cliente."],
    ],
    "Triggers": [
      ["TRG_GENERAR_RESERVA_ORDEN", "al crear/aprobar el presupuesto genera las reservas de stock de sus líneas."],
      ["TRG_OV_LIBERA_RESERVA", "libera las reservas cuando el presupuesto se factura o anula."],
      ["TRG_OV_USUARIO_CREACION", "estampa el usuario creador del presupuesto (habilitador del vendedor en reportes)."],
      ["TRG_OV_FECHA_VENCIMIENTO", "calcula el vencimiento de la vigencia del presupuesto."],
      ["TRG_OV_VALIDA_REVERSO_FACT", "controla las transiciones válidas del presupuesto ligadas a la facturación."],
    ],
  },

  facturacion_caja: {
    "Funciones": [
      ["FN_OBTENER_COMPROBANTE", "reserva y devuelve el próximo número del talonario vigente del tipo pedido, de forma atómica; valida vigencia y rango."],
      ["FN_CAJA_ABIERTA_USUARIO", "devuelve la caja abierta del usuario actual (o NULL); valida que exista caja antes de facturar/cobrar."],
      ["FN_CAJA_CONF_USUARIO", "resuelve la caja configurada del usuario de sesión."],
      ["FN_PUEDE_TRANSICION_OV", "valida la transición de estado del presupuesto (APROBADO → FACTURADO)."],
      ["FN_COBRAR_CUOTA", "registra el cobro de una o más cuotas de una CxC: crea el movimiento de caja (COBRO_CXC), marca las cuotas PAGADA, recalcula el saldo y numera el recibo."],
      ["FN_MOTIVO_BLOQUEO_ANULACION", "determina si una factura puede anularse dentro de la ventana (48 h) y devuelve el motivo de bloqueo si no."],
      ["FN_NC_ELEGIBLE / FN_NC_AVISO", "determinan si una factura admite nota de crédito y el aviso a mostrar."],
      ["FN_CANT_ACREDITABLE", "cantidad máxima acreditable por línea en una nota de crédito."],
      ["FN_COBRO_REVERSABLE", "indica si un cobro admite reverso (módulo de reverso, hoy oculto)."],
      ["FN_KUDE_FACTURA_HTML / FN_KUDE_RECIBO_HTML / FN_KUDE_NOTA_CREDITO_HTML", "generan la representación gráfica (KuDE) de factura, recibo y nota de crédito; sin CDC/QR, con leyenda «sin validez fiscal»."],
      ["FN_CIERRE_CAJA_HTML", "genera el documento de arqueo de caja (control interno, no fiscal)."],
      ["FN_NUMERO_A_LETRAS", "convierte un importe a su expresión en letras para los documentos."],
    ],
    "Procedimientos": [
      ["CERRAR_CAJA", "cierra y arquea la caja: calcula el saldo esperado por moneda desde V_CAJA_SALDO, lo compara con el efectivo declarado y guarda la diferencia."],
      ["PRC_SOLICITAR/APROBAR/RECHAZAR_ANULACION", "flujo de anulación de factura con aprobación (dentro de las 48 h)."],
      ["PRC_SOLICITAR/APROBAR/RECHAZAR_NOTA_CREDITO", "flujo de nota de crédito: staging con aprobación, reserva del número de NC al aprobar y efectos en stock/caja/CxC."],
      ["PRC_VALIDAR_SOLICITUD_NC", "valida una solicitud de nota de crédito antes de resolverla."],
      ["PRC_SOLICITAR/APROBAR/RECHAZAR_REVERSO_COBRO", "flujo de reverso de cobro (módulo oculto; el histórico persiste)."],
    ],
    "Triggers": [
      ["TRG_INS_CUENTAS_COBRAR", "al insertar una factura a crédito arma la CxC y sus cuotas en enteros PYG (la última absorbe el remanente), de modo que factura = CxC.SALDO = Σ cuotas."],
      ["TRG_CAJA_UNA_POR_DIA", "bloquea la apertura si el empleado ya tiene una caja con ESTADO='A'."],
      ["TRG_CERRAR_CAJA_CONF", "consistencia de la caja configurada al cerrar."],
      ["TRG_COMPROBANTE_FECHA_HORA", "sella la fecha-hora de emisión con la hora local."],
      ["TRG_FACTURA_ORDEN", "sincroniza el estado del presupuesto al facturar."],
      ["TRG_TALONARIO_DERIVA_OFICINA", "deriva oficina, establecimiento y punto de expedición del talonario desde la caja configurada."],
    ],
    "Vistas": [
      ["V_CAJA_SALDO", "saldo por caja y moneda (fuente de verdad del estado de caja y del cierre)."],
      ["V_TALONARIOS_DISPONIBLES", "talonarios activos y vigentes disponibles para emitir."],
      ["V_RECIBOS_COBRO / V_RECIBOS_LISTA", "recibos de dinero para consulta y reimpresión."],
      ["V_ANULACIONES_FACTURAS", "solicitudes de anulación y su estado."],
      ["V_NOTAS_CREDITO / V_SOLICITUDES_NC", "notas de crédito emitidas y solicitudes en curso."],
      ["V_SOLICITUDES_REVERSO", "solicitudes de reverso de cobro (módulo oculto)."],
    ],
  },

  compras: {
    "Funciones": [
      ["FN_COSTO_PONDERADO", "costo promedio ponderado de un producto a partir de las facturas de compra."],
      ["FN_GET_LIMITE_OC_MENSUAL", "límite de monto mensual de órdenes de compra (parámetro de control)."],
      ["FN_NC_COMPRA_ELEGIBLE", "indica si una factura de compra admite nota de crédito de proveedor."],
      ["FN_CANT_ACREDITABLE_COMPRA / FN_CANT_DEVOLVIBLE_COMPRA", "cantidades máximas a acreditar y a devolver (esta última capada a lo recibido) en una NC de compra."],
      ["FN_ORDEN_PAGO_HTML", "genera el documento imprimible de la orden de pago."],
      ["FN_KUDE_FACTURA_PROV_HTML / FN_KUDE_NC_COMPRA_HTML", "representación gráfica de la factura y la nota de crédito del proveedor (registro interno, sin validez fiscal)."],
    ],
    "Procedimientos": [
      ["PRC_GENERAR_ORDEN_PAGO", "emite la orden de pago en BORRADOR (autoriza, no baja saldo)."],
      ["PRC_CONFIRMAR_ORDEN_PAGO", "ejecuta el pago: baja el saldo de las CxP aplicadas y marca su estado."],
      ["PRC_ANULAR_ORDEN_PAGO", "anula la orden de pago registrando el motivo."],
      ["PRC_REGISTRAR_NC_COMPRA", "registra la nota de crédito del proveedor de forma atómica: baja la CxP y, si es devolución, genera la salida de stock."],
      ["RECALCULAR_ESTADO_OC", "recalcula el estado de la orden de compra según sus recepciones."],
      ["SP_INSERTAR_PRODUCTO_PROVEEDOR", "alta de un precio en la lista de precios por proveedor."],
    ],
    "Triggers": [
      ["TRG_INS_CUENTAS_PAGAR", "al registrar un comprobante de proveedor a crédito genera la cuenta por pagar (pago único, con vencimiento por plazo del proveedor)."],
      ["TRG_ACTUALIZAR_COSTO_COMPRA", "actualiza el costo del producto al registrar la compra."],
      ["TRG_MOV_STOCK_RECEPCION / TRG_MOV_STOCK_DETALLE_PROV", "generan la entrada de stock a partir de la recepción de la orden de compra."],
      ["TRG_AUD_PP / TRG_PP_SET_AUDIT / TRG_CIERRE_PP_ANTERIOR", "auditan y versionan los cambios de la lista de precios por proveedor."],
      ["TRG_CIERRE_MARGEN_ANTERIOR", "cierra la vigencia del margen anterior al insertar uno nuevo."],
    ],
    "Vistas": [
      ["V_CXP_DEUDA", "deuda por pagar con días de atraso (fuente de la gestión de CxP)."],
      ["V_PRODUCTO_PROVEEDOR_VIGENTE", "precio de compra vigente por producto y proveedor."],
      ["V_COMPARATIVA_PRECIO_PROVEEDORES", "comparativa de precios entre proveedores para un mismo producto."],
      ["V_NC_COMPRA", "notas de crédito de compra registradas."],
      ["V_ALERTAS_CADUCIDAD_PP", "alertas de vencimiento del acuerdo de precio de proveedor."],
    ],
  },

  inventario: {
    "Paquetes": [
      ["INVENTARIO_PKG", "operaciones del inventario físico (conteo): creación, envío, aprobación y posteo de diferencias."],
    ],
    "Funciones": [
      ["FN_HAY_STOCK", "verifica si hay existencia suficiente de un producto en una oficina."],
      ["FN_GET_STOCK_MAXIMO", "devuelve el stock máximo configurado de un producto."],
      ["FN_OFICINAS_CON_STOCK", "lista las oficinas con existencia de un producto."],
      ["FN_OFICINA_USUARIO / FN_OFICINA_USUARIO_V2", "resuelven la oficina del usuario de sesión."],
    ],
    "Procedimientos": [
      ["PRC_TRANSFERIR_STOCK", "transfiere stock de un producto entre dos oficinas (salida en origen, entrada en destino)."],
    ],
    "Triggers": [
      ["TRG_ACTUALIZAR_STOCK_MOVIMIENTO", "aplica cada movimiento de stock sobre la existencia on-hand (backstop de decremento)."],
      ["TRG_AJUSTE_MOVIMIENTO", "genera el movimiento de stock a partir de un ajuste."],
      ["TRG_MOV_STOCK_DETALLE", "genera la salida de stock desde el detalle del comprobante de venta."],
      ["TRG_AJUSTES_HORA / TRG_MOVIMIENTOS_HORA", "sellan la hora local en ajustes y movimientos."],
      ["INVENTARIO_BI / INVENTARIO_DETALLE_BI / STOCK_PRODUCTO_T / TRG_STOCK_CONFIG_BIU", "asignan identidad y valores por defecto (auditoría) en las tablas de inventario y stock."],
    ],
  },

  reportes: {
    "Funciones": [
      ["FN_INFORME_VENTAS_HTML", "genera el informe imprimible de ventas por filtros (rango, vendedor, sucursal, condición)."],
      ["FN_INFORME_COBROS_HTML", "genera el informe imprimible de cobros y cartera."],
      ["FN_INFORME_COMPRAS_HTML", "genera el informe imprimible de compras (gasto y aging de CxP)."],
      ["FN_INFORME_INVENTARIO_HTML", "genera el informe imprimible de inventario (valorización y niveles)."],
    ],
    "Triggers": [
      ["TRG_METAS_VENTA_BI / TRG_METAS_COBRANZA_BI", "asignan identidad a las metas de venta y de cobranza."],
    ],
    "Vistas": [
      ["V_VENTAS_FACTURA / V_VENTAS_LINEA / V_VENTAS_NC", "ventas facturadas, sus líneas y las NC, base del dashboard de Ventas."],
      ["V_VENTAS_NETA_MES / V_VENTAS_VENDEDOR_META", "venta neta por mes y comparación contra la meta del vendedor/sucursal."],
      ["V_COBROS_MOV / V_COBROS_MEDIO / V_COBROS_NETO_MES / V_COBROS_REVERSO", "movimientos de cobranza, medio de pago, neto por mes y reversos."],
      ["V_COBROS_OFICINA_META / V_CARTERA_CXC", "cobranza por sucursal vs. meta y aging de la cartera por cobrar."],
      ["V_INV_STOCK / V_INV_MOV / V_INV_FLUJO_MES / V_INV_ROTACION / V_INV_CONTEO_DIF", "valorización, movimientos, flujo mensual, rotación y diferencias de conteo del inventario."],
      ["V_CMP_COMPRA / V_CMP_LINEA / V_CMP_GASTO_MES", "compras, sus líneas y el gasto mensual."],
      ["V_CMP_OC_EMBUDO / V_CMP_OC_ABIERTA / V_CMP_RECEPCION", "embudo de órdenes de compra, órdenes abiertas y lead time de recepción."],
      ["V_CMP_CXP_AGING / V_CMP_PAGOS", "aging de la deuda con proveedores y pagos realizados."],
    ],
  },

  seguridad: {
    "Paquetes": [
      ["PKG_EMPLEADOS", "gestión de usuarios y autenticación: login, hash de contraseña con sal, tokens de reseteo y bloqueo por intentos fallidos."],
      ["AUT_PKG / SECURITY_PKG", "autorización: resolución de privilegios del usuario y control de acceso a recursos de la aplicación."],
    ],
    "Procedimientos": [
      ["PR_ALTA_RAPIDA_CLIENTE", "alta rápida de un cliente (persona + cliente) desde las pantallas de venta."],
    ],
    "Triggers": [
      ["EMPLEADOS_T_B / EMPLEADOS_T_CONTRA", "asignan identidad y gestionan la contraseña del empleado al insertar/actualizar."],
      ["ROLES_T_B", "asigna identidad a los roles."],
    ],
    "Vistas": [
      ["V_USUARIO_PRIVILEGIOS", "privilegios efectivos de cada usuario (resueltos por sus roles)."],
      ["V_RECURSOS_DET", "detalle del mapa de recursos protegidos y el privilegio que exige cada uno."],
    ],
  },

  catalogos: {
    "Funciones": [
      ["FN_GET_PARAMETRO", "devuelve el valor (numérico o de texto) de un parámetro del sistema por su clave."],
    ],
    "Procedimientos": [
      ["TC_ACTUALIZAR_DOLARPY", "actualiza la cotización del dólar desde la fuente externa (tipos de cambio)."],
    ],
    "Triggers": [
      ["TRG_PARAMETRO_BI / TRG_PARAMETRO_BU", "asignan identidad y auditoría a los parámetros del sistema."],
      ["OFICINAS_T / CIUDADES_T / DEPARTAMENTOS_T", "asignan identidad a los catálogos de oficinas y geografía."],
    ],
  },
};

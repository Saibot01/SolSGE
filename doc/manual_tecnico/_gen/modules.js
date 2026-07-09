// ============================================================================
// modules.js — partición del esquema por módulo para el Manual Técnico.
// Cada tabla se asigna a EXACTAMENTE un módulo dueño (diccionario exhaustivo
// sin duplicados). La estructura (columnas/tipos/PK/FK) se lee de la BD; aquí
// solo se curan el propósito de cada tabla y las descripciones de columnas de
// negocio (las PK/FK/auditoría usan la heurística de schema.js).
// Orden de módulos = flujo de negocio + soporte (igual que el libro de Diagramas).
// ============================================================================

const MODULES = [
  // =========================================================================
  { key: "ventas", name: "Ventas (Presupuestos y Pedidos)",
    intro: "Gestiona los presupuestos/pedidos de venta y la reserva de stock asociada. Un presupuesto aprobado es el punto de partida de la facturación.",
    tables: [
      { t: "ORDENES_VENTA", prop: "Cabecera del presupuesto/pedido de venta. Concentra el cliente, la oficina, el total y el ciclo de vida (creación, aprobación, anulación).", ov: {
        FECHA_ORDEN: "Fecha del presupuesto/pedido.",
        ESTADO: "Estado del ciclo de vida (BORRADOR, APROBADO, FACTURADO, ANULADO).",
        TOTAL: "Importe total del presupuesto.",
        FECHA_VENCIMIENTO: "Vencimiento de la vigencia del presupuesto.",
      } },
      { t: "DETALLE_ORDEN", prop: "Líneas del presupuesto/pedido (un renglón por producto). Composición de ORDENES_VENTA.", ov: {
        CANTIDAD: "Cantidad solicitada.", PRECIO_UNITARIO: "Precio unitario ofertado.", TOTAL: "Importe de la línea.",
      } },
      { t: "RESERVAS_PRODUCTO", prop: "Reserva de stock que genera un presupuesto sobre un producto y oficina, hasta que se factura o se libera.", ov: {
        CANTIDAD_RESERVADA: "Unidades reservadas.", FECHA_RESERVA: "Fecha de la reserva.",
        ESTADO: "Estado de la reserva (activa/liberada).",
      } },
    ] },

  // =========================================================================
  { key: "facturacion_caja", name: "Facturación y Caja",
    intro: "Emisión de comprobantes (factura y nota de crédito), cuentas por cobrar de las ventas a crédito, operación y arqueo de caja, y numeración fiscal por talonario timbrado.",
    tables: [
      { t: "COMPROBANTES", prop: "Cabecera de todo comprobante emitido: factura (TIPO_COMPROBANTE='FA') y nota de crédito ('NC'). Concentra totales, IVA discriminado por tasa, condición de venta y la trazabilidad fiscal.", ov: {
        ID_CLIENTE: "Cliente al que se factura.", ID_OFICINA: "Sucursal emisora.",
        ID_ORDEN_VENTA: "Presupuesto/pedido de origen (NULL en NC).",
        TIPO_COMPROBANTE: "'FA' factura, 'NC' nota de crédito.",
        ID_FAC_ORIGEN: "Referencia textual a la factura de origen; el vínculo autoritativo de la NC es ID_COMPROBANTE_ORIGEN.",
        FECHA: "Fecha del comprobante.", TOTAL_MONEDA_LOCAL: "Total en moneda local (PYG), IVA incluido.",
        MONEDA: "Código de moneda; default '1' (PYG).", FORMA_PAGO: "'21' contado / '1' crédito.",
        ESTADO: "'A' activo, 'P' pendiente de anulación, 'N' anulado.",
        NRO_COMPROBANTE: "Número fiscal formateado establecimiento-punto-número.",
        TOTAL_EXENTA: "Base exenta de IVA (0%).", TOTAL_GRAVADA_5: "Base gravada al 5% (sin IVA).",
        TOTAL_GRAVADA_10: "Base gravada al 10% (sin IVA).", TOTAL_IVA_5: "IVA de las líneas al 5%.",
        TOTAL_IVA_10: "IVA de las líneas al 10%.", TOTAL_IVA: "IVA total (5% + 10%).",
        MOTIVO_ANULACION: "Motivo cuando el comprobante se anula.",
        USUARIO_SOLICITA: "Usuario que solicita la anulación.", USUARIO_APRUEBA: "Usuario que resuelve la anulación.",
        FECHA_HORA_EMISION: "Sello de fecha-hora de emisión.",
        COD_MOTIVO: "Motivo SIFEN de la nota de crédito.",
        ID_COMPROBANTE_ORIGEN: "Factura de origen de la NC (autorreferencia).",
        INTERES_FINANCIACION: "Interés de financiación de la venta a crédito, IVA incluido.",
      } },
      { t: "DETALLE_COMPROBANTE", prop: "Líneas del comprobante (un renglón por producto vendido/acreditado). Composición de COMPROBANTES.", ov: {
        CANTIDAD: "Cantidad de unidades.", PRECIO_UNITARIO: "Precio unitario (IVA incluido).",
        TOTAL_LINEA: "Importe de la línea.", MONTO_IVA: "IVA de la línea.",
        PORCENTAJE_IVA: "Porcentaje de IVA aplicado.",
      } },
      { t: "TALONARIOS", prop: "Talonarios timbrados por la SET, asignados a una caja configurada. Numeración establecimiento-punto-expedición y rango vigente. ID_OFICINA, ESTABLECIMIENTO y PUNTO_EXPEDICION se derivan por trigger.", ov: {
        TIPO_COMPROBANTE: "'FA' factura, 'NC' nota de crédito, 'RC' recibo.",
        ESTABLECIMIENTO: "Código de establecimiento SET (derivado).", PUNTO_EXPEDICION: "Punto de expedición SET (derivado).",
        NRO_INICIAL: "Primer número autorizado del rango.", NRO_FINAL: "Último número autorizado del rango.",
        NRO_ACTUAL: "Próximo número a emitir.", TIMBRADO: "Número de timbrado de la SET.",
        FECHA_INICIO: "Inicio de vigencia del timbrado.", FECHA_FIN: "Fin de vigencia del timbrado.",
        ACTIVO: "'S'/'N'. Un solo talonario activo por (caja, tipo).",
      } },
      { t: "PLANES_CUOTA", prop: "Catálogo de planes de cuotas para las ventas a crédito (cantidad y condiciones de las cuotas)." },
      { t: "CUENTAS_COBRAR", prop: "Cabecera de la cuenta por cobrar generada por una factura a crédito. Guarda el total financiado y el saldo pendiente.", ov: {
        ID_PERSONA: "Deudor (cliente).", ID_COMPROBANTE: "Factura que originó la deuda (vínculo lógico).",
        TOTAL_A_PAGAR: "Monto total financiado (bienes + interés).", SALDO: "Saldo pendiente (= Σ cuotas vigentes).",
        ESTADO: "'PENDIENTE' / 'PAGADA' / 'ANULADA'.",
      } },
      { t: "CUENTAS_COBRAR_DET", prop: "Cuotas de la cuenta por cobrar. Composición de CUENTAS_COBRAR.", ov: {
        NRO_CUOTA: "Número de cuota (1..n).", FECHA_VENCIMIENTO: "Vencimiento de la cuota.",
        MONTO_CUOTA: "Importe de la cuota.", ESTADO: "'PENDIENTE' / 'PAGADA' / 'VENCIDA' / 'ANULADA'.",
      } },
      { t: "CAJA_CONF", prop: "Configuración lógica de una caja (punto de venta): vincula la caja con su oficina y su punto de expedición SET.", ov: {
        DESCRIPCION: "Nombre de la caja configurada.", ESTADO: "'A' activa.",
        PUNTO_EXPEDICION: "Punto de expedición SET; único por oficina.",
      } },
      { t: "CAJAS", prop: "Instancia de caja abierta por un empleado (sesión de caja). Regla: un empleado tiene a lo sumo una caja abierta.", ov: {
        ESTADO: "'A' abierta / 'C' cerrada.", FEC_APERTURA: "Momento de apertura.", FEC_CIERRE: "Momento de cierre/arqueo.",
        USU_APERTURA: "Usuario que abrió la caja.", USU_CIERRE: "Usuario que cerró la caja.",
        OBSERVACION: "Comentario del cierre/arqueo.",
      } },
      { t: "CAJA_MONEDAS", prop: "Saldos por moneda de cada caja (apertura, cierre y arqueo). PK compuesta (ID_CAJA, MONEDA).", ov: {
        MONTO_APERTURA: "Saldo declarado al abrir.", MONTO_CIERRE: "Saldo esperado al cerrar.",
        MONTO_DECLARADO: "Efectivo contado en el arqueo.", MONTO_DIFERENCIA: "Diferencia = declarado − esperado.",
        MONTO_CIERRE_PREV: "Saldo de cierre previo conservado como respaldo.",
      } },
      { t: "MOVIMIENTOS_CAJA", prop: "Movimientos de dinero de una caja: ingreso por venta, cobro de CxC, egreso y ajuste. También modela el recibo de dinero (numeración RC).", ov: {
        ID_CLIENTE: "Cliente asociado al movimiento.", ID_CAJA: "Caja donde se registra.",
        FECHA: "Momento del movimiento.", TOTAL_MONEDA_LOCAL: "Importe en moneda local (PYG).",
        MONEDA: "Guarda el texto 'PYG'.", ESTADO: "'A' caja abierta / 'C' caja cerrada (no activo/anulado).",
        TIPO: "'INGRESO_VENTA' / 'COBRO_CXC' / 'EGRESO' / 'AJUSTE'.", ID_COMPROBANTE: "Factura de contado que originó el ingreso.",
        USUARIO: "Cobrador que registró el movimiento.", NRO_RECIBO: "Número del recibo de dinero (RC).",
        ID_CUENTA_COBRAR_DET: "Cuota cobrada (COBRO_CXC).", ID_MOVIMIENTO_REVERSADO: "Movimiento compensado por un EGRESO de reverso.",
      } },
      { t: "DETALLE_MOVIMIENTO_CAJA", prop: "Desglose del movimiento por forma/método de pago (efectivo, tarjeta, transferencia…). Composición de MOVIMIENTOS_CAJA.", ov: {
        MONTO_LOCAL: "Importe en moneda local.", NRO_REFERENCIA: "Referencia de la transacción.",
        NRO_TARJETA: "Enmascarado de la tarjeta.",
      } },
      { t: "FORMAS_PAGO", prop: "Catálogo de formas de pago (efectivo / no efectivo).", ov: {
        REQUIERE_REFERENCIA: "'S' exige número de referencia.",
      } },
      { t: "METODOS_PAGO", prop: "Catálogo de métodos de pago concretos (Efectivo, Tarjeta, Transferencia…)." },
      { t: "MONEDAS", prop: "Catálogo de monedas. PYG es la moneda base (ES_LOCAL='S').", ov: {
        CODIGO_MONEDA: "Código de la moneda (p. ej. '1' = PYG).", ES_LOCAL: "'S' para la moneda base del sistema.",
      } },
      { t: "MOTIVOS_NOTA_CREDITO", prop: "Catálogo de motivos SIFEN de nota de crédito (devolución, descuento, ajuste, etc.)." },
      { t: "SOLICITUDES_NOTA_CREDITO", prop: "Cabecera del flujo de solicitud de nota de crédito (staging con aprobación previa a emitir la NC).", ov: {
        ESTADO: "Estado del workflow (solicitada, aprobada, rechazada).",
      } },
      { t: "SOLICITUD_NC_DETALLE", prop: "Líneas de la solicitud de nota de crédito (producto y cantidad a acreditar). Composición de SOLICITUDES_NOTA_CREDITO." },
      { t: "SOLICITUDES_REVERSO_COBRO", prop: "Cabecera del flujo de reverso de cobro (módulo oculto por parámetro; el histórico persiste).", ov: {
        ESTADO: "Estado del workflow de reverso.",
      } },
    ] },

  // =========================================================================
  { key: "compras", name: "Compras y Cuentas por Pagar",
    intro: "Ciclo de compra: proveedores, órdenes de compra, recepción de mercadería, comprobantes de proveedor, cuentas por pagar y órdenes de pago, más la lista de precios por proveedor.",
    tables: [
      { t: "PROVEEDORES", prop: "Datos de proveedor asociados a una persona (subtipo de PERSONAS). Define plazo de pago y categoría.", ov: {
        ID_PERSONA: "Persona que es el proveedor (PK y FK a PERSONAS).",
        ESTADO: "Estado del proveedor (activo/inactivo).", FECHA_REGISTRO: "Alta del proveedor.",
        CATEGORIA: "Categoría del proveedor.", PLAZO_PAGO_DIAS: "Días de plazo para el vencimiento de la CxP.",
      } },
      { t: "PROVEEDOR_CONTACTOS", prop: "Contactos de un proveedor (nombre, teléfono, correo, cargo)." },
      { t: "ORDENES_COMPRA", prop: "Cabecera de la orden de compra a un proveedor. Ciclo: Borrador, Pendiente de recepción, Completada, Rechazada, Anulada.", ov: {
        FECHA_ORDEN: "Fecha de la orden.", ESTADO: "B/P/C/X/A (borrador/pendiente/completada/rechazada/anulada).",
        TOTAL_ORDEN: "Importe total de la orden.", ID_APROBADOR: "Empleado que aprobó la orden.",
      } },
      { t: "DETALLE_ORDEN_COMPRA", prop: "Líneas de la orden de compra (producto, cantidad, precio). Composición de ORDENES_COMPRA.", ov: {
        CANTIDAD: "Cantidad solicitada.", PRECIO_UNITARIO: "Precio unitario acordado.", TOTAL_DETALLE: "Importe de la línea.",
      } },
      { t: "RECEPCIONES_COMPRA", prop: "Recepción de mercadería contra una orden de compra; dispara la entrada de stock.", ov: {
        FECHA_RECEPCION: "Fecha de la recepción.",
      } },
      { t: "DETALLE_RECEPCION_COMPRA", prop: "Líneas recibidas por recepción (cantidad efectivamente recibida por producto). Composición de RECEPCIONES_COMPRA.", ov: {
        CANTIDAD_RECIBIDA: "Unidades recibidas.",
      } },
      { t: "COMPROBANTES_PROVEEDOR", prop: "Factura o nota de crédito emitida por el proveedor y capturada por el sistema. Genera la cuenta por pagar cuando es a crédito.", ov: {
        TIPO_COMPROBANTE: "'FA' factura, 'NC' nota de crédito.", FECHA_EMISION: "Fecha de emisión del proveedor.",
        NRO_COMPROBANTE: "Número del comprobante del proveedor.", NRO_TIMBRADO: "Timbrado del proveedor.",
        TOTAL_COMPROBANTE: "Importe total del comprobante.", ESTADO: "R/PR/C/A (registrada/recepción parcial/completada/anulada).",
        FORMA_PAGO: "'1' crédito / '21' contado.", COD_MOTIVO: "Motivo SIFEN (en NC de compra).",
        ID_FAC_ORIGEN: "Factura de compra de origen (en NC de compra).",
      } },
      { t: "DETALLE_COMPROBANTE_PROV", prop: "Líneas del comprobante de proveedor. Composición de COMPROBANTES_PROVEEDOR.", ov: {
        CANTIDAD: "Cantidad.", PRECIO_UNITARIO: "Precio unitario.", TOTAL: "Importe de la línea.",
        ID_DETALLE_ORIGEN: "Línea de origen (en NC de compra).",
      } },
      { t: "CUENTAS_PAGAR", prop: "Cuenta por pagar generada por un comprobante de proveedor a crédito. Pago único (sin cuotas).", ov: {
        ID_COMPROBANTE: "Comprobante de proveedor que originó la deuda.", TOTAL_A_PAGAR: "Monto adeudado.",
        SALDO: "Saldo pendiente.", ESTADO: "PENDIENTE / PARCIAL / PAGADA / ANULADA.",
        FECHA_VENCIMIENTO: "Vencimiento = emisión + plazo de pago del proveedor.",
      } },
      { t: "ORDENES_PAGO", prop: "Orden de pago a proveedor. Se emite en Borrador (autoriza) y se Confirma (ejecuta el pago y baja el saldo de las CxP).", ov: {
        FECHA_EMISION: "Fecha de emisión de la orden.", FECHA_PAGO: "Fecha del pago.", TOTAL_PAGO: "Importe pagado.",
        ESTADO: "BORRADOR / CONFIRMADA / ANULADA.", USUARIO: "Usuario que gestiona la orden.",
        MOTIVO_ANULACION: "Motivo si se anula la orden.",
      } },
      { t: "ORDEN_PAGO_DET", prop: "Cuentas por pagar aplicadas en una orden de pago y el monto imputado a cada una. Composición de ORDENES_PAGO.", ov: {
        MONTO_APLICADO: "Monto imputado a la CxP.",
      } },
      { t: "PRODUCTO_PROVEEDORES", prop: "Lista de precios de compra: precio de un producto por proveedor, con vigencia.", ov: {
        ID_PERSONA: "Proveedor.", CODIGO_REFERENCIA: "Código del producto en el proveedor.",
        PRECIO: "Precio de compra.", FECHA_INICIO: "Inicio de vigencia.", FECHA_FIN: "Fin de vigencia.",
        ESTADO: "Estado del precio (activo/inactivo).",
      } },
      { t: "PRECIO_POR_CATEGORIA", prop: "Precio de venta de un producto por categoría de cliente, con vigencia.", ov: {
        CATEGORIA_CLIENTE: "Categoría de cliente a la que aplica.", PRECIO: "Precio de venta.",
        FECHA_VIGENCIA: "Fecha desde la que rige.",
      } },
      { t: "MARGEN_CATEGORIA", prop: "Margen (porcentaje) aplicado por categoría de producto y de cliente, con vigencia.", ov: {
        CATEGORIA_CLIENTE: "Categoría de cliente.", PORCENTAJE: "Margen porcentual.",
        FECHA_INICIO: "Inicio de vigencia.", FECHA_FIN: "Fin de vigencia.",
      } },
      { t: "AUDITORIA_PRODUCTO_PROVEEDOR", prop: "Bitácora de cambios de precio/estado en la lista de precios por proveedor.", ov: {
        PRECIO_ANTERIOR: "Precio antes del cambio.", PRECIO_NUEVO: "Precio luego del cambio.",
        ESTADO_ANTERIOR: "Estado previo.", ESTADO_NUEVO: "Estado nuevo.",
        TIPO_OPERACION: "Tipo de operación registrada.", FECHA_CAMBIO: "Momento del cambio.",
        USUARIO_CAMBIO: "Usuario que hizo el cambio.",
      } },
      { t: "CARGA_MASIVA_PP", prop: "Cabecera de una carga masiva de la lista de precios por proveedor (importación desde archivo).", ov: {
        FECHA_CARGA: "Fecha de la carga.", NOMBRE_ARCHIVO: "Archivo importado.",
        REGISTROS_TOTALES: "Filas totales del archivo.", REGISTROS_EXITOSOS: "Filas procesadas OK.",
        REGISTROS_ERROR: "Filas con error.", ESTADO_CARGA: "Estado del proceso de carga.",
      } },
      { t: "DETALLE_CARGA_MASIVA_PP", prop: "Filas de una carga masiva de precios y su resultado de procesamiento. Composición de CARGA_MASIVA_PP.", ov: {
        FILA_NUMERO: "Número de fila en el archivo.", PRECIO: "Precio importado.",
        ESTADO_PROCESAMIENTO: "Resultado del procesamiento de la fila.", MENSAJE_ERROR: "Detalle del error, si lo hubo.",
      } },
    ] },

  // =========================================================================
  { key: "inventario", name: "Inventario",
    intro: "Catálogo de productos, existencias por sucursal, kardex de movimientos, ajustes y transferencias de stock, ubicaciones físicas e inventario físico (conteo).",
    tables: [
      { t: "PRODUCTOS", prop: "Catálogo maestro de productos (categoría, marca, modelo, tipo de IVA).", ov: {
        CODIGO_PROVEEDOR: "Código de referencia del producto.", ACTIVO: "Indicador de vigencia (S/N).",
      } },
      { t: "CATEGORIAS_PRODUCTOS", prop: "Catálogo de categorías de productos." },
      { t: "MARCAS", prop: "Catálogo de marcas de productos." },
      { t: "STOCK_PRODUCTO", prop: "Existencia (on-hand) de un producto por oficina. Es el stock autoritativo (snapshot). PK compuesta (ID_PRODUCTO, ID_OFICINA).", ov: {
        CANTIDAD: "Cantidad disponible (on-hand).", STOCK_MAXIMO: "Nivel máximo objetivo.", STOCK_MINIMO: "Nivel mínimo (punto de reposición).",
      } },
      { t: "MOVIMIENTOS_STOCK", prop: "Kardex: movimientos de entrada/salida de stock por producto y oficina. No reconcilia la apertura (el stock inicial se cargó sin movimiento).", ov: {
        TIPO_MOVIMIENTO: "ENTRADA / SALIDA (puede venir en mayúscula mixta).", CANTIDAD: "Unidades del movimiento.",
        FECHA_MOVIMIENTO: "Fecha del movimiento.", REFERENCIA: "Referencia al documento que lo originó.",
        USUARIO: "Usuario del movimiento.", FECHA: "Fecha (negocio).", HORA: "Hora del movimiento.",
      } },
      { t: "AJUSTES_STOCK", prop: "Ajuste manual de existencias (entrada o salida) con su motivo.", ov: {
        TIPO_AJUSTE: "Tipo de ajuste.", CANTIDAD: "Unidades ajustadas.", TIPO_MOVIMIENTO: "ENTRADA / SALIDA.",
        FECHA: "Fecha del ajuste.", USUARIO: "Usuario que ajustó.", HORA: "Hora del ajuste.",
      } },
      { t: "TRANSFERENCIAS_STOCK", prop: "Transferencia de stock de un producto entre dos oficinas.", ov: {
        CANTIDAD: "Unidades transferidas.", FECHA: "Fecha de la transferencia.", USUARIO: "Usuario que transfirió.", HORA: "Hora.",
      } },
      { t: "INVENTARIO", prop: "Cabecera de un inventario físico (conteo) por oficina, con su flujo de creación, envío, aprobación y posteo.", ov: {
        NRO_DOCUMENTO: "Número del documento de inventario.", FECHA_INVENTARIO: "Fecha del conteo.",
        ESTADO: "Estado del flujo (borrador, enviado, aprobado, posteado, rechazado).",
      } },
      { t: "INVENTARIO_DETALLE", prop: "Líneas del inventario físico: stock de sistema vs. conteo físico y su diferencia. Composición de INVENTARIO.", ov: {
        STOCK_SISTEMA: "Existencia según el sistema al momento del conteo.", CANTIDAD_FISICA: "Cantidad contada físicamente.",
        DIFERENCIA: "Diferencia (física − sistema).",
      } },
      { t: "SECTORES", prop: "Sectores físicos de una oficina para ordenar el conteo y la ubicación de productos.", ov: {
        NOMBRE: "Nombre del sector.", ORDEN: "Orden de recorrido.",
      } },
      { t: "UBICACIONES", prop: "Ubicaciones dentro de un sector (posiciones de almacenamiento).", ov: {
        CODIGO: "Código de la ubicación.", ORDEN: "Orden de recorrido.",
      } },
      { t: "PRODUCTO_UBICACION", prop: "Asignación de un producto a una ubicación física dentro de una oficina/sector.", ov: {
        ORDEN_POSICION: "Orden de la posición.",
      } },
    ] },

  // =========================================================================
  { key: "reportes", name: "Reportes Gerenciales",
    intro: "Metas de negocio contra las cuales se miden los reportes gerenciales. El resto de los reportes se alimenta de vistas (no de tablas propias): ventas, cobros, inventario y compras.",
    tables: [
      { t: "METAS_VENTA", prop: "Meta de venta por vendedor o sucursal y mes (PERIODO). Base de comparación del dashboard de Ventas.", ov: {
        PERIODO: "Mes de la meta (primer día del mes).",
      } },
      { t: "METAS_COBRANZA", prop: "Meta de cobranza por sucursal y mes (PERIODO). Base de comparación del dashboard de Cobros.", ov: {
        PERIODO: "Mes de la meta (primer día del mes).",
      } },
    ] },

  // =========================================================================
  { key: "seguridad", name: "Seguridad y Personas",
    intro: "Modelo de personas (base de clientes, empleados y proveedores) y control de acceso basado en roles (RBAC): empleados, roles, privilegios y el mapa de recursos protegidos de la aplicación.",
    tables: [
      { t: "PERSONAS", prop: "Entidad base de toda persona física o jurídica del sistema (documento, nombres, contacto). Clientes, empleados y proveedores son subtipos.", ov: {
        NRO_DOCUMENTO: "Número de documento.", TIPO_DOCUMENTO: "Tipo de documento.", TIPO_PERSONA: "Física o jurídica.",
        PRIMER_NOMBRE: "Primer nombre.", PRIMER_APELLIDO: "Primer apellido / razón social.",
        CORREO: "Correo electrónico.", FECHA_REGISTRO: "Alta de la persona.",
      } },
      { t: "EMPLEADOS", prop: "Usuario del sistema (subtipo de PERSONAS). Guarda las credenciales, el control de acceso y el estado de bloqueo por intentos.", ov: {
        NOMBRE: "Nombre del empleado/usuario.", CARGO: "Cargo.", "CONTRASEÑA": "Hash de la contraseña.",
        CODIGO_USUARIO: "Nombre de usuario de acceso.", CORREO: "Correo del usuario.",
        SALT_CONTRASENA: "Sal criptográfica de la contraseña.", CONTRASENA_TEMP: "Contraseña temporal.",
        TOKEN_RESET: "Token de reseteo de contraseña.", TOKEN_EXPIRACION: "Vencimiento del token.",
        ACTIVO: "Indicador de vigencia (S/N).", INTENTOS_FALLIDOS: "Contador de intentos fallidos de login.",
      } },
      { t: "EMPLEADOS_ROLES", prop: "Asignación de roles a un empleado (relación N:M entre EMPLEADOS y ROLES).", ov: {
        FECHA_ASIGNACION: "Fecha de asignación del rol.",
      } },
      { t: "ROLES", prop: "Roles del sistema (agrupan privilegios).", ov: { NOMBRE_ROL: "Nombre del rol." } },
      { t: "PRIVILEGIOS", prop: "Privilegios atómicos que habilitan acciones/recursos.", ov: { CODIGO: "Código del privilegio." } },
      { t: "ROLES_PRIVILEGIOS", prop: "Privilegios que otorga cada rol (relación N:M entre ROLES y PRIVILEGIOS)." },
      { t: "RECURSOS", prop: "Mapa de seguridad de la app APEX: qué privilegio requiere cada página o componente.", ov: {
        APP_ID: "ID de la aplicación APEX.", PAGE_ID: "Número de página.",
        COMPONENT_STATIC_ID: "Identificador estático del componente protegido.", ACTIVO: "Indicador de vigencia (S/N).",
      } },
      { t: "CLIENTES", prop: "Datos de cliente asociados a una persona (subtipo de PERSONAS).", ov: {
        ID_PERSONA: "Persona que es el cliente (PK y FK a PERSONAS).", ESTADO: "Estado del cliente.",
        FECHA_REGISTRO: "Alta del cliente.", CATEGORIA_CLIENTE: "Categoría comercial del cliente.",
      } },
      { t: "DIRECCIONES", prop: "Direcciones de una persona (calle, ciudad, país, tipo).", ov: {
        DESCRIPCION: "Descripción de la dirección.", CALLE_PRINCIPAL: "Calle principal.", CALLE_SECUNDARIA: "Calle secundaria.",
        NRO_CASA: "Número de casa.", CODIGO_POSTAL: "Código postal.", TIPO: "Tipo de dirección.",
      } },
      { t: "TELEFONOS", prop: "Teléfonos de una persona.", ov: { TIPO: "Tipo de teléfono.", NRO_TELEFONO: "Número." } },
      { t: "DOCUMENTOS", prop: "Catálogo de tipos de documento de identidad.", ov: {
        DESCRIPCION: "Descripción del documento.", TIPO_DOCUMENTO: "Código del tipo de documento.",
      } },
    ] },

  // =========================================================================
  { key: "catalogos", name: "Catálogos base y configuración",
    intro: "Tablas transversales de configuración y referencia usadas por todos los módulos: oficinas (sucursales), parámetros del sistema, división geográfica, tipo de IVA y tipos de cambio.",
    tables: [
      { t: "OFICINAS", prop: "Sucursales/oficinas de la empresa. Su establecimiento SET es prerequisito fiscal para facturar.", ov: {
        DESCRIPCION: "Nombre de la sucursal.", ESTABLECIMIENTO_SET: "Código de establecimiento SET.",
      } },
      { t: "PARAMETROS", prop: "Parámetros configurables del sistema (reglas de negocio y datos de la empresa emisora). Cada parámetro es una clave con valor numérico o de texto.", ov: {
        TIPO_PARAMETRO: "Agrupador del parámetro (p. ej. EMPRESA, regla de negocio).", CLAVE: "Clave del parámetro.",
        VALOR_NUMERICO: "Valor numérico, si aplica.", VALOR_TEXTO: "Valor de texto, si aplica.",
        MES_APLICABLE: "Mes de aplicación (parámetros con vigencia).", ANO_APLICABLE: "Año de aplicación.",
        ACTIVO: "Indicador de vigencia (S/N).",
      } },
      { t: "APP_CONFIG", prop: "Configuración simple de la aplicación en pares clave-valor.", ov: {
        CLAVE: "Clave de configuración.", VALOR: "Valor.",
      } },
      { t: "TIPO_IVA", prop: "Catálogo de tipos de IVA (exento, 5%, 10%) con su porcentaje.", ov: {
        PORCENTAJE: "Porcentaje de IVA.",
      } },
      { t: "TIPOS_CAMBIO", prop: "Cotizaciones de cambio por fecha y par de monedas (compra/venta).", ov: {
        FECHA: "Fecha de la cotización.", COD_MONEDA_BASE: "Moneda base.", COD_MONEDA_COTIZADA: "Moneda cotizada.",
        FUENTE: "Fuente de la cotización.", TIPO_COMPRA: "Cotización compradora.", TIPO_VENTA: "Cotización vendedora.",
        REF_DIARIO: "Referencia diaria.", FECHA_UPDATED: "Última actualización.",
      } },
      { t: "PAISES", prop: "Catálogo de países." },
      { t: "DEPARTAMENTOS", prop: "Catálogo de departamentos (división geográfica de primer nivel)." },
      { t: "CIUDADES", prop: "Catálogo de ciudades, asociadas a un departamento." },
    ] },
];

module.exports = { MODULES };

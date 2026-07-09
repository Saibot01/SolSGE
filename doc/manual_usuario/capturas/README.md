# Capturas del Manual de Usuario — guía para el alumno

Acá van **las capturas de pantalla** que se embeben en el Manual de Usuario. El `build.js` las
toma automáticamente de esta carpeta: mientras un archivo **no exista**, en el `.docx` sale un
**recuadro `[FIGURA: …]`** en su lugar (placeholder). Apenas dejás el `.png` con el nombre exacto,
al re-generar el documento la captura reemplaza al recuadro. No hay que tocar el código.

## Convención de nombres

`NN_modulo_tarea_SS.png`

- `NN` — nº de capítulo del manual (`02` Acceso, `05` Facturación y Caja, …).
- `modulo` / `tarea` — identificador corto en minúsculas, sin espacios ni tildes.
- `SS` — secuencia del paso dentro de la tarea (`01`, `02`, …).

Ejemplos: `02_acceso_login_01.png`, `05_facturacion_contado_03.png`, `05_caja_apertura_01.png`.

## Cómo capturar (para que salgan consistentes)

- Navegador **maximizado**, **zoom 100%**, ancho estándar (idealmente ~1366–1440 px).
- Recortá al **contenido de la región** relevante (no toda la pantalla si sobra el cromo del navegador).
- Formato **PNG**. Usá **datos de demo** coherentes (los mismos de la defensa); evitá datos sensibles reales.
- Pantallas anchas (dashboards, documentos): captura completa; en el manual van en apaisado.

## Capturas que espera el piloto (Facturación y Caja)

El `build.js` referencia exactamente estos nombres. Entregalos y el documento los embebe solo:

| Archivo | Pantalla / momento a capturar |
|---|---|
| `02_acceso_login_01.png` | Pantalla de inicio de sesión (login), con el enlace *¿Olvidaste tu contraseña?*. |
| `02_acceso_reset_01.png` | Pantalla de restablecimiento de contraseña (definir la nueva clave). |
| `02_acceso_menu_01.png` | Pantalla principal con el menú de navegación desplegado. |

## Capturas que espera Ventas (capítulo 4)

| Archivo | Pantalla / momento a capturar |
|---|---|
| `04_presupuesto_lista_01.png` | **Ventas → Presupuesto**: lista de presupuestos con sus estados. |
| `04_presupuesto_alta_01.png` | Alta de presupuesto: cliente + grilla de productos/cantidad. |
| `04_presupuesto_aprobar_01.png` | **Ventas → Aprobación de Presupuestos**: aprobar/anular. |
| `04_presupuesto_documento_01.png` | Documento del presupuesto (impresión). |
| `04_presupuesto_vencidos_01.png` | **Ventas → Reportes → Presupuestos Anulados y Vencidos**. |
| `05_caja_apertura_01.png` | **Ventas → Caja → Apertura de Caja**: formulario de apertura con montos. |
| `05_facturacion_contado_01.png` | **Ventas → Proceso Ventas**: lista de comprobantes con el botón *Crear*. |
| `05_facturacion_contado_02.png` | Formulario de facturación: cliente/presupuesto y detalle cargados. |
| `05_facturacion_contado_03.png` | Forma de pago **Contado**: monto ingresado y vuelto calculado. |
| `05_facturacion_contado_04.png` | Documento de la factura (KuDE) generado. |
| `05_anulacion_solicitud_01.png` | **Ventas → Proceso Ventas**: solicitud de anulación con motivo. |
| `05_anulacion_aprobacion_01.png` | Aprobación/rechazo de la anulación (vista del Supervisor). |
| `05_estado_caja_01.png` | **Ventas → Caja → Estado de Caja**: saldos por moneda y movimientos. |
| `05_cierre_caja_01.png` | **Ventas → Caja → Cierre de Caja**: arqueo con el monto declarado. |
| `05_cierre_caja_02.png` | Documento de arqueo generado. |

## Capturas que espera Cobranzas (capítulo 6)

| Archivo | Pantalla / momento a capturar |
|---|---|
| `06_cobros_lista_01.png` | **Cobranzas → Cobros**: lista de cuentas por cobrar. |
| `06_cobros_cuotas_01.png` | Detalle de cuotas de una cuenta por cobrar (al abrir una cuenta). |
| `06_cobros_pago_01.png` | Cobro de Cuotas: método de pago, monto recibido y vuelto. |
| `06_cobros_recibo_01.png` | Documento del recibo de cobro generado. |
| `06_recibos_reimpresion_01.png` | **Cobranzas → Recibos de Cobro**: lista para reimprimir. |
| `06_cuenta_cliente_01.png` | Detalle de cuotas y saldo del cliente (misma vista que el detalle de cuotas). |

## Capturas que espera Notas de Crédito (capítulo 7)

| Archivo | Pantalla / momento a capturar |
|---|---|
| `07_nc_solicitar_01.png` | **Ventas → Proceso Ventas**: acción *Solicitar Nota de Crédito* sobre una factura. |
| `07_nc_solicitar_02.png` | Formulario de solicitud: motivo, tipo y grilla de líneas (Cantidad / Precio Nuevo). |
| `07_nc_lista_01.png` | **Ventas → Notas de Crédito**: lista de solicitudes. |
| `07_nc_aprobar_01.png` | Aprobar/rechazar la nota de crédito con el desglose. |
| `07_nc_documento_01.png` | Documento de la nota de crédito. |

## Capturas que espera Compras (capítulo 8)

| Archivo | Pantalla / momento a capturar |
|---|---|
| `08_oc_alta_01.png` | **Compras y Pagos → Orden de Compra**: alta con proveedor y productos. |
| `08_oc_aprobar_01.png` | **Compras y Pagos → Aprobación de Órdenes de Compra**. |
| `08_oc_recepcion_01.png` | **Compras y Pagos → Recepción de Orden de Compra**. |
| `08_factura_prov_01.png` | **Compras y Pagos → Proceso de Compras**: registro de factura de proveedor (proveedor, timbrado, condición). |
| `08_op_generar_01.png` | **Compras y Pagos → Deuda a Proveedores**: generar orden de pago. |
| `08_op_resolver_01.png` | **Compras y Pagos → Órdenes de Pago → Resolver**: confirmar pago / anular. |
| `08_op_documento_01.png` | Documento de la orden de pago. |
| `08_nc_compra_01.png` | **Compras y Pagos → Nota de Credito Proveedor**: captura de la NC. |

## Capturas que espera Inventario (capítulo 9)

| Archivo | Pantalla / momento a capturar |
|---|---|
| `09_existencias_01.png` | **Productos e Inventario → Reporte Inventario → Existencias**. |
| `09_movimientos_01.png` | **Productos e Inventario → Reporte Inventario → Movimiento de Stock**. |
| `09_conteo_01.png` | **Proceso de Inventario / Conteo Físico**: conteo de productos. |
| `09_revision_01.png` | **Productos e Inventario → Revisión**: aprobación del inventario. |

## Capturas que espera Documentos fiscales (capítulo 10)

| Archivo | Pantalla / momento a capturar |
|---|---|
| `10_kude_documento_01.png` | Documento (KuDE) de un comprobante (factura, recibo o NC). |
| `10_talonarios_01.png` | **Configuración → Talonarios**: alta/edición de talonario. |

## Capturas que espera Reportes gerenciales (capítulo 11)

| Archivo | Pantalla / momento a capturar |
|---|---|
| `11_dashboard_01.png` | Un dashboard gerencial (Ventas, Cobros, Inventario o Compras) con KPIs y gráficos. |
| `11_informe_01.png` | Un generador de informe (con sus filtros). |
| `11_metas_01.png` | ABM de metas (Metas de Venta o Metas de Cobranza). |

## Capturas que espera Administración (capítulo 12)

| Archivo | Pantalla / momento a capturar |
|---|---|
| `12_empleados_01.png` | **Personas → Empleados**: alta/edición de empleado con su rol. |
| `12_reset_01.png` | Empleado abierto con el botón *Restablecer / Reenviar credenciales* y el enlace. |
| `12_roles_01.png` | **Seguridad → Roles - Privilegios**: asignación de privilegios. |
| `12_config_01.png` | **Configuración**: un catálogo (Monedas, Formas de Pago, Planes de Cuota, etc.). |
| `12_cajas_01.png` | **Configuración de Cajas** (u **Oficinas**): configuración de una caja/sucursal. |

> Si el nombre real de alguna pantalla o el orden de un paso no coincide con lo redactado, avisá:
> ajustamos el texto contra la app en vivo (la app es la fuente de verdad, nunca inventamos pasos).

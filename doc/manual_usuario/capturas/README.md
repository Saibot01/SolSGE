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

> Si el nombre real de alguna pantalla o el orden de un paso no coincide con lo redactado, avisá:
> ajustamos el texto contra la app en vivo (la app es la fuente de verdad, nunca inventamos pasos).

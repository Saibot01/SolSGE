# Plan de implementación — Módulo de Facturación + Caja

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace:** `WKSP_WORKPLACE`
**Schema de aplicación:** `WKSP_WORKPLACE`
**Estado del plan:** pendiente de aprobación (2026-06-06).

> Plan separado de `PLAN_VENTAS.md`. Aquel cubre el ciclo del **presupuesto**
> (`ORDENES_VENTA`); éste cubre la conversión del presupuesto en **factura**
> (`COMPROBANTES`) y todo lo relacionado a **caja** (apertura, cierre,
> movimientos). Las dependencias hacia `PLAN_VENTAS.md` se marcan como
> [PV-F#].

---

## 1. Objetivo

Cerrar el flujo end-to-end **Presupuesto Aprobado → Factura Contado → Stock
descontado → Movimiento registrado en la caja del cajero**, dejando el modelo
preparado para crédito sin habilitarlo todavía.

Esto implica:

- Endurecer la sesión de caja: 1 caja abierta por empleado, validada contra
  `:APP_USER`, con regla "una caja por día y cerrar antes de abrir nueva".
- Resolver el control de talonario/timbrado (vigencia, rango, atomicidad de
  numeración).
- Reescribir P67 para que el cajero **no elija** oficina/talonario libremente
  — se derivan de su caja abierta.
- Unificar el modelo de movimientos de caja renombrando `RECIBOS_COBRO` →
  `MOVIMIENTOS_CAJA` y extendiéndola para soportar venta contado, cobro CxC y
  egresos bajo un solo esquema maestro-detalle.
- Disparar el descuento de stock vía `MOVIMIENTOS_STOCK` al insertar
  `DETALLE_COMPROBANTE` (el trigger `TRG_ACTUALIZAR_STOCK_MOVIMIENTO` ya
  existente cubre la baja en `STOCK_PRODUCTO`).

Queda **fuera de alcance** de F8 y se difiere a F9:

- Venta a crédito (insertar `CUENTAS_COBRAR` + cuotas en `CUENTAS_COBRAR_DET`).
- Pantalla de cobro de cuotas (genera `MOVIMIENTOS_CAJA` `TIPO='COBRO_CXC'`).
- Pantalla de anulación de factura (se decidirá en otra pasada; en F8 la
  columna `ESTADO` queda solo como **display only** en P67).
- Egresos manuales de caja (vueltos grandes, devoluciones) — el modelo lo
  soporta pero no se construye UI ahora.

---

## 2. Estado actual relevado

### 2.1 Tablas implicadas

| Tabla | Rol | Notas |
|-------|-----|-------|
| `COMPROBANTES` | Cabecera de factura | `ID_COMPROBANTE PK, ID_CLIENTE NN, ID_OFICINA NN, ID_ORDEN_VENTA, TIPO_COMPROBANTE CHAR(2) NN, FECHA def SYSDATE, TOTAL_MONEDA_LOCAL NN, MONEDA def 'PYG', TIPO_CAMBIO, TOTAL_MONEDA_ORIGEN, FORMA_PAGO, ESTADO def 'A', ID_TALONARIO, NRO_COMPROBANTE, ID_PLAN_CUOTA, totales IVA, ID_METODO_PAGO`. |
| `DETALLE_COMPROBANTE` | Líneas de factura | `ID_DETALLE PK, ID_COMPROBANTE FK, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, TOTAL_LINEA, ID_TIPO_IVA, MONTO_IVA, PORCENTAJE_IVA`. |
| `CAJAS` | Sesión de caja | `ID_CAJA PK, ID_EMPLEADO NN, ESTADO ('A'/'C'/NULL), FEC_APERTURA, FEC_CIERRE, USU_APERTURA, USU_CIERRE, ID_CAJA_CONF, ID_OFICINA`. `USU_APERTURA` hoy siempre NULL (bug C1). |
| `CAJA_CONF` | Catálogo de cajas físicas | `ID_CAJA_CONF, DESCRIPCION, ESTADO, ID_OFICINA`. Hoy 1 fila (`Caja 1`, oficina 1). |
| `CAJA_MONEDAS` | Saldo apertura/cierre por moneda | `ID_CAJA, MONEDA, MONTO_APERTURA, MONTO_CIERRE`. |
| `RECIBOS_COBRO` | Cabecera de recibo (vacía) | Será **renombrada** a `MOVIMIENTOS_CAJA` (Opción C aprobada). |
| `DETALLE_RECIBO_COBRO` | Detalle por forma de pago (vacía) | Será **renombrada** a `DETALLE_MOVIMIENTO_CAJA`. |
| `TALONARIOS` | Numeración facturas | `ID_TALONARIO PK, ID_OFICINA NN, TIPO_COMPROBANTE NN, ESTABLECIMIENTO NN, PUNTO_EXPEDICION NN, NRO_INICIAL/ACTUAL/FINAL, TIMBRADO, FECHA_INICIO/FIN NN, ACTIVO def 'S'`. |
| `MOVIMIENTOS_STOCK` | Diario de stock | `TIPO_MOVIMIENTO ('ENTRADA'/'SALIDA')`. Se descuenta vía `TRG_ACTUALIZAR_STOCK_MOVIMIENTO`. |
| `CUENTAS_COBRAR` + `_DET` | Crédito (vacías) | Usadas recién en F9. |
| `EMPLEADOS` | Personas con `CODIGO_USUARIO` | El vínculo `EMPLEADOS.CODIGO_USUARIO = :APP_USER` es el que permite resolver "qué cajero soy". `EMPLEADOS` no tiene `ID_OFICINA` (decisión heredada de PV). |

### 2.2 Funciones/procedimientos existentes

| Objeto | Comentario |
|--------|------------|
| `FN_OBTENER_COMPROBANTE(p_id_oficina, p_tipo)` | Lee el talonario activo y arma el string `EST-PE-NRO` **sin reservar el número**. **No se elimina**: P70 (Proceso de Compras) la sigue usando. F8 agrega `FN_RESERVAR_NRO_COMPROBANTE` y P67 migra a la nueva. |
| `CERRAR_CAJA(p_id_caja, p_usuario)` | Cierra `CAJAS`, calcula `MONTO_CIERRE = MONTO_APERTURA + SUM(RECIBOS_COBRO.TOTAL_MONEDA_ORIGEN)` por moneda, marca recibos `ESTADO='C'`. **Bug C7**: no contempla `COMPROBANTES`. Será reescrito post-renombre. |
| `TRG_FACTURA_ORDEN` | Endurecido en [PV-F4]. AFTER INSERT en `COMPROBANTES`: si `ID_ORDEN_VENTA` no es NULL y la transición no es válida, levanta error; si es válida hace `UPDATE ORDENES_VENTA SET ESTADO='FACTURADO'`. |
| `TRG_OV_LIBERA_RESERVA` | [PV-F4]. Hoy libera reservas al pasar a `ANULADO`/`VENCIDO`. **Hay que extender a `FACTURADO`** en F8.A. |
| `TRG_ACTUALIZAR_STOCK_MOVIMIENTO` | AFTER INSERT en `MOVIMIENTOS_STOCK`. Hace upsert de `STOCK_PRODUCTO` y respeta tipo `ENTRADA`/`SALIDA`. **No tocar**. |
| `TRG_MOV_STOCK_DETALLE` | **AFTER INSERT en `DETALLE_COMPROBANTE` cuando COMPROBANTES.ESTADO='A' AND TIPO='FA'**: inserta `MOVIMIENTOS_STOCK SALIDA` y valida stock. **Esto ya cubre el descuento al facturar** — no es necesario crear `TRG_COMPROBANTE_STOCK`. |
| `TRG_INS_CUENTAS_COBRAR` | **AFTER INSERT en `COMPROBANTES` cuando FORMA_PAGO='1'**: lee `PLANES_CUOTA`, genera `CUENTAS_COBRAR` (con interés) + N filas `CUENTAS_COBRAR_DET`. **F9 backend ya está hecho** — el alcance de F9 se reduce a UI de cobro. |
| `TRG_ACTUALIZAR_STOCK_FACTURA` | AFTER INSERT en `COMPROBANTES` cuando `ESTADO='A' AND TIPO='FA'`. Itera `DETALLE_COMPROBANTE` para descontar stock, pero como corre en AFTER INSERT de la **cabecera**, el detalle aún está vacío → no hace nada. **Roto en la práctica** pero ENABLED. **F8 lo dropea** para evitar trampas futuras (si alguien hace UPDATE ESTADO='A' después del detalle, descontaría stock duplicado contra `TRG_MOV_STOCK_DETALLE`). |
| `TRG_CERRAR_CAJA_CONF` | AFTER UPDATE de `ESTADO` en `CAJA_CONF`: si pasa a 'C' cierra la sesión `CAJAS` abierta. Semántica confusa pero no rompe nada; queda como deuda menor. |
| `INVENTARIO_PKG` | Paquete de inventario físico (BORRADOR/ENVIADO/APROBADO). Usa `MOVIMIENTOS_STOCK` para ajustes — **no toca** `COMPROBANTES` ni `RECIBOS_COBRO`. Sin impacto en F8. |
| `STOCK_PRODUCTO_T` | Trigger BIDU autogenerado por APEX en `STOCK_PRODUCTO`, body `null;`. **No-op**, sin impacto. |
| `TRG_STOCK_CONFIG_BIU` | BEFORE INSERT OR UPDATE OF `STOCK_MAXIMO,STOCK_MINIMO` en `STOCK_PRODUCTO`. Audita `FECHA_*` y `USUARIO_*` solo cuando cambian max/min. **No interfiere** con el UPDATE de `CANTIDAD` que dispara `TRG_ACTUALIZAR_STOCK_MOVIMIENTO`. |
| `SECURITY_PKG` | Paquete `VALID`. Función `security_pkg.can_access(:APP_ID,:APP_USER,page_id,NULL)` se usa en condiciones de menú. No tocar. |
| `JOB_VENCER_PRESUPUESTOS` | **No existe** en `USER_SCHEDULER_JOBS` (deuda de [PV-F2], no de F8/F9). El UPDATE `ESTADO='VENCIDO'` no corre automáticamente; sigue siendo manual hasta que se cree el job. |

### 2.3 Páginas APEX involucradas

#### Caja + Facturación (F8)

| Pag. | Nombre | Rol | Estado F8 |
|------|--------|-----|-----------|
| 61 | Cierre de Caja | Modal: select empleado + caja, llama `cerrar_caja` | a refactorizar (bugs C3/C4) |
| 62 | Lista de Cajas | IR sobre `CAJAS` | revisar filtro default |
| 63 | Configuración de Cajas | IR sobre `CAJA_CONF` | sin cambios |
| 64 | Form `CAJA_CONF` | Form | sin cambios |
| 65 | Apertura de Caja | Form `CAJAS` + IG `CAJA_MONEDAS` | a refactorizar (bugs C1–C6) |
| 66 | Proceso Ventas (lista) | IG sobre `COMPROBANTES` | fix LOV (B15) + filtro default |
| 67 | Proceso Ventas (form) | Form `COMPROBANTES` + IG `DETALLE_ORDEN` | rediseñado completo |
| 70 | Proceso de Compras (form) | Form `COMPROBANTES_PROVEEDOR` | **no tocar en F8** — sigue usando `FN_OBTENER_COMPROBANTE`. Futura F10. |
| 96 | Documento Factura | Modal print | sin cambios |

#### Cobros (F9 — ya hay UI parcial)

| Pag. | Nombre | Rol | Estado F9 |
|------|--------|-----|-----------|
| 93 | Cobros/Pagos | **Placeholder huérfano** (solo breadcrumb, 38 líneas) | deuda (CC8) — link a P95 o eliminar |
| 95 | **Cobros** | IR sobre `CUENTAS_COBRAR`, link a P99 | reusar; agregar badges, filtros |
| 98 | Cobros de Cuotas | Form `CUENTAS_COBRAR` modal | **redundante** con P95, sin entry de menú — eliminar (CC7) |
| 99 | **Detalle de Cuotas** | IG sobre `CUENTAS_COBRAR_DET` (filtrado por `P99_ID_CXC`), link a P100 | reusar; agregar badges por estado |
| 100 | **Cobro de Cuotas** | Form `CUENTAS_COBRAR_DET` modal — hoy **CRUD genérico que solo cambia ESTADO** | **rediseñar completo**: registrar cobro real (movimientos de caja + bajar saldo + reservar NRO_RECIBO) |
| 119 | **Documento Recibo** (nueva) | Modal print sobre `V_RECIBOS_COBRO` | crear en F9.F. Análoga a P6/P96. |

### 2.4 Bugs detectados

#### Bugs de Facturación (P66/P67)

| # | Descripción | Severidad |
|---|-------------|-----------|
| **B1** | LOV `P67_ID_ORDEN_VENTA` filtra `ESTADO='Pendiente'` (mixed case). Tras [PV-F4] todo es `PENDIENTE`/`APROBADO`/… → devuelve 0 filas. Además debe ser `APROBADO`. | Crítico |
| **B2** | Talonarios todos vencidos antes de F8. **Mitigado** en preparación previa: extendidos a 2027-12-31. | Crítico → Resuelto |
| **B3** | `Validacion de Caja` (BEFORE_HEADER) tiene comentado `EP.CODIGO_USUARIO = &APP_USER`. Cualquier vendedor puede facturar si existe cualquier caja con `ESTADO='A'`. | Crítico |
| **B4** | `UPDATE TALONARIOS SET NRO_ACTUAL=NRO_ACTUAL+1 WHERE TIPO_COMPROBANTE=:P67_TIPO_COMPROBANTE` incrementa **todos** los talonarios del tipo si hay >1. | Crítico |
| **B5** | Race condition: el nro se lee en DA (sin lock) y se incrementa en submit. Dos cajeros pueden obtener el mismo número. | Crítico |
| **B6** | `FN_OBTENER_COMPROBANTE` revienta con TOO_MANY_ROWS si hay >1 talonario activo por (oficina,tipo). | Alto |
| **B7** | IG `Detalle_Venta` insertable hace INSERT/UPDATE/DELETE contra `DETALLE_ORDEN` al facturar — efecto colateral grosero sobre el presupuesto. | Crítico |
| **B8** | Doble IG redundante (`Detalle_Venta` sin IVA + `Detalle_V` con IVA). JS y DAs inconsistentes entre ambas. | Alto |
| **B9** | Sin descuento de stock al facturar. `MOVIMIENTOS_STOCK` no se toca; reservas quedan `VIGENTE`. | Crítico |
| **B10** | Sin registro de movimiento de caja al facturar (ni `RECIBOS_COBRO` ni `CAJA_MONEDAS`). El cierre de caja siempre da 0 ingresos. | Crítico |
| **B11** | `P67_ID_TALONARIO` editable libre — el cajero elige talonario de cualquier oficina. | Alto |
| **B12** | `P67_ID_OFICINA` editable libre. | Alto |
| **B14** | `P67_TIPO_COMPROBANTE` text field libre con `cMaxlength=1` (BD acepta CHAR(2)) sin LOV. Hoy igual graba `FA`/`NC` correctamente porque APEX usa `REGION_SOURCE_COLUMN`, pero el campo visible truncaría a 1 si el usuario escribiera. Debe derivarse del talonario y pasar a Display Only en F8.D. | Alto |
| **B15** | Columna `ID_ORDEN_VENTA` del IG P66 usa LOV compartida `ORDENES_VENTA.ESTADO` (lov_id 12151050193730169). Muestra el estado en lugar del id. | Alto |
| **B16** | Cursor `Detalle Factura Cursor` no valida `P67_ID_ORDEN_VENTA IS NOT NULL` ni la coherencia con la orden. | Crítico |
| **B17** | No valida `MONTO_PAGO >= TOTAL` para contado (sólo VUELTO ≥ 0 vía DA cliente, fácil de saltar). | Alto |
| **B18** | `P67_NEW` item de debug con default `Valor recibido: &P67_ID_ORDEN_VENTA.` quedó en producción. | Bajo |

> **B19 retirado del alcance de F8** (decisión 2026-06-06): la columna
> `P67_ESTADO` queda como display only en F8; la pantalla de anulación de
> factura se diseñará en otro plan.

#### Bugs de Caja (P61/P65)

| # | Descripción | Severidad |
|---|-------------|-----------|
| **C1** | `P65_USU_APERTURA` hidden sin default → siempre NULL. | Alto |
| **C2** | `P65_FEC_APERTURA` editable como date picker — cajero puede mentir la fecha. | Alto |
| **C3** | `P65_ID_EMPLEADO` libre — cualquiera puede abrir caja a nombre ajeno. | Alto |
| **C4** | `P61` pasa `:P61_EMPLEADO` (ID NUMBER) al parámetro `p_usuario VARCHAR2` de `cerrar_caja` → `USU_CIERRE` queda con el id ("61") en lugar del código de usuario. | Alto |
| **C5** | Sin constraint "1 caja abierta por empleado". | Alto |
| **C6** | Sin control "una caja por día / cerrar la anterior antes de abrir". | Alto |
| **C7** | `cerrar_caja` calcula cierre sólo desde `RECIBOS_COBRO` (vacía). Ignora `COMPROBANTES`. | Crítico |
| **C8** | `TRG_CERRAR_CAJA_CONF` acopla deshabilitar catálogo con cerrar sesión. Confuso. | Bajo (deuda) |
| **C9** | `P63` permite editar `CAJA_CONF.ESTADO` como text libre. | Bajo |
| **C10** | El cajero no ve "mi caja abierta hoy" como contexto en P66/P67. | Bajo |

#### Bugs de Cobros (P93/P95/P98/P99/P100) — alcance F9

| # | Descripción | Severidad |
|---|-------------|-----------|
| **CC1** | **P100 es CRUD genérico**: solo cambia `ESTADO='PAGADO'`. **No inserta `MOVIMIENTOS_CAJA`, no baja `CUENTAS_COBRAR.SALDO`, no exige forma de pago, no valida caja abierta.** No hay cobro real. | Crítico |
| **CC2** | P100 permite editar `MONTO_CUOTA`, `FECHA_VENCIMIENTO`, `NRO_CUOTA`, `ID_CXC` libremente. Cajero podría marcar una cuota como pagada con monto = 1. | Crítico |
| **CC3** | P100 permite DELETE de cuota — rompe el plan completo. | Alto |
| **CC4** | P100 `P100_ID_CXC` LOV mal asignado: usa `CUENTAS_COBRAR.ESTADO` (mismo patrón que B15 en P67). | Alto |
| **CC5** | `P100_ESTADO` LOV estático "PENDIENTE,PAGADO" — falta `VENCIDA`. | Bajo |
| **CC6** | P99 no muestra historial de pagos por cuota. | Bajo |
| **CC7** | **P98 "Cobros de Cuotas"** parece duplicar P95; sin entry de menú; posiblemente huérfana. | Medio |
| **CC8** | **P93 "Cobros/Pagos" placeholder vacío** (38 líneas, solo breadcrumb), igual problema que P30 en PV. | Bajo (deuda) |
| **CC9** | Header "Cobros" del menú apunta a P93 placeholder, no a P95. | Medio (UX) |

### 2.5 Datos vivos al inicio de F8 (2026-06-06)

| Cosa | Estado |
|------|--------|
| Presupuestos `APROBADO` listos para facturar | 2 (IDs 183 y 203) |
| Talonarios activos vigentes | **3** (`ID_TALONARIO=1` FA, `=21` NC, `=41` RC, los tres oficina 1, vigentes hasta 2027-12-31). FA y NC extendidos en prep previa, RC creado en prep previa. |
| Cajas con `ESTADO='A'` | **0** (la 2, dato sucio desde 2025-05-29, fue **cerrada administrativamente por SQL** el 2026-06-06 — `USU_CIERRE='ADMIN'`, observación grabada) |
| Cajas con `ESTADO=NULL` | 2 (IDs 41 y 42, sesiones nunca cerradas correctamente; deuda menor, no rompen la `UQ_CAJA_ABIERTA_EMP` parcial porque ese índice filtra `WHERE ESTADO='A'`) |
| `RECIBOS_COBRO` | 0 filas |
| `CAJA_CONF` | 1 (`Caja 1`, oficina 1) |
| `CUENTAS_COBRAR` | **1 fila**: `ID_CXC=2`, persona 81 (TCASCO), comprobante 46, total 4.704.151, saldo 4.704.151, `ESTADO='PENDIENTE 2\n'` (texto sucio con salto de línea — deuda menor, se limpia en F9.A) |
| `CUENTAS_COBRAR_DET` | **6 cuotas**: 4 `PENDIENTE`, 2 con otro estado (caso real para test F9). |
| `EMPLEADOS con CODIGO_USUARIO` | 4 mapeados: `TCASCO` (id 81), `CBARRIOS` (61), `FPAREDES` (141), `NCACERES` (192). |

### 2.6 Pre-check de dependencias APEX + BD (ejecutado 2026-06-06)

Búsqueda cruzada de referencias a los objetos que F8 toca o renombra:

| Objeto | Referenciado por (APEX) | Referenciado por (BD) | Conclusión |
|--------|-------------------------|------------------------|------------|
| `RECIBOS_COBRO` | **ninguno** (grep en `apex-learn` + `apex-work`) | `CERRAR_CAJA` | Renombre seguro; basta recompilar `cerrar_caja` v2. |
| `DETALLE_RECIBO_COBRO` | **ninguno** | **ninguno** | Renombre seguro. |
| `FN_OBTENER_COMPROBANTE` | `page_00067.sql` (P67 — facturación) y `page_00070.sql` (P70 — **Proceso de Compras** sobre `COMPROBANTES_PROVEEDOR`) | — | Se mantiene viva. P67 migra a `FN_RESERVAR_NRO_COMPROBANTE`; P70 sigue usándola. Eventual unificación queda para F10-Compras. |
| `COMPROBANTES` (INSERT) | — | `TRG_FACTURA_ORDEN`, `TRG_INS_CUENTAS_COBRAR`, `TRG_ACTUALIZAR_STOCK_FACTURA` | El orden de procesos en P67 importa: ver §4 F8.D. |
| `DETALLE_COMPROBANTE` (INSERT) | — | `TRG_MOV_STOCK_DETALLE` | Stock ya descontado automáticamente. |
| `CAJAS`, `CAJA_MONEDAS`, `TALONARIOS` | (las páginas P61/P63/P65 ya conocidas) | `CERRAR_CAJA`, `FN_OBTENER_COMPROBANTE`, `TRG_CERRAR_CAJA_CONF` | Sin sorpresas. |
| `CUENTAS_COBRAR`, `CUENTAS_COBRAR_DET` | **P95, P98, P99, P100** (módulo de cobros — ver §2.3) | `TRG_INS_CUENTAS_COBRAR` | UI parcial ya existe. F9 los rediseña (CC1–CC9). |

### 2.7 Revisión final ejecutada 2026-06-06

Cross-check completo vs BD vs export APEX. Resumen:

- **28 tablas** referenciadas en el plan: todas existen en `WKSP_WORKPLACE`.
- **9 funciones/procedures** referenciados: todos existen y `VALID`.
- **9 triggers** existentes referenciados: todos `ENABLED` y `VALID`.
- **17 páginas APEX** referenciadas (P6, P61–P67, P70, P93–P100): todas existen. P119 no existe (correcto — se crea en F9.F).
- **`SECURITY_PKG`**: existe y `VALID`. Las condiciones de menú con `security_pkg.can_access` siguen funcionando.
- **Sin colisiones** de nombre para `MOVIMIENTOS_CAJA`, `DETALLE_MOVIMIENTO_CAJA`, `V_TALONARIOS_DISPONIBLES`, `V_RECIBOS_COBRO`.
- **Sin índice previo** `UQ_CAJA_ABIERTA_EMP` — el create del plan es seguro.
- **Conexión APP_USER ↔ EMPLEADOS.CODIGO_USUARIO**: 4 mapeos vivos (TCASCO/CBARRIOS/FPAREDES/NCACERES).
- Ajustes mínimos al plan derivados de la revisión: `COMPROBANTES.TIPO_COMPROBANTE` corregido a CHAR(2); F9.A suma CKs y limpieza del dato sucio `'PENDIENTE 2\n'`; documentados triggers inocuos sobre `STOCK_PRODUCTO`; deuda externa del `JOB_VENCER_PRESUPUESTOS` anotada.

---

## 3. Decisiones tomadas

| # | Decisión |
|---|----------|
| 1 | **Modelo movimientos de caja = Opción C.** Renombrar `RECIBOS_COBRO → MOVIMIENTOS_CAJA` y `DETALLE_RECIBO_COBRO → DETALLE_MOVIMIENTO_CAJA`. Extender con `TIPO`, `ID_COMPROBANTE`, `USUARIO`. Mantener el detalle como maestro-detalle por forma de pago — calza con la sugerencia del profesor. |
| 2 | **F8 sólo cubre venta CONTADO.** La opción `FORMA_PAGO=1` (Crédito) queda **visible** en el LOV de P67 (sin ocultar ni cartel) pero el flujo de generar `CUENTAS_COBRAR` es de F9. Si se elige Crédito en F8 → no se genera movimiento de caja (la factura queda emitida con `FORMA_PAGO=1` sin CxC asociado — se considerará deuda y se completa en F9). |
| 3 | **Origen presupuesto obligatorio.** P67 no permite emitir factura sin `ID_ORDEN_VENTA`. Las "facturas libres" se discontinúan. |
| 4 | **1 caja abierta por empleado a la vez.** Constraint vía índice único parcial. |
| 5 | **La caja debe cerrarse en su día.** No bloqueamos múltiples cajas del mismo día siempre que las anteriores estén cerradas. Si una caja quedó abierta de un día anterior, hay que cerrarla antes de abrir hoy. La factura solo se permite contra una caja del día actual (validado en P67). El trigger `TRG_CAJA_UNA_POR_DIA` (mal nombrado pero mantengo el nombre) chequea solo "no hay otra caja abierta del empleado". |
| 6 | **Cajero == empleado con `CODIGO_USUARIO`.** Resolver siempre con `EMPLEADOS.CODIGO_USUARIO = :APP_USER`. `USU_APERTURA` / `USU_CIERRE` guardan el `CODIGO_USUARIO`, no el id. |
| 7 | **Talonario derivado, no elegido.** El cajero no elige `ID_TALONARIO`. P67 muestra solo los talonarios vigentes de su oficina; si hay más de uno, lo elige automáticamente el de menor `ID_TALONARIO` (o el activo más reciente — a definir, ver §6 R5). |
| 8 | **`P67_ESTADO`** queda como **display only** en F8. La pantalla de anulación de factura se trata en otro plan, fuera de F8. |
| 9 | **Mantener `TRG_CERRAR_CAJA_CONF`** sin tocar (deuda menor — C8). |
| 10 | **`FN_OBTENER_COMPROBANTE` se REESCRIBE in-place** (no se crea nueva función). En la versión nueva el `UPDATE NRO_ACTUAL` queda dentro de la función con `FOR UPDATE` — atómica. Confirmado por el PO que P70 (Compras) **carga el nro de comprobante manualmente y no usa la función en la práctica**, así que reescribirla es seguro. Esto colateralmente arregla los bugs B4/B5/B6. |
| 14 | **Camino A para documento de recibo**: `MOVIMIENTOS_CAJA` lleva las columnas del documento (`NRO_RECIBO`, `ID_TALONARIO_RECIBO`, `FECHA_EMISION_RECIBO`, `ID_CUENTA_COBRAR_DET`). El recibo se imprime desde `V_RECIBOS_COBRO` (vista filtrada `TIPO='COBRO_CXC'`). Solo aplica a cobros de CxC; en venta contado el documento de pago es la factura. |
| 15 | **1 cuota = 1 recibo** en F9 (en principio). Si más adelante se necesita cobrar varias cuotas con un solo recibo, se agrega tabla puente `MOVIMIENTO_CXC`. |
| 16 | **Talonario `RC`** cargado en BD (ID 41, oficina 1, vigente 2025-01-01 → 2027-12-31). Ver §10. |
| 11 | **Crédito ya implementado a nivel BD.** El trigger `TRG_INS_CUENTAS_COBRAR` genera `CUENTAS_COBRAR` + cuotas automáticamente cuando `COMPROBANTES.FORMA_PAGO='1'`. Por eso F8 no necesita lógica adicional para crédito — basta con que el cajero elija forma de pago Crédito y plan de cuotas en P67. El alcance de F9 se reduce a: pantalla de cobro de cuotas. |
| 12 | **Drop de `TRG_ACTUALIZAR_STOCK_FACTURA`** en F8.A. Está activo pero roto (lee `DETALLE_COMPROBANTE` en AFTER INSERT de cabecera). Mantenerlo es trampa: si en el futuro alguien hace UPDATE `COMPROBANTES.ESTADO='A'` después de insertar el detalle, descontaría stock duplicado contra `TRG_MOV_STOCK_DETALLE`. |
| 13 | **No se crea `TRG_COMPROBANTE_STOCK`** (estaba planeado en el draft anterior). El existente `TRG_MOV_STOCK_DETALLE` ya descuenta stock al insertar `DETALLE_COMPROBANTE` con filtro `ESTADO='A' AND TIPO='FA'`. |

---

## 4. Diseño por feature

### Feature 8 — Facturación contado de presupuesto

Dependencias: [PV-F4] estados ✅, [PV-F2] caducidad ✅, [PV-F5] aprobación ✅.

#### F8.A — Backend BD (`db/F8_facturacion.sql`)

Script idempotente. Pasos:

**Paso 1 — Modelo de movimientos de caja (Opción C + Camino A para documento)**

```sql
-- Las tablas están vacías; rename limpio
RENAME WKSP_WORKPLACE.RECIBOS_COBRO        TO MOVIMIENTOS_CAJA;
RENAME WKSP_WORKPLACE.DETALLE_RECIBO_COBRO TO DETALLE_MOVIMIENTO_CAJA;

-- Extender el maestro: dimensión "movimiento contable"
ALTER TABLE MOVIMIENTOS_CAJA ADD (
  TIPO            VARCHAR2(20) DEFAULT 'INGRESO_VENTA' NOT NULL,
  ID_COMPROBANTE  NUMBER NULL,
  USUARIO         VARCHAR2(60) DEFAULT NV('APP_USER')
);

-- Extender el maestro: dimensión "documento recibo" (solo se llena para TIPO='COBRO_CXC')
ALTER TABLE MOVIMIENTOS_CAJA ADD (
  NRO_RECIBO              VARCHAR2(20),
  ID_TALONARIO_RECIBO     NUMBER,
  FECHA_EMISION_RECIBO    DATE,
  ID_CUENTA_COBRAR_DET    NUMBER
);

ALTER TABLE MOVIMIENTOS_CAJA ADD CONSTRAINT FK_MOVCAJA_COMP
  FOREIGN KEY (ID_COMPROBANTE) REFERENCES COMPROBANTES(ID_COMPROBANTE);
ALTER TABLE MOVIMIENTOS_CAJA ADD CONSTRAINT FK_MOVCAJA_TALONARIO
  FOREIGN KEY (ID_TALONARIO_RECIBO) REFERENCES TALONARIOS(ID_TALONARIO);
ALTER TABLE MOVIMIENTOS_CAJA ADD CONSTRAINT FK_MOVCAJA_CXC_DET
  FOREIGN KEY (ID_CUENTA_COBRAR_DET) REFERENCES CUENTAS_COBRAR_DET(ID_DETALLE);
ALTER TABLE MOVIMIENTOS_CAJA ADD CONSTRAINT CK_MOVCAJA_TIPO
  CHECK (TIPO IN ('INGRESO_VENTA','COBRO_CXC','EGRESO','AJUSTE'));
ALTER TABLE MOVIMIENTOS_CAJA ADD CONSTRAINT CK_MOVCAJA_ESTADO
  CHECK (ESTADO IN ('A','C'));
-- Regla: si es COBRO_CXC el recibo es obligatorio; si no, debe quedar NULL
ALTER TABLE MOVIMIENTOS_CAJA ADD CONSTRAINT CK_MOVCAJA_RECIBO
  CHECK (
    (TIPO = 'COBRO_CXC' AND NRO_RECIBO IS NOT NULL AND ID_TALONARIO_RECIBO IS NOT NULL
     AND FECHA_EMISION_RECIBO IS NOT NULL AND ID_CUENTA_COBRAR_DET IS NOT NULL)
    OR
    (TIPO <> 'COBRO_CXC' AND NRO_RECIBO IS NULL AND ID_TALONARIO_RECIBO IS NULL
     AND FECHA_EMISION_RECIBO IS NULL AND ID_CUENTA_COBRAR_DET IS NULL)
  );
```

**Paso 2 — Hardening de `CAJAS`**

```sql
-- Ya no permitir ESTADO arbitrario; los NULL históricos se conservan como están
-- Constraint diferida (porque hay filas con NULL)
ALTER TABLE CAJAS ADD CONSTRAINT CK_CAJAS_ESTADO
  CHECK (ESTADO IS NULL OR ESTADO IN ('A','C'));

-- Sólo una caja abierta por empleado
CREATE UNIQUE INDEX UQ_CAJA_ABIERTA_EMP
  ON CAJAS (ID_EMPLEADO)
  WHERE ESTADO = 'A';
```

**Paso 3 — Funciones nuevas**

```sql
-- Caja abierta del usuario logueado (NULL si ninguna)
CREATE OR REPLACE FUNCTION FN_CAJA_ABIERTA_USUARIO (
  p_usuario IN VARCHAR2 DEFAULT V('APP_USER')
) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT c.ID_CAJA INTO v_id
    FROM CAJAS c
    JOIN EMPLEADOS e ON e.ID_EMPLEADO = c.ID_EMPLEADO
   WHERE UPPER(e.CODIGO_USUARIO) = UPPER(p_usuario)
     AND c.ESTADO = 'A'
     AND ROWNUM = 1;
  RETURN v_id;
EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
END;
/

-- Oficina del usuario (deriva de la caja abierta)
CREATE OR REPLACE FUNCTION FN_OFICINA_USUARIO_V2 (
  p_usuario IN VARCHAR2 DEFAULT V('APP_USER')
) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT c.ID_OFICINA INTO v_id
    FROM CAJAS c
    JOIN EMPLEADOS e ON e.ID_EMPLEADO = c.ID_EMPLEADO
   WHERE UPPER(e.CODIGO_USUARIO) = UPPER(p_usuario)
     AND c.ESTADO = 'A'
     AND ROWNUM = 1;
  RETURN v_id;
EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
END;
/

-- REESCRITURA in-place de FN_OBTENER_COMPROBANTE: ahora reserva nro atómicamente
-- (P67 nuevo elige talonario explícito; P70 sigue cargando manualmente — no la usa
-- en práctica, confirmado por PO).
CREATE OR REPLACE FUNCTION FN_OBTENER_COMPROBANTE (
  p_id_talonario IN NUMBER
) RETURN VARCHAR2 IS
  v_talon TALONARIOS%ROWTYPE;
  v_nro   NUMBER;
BEGIN
  SELECT * INTO v_talon
    FROM TALONARIOS
   WHERE ID_TALONARIO = p_id_talonario
     AND ACTIVO = 'S'
   FOR UPDATE;

  IF TRUNC(SYSDATE) NOT BETWEEN v_talon.FECHA_INICIO AND v_talon.FECHA_FIN THEN
    RAISE_APPLICATION_ERROR(-20002,'El talonario no está vigente en la fecha actual.');
  END IF;
  v_nro := v_talon.NRO_ACTUAL + 1;
  IF v_nro > v_talon.NRO_FINAL THEN
    RAISE_APPLICATION_ERROR(-20001,'El talonario ha llegado a su numeración final.');
  END IF;

  UPDATE TALONARIOS SET NRO_ACTUAL = v_nro
   WHERE ID_TALONARIO = p_id_talonario;

  RETURN LPAD(v_talon.ESTABLECIMIENTO,3,'0')||'-'||
         LPAD(v_talon.PUNTO_EXPEDICION,3,'0')||'-'||
         LPAD(v_nro,7,'0');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20003,'No se encontró talonario activo para el id indicado.');
END;
/

-- Nota: la firma vieja (p_id_oficina, p_tipo_comprobante) cambia. P70 deja de
-- compilar si llama a la vieja. Como P70 carga manualmente el nro (confirmado),
-- se acepta el costo: si P70 alguna vez la invoca, va a fallar y obligará a
-- limpiar esa llamada huérfana en el momento.

-- Vista de "talonarios disponibles": fuente de LOV en P67 (filtra TIPO='FA')
-- y en P100 (filtra TIPO='RC')
CREATE OR REPLACE VIEW V_TALONARIOS_DISPONIBLES AS
SELECT t.ID_TALONARIO,
       t.ID_OFICINA,
       t.TIPO_COMPROBANTE,
       t.TIMBRADO || ' / ' ||
         LPAD(t.ESTABLECIMIENTO,3,'0')||'-'||LPAD(t.PUNTO_EXPEDICION,3,'0') AS DESCRIPCION
  FROM TALONARIOS t
 WHERE t.ACTIVO = 'S'
   AND TRUNC(SYSDATE) BETWEEN t.FECHA_INICIO AND t.FECHA_FIN
   AND t.NRO_ACTUAL < t.NRO_FINAL;

-- Vista del documento "Recibo de Cobro" (lectura para print P119)
CREATE OR REPLACE VIEW V_RECIBOS_COBRO AS
SELECT mc.ID_MOVIMIENTO           AS ID_RECIBO,
       mc.NRO_RECIBO,
       mc.ID_TALONARIO_RECIBO,
       mc.FECHA_EMISION_RECIBO,
       mc.ID_CAJA,
       mc.ID_CLIENTE,
       mc.USUARIO,
       mc.TOTAL_MONEDA_LOCAL,
       mc.MONEDA,
       mc.TIPO_CAMBIO,
       mc.TOTAL_MONEDA_ORIGEN,
       mc.ESTADO,
       mc.OBSERVACION,
       mc.ID_CUENTA_COBRAR_DET,
       ccd.ID_CXC,
       ccd.NRO_CUOTA,
       cxc.ID_COMPROBANTE         AS COMPROBANTE_ORIGEN,
       cxc.ID_PERSONA
  FROM MOVIMIENTOS_CAJA  mc
  LEFT JOIN CUENTAS_COBRAR_DET ccd ON ccd.ID_DETALLE = mc.ID_CUENTA_COBRAR_DET
  LEFT JOIN CUENTAS_COBRAR     cxc ON cxc.ID_CXC      = ccd.ID_CXC
 WHERE mc.TIPO = 'COBRO_CXC';
```

**Paso 4 — Triggers**

```sql
-- Drop del trigger roto que en el futuro causaría doble descuento
DROP TRIGGER WKSP_WORKPLACE.TRG_ACTUALIZAR_STOCK_FACTURA;

-- NOTA: NO se crea TRG_COMPROBANTE_STOCK. El trigger existente
-- TRG_MOV_STOCK_DETALLE (AFTER INSERT on DETALLE_COMPROBANTE,
-- filtro ESTADO='A' AND TIPO='FA') ya descuenta stock automáticamente
-- e inserta el MOVIMIENTOS_STOCK SALIDA. Cubierto.

-- Liberar reservas también al pasar a FACTURADO
-- (extiende el trigger ya existente de [PV-F4])
CREATE OR REPLACE TRIGGER TRG_OV_LIBERA_RESERVA
AFTER UPDATE OF ESTADO ON ORDENES_VENTA
FOR EACH ROW
WHEN (NEW.ESTADO IN ('ANULADO','VENCIDO','FACTURADO')
      AND OLD.ESTADO IN ('PENDIENTE','APROBADO'))
BEGIN
  UPDATE RESERVAS_PRODUCTO
     SET ESTADO = 'ANULADA'
   WHERE ID_ORDEN_VENTA = :NEW.ID_ORDEN
     AND ESTADO = 'VIGENTE';
END;
/

-- Bloquear apertura si ya existe una caja del mismo empleado del día
CREATE OR REPLACE TRIGGER TRG_CAJA_UNA_POR_DIA
BEFORE INSERT ON CAJAS
FOR EACH ROW
DECLARE
  v_otra NUMBER;
BEGIN
  -- 1) No abrir si ya hay otra abierta del mismo empleado
  SELECT COUNT(*) INTO v_otra
    FROM CAJAS
   WHERE ID_EMPLEADO = :NEW.ID_EMPLEADO
     AND ESTADO = 'A';
  IF v_otra > 0 THEN
    RAISE_APPLICATION_ERROR(-20020,
      'El empleado ya tiene una caja abierta. Debe cerrarla antes de abrir otra.');
  END IF;
  -- 2) No abrir si ya hay otra caja del mismo empleado del mismo día (cerrada incluso)
  --    salvo que se esté abriendo en la misma fecha (re-apertura prohibida)
  SELECT COUNT(*) INTO v_otra
    FROM CAJAS
   WHERE ID_EMPLEADO = :NEW.ID_EMPLEADO
     AND TRUNC(FEC_APERTURA) = TRUNC(NVL(:NEW.FEC_APERTURA, SYSTIMESTAMP));
  IF v_otra > 0 THEN
    RAISE_APPLICATION_ERROR(-20021,
      'Ya existe una caja del empleado para esta fecha. No se admiten dos cajas del mismo día.');
  END IF;
END;
/
```

**Paso 5 — `CERRAR_CAJA` v2**

Reescribir para sumar los movimientos del día (no sólo recibos):

```sql
CREATE OR REPLACE PROCEDURE cerrar_caja(
  p_id_caja IN NUMBER,
  p_usuario IN VARCHAR2
) IS
BEGIN
  UPDATE CAJAS
     SET ESTADO='C', FEC_CIERRE=SYSTIMESTAMP, USU_CIERRE=p_usuario
   WHERE ID_CAJA=p_id_caja AND ESTADO='A';

  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20030,'No hay caja abierta con ese id.');
  END IF;

  FOR reg IN (
    SELECT cm.MONEDA, cm.MONTO_APERTURA,
           NVL((SELECT SUM(mc.TOTAL_MONEDA_ORIGEN)
                  FROM MOVIMIENTOS_CAJA mc
                 WHERE mc.ID_CAJA = cm.ID_CAJA
                   AND mc.MONEDA  = cm.MONEDA
                   AND mc.TIPO   IN ('INGRESO_VENTA','COBRO_CXC')),0) AS INGRESOS,
           NVL((SELECT SUM(mc.TOTAL_MONEDA_ORIGEN)
                  FROM MOVIMIENTOS_CAJA mc
                 WHERE mc.ID_CAJA = cm.ID_CAJA
                   AND mc.MONEDA  = cm.MONEDA
                   AND mc.TIPO    = 'EGRESO'),0) AS EGRESOS
      FROM CAJA_MONEDAS cm
     WHERE cm.ID_CAJA = p_id_caja
  ) LOOP
    UPDATE CAJA_MONEDAS
       SET MONTO_CIERRE = reg.MONTO_APERTURA + reg.INGRESOS - reg.EGRESOS
     WHERE ID_CAJA = p_id_caja AND MONEDA = reg.MONEDA;
  END LOOP;

  UPDATE MOVIMIENTOS_CAJA SET ESTADO='C' WHERE ID_CAJA=p_id_caja;
  COMMIT;
END;
/
```

#### F8.B — P65 (apertura de caja)

Cambios manuales en APEX Builder (Form):

- `P65_ID_EMPLEADO`:
  - tipo Display Only
  - default SQL `SELECT ID_EMPLEADO FROM EMPLEADOS WHERE UPPER(CODIGO_USUARIO)=UPPER(:APP_USER)`.
- `P65_USU_APERTURA`:
  - default `:APP_USER`.
- `P65_FEC_APERTURA`:
  - Display Only (no Date Picker).
  - default `SYSTIMESTAMP AT TIME ZONE 'America/Argentina/Buenos_Aires'`.
- `P65_ID_OFICINA`:
  - LOV existente, cascada con `P65_ID_CAJA_CONF` (ya está).
- Validación BEFORE_HEADER (PL/SQL): si `FN_CAJA_ABIERTA_USUARIO(:APP_USER)` no es NULL → redirigir a P62 con error "Ya tenés caja abierta — cerrala primero".
- Validación BEFORE_HEADER #2: si existe `CAJAS` del empleado de hoy ya cerrada → mostrar info "Ya cerraste tu caja del día. Volvé mañana." y redirigir.
- El trigger `TRG_CAJA_UNA_POR_DIA` es la barrera dura; la validación en página es para UX.

#### F8.C — P61 (cierre de caja)

- `P61_EMPLEADO`:
  - Display Only.
  - default SQL `SELECT ID_EMPLEADO FROM EMPLEADOS WHERE UPPER(CODIGO_USUARIO)=UPPER(:APP_USER)`.
- `P61_CAFA_CONF`:
  - LOV cambia a `SELECT CF.DESCRIPCION, CA.ID_CAJA FROM CAJA_CONF CF JOIN CAJAS CA ON CA.ID_CAJA_CONF=CF.ID_CAJA_CONF WHERE CA.ESTADO='A' AND CA.ID_EMPLEADO = :P61_EMPLEADO`.
- Proceso `Cerrar caja`: cambiar `p_usuario => :APP_USER` (string).
- Validación: si no hay caja abierta del usuario → error "No tenés caja abierta".

#### F8.D — P67 (form de facturación)

Items nuevos / cambios:

| Item | Cambio |
|------|--------|
| `P67_ID_CAJA` | nuevo, Display Only, default `FN_CAJA_ABIERTA_USUARIO(:APP_USER)` |
| `P67_ID_OFICINA` | Display Only, default `FN_OFICINA_USUARIO_V2(:APP_USER)` |
| `P67_ID_TALONARIO` | Select List, LOV `SELECT DESCRIPCION d, ID_TALONARIO r FROM V_TALONARIOS_DISPONIBLES WHERE ID_OFICINA = :P67_ID_OFICINA AND TIPO_COMPROBANTE = 'FA'` (sólo facturas en F8 — RC se filtra para P100, NC queda para futura nota de crédito) |
| `P67_TIPO_COMPROBANTE` | Display Only, derivado del talonario por DA |
| `P67_ID_ORDEN_VENTA` | LOV `SELECT ID_ORDEN, ID_ORDEN FROM ORDENES_VENTA WHERE ESTADO = 'APROBADO' AND ID_OFICINA = :P67_ID_OFICINA ORDER BY ID_ORDEN DESC` |
| `P67_NRO_COMPROBANTE` | Display Only, sólo preview (NO reserva) |
| `P67_ESTADO` | Display Only (solo lectura) |
| `P67_NEW` | **eliminar** |
| Cliente (`P67_ID_CLIENTE`) | default desde la orden: `SELECT ID_PERSONA FROM ORDENES_VENTA WHERE ID_ORDEN = :P67_ID_ORDEN_VENTA` al cambiar orden (DA) |

Regiones:

- **Eliminar IG `Detalle_Venta`** y su proceso `Detalle_Venta - Save Interactive Grid Data` (rompe B7/B8).
- IG `Detalle_V`:
  - Edit Enabled = **No** (read-only).
  - Mantiene cálculo de IVA por línea.
  - Mantiene el JS `recalculaImporte()` que totaliza los items P67_TOTAL_*.

Procesos AFTER_SUBMIT (orden):

| # | Proceso | Tipo | Condición | Detalle |
|---|---------|------|-----------|---------|
| 5 | Validar caja del día | PL/SQL | siempre | Falla si `FN_CAJA_ABIERTA_USUARIO(:APP_USER)` NULL o `TRUNC(c.FEC_APERTURA) <> TRUNC(SYSDATE)` |
| 6 | Validar transición OV | PL/SQL | request IN CREATE | `FN_PUEDE_TRANSICION_OV(estado_ov,'FACTURADO')='S'` |
| 7 | Validar monto pagado | PL/SQL | request IN CREATE AND FORMA_PAGO=21 (contado) | `:P67_MONTO_PAGO >= :P67_TOTAL_MONEDA_LOCAL` |
| 8 | Reservar nro comprobante | PL/SQL | request IN CREATE | Llama `FN_OBTENER_COMPROBANTE(:P67_ID_TALONARIO)` (reescrita en F8.A) y setea `:P67_NRO_COMPROBANTE`. `P67_ID_OFICINA` y `P67_TIPO_COMPROBANTE` ya están en sesión derivados desde la caja / talonario. |
| 10 | Process form COMPROBANTES | Form DML | siempre | (ya existe, inserta cabecera) |
| 20 | Detalle Factura Cursor | PL/SQL | request IN CREATE | Ya existe; **fix**: validar `:P67_ID_ORDEN_VENTA IS NOT NULL`. Al insertar `DETALLE_COMPROBANTE` se dispara `TRG_MOV_STOCK_DETALLE` → descuento de stock automático. |
| 25 | Movimiento de caja (NUEVO) | PL/SQL | request IN CREATE AND FORMA_PAGO=21 | Inserta `MOVIMIENTOS_CAJA(TIPO='INGRESO_VENTA', ID_CAJA, ID_COMPROBANTE, FECHA, TOTAL_MONEDA_LOCAL, MONEDA, USUARIO, ESTADO='A')` + detalle con `ID_FORMA_PAGO=21, MONTO_LOCAL=TOTAL`. **Solo para contado** — si crédito, `TRG_INS_CUENTAS_COBRAR` ya creó las cuotas en CxC. |
| 27 | (existente) Actualiza talonario | **eliminar** | — | Ya lo hizo F8.A paso 4 vía `FN_RESERVAR_NRO_COMPROBANTE`. |
| 30 | Close Dialog | Session State | request IN CREATE,SAVE,DELETE | (existe) |

**Efectos colaterales automáticos al INSERT de `COMPROBANTES` (ya gestionados por triggers existentes; no necesitan código en P67):**

- `TRG_FACTURA_ORDEN` valida y mueve `ORDENES_VENTA` a `FACTURADO`.
- `TRG_INS_CUENTAS_COBRAR` genera `CUENTAS_COBRAR` + cuotas si `FORMA_PAGO='1'`.
- `TRG_OV_LIBERA_RESERVA` (extendido en F8.A) libera reservas vigentes al pasar a `FACTURADO`.
- Al INSERT de `DETALLE_COMPROBANTE`: `TRG_MOV_STOCK_DETALLE` descuenta stock + inserta `MOVIMIENTOS_STOCK`.

Eliminar:
- Proceso `Detalle_Venta - Save Interactive Grid Data` (B7).
- Proceso `Actualiza Factura` (UPDATE TALONARIOS — bug B4).
- DA `Rellena Campos` action 2 que llama `FN_OBTENER_COMPROBANTE` (el nro lo reserva el proceso AFTER_SUBMIT). Dejar solo la parte que carga `ID_OFICINA`/`TIPO_COMPROBANTE` para mostrar en pantalla.

Crédito (`P67_FORMA_PAGO=1`): el cajero puede seleccionarlo. En F8:
- **NO** se inserta `MOVIMIENTOS_CAJA` (la plata no entró todavía a la caja).
- **SÍ** se inserta `CUENTAS_COBRAR` + N cuotas — lo hace **automáticamente** `TRG_INS_CUENTAS_COBRAR` al insertar el comprobante con `FORMA_PAGO='1' AND ID_PLAN_CUOTA=<plan>`.

Por lo tanto, vender a crédito en F8 deja una **deuda registrada en CXC**, sin pantalla de gestión todavía. La pantalla de cobro llega en F9.

#### F8.E — P66 (lista)

- Columna `ID_ORDEN_VENTA`: quitar LOV (devuelve estados — B15), mostrar el id crudo.
- IR Source: agregar JOIN a `PERSONAS` para mostrar nombre del cliente.
- Filtro default: `WHERE ID_OFICINA = FN_OFICINA_USUARIO_V2(:APP_USER) AND FECHA >= TRUNC(SYSDATE,'MM')`.
- Columna `ESTADO`: HTML expression con badge.

---

### Feature 9 — Cobro de cuotas de CxC

Dependencias: F8 cerrada.

> **Hallazgo 2026-06-06**: el backend de venta a crédito **ya existe**
> (`TRG_INS_CUENTAS_COBRAR` genera cabecera + cuotas automáticamente). Además
> ya existen **3 páginas funcionales** del flujo de cobros (P95, P99, P100)
> que no aparecían en mi análisis inicial. **P100 sin embargo no registra
> cobro real** (CC1): solo cambia ESTADO de la cuota. F9 se enfoca en
> rediseñar P100 y limpiar el resto.

**Alcance F9:**

#### F9.A — Backend BD (`db/F9_cobros.sql`)

- **`FN_COBRAR_CUOTA(p_id_detalle, p_id_caja, p_id_talonario_rc, p_id_forma_pago, p_monto_local, p_moneda, p_nro_ref)`**:
  procedimiento atómico que:
  1. Valida cuota en `PENDIENTE`/`VENCIDA`, valida caja abierta del cajero.
  2. Reserva nro de recibo: `v_nro_recibo := FN_OBTENER_COMPROBANTE(p_id_talonario_rc)` (mismo mecanismo que la factura — solo cambia el talonario).
  3. Inserta `MOVIMIENTOS_CAJA(TIPO='COBRO_CXC', ID_CAJA, ID_CLIENTE, USUARIO, NRO_RECIBO=v_nro_recibo, ID_TALONARIO_RECIBO=p_id_talonario_rc, FECHA_EMISION_RECIBO=SYSDATE, ID_CUENTA_COBRAR_DET=p_id_detalle, TOTAL_*=monto)`.
  4. Inserta `DETALLE_MOVIMIENTO_CAJA(ID_FORMA_PAGO, MONTO_LOCAL, …)`.
  5. Marca cuota `CUENTAS_COBRAR_DET.ESTADO='PAGADA'`.
  6. Baja `CUENTAS_COBRAR.SALDO`; si SALDO=0 → `CUENTAS_COBRAR.ESTADO='PAGADA'`.
  7. Retorna el `NRO_RECIBO` (para que P100 muestre confirmación y abra el print).
- Limpiar el dato sucio `CUENTAS_COBRAR.ESTADO='PENDIENTE 2\n'` → `'PENDIENTE'`.
- Agregar `CK_CCD_ESTADO` en `CUENTAS_COBRAR_DET`: `CHECK (ESTADO IN ('PENDIENTE','PAGADA','VENCIDA'))`.
- Agregar `CK_CXC_ESTADO` en `CUENTAS_COBRAR`: `CHECK (ESTADO IN ('PENDIENTE','PAGADA'))` (la cuenta global no vence, sus cuotas sí).
- Trigger / job diario `JOB_VENCER_CUOTAS` que marque cuotas
  `FECHA_VENCIMIENTO < TRUNC(SYSDATE) AND ESTADO='PENDIENTE'` → `VENCIDA`
  (paralelo al `JOB_VENCER_PRESUPUESTOS` de [PV-F2]).

#### F9.B — P100 rediseñada

- **Eliminar** los botones SAVE/DELETE genéricos (CC2, CC3).
- Items `P100_ID_CXC`, `P100_NRO_CUOTA`, `P100_FECHA_VENCIMIENTO`,
  `P100_MONTO_CUOTA` → **Display Only**.
- Fix LOV `P100_ID_CXC` (CC4) — no se necesita LOV si es Display Only.
- Items nuevos para registrar el pago:
  - `P100_ID_CAJA` — Display Only, default `FN_CAJA_ABIERTA_USUARIO(:APP_USER)`.
  - `P100_ID_TALONARIO_RC` — Display Only, default desde `V_TALONARIOS_DISPONIBLES WHERE TIPO_COMPROBANTE='RC' AND ID_OFICINA = FN_OFICINA_USUARIO_V2(:APP_USER)`.
  - `P100_ID_FORMA_PAGO` — Select List sobre `FORMAS_PAGO ACTIVO='S'`.
  - `P100_ID_METODO_PAGO` — Select List sobre `METODOS_PAGO`.
  - `P100_MONTO_PAGO` — Number Field; default = `P100_MONTO_CUOTA`.
  - `P100_NRO_REFERENCIA` — opcional, visible si forma de pago ≠ efectivo.
  - `P100_NRO_RECIBO_GENERADO` — Display Only (se llena tras COBRAR).
- Botón `COBRAR` reemplaza `SAVE`. Llama proceso AFTER_SUBMIT que invoca `FN_COBRAR_CUOTA(...)` y guarda el `NRO_RECIBO` retornado en `P100_NRO_RECIBO_GENERADO`.
- Botón `IMPRIMIR RECIBO` aparece tras COBRAR, abre P119 con `P119_ID_RECIBO`.
- Validación BEFORE_HEADER: si `FN_CAJA_ABIERTA_USUARIO(:APP_USER) IS NULL`
  → error + redirect a P65 (mismas reglas que P67).
- Validación: cuota debe estar en `PENDIENTE` o `VENCIDA` (no permitir cobrar PAGADA).
- Validación: `MONTO_PAGO >= MONTO_CUOTA` (sin pagos parciales en esta versión).
- Validación: debe existir talonario RC vigente para la oficina del cajero.

#### F9.C — P95 / P99 retoques

- **P95**: agregar columna `SALDO_PCT` (cuánto queda por cobrar), badge en
  ESTADO, filtros default por cliente y fecha.
- **P99**: badge por estado (PENDIENTE amarillo / PAGADA verde /
  VENCIDA rojo); ordenar por `NRO_CUOTA`. Mostrar fecha de pago si está pagada.

#### F9.D — Limpieza de menú/páginas huérfanas

- **Eliminar** P98 (redundante, CC7). Confirmar que no está enlazada desde ningún lado.
- **Eliminar o reapuntar** P93 (placeholder huérfano, CC8). Opciones:
  - Eliminar la página y reapuntar el header del menú directo a P95.
  - Convertir P93 en dashboard real de cobros.
- Limpiar `current_for_pages='93'` del header "Cobros" del menú.

#### F9.E — (Opcional, post-F9) Estado de cuenta cliente

- Página por cliente: total adeudado, cuotas vencidas, próximas a vencer,
  histórico de pagos.

#### F9.F — P119 Documento Recibo (modal print)

Análoga a **P6 (presupuesto print)** y **P96 (factura print)**, pero para el recibo de cobro.

- Página nueva **P119 — Documento Recibo**, modal print.
- Item `P119_ID_RECIBO` (NUMBER, recibe el `ID_MOVIMIENTO`).
- Región Dynamic PL/SQL Content: genera HTML con datos del recibo, leyendo de **`V_RECIBOS_COBRO`** (vista creada en F9.A) + `DETALLE_MOVIMIENTO_CAJA` para las formas de pago + JOIN a `PERSONAS` (cliente) y `OFICINAS`.
- Contenido mínimo del print:
  - Cabecera: razón social oficina, RUC (si se modela), timbrado, vigencia.
  - `<h1>RECIBO DE COBRO #NNN-NNN-NNNNNNN</h1>` (`NRO_RECIBO`).
  - Fecha de emisión.
  - Datos del cliente.
  - Línea "Cobro de cuota N° X de la cuenta ID_CXC asociada a comprobante #YYY-YYY-NNNNNNN".
  - Detalle de formas de pago.
  - Total cobrado.
- Punto de entrada: botón "Imprimir Recibo" en P100 tras COBRAR exitoso, y columna `<fa-print>` en P95 sobre filas con cobros (vía join con `MOVIMIENTOS_CAJA TIPO='COBRO_CXC'`).

---

## 5. Flujo de implementación paso a paso

Cada hito es una unidad atómica: cuando termina, queda en un estado verificable y
los siguientes pueden arrancar. Marcamos ⏳ los pendientes y ✅ los cerrados.

### Hito 1 — Backend BD (F8.A) ✅ (2026-06-06)

**Entregable:** `db/F8_facturacion.sql` idempotente, aplicado contra `tesis_db`.

1. Pre-check de dependencias (`SELECT * FROM all_dependencies WHERE referenced_name='RECIBOS_COBRO'`).
2. RENAME `RECIBOS_COBRO → MOVIMIENTOS_CAJA` (+ detalle); rename de `ID_RECIBO` → `ID_MOVIMIENTO` para coherencia semántica.
3. ALTER ADD de columnas: `TIPO`, `ID_COMPROBANTE`, `USUARIO`, `NRO_RECIBO`, `ID_TALONARIO_RECIBO`, `FECHA_EMISION_RECIBO`, `ID_CUENTA_COBRAR_DET`.
4. Constraints: `FK_MOVCAJA_*`, `CK_MOVCAJA_TIPO`, `CK_MOVCAJA_ESTADO`, `CK_MOVCAJA_RECIBO`.
5. Hardening `CAJAS`: `CK_CAJAS_ESTADO`, índice único parcial `UQ_CAJA_ABIERTA_EMP`.
6. Funciones: `FN_CAJA_ABIERTA_USUARIO`, `FN_OFICINA_USUARIO_V2`, **reescritura** de `FN_OBTENER_COMPROBANTE`.
7. Vistas: `V_TALONARIOS_DISPONIBLES`, `V_RECIBOS_COBRO`.
8. Triggers: DROP `TRG_ACTUALIZAR_STOCK_FACTURA`, REPLACE `TRG_OV_LIBERA_RESERVA` extendido a FACTURADO, CREATE `TRG_CAJA_UNA_POR_DIA`.
9. `cerrar_caja` v2 (suma `MOVIMIENTOS_CAJA`).
10. Verificación final (counts post-aplicación).

**Hito cerrado cuando:** el script corre dos veces seguidas sin errores y el SELECT final reporta los counts esperados.

### Hito 2 — P65 Apertura de caja (F8.B) ✅ (2026-06-06, pendiente prueba browser)

**Entregable:** P65 retocada en APEX Builder + re-export al repo.

1. `P65_ID_EMPLEADO` → Display Only con default SQL desde APP_USER.
2. `P65_USU_APERTURA` → default `:APP_USER`.
3. `P65_FEC_APERTURA` → Display Only con `SYSTIMESTAMP`.
4. Validaciones BEFORE_HEADER (caja ya abierta / caja del día ya cerrada).
5. Test browser: abrir caja → confirmar `USU_APERTURA = TCASCO`.
6. Re-export a `apex-work/.../page_00065.sql` + agregar a `install_page.sql`.

### Hito 3 — P61 Cierre de caja (F8.C) ⏳

**Entregable:** P61 retocada + re-export.

1. `P61_EMPLEADO` Display Only desde APP_USER.
2. `P61_CAFA_CONF` LOV restringido a cajas del empleado actual.
3. Proceso `Cerrar caja` pasa `:APP_USER` (string).
4. Test browser: cerrar caja → confirmar `USU_CIERRE = TCASCO` (no "61").

### Hito 4 — P67 Facturación contado (F8.D) ✅ (2026-06-07, end-to-end verificado)

**Entregable:** P67 rediseñada + re-export.

1. Eliminar IG `Detalle_Venta` + proceso DML correspondiente.
2. Eliminar proceso `Actualiza Factura` (el UPDATE TALONARIOS que falla).
3. Eliminar item `P67_NEW` (debug).
4. Fix LOV `P67_ID_ORDEN_VENTA` → `ESTADO='APROBADO' AND ID_OFICINA = …`.
5. Items derivados: `P67_ID_CAJA`, `P67_ID_OFICINA`, `P67_TIPO_COMPROBANTE` Display Only (`P67_TIPO_COMPROBANTE` también ajustar `cMaxlength` a 2).
6. `P67_ID_TALONARIO` desde `V_TALONARIOS_DISPONIBLES`.
7. Procesos AFTER_SUBMIT en el nuevo orden (ver §4 F8.D tabla de procesos).
8. Test golden path (§8) + test crédito colateral (§8 sub-sección).
9. Re-export.

### Hito 5 — P66 Lista comprobantes (F8.E) ✅ (2026-06-07)

**Entregable:** P66 retocada + re-export.

1. Fix LOV columna `ID_ORDEN_VENTA` (eliminar el LOV mal asignado, mostrar id crudo).
2. Filtro default por oficina del usuario + mes actual.
3. JOIN a PERSONAS para mostrar nombre cliente.
4. Badge en ESTADO.

### Hito 6 — Cierre F8 ✅ (2026-06-07)

**Entregable:** todo capturado al repo + tag de versión.

1. ✅ Re-export de páginas tocadas (P61, P65, P66, P67) en `apex-work/`.
2. ✅ Update de `install_page.sql` con todas las entries.
3. ✅ Commit `a67ccf3` "feat(F8): facturacion contado end-to-end + modulo de caja".
4. ✅ Tag `f8-facturacion-contado` creado.

### Hito 7 — Backend BD F9 (F9.A) ✅ (2026-06-07)

**Entregable:** `db/F9_cobros.sql`.

1. Limpiar dato sucio `CUENTAS_COBRAR.ESTADO='PENDIENTE 2\n'`.
2. Constraints `CK_CCD_ESTADO`, `CK_CXC_ESTADO`.
3. Función `FN_COBRAR_CUOTA` (atómica, reserva nro recibo, baja saldo).
4. Job `JOB_VENCER_CUOTAS` diario.

### Hito 8 — P100 rediseño (F9.B) ✅ (2026-06-07, end-to-end verificado)

**Entregable:** P100 reescrita.

1. Eliminar botones SAVE/DELETE/CREATE genéricos.
2. Items de cuota → Display Only.
3. Items nuevos de pago (`P100_ID_CAJA`, `P100_ID_TALONARIO_RC`, `P100_ID_FORMA_PAGO`, `P100_MONTO_PAGO`, `P100_NRO_REFERENCIA`).
4. Botón COBRAR + proceso que invoca `FN_COBRAR_CUOTA`.
5. Validaciones de caja, monto, estado.

### Hito 9 — P95/P99 retoques + Limpieza (F9.C/D) ⏳

1. P95: columna SALDO_PCT, badges, filtros.
2. P99: badges por estado, orden por NRO_CUOTA.
3. Eliminar P98 (huérfana) y P93 (placeholder) o reapuntarlas.
4. Update menú para sacar `current_for_pages='93'`.

### Hito 10 — P119 Documento Recibo (F9.F) ⏳

**Entregable:** P119 nueva creada en APEX Builder.

1. Modal Dialog basada en P96.
2. Region Dynamic PL/SQL que lee `V_RECIBOS_COBRO` + `DETALLE_MOVIMIENTO_CAJA`.
3. Botón "Imprimir Recibo" en P100 que abre P119.
4. Columna print en P95 para reimprimir cualquier recibo histórico.
5. Test browser end-to-end (cobrar cuota → modal con recibo → imprimir).

### Hito 11 — Cierre F9 ⏳

1. Re-export, commit, tag `f9-cobros`.

---

## 5.1 Dependencias y orden de implementación

```
[F8.A] Backend BD
   ├── [F8.B] P65 apertura          ← requiere FN_CAJA_ABIERTA_USUARIO + UQ
   ├── [F8.C] P61 cierre            ← requiere cerrar_caja v2
   ├── [F8.D] P67 form              ← requiere V_TALONARIOS + FN_RESERVAR + TRG_COMPROBANTE_STOCK + extensión MOV_CAJA
   └── [F8.E] P66 lista             ← cosmético, último

[F9] Crédito ← requiere F8 cerrada y probada en browser end-to-end
```

**Orden recomendado:**

1. F8.A — backend (BD). Sin esto nada anda.
2. F8.B — apertura (manual en APEX Builder).
3. F8.C — cierre (manual).
4. F8.D — factura (manual + capturar al repo vía `apex-export`).
5. F8.E — lista P66 (manual).
6. Test end-to-end en browser (golden path + edge cases del §7).
7. Capturar al repo todas las páginas tocadas + agregar a `install_page.sql`.

---

## 6. Riesgos identificados

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | El `RENAME RECIBOS_COBRO → MOVIMIENTOS_CAJA` rompe `cerrar_caja` y `TRG_CERRAR_CAJA_CONF` por nombre stale. | Recompilar `cerrar_caja` con el código v2 (parte de F8.A). `TRG_CERRAR_CAJA_CONF` no referencia `RECIBOS_COBRO`, solo a `cerrar_caja`, así que con que ese procedimiento exista vuelve a compilar. |
| R2 | El `TRG_CAJA_UNA_POR_DIA` impide reapertura legítima si el día anterior quedó abierto y hay que volver a operar. | La regla del PO es estricta: cerrar primero, abrir hoy. Si aparece un caso "olvidé cerrar ayer y necesito facturar ya", el cajero cierra primero la sesión vieja (P61). Cubierto por UX en P65. |
| R3 | `FN_RESERVAR_NRO_COMPROBANTE` hace `FOR UPDATE` sobre la fila del talonario → serializa todas las facturas con ese timbrado. | Aceptable: una factura tarda ms en commitearse, no es cuello de botella para la escala del proyecto. |
| R4 | El trigger `TRG_COMPROBANTE_STOCK` puede fallar por stock insuficiente al facturar (vía `TRG_ACTUALIZAR_STOCK_MOVIMIENTO -20001`). Eso aborta toda la factura. | Es el comportamiento deseado: no se puede facturar lo que no se tiene en stock. Si el presupuesto tenía reserva [PV-F3], el stock debería estar disponible. |
| R5 | Si hay 2 talonarios FA vigentes para la misma oficina (transición de timbrado), `V_TALONARIOS_DISPONIBLES` muestra ambos al cajero. | Cajero elige; aceptable. Si más adelante se quiere automatizar, agregar regla "prefiero el de mayor `FECHA_INICIO`". |
| R6 | `EMPLEADOS.CODIGO_USUARIO` puede no estar poblado para todos los cajeros. | Validación en P65/P67: si la función devuelve NULL, mostrar mensaje "Su usuario APEX no está vinculado a un empleado — contacte al admin". |
| R7 | Crédito visible en F8 sin pipeline detrás → cajero puede grabar una venta a crédito que queda en "deuda fantasma". | Documentado como decisión §3 #2. En F9 se completa. Mientras tanto el cajero "sabe" que no debe usarlo (decisión del PO). |
| R8 | El `RENAME` requiere que `RECIBOS_COBRO` no tenga otras referencias en la app (P67 actual no la usa). | **Pre-check ejecutado** (§2.6): 0 refs en APEX, solo `CERRAR_CAJA` en BD (que se reescribe). Renombre seguro. |
| R9 | `FN_OBTENER_COMPROBANTE` se reescribe in-place (firma cambia de `(p_id_oficina, p_tipo)` a `(p_id_talonario)`). Si P70 alguna vez la llama, deja de compilar. | Confirmado por PO que P70 carga manualmente el nro de comprobante de proveedor y no la usa en la práctica. Si llegara a fallar, se limpia esa llamada huérfana en el momento. |
| R10 | El drop de `TRG_ACTUALIZAR_STOCK_FACTURA` podría romper algún flujo que dependiese de él. | El trigger lee `DETALLE_COMPROBANTE` en AFTER INSERT de la cabecera → siempre encuentra cero filas → no descuenta nada. Es no-op de hecho. Verificar con un test pre-drop: `SELECT COUNT(*) FROM MOVIMIENTOS_STOCK WHERE referencia LIKE 'Factura %'` (los que generaría el trigger). Si es 0, confirma que nunca hizo nada. |
| R11 | Tres triggers AFTER INSERT en `COMPROBANTES` sin `FOLLOWS/PRECEDES` definido. Tras drop de `TRG_ACTUALIZAR_STOCK_FACTURA` quedan `TRG_FACTURA_ORDEN` y `TRG_INS_CUENTAS_COBRAR`. | Verificado que no comparten dependencias: el primero hace `SELECT FOR UPDATE` y `UPDATE` sobre `ORDENES_VENTA`; el segundo solo lee `:NEW.FORMA_PAGO` y escribe en `CUENTAS_COBRAR*`. El orden de ejecución es indiferente. |
| R12 | `JOB_VENCER_PRESUPUESTOS` referenciado en [PV-F2] **no existe** en `USER_SCHEDULER_JOBS`. | Deuda de PV, fuera del alcance de F8/F9. Si el PO quiere ver presupuestos vencidos automáticamente, hay que crear el job aparte. |

---

## 7. Checklists por feature

### F8.A — Backend ✅ (2026-06-06)

- [x] `RENAME RECIBOS_COBRO → MOVIMIENTOS_CAJA` (+ detalle)
- [x] Columnas extra: `TIPO`, `ID_COMPROBANTE`, `USUARIO`
- [x] Constraints: `CK_MOVCAJA_TIPO`, `CK_MOVCAJA_ESTADO`, `FK_MOVCAJA_COMP`
- [x] `CK_CAJAS_ESTADO` (admite NULL para datos heredados)
- [x] `UQ_CAJA_ABIERTA_EMP` (parcial WHERE ESTADO='A')
- [x] `FN_CAJA_ABIERTA_USUARIO`
- [x] `FN_OFICINA_USUARIO_V2`
- [x] `FN_OBTENER_COMPROBANTE` reescrita in-place: nueva firma `(p_id_talonario)`, atómica con `FOR UPDATE` + `UPDATE NRO_ACTUAL`
- [x] `V_TALONARIOS_DISPONIBLES`
- [x] `V_RECIBOS_COBRO` (lectura para print P119)
- [x] Columnas documento en `MOVIMIENTOS_CAJA`: `NRO_RECIBO`, `ID_TALONARIO_RECIBO`, `FECHA_EMISION_RECIBO`, `ID_CUENTA_COBRAR_DET`
- [x] FKs + CK_MOVCAJA_RECIBO (validación condicional según TIPO)
- [x] **DROP** `TRG_ACTUALIZAR_STOCK_FACTURA` (roto, riesgo de doble descuento futuro)
- [x] `TRG_OV_LIBERA_RESERVA` extendido a `FACTURADO`
- [x] `TRG_CAJA_UNA_POR_DIA` (relajado el 2026-06-07: solo valida "ya hay caja abierta")
- [x] `CERRAR_CAJA` v2 (suma MOVIMIENTOS_CAJA)
- [x] Script `db/F8_facturacion.sql` idempotente + verificación final
- [x] Pre-check de dependencias APEX + BD (§2.6) — ejecutado 2026-06-06

### F8.B — P65 Apertura ✅ (2026-06-06)

- [x] `P65_ID_EMPLEADO` Display Only (hidden con ID + `P65_EMPLEADO_NOMBRE` display only con nombre), default SQL desde APP_USER
- [x] `P65_USU_APERTURA` default `V('APP_USER')`
- [x] `P65_FEC_APERTURA` Display Only con SYSTIMESTAMP (formato `DD/MM/YYYY HH24:MI:SS`)
- [x] `P65_ESTADO` default `'A'` (fix encontrado el 2026-06-06)
- [x] Validación BEFORE_HEADER caja ya abierta
- [x] Test browser confirmado: `USU_APERTURA=TCASCO`, `ESTADO='A'`

### F8.C — P61 Cierre ✅ (2026-06-06)

- [x] `P61_EMPLEADO` Hidden + `P61_EMPLEADO_NOMBRE` Display Only desde APP_USER
- [x] `P61_CAFA_CONF` LOV restringido a cajas del empleado actual
- [x] Proceso `Cerrar caja` pasa `V('APP_USER')` (string) — fix bug C4
- [x] Validación BEFORE_HEADER "sin caja abierta no se cierra nada"
- [x] Test browser confirmado: `USU_CIERRE=TCASCO`

### F8.D — P67 Facturación ✅ (2026-06-07, end-to-end verificado)

- [x] Eliminar proceso `Detalle_Venta - Save Interactive Grid Data` (corrompía DETALLE_ORDEN)
- [x] Eliminar proceso `Actualiza Factura` (UPDATE TALONARIOS roto)
- [x] Eliminar item `P67_NEW` (debug)
- [x] LOV `P67_ID_ORDEN_VENTA` corregida a `ESTADO='APROBADO'`
- [x] `P67_ID_OFICINA` derivado de `FN_OFICINA_USUARIO_V2` con LOV restringido
- [x] `P67_TIPO_COMPROBANTE` Hidden (se lee del talonario en AFTER_SUBMIT)
- [x] `P67_NRO_COMPROBANTE` Display Only (lo setea el proceso de reserva)
- [x] LOV `P67_ID_TALONARIO` desde `V_TALONARIOS_DISPONIBLES WHERE TIPO='FA'` cascade con oficina
- [x] `P67_ESTADO` Display Only (botón Anular fuera de F8)
- [x] Validación BEFORE_HEADER "Validacion de Caja" reescrita con `FN_CAJA_ABIERTA_USUARIO` + chequeo día actual
- [x] Proceso AFTER_SUBMIT seq 3 "Validar transición OV → FACTURADO"
- [x] Proceso AFTER_SUBMIT seq 5 "Validar monto pagado contado"
- [x] Proceso AFTER_SUBMIT seq 8 "Reservar nro comprobante" (lee TIPO_COMPROBANTE del talonario + reserva nro atómico)
- [x] Proceso AFTER_SUBMIT seq 40 "Movimiento de caja contado" (INSERT en `MOVIMIENTOS_CAJA` + `DETALLE_MOVIMIENTO_CAJA`)
- [x] DA "Rellena Campos" eliminada (era para firma vieja, ya no necesaria)
- [x] DA "Carga de Detalle" ampliada: al elegir presupuesto carga cliente + total
- [x] Re-export P67 a `apex-work/f100/application/pages/page_00067.sql`
- [x] Test end-to-end browser confirmado (factura #001-001-0000022, stock bajado, OV→FACTURADO, RESERVAS→ANULADA, talonario incrementado, MOVIMIENTOS_CAJA generado)

### F8.E — P66 Lista ✅ (2026-06-07)

- [x] Quitar LOV de columna `ID_ORDEN_VENTA` (apuntaba a LOV de ESTADO — bug B15)
- [x] Cambiar LOV de columna `ID_CLIENTE` a `PERSONA.NOMBRE` (antes mostraba nro documento)
- [x] Columna renombrada a "N° Presupuesto"
- [ ] Filtro default por oficina del usuario + mes actual (opcional, requiere saved report)

### F9.A — Backend BD cobros ✅ (2026-06-07)

- [x] Normalizar `CUENTAS_COBRAR_DET.ESTADO='PAGADO'` → `'PAGADA'` (el dato sucio del plan original ya no existía)
- [x] Reset caso de prueba CxC=2 (cuotas a PENDIENTE, SALDO=TOTAL) — decisión del PO 2026-06-07
- [x] Extensión `DETALLE_MOVIMIENTO_CAJA.ID_METODO_PAGO` (FK a `METODOS_PAGO`) — agregado fuera del plan original para guardar método (Efectivo/Tarjeta/Transferencia/QR)
- [x] `CK_CCD_ESTADO` en `CUENTAS_COBRAR_DET`: `CHECK (ESTADO IN ('PENDIENTE','PAGADA','VENCIDA'))`
- [x] `CK_CXC_ESTADO` en `CUENTAS_COBRAR`: `CHECK (ESTADO IN ('PENDIENTE','PAGADA'))`
- [x] `FN_COBRAR_CUOTA(p_id_detalle, p_id_caja, p_id_talonario_rc, p_id_forma_pago, p_id_metodo_pago, p_monto_pago, p_moneda, p_nro_ref, p_usuario) RETURN VARCHAR2`:
  - Validar cuota PENDIENTE/VENCIDA + caja abierta del cajero
  - Reservar nro recibo vía `FN_OBTENER_COMPROBANTE(p_id_talonario_rc)`
  - INSERT `MOVIMIENTOS_CAJA(TIPO='COBRO_CXC', NRO_RECIBO, ID_TALONARIO_RECIBO, FECHA_EMISION_RECIBO, ID_CUENTA_COBRAR_DET, ...)`
  - INSERT `DETALLE_MOVIMIENTO_CAJA` (forma de pago)
  - UPDATE cuota a `ESTADO='PAGADA'`
  - UPDATE saldo `CUENTAS_COBRAR`; si SALDO=0 → `ESTADO='PAGADA'`
  - RETURN `NRO_RECIBO` para que P100 lo muestre
- [x] `JOB_VENCER_CUOTAS` (DAILY 02:00): marca cuotas vencidas `PENDIENTE → VENCIDA` cuando `FECHA_VENCIMIENTO < TRUNC(SYSDATE)`
- [x] Parámetros de emisor en `PARAMETROS` con `TIPO_PARAMETRO='EMPRESA'` (claves `RUC`, `RAZON_SOCIAL`, `DIRECCION`) — agregado 2026-06-08 a pedido del PO para evitar hardcodear datos en documentos
- [x] Script `db/F9_cobros.sql` idempotente + verificación final

### F9.B — P100 Cobro de Cuotas ✅ (2026-06-07)

- [x] Eliminar botones SAVE/DELETE/CREATE genéricos del CRUD
- [x] Items de cuota como Display Only / Number Field readonly: `P100_ID_CXC`, `P100_NRO_CUOTA`, `P100_FECHA_VENCIMIENTO`, `P100_MONTO_CUOTA`, `P100_ESTADO`
- [x] Items nuevos para registrar pago:
  - `P100_ID_CAJA` Display Only desde `FN_CAJA_ABIERTA_USUARIO`
  - `P100_OFICINA` Hidden desde `FN_OFICINA_USUARIO_V2`
  - `P100_ID_TALONARIO_RC` Display Only desde `V_TALONARIOS_DISPONIBLES WHERE TIPO='RC'`
  - `P100_ID_FORMA_PAGO` Hidden fijo en 21 (Contado)
  - `P100_ID_METODO_PAGO` Select List desde `METODOS_PAGO`
  - `P100_MONTO_PAGO` Text Field con default = monto cuota (deuda: convertir a Number Field — ver F9.G)
  - `P100_VUELTO` Display Only, calculado vía DA con PL/SQL Expression
  - `P100_NRO_REFERENCIA` Text Field, visible si método ≠ Efectivo (condición VAL_OF_ITEM_IN_COND_NOT_EQ_COND2)
  - `P100_NRO_RECIBO_GENERADO` Display Only (se llena tras COBRAR)
  - `P100_ID_MOVIMIENTO_GENERADO` Hidden (para link de Imprimir Recibo)
- [x] Botón `COBRAR` invoca `FN_COBRAR_CUOTA` y rellena `NRO_RECIBO_GENERADO` + `ID_MOVIMIENTO_GENERADO`
- [x] Botón `IMPRIMIR` redirect a P119 con `P119_ID_RECIBO=&P100_ID_MOVIMIENTO_GENERADO.` — visible solo post-cobro
- [x] BEFORE_HEADER "Validar caja del dia": redirige a P65 con notification si no hay caja
- [x] BEFORE_HEADER "Validar talonario RC vigente": error inline si no hay talonario
- [x] DA "Calcular Vuelto": Change en MONTO_PAGO → Set Value PL/SQL Expression `GREATEST(NVL(:P100_MONTO_PAGO,0) - NVL(:P100_MONTO_CUOTA,0), 0)`
- [x] DA "Visibilidad Nro Referencia": Change en METODO_PAGO + JS Condition `$v('P100_ID_METODO_PAGO') != '1'` → True Show, False Hide
- [x] Test browser end-to-end: 2 cobros aplicados a CxC=2, recibos `001-001-0000001` y `0000002`, saldo bajado correctamente, JOB marcó cuotas vencidas, talonario RC incrementado
- [x] P100 re-exportado a `apex-work/f100/application/pages/page_00100.sql` + `delete_00100.sql`

### F9.C — P95/P99 retoques ✅ (2026-06-08)

- [x] **P95**: SQL source con `SALDO_PCT = ROUND(SALDO/TOTAL_A_PAGAR*100,1)`. Botón CREATE eliminado.
- [x] **P95**: badge HTML en ESTADO (no funciona el CSS — ver F9.G)
- [x] **P99**: SQL source con LEFT JOIN a `MOVIMIENTOS_CAJA` para mostrar FECHA_PAGO y NRO_RECIBO por cuota
- [x] **P99**: orden default por `NRO_CUOTA` ascendente
- [x] **P99**: badge HTML en ESTADO (no funciona el CSS — ver F9.G)
- [x] **P99**: botón CREATE eliminado (era el que abría P100 sin id)

### F9.D — Limpieza menú/páginas huérfanas ✅ (2026-06-08)

- [x] Eliminar P98 "Cobros de Cuotas"
- [x] Eliminar P93 "Cobros/Pagos" placeholder
- [x] Header de menú renombrado a "Cuentas a Cobrar" y `current_for_pages` cambiado de '93' a '95' — decisión PO 2026-06-08
- [x] Estructura header+child del menú se mantiene (decisión PO)

### F9.E — Estado de cuenta cliente (opcional, post-F9) 🕓

- [ ] Página nueva con saldo por cliente, cuotas vencidas, próximas a vencer
- [ ] Histórico de pagos

### F9.G — Cosmética visual (deuda técnica) 🕓

**Formato de números.** Durante F9.B se quitaron las format mask `999G999G999G990` de
`P100_MONTO_CUOTA`, `P100_MONTO_PAGO` y `P100_VUELTO` porque rompían los binds PL/SQL
(APEX serializa el valor formateado y la conversión implícita falla con separador de
miles). Los montos se muestran en crudo. Cuando se aborde:

- [ ] Opción A: agregar format mask sólo para presentación + parsear con
      `apex_util.string_to_number` en server side. Verificar primero que la función
      exista (no estaba en APEX 24.2.17 al armar F9).
- [ ] Opción B (más simple): usar Static ID + JS post-render con `Intl.NumberFormat`
      para formatear visualmente sin tocar el valor de sesión. El cálculo de vuelto
      ya está hecho en JavaScript Expression así que no rompe.
- [ ] Aplicar el mismo tratamiento a P67 (factura) y P95/P99 (cobros) para coherencia
      visual.

**P96 datos emisor hardcoded.** P96 (Documento Factura) sigue con `RUC: 80004571-1`,
`Denominación: SOLSGE` y `Dirección: Itauguá Km 25 Mboiy` hardcoded en el HTML. P119
ya migró a `FN_GET_PARAMETRO(...,'TEXTO')` leyendo de `PARAMETROS` TIPO=`EMPRESA`.
Aplicar el mismo patrón a P96 (y eventuales P6 / nuevos prints) para coherencia.

- [ ] Migrar P96 a `FN_GET_PARAMETRO('RUC','TEXTO')` / `'RAZON_SOCIAL'` / `'DIRECCION'`
- [ ] Capturar P96 al repo después del cambio

**Badges de estado.** En F9.C se intentó aplicar badge HTML con expresión condicional
del tipo `<span class="t-Label u-color-{case '&ESTADO.' when ...}">&ESTADO.</span>` en
P95 y P99. APEX HTML Expression no interpreta sintaxis SQL CASE — solo substitution
de columnas. Quedó como CSS class fijo (no condicional). Para arreglarlo:

- [ ] Opción A: agregar columna computed en el SQL del IG: `case ESTADO when 'PAGADA' then 'u-color-24' when 'PENDIENTE' then 'u-color-21' else 'u-color-14' end as ESTADO_CLASS`,
      y usar `<span class="t-Label t-Label--badge &ESTADO_CLASS.">&ESTADO.</span>` como HTML Expression.
- [ ] Opción B: usar atributo "CSS Classes" del column con expresión de IG (server-side processing).

### F9.F — P119 Documento Recibo ✅ (2026-06-08)

- [x] Crear P119 nueva, Modal Dialog, basada en patrón de P96 (factura print)
- [x] Item `P119_ID_RECIBO` recibe `ID_MOVIMIENTO`
- [x] Region Dynamic PL/SQL Content que lee de `V_RECIBOS_COBRO` + `DETALLE_MOVIMIENTO_CAJA`
- [x] HTML del recibo:
  - Cabecera con datos de emisor (RUC, denominación, dirección) + timbrado + vigencia
  - Título: `RECIBO DE COBRO`
  - Fecha emisión + datos cliente + cajero
  - Línea "Cobro de cuota N° X de la cuenta corriente #YYY (factura origen #...)"
  - Tabla detalle formas de pago + método + monto + nro referencia
  - Tabla total cobrado
- [x] Datos de emisor parametrizados en `PARAMETROS` con `TIPO_PARAMETRO='EMPRESA'` (claves `RUC`, `RAZON_SOCIAL`, `DIRECCION`). Se leen vía `FN_GET_PARAMETRO(p_clave, 'TEXTO')`.
- [x] Botón "IMPRIMIR" en P100 (tras COBRAR exitoso) → abre P119 con `P119_ID_RECIBO`
- [ ] Columna print en P95 sobre filas con cobros (reimprimir histórico) — deferido
- [x] Test browser end-to-end: cobrar cuota → ver modal P119 → confirmado por PO 2026-06-08
- [x] Capturado al repo: `apex-work/.../page_00119.sql` + `delete_00119.sql` + entry en `install_page.sql`

---

## 8. Test plan end-to-end (golden path F8)

1. **Setup**: usuario `TCASCO` con `EMPLEADOS.CODIGO_USUARIO='TCASCO'`. Caja 1 (oficina 1) configurada en `CAJA_CONF`. Sin caja abierta.
2. Login como `TCASCO`. Ir a Caja → Apertura. `P65_ID_EMPLEADO` ya muestra el id del empleado, `USU_APERTURA` se llena automáticamente. Cargar `MONTO_APERTURA` por moneda y submit.
3. Verificar BD: `CAJAS` nueva fila con `ESTADO='A'`, `USU_APERTURA='TCASCO'`, `FEC_APERTURA=hoy`.
4. Ir a Ventas → Proceso Ventas (P66). Click "Crear" → P67.
5. P67 muestra: oficina = 1 (de mi caja), talonario = FA (único vigente), tipo = FA. LOV de orden lista solo `APROBADO` (debería traer 183 y 203).
6. Elegir presupuesto 183. La IG `Detalle_V` muestra las líneas con IVA calculado. Totales arriba se calculan.
7. Forma de pago = Contado, método = Efectivo, monto pago = total exacto. Submit.
8. Esperado (todo en una transacción):
   - `COMPROBANTES` nueva fila con `NRO_COMPROBANTE` reservado (ej. `001-001-0000022`), `ESTADO='A'`, `ID_OFICINA=1`.
   - `DETALLE_COMPROBANTE` con N filas (las de la orden).
   - `MOVIMIENTOS_STOCK` con N filas tipo `SALIDA` (vía `TRG_MOV_STOCK_DETALLE`).
   - `STOCK_PRODUCTO.CANTIDAD` reducido (vía `TRG_ACTUALIZAR_STOCK_MOVIMIENTO`).
   - `RESERVAS_PRODUCTO` de la orden 183 → `ESTADO='ANULADA'` (vía `TRG_OV_LIBERA_RESERVA` extendido).
   - `ORDENES_VENTA` 183 → `ESTADO='FACTURADO'` (vía `TRG_FACTURA_ORDEN`).
   - `TALONARIOS` ID 1 → `NRO_ACTUAL=22` (vía `FN_RESERVAR_NRO_COMPROBANTE`).
   - `MOVIMIENTOS_CAJA` 1 fila `TIPO='INGRESO_VENTA'`, `ID_COMPROBANTE` poblado (vía proceso 25 P67).
   - `DETALLE_MOVIMIENTO_CAJA` 1 fila `ID_FORMA_PAGO=21`, monto = total.
   - `CUENTAS_COBRAR`: sin filas nuevas (contado).
9. Ir a P66: ver la factura recién emitida.
10. Cerrar caja (P61): `MONTO_CIERRE = MONTO_APERTURA + total facturado`.

### Edge cases

- Sin caja abierta → P67 redirige con error.
- Talonario vencido → error explícito.
- Stock insuficiente → factura aborta vía `TRG_MOV_STOCK_DETALLE` (`ORA-20005`), no quedan parciales.
- Race: dos usuarios facturando contra mismo talonario → ambos obtienen nros consecutivos sin colisión (`FOR UPDATE` en `FN_RESERVAR_NRO_COMPROBANTE`).
- Presupuesto `PENDIENTE` (no `APROBADO`) → no aparece en LOV.
- Presupuesto `FACTURADO` → no aparece y si se manipula la URL, el trigger `TRG_FACTURA_ORDEN` bloquea.

### Test colateral: venta a crédito (efecto automático de `TRG_INS_CUENTAS_COBRAR`)

Como el backend de crédito ya existe, vale la pena probarlo en F8 incluso si la pantalla de cobro llega en F9:

1. Repetir el flujo del golden path eligiendo `FORMA_PAGO=1` (Crédito) y un `PLAN_CUOTA` (ej. plan de 3 cuotas).
2. Esperado adicional:
   - `CUENTAS_COBRAR` 1 fila para el cliente, `TOTAL_A_PAGAR = total + interés del plan`, `SALDO = TOTAL_A_PAGAR`, `ESTADO='PENDIENTE'`.
   - `CUENTAS_COBRAR_DET` N filas (una por cuota), cada una `MONTO_CUOTA = TOTAL / N`, `FECHA_VENCIMIENTO` = comprobante + i meses, `ESTADO='PENDIENTE'`.
   - `MOVIMIENTOS_CAJA`: **sin filas** (la plata no entró).
   - `STOCK_PRODUCTO`: igual descontado (el stock se mueve sí o sí, lo paguen o no).

---

## 9. Cosas que NO se hacen en F8 (explícito)

- Pantalla de anulación de comprobante.
- Pantalla de cobro de cuotas de CxC (F9).
- Egresos manuales de caja (UI). El modelo soporta `TIPO='EGRESO'` pero no hay form.
- Reportes contables (libros IVA, retenciones).
- Manejo multi-moneda en venta contado (`MONEDA` distinta a `PYG`). Se soporta a nivel modelo pero P67 trabaja en moneda local; F8 no completa la conversión.
- Refactor de `TRG_CERRAR_CAJA_CONF` (queda como C8 — deuda).
- Limpiar las cajas heredadas con `ESTADO=NULL` (IDs 41, 42).
- Renombrar tablas / columnas más allá del rename de `RECIBOS_COBRO`.
- Reemplazar `FN_OBTENER_COMPROBANTE` en **P70 — Proceso de Compras**. Se posterga a una eventual F10-Compras.
- Reconstruir / eliminar **P93 placeholder** y **P98 redundante**. Pasan a F9 como deuda menor (CC7, CC8).

---

## 10. Preparación previa ejecutada (2026-06-06)

| Acción | Resultado |
|--------|-----------|
| `UPDATE CAJAS SET ESTADO='C', FEC_CIERRE=SYSTIMESTAMP, USU_CIERRE='ADMIN', OBSERVACION='Cierre administrativo (dato sucio previo F8)…' WHERE ID_CAJA=2 AND ESTADO='A'` | ✅ Caja 2 cerrada. `USU_CIERRE='ADMIN'`, `FEC_CIERRE='2026-06-06 04:33'`. |
| `UPDATE TALONARIOS SET FECHA_FIN=DATE '2027-12-31' WHERE ID_TALONARIO IN (1,21)` | ✅ FA y NC vigentes hasta 2027-12-31. |
| `INSERT INTO TALONARIOS (...) VALUES (1,'RC','1','1',1,0,100,'111222333',DATE '2025-01-01',DATE '2027-12-31','S')` | ✅ Talonario **RC** creado, ID 41, oficina 1, vigente 2025-01-01 → 2027-12-31, rango 1–100. Necesario para F9 (recibos de cobro). |

---

## 11. Aprobación

> Plan pendiente de aprobación. Una vez confirmado, F8.A arranca con el
> script `db/F8_facturacion.sql`.

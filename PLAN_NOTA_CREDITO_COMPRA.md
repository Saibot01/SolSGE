# Plan de implementación — Nota de Crédito de Compra / Proveedor (F26)

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db` (conectás como ADMIN; los datos viven en `WKSP_WORKPLACE` → usar `ALL_*`, no `USER_*`)
**Estado del plan:** ✅ IMPLEMENTADO — 2026-07-03 (H1–H5 hechos y validados por el PO por navegador, incl. NC 102 y documento P151 que imprime bien). Solo resta el commit `feat(F26)` (H6), pendiente de OK del PO.
**Rango de error reservado:** `-20910 … -20920` (bloque libre entre F22 `-20904..-20909` y F23 `-20921..-20929`).
**Páginas APEX:** **P94** "Nota de Crédito Proveedor" (hoy cascarón vacío → se construye) · (opcional) **P95x** Documento NC de compra imprimible.

> Feature **transaccional** del lado **compras**. Espejo **invertido y recortado** de
> la NC de venta (`PLAN_NOTA_CREDITO.md`, F14): documenta el crédito que **el
> proveedor** nos emite contra una **factura de compra** (`COMPROBANTES_PROVEEDOR`),
> reduce la **deuda a pagar** (`CUENTAS_PAGAR`, de F24) y, si es devolución de
> mercadería, saca stock (`SALIDA`). Consume F24 y alimenta la resta de gasto de F25.

---

## 1. Contexto y diferencia central con F14

La NC de **venta** (F14) la **emitimos nosotros** al cliente: por eso lleva
workflow de solicitud→aprobación (4 ojos), reserva un número de **nuestro**
talonario NC, y su efecto es EGRESO de caja / reversión de CxC.

La NC de **compra es el espejo invertido y más simple**: el **proveedor la emite y
nos la manda ya hecha**; nosotros solo la **capturamos** (como se registra una
factura de compra en P69/P70) y aplicamos sus efectos. Consecuencias de diseño:

| Aspecto | NC Venta (F14) | NC Compra (F26) |
|---|---|---|
| ¿Quién emite? | Nosotros → cliente | **Proveedor → nosotros** |
| ¿Se genera o se recibe? | Se **genera** | Se **recibe** y se **captura** |
| Workflow de aprobación | Sí (solicita/aprueba) | **No — captura directa** (decisión PO §2) |
| Número / talonario propio | Sí (reserva atómica) | **No** — se guarda el `NRO_COMPROBANTE` que trajo el proveedor |
| Documento origen | Factura de venta (`COMPROBANTES`) | Factura de compra (`COMPROBANTES_PROVEEDOR`) |
| Saldo que ajusta | **CxC** (nos deben) | **CxP** (le debemos) |
| Stock | **ENTRADA** (nos devuelven) | **SALIDA** (devolvemos al proveedor) |
| Caja | EGRESO (devolvemos plata) | **Fuera de alcance** (decisión PO §2) |
| Costo del producto | N/A | No se recalcula (decisión PO §2) |

**Resultado:** F26 no necesita tablas de staging (`SOLICITUDES_*`), ni reserva de
número, ni páginas de aprobación. Es ~40 % menos código que F14: un formulario de
captura (**P94**) + un procedure de aplicación + un ajuste de una vista de F25.

---

## 2. Decisiones del PO (2026-07-02)

| # | Tema | Decisión |
|---|------|----------|
| 1 | **Workflow** | **Captura directa, un solo paso.** El proveedor ya emitió la NC → no hay solicitud/aprobación ni reserva de número. P94 captura y al Guardar se aplican los efectos en una transacción. (Si en el futuro se quiere control de 4 ojos sobre la baja de CxP, se agrega; no es intrínseco como en F14.) |
| 2 | **Caja / reembolso** | **Fuera de alcance.** Igual que F24: sin impacto en `MOVIMIENTOS_CAJA` (exige `ID_CLIENTE`/`ID_CAJA` NOT NULL, sin `ID_PROVEEDOR`). La NC solo baja **CxP pendiente**; si la factura ya se pagó (saldo 0) → **bloqueo** `-20915` (reembolso = deuda futura). |
| 3 | **Costo / valorización** | **No recalcular.** La NC de ajuste/descuento baja CxP pero **no** toca `FN_COSTO_PONDERADO` ni la valorización de Inventario (F23). Documentado como deuda futura (mismo criterio que R7 del interés en F14). |
| 4 | **Motivos** | **Los 8 motivos SIFEN quedan seleccionables** (transcribimos el que el proveedor puso en su NC — no lo elegimos nosotros). El sistema **solo deriva el efecto de stock**: Devolución (1, 2) → `SALIDA`; resto (3–8) → no mueve stock. Ver §4. |
| 5 | **Referencia a la factura origen** | Se reutiliza **`COMPROBANTES_PROVEEDOR.ID_FAC_ORIGEN`** (ya es `NUMBER` → apunta al `ID_COMPROBANTE` de la factura de compra). Es el vínculo autoritativo. |
| 6 | **Desacople CxP ↔ stock según recepción** | Los dos efectos tienen **prerrequisitos distintos** (ver §4.1). **CxP:** la deuda nace al *registrar* la factura (F24), **no** requiere recepción → un descuento/ajuste/bonificación es válido aunque la mercadería no se haya recibido. **Stock (solo devolución):** solo se puede devolver **lo recibido** → el tope de la devolución es la **cantidad recibida** menos lo ya devuelto, no la facturada. Si no hay recepción, no hay devolución posible (`-20919`). Resuelve la inconsistencia de SALIDA fantasma. |

---

## 3. Estado actual relevado (`tesis_db`, 2026-07-02)

### 3.1 Lo que ya existe (groundwork)
- **`COMPROBANTES_PROVEEDOR`** soporta `TIPO_COMPROBANTE CHAR(2)` (hoy 19 filas,
  **todas `FA`**, ninguna `NC`), y trae **`ID_FAC_ORIGEN NUMBER`** (¡numérico, no el
  `VARCHAR2` legacy del lado venta!) → hook de referencia listo. También tiene
  `FORMA_PAGO` (F24), `MONEDA`/`TIPO_CAMBIO`, `NRO_COMPROBANTE`, `NRO_TIMBRADO`,
  `FECHA_EMISION`, `ID_OFICINA`, `ID_ORDEN_COMPRA`, `TOTAL_COMPROBANTE`.
- **`DETALLE_COMPROBANTE_PROV`**: `ID_PRODUCTO`, `CANTIDAD`, `PRECIO_UNITARIO`,
  `TOTAL` (líneas reutilizables para la NC).
- **`MOTIVOS_NOTA_CREDITO`**: 8 motivos activos (F11.2), reutilizable tal cual.
- **`CUENTAS_PAGAR`** (F24): PK `ID_CXP`, **una CxP por factura**, referenciada por
  **`ID_COMPROBANTE`** = la factura. Columnas `SALDO`, `TOTAL_A_PAGAR`, `ESTADO`
  (`PENDIENTE`/`PARCIAL`/`PAGADA`), `FECHA_VENCIMIENTO`. → la NC ubica su CxP con
  `WHERE ID_COMPROBANTE = <NC.ID_FAC_ORIGEN>`.
- **`MOVIMIENTOS_STOCK`**: `TIPO_MOVIMIENTO` (usar `'SALIDA'`), `ID_PRODUCTO`,
  `ID_OFICINA`, `CANTIDAD`, `FECHA_MOVIMIENTO`, `REFERENCIA`, `OBSERVACION`. El stock
  de compra entra por recepción (`TRG_MOV_STOCK_RECEPCION` → `ENTRADA`); el reverso
  de la NC lo hacemos **explícito** (`SALIDA`) en el procedure.
- **Trigger `TRG_MOV_STOCK_DETALLE_PROV` DISABLED**: insertar detalle de compra **no**
  mueve stock → un INSERT de detalle de NC no dispara efectos indeseados (igual que
  en F14; el stock se maneja explícito).
- **Página P94 "Nota de Credito Proveedor"** existe pero es **cascarón puro**: un IG
  sin source, **sin items, sin botones, sin procesos**. Se construye desde cero.

### 3.2 Triggers a vigilar (clave para el diseño)
- **`TRG_INS_CUENTAS_PAGAR`** (`AFTER INSERT OR UPDATE ON COMPROBANTES_PROVEEDOR`):
  crea CxP **solo si `FORMA_PAGO='1'`**. → **La NC debe insertarse con
  `FORMA_PAGO ≠ '1'`** (NULL o `'21'`) para no generar una **CxP fantasma** para la
  propia NC. Es el espejo exacto de la decisión #8 de F14 (`FORMA_PAGO` de la NC ≠ '1').
- `TRG_ACTUALIZAR_COSTO_COMPRA` (`AFTER UPDATE`, copia precio a costo al pasar a `'C'`):
  actúa sobre UPDATE; la NC nace y queda; no lo dispara de forma indeseada (y por
  decisión #3 no queremos tocar costo). Verificar en el smoke que un INSERT de NC no
  lo active.

### 3.3 Realidad de datos que ejercita casos borde
- **CxP #4 (comprobante 42) está `PAGADA`, `SALDO=0`** → una NC contra esa factura
  dispara el bloqueo `-20915` (excede saldo pendiente / reembolso fuera de alcance).
  El escenario existe hoy: hay que bloquearlo **explícitamente**, no ignorarlo.
- Facturas contado presentes (`FORMA_PAGO='21'`): sin CxP → la NC sobre ellas también
  bloquea (nada que acreditar en cuenta; reembolso fuera de alcance).
- **Facturas con deuda pero SIN mercadería recibida (el caso de la duda del PO):** los
  comprobantes demo **88–97** están `ESTADO='C'` con CxP (saldo hasta 12,6 M) pero
  **`TOTAL_RECIBIDO_OC = 0`** (el seed de F25 los creó sin recepciones). También comp
  **1** (`ESTADO='R'`, saldo 3,4 M) recibió solo parte. → una NC **devolución** contra
  ellas generaría **SALIDA de stock fantasma**. La inconsistencia **existe hoy en los
  datos**, no es teórica → el tope de stock por recibido (§4.1, §5.1 Paso 4) es
  obligatorio, no opcional.
- **La recepción se rastrea por OC, no por comprobante:** `RECEPCIONES_COMPRA`
  (`ID_ORDEN_COMPRA` NOT NULL, `ID_COMPROBANTE` nullable) + `DETALLE_RECEPCION_COMPRA`
  (`ID_PRODUCTO`, `CANTIDAD_RECIBIDA`, `ID_DETALLE_OC`). Varios comprobantes pueden
  compartir una OC (comp 1 y 3 comparten OC #1). → el "recibido por producto" se computa
  por **producto dentro de la OC** de la factura (o por `ID_COMPROBANTE` cuando la
  recepción lo trae seteado).

### 3.4 Punto exacto a tocar en F25
`V_CMP_COMPRA` termina con `WHERE c.TIPO_COMPROBANTE = 'FA' AND c.ESTADO <> 'A' AND
c.TOTAL_COMPROBANTE IS NOT NULL`. Para restar la NC del gasto se agrega un
**`UNION ALL`** que trae `TIPO_COMPROBANTE='NC'` con `-TOTAL_COMPROBANTE` (todas las
dimensiones — proveedor, período, oficina — ya están en la tabla). El resto de F25
(`V_CMP_GASTO_MES`, dashboard P144, informe P145) hereda la resta automáticamente.

---

## 4. Análisis de motivos (los 8, cómo aplican del lado compra)

Como el **proveedor** elige el motivo de **su** NC, del lado comprador **los
transcribimos todos**. Lo único que el sistema deriva es el **efecto de stock**.

| Cód | Descripción (catálogo real) | Aplicabilidad en compra | ¿Stock? | Efecto financiero |
|---|---|---|---|---|
| **1** | Devolución y ajuste de precios | Alta — devolvemos mercadería y/o corrige precio | **Sí → SALIDA** | Baja CxP |
| **2** | Devolución | Alta — devolvemos mercadería fallada/errónea/vencida | **Sí → SALIDA** | Baja CxP |
| **3** | Descuento | Alta — descuento post-factura (volumen, pronto pago) | No | Baja CxP |
| **4** | Bonificación | Alta — bonificación comercial del proveedor | No | Baja CxP |
| **5** | Crédito incobrable | Baja/atípica — el proveedor condona deuda que le debemos | No | Baja CxP |
| **6** | Recupero de costo | Baja/atípica — el proveedor nos acredita un costo | No | Baja CxP |
| **7** | Recupero de gasto | Baja/atípica — ídem, un gasto | No | Baja CxP |
| **8** | Ajuste de precio | Alta — nos facturó de más; corrige el precio | No | Baja CxP (costo no se recalcula, dec. #3) |

**Regla de stock (idéntica a F14):** `DEVUELVE_STOCK = 'S'` sii `COD_MOTIVO IN (1,2)`;
resto `'N'`. Se **deriva** en el backend, no lo carga el usuario.

**Nota UI:** los 8 se ofrecen en el select. Los motivos 5/6/7 son atípicos del lado
compra pero **posibles** (el proveedor pudo emitir su NC con ese código); no se
bloquean. La única semántica que el sistema impone es el efecto de stock.

### 4.1 Dos efectos, dos prerrequisitos (desacople CxP ↔ stock)

El efecto financiero y el efecto de stock **no dependen de lo mismo** — separarlos es lo
que evita la SALIDA de stock fantasma:

| Efecto | ¿De qué depende? | Tope |
|---|---|---|
| **Baja de CxP** (todos los motivos) | De que exista **deuda** (CxP con `SALDO>0`). La deuda nace **al registrar** la factura (F24), **no** al recibir. | Monto: `total NC ≤ SALDO pendiente` |
| **SALIDA de stock** (solo Devolución 1,2) | De haber **recibido** físicamente la mercadería (`RECEPCIONES_COMPRA`). Solo se devuelve lo que se tiene. | Cantidad: `devuelto ≤ recibido − ya devuelto` (por producto) |

**Consecuencias:**
- **Descuento / Ajuste / Bonificación / Recupero** (3–8): válidos **aunque no se haya
  recibido** la mercadería (solo tocan CxP). Este es el caso de "factura registrada,
  mercadería en camino, llega un descuento" → consistente, sin stock.
- **Devolución** (1, 2): **exige recepción**. El tope de cada línea es lo **recibido**,
  no lo facturado. Si la factura no tiene mercadería recibida (recibido = 0 en todas las
  líneas) → la devolución se **bloquea** (`-20919`): no se puede devolver lo que no se
  recibió. Si el proveedor de hecho acredita mercadería no entregada, en realidad es un
  **descuento/anulación** → el usuario elige un motivo sin stock.
- **Recepción parcial** (`ESTADO='PR'`, o `C` con recibido < facturado): la devolución
  se capa a lo recibido; el excedente no es devolvible (usar motivo sin stock para esa
  porción).

---

## 5. Diseño

### 5.1 Esquema — `db/F26_nota_credito_compra.sql` (idempotente)

**Paso 1 — Columna nueva en `COMPROBANTES_PROVEEDOR`** (nullable; solo la llena la NC):
```sql
COD_MOTIVO  NUMBER(2)   -- FK MOTIVOS_NOTA_CREDITO(COD_MOTIVO), solo para TIPO='NC'
```
- FK `FK_CMPPROV_MOTIVO_NC`.
- **No** se agrega CHECK validado sobre `COD_MOTIVO` (evita backfill sobre las 19 FA
  existentes con `COD_MOTIVO` NULL); la obligatoriedad para NC se garantiza en el
  procedure de captura.
- `ID_FAC_ORIGEN` (ya existe, `NUMBER`) = referencia autoritativa a la factura origen.

**Paso 2 — Dos topes distintos (§4.1): monto para CxP, cantidad recibida para stock.**

- **`FN_CANT_ACREDITABLE_COMPRA(p_id_detalle_origen) RETURN NUMBER`** — tope de la
  **línea a los fines de la NC/CxP**: cantidad facturada en esa línea − Σ cantidades ya
  acreditadas por NC de compra **existentes** sobre esa misma línea. Anti-doble-crédito
  (espejo de `FN_CANT_ACREDITABLE`). Se usa para descuento/ajuste/bonif/recupero (no
  dependen de recepción).
- **`FN_CANT_DEVOLVIBLE_COMPRA(p_id_detalle_origen) RETURN NUMBER`** — tope **de stock
  para devolución**: `Σ recibido de ese producto en la OC de la factura` (vía
  `RECEPCIONES_COMPRA`→`DETALLE_RECEPCION_COMPRA`, o por `ID_COMPROBANTE` si la recepción
  lo trae) − `Σ ya devuelto` por NC de devolución previas. **Devuelve 0 si no hubo
  recepción** → bloquea la SALIDA fantasma. Solo se aplica cuando `COD_MOTIVO IN (1,2)`.
- El tope efectivo de una línea en una **devolución** es `LEAST(acreditable,
  devolvible)`; en los demás motivos es solo `acreditable`.

*(Traza línea NC↔línea factura: se guarda el `ID_DETALLE` origen en el detalle de la NC
— ver Paso 5, `DETALLE_COMPROBANTE_PROV.ID_DETALLE_ORIGEN`.)*

**Paso 3 — `FN_NC_COMPRA_ELEGIBLE(p_id_factura) RETURN VARCHAR2`** (mensaje / NULL)
Bloquea (devuelve texto) si:
- factura inexistente / no es `TIPO='FA'` / `ESTADO='A'` (anulada);
- **`FORMA_PAGO ≠ '1'`** (contado: no hay CxP → reembolso fuera de alcance);
- **sin CxP con `SALDO > 0`** (ya pagada: `-20915` conceptual, reembolso fuera de alcance);
- ya acreditada al 100 % por NC previas.

**Paso 4 — `PRC_REGISTRAR_NC_COMPRA(...)`** (atómica, un solo paso — captura + efectos)
Parámetros: `p_id_factura`, `p_cod_motivo`, `p_nro_comprobante` (el nº que trajo el
proveedor), `p_nro_timbrado`, `p_fecha_emision` (fecha del documento del proveedor),
`p_observacion`, y las **líneas** a acreditar `[(id_detalle_origen, cantidad,
precio_unitario)]`. Lógica:
1. Validar elegibilidad (`FN_NC_COMPRA_ELEGIBLE`); si bloquea → `-20911`.
2. Derivar `v_devuelve_stock` del motivo (1,2→'S').
   Validar cada línea: `0 < cantidad ≤ FN_CANT_ACREDITABLE_COMPRA` (`-20912`) y
   `0 < precio ≤ precio facturado` (`-20913`). Al menos una línea (`-20914`).
   **Si `v_devuelve_stock='S'` (devolución):** además `cantidad ≤
   FN_CANT_DEVOLVIBLE_COMPRA` por línea (`-20919` "no se puede devolver más de lo
   recibido"); si el total devolvible de la factura es 0 (sin recepción) → `-20919`
   ("la factura no tiene mercadería recibida; para un descuento/anulación usá un motivo
   sin devolución").
3. Calcular `v_total = Σ(cantidad × precio)`.
4. **Cap CxP:** localizar la CxP (`WHERE ID_COMPROBANTE = p_id_factura` `FOR UPDATE`);
   si `v_total > SALDO` → `-20915` ("la NC excede el saldo pendiente; el reembolso de
   lo ya pagado está fuera de alcance"). Sin CxP → `-20916`.
5. **INSERT `COMPROBANTES_PROVEEDOR`**: `TIPO_COMPROBANTE='NC'`, `ESTADO='R'`
   (registrada; se puede usar `'A'`? **no** — `'A'`=anulada), `ID_PROVEEDOR`/`MONEDA`/
   `TIPO_CAMBIO`/`ID_OFICINA` de la factura, `ID_ORDEN_COMPRA=NULL`,
   **`FORMA_PAGO=NULL`** (evita `TRG_INS_CUENTAS_PAGAR` fantasma — §3.2),
   `COD_MOTIVO=p_cod_motivo`, `ID_FAC_ORIGEN=p_id_factura`,
   `NRO_COMPROBANTE=p_nro_comprobante`, `NRO_TIMBRADO=p_nro_timbrado`,
   `FECHA_EMISION=p_fecha_emision`, `TOTAL_COMPROBANTE=v_total`.
6. **INSERT `DETALLE_COMPROBANTE_PROV`** por línea (no mueve stock: trigger DISABLED).
7. **Stock** (si `v_devuelve_stock='S'`): por línea (ya validada `≤ devolvible` en el
   paso 2), **guarda de stock no-negativo** — verificar que el on-hand actual
   (`STOCK_PRODUCTO.CANTIDAD` de ese producto/oficina, el saldo autoritativo de F23)
   `≥ cantidad`; si no → `-20920` ("stock insuficiente para la devolución: la mercadería
   ya no está disponible", típico cuando ya se vendió). Luego INSERT `MOVIMIENTOS_STOCK
   TIPO='SALIDA'`, `CANTIDAD`, `ID_OFICINA` = la de la factura (`NVL(oc.ID_OFICINA,
   c.ID_OFICINA)`, mismo patrón que `V_CMP_COMPRA`), `FECHA_MOVIMIENTO=FN_AHORA`,
   `REFERENCIA='NC COMPRA '||<id_nc>`, `OBSERVACION` cita la factura origen. (Nunca genera
   stock fantasma ni negativo: el tope por recibido + la guarda de on-hand lo garantizan.)
8. **CxP:** `UPDATE CUENTAS_PAGAR SET SALDO = SALDO - v_total,
   ESTADO = CASE WHEN SALDO - v_total <= 0 THEN 'PAGADA'* ELSE 'PARCIAL' END
   WHERE ID_COMPROBANTE = p_id_factura`.
   \* Si `SALDO` llega a 0 por NC total, marcar `'ANULADA'` (no `'PAGADA'`: no se pagó,
   se acreditó). Definir etiqueta con el PO; sugerido **`'ANULADA'`** cuando el saldo
   queda en 0 por crédito total y `'PARCIAL'` si baja parcial.
9. Sin `COMMIT` en el procedure (APEX commitea — patrón F11/F14).

**Paso 5 — Trazabilidad de línea (decisión de implementación).** Para que
`FN_CANT_ACREDITABLE_COMPRA` sepa cuánto se acreditó por línea, guardar el
`ID_DETALLE` de la factura origen en el detalle de la NC. Como
`DETALLE_COMPROBANTE_PROV` **no** tiene columna de "detalle origen", opciones:
(a) agregar `DETALLE_COMPROBANTE_PROV.ID_DETALLE_ORIGEN NUMBER` (nullable, la llena
solo la NC) — **recomendado**, es limpio; (b) trazar por `ID_PRODUCTO` (frágil si el
mismo producto está en 2 líneas). Se toma (a).

**Paso 6 — Vista `V_NC_COMPRA`** (NC emitidas por proveedor: cabecera + proveedor +
motivo + factura origen derivada por join) → listado/documento.

**Paso 7 — Verificación** (counts, idempotencia, smoke con `ROLLBACK`).

> **Rango de error F26: `-20910 … -20920`.** Asignación tentativa: `-20911`
> elegibilidad; `-20912` cantidad excede acreditable; `-20913` precio fuera de rango;
> `-20914` sin líneas; `-20915` excede saldo pendiente (reembolso fuera de alcance);
> `-20916` factura sin CxP; `-20917` motivo inexistente; `-20918` factura no es FA /
> anulada; **`-20919` devolución que excede lo recibido / factura sin mercadería
> recibida**; **`-20920` stock insuficiente para la devolución (on-hand < cantidad; ya
> vendido)**.

### 5.2 F25 — resta del gasto (`db/F25_1_vistas_compras.sql`, in-place)

`V_CMP_COMPRA` gana un `UNION ALL` que trae los `TIPO_COMPROBANTE='NC'` (`ESTADO<>'A'`,
`TOTAL_COMPROBANTE IS NOT NULL`) con **`-TOTAL_COMPROBANTE`** como `TOTAL`, mismas
dimensiones (proveedor/oficina/comprador/periodo). El gasto neto queda `Σ FA − Σ NC`.
`ESTADO_LABEL`='Nota de crédito', `CONDICION`=NULL. **Footgun de despliegue:** el
cambio vive en el archivo de vistas de F25 → re-correr `F25_1_vistas_compras.sql`.

### 5.3 APEX — P94 (captura directa)

P94 hoy es cascarón vacío. Se construye siguiendo el patrón F14/F24 (**el PO arma el
shell en el Builder, Claude cablea**). Spec del shell:

- **Items:** `P94_ID_FACTURA` (selector de factura de compra origen; LOV de
  `COMPROBANTES_PROVEEDOR` `TIPO='FA'`, `ESTADO<>'A'`, `FORMA_PAGO='1'`, con CxP
  `SALDO>0`), `P94_COD_MOTIVO` (Select List, LOV `MOTIVOS_NOTA_CREDITO`),
  `P94_NRO_COMPROBANTE` (Text, el nº del proveedor), `P94_NRO_TIMBRADO` (Text),
  `P94_FECHA_EMISION` (Date Picker, fecha del documento del proveedor),
  `P94_OBSERVACION` (Textarea), `P94_BLOQUEO` (display-only, de `FN_NC_COMPRA_ELEGIBLE`).
- **Región "Datos de la factura"** (Static/Display): proveedor, nº factura, total,
  saldo CxP, condición — todo derivado del `P94_ID_FACTURA` elegido.
- **Región "Líneas a acreditar"**: **Interactive Grid editable**, PK
  `ID_DETALLE_ORIGEN`, source parecido al de P125 pero sobre compra:
  ```sql
  SELECT dcp.ID_DETALLE AS ID_DETALLE_ORIGEN, dcp.ID_PRODUCTO,
         pr.NOMBRE AS PRODUCTO, dcp.CANTIDAD AS CANT_FACTURADA,
         WKSP_WORKPLACE.FN_CANT_ACREDITABLE_COMPRA(dcp.ID_DETALLE) AS CANT_ACREDITABLE,
         WKSP_WORKPLACE.FN_CANT_DEVOLVIBLE_COMPRA(dcp.ID_DETALLE) AS CANT_DEVOLVIBLE,
         dcp.PRECIO_UNITARIO, 0 AS CANT_ACREDITAR, dcp.PRECIO_UNITARIO AS PRECIO_ACREDITAR
    FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV dcp
    JOIN WKSP_WORKPLACE.PRODUCTOS pr ON pr.ID_PRODUCTO = dcp.ID_PRODUCTO
   WHERE dcp.ID_COMPROBANTE = :P94_ID_FACTURA
  ```
  Editables: `CANT_ACREDITAR` y `PRECIO_ACREDITAR` (≤ facturado); resto read-only;
  toolbar oculta (guardado solo por el botón). **Tope de `CANT_ACREDITAR` según motivo:**
  si el motivo es **Devolución** (1,2), el tope es `LEAST(CANT_ACREDITABLE,
  CANT_DEVOLVIBLE)` y se muestra `CANT_DEVOLVIBLE` como columna visible (el usuario ve
  cuánto puede devolver); si es otro motivo, el tope es `CANT_ACREDITABLE` y
  `CANT_DEVOLVIBLE` puede ocultarse. La UI valida el tope, pero el **backend
  re-valida** (`-20912`/`-20919`) — la UI no es la guarda autoritativa.
- **Botón `REGISTRAR`** (Submit): oculto si `P94_BLOQUEO` no es NULL.
- **Claude cablea:** LOVs, columnas editables/read-only, BEFORE_HEADER que setea
  `P94_BLOQUEO` (`FN_NC_COMPRA_ELEGIBLE`), proceso AFTER_SUBMIT que llama
  `PRC_REGISTRAR_NC_COMPRA` con las líneas del IG (`CANT_ACREDITAR>0`), validaciones,
  y redirección/limpieza. Un solo submit (no hay pantalla de aprobación).

> **Regla del PO:** re-exportar P94 del Builder **antes** de editar y re-importar
> **aislado** (`install_p94.sql`, no el `install_page.sql` completo). El menú lo agrega
> el PO en el Builder ("Nota de Crédito Proveedor" bajo Compras).

### 5.4 APEX — Documento imprimible (opcional, fase 2)

`FN_KUDE_NC_COMPRA_HTML(p_id_nc)` espejando **`FN_KUDE_FACTURA_PROV_HTML`** (P97,
`db/kude_factura_proveedor.sql`): emisor = proveedor, receptor = nuestra empresa,
título "Nota de Crédito — registro interno", motivo, referencia a la factura origen
por join, líneas acreditadas, leyenda "sin validez fiscal". Página P95x (Dynamic
Content, estilo `kude`). **No** es DE SIFEN (no lo emitimos nosotros; es constancia
interna del documento que mandó el proveedor).

### 5.5 Despliegue
- DB (stdin redirect, por el bug del `@file`): `sql -S -name tesis_db <
  db/F26_nota_credito_compra.sql`, luego re-correr `db/F25_1_vistas_compras.sql`.
- APEX: `install_p94.sql` aislado.

---

## 6. Hitos

- [x] **H1 — Esquema + backend** (`db/F26_nota_credito_compra.sql`). **HECHO 2026-07-03.**
  `COD_MOTIVO` + `DETALLE_COMPROBANTE_PROV.ID_DETALLE_ORIGEN` + FK + `FN_CANT_ACREDITABLE_COMPRA`
  + `FN_CANT_DEVOLVIBLE_COMPRA` (tope por recibido) + `FN_NC_COMPRA_ELEGIBLE` +
  `PRC_REGISTRAR_NC_COMPRA` (array-based) + `V_NC_COMPRA` + verificación (2 columnas,
  0 inválidos). Smoke con `ROLLBACK` OK: ver §11.
- [x] **H2 — F25 resta de gasto** (`db/F25_1_vistas_compras.sql`). **HECHO 2026-07-03.**
  `V_CMP_COMPRA` ahora incluye `TIPO IN ('FA','NC')` con NC en `TOTAL` negativo + columna
  `TIPO_COMPROBANTE`; `V_CMP_LINEA` filtra FA (top productos sin líneas de NC);
  `V_CMP_GASTO_MES.N_COMPRAS` cuenta solo FA. Smoke: gasto 91.022.000→90.918.000 (resta la
  NC), N_COMPRAS y V_CMP_LINEA sin cambios. 8 vistas VALID. Ver §11.
- [x] **H3 — P94 (captura)**. **HECHO 2026-07-03** (Claude armó la página entera, decisión
  del PO). Espejo de P147/F24: región form (factura/motivo/nro/timbrado/fecha/observación)
  + Classic Report de líneas con `APEX_ITEM.HIDDEN`/`TEXT` + botón REGISTRAR + proceso que
  arma `SYS.ODCINUMBERLIST` y llama `PRC_REGISTRAR_NC_COMPRA` + DA refresh. Import aislado
  `install_p94.sql` OK; registrada en `install_page.sql`. Validada a nivel consulta. Ver §11.
- [x] **H4 — Documento imprimible** `FN_KUDE_NC_COMPRA_HTML` (`db/F26_1_kude_nc_compra.sql`)
  + **P151** "Documento Nota de Credito Proveedor". **HECHO 2026-07-03.** Espejo de
  `FN_KUDE_FACTURA_PROV_HTML`/P149: emisor=proveedor, receptor=nuestra empresa, muestra
  **motivo** + **documento asociado** (factura origen por join), desglose de IVA por
  producto, "sin validez fiscal". Verificado contra NC 102 (HTML 2135 chars). Import
  aislado `install_p151.sql` + registrada en `install_page.sql`. Ver §11.
- [x] **H5 — Test e2e por navegador** (PO, 2026-07-03): capturó la **NC 102** (devolución
  total a crédito sobre comp 2) → CxP anulada, SALIDA de stock, on-hand 79→78, factura
  intacta, resta del gasto F25. Documento P151 verificado (abre como modal, **imprime bien**).
- [~] **H6 — Cierre**: `CLAUDE.md` (entrada F26) ✔, plan ✔. Commit `feat(F26)` pendiente de OK del PO.

---

## 7. Test plan

| Caso | Escenario | Esperado |
|------|-----------|----------|
| A | NC **descuento** (3) parcial sobre factura crédito con saldo | NC registrada `TIPO='NC'`; **sin** stock; `CUENTAS_PAGAR.SALDO` baja por el monto |
| B | NC **devolución** (2) sobre factura crédito | NC registrada; **`MOVIMIENTOS_STOCK SALIDA`** por las cantidades; CxP baja |
| C | NC **total** (todas las líneas al 100 %) | CxP `SALDO=0`, `ESTADO='ANULADA'` (a confirmar etiqueta con PO) |
| D | NC sobre factura **ya pagada** (CxP #4, saldo 0) | Bloqueo `-20915` (reembolso fuera de alcance) |
| E | NC sobre factura **contado** (`FORMA_PAGO='21'`) | Bloqueo (sin CxP) en `FN_NC_COMPRA_ELEGIBLE` |
| F | **Doble crédito** (cantidad > acreditable) | Bloqueo `-20912` |
| G | NC que **excede el saldo pendiente** (parcialmente pagada) | Bloqueo `-20915` |
| H | Idempotencia: correr `F26_nota_credito_compra.sql` 2× | Sin error, verificación OK |
| I | Impacto F25: gasto neto = Σ FA − Σ NC | P144/P145 restan la NC |
| J | **Sin CxP fantasma**: la NC (`FORMA_PAGO=NULL`) no dispara `TRG_INS_CUENTAS_PAGAR` | No se crea CxP para la NC |
| K | NC **devolución** contra factura con deuda pero **sin recepción** (comp 88–97 demo) | Bloqueo `-20919` (no hay stock recibido); **sin** SALIDA fantasma |
| L | NC **descuento** contra la misma factura sin recepción | **Permitido**: baja CxP, **sin** stock (los motivos no-devolución no dependen de recepción) |
| M | NC **devolución** parcial: recibido 4 de 10 facturados, devolver 6 | Bloqueo `-20919` en esa línea (tope = 4); devolver ≤4 pasa |
| N | NC **devolución** de mercadería recibida pero **ya vendida** (on-hand < cantidad) | Bloqueo `-20920` (guarda de stock no-negativo); nunca deja stock negativo |

---

## 8. Riesgos / fuera de alcance (deuda futura)

| # | Tema | Tratamiento |
|---|------|-------------|
| R1 | **CxP fantasma** si la NC entra con `FORMA_PAGO='1'`. | Insertar la NC con `FORMA_PAGO=NULL` (§3.2, espejo dec. #8 de F14). Caso J del test. |
| R2 | **Reembolso de factura ya pagada** (contado o crédito saldado). | Fuera de alcance (dec. #2): bloqueo `-20915`. `MOVIMIENTOS_CAJA` no tiene `ID_PROVEEDOR` (mismo límite que F24). |
| R3 | **Costo ponderado** no se recalcula ante ajuste/descuento. | Fuera de alcance (dec. #3); documentado. `FN_COSTO_PONDERADO`/F23 intactos. |
| R4 | Doble crédito parcial concurrente. | `FN_CANT_ACREDITABLE_COMPRA` + `SELECT ... FOR UPDATE` de la CxP + re-check en el procedure. |
| R5 | Etiqueta de `ESTADO` de la CxP saldada por crédito total (`'ANULADA'` vs `'PAGADA'`). | **Resuelto (H1):** se usa `'ANULADA'` cuando el saldo queda ≤0 por crédito (no se pagó, se acreditó); `'PARCIAL'` si baja parcial. El PO puede pedir cambiarlo. |
| R6 | `TRG_ACTUALIZAR_COSTO_COMPRA` se dispara al tocar la NC. | Es `AFTER UPDATE`; la NC solo INSERTa. Verificar en smoke que no se active. |
| R7 | Re-import del menú con `@@` falla (shared components no-upsert). | El PO agrega la entrada en el Builder (igual R8 de F11 / R6 de F14). |
| R8 | Editar P94 vía `install_page.sql` completo pisa cambios del PO. | Import **aislado** `install_p94.sql` (memoria `apex-import-aislado`). |
| R9 | **SALIDA de stock fantasma**: NC devolución contra factura con deuda pero sin mercadería recibida (comp 88–97 demo lo tienen hoy). | Desacople CxP↔stock (§4.1): la devolución se capa a **lo recibido** (`FN_CANT_DEVOLVIBLE_COMPRA`); sin recepción → `-20919`. El descuento/ajuste no depende de recepción (solo CxP). |
| R10 | Mercadería recibida y **ya vendida** (stock on-hand < devolvible teórico). | **Cubierto en el MVP (decisión PO):** además del tope por recibido, `PRC_REGISTRAR_NC_COMPRA` valida que el **on-hand actual** (`STOCK_PRODUCTO.CANTIDAD` de ese producto/oficina) alcance para la SALIDA → si no, `-20920` ("stock insuficiente para la devolución: la mercadería ya no está disponible"). Nunca deja stock negativo. |
| — | Integración SIFEN real (la NC del proveedor es un DE que **él** emitió). | Fuera de alcance: SolSGE registra la representación/constancia, sin CDC/QR/validación. |

---

## 9. Casos de uso (guía)

### 9.0 Concepto base
La **NC de compra** es un documento que **el proveedor** nos emite para **acreditar**
(reducir) total o parcialmente una **factura de compra** ya registrada. **Nosotros no
la generamos: la recibimos y la capturamos.** Reglas comunes:
- La factura de compra origen **NO se anula** (sigue válida); la NC es documento
  separado que la credita.
- El total de la NC = lo que el proveedor nos acredita = lo que **baja nuestra deuda**
  (CxP). Nunca supera lo facturado ni el saldo pendiente.
- **Workflow:** captura directa (P94) → al Registrar se aplican los efectos.

### 9.1 Efectos al registrar
| Efecto | Cuándo | Detalle |
|--------|--------|---------|
| **CxP (baja saldo)** | Siempre (efecto principal) | `SALDO -= total NC`. Total → `SALDO=0`/`ANULADA`; parcial → `PARCIAL`. Tope = saldo pendiente (`-20915` si excede). |
| **Stock (SALIDA)** | Solo motivos **Devolución** (1, 2) **y solo hasta lo recibido** | Sale de nuestro inventario (lo devolvemos al proveedor), oficina de la factura. Tope = cantidad **recibida** (§4.1); sin recepción → `-20919`. Descuento/ajuste/bonificación/recupero → no toca stock (y no dependen de recepción). |
| **Caja** | Nunca (fuera de alcance) | Si la factura ya se pagó, el reembolso queda como deuda futura (`-20915`). |
| **Costo** | Nunca (fuera de alcance) | El ajuste de precio no re-costea el producto (dec. #3). |
| **Reporte de gasto (F25)** | Siempre | La NC resta del gasto neto de compras (`V_CMP_COMPRA` `UNION ALL` negativa). |

### 9.2 Caso — Descuento del proveedor (no devolvemos nada)
El proveedor nos concede un descuento post-factura. Motivo = *Descuento* (3) o
*Bonificación* (4). Se capturan las líneas afectadas con el importe acreditado. **No
mueve stock.** Baja la CxP por el monto → pagamos menos.

### 9.3 Caso — Devolución de mercadería
Recibimos productos fallados/erróneos y los devolvemos. Motivo = *Devolución* (2).
Se cargan las cantidades devueltas (**tope = lo recibido**). **Stock SALIDA** de esas
unidades + baja de CxP.

### 9.3b Caso — NC contra factura aún NO recepcionada (la duda del PO)
La factura se registró (`ESTADO='R'`) y ya generó deuda (F24: la deuda nace al
registrar, no al recibir), pero la mercadería **no llegó todavía**. Llega una NC:
- **Si es descuento / ajuste / bonificación:** se registra normal → **baja la CxP, sin
  stock**. Consistente (no hay mercadería que mover).
- **Si es devolución:** se **bloquea** (`-20919`) — no se puede devolver lo que no se
  recibió. Semánticamente, si el proveedor acredita mercadería no entregada, es un
  descuento/anulación, no una devolución → el usuario usa un motivo sin stock.
Esto elimina la SALIDA de stock fantasma que motivó la duda.

### 9.4 Caso — Ajuste de precio (nos facturó de más)
Motivo = *Ajuste de precio* (8). Se acredita la diferencia de precio. No mueve stock,
no re-costea (dec. #3), baja la CxP.

### 9.5 Qué NO cubre
| Necesidad | Tratamiento |
|-----------|-------------|
| Reembolso en efectivo de una compra ya pagada | Fuera de alcance (dec. #2); requeriría egreso/ingreso de caja con `ID_PROVEEDOR`. |
| Recalcular el costo del producto por la NC | Fuera de alcance (dec. #3). |
| Nota de Débito de compra (el proveedor nos cobra de más) | No implementada (análoga a ND de venta, fuera de alcance). |

---

## 10. Aprobación
> Decisiones tomadas con el PO el 2026-07-02 (captura directa, caja fuera de alcance,
> sin recálculo de costo, 8 motivos con stock derivado 1/2). PO dio OK para arrancar;
> **H1 aplicado el 2026-07-03** (§11). Al cerrar: los 4 módulos de compras (F24 CxP/OP,
> F25 reportes, F26 NC de compra) quedan integrados.

---

## 11. Bitácora de implementación

### H1 — Backend `db/F26_nota_credito_compra.sql` (2026-07-03) ✅
Aplicado y verificado (2 columnas nuevas, 0 objetos INVALID). Objetos: `COD_MOTIVO` +
`ID_DETALLE_ORIGEN` + FK `FK_CMPPROV_MOTIVO_NC`; `FN_CANT_ACREDITABLE_COMPRA`,
`FN_CANT_DEVOLVIBLE_COMPRA`, `FN_NC_COMPRA_ELEGIBLE`, `PRC_REGISTRAR_NC_COMPRA` (líneas
por arrays `SYS.ODCINUMBERLIST`), `V_NC_COMPRA`.

**Hallazgos que ajustaron el diseño (relevados en BD):**
- **`TRG_ACTUALIZAR_STOCK_MOVIMIENTO`** (AFTER INSERT en `MOVIMIENTOS_STOCK`) ya
  decrementa `STOCK_PRODUCTO.CANTIDAD` en cada SALIDA **y** ya bloquea con `-20001` si el
  on-hand no alcanza. → el proc **no** actualiza `STOCK_PRODUCTO` a mano (sería doble
  descuento); solo inserta la SALIDA. La guarda `-20920` queda como pre-check con mensaje
  claro y el trigger es el backstop final.
- IDs por **identity** (`RETURNING INTO`); sin CHECK sobre `ESTADO` → se usa `'ANULADA'`
  cuando el saldo queda ≤0 por crédito (R5).

**Smoke test (todo con `ROLLBACK`, datos intactos):**
| Caso | Resultado |
|------|-----------|
| L — descuento (motivo 3) sobre comp 3 | NC creada; CxP 5.000.000→4.900.000 (PARCIAL); **sin stock**; **sin CxP fantasma** ✓ |
| B — devolución (motivo 2) sobre comp 62 | NC creada; CxP 260.000→156.000; **SALIDA=2**; on-hand 116→114 ✓ |
| K — devolución sin recepción (comp 88) | `-20919` ✓ |
| D — factura saldada (comp 42) | `-20911` (elegibilidad) ✓ |
| F — cantidad > acreditable | `-20912` ✓ |
| precio > facturado | `-20913` ✓ |
| NC excede saldo (bajado a 50k en la tx) | `-20915` ✓ |

Pendientes de smoke directo (cubiertos por lógica / se verán en H5 e2e): `-20920`
(on-hand < cantidad con devolvible>0), `-20914` (sin líneas), `-20916` (subsumido por
`-20911`), `-20917` (motivo inexistente).

**Nota para H3 (APEX):** como el proc toma arrays, **P94 conviene armarla al estilo
P147/F24** (Classic Report con `APEX_ITEM` + armado de `SYS.ODCINUMBERLIST` en el
proceso), no como IG con `NATIVE_IG_DML`. Es el patrón ya probado en el repo para
"grilla de líneas → array → proc". (Actualiza la §5.3, que describía un IG.)

### H2 — F25 resta de gasto `db/F25_1_vistas_compras.sql` (2026-07-03) ✅
El plan asumía "solo `V_CMP_COMPRA`", pero agregar la NC ahí rompía dos vistas downstream
(`V_CMP_LINEA` contaría líneas de NC como productos comprados; `V_CMP_GASTO_MES.COUNT(*)`
contaría la NC como compra). **Solución:**
- `V_CMP_COMPRA`: `WHERE TIPO_COMPROBANTE IN ('FA','NC')`, `TOTAL` negativo para NC,
  `ESTADO_LABEL`/`CONDICION`='Nota de credito', + **nueva columna `TIPO_COMPROBANTE`**.
- `V_CMP_LINEA`: `WHERE cc.TIPO_COMPROBANTE='FA'` (top productos = compras brutas).
- `V_CMP_GASTO_MES`: `N_COMPRAS = SUM(CASE WHEN TIPO='FA' THEN 1 ELSE 0 END)`; `GASTO =
  SUM(TOTAL)` netea solo.

**Smoke (ROLLBACK):** NC descuento 104.000 sobre comp 62 → gasto total 91.022.000 →
90.918.000 (resta exacta); `N_COMPRAS` 18→18; `V_CMP_LINEA` 19→19. Las 8 vistas `V_CMP_*`
VALID (recompilé `V_CMP_CXP_AGING`, que estaba INVALID por una dependencia stale ajena a
este cambio). **P144/P145 heredan el gasto neto** (leen estas vistas); su verificación
visual queda para H5. Pendiente menor: los KPIs de P144 que hagan `COUNT`/ticket sobre
`V_CMP_COMPRA` deberían filtrar `TIPO_COMPROBANTE='FA'` (hoy sin impacto: 0 NC reales).

### H3 — P94 "Nota de Credito Proveedor" (2026-07-03) ✅
Claude armó la página entera (decisión del PO), espejando **P147/F24** (patrón
Classic Report + `APEX_ITEM` + `SYS.ODCINUMBERLIST`), no como IG. Estructura:
- **Región form "Datos de la Nota de Credito":** `P94_ID_FACTURA` (Select List, LOV de
  facturas **elegibles** = `TIPO='FA'`, `ESTADO<>'A'`, `FORMA_PAGO='1'`, con CxP
  `SALDO>0` → 15 hoy), `P94_COD_MOTIVO` (Select List, LOV `MOTIVOS_NOTA_CREDITO` activos),
  `P94_NRO_COMPROBANTE`/`P94_NRO_TIMBRADO` (text), `P94_FECHA_EMISION` (Date Picker
  `YYYY-MM-DD`), `P94_OBSERVACION` (textarea).
- **Región Classic Report "Lineas a acreditar":** `APEX_ITEM.HIDDEN(1,ID_DETALLE)` +
  columnas Producto/Cant.facturada/**Acreditable** (`FN_CANT_ACREDITABLE_COMPRA`)/
  **Devolvible** (`FN_CANT_DEVOLVIBLE_COMPRA`)/Precio facturado + `APEX_ITEM.TEXT(2,...)`
  Cant. a acreditar + `APEX_ITEM.TEXT(3, precio facturado)` Precio a acreditar. AJAX
  refresca con `P94_ID_FACTURA`.
- **Botón REGISTRAR** (submit) + **proceso ON_SUBMIT** que arma tres `SYS.ODCINUMBERLIST`
  desde `G_F01/F02/F03` (filtra cantidad>0, parsea miles/decimales estilo P147/P67) y
  llama `PRC_REGISTRAR_NC_COMPRA`. **DA** refresca el report al cambiar la factura.
  **Branch** recarga P94 limpiando caché con success msg.
- **Import aislado** `install_p94.sql` (`set_environment`+`delete_00094`+`page_00094`+
  `end_environment`), corrido por **stdin redirect** (`sql -S -name tesis_db <
  install_p94.sql` desde `apex-work/f100`, por el bug del `@file`). Registrada en
  `install_page.sql`. Verificado: 2 regiones, 6 ítems, botón, proceso, DA; LOV (15
  facturas) y report (funciones de tope) ejecutan OK.
- **Pendiente H5:** prueba e2e por navegador (el PO) + entrada de menú a P94 (la ajusta
  el PO en el Builder; la página ya existía en el menú como shell). Falta el bloqueo/aviso
  live de elegibilidad en pantalla (hoy la LOV ya filtra elegibles y el backend valida al
  registrar con `-20911`); se puede sumar un display-only si el PO lo pide.
- **Validado por el PO (2026-07-03):** capturó la **NC 102** (devolución total a crédito
  sobre comp 2) por navegador. Efectos verificados: CxP comp 2 → SALDO 0 / ANULADA; stock
  SALIDA de 1 (on-hand 79→78, usuario TCASCO); sin CxP fantasma; factura sigue `'C'`; NC
  resta del gasto F25. El PO hizo un cambio menor en P94 desde el Builder (re-exportar
  antes de tocar P94).

### H4 — Documento imprimible `db/F26_1_kude_nc_compra.sql` + P151 (2026-07-03) ✅
`FN_KUDE_NC_COMPRA_HTML(p_id_nc)` espeja `FN_KUDE_FACTURA_PROV_HTML` (P97/P149) del lado
NC: título "Nota de Crédito de Compra", emisor=proveedor, receptor=nuestra empresa,
recuadro con **Motivo** y **Documento asociado** (factura origen derivada por join vía
`ID_FAC_ORIGEN`: nro/fecha/timbrado), detalle con desglose de IVA por producto (precio IVA
incluido, 5%/10% contenido), total acreditado en letras, leyenda "registro interno — sin
validez fiscal". **P151** "Documento Nota de Credito Proveedor" (Dynamic Content →
`FN_KUDE_NC_COMPRA_HTML(:P151_ID_NC)` + item hidden, CSS `kude` + `@media print`, espejo de
P149). Verificado contra NC 102 (2135 chars). Import aislado `install_p151.sql`, registrada
en `install_page.sql`.

### H4b — Link a P151 desde P94 + captura del cambio del PO (2026-07-03) ✅
Se **re-exportó P94** antes de tocarla (regla del PO): el export fresco trajo el cambio que
el PO hizo en el Builder — una **máscara JS `applyMask`** que formatea `P94_NRO_COMPROBANTE`
como `000-000-0000000` mientras se tipea (page-level `p_javascript_code` + `oninput` en el
ítem). Sobre esa base se agregó una **3ª región** Classic Report **"Notas de credito
registradas"** (sobre `V_NC_COMPRA`, `ORDER BY ID_NC DESC`) con columna **"Documento"** que
arma `<a href="f?p=...:151:...:P151_ID_NC:ID_NC">` vía `V('APP_ID')`/`V('APP_SESSION')`
(`WITHOUT_MODIFICATION` para render HTML), patrón P124→P127 de la NC de venta. Reimport
aislado `install_p94.sql`. Verificado: 3 regiones, **máscara JS del PO preservada**, el
report lista la NC 102 con su link a P151.

**Fix checksum + modal + print (2026-07-03):** el primer intento armaba el `<a href>` a mano
(primero con `V('APP_ID')`, luego con `APEX_PAGE.GET_URL`) y abría con `target="_blank"`. Dos
problemas que reportó el PO: (1) `APEX.SESSION_STATE.SSP_CHECKSUM_MISSING` al abrir; (2) **al
imprimir se desacomodaba** y no abría como modal (a diferencia de P96). **Solución final —
alinear a P96 y usar link declarativo** (patrón P66→P96 / P148→P149):
- **Link:** se reemplazó el anchor-en-SQL por un **column-link declarativo** en la columna
  `NRO_COMPROBANTE` → `f?p=...:151:...:RP,151:P151_ID_NC:#ID_NC#`. APEX lo abre **como modal**
  (P151 es Modal Dialog) y **agrega el checksum solo**. No más `target="_blank"`.
- **P151 = P96 exacto:** `p_page_mode='MODAL'` + `p_page_template_options='#DEFAULT#:ui-dialog--stretch'`
  + `p_dialog_resizable='Y'` + **CSS idéntico al de P96**. Bug de tamaño corregido:
  `.krec td` pasó de `width:50%` (copiado de P149, que tiene filas de 2 columnas) a **`33%`**
  (el recuadro de la NC tiene **3 columnas** → 3×50%=150% desbordaba). Se sumó `tr.ksub` y el
  bloque `@media print` de P96 (sin la línea de ocultar nav, innecesaria en modal). **PO
  confirmó que imprime bien (2026-07-03).**
- Lección: para linkear a un documento modal protegido, usar **column-link declarativo**
  (auto-checksum + auto-modal), NO armar el `f?p`/anchor a mano; y clonar el `create_page`
  (modo/template/CSS) del documento de referencia (P96) para que imprima igual.
- **P149 (doc OP, F24) también alineado a P96 (2026-07-03, a pedido del PO):** re-exportado
  fresco (traía `p_page_mode='MODAL'` que la copia del repo no tenía) + `ui-dialog--stretch`
  + bloque `@media print` limpio (sin la línea de ocultar-nav) + `tr.ksub`. Reimport aislado
  `install_p149.sql`. Su recuadro es de 2 columnas → no tenía el bug del 150% de P151. Verificado
  por grep del export. (Toca F24, versionado junto a F26 por ser el mismo pedido de impresión.)

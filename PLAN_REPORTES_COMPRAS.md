# Plan de implementación — Reportes Gerenciales (Compras) — F25

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db`
**Estado del plan:** EN DEFINICIÓN — 2026-07-01. **Cuarto y último módulo gerencial**; replica la plantilla de Ventas (F18) / Cobros (F22) / Inventario (F23).
**Rango de error reservado:** `-20945 … -20948` (bloque libre entre F10 `-20944`/F17 y F10 `-20949`).
**Páginas APEX nuevas:** **P144** (Dashboard de Compras, interactivo) · **P145** (Generador de Informe de Compras, imprimible).
**Decisiones PO (2026-07-01):** alcance = **Gasto de compra + Embudo de OC + Desempeño de recepción/lead time + OC abiertas (+ KPI límite mensual)**; dataset = **enriquecer con seed demo** (como Inventario); **deuda a proveedores / aging CxP = consume la CxP REAL**, no demo → **depende de F24** (feature transaccional de Cuentas por Pagar, otra sesión — ver `HANDOFF_CUENTAS_PAGAR`).

> Último de los **reportes gerenciales para todos los módulos** pedidos por el
> profesor. La plantilla quedó cerrada en **Ventas (F18)**, **Cobros (F22)** e
> **Inventario (F23)**: seed/habilitador → vistas `V_*` (single source of truth) →
> dashboard JET (import aislado) → informe imprimible por filtros (`FN_..._HTML`,
> barras CSS + `@media print`, estilo `kude`). Este plan la calca para **Compras**.
> Ver `PLAN_REPORTES_INVENTARIO.md`, `PLAN_REPORTES_COBROS.md`,
> `PLAN_REPORTES_GERENCIALES.md` y la memoria `reportes-gerenciales`.

---

## 1. Contexto y problema (verificado en `tesis_db`, 2026-07-01)

El módulo de Compras ya está operativo (órdenes de compra, comprobantes de
proveedor, recepciones) y los datos son **mayormente consistentes**, pero **no hay
vista gerencial**: el gerente de área no puede ver **cuánto se gasta en compras**
por mes/proveedor/producto, en qué etapa están las **órdenes de compra**, cuánto
tarda cada proveedor en **entregar** (lead time), ni qué **OC quedaron abiertas**.

**El dataset es el más chico de todos los módulos** (limitaciones no bloqueantes,
se resuelven con seed demo, igual que Inventario) y hay **un hueco estructural**
que se ataca en un feature aparte (F24, ver §1.4):

1. **`CUENTAS_PAGAR` está VACÍA (0 filas) y ningún trigger la puebla** → el aging
   de **deuda a proveedores** (el análogo del aging de cartera de Cobros, el
   reporte más gerencial) **no tiene datos reales hoy**. Decisión del PO: **NO
   sembrar CxP demo** — primero se construye el feature transaccional de Cuentas
   por Pagar (F24, otra sesión) para que la CxP se genere de verdad desde los
   comprobantes y el sistema llegue a **generar la orden de pago**. El reporte
   gerencial de deuda/aging (H, §2) consume esa CxP real → **depende de F24**.
2. **Dataset finísimo:** **1 sola oficina** en las 12 OC (corte por sucursal = 1
   barra), **2 proveedores**, **3 productos comprados** (todos "Gaming"), **2
   compradores**, comprobantes en **3 meses**. Sin seed, varios charts degeneran.
   → **seed demo** que enriquece proveedores/productos/OC/comprobantes/recepciones
   (dato de demostración, se presenta así en la defensa).

### 1.1 Esquema relevante (verificado 2026-07-01)

| Tabla | Rol | Datos vivos |
|---|---|---|
| `ORDENES_COMPRA` (PK `ID_ORDEN_COMPRA`) | **cabecera OC** (dimensión comprador/oficina/aprobador) | 12 OC. `ID_EMPLEADO` 12/12, `ID_OFICINA` 12/12 (**1 sola oficina**), `ID_APROBADOR` 3/12 |
| `DETALLE_ORDEN_COMPRA` | líneas OC (cantidad pedida) | 13 |
| `COMPROBANTES_PROVEEDOR` (PK `ID_COMPROBANTE`) | **factura de compra = fuente del gasto** | 8, todos `TIPO_COMPROBANTE='FA'`. `ID_ORDEN_COMPRA`/`ID_OFICINA`/`ID_PROVEEDOR` |
| `DETALLE_COMPROBANTE_PROV` | líneas de la factura de compra (producto×precio) | 10 |
| `RECEPCIONES_COMPRA` (PK `ID_RECEPCION`) | **recepción de mercadería** (lead time) | 10, con recepciones parciales sobre la misma OC |
| `DETALLE_RECEPCION_COMPRA` | cantidad recibida por línea | 10 |
| `CUENTAS_PAGAR` (PK `ID_CXP` identity) | **deuda a proveedores** (espejo de `CUENTAS_COBRAR`) | **0 (vacía)** — se puebla en F24 |
| `PROVEEDORES` (PK `ID_PERSONA`) → `PERSONAS` | dimensión proveedor | **2** (id 1 "Tobias Casco", id 101 "Nissei S.A.") |
| `OFICINAS` (PK **`CODIGO_OFICINA`**) | dimensión oficina | 2 (pero las OC usan **1 sola**) |
| `PRODUCTOS`/`CATEGORIAS`/`MARCAS` | dimensión producto | 3 comprados hoy (todos "Gaming") |

**Reusables ya en BD:** `V_COMPARATIVA_PRECIO_PROVEEDORES`,
`V_PRODUCTO_PROVEEDOR_VIGENTE`, `FN_COSTO_PONDERADO`, `FN_GET_LIMITE_OC_MENSUAL`
(límite mensual de OC, base del KPI E). Triggers: `TRG_ACTUALIZAR_COSTO_COMPRA`
(AFTER UPDATE de `COMPROBANTES_PROVEEDOR`, copia precio a `PRODUCTO_PROVEEDORES` al
pasar a `'C'`), `TRG_MOV_STOCK_RECEPCION` (ENTRADA de stock en cada recepción),
`TRG_MOV_STOCK_DETALLE_PROV` (**DISABLED** — insertar detalle de compra ya no mueve
stock).

### 1.2 🔑 REGLAS DE ORO de compras (verificadas en `tesis_db` 2026-07-01)

1. **El "gasto de compra" se cuenta por el COMPROBANTE DE PROVEEDOR (factura de
   compra), NO por la OC.** Es el análogo de "ventas por la factura, no por la
   orden" de F18. La OC es presupuesto/compromiso (embudo); la compra concretada es
   el comprobante. `gasto = Σ COMPROBANTES_PROVEEDOR con ESTADO != 'A'` (registrada
   R / recepción parcial PR / completada C, todas dinero comprometido). **Total
   real ≈ 12,6 M PYG** (R 4.294.000 + PR 5.000.000 + C 3.320.000).
2. **No hay NC de compra en los datos** (los 8 comprobantes son `FA`) → a diferencia
   de Ventas, **no hay resta de NC**. Existe la página P94 "Nota de Crédito
   Proveedor" pero sin datos; si el dataset crece, la NC de compra restaría al gasto
   por `ID_FAC_ORIGEN`/`ID_COMPROBANTE_ORIGEN` (dejar la vista preparada, `TIPO='NC'`).
3. **Estados OC:** `B`=Borrador (pend. aprobación), `P`=Pendiente recepción
   (aprobada), `C`=Completada (recibida), `X`=Rechazada, `A`=Anulada. El **embudo**
   usa estos estados (única visual que mira `ORDENES_COMPRA.ESTADO`; no alimenta el
   gasto). Reparto real: B 1 / P 4 / C 6 / X 1 / A 0.
4. **Estados comprobante:** `R`=Registrada, `PR`=Recepción parcial, `C`=Completada,
   `A`=Anulada. Filtrar `!= 'A'` para el gasto.
5. **Comprobante 21 es basura** (estado `R` con `FECHA_EMISION`/`TOTAL_COMPROBANTE`
   NULL) → se excluye naturalmente (`total` NULL no suma; sin fecha no entra a
   ningún período).
6. **Dimensión comprador/oficina viene de la OC**, no del comprobante:
   `COMPROBANTES_PROVEEDOR.ID_ORDEN_COMPRA → ORDENES_COMPRA.ID_EMPLEADO/ID_OFICINA`.
   El comprobante también trae su propio `ID_OFICINA` (fallback si la OC es NULL).
7. **Fecha:** las páginas de compras usan `SYSDATE` (bug del proyecto, no se toca
   acá). En las vistas/informe usar **`FN_HOY`/`FN_AHORA`** (UTC-3), nunca `SYSDATE`
   (BD en UTC). `FECHA_EMISION`/`FECHA_ORDEN`/`FECHA_RECEPCION` son DATE.

### 1.3 Realidad del dataset (presentarlo así en la defensa)

Dataset base: **12 OC / 8 comprobantes / 10 recepciones**, **2 proveedores**, **3
productos**, **1 oficina**, **2 compradores**, comprobantes en 3 meses. Sin seed,
"gasto por proveedor" son 2 barras, "top productos" son 3, "por sucursal" es 1. Por
eso el seed demo (§3.1) suma proveedores + productos + OC/comprobantes/recepciones
en categorías y meses distintos, para que los charts no queden degenerados. **Es
dato de demostración, no histórico real.**

### 1.4 Dependencia: feature transaccional de Cuentas por Pagar (F24)

El reporte de **deuda a proveedores / aging CxP** (H) requiere que `CUENTAS_PAGAR`
tenga datos reales. Por decisión del PO **no se siembra demo**: se construye antes,
en otra sesión, el feature transaccional que (a) puebla `CUENTAS_PAGAR` desde los
comprobantes de proveedor (espejo de `TRG_INS_CUENTAS_COBRAR`), (b) agrega
`FECHA_VENCIMIENTO` a la CxP (hoy no existe, hace falta para el aging) y (c) permite
**generar la orden de pago** que salda las cuentas. Ver `HANDOFF_CUENTAS_PAGAR`
(rango de error `-20935..-20939`). **Este plan (F25) no toca la CxP**; su vista de
aging (`V_CMP_CXP_AGING`) y la sección/KPI de deuda quedan **detrás de un guard**:
si `CUENTAS_PAGAR` está vacía muestran "sin datos" y se activan solas cuando F24
esté aplicado.

---

## 2. Definiciones y decisiones (PO 2026-07-01)

| # | Tema | Decisión |
|---|------|----------|
| 1 | **Alcance** | **Gasto de compra (A) + Embudo de OC (B) + Recepción/lead time (C) + OC abiertas (D) + KPI límite mensual (E).** Deuda/aging CxP (H) entra como capa que **consume la CxP real de F24** (guard si vacía). Secundarios: gasto por comprador (F), comparativa de precios (G, reusa vistas). |
| 2 | **Regla de oro** | Gasto = Σ comprobantes de proveedor `!= 'A'` (§1.2.1). Sin resta de NC (no hay datos; vista preparada). |
| 3 | **Deuda a proveedores** | **NO demo.** Depende de F24 (feature CxP transaccional). El reporte consume `CUENTAS_PAGAR` real + su nueva `FECHA_VENCIMIENTO`. |
| 4 | **Dataset** | **Enriquecer con seed demo idempotente** (proveedores + productos + OC/comprobantes/recepciones en varias categorías/meses), como el seed de Inventario. Dato de demostración. |
| 5 | **Dimensión tiempo** | Gasto/embudo/recepciones = por **período** (`TRUNC(FECHA,'MM')`). OC abiertas y aging CxP = **snapshot a-hoy** (como el aging de Cobros). |
| 6 | **Dos capas de reporte** | (a) **Dashboard interactivo** P144 (JET charts + KPIs + selector de período). (b) **Informe imprimible por filtros** P145 (`FN_INFORME_COMPRAS_HTML`, barras CSS + `@media print`, estilo `kude`). Idéntico patrón a P133/P135, P136/P137, P142/P143. |

---

## 3. Diseño

### 3.1 Seed demo / enriquecedor — `db/F25_seed_compras_demo.sql` (idempotente, `MERGE`/`NOT EXISTS`)

Enriquece el dataset para que los charts no degeneren. Idempotente (identidad
capturada por nombre/nro, inserción con `NOT EXISTS`). **Ojo con los triggers de
stock:** `TRG_MOV_STOCK_RECEPCION` mueve stock en cada recepción demo → o se siembra
sin recepciones que muevan stock, o se documenta el impacto en Inventario (coordinar
con F23). Preferible: **comprobantes + OC demo sin recepción** (no tocan stock;
`TRG_MOV_STOCK_DETALLE_PROV` está DISABLED) y unas pocas recepciones demo calibradas.

1. **+2–3 proveedores demo** (reusar `PERSONAS` existentes o crear personas demo +
   `PROVEEDORES`), en categorías distintas.
2. **+OC y comprobantes demo** repartidos en varios meses (para serie temporal) y
   varios productos/categorías (reusar los productos demo de F23: Notebook, Samsung,
   JBL, Smart TV) + los 2 compradores + (si se quiere) una 2ª oficina para que el
   corte por sucursal tenga ≥2 barras.
3. **Algunas recepciones demo con lead time variado** (para el chart de desempeño),
   calibradas; documentar el efecto en stock si mueven `TRG_MOV_STOCK_RECEPCION`.
4. **1 comprobante `TIPO='NC'`** opcional (NC de compra) para ejercitar la resta.
5. Bloque de **verificación** final; `RAISE -20945` si falla.

> **Dato de demostración**, no histórico real. Mismo criterio que
> `F23_seed_inventario_demo.sql` / `F18_seed_vendedor_demo.sql`.

### 3.2 Vistas de apoyo — `db/F25_1_vistas_compras.sql` (idempotente)

Single source of truth compartido por dashboard e informe HTML.

- **`V_CMP_COMPRA`** — grano comprobante (compra) `!= 'A'`: proveedor (vía
  `PROVEEDORES`→`PERSONAS`), oficina/comprador (vía `ORDENES_COMPRA`, fallback
  `COMPROBANTES_PROVEEDOR.ID_OFICINA`), `PERIODO` (`TRUNC(FECHA_EMISION,'MM')`),
  `TOTAL`, `ESTADO_LABEL`. **Fuente del gasto.**
- **`V_CMP_LINEA`** — grano comprobante×producto (`DETALLE_COMPROBANTE_PROV` +
  `PRODUCTOS`/`CATEGORIAS`): para top productos comprados (cantidad y valor).
- **`V_CMP_GASTO_MES`** — gasto por período/proveedor/categoría (de `V_CMP_COMPRA`).
- **`V_CMP_OC_EMBUDO`** — OC por `ESTADO` (B/P/C/X/A) con conteo, monto y
  `ESTADO_LABEL`; base del embudo y las tasas de aprobación/rechazo.
- **`V_CMP_OC_ABIERTA`** — OC en estado `P` (aprobadas, pendientes de recepción
  completa) con valor comprometido y `DIAS_ABIERTA` (`FN_HOY − FECHA_ORDEN`).
- **`V_CMP_RECEPCION`** — recepciones con `LEAD_DIAS` (`FECHA_RECEPCION −
  ORDENES_COMPRA.FECHA_ORDEN`), proveedor, `PERIODO`, cantidad recibida; +
  cantidad pendiente de recibir (OC pedida − Σ recibida) por proveedor.
- **`V_CMP_CXP_AGING`** *(depende de F24)* — `CUENTAS_PAGAR` con `SALDO > 0` +
  `DIAS_ATRASO` (`FN_HOY − FECHA_VENCIMIENTO`), `BUCKET` (por-vencer/1-30/31-60/
  61-90/+90), proveedor. **Guard:** si la tabla está vacía la vista devuelve 0
  filas (el dashboard/informe muestran "sin datos" hasta F24).

> **Gotcha tiempo:** usar `FN_HOY`/`FN_AHORA` (UTC-3), nunca `SYSDATE`. Excluir
> comprobante 21 sale gratis (`total` NULL, sin fecha).

### 3.3 Dashboard interactivo — **P144** (JET charts + KPIs)

Página normal (no modal). Selector de **período** `P144_PERIODO` (Select List,
default "Todos los meses"), como P133/P136.

- **Tarjetas KPI** (Dynamic Content PL/SQL): **gasto de compra del período**, #
  comprobantes, ticket promedio, # OC abiertas + **valor comprometido pendiente**,
  **consumo del límite mensual** (`FN_GET_LIMITE_OC_MENSUAL`), lead time promedio;
  *(dep F24)* **deuda a proveedores** + % vencido.
- **Charts JET** (patrón `jet_chart`; **omitir** `p_value_format_scaling`/
  `p_format_scaling` → rompen el check `JET_CHARTS_SCALING`; sin `p_static_id`):
  1. **Gasto de compra por mes** (barras).
  2. **Gasto por proveedor** (barras/dona) — concentración/dependencia.
  3. **Top productos comprados** (barras horizontales, valor).
  4. **Embudo de OC por estado** (barras: borrador/pendiente/completada/rechazada).
  5. **Lead time promedio por proveedor** (barras horizontales) — desempeño.
  6. **OC abiertas por antigüedad** (barras) **o** *(dep F24)* **aging de CxP**
     (por-vencer/1-30/31-60/61-90/+90) + top acreedores.
- **Reporte clásico** de respaldo (detalle de compras). Botón "Imprimir informe" →
  abre **P145**.

### 3.4 Informe Gerencial imprimible — **P145** + `FN_INFORME_COMPRAS_HTML`

- **`FN_INFORME_COMPRAS_HTML(p_fecha_desde, p_fecha_hasta, p_proveedor,
  p_categoria)`** en `db/F25_2_informe_compras_html.sql` — genera **HTML del
  servidor**. **Gasto/recepciones = rango** (desglose auto día ≤31d / mes, como
  F18/F22/F23); **OC abiertas / aging CxP = snapshot a-hoy**. Secciones: encabezado
  (emisor desde `PARAMETROS` TIPO=`EMPRESA` + fecha de corte), KPIs, **gasto por
  proveedor/categoría/mes**, **embudo de OC**, **desempeño de recepción / lead
  time**, **OC abiertas**, *(dep F24)* **deuda a proveedores / aging**, detalle de
  compras. Visuales = **barras CSS/HTML** (no JET). Entidades HTML (no `unistr`).
  `FN_HOY`/`FN_AHORA`.
- **P145 "Generador de Informe de Compras"** (normal, no modal): región Filtros
  (contenedor **plano** + `p_region_css_classes=>'js-noprint'`) con Select Lists
  Proveedor/Categoría + Date Pickers `P145_DESDE`/`P145_HASTA` (default este mes,
  `YYYY-MM-DD`, etiquetados "rango para gasto/recepciones"); botón **Generar**
  (DA→refresh) y **Imprimir** (DA→`window.print()`); región Informe (Dynamic
  Content → `FN_INFORME_COMPRAS_HTML(...)` con `ajax_items_to_submit`); CSS `kude`
  scopeado a `.kude` + `@media print` que oculta `.js-noprint` y el chrome UT.
- **NO es Documento Electrónico SIFEN**: control interno, sin CDC/QR, leyenda "sin
  validez fiscal".

### 3.5 Despliegue / importación

- DB: `sql -S -name tesis_db < db/F25_seed_compras_demo.sql` (stdin redirect, por el
  bug del `@file`), luego vistas y función.
- APEX: P144/P145 se importan **aisladas** (install temporal mínimo:
  `set_environment` + `delete_NN`/`page_NN` + `end_environment`), **no** el
  `install_page.sql` completo (pisa cambios del PO). El menú lo agrega el PO en el
  Builder (entrada recomendada: "Dashboard de Compras" → P144).

---

## 4. Hitos

- [x] **H0 — (dependencia externa) Feature CxP transaccional (F24). ✔ APLICADO
  2026-07-02** (`PLAN_CUENTAS_PAGAR.md`). `CUENTAS_PAGAR` ya tiene **7 filas reales**
  con `FECHA_VENCIMIENTO`; existe la vista **`V_CXP_DEUDA`** (deuda + `DIAS_ATRASO`
  con `FN_HOY`) y el flujo de orden de pago (P146/P147/P148/P149). → La capa de
  deuda/aging de F25 (H, `V_CMP_CXP_AGING`) puede **quitar el guard** y consumir la
  CxP real: `CUENTAS_PAGAR` (con `FECHA_VENCIMIENTO`), o reusar `V_CXP_DEUDA`.
- [ ] **H1 — Seed demo / enriquecedor (`db/F25_seed_compras_demo.sql`).**
  Idempotente. Enriquece proveedores/productos/OC/comprobantes/recepciones. Cuidar
  triggers de stock. Verificación + `RAISE -20945`.
- [ ] **H2 — Vistas (`db/F25_1_vistas_compras.sql`).** `V_CMP_COMPRA`/`V_CMP_LINEA`/
  `V_CMP_GASTO_MES`/`V_CMP_OC_EMBUDO`/`V_CMP_OC_ABIERTA`/`V_CMP_RECEPCION`/
  `V_CMP_CXP_AGING` (guard). Verificar contra datos reales.
- [ ] **H3 — Dashboard interactivo P144.** KPIs + 6 JET charts + reporte detalle +
  botón Imprimir → P145 + selector de período. Gotchas APEX respetados. Import
  aislado `install_p144.sql`.
- [ ] **H4 — Informe imprimible P145 + `FN_INFORME_COMPRAS_HTML`.** Rango +
  snapshot. Barras CSS + `@media print`, estilo `kude`. Import aislado
  `install_p145.sql`.
- [ ] **H5 — Cierre.** Páginas en `apex-work` + installs aislados registrados en
  `install_page.sql` (tracking), `CLAUDE.md` actualizado (entrada F25), memoria
  `reportes-gerenciales` actualizada (replicación **completa**), commit `feat(F25)`.
  Menú y validación visual a cargo del PO.

---

## 5. Riesgos

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | Dataset chico / 1 oficina → charts degenerados. | Seed demo enriquece proveedores/productos/OC/comprobantes (§3.1); presentarlo como demo. |
| R2 | Deuda/aging sin datos (CxP vacía). | Depende de F24 (§1.4); vista con guard → "sin datos" hasta que se aplique. **NO** se siembra CxP demo (decisión PO). |
| R3 | Seed de recepciones demo mueve stock (`TRG_MOV_STOCK_RECEPCION` ENABLED). | Sembrar sobre todo comprobantes/OC sin recepción; recepciones demo mínimas y documentadas; coordinar con F23. |
| R4 | Doble lógica dashboard vs HTML. | Ambos consumen `V_CMP_*` (§3.2). |
| R5 | Contar el gasto por la OC en vez del comprobante. | Regla de oro §1.2.1 encapsulada en `V_CMP_COMPRA`; el embudo es la única visual sobre `ORDENES_COMPRA.ESTADO`. |
| R6 | Comprobante 21 (NULL fecha/total) ensucia. | Excluido naturalmente; filtrar `total IS NOT NULL` / `estado != 'A'`. |
| R7 | Editar P144/P145 vía `install_page.sql` completo pisa cambios del PO. | Import **aislado** por página (memoria `apex-import-aislado`); re-exportar antes de tocar. |
| R8 | Gotchas APEX heredados. | `JET_CHARTS_SCALING` (omitir scaling); `p_static_id` no en `create_page_plug`; `unistr` en LOV → `ORA-12704` (LOV estático ASCII); región con ítems = contenedor plano (`ORA-01403`). |
| R9 | `SYSDATE` (BD en UTC). | `FN_HOY`/`FN_AHORA` (UTC-3) en todas las vistas/informe. |

---

## 6. Fuera de alcance

- **Feature transaccional de Cuentas por Pagar / orden de pago** — es **F24**, otra
  sesión (`HANDOFF_CUENTAS_PAGAR`). F25 solo lo consume para el reporte de deuda.
- **Sembrar CxP demo** (decisión PO: la CxP debe funcionar de verdad primero).
- Corte por **sucursal** significativo (las OC reales son de 1 oficina; el seed puede
  sumar una 2ª para demo).
- **NC de compra** como flujo completo (P94 existe sin datos; la vista queda
  preparada para restarla si el dataset crece).
- Multi-moneda real (todo PYG en datos).
- PDF nativo / print server / envío por correo del informe.
- Metas/presupuesto de compras (no hay tabla; el "límite mensual de OC" ya existe y
  se usa como KPI, no como meta editable).

---

## 7. Aprobación y dependencias

> Decisiones tomadas con el PO el 2026-07-01 (alcance A+B+C+D+E; deuda/aging CxP
> **no demo** → depende del feature transaccional F24; enriquecer dataset con seed
> demo). **Dependencia:** H0/F24 (Cuentas por Pagar → orden de pago) se construye
> primero en otra sesión (`HANDOFF_CUENTAS_PAGAR`). F25 arranca por **H1**
> (`db/F25_seed_compras_demo.sql`) — las capas A–E no esperan a F24; solo la capa de
> deuda/aging (H) queda detrás del guard hasta que F24 esté aplicado.

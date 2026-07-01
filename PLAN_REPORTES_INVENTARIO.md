# Plan de implementación — Reportes Gerenciales (Inventario) — F23

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db`
**Estado del plan:** EN DEFINICIÓN — 2026-06-29. Tercer módulo gerencial; **replica la plantilla de Ventas (F18) / Cobros (F22)**.
**Rango de error reservado:** `-20921 … -20929` (bloque libre; `-20920` lo usa F11, `-20930+` también).
**Páginas APEX nuevas:** **P142** (Dashboard de Inventario, interactivo) · **P143** (Generador de Informe de Inventario, imprimible).
**Decisiones PO (2026-06-29):** alcance = **Valorización + Niveles + Rotación**; mín/máx = **seed demo (sin pantalla ABM)**; costo = **enriquecer el dataset** (precios de proveedor + productos demo) y resolver en la vista con `COALESCE(costo ponderado, precio proveedor)`.

> Tercero de los **reportes gerenciales para todos los módulos** pedidos por el
> profesor. La plantilla quedó cerrada en **Ventas (F18)** y **Cobros (F22)**:
> habilitador/seed → vistas `V_*` (single source of truth) → dashboard JET →
> informe imprimible por filtros (barras CSS + `@media print`, estilo `kude`).
> Este plan la calca para **Inventario/Stock**. Ver `PLAN_REPORTES_GERENCIALES.md`,
> `PLAN_REPORTES_COBROS.md` y la memoria `reportes-gerenciales`.

---

## 1. Contexto y problema (verificado en `tesis_db`, 2026-06-29)

El módulo de Inventario ya está operativo (stock, movimientos, ajustes,
transferencias, conteos físicos, reservas) y los datos están **mayormente
consistentes**, pero **no hay vista gerencial**: el dueño no puede ver el **valor
inmovilizado**, qué productos están **bajo mínimo / sobre máximo / en quiebre**,
la **rotación** (rápido vs lento movimiento), ni los productos **obsoletos / sin
movimiento**.

**A diferencia de Cobros, hay dos huecos de datos que limitan los reportes** (no
bloqueantes, se resuelven con seed demo, igual que el vendedor de F18):

1. **`STOCK_PRODUCTO.STOCK_MINIMO` casi vacío** (1 de 6 filas) → "bajo mínimo /
   quiebre" hoy daría casi nada. **`STOCK_MAXIMO`** poblado 4/6.
2. **Costo incompleto:** `FN_COSTO_PONDERADO` (ventana 90d) solo devuelve costo
   para 1 de 4 productos; con ventana histórica, 3/4. El **Monitor (prod 1) no
   tiene costo en ninguna fuente** (sin compras ni precio de proveedor).

### 1.1 Esquema relevante (verificado)

| Tabla | Rol | Datos vivos |
|---|---|---|
| `STOCK_PRODUCTO` (PK prod+ofi) | **stock on-hand autoritativo** + `STOCK_MINIMO`/`STOCK_MAXIMO` | 6 filas (todas CANTIDAD>0). `STOCK_MAXIMO` 4/6, `STOCK_MINIMO` **1/6** |
| `MOVIMIENTOS_STOCK` (PK `ID_MOVIMIENTO`) | **kardex** transaccional | 47 mov, oct/25–jun/26. `REFERENCIA` rica (`VENTA - COMPROBANTE n`, `NOTA_CREDITO#`, `ANULACION_FACTURA#`, `COMPRA`, `RECEPCION`) |
| `AJUSTES_STOCK` | ajustes manuales | 2 |
| `TRANSFERENCIAS_STOCK` | transferencias inter-oficina | 2 |
| `RESERVAS_PRODUCTO` | reservas por orden de venta | VIGENTE 10 / ANULADA 15 |
| `INVENTARIO` + `INVENTARIO_DETALLE` | **conteos físicos** (workflow) + `STOCK_SISTEMA`/`CANTIDAD_FISICA`/`DIFERENCIA` | 8 docs (APROBADO 4, ENVIADO 2, BORRADOR 1, RECHAZADO 1), 16 detalles |
| `PRODUCTOS` / `CATEGORIAS_PRODUCTOS` / `MARCAS` | dimensión producto | **4 productos, todos cat. "Gaming"**; 10 categorías, 5 marcas |
| `OFICINAS` (PK **`CODIGO_OFICINA`**) | dimensión oficina | 2 (Roberto L Petit=1, Villarrica=2; Villarrica solo 2 productos) |
| Compras (`COMPROBANTES_PROVEEDOR`/`DETALLE_COMPROBANTE_PROV`/`PRODUCTO_PROVEEDORES`) | **costo** + dimensión proveedor | 8 fact compra (3 estado `'C'`), 10 precios de proveedor |

**Reusable ya en BD:** `FN_COSTO_PONDERADO(id_producto, ventana_dias)` — costo
promedio ponderado desde facturas de compra `estado='C'` (ventana default 90d,
configurable por `PARAMETROS` TIPO=`COSTO` clave `COSTO_VENTANA_DIAS`). Otras:
`FN_HAY_STOCK`, `FN_GET_STOCK_MAXIMO`, `FN_OFICINAS_CON_STOCK`,
`INVENTARIO_PKG`.

### 1.2 🔑 REGLAS DE ORO de inventario (verificadas en `tesis_db` 2026-06-29)

1. **`STOCK_PRODUCTO.CANTIDAD` es la verdad del on-hand — NO sumar el kardex
   desde cero.** Verifiqué Σ`MOVIMIENTOS_STOCK` vs `STOCK_PRODUCTO`: **no
   reconcilian** (ej. prod 2 ofi 1: stock 79, neto mov −1 → apertura ~80; prod 1:
   dif −5). El stock inicial se cargó **sin movimiento**. → los reportes de nivel
   usan `STOCK_PRODUCTO`; el kardex sirve para historia, y un saldo corrido se
   **ancla al stock actual y se reconstruye hacia atrás**, nunca sumando desde 0.
2. **El stock es SNAPSHOT (foto a-hoy), no serie temporal.** `STOCK_PRODUCTO` no
   tiene historia. → niveles/valorización son **a-hoy** (como el aging de cartera
   en F22); la dimensión **tiempo** solo vive en `MOVIMIENTOS_STOCK` (flujo,
   rotación, kardex).
3. **`TIPO_MOVIMIENTO` con mayúscula mixta:** hay `ENTRADA` (20) y un `Entrada`
   (1) suelto → **siempre `UPPER(TIPO_MOVIMIENTO)`** en las vistas (análogo al
   `ESTADO IN ('A','C')` de cobros).
4. **Costo de valorización = `COALESCE(FN_COSTO_PONDERADO(prod, ventana_amplia),
   último PRODUCTO_PROVEEDORES ACTIVO)`.** `FN_COSTO_PONDERADO` mira facturas de
   compra, **no** la lista de precios; `PRODUCTO_PROVEEDORES` es el fallback. Si
   ambos NULL → `'(sin costo)'`, se excluye del total valorizado.
5. **`disponible = CANTIDAD − Σ RESERVAS_PRODUCTO (ESTADO='VIGENTE')`.** El
   on-hand incluye lo reservado por órdenes de venta.

### 1.3 Mecánica de triggers de compra (verificada — relevante para el seed)

- `FN_COSTO_PONDERADO` lee `DETALLE_COMPROBANTE_PROV` + `COMPROBANTES_PROVEEDOR`
  `estado='C'`, `fecha_emision >= FN_HOY − ventana`.
- `TRG_ACTUALIZAR_COSTO_COMPRA` (AFTER UPDATE OF ESTADO, al pasar a `'C'`) **copia
  el precio de compra a `PRODUCTO_PROVEEDORES`** (la lista de precios es espejo del
  último costo).
- `TRG_MOV_STOCK_DETALLE_PROV` genera ENTRADA de stock **solo si la compra está en
  `estado='R'`**; `TRG_MOV_STOCK_RECEPCION` genera ENTRADA en cada recepción. →
  **el seed de costo se hace insertando `PRODUCTO_PROVEEDORES` directo (sin tocar
  stock)**, NO insertando compras (que moverían el on-hand).

### 1.4 Realidad del dataset (presentarlo así en la defensa)

Dataset chico (**4 productos, todos "Gaming", 2 oficinas**) → cualquier corte
"por categoría" sale con 1 barra y la rotación tiene pocos puntos. Por eso el seed
demo (§3.1) suma **3–4 productos en categorías distintas** + precios + mín/máx,
para que los charts no queden degenerados. **Es dato de demostración, no
histórico real.** Los productos nuevos no tienen ventas → aparecen como "sin
movimiento / rotación 0" (realista).

---

## 2. Definiciones y decisiones (PO 2026-06-29)

| # | Tema | Decisión |
|---|------|----------|
| 1 | **Alcance** | **Valorización + Niveles + Rotación.** Núcleo: stock valorizado, niveles vs mín/máx + quiebres, entradas/salidas por mes, rotación (rápido/lento), sin movimiento/obsoletos, diferencias de conteo físico. Secundarios: kardex por producto, disponibilidad (on-hand − reservas). |
| 2 | **Mín/máx (niveles)** | **Seed demo idempotente** que puebla `STOCK_MINIMO`/`STOCK_MAXIMO` faltantes (calibrado para un mix: algún bajo mínimo, algún sobre máximo). **Sin pantalla ABM** (a diferencia de las metas de F18/F22). Las columnas ya existen, no hay DDL. |
| 3 | **Costo / valorización** | Vista usa `COALESCE(FN_COSTO_PONDERADO(prod, ventana_amplia), último precio ACTIVO de PRODUCTO_PROVEEDORES)`. Se **enriquece el dataset** con precios de proveedor (seed directo, sin mover stock) + productos demo nuevos. Sin tabla de "metas" (en inventario la "meta" es el mín/máx). |
| 4 | **Dimensión tiempo** | Stock/valorización/niveles = **snapshot a-hoy** (sin filtro de fecha). Flujo/rotación/kardex/movimientos = por **período** (`TRUNC(FECHA_MOVIMIENTO,'MM')`). |
| 5 | **Dos capas de reporte** | (a) **Dashboard interactivo** P142 (JET charts + KPIs + selector de oficina). (b) **Informe imprimible por filtros** P143 (`FN_INFORME_INVENTARIO_HTML`, barras CSS + `@media print`, estilo `kude`). Idéntico patrón a P133/P135 y P136/P137. |

---

## 3. Diseño

### 3.1 Seed demo / habilitador — `db/F23_seed_inventario_demo.sql` (idempotente, `MERGE`)

**No hay DDL** (mín/máx y costo usan columnas/funciones existentes). El script:

1. **Puebla mín/máx faltantes** en `STOCK_PRODUCTO` (`MERGE`/`UPDATE WHERE
   STOCK_MINIMO IS NULL`), calibrado para mostrar: ≥1 producto **bajo mínimo**,
   ≥1 **sobre máximo**, el resto OK. Solo toca filas con NULL (idempotente).
2. **Agrega 3–4 productos demo** en categorías distintas a "Gaming" (de las 10
   existentes) + `STOCK_PRODUCTO` (cantidad + mín/máx) + `PRODUCTO_PROVEEDORES`
   (precio ACTIVO) → enriquece categoría/valor. `MERGE` por nombre/código para
   idempotencia.
3. **Completa el costo** de los productos sin compra (ej. Monitor): inserta un
   precio ACTIVO en `PRODUCTO_PROVEEDORES` (directo, **sin** factura de compra →
   no mueve stock). Idempotente.
4. Bloque de **verificación** final (todas las filas de stock con mín/máx no
   NULL; todos los productos con costo resoluble vía COALESCE); `RAISE -20921` si
   falla.

> **Dato de demostración**, no objetivo real (defensa). Mismo criterio que
> `F18_seed_vendedor_demo.sql` / `F22_seed_metas_cobranza_demo.sql`.

### 3.2 Vistas de apoyo — `db/F23_1_vistas_inventario.sql` (idempotente)

Single source of truth compartido por dashboard e informe HTML.

- **`V_INV_STOCK`** — grano producto×oficina (snapshot): `STOCK_PRODUCTO` +
  `PRODUCTOS`/`CATEGORIAS`/`MARCAS` + `OFICINAS`. Derivadas: `COSTO_UNITARIO`
  (`COALESCE(FN_COSTO_PONDERADO(...), precio prov.)`), `VALOR_STOCK`
  (`CANTIDAD*COSTO_UNITARIO`), `RESERVADO` (Σ reservas VIGENTE), `DISPONIBLE`
  (`CANTIDAD−RESERVADO`), `ESTADO_NIVEL` (semáforo: `QUIEBRE` si 0, `BAJO_MINIMO`,
  `SOBRE_MAXIMO`, `OK`, `SIN_DEFINIR` si min/max NULL).
- **`V_INV_MOV`** — grano movimiento: `MOVIMIENTOS_STOCK` normalizado
  (`UPPER(TIPO_MOVIMIENTO)`), `PERIODO` (`TRUNC(FECHA_MOVIMIENTO,'MM')`),
  `SIGNO_CANTIDAD` (+entrada/−salida), producto/categoría/oficina, `CLASE_REF`
  (venta/compra/NC/anulación/ajuste, parseada de `REFERENCIA`).
- **`V_INV_FLUJO_MES`** — entradas vs salidas (cantidad) por período/oficina/
  categoría (de `V_INV_MOV`).
- **`V_INV_ROTACION`** — por producto/oficina: `SALIDAS_VENTANA` (Σ salidas por
  venta en ventana configurable), `STOCK_ACTUAL`, `INDICE_ROTACION`
  (`SALIDAS/NULLIF(STOCK_ACTUAL,0)` — proxy con stock actual, **documentado**),
  `DIAS_SIN_MOV` (`FN_HOY − último movimiento`), `CLASE` (rápido/lento/sin
  movimiento).
- **`V_INV_CONTEO_DIF`** — `INVENTARIO_DETALLE` + `INVENTARIO`: por documento/
  producto, `STOCK_SISTEMA`/`CANTIDAD_FISICA`/`DIFERENCIA`, `EXACTITUD_PCT`. Para
  diferencias de conteo físico (#7).

> **Gotcha tiempo:** `MOVIMIENTOS_STOCK.FECHA_MOVIMIENTO` es DATE (no TIMESTAMP).
> Las filas nuevas se estampan con `FN_AHORA` (UTC-3); `TRUNC(...,'MM')` da el
> período correcto. Usar `FN_HOY`/`FN_AHORA`, nunca `SYSDATE`.

### 3.3 Dashboard interactivo — **P142** (JET charts + KPIs)

Página normal (no modal). Selector de **oficina** `P142_OFICINA` (Select List,
default "Todas"), porque el corte natural es por sucursal (el stock es snapshot,
no hay selector de mes para nivel; el flujo/rotación sí miran período internamente).

- **Tarjetas KPI** (Dynamic Content PL/SQL): **valor total inmovilizado**, # SKUs,
  # bajo mínimo, # sobre máximo, # quiebres (stock 0), # sin movimiento.
- **Charts JET** (patrón `jet_chart`; **ojo** `p_value_format_scaling`/
  `p_format_scaling` rompen el check `JET_CHARTS_SCALING` → omitir):
  1. **Valor de stock por categoría** (barras).
  2. **Stock actual vs mín/máx por producto** (barras + líneas de referencia, o
     barras agrupadas).
  3. **Entradas vs Salidas por mes** (2 series, de `V_INV_FLUJO_MES`).
  4. **Rotación: rápido vs lento** (barras horizontales, top productos por índice).
  5. **Valor inmovilizado por oficina** (barras/dona).
  6. **Top productos por valor de stock** (barras horizontales).
- **Reporte clásico** de respaldo (detalle de stock valorizado + estado de nivel).
  Botón "Imprimir informe" → abre **P143**.

### 3.4 Informe Gerencial imprimible — **P143** + `FN_INFORME_INVENTARIO_HTML`

- **`FN_INFORME_INVENTARIO_HTML(p_oficina, p_categoria, p_fecha_desde,
  p_fecha_hasta)`** en `db/F23_2_informe_inventario_html.sql` — genera **HTML del
  servidor**. **Stock/valorización/niveles = snapshot a-hoy** (los filtros de
  fecha aplican SOLO a las secciones de flujo/rotación/movimientos). Secciones:
  encabezado (emisor desde `PARAMETROS` TIPO=`EMPRESA` + fecha de corte), KPIs,
  **stock valorizado** por categoría/producto, **niveles** (bajo mín/sobre máx/
  quiebres), **flujo entradas-salidas** del rango (desglose auto día ≤31d / mes,
  como F18/F22), **rotación / obsolescencia**, **diferencias de conteo físico**,
  detalle de stock. Visuales = **barras CSS/HTML** (no JET). Entidades HTML (no
  `unistr`). `FN_HOY`/`FN_AHORA`.
- **P143 "Generador de Informe de Inventario"** (normal, no modal): región Filtros
  (contenedor **plano** + `p_region_css_classes=>'js-noprint'`) con Select Lists
  Oficina/Categoría + Date Pickers `P143_DESDE`/`P143_HASTA` (default este mes,
  `YYYY-MM-DD`, etiquetados "rango para flujo/rotación"); botón **Generar**
  (DA→refresh) y **Imprimir** (DA→`window.print()`); región Informe (Dynamic
  Content → `FN_INFORME_INVENTARIO_HTML(...)` con `ajax_items_to_submit`); CSS
  `kude` scopeado a `.kude` + `@media print` que oculta `.js-noprint` y el chrome UT.
- **NO es Documento Electrónico SIFEN**: control interno, sin CDC/QR, leyenda "sin
  validez fiscal".

### 3.5 Despliegue / importación

- DB: `sql -S -name tesis_db < db/F23_seed_inventario_demo.sql` (stdin redirect,
  por el bug del `@file` en esta máquina), luego vistas y función.
- APEX: P142/P143 se importan **aisladas** (install temporal mínimo:
  `set_environment` + `delete_NN`/`page_NN` + `end_environment`), **no** el
  `install_page.sql` completo (pisa cambios del PO). El menú lo agrega el PO en el
  Builder.

---

## 4. Hitos

- [x] **H1 — Seed demo / habilitador (`db/F23_seed_inventario_demo.sql`). Hecho
  2026-06-30.** Aplicado a `tesis_db`, verificación interna OK → `COMMIT`.
  Idempotente (identity capturada por nombre; precio guardado con NOT EXISTS por
  el trigger `TRG_CIERRE_PP_ANTERIOR`). Resultado verificado (11 filas de stock, 5
  categorías): **niveles** OK 6 / BAJO_MINIMO 3 / SOBRE_MAXIMO 1 / QUIEBRE 1;
  **todos los productos con costo resoluble** (Monitor 1.500.000 vía precio prov.;
  Silla 2.980.000 y Auriculares 80.000 por ponderado; los 4 nuevos por precio
  Nissei). 4 productos demo nuevos (IDs 21–24): Notebook Lenovo (Laptops, OK),
  Samsung A54 (Smartphones, SOBRE_MAXIMO), JBL Charge 5 (Audio, QUIEBRE), Smart TV
  LG 50" (Televisores, Petit OK / Villa BAJO_MINIMO) + 4 marcas (Lenovo/Samsung/
  JBL/LG). **Valor inmovilizado total ≈ 428,8 M PYG.** Dato de demo, no histórico.
- [x] **H2 — Vistas (`db/F23_1_vistas_inventario.sql`). Hecho 2026-06-30.** 5
  vistas `CREATE OR REPLACE FORCE`: `V_INV_STOCK` (snapshot prod×ofi con
  costo `COALESCE(FN_COSTO_PONDERADO(prod,3650), precio prov.)`, `VALOR_STOCK`,
  `RESERVADO`/`DISPONIBLE`, `ESTADO_NIVEL`, `COSTO_ORIGEN`), `V_INV_MOV` (kardex
  normalizado `UPPER(TIPO)`, `PERIODO`, `SIGNO_CANTIDAD`, `CLASE_REF`),
  `V_INV_FLUJO_MES` (entradas/salidas/ajustes/neto por período×oficina),
  `V_INV_ROTACION` (índice = salidas venta / stock actual (proxy), `DIAS_SIN_MOV`,
  `CLASE_ROTACION`), `V_INV_CONTEO_DIF` (conteos físicos, `EXACTITUD_PCT` acotada
  0–100 por coincidencia min/max). **Verificado contra datos reales:** valor
  inmovilizado **428,8 M** (costo PONDERADO 4 / PRECIO_PROV 7); niveles OK 6 /
  BAJO_MINIMO 3 / SOBRE_MAXIMO 1 / QUIEBRE 1; reservado 24 / disponible 296; valor
  por categoría (Gaming 274,4 M · Smartphones 94,5 M · Televisores 34,3 M ·
  Laptops 25,6 M · Audio 0=quiebre); flujo mensual may/25–jun/26; rotación (los 3
  Gaming con ventas = LENTO, los 4 nuevos + Monitor = SIN_MOVIMIENTO); conteos con
  exactitud promedio 30–46%. **Nota:** los datos de `INVENTARIO_DETALLE` son
  sintéticos y muy dispares (por eso la exactitud acotada).
- [~] **H3 — Dashboard interactivo P142. Construido 2026-07-01**
  (`apex-work/f100/application/pages/page_00142.sql`, importado aislado vía
  `install_p142.sql`). 9 regiones: KPIs (Dynamic Content: valor inmovilizado, SKUs,
  bajo mínimo, sobre máximo, quiebres, sin movimiento) + 6 JET charts (valor por
  categoría, stock vs mín/máx por producto 3 series, entradas/salidas por mes 2
  series, rotación top-10 horizontal, valor por sucursal donut, top productos por
  valor horizontal) + reporte "Detalle de stock" + botón Imprimir → P143. Selector
  `P142_OFICINA` (DA refresh de las regiones filtradas; rotación y valor-por-sucursal
  son snapshot no filtrado). **Gotchas respetados:** sin `p_value_format_scaling`/
  `p_format_scaling` (check `JET_CHARTS_SCALING`); sin `p_static_id`; filtro =
  contenedor plano; `unistr` para acentos/₲. Página registrada con las 9 regiones,
  queries validadas. **Pendiente:** validación visual en vivo por el PO; entry de
  menú (la agrega el PO).
- [x] **H4 — Informe imprimible P143 + `FN_INFORME_INVENTARIO_HTML`. Hecho
  2026-07-01.** `FN_INFORME_INVENTARIO_HTML(p_oficina, p_categoria, p_fecha_desde,
  p_fecha_hasta)` (`db/F23_2_informe_inventario_html.sql`): **snapshot** para
  stock/valorización/niveles/rotación/conteos/detalle + **rango** para el flujo
  entradas/salidas (desglose auto día ≤31d / mes). Secciones: encabezado, KPIs,
  stock valorizado por categoría (barras), **alertas de nivel** (quiebre/bajo/sobre),
  flujo por día-mes, **rotación/obsolescencia**, **diferencias de conteo físico**,
  detalle de stock valorizado. Barras CSS, entidades HTML (no `unistr`),
  `FN_HOY`/`FN_AHORA`, acento azul `#1565c0`. **9/9 verificaciones OK** (HTML 9961
  chars sin filtros; desglose por día; filtros combinados). **P143 "Generador de
  Informe de Inventario"** (`page_00143.sql`, normal): Filtros (contenedor plano
  `js-noprint`: sucursal + categoría + date pickers desde/hasta) + Generar (DA
  refresh) + Imprimir (DA `window.print()`) + Informe (Dynamic Content → la
  función); CSS `kude` scopeado + `@media print`. El botón de P142 abre P143.
  Import aislado vía `install_p143.sql`. **Pendiente:** validación visual del PO.
- [x] **H5 — Cierre. Hecho 2026-07-01.** Páginas P142/P143 en `apex-work` +
  installs aislados, registradas en `install_page.sql` (tracking), `CLAUDE.md`
  actualizado (entrada F23 + gotchas de inventario), memoria `reportes-gerenciales`
  actualizada, commit `feat(F23)`. Menú y validación visual a cargo del PO (entrada
  recomendada: "Dashboard de Inventario" → P142).

---

## 5. Riesgos

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | Dataset chico / 1 sola categoría → charts degenerados. | Seed demo suma productos en categorías distintas (§3.1); presentarlo como demo. |
| R2 | Doble lógica dashboard vs HTML (números que no cuadran). | Ambos consumen `V_INV_*` (§3.2). |
| R3 | Sumar el kardex desde cero da saldos erróneos (no reconcilia apertura). | `STOCK_PRODUCTO` es la verdad; saldo corrido anclado al stock actual (regla §1.2.1). |
| R4 | Costo NULL para productos sin compra (Monitor). | `COALESCE(costo ponderado, precio proveedor)` + seed de precios; `'(sin costo)'` excluido del total. |
| R5 | `TIPO_MOVIMIENTO` con mayúscula mixta (`Entrada`/`ENTRADA`). | `UPPER(TIPO_MOVIMIENTO)` en todas las vistas. |
| R6 | Rotación sin historia de stock (solo snapshot). | Índice de rotación con stock actual como proxy del promedio, **documentado** en la vista y el informe. |
| R7 | Editar P142/P143 vía `install_page.sql` completo pisa cambios del PO. | Import **aislado** por página (memoria `apex-import-aislado`); re-exportar antes de tocar. |
| R8 | Gotchas APEX heredados se repiten. | `JET_CHARTS_SCALING` (omitir scaling); `p_static_id` no en `create_page_plug`; `unistr` en LOV → `ORA-12704` (LOV estático ASCII); región con ítems = contenedor plano (`ORA-01403`). |
| R9 | Seed de costo vía compras movería el stock (triggers). | Seed de costo se hace en `PRODUCTO_PROVEEDORES` **directo**, sin facturas de compra (§1.3). |

---

## 6. Fuera de alcance

- **Alertas de caducidad / vencimiento de mercadería** — **no factible**: no hay
  tabla de lotes ni `FECHA_VENCIMIENTO` de producto (`V_ALERTAS_CADUCIDAD_PP` es
  vencimiento del acuerdo de precio con proveedor, no de la mercadería).
- **Pantalla ABM de mín/máx** (decisión PO: solo seed). Se puede agregar después
  con el patrón reporte+modal (P13/P63), como las metas de F18/F22.
- **Historia de stock / valorización a una fecha pasada** (el stock es snapshot;
  no hay tabla de saldos por fecha).
- Multi-moneda real (todo PYG en datos).
- PDF nativo / print server / envío por correo del informe.
- Reportes gerenciales de **Compras** (último módulo de la plantilla, pendiente).
- Costeo FIFO/LIFO real (solo promedio ponderado + precio de lista).

---

## 7. Aprobación

> Decisiones tomadas con el PO el 2026-06-29 (alcance Valorización+Niveles+Rotación;
> mín/máx por seed sin pantalla; costo por `COALESCE` + enriquecer dataset con
> precios de proveedor y productos demo, sin mover stock). **Arranca por H1**
> (`db/F23_seed_inventario_demo.sql`) — pendiente de escribir y aplicar.

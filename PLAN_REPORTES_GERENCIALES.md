# Plan de implementación — Reportes Gerenciales (Ventas) — F18

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db`
**Estado del plan:** EN DEFINICIÓN — 2026-06-26. Arranca por **Ventas** como plantilla replicable.
**Rango de error reservado:** `-20991 … -20999` (último hueco libre tras NC `-20970..-20990`).
**Páginas APEX nuevas:** **P133** (Dashboard de Ventas, interactivo) · **P134** (Informe Gerencial de Ventas, imprimible).

> El profesor pidió **reportes gerenciales para todos los módulos** de SolSGE.
> Se arranca por **Ventas/Facturación** con un **Dashboard de Ventas**, pensado
> como **plantilla replicable** a Compras / Inventario / Cobros. Antes de los
> reportes hay un **habilitador de datos** (la dimensión "vendedor", que hoy no
> existe).

---

## 1. Contexto y problema (verificado en `tesis_db`, 2026-06-26)

El módulo de Ventas/Facturación ya está cerrado (F8–F17) y los datos están
limpios, pero **no hay ninguna vista gerencial**: el dueño no puede ver
facturación por mes/sucursal, top productos, contado vs. crédito, ni desempeño
por vendedor.

**Hueco de datos que bloquea "ventas por vendedor"** (verificado):
`ORDENES_VENTA` (13 columnas) tiene `USUARIO_APROBACION`/`USUARIO_ANULACION`
pero **NO `USUARIO_CREACION`** → no se sabe **quién cargó** cada presupuesto.
`USUARIO_APROBACION` además está NULL en 11 de 21 facturas, así que no sirve como
proxy. El vendedor, por definición del PO, **es quien carga el presupuesto**.

| Hecho verificado | Valor |
|---|---|
| `ORDENES_VENTA.USUARIO_CREACION` | **No existe** |
| `METAS_VENTA` | **No existe** |
| `USUARIO_APROBACION` (formato) | `:APP_USER` en mayúsculas — `TCASCO`, `CBARRIOS` |
| Clave dimensión empleado | `EMPLEADOS.CODIGO_USUARIO` (= ese mismo string) |
| Empleados activos | 61 CBARRIOS, 81 TCASCO, 141 FPAREDES, 192 NCACERES |
| Estados `ORDENES_VENTA` | FACTURADO 23, VENCIDO 8, PENDIENTE 2, APROBADO 1, ANULADO 1 |
| Vínculo factura→orden | `COMPROBANTES.ID_ORDEN_VENTA` |
| Trigger BEFORE INSERT existente (precedente) | `TRG_OV_FECHA_VENCIMIENTO` |
| Helper de sesión reusable | `FN_OFICINA_USUARIO_V2(:APP_USER)` |

---

## 2. Definiciones y decisiones (PO 2026-06-26)

| # | Tema | Decisión |
|---|------|----------|
| 1 | **Quién es el "vendedor"** | El **usuario que carga el presupuesto** (`ORDENES_VENTA`), propagado a la factura por `COMPROBANTES.ID_ORDEN_VENTA`. |
| 2 | **Cómo se estampa el vendedor** | ✅ **Trigger BEFORE INSERT** `TRG_OV_USUARIO_CREACION` (`V('APP_USER')`). Elegido sobre "proceso en P54" porque captura todo camino de insert, **no toca la página APEX** (sin riesgo de re-export que ya nos mordió) y sigue el patrón `TRG_OV_FECHA_VENCIMIENTO`. |
| 3 | **Modelo de metas** | Tabla `METAS_VENTA`, meta por **vendedor** (`ID_EMPLEADO`) **o** por **sucursal** (`ID_OFICINA`), exactamente uno, por **mes**. |
| 4 | **Representación del período** | ✅ **`PERIODO DATE`** (1ro del mes) — joinea directo a `TRUNC(COMPROBANTES.FECHA,'MM')` sin parsear. |
| 5 | **Dos capas de reporte** | ✅ (a) **Dashboard interactivo** (P133): JET charts + tarjetas KPI + IRs, para explorar en pantalla. (b) **Informe Gerencial imprimible** (P134): `FN_INFORME_VENTAS_HTML(periodo, oficina, vendedor)` + modal de impresión `@media print`, **misma convención que el arqueo/KuDE**. |
| 6 | **Gráficos del imprimible** | ✅ **Barras CSS/HTML** (divs con ancho proporcional) — **NO JET charts** (son JS, no entran en el HTML del servidor). Razón de fondo: en este ATP probablemente no hay print server → el PDF nativo de APEX no está, igual que en KuDE/arqueo (HTML + `@media print` + Ctrl+P). |

---

## 3. Diseño

### 3.1 Habilitador — `db/F18_habilitador_vendedor.sql` (idempotente) — **escrito**

1. **`ORDENES_VENTA.USUARIO_CREACION VARCHAR2(60)`** nullable. Guardado por `COUNT(*)`.
2. **`TRG_OV_USUARIO_CREACION`** BEFORE INSERT:
   ```sql
   :NEW.USUARIO_CREACION := NVL(:NEW.USUARIO_CREACION, NVL(V('APP_USER'), USER));
   ```
3. **`METAS_VENTA`**: `ID_META` (identity PK), `ID_EMPLEADO` FK→EMPLEADOS (null),
   `ID_OFICINA` FK→OFICINAS (null), `PERIODO DATE`, `MONTO_META>0`;
   `CHECK` 1-de-2 (empleado **o** oficina) + índice único
   `(NVL(emp,-1), NVL(ofi,-1), PERIODO)` + `TRG_METAS_VENTA_BI` que trunca
   `PERIODO` a `'MM'` y reafirma la regla 1-de-2.
4. Bloque de **verificación** final (columna, ambos triggers VALID/ENABLED, tabla,
   índice); `RAISE -20999` si falla.

> **Backfill imposible de forma fidedigna** (no se registró quién creó las
> históricas). **Seed de demo aplicado 2026-06-26** (`db/F18_seed_vendedor_demo.sql`):
> se sembró un vendedor en las 35 órdenes — respetando el aprobador real donde
> existe (10 TCASCO + 1 CBARRIOS) y repartiendo el resto por `MOD(ID_ORDEN,8)`
> ponderado a TCASCO. Distribución: TCASCO 18, CBARRIOS 9, NCACERES 5, FPAREDES 3
> (0 NULL). **Es dato de demostración, no histórico real** — presentarlo así en la
> defensa. El criterio "(sin asignar)" en los reportes sigue vigente por si
> entran órdenes nuevas sin sesión.

### 3.2 Vistas de apoyo — `db/F18_1_vistas_ventas.sql` (idempotente)

Para que el dashboard **y** el informe HTML compartan la misma lógica (single
source of truth), una capa de vistas.

> **REGLA DE ORO (verificada en `tesis_db` 2026-06-26): "ventas" y "meta" cuentan
> SOLO lo facturado, atribuido por la FACTURA — nunca por el estado de la orden.**
> - Las 21 facturas activas tienen las 21 su `ID_ORDEN_VENTA` → vendedor
>   atribuible al 100% (sin "(sin asignar)" en facturas).
> - **NO usar `ORDENES_VENTA.ESTADO='FACTURADO'`** como proxy de venta: da 23,
>   pero las facturas activas son 21 (2 órdenes quedaron `FACTURADO` con su factura
>   **anulada** `ESTADO='N'`). La cifra sale de `COMPROBANTES`, no del estado de la
>   orden.
> - **Atribución de NC = dos saltos.** Las 4 NC **no** tienen `ID_ORDEN_VENTA`
>   (todas NULL); se vinculan por `ID_COMPROBANTE_ORIGEN`. Para restar la NC al
>   vendedor correcto: `NC.ID_COMPROBANTE_ORIGEN → factura origen → ID_ORDEN_VENTA
>   → ORDENES_VENTA.USUARIO_CREACION`.
>
> `ventas_netas(vendedor,periodo) = Σ FA activas (por ID_ORDEN_VENTA) − Σ NC (por`
> `ID_COMPROBANTE_ORIGEN→factura→orden)`. Datos vivos: FA 60.135.952 − NC 406.400.

- **`V_VENTAS_LINEA`** — grano factura/línea: `COMPROBANTES` (FA activas, `ESTADO='A'`) +
  `DETALLE_COMPROBANTE` + `ORDENES_VENTA` (vendedor vía `ID_ORDEN_VENTA`) +
  `OFICINAS`. Columnas derivadas: `PERIODO` (`TRUNC(FECHA,'MM')`), `VENDEDOR`
  (`NVL(USUARIO_CREACION,'(sin asignar)')`), `ES_CONTADO` (`FORMA_PAGO=21`).
- **`V_VENTAS_NC`** — NC activas atribuidas al vendedor por el **dos saltos**
  (`ID_COMPROBANTE_ORIGEN`→factura→orden), con `PERIODO`/`OFICINA`/`VENDEDOR` para
  poder restarlas por las mismas dimensiones.
- **`V_VENTAS_NETAS_MES`** — facturación **neta** por mes/oficina/vendedor =
  Σ FA activas − Σ NC (combinando las dos vistas anteriores).
- **`V_VENTAS_VENDEDOR_META`** — neto por vendedor/mes (de `V_VENTAS_NETAS_MES`)
  vs. `METAS_VENTA` (cumplimiento %). La meta por **oficina** agrega los vendedores
  de esa oficina.

> El **embudo presupuesto→factura** (chart aparte) SÍ usa `ORDENES_VENTA.ESTADO`
> — es la única visual que mira estados de orden, y no alimenta la cifra de
> ventas/meta.
>
> Convenciones de datos (memoria): `COMPROBANTES.ESTADO` `A`=activa/`N`=anulada;
> `TIPO_COMPROBANTE` `FA`/`NC`; `FORMA_PAGO` `21`=contado, `1`=crédito.

### 3.3 Dashboard interactivo — **P133** (JET charts + KPIs)

Página normal (no modal). Filtros: período (rango de meses), oficina, vendedor.

- **Tarjetas KPI**: facturación neta del período, # facturas, ticket promedio,
  % contado vs. crédito, cumplimiento de meta global.
- **Charts JET** (patrón `jet_chart` ya en el repo):
  facturación neta/mes (barras), por sucursal (barras), contado vs. crédito (dona),
  top productos (barras horizontales), **ventas por vendedor vs. meta** (barras
  combinadas/línea de meta), **embudo presupuesto→factura** (estados de
  `ORDENES_VENTA`).
- **IRs** de respaldo (detalle navegable). Botón "Imprimir informe" → abre P134.

> Dataset chico (~21 facturas, jun/25–jun/26) → charts esparcidos; normal para
> tesis.

### 3.4 Informe Gerencial imprimible — **P134** + `FN_INFORME_VENTAS_HTML`

- **`FN_INFORME_VENTAS_HTML(p_periodo, p_oficina, p_vendedor)`** en
  `db/F18_2_informe_ventas_html.sql` — genera **HTML del servidor** con:
  encabezado (emisor desde `PARAMETROS` TIPO=`EMPRESA` + período), tablas con
  totales (neto/mes, por sucursal, top productos, contado/crédito), KPIs y
  **ranking de vendedores vs. meta**. Los visuales van como **barras CSS/HTML**
  (divs con `width:%`), **no** JET.
- **P134**: página **modal de impresión**, región PL/SQL que imprime el retorno de
  la función + CSS `@media print`, **misma identidad visual que P132/P96/P119**
  (reusa el estilo `kude`/arqueo). Impresión por navegador (Ctrl+P).
- **NO es Documento Electrónico SIFEN**: control interno, sin CDC/QR, leyenda
  "sin validez fiscal".

### 3.5 Despliegue / importación

- DB: `sql -S -name tesis_db < db/F18_habilitador_vendedor.sql` (stdin redirect,
  por el bug del `@file` en esta máquina), luego las vistas y la función.
- APEX: P133/P134 se importan **aisladas** (install temporal mínimo:
  `set_environment` + `delete_NN`/`page_NN` + `end_environment`), **no** el
  `install_page.sql` completo (pisa cambios del PO). El menú lo agrega el PO en el
  Builder.

---

## 4. Hitos

- [x] **H1 — Habilitador (`db/F18_habilitador_vendedor.sql`). Hecho 2026-06-26.**
  Columna `USUARIO_CREACION` + `TRG_OV_USUARIO_CREACION` + `METAS_VENTA` +
  índice `UQ_METAS_VENTA_DIM_PER` + `TRG_METAS_VENTA_BI` + verificación, todo
  aplicado a `tesis_db` (6/6 checks OK). **Smoke con `ROLLBACK`:** insert sin
  usuario estampa la sesión (`ADMIN`; en APEX será `:APP_USER`); insert con
  usuario explícito respeta (`NVL`); `PERIODO` se trunca a `'MM'`; meta sin
  dimensión → `ORA-20992`; meta duplicada (emp+período) → `ORA-00001`. Nada
  persistido (`METAS_VENTA`=0, órdenes con vendedor=0).
- [x] **H2 — Vistas (`db/F18_1_vistas_ventas.sql`). Hecho 2026-06-26.** 5 vistas:
  `V_VENTAS_FACTURA` (grano factura, FA activas), `V_VENTAS_NC` (atribuida a la
  factura origen por el dos-saltos), `V_VENTAS_NETA_MES` (FA−NC por
  periodo/oficina/vendedor), `V_VENTAS_VENDEDOR_META` (neto vs. meta empleado),
  `V_VENTAS_LINEA` (factura×producto, top productos). Verificado contra datos
  reales: FA 60.135.952 (21) − NC 406.400 (4) = neto 59.729.552. La NC restó al
  vendedor correcto (Tobias Casco 20.397.120 → neto 19.990.720) vía el dos-saltos.
- [~] **H3 — Dashboard interactivo P133. Construido 2026-06-26** (`apex-work/f100/
  application/pages/page_00133.sql`, importado aislado vía `install_p133.sql`).
  8 regiones: tarjetas KPI (Dynamic Content PL/SQL: facturación neta, # facturas,
  ticket promedio, % contado, cumplimiento meta) + 6 JET charts (neto/mes,
  neto/sucursal, contado-vs-crédito donut, top productos horizontal, vendedor-vs-meta
  2 series, embudo por estado de orden) + reporte clásico "Detalle de ventas". Todas
  las queries validadas contra datos reales. **Es el primer JET chart del proyecto**
  (estructura `create_jet_chart`/`_series`/`_axis`; ojo: `p_value_format_scaling`/
  `p_format_scaling` violan el check `JET_CHARTS_SCALING` — omitir). **Selector "Mes"
  agregado 2026-06-26** (`P133_PERIODO`, Select List con `page_action_on_selection=
  SUBMIT`, default "Todos los meses"): KPIs, cumplimiento, los 6 charts y el reporte
  filtran por `:P133_PERIODO` (el cumplimiento ahora es POR MES, no un promedio global
  — ej. nov/2025 103%, jun/2026 44,3%). El embudo filtra por `TO_CHAR(FECHA_ORDEN,
  'YYYY-MM')`. **Pendiente:** validación visual en vivo por el PO; filtros oficina/
  vendedor (mismo patrón, si el PO los quiere); entry de menú (hecho por el PO).
- [x] **H4 — Informe imprimible POR FILTROS (refinado por el profesor 2026-06-27).
  Hecho 2026-06-28.** El profesor pidió que el imprimible se genere **según
  filtros** (por fecha: día/mes/año/rango, vendedor, sucursal, condición), no por
  mes fijo. Decisión: **página dedicada P135** (no ensuciar el dashboard) +
  retiro de P134.
  - **`FN_INFORME_VENTAS_HTML(p_fecha_desde, p_fecha_hasta, p_vendedor, p_oficina,
    p_condicion)`** (`db/F18_2_informe_ventas_html.sql`) — refactor a **rango de
    fechas** (cubre día/mes/año/rango con un solo mecanismo); **desglose temporal
    automático** por día (rango ≤ 31 días) o por mes; secciones: KPIs, ventas/día-mes,
    por sucursal, top productos, ranking vs. meta (meta de los meses del rango),
    **detalle de facturas**. Entidades HTML (no unistr), barras CSS. Usa `FN_HOY`/
    `FN_AHORA` (UTC-3). Requirió agregar `fecha` a `V_VENTAS_LINEA` (F18.1).
  - **P135 "Generador de Informe de Ventas"** (`page_00135.sql`, normal, no modal):
    región Filtros (contenedor plano + `p_region_css_classes=>'js-noprint'`) con
    Date Pickers `P135_DESDE`/`P135_HASTA` (default este mes, format `YYYY-MM-DD`),
    Select Lists Vendedor/Sucursal/Condición; botón **Generar** (DA → refresh) y
    **Imprimir** (DA → `window.print()`); región Informe (Dynamic Content →
    `FN_INFORME_VENTAS_HTML(TO_DATE(:P135_DESDE,...),...)` con `ajax_items_to_submit`);
    CSS `kude` scopeado a `.kude` + `@media print` que oculta `.js-noprint` y el chrome UT.
  - **P133**: el botón ahora abre **P135** (era P134). **P134 retirada** (estaba rota
    tras el refactor: llamaba la firma vieja de 3 args).
  - **Gotchas resueltos:** `p_static_id` NO es válido en `create_page_plug` (usar el
    div `.kude` para scopear CSS); `unistr` (NVARCHAR2) en el SQL de un LOV rompe por
    charset `ORA-12704` → usar LOV estático ASCII; scalar subquery `(SELECT..)` ilegal
    en asignación PL/SQL → `SELECT INTO`. Validado por el PO en el navegador.
- [~] **H5 — Carga de metas. Seed demo hecho 2026-06-26** (`db/F18_seed_metas_demo.sql`,
  6 metas de empleado × mes, `MERGE` idempotente, calibradas para un mix de
  cumplimiento: 2 sobre meta, 4 debajo). `V_VENTAS_VENDEDOR_META.cumplimiento_pct`
  ya pobla. **Pendiente:** el PO carga las metas reales en producción.
- [ ] **H6 — Cierre.** Páginas re-exportadas y sincronizadas a `apex-work`,
  `CLAUDE.md` actualizado, commit `feat(F18)` + tag. Menú lo agrega el PO.

---

## 5. Riesgos

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | Vendedor NULL en históricos distorsiona el ranking. | Tratar como "(sin asignar)" explícito; el ranking real arranca con presupuestos nuevos (documentado). |
| R2 | Editar P133/P134 vía `install_page.sql` completo pisa cambios vivos del PO. | Import **aislado** por página (memoria `apex-import-aislado`); re-exportar antes de tocar. |
| R3 | Sin print server, el PDF nativo de APEX no está. | Capa imprimible es HTML + `@media print` + Ctrl+P, igual que KuDE/arqueo (ya probado). |
| R4 | Doble lógica entre dashboard y HTML (números que no cuadran). | Ambos consumen las mismas vistas `V_VENTAS_*` (§3.2). |
| R5 | Charts esparcidos por dataset chico. | Esperado para tesis; opcional seed de datos de demo. |
| R6 | El UNIQUE de metas colisiona por NULLs entre dimensiones. | Índice funcional `NVL(...,-1)` + `CHECK` 1-de-2. |

---

## 6. Fuera de alcance

- **Backfill** de vendedor en facturas/órdenes históricas (imposible).
- Reportes gerenciales de **Compras / Inventario / Cobros** (este plan es la
  plantilla; se replican después).
- Multi-moneda real (todo PYG en datos).
- PDF nativo / print server / envío por correo del informe.
- Metas por producto, por cliente o por segmento (hoy solo vendedor/sucursal × mes).
- Integración SIFEN (el informe es control interno sin validez fiscal).

---

## 7. Mejoras pendientes (opcionales, no bloquean el cierre)

- **Presets de fecha en P135** — botones rápidos **Hoy / Este mes / Este año** que
  llenan `P135_DESDE`/`P135_HASTA` con un clic (DA "Set Value" + refresh del informe).
  Hoy el rango se carga a mano (default = este mes). No implementado aún.
- **Entry de menú directa a P135** "Informe de Ventas" (hoy se llega por el botón del
  dashboard P133). La agrega el PO en el Builder.
- **Filtro de fecha de la NC**: al combinar `condición` con NC, la NC no se filtra por
  condición (se restan todas las del rango) — impacto chico (4 NC), documentado en la
  función. Afinar si crece el dataset.
- Replicar la plantilla a **Compras / Inventario / Cobros**.

---

## 8. Aprobación

> Decisiones de definición tomadas con el PO el 2026-06-26 (vendedor = quien carga
> el presupuesto; estampado por trigger; `METAS_VENTA` con `PERIODO DATE`; dos
> capas con barras CSS en el imprimible). **Arranca por H1**
> (`db/F18_habilitador_vendedor.sql`, ya escrito) — pendiente aplicar y validar.

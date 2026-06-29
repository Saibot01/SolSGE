# Plan de implementación — Reportes Gerenciales (Cobros/Caja) — F22

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db`
**Estado del plan:** EN DEFINICIÓN — 2026-06-28. Segundo módulo gerencial; **replica la plantilla de Ventas (F18)**.
**Rango de error reservado:** `-20904 … -20909` (hueco libre entre F9 `-20903` y `-20910`; vecindario de Cobros).
**Páginas APEX nuevas:** **P136** (Dashboard de Cobros, interactivo) · **P137** (Generador de Informe de Cobros, imprimible) · **P138** (Carga de Metas de Cobranza, mantenimiento).
**Decisiones PO (2026-06-28):** alcance = **Cobranzas + Cartera CxC** (sin capa de flujo de caja); metas = **`METAS_COBRANZA` por OFICINA × mes** + seed demo.

> Segundo de los **reportes gerenciales para todos los módulos** pedidos por el
> profesor. La plantilla quedó cerrada en **Ventas (F18)**:
> habilitador → vistas `V_*` (single source of truth) → dashboard JET (P133) →
> informe imprimible por filtros (P135, barras CSS + `@media print`). Este plan la
> calca para **Cobros/Caja**. Ver `PLAN_REPORTES_GERENCIALES.md` y la memoria
> `reportes-gerenciales`.

---

## 1. Contexto y problema (verificado en `tesis_db`, 2026-06-28)

El módulo de Cobros/Caja ya está cerrado (F9 cobro de cuotas, F15 reverso, F17
cierre/arqueo) y los datos están limpios y **consistentes**, pero **no hay vista
gerencial**: el dueño no puede ver cuánto se recaudó por mes/oficina/medio de pago,
ni la antigüedad de la cartera por cobrar, ni quién le debe.

**A diferencia de Ventas, NO hay hueco de datos que bloquee el reporte.** La
dimensión "cobrador" ya existe poblada (`MOVIMIENTOS_CAJA.USUARIO`), así que **no
se necesita habilitador de dimensión** (en Ventas hubo que crear
`ORDENES_VENTA.USUARIO_CREACION` por trigger). El único agregado opcional es la
tabla de **metas de cobranza** para medir cumplimiento de recaudación.

### 1.1 Esquema relevante (verificado)

| Tabla | Rol | Datos vivos |
|---|---|---|
| `MOVIMIENTOS_CAJA` (PK `ID_MOVIMIENTO`) | movimientos de caja | 24 movimientos (20 en caja cerrada `'C'` + 4 en caja abierta `'A'`) |
| `DETALLE_MOVIMIENTO_CAJA` | desglose por medio de pago (`ID_METODO_PAGO`) | — |
| `CUENTAS_COBRAR` (`ID_CXC`) / `CUENTAS_COBRAR_DET` (`ID_DETALLE`) | cartera CxC + cuotas | 5 CxC PENDIENTE, 30 cuotas |
| `SOLICITUDES_REVERSO_COBRO` | workflow de reverso (F15, **oculto** — ver §1.5) | 1 aprobada (histórica) |
| `OFICINAS` (PK **`CODIGO_OFICINA`**), `CLIENTES`→`PERSONAS`, `METODOS_PAGO` | dimensiones | — |

> ⚠️ **`MOVIMIENTOS_CAJA.ESTADO` NO es activo/anulado — es abierta/cerrada de
> caja.** `'A'` ↔ `CAJAS.ESTADO='A'` (caja abierta); `'C'` ↔ caja **cerrada** (al
> cerrar la caja en F17, sus movimientos pasan de `'A'` a `'C'`). **Ambos estados
> son dinero válido** (verificado: solo existen `'A'` y `'C'`, no hay estado
> anulado en movimientos). El reverso **no** marca el movimiento — lo compensa con
> un EGRESO contrapartida (§1.2). **Filtrar `ESTADO IN ('A','C')`, NUNCA solo
> `='C'`** (eso descartaría toda cobranza en cajas abiertas).

**Tipos de movimiento (`MOVIMIENTOS_CAJA.TIPO`, `ESTADO IN ('A','C')`):**

| TIPO | Significado | n | Σ `TOTAL_MONEDA_LOCAL` |
|---|---|---:|---:|
| `INGRESO_VENTA` | venta contado que entra a caja | 9 | 3.962.000 |
| `COBRO_CXC` | cobranza de venta a crédito (recibo) | 9 | 2.650.555,6 |
| `EGRESO` | egresos (reversos + NC contado + gastos) | 6 | 1.476.025,2 |

### 1.2 🔑 REGLA DE ORO de cobranzas (verificada en `tesis_db` 2026-06-28)

**La cobranza "neta" se cuenta por los MOVIMIENTOS DE CAJA, descontando los
reversos — nunca por el flag de la cuota.** Es el análogo de FA−NC en Ventas:

- El **reverso NO anula** el `COBRO_CXC`: la fila original conserva su `ESTADO`
  (`'A'`/`'C'` según la caja). El reverso (F15) crea un **`EGRESO` contrapartida**
  que apunta al cobro original por `MOVIMIENTOS_CAJA.ID_MOVIMIENTO_REVERSADO`.
- Por lo tanto **`cobranza_neta = Σ COBRO_CXC (ESTADO IN ('A','C')) − Σ EGRESO con
  ID_MOVIMIENTO_REVERSADO NOT NULL`**.
- Verificado con datos vivos (2026-06-29): 2.650.555,6 (9 cobros) − 784.025,2
  (1 reverso) = **1.866.530,4**. Ese neto **cuadra** con las cuotas `PAGADA` y la
  cuota reversada **volvió a la cartera** (reaparece en el bucket de aging 61-90
  días). Datos 100% consistentes.
- **NO** medir cobranza por `CUENTAS_COBRAR_DET.ESTADO='PAGADA'` como fuente
  primaria: es un efecto derivado, no la fuente. El dinero recibido vive en
  `MOVIMIENTOS_CAJA` (igual criterio que F17 cierre de caja).
- El **`EGRESO` total** mezcla 3 cosas: reverso de cobro (1, 784.025,2), refund de
  NC contado (F14) y gastos manuales. Solo el reverso resta a la cobranza; los
  demás son flujo de caja (fuera de alcance de este módulo).

### 1.3 Cartera CxC y aging (verificado, `FN_HOY`=28/6/26)

`CUENTAS_COBRAR.SALDO` total = **3.927.140,8** (cuadra con Σ cuotas no pagadas).
Aging por `CUENTAS_COBRAR_DET.FECHA_VENCIMIENTO` vs `FN_HOY` (29/6/26):

| Bucket | Cuotas | Monto |
|---|---:|---:|
| Por vencer (≤0 días) | 18 | 791.040 |
| 61-90 días | 1 | 784.025,2 |
| +90 días | 3 | 2.352.075,6 |

> El flag `CUENTAS_COBRAR_DET.ESTADO` (`PAGADA`/`PENDIENTE`/`VENCIDA`) hoy está al
> día, pero el aging se **calcula desde `FECHA_VENCIMIENTO`** (no se confía en el
> flag, que puede quedar stale entre corridas del batch).

### 1.4 Dimensiones disponibles

| Dimensión | Origen | Nota |
|---|---|---|
| **Tiempo** | `MOVIMIENTOS_CAJA.FECHA` (TIMESTAMP) | post-fix F20 se guarda en **hora local** (`FN_AHORA`); `TRUNC(FECHA,'MM')` da el período correcto. Verificar en H2 que no queden filas viejas en UTC. |
| **Oficina** | `CAJAS.ID_OFICINA` → `OFICINAS.`**`CODIGO_OFICINA`** | ⚠️ PK de OFICINAS es `CODIGO_OFICINA`, **no** `ID_OFICINA`. |
| **Cobrador/cajero** | `MOVIMIENTOS_CAJA.USUARIO` | **ya poblado**; matchea `EMPLEADOS.CODIGO_USUARIO`. |
| **Cliente** | `MOVIMIENTOS_CAJA.ID_CLIENTE` → `CLIENTES.ID_PERSONA` → `PERSONAS` | nombre = `TRIM(PRIMER_NOMBRE||' '||SEGUNDO_NOMBRE||' '||PRIMER_APELLIDO||' '||SEGUNDO_APELLIDO)` (misma convención que `FN_KUDE_RECIBO_HTML`). |
| **Medio de pago** | `DETALLE_MOVIMIENTO_CAJA.ID_METODO_PAGO` → `METODOS_PAGO` | 1=efectivo, 2=POS, 3=transferencia, 4=QR. |
| **Cartera: oficina** | `CUENTAS_COBRAR.ID_COMPROBANTE` → `COMPROBANTES.ID_OFICINA` | la oficina de la cartera sale de la factura origen. |

**Reusables ya en BD:** `V_CAJA_SALDO`, `V_RECIBOS_COBRO` (ya joinea
COBRO_CXC→cuota→CxC), `V_RECIBOS_LISTA`.

**Realidad del dataset (presentarlo así en la defensa):** toda la cobranza está
concentrada en **1 cobrador (TCASCO) / 1 oficina (Suc - Roberto L Petit)**. Por
eso el corte gerencial fuerte es **cartera/aging + recaudación mensual + medios de
cobro + top deudores**, no un ranking de cobradores (saldría con una sola barra).
Por eso la **meta es por oficina**, no por cobrador.

### 1.5 Impacto del Reverso de Cobro OCULTO (F15, cambio 2026-06-29)

El módulo Reverso de Cobro **se ocultó a propósito** (interruptor maestro
`PARAMETROS.REVERSO_COBRO_ACTIVO='N'`, `db/F15_2_ocultar_reverso.sql`): el ícono de
P99 y el menú a P129 desaparecen, pero **backend, tablas y datos siguen
existiendo** y la feature es reactivable (`...='S'`). Razón del PO: la NC ya
reconcilia las cuotas y el reverso devolvía efectivo (contra "no se devuelve
dinero"). Impacto en este módulo gerencial — **mínimo, el plan NO cambia**:

1. **El reverso histórico (1, 784.025,2) persiste en los datos** → la regla de oro
   §1.2 y `V_COBROS_REVERSO` **se mantienen** (sin restarlo, la cobranza neta sale
   inflada en 784.025,2 y no cuadraría con la cartera).
2. **No habrá reversos nuevos** mientras el switch esté en `'N'` → el gap
   bruta↔neta queda **congelado** en el histórico; igual el cálculo es genérico y
   absorbe automáticamente si se reactiva.
3. **No se construye ningún visual centrado en reversos** (no estaba previsto): el
   reverso solo aparece como resta dentro del neto. El dashboard no expone una
   tarjeta/chart de "reversos del período".

---

## 2. Definiciones y decisiones (PO 2026-06-28)

| # | Tema | Decisión |
|---|------|----------|
| 1 | **Alcance** | **Cobranzas + Cartera CxC.** Recaudación neta (COBRO_CXC − reversos) por mes/oficina/medio + antigüedad de cartera + top deudores. **Sin** capa de flujo de caja (ingresos/egresos/saldos) — se puede agregar después como tercera capa. |
| 2 | **Habilitador de dimensión** | **No hace falta.** El cobrador ya existe (`MOVIMIENTOS_CAJA.USUARIO`). |
| 3 | **Metas** | Tabla **`METAS_COBRANZA` por OFICINA × mes** (`PERIODO DATE`, 1ro del mes). Más simple que `METAS_VENTA` (sin la regla 1-de-2: solo oficina). Seed demo idempotente. |
| 4 | **Regla de oro** | cobranza neta = Σ COBRO_CXC activos − Σ EGRESO-de-reverso (§1.2). |
| 5 | **Dos capas de reporte** | (a) **Dashboard interactivo** P136 (JET charts + KPIs + selector de mes). (b) **Informe imprimible por filtros** P137 (`FN_INFORME_COBROS_HTML`, barras CSS + `@media print`, estilo `kude`). Idéntico patrón a P133/P135. |

---

## 3. Diseño

### 3.1 Habilitador — `db/F22_metas_cobranza.sql` (idempotente)

1. **`METAS_COBRANZA`**: `ID_META` (identity PK), `ID_OFICINA` FK→`OFICINAS(CODIGO_OFICINA)` NOT NULL,
   `PERIODO DATE` (1ro del mes), `MONTO_META` NUMBER CHECK `>0`.
2. **Índice único** `UQ_METAS_COBRANZA_OFI_PER (ID_OFICINA, PERIODO)`.
3. **`TRG_METAS_COBRANZA_BI`** BEFORE INSERT/UPDATE: trunca `PERIODO` a `'MM'`.
4. Bloque de **verificación** final (tabla, trigger VALID/ENABLED, índice);
   `RAISE -20904` si falla.

> Más liviano que `METAS_VENTA`: como la meta es solo por oficina, no hay CHECK
> 1-de-2 ni índice funcional con `NVL`. `ID_OFICINA` es obligatorio.

### 3.2 Seed demo — `db/F22_seed_metas_cobranza_demo.sql` (idempotente, `MERGE`)

Metas demo por la(s) oficina(s) con cobranza, calibradas para un mix de
cumplimiento (algún mes sobre meta, otro debajo), como en F18. **Dato de
demostración**, no objetivo real (el PO carga los reales). Solo toca filas demo.

### 3.3 Vistas de apoyo — `db/F22_1_vistas_cobros.sql` (idempotente)

Single source of truth compartido por dashboard e informe HTML.

- **`V_COBROS_MOV`** — grano movimiento: `COBRO_CXC` válidos (**`ESTADO IN
  ('A','C')`** — abierta/cerrada, NO solo `'C'`) enriquecido con oficina (vía
  `CAJAS`→`OFICINAS.CODIGO_OFICINA`), `COBRADOR` (`USUARIO`), `CLIENTE` (vía
  `PERSONAS`), `PERIODO` (`TRUNC(FECHA,'MM')`), `FECHA_LOCAL`.
- **`V_COBROS_REVERSO`** — `EGRESO` (`ESTADO IN ('A','C')`) con
  `ID_MOVIMIENTO_REVERSADO NOT NULL`, atribuidos al cobro original (misma
  oficina/cobrador/período) para poder restarlos por las mismas dimensiones.
- **`V_COBROS_NETO_MES`** — recaudación **neta** por período/oficina(/cobrador) =
  Σ `V_COBROS_MOV` − Σ `V_COBROS_REVERSO`.
- **`V_COBROS_MEDIO`** — desglose neto por **medio de pago**
  (`DETALLE_MOVIMIENTO_CAJA`→`METODOS_PAGO`).
- **`V_CARTERA_CXC`** — cuotas no pagadas (`ESTADO IN ('PENDIENTE','VENCIDA')`) con
  `DIAS_ATRASO` (= `FN_HOY − FECHA_VENCIMIENTO`), `BUCKET` (por-vencer/1-30/31-60/
  61-90/+90), `CLIENTE`, `OFICINA` (vía `COMPROBANTE`→`COMPROBANTES.ID_OFICINA`),
  `COMPROBANTE_ORIGEN`, `MONTO_CUOTA`, `FECHA_VENCIMIENTO`.
- **`V_COBROS_OFICINA_META`** — neto por oficina/mes (de `V_COBROS_NETO_MES`) vs
  `METAS_COBRANZA` (cumplimiento %).

> **Gotcha de zona horaria:** `MOVIMIENTOS_CAJA.FECHA` es TIMESTAMP. Post-fix F20
> se inserta en hora local (`FN_AHORA`), así que `TRUNC(FECHA,'MM')` alcanza. H2
> verifica que no haya filas viejas en UTC; si las hubiera, convertir con
> `CAST(FECHA AT TIME ZONE 'America/Argentina/Buenos_Aires' AS DATE)`. **No usar
> `SYSDATE`** (BD en UTC) — usar `FN_HOY`/`FN_AHORA`.

### 3.4 Dashboard interactivo — **P136** (JET charts + KPIs)

Página normal (no modal). Selector de mes `P136_PERIODO` (Select List,
`page_action_on_selection=SUBMIT`, default "Todos los meses"), idéntico a P133.

- **Tarjetas KPI** (Dynamic Content PL/SQL): recaudación neta del período,
  # recibos, ticket promedio de cobro, % efectivo vs otros medios, **saldo de
  cartera** + % vencido, **cumplimiento de meta** de recaudación.
- **Charts JET** (patrón `jet_chart`; **ojo** `p_value_format_scaling`/
  `p_format_scaling` rompen el check `JET_CHARTS_SCALING` → omitir):
  1. Recaudación neta / mes (barras).
  2. Recaudación neta por oficina (barras).
  3. Medios de cobro (dona: efectivo/POS/transferencia/QR).
  4. **Aging de cartera** (barras: por-vencer/1-30/31-60/61-90/+90).
  5. **Top deudores** (barras horizontales: saldo por cliente).
  6. Recaudación por oficina **vs meta** (2 series: real + meta).
- **Reporte clásico** de respaldo (detalle de recibos). Botón "Imprimir informe" →
  abre **P137**.

### 3.5 Informe Gerencial imprimible — **P137** + `FN_INFORME_COBROS_HTML`

- **`FN_INFORME_COBROS_HTML(p_fecha_desde, p_fecha_hasta, p_oficina, p_cobrador,
  p_medio)`** en `db/F22_2_informe_cobros_html.sql` — genera **HTML del servidor**
  (mismo refactor por **rango de fechas** que `FN_INFORME_VENTAS_HTML`: cubre
  día/mes/año/rango; desglose temporal auto por día ≤31d / por mes). Secciones:
  encabezado (emisor desde `PARAMETROS` TIPO=`EMPRESA` + período), KPIs,
  recaudación/día-mes, por oficina, medios de cobro, **aging de cartera** (snapshot
  a hoy), **top deudores**, **ranking oficina vs meta**, **detalle de recibos**.
  Visuales como **barras CSS/HTML** (no JET). Entidades HTML (no `unistr`).
  `FN_HOY`/`FN_AHORA`.
- **P137 "Generador de Informe de Cobros"** (normal, no modal): región Filtros
  (contenedor **plano** + `p_region_css_classes=>'js-noprint'`) con Date Pickers
  `P137_DESDE`/`P137_HASTA` (default este mes, `YYYY-MM-DD`), Select Lists
  Oficina/Cobrador/Medio; botón **Generar** (DA→refresh) y **Imprimir**
  (DA→`window.print()`); región Informe (Dynamic Content →
  `FN_INFORME_COBROS_HTML(...)` con `ajax_items_to_submit`); CSS `kude` scopeado a
  `.kude` + `@media print` que oculta `.js-noprint` y el chrome UT.
- **NO es Documento Electrónico SIFEN**: control interno, sin CDC/QR, leyenda "sin
  validez fiscal".

### 3.7 Pantalla de carga de Metas de Cobranza — **P138** (pedido PO 2026-06-29)

Las metas hoy se cargan por SQL (seed/`MERGE`). El PO pidió una pantalla para
**altas/ediciones/bajas** de metas sin tocar la BD. Se implementa con el **patrón
ABM nativo de SolSGE** (reporte + form modal, como P13/P14 "Roles" y P63/P64
"Config. de Cajas") — **no Interactive Grid editable**, porque la app no tiene
ningún IG editable de precedente (todos sus IG son IR de solo lectura; los
editables son forms de un registro).

- **P138 "Metas de Cobranza"** (página normal): **Interactive Report** (patrón de
  P13/P63 de la app) de `METAS_COBRANZA` mostrando **Sucursal** (join `OFICINAS`),
  **Período**
  (`TO_CHAR(periodo,'YYYY-MM')`), **Monto meta**, y además **Recaudación real** +
  **Cumplimiento %** (LEFT JOIN a `V_COBROS_OFICINA_META`, así el PO ve el avance
  al cargar). Columna con **link de edición** (ícono) → P139 pasando
  `P139_ID_META`; botón **Crear** → P139 (cache limpia); DA `apexafterclosedialog`
  → refresh del reporte.
- **P139 "Meta de Cobranza"** (modal): form DML sobre `METAS_COBRANZA` con
  **Sucursal** (`ID_OFICINA`, Select List, LOV SQL inline `OFICINAS` display
  `DESCRIPCION` / return `CODIGO_OFICINA`), **Período** (`PERIODO`, Date Picker
  `YYYY-MM-DD`; el trigger `TRG_METAS_COBRANZA_BI` trunca a mes — el ítem va **sin
  default**, lo carga el usuario), **Monto meta** (`MONTO_META`, number). `ID_META`
  PK identity oculta. Botones Crear/Guardar/Eliminar (condicionados por PK
  null/not-null) + Cancelar. Las validaciones de BD cubren: monto>0 (CHECK),
  duplicado oficina+período (índice único → notificación inline), FK oficina.
- Import **aislado** (`install_p138.sql`, P139 antes que P138). Menú "Metas de
  Cobranza"→P138 lo agrega el PO. Opcional: link desde P136.

### 3.6 Despliegue / importación

- DB: `sql -S -name tesis_db < db/F22_metas_cobranza.sql` (stdin redirect, por el
  bug del `@file` en esta máquina), luego seed, vistas y función.
- APEX: P136/P137 se importan **aisladas** (install temporal mínimo:
  `set_environment` + `delete_NN`/`page_NN` + `end_environment`), **no** el
  `install_page.sql` completo (pisa cambios del PO). El menú lo agrega el PO en el
  Builder.

---

## 4. Hitos

- [x] **H1 — Habilitador (`db/F22_metas_cobranza.sql`). Hecho 2026-06-29.**
  `METAS_COBRANZA` (ID_META identity PK, ID_OFICINA FK→OFICINAS(CODIGO_OFICINA)
  NOT NULL, PERIODO DATE, MONTO_META>0) + `UQ_METAS_COBRANZA_OFI_PER` +
  `TRG_METAS_COBRANZA_BI` (trunca PERIODO a 'MM') + verificación, aplicado a
  `tesis_db` (4/4 checks OK). **Smoke con `ROLLBACK`:** período 2026-06-15 → trunca
  a 2026-06-01; meta=0 → ORA-02290 (CK_METAS_COBRANZA_MONTO); duplicado
  (oficina,período) → ORA-00001. Nada persistido (0 filas).
- [x] **H2 — Vistas (`db/F22_1_vistas_cobros.sql`). Hecho 2026-06-29.** 6 vistas:
  `V_COBROS_MOV` (grano cobro, `ESTADO IN ('A','C')`), `V_COBROS_REVERSO` (EGRESO
  de reverso atribuido al cobro origen), `V_COBROS_NETO_MES` (bruto−reverso),
  `V_COBROS_MEDIO` (detalle×medio, bruto), `V_CARTERA_CXC` (cuotas no pagadas +
  aging por `FECHA_VENCIMIENTO` vs `FN_HOY`), `V_COBROS_OFICINA_META` (neto vs
  meta). **Verificado contra datos reales:** cobranza neta 1.866.530,4 (bruto
  2.650.555,6 − reverso 784.025,2); cartera 3.927.140,8; aging 791.040 /
  784.025,2 / 2.352.075,6; medios efectivo 1.866.530,4 + transf 784.025,2; top
  deudor Willian Benega 3.559.500,8. Filtro `ESTADO IN ('A','C')` (gotcha R8).
  *(Cifras vivas — se mueven con cada cobro/cierre nuevo.)*
- [x] **H3 — Dashboard interactivo P136. Construido 2026-06-29**
  (`apex-work/f100/application/pages/page_00136.sql`, importado aislado vía
  `install_p136.sql`). 9 regiones: KPIs (Dynamic Content: recaudación neta, recibos,
  cobro promedio, % efectivo, cartera + % vencido, cumplimiento meta) + 6 JET charts
  (neta/mes, neta/sucursal, medios de cobro donut, aging de cartera, top deudores
  horizontal, sucursal-vs-meta 2 series) + reporte "Detalle de recibos" + botón
  Imprimir → P137. Selector `P136_PERIODO` (DA refresh, no submit). Queries y bloque
  KPI validados contra datos reales (neta 1.866.530,4; cartera 3.927.140,8; %vencido
  79,9%; %efectivo 70,4%). Aging y top deudores son **snapshot** (no filtran por mes).
  **Gotchas heredados respetados:** sin `p_value_format_scaling`/`p_format_scaling`
  (check `JET_CHARTS_SCALING`); sin `p_static_id`; región de filtros = contenedor
  plano. **Pendiente:** validación visual en vivo por el PO; entry de menú (la agrega
  el PO). El chart sucursal-vs-meta y el KPI de cumplimiento quedan vacíos/"—" hasta
  el seed de metas (H5).
- [x] **H4 — Informe imprimible P137 + `FN_INFORME_COBROS_HTML`. Hecho
  2026-06-29.** `FN_INFORME_COBROS_HTML(p_fecha_desde, p_fecha_hasta, p_oficina,
  p_cobrador)` (`db/F22_2_informe_cobros_html.sql`): rango de fechas (día/mes/año/
  rango, desglose auto día≤31d / mes), regla de oro cobros−reversos (reversos por
  `V_COBROS_REVERSO.fecha` = fecha del cobro original). Secciones: KPIs, recaudación
  neta/día-mes, por sucursal, **medios de cobro**, **aging de cartera** (snapshot),
  ranking sucursal vs meta, **top deudores**, detalle de recibos. Barras CSS,
  entidades HTML (no `unistr`), `FN_HOY`/`FN_AHORA`. **Filtro = oficina + cobrador**
  (medio va como sección, no filtro — el grano detalle vs movimiento lo hace ruidoso
  con pagos mixtos; condición no aplica a cobros). 7/7 verificaciones OK (HTML 5658
  chars sin filtros). Requirió agregar `fecha` a `V_COBROS_REVERSO` y
  `fecha`/`cobrador_cod` a `V_COBROS_MEDIO` (F22.1). **P137 "Generador de Informe de
  Cobros"** (`page_00137.sql`, normal): Filtros (contenedor plano `js-noprint`, date
  pickers + select lists) + Generar (DA refresh) + Imprimir (DA `window.print()`) +
  Informe (Dynamic Content → la función); CSS `kude` scopeado + `@media print`. El
  botón de P136 abre P137. Import aislado vía `install_p137.sql`. **Pendiente:**
  validación visual del PO.
- [x] **H5 — Seed de metas demo (`db/F22_seed_metas_cobranza_demo.sql`). Hecho
  2026-06-29.** `MERGE` idempotente por (oficina, período). 1 meta demo: Roberto L
  Petit jun/2026 = 1.700.000 → `V_COBROS_OFICINA_META`: neto 1.866.530,4 /
  cumplimiento **109,8%**. El KPI "Cumplimiento meta" y el chart sucursal-vs-meta de
  P136 ya poblan. Dato de demo (defensa); las reales las carga el PO en **P138**.
- [x] **H5b — Pantalla de carga de Metas de Cobranza (P138 + P139). Construido
  2026-06-29.** *(Pedido del PO 2026-06-29.)* Patrón ABM de la app (reporte +
  form modal, como P13/P14 y P63/P64; **no IG** — no hay precedente de IG editable
  en SolSGE). **P138** "Metas de Cobranza": **Interactive Report** de `METAS_COBRANZA`
  con sucursal + período + monto + **recaudación real y cumplimiento %** (LEFT JOIN a
  `V_COBROS_OFICINA_META`), link de edición por fila + botón **Crear** → P139, y DA
  `apexafterclosedialog` → refresh. **P139** "Meta de Cobranza" (modal): form DML
  sobre `METAS_COBRANZA` (Sucursal Select List LOV `OFICINAS`, Período Date Picker,
  Monto number) con botones Crear/Guardar/Eliminar; las validaciones de BD (monto>0,
  único oficina+período, FK) protegen. Importado aislado vía `install_p138.sql`
  (P139 primero). Reporte verificado (meta 1.700.000 / real 1.866.530,4 / 109,8%).
  **Pendiente:** validación visual del PO; entry de menú "Metas de Cobranza"→P138 (la
  agrega el PO). Ver §3.7.
- [x] **H6 — Cierre. Hecho 2026-06-29.** Páginas en `apex-work` (P136-P141 +
  installs aislados), registradas en `install_page.sql` (tracking), `CLAUDE.md`
  actualizado (entrada F22 + gotcha ESTADO A/C), commit `feat(F22)`. Menú y
  validación visual a cargo del PO.

---

## 5. Riesgos

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | Cobranza concentrada en 1 cobrador/oficina → charts esparcidos. | Esperado para tesis; el foco es cartera/aging/medios, no ranking de cobradores. Meta por oficina (no cobrador). |
| R2 | Doble lógica dashboard vs HTML (números que no cuadran). | Ambos consumen `V_COBROS_*`/`V_CARTERA_CXC` (§3.3). |
| R3 | Confundir cobranza bruta con neta (no restar reversos). | Regla de oro §1.2 encapsulada en `V_COBROS_NETO_MES`. |
| R4 | `MOVIMIENTOS_CAJA.FECHA` en UTC para filas viejas. | H2 verifica; convertir con `AT TIME ZONE` si hace falta; `FN_HOY`/`FN_AHORA` en todo. |
| R5 | Editar P136/P137 vía `install_page.sql` completo pisa cambios del PO. | Import **aislado** por página (memoria `apex-import-aislado`); re-exportar antes de tocar. |
| R6 | Sin print server, no hay PDF nativo de APEX. | HTML + `@media print` + Ctrl+P, igual que KuDE/arqueo/P135 (ya probado). |
| R7 | Gotchas APEX del primer dashboard se repiten. | `JET_CHARTS_SCALING` (omitir scaling); `p_static_id` no en `create_page_plug`; `unistr` en LOV → ORA-12704 (LOV estático ASCII); región con ítems = contenedor plano (no `NATIVE_STATIC_CONTENT` → ORA-01403). |
| R8 | **Trampa `MOVIMIENTOS_CAJA.ESTADO`**: `'C'` parece "anulado/confirmado" pero es **caja cerrada**; `'A'` es **caja abierta**, ambos dinero válido. Filtrar `='C'` borra la cobranza de cajas abiertas. | Filtrar **`ESTADO IN ('A','C')`** en todas las vistas; el reverso se descuenta por el EGRESO contrapartida, no por estado. Encapsulado en `V_COBROS_*`. |

---

## 6. Fuera de alcance

- **Flujo de Caja** como capa propia (ingresos/egresos/saldos por caja) — se puede
  sumar después reusando `V_CAJA_SALDO` y F17.
- Metas por cobrador o por cliente (hoy solo oficina × mes).
- Multi-moneda real (todo PYG en datos; `TOTAL_MONEDA_LOCAL`).
- PDF nativo / print server / envío por correo.
- Backfill o reconstrucción de movimientos históricos.
- Proyección de cobranza / scoring de morosidad (solo aging descriptivo).

---

## 7. Aprobación

> Decisiones tomadas con el PO el 2026-06-28 (alcance Cobranzas+Cartera; sin
> habilitador de dimensión; `METAS_COBRANZA` por oficina×mes con seed demo; dos
> capas con barras CSS en el imprimible). **Arranca por H1**
> (`db/F22_metas_cobranza.sql`) — pendiente de escribir y aplicar.

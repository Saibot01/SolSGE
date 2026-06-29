# Plan de implementación — Reverso de Cobro de Cuota (F15)

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db`
**Estado del plan:** PROPUESTO 2026-06-21 (workflow 2026-06-24) → **OCULTO 2026-06-29**
(ver §12). El backend y las pantallas siguen intactos; solo se ocultaron los puntos
de entrada con un interruptor reversible, porque la NC ya reconcilia las cuotas
pendientes de la CxC y el reverso devuelve efectivo (contra la regla del PO "no se
devuelve dinero").
**Rango de error reservado:** `-20991 … -20999` (no colisiona con F11 -20930.. ni F14 -20970..-20990).

> Plan separado. Cierra la deuda cruzada anotada en `PLAN_FACTURACION.md §F9`,
> `PLAN_ANULACION_FACTURAS.md §2 #2` y `PLAN_NOTA_CREDITO.md §8 R4`: hoy **no
> existe forma de revertir un cobro de cuota ya aplicado**. Eso bloquea dos
> flujos completos:
> - **Anulación (F11):** no se puede solicitar anular una factura a crédito que
>   tenga alguna cuota `PAGADA`.
> - **Nota de Crédito (F14):** una NC de crédito se capa al saldo pendiente; si el
>   monto excede lo ya cobrado falla con `-20982` ("reverse los cobros primero").
>
> El reverso de cobro es la pieza faltante para destrabarlos y, además, para
> corregir cobros mal aplicados (monto/método/cuota equivocada).

---

## 1. Contexto

`FN_COBRAR_CUOTA` (`db/F9_cobros.sql`) registra un cobro así (todo atómico):

1. Reserva nro de recibo vía `FN_OBTENER_COMPROBANTE(<talonario RC>)`.
2. INSERT `MOVIMIENTOS_CAJA` `TIPO='COBRO_CXC'` (cabecera del recibo:
   `NRO_RECIBO`, `ID_TALONARIO_RECIBO`, `FECHA_EMISION_RECIBO`,
   `ID_CUENTA_COBRAR_DET`, `ID_CAJA`, `ID_CLIENTE`, totales).
3. INSERT `DETALLE_MOVIMIENTO_CAJA` (forma de pago + método + nro referencia).
4. UPDATE cuota `CUENTAS_COBRAR_DET.ESTADO='PAGADA'`.
5. UPDATE `CUENTAS_COBRAR.SALDO -= monto`; si `SALDO=0` → `ESTADO='PAGADA'`.

Decisión vigente F9 #15: **1 cuota = 1 recibo**. Por lo tanto **revertir un
recibo = revertir exactamente una cuota** (no hay recibos multi-cuota hoy).

El reverso debe deshacer (4) y (5), compensar (2)/(3) en caja, y **conservar la
historia** (no borra el recibo; el número RC queda quemado, igual que F11/F14).

---

## 2. Estado actual relevado (BD, 2026-06-21)

- `MOVIMIENTOS_CAJA`: `ESTADO CHAR` con `CK_MOVCAJA_ESTADO CHECK (ESTADO IN ('A','C'))`,
  `CK_MOVCAJA_TIPO CHECK (TIPO IN ('INGRESO_VENTA','COBRO_CXC','EGRESO','AJUSTE'))`,
  `CK_MOVCAJA_RECIBO` (si `TIPO='COBRO_CXC'` el recibo es obligatorio; si no, los
  4 campos del recibo deben ser NULL).
- `CUENTAS_COBRAR_DET.ESTADO`: `CK_CCD_ESTADO IN ('PENDIENTE','PAGADA','VENCIDA','ANULADA')`
  → revertir a `PENDIENTE`/`VENCIDA` está permitido sin tocar el CK.
- `CUENTAS_COBRAR.ESTADO`: `CK_CXC_ESTADO IN ('PENDIENTE','PAGADA','ANULADA')`
  → revertir `PAGADA → PENDIENTE` permitido.
- `FN_CAJA_ABIERTA_USUARIO` existe (caja abierta del aprobador).
- `TIPO='EGRESO'` ya está soportado por el CK y por `CERRAR_CAJA` v2 (resta egresos).

**Implicancia clave:** un `EGRESO` de reversión es válido sin tocar constraints
(no lleva campos de recibo, que quedan NULL → cumple `CK_MOVCAJA_RECIBO`).

---

## 3. Decisiones tomadas (con el PO, 2026-06-24)

| # | Decisión |
|---|----------|
| 1 | **Workflow con aprobación (4 ojos), patrón F11/F14.** El cajero **SOLICITA** el reverso (queda pendiente) → un aprobador **APRUEBA** (se ejecutan los efectos: EGRESO + reactivación de cuota + suba de saldo) o **RECHAZA** (no pasa nada). El número de recibo RC **no** se quema de nuevo: ya estaba quemado al cobrar; el reverso es un evento posterior. |
| 2 | **Caja del contramovimiento = caja abierta del día del APROBADOR.** El EGRESO sale del cajón de hoy del que aprueba (la caja del cobro original pudo cerrarse/arquearse). Requiere caja abierta del día al aprobar. Caja original intacta. |
| 3 | **La solicitud NO toca caja ni CxC.** Solo al **aprobar** se materializan los efectos. Una solicitud pendiente o rechazada deja todo como estaba (el cobro sigue aplicado). |
| 4 | **Conservar el recibo.** El `NRO_RECIBO` (RC) queda; el talonario RC **no** se decrementa. El reverso se documenta como EGRESO + reactivación de la cuota. |
| 5 | **Guard anti doble-reverso.** Un cobro `COBRO_CXC` no puede tener más de una solicitud `P` (pendiente) ni una `A` (ya aprobada/reversado). Se valida al solicitar y se re-valida al aprobar. |
| 6 | **Cuota vencida:** si al reactivar la `FECHA_VENCIMIENTO` ya pasó, la cuota vuelve a `VENCIDA`; si no, a `PENDIENTE`. |
| 7 | **Orden operativo con NC/anulación:** el reverso es **prerequisito** — primero se aprueba el reverso del/los cobro(s), luego queda habilitada la NC total (F14) o la anulación (F11). No se automatiza el encadenamiento. |
| 8 | **Aprobador = cualquier usuario con acceso a la página de aprobación** (auth estándar APEX, sin nuevo modelo de roles), igual que F11/P121 y F14/P126. Autoaprobación no se enforza en el MVP (decisión consciente, como F11). |

---

## 4. Diseño

### 4.1 Backend — `db/F15_reverso_cobro.sql` (idempotente)

**Paso 1 — Tabla de staging `SOLICITUDES_REVERSO_COBRO`:**
```
ID_SOLICITUD_RC       NUMBER PK (identity)
ID_MOVIMIENTO         NUMBER NOT NULL FK MOVIMIENTOS_CAJA  -- el cobro COBRO_CXC a revertir
MOTIVO                VARCHAR2(500) NOT NULL                -- ≥10 chars
ESTADO                CHAR(1) NOT NULL CK ('P','A','R')     -- pend/aprob/rechaz
USUARIO_SOLICITA      VARCHAR2(60) NOT NULL
FECHA_SOLICITUD       DATE NOT NULL
USUARIO_APRUEBA       VARCHAR2(60)
FECHA_RESOLUCION      DATE
MOTIVO_RECHAZO        VARCHAR2(500)
ID_MOVIMIENTO_EGRESO  NUMBER FK MOVIMIENTOS_CAJA            -- el EGRESO generado al aprobar
```
Índice único parcial: una sola solicitud **no resuelta** por cobro →
`CREATE UNIQUE INDEX UQ_SRC_MOV_PEND ON SOLICITUDES_REVERSO_COBRO
 (CASE WHEN ESTADO='P' THEN ID_MOVIMIENTO END)`.

**Paso 2 — `FN_COBRO_REVERSABLE(p_id_movimiento) RETURN VARCHAR2`** (mensaje
amigable / NULL). Bloquea si: el movimiento no existe o `TIPO<>'COBRO_CXC'`; ya
fue reversado (existe solicitud `A`); ya tiene una solicitud `P` pendiente; la
cuota/CxC asociada está `ANULADA`.

**Paso 3 — `PRC_SOLICITAR_REVERSO_COBRO(p_id_movimiento, p_motivo, p_usuario)`**
- Valida `FN_COBRO_REVERSABLE` → `-20991` si bloquea; motivo ≥10 → `-20992`.
- INSERT solicitud `ESTADO='P'`. No toca caja ni CxC.

**Paso 4 — `PRC_APROBAR_REVERSO_COBRO(p_id_solicitud, p_usuario)`** (atómica, sin COMMIT):
1. Lock solicitud `FOR UPDATE`; validar `ESTADO='P'` → `-20996`.
2. Lock del `MOVIMIENTOS_CAJA` original; re-validar reversable (otra pudo aprobarse) → `-20991`.
3. Resolver caja del aprobador: `v_caja := FN_CAJA_ABIERTA_USUARIO(p_usuario)`;
   NULL → `-20993`; `TRUNC(FEC_APERTURA)<>TRUNC(SYSDATE)` → `-20994`.
4. **Caja:** INSERT `MOVIMIENTOS_CAJA` `TIPO='EGRESO'`, `ID_CAJA=v_caja`,
   `ID_CLIENTE` y montos del original, campos de recibo NULL,
   `OBSERVACION='Reverso de cobro recibo '||nro||' — '||motivo`. + `DETALLE_MOVIMIENTO_CAJA`
   espejo. Guardar el `ID_MOVIMIENTO` del egreso.
5. **Cuota:** `UPDATE CUENTAS_COBRAR_DET SET ESTADO = CASE WHEN FECHA_VENCIMIENTO <
   TRUNC(SYSDATE) THEN 'VENCIDA' ELSE 'PENDIENTE' END WHERE ID_DETALLE = <det del recibo>`.
6. **Cabecera CxC:** `UPDATE CUENTAS_COBRAR SET SALDO = SALDO + <monto cuota>,
   ESTADO='PENDIENTE' WHERE ID_CXC = <cxc>`. Sanity `SALDO <= TOTAL_A_PAGAR` → `-20995`.
7. UPDATE solicitud `ESTADO='A'`, `USUARIO_APRUEBA`, `FECHA_RESOLUCION`,
   `ID_MOVIMIENTO_EGRESO`.

**Paso 5 — `PRC_RECHAZAR_REVERSO_COBRO(p_id_solicitud, p_motivo, p_usuario)`**
- Valida `ESTADO='P'` y motivo ≥10 → `-20998`. UPDATE `ESTADO='R'` + auditoría.
  No materializa nada.

**Paso 6 — Vista `V_SOLICITUDES_REVERSO`** (fuente del IR P129): solicitud +
recibo (`NRO_RECIBO`, monto, cuota, cliente) + estados, para listar/aprobar.

**Paso 7 — Verificación final** (counts, idempotencia, smoke con `ROLLBACK`).

### 4.2 APEX

| Página | Tipo | Rol |
|--------|------|-----|
| **P128** (nueva) | Modal Dialog | "Solicitar Reverso de Cobro". Entra con `P128_ID_MOVIMIENTO` (el recibo, desde P99/P95). Display: nro recibo, cuota, cliente, monto, fecha. Aviso `FN_COBRO_REVERSABLE` (BEFORE_HEADER, estilo F14 P125). Item editable: `P128_MOTIVO` (Textarea ≥10). Botón **SOLICITAR** → `PRC_SOLICITAR_REVERSO_COBRO` + close. |
| **P129** (nueva) | IR Normal | "Reversos de Cobro". Source = `V_SOLICITUDES_REVERSO`. Filtros por estado (Pendientes / Aprobados / Histórico). Link a P130 sobre `ESTADO='P'`. Badges. |
| **P130** (nueva) | Modal Dialog | "Aprobar/Rechazar Reverso". Detalle de la solicitud (display only) + `P130_MOTIVO_RECHAZO` (visible si RECHAZAR). Botones **APROBAR** / **RECHAZAR** → `PRC_APROBAR_REVERSO_COBRO` / `PRC_RECHAZAR_REVERSO_COBRO` según request. Validación motivo rechazo ≥10. |

**Páginas modificadas:**
- **P99 (Detalle de Cuotas)** y/o **P95 (Cobros)**: ícono "Solicitar Reverso"
  sobre cuotas `PAGADA` → abre P128 con el `ID_MOVIMIENTO` del cobro asociado
  (join a `MOVIMIENTOS_CAJA TIPO='COBRO_CXC'` por `ID_CUENTA_COBRAR_DET`, ya
  presente en P99 para mostrar recibo/fecha de pago).
- **Menú** (`navigation_menu`): entry "Reversos de Cobro" → P129 bajo "Cuentas a
  Cobrar", con `security_pkg.can_access`. **Editar en Builder + re-exportar**
  (shared components no upsert por `@@`).

> **Enfoque de capa APEX (igual que F14):** el PO arma los shells en el Builder,
> Claude cablea (procesos, SQL, LOVs, validaciones, links, condiciones) y captura
> al repo. Re-exportar cada página **antes** de editar.

---

## 5. Hitos

- [x] **Hito 1** ✅ (2026-06-24) — Backend `db/F15_reverso_cobro.sql` aplicado y
  verificado en `tesis_db`: columna `MOVIMIENTOS_CAJA.ID_MOVIMIENTO_REVERSADO` +
  FK, tabla staging `SOLICITUDES_REVERSO_COBRO`, índice único parcial
  `UQ_SRC_MOV_PEND`, `FN_COBRO_REVERSABLE`, `PRC_SOLICITAR/APROBAR/RECHAZAR_REVERSO_COBRO`,
  `V_SOLICITUDES_REVERSO` (8/8 OK, idempotente). Smoke end-to-end con `ROLLBACK`
  PASS: cobro #7 (recibo 0006) → solicitar (CBARRIOS) → guard doble solicitud
  `-20991` → aprobar (TCASCO) → cuota `PAGADA→PENDIENTE`, saldo `98280→147420`
  (+49140 exacto), EGRESO en caja del aprobador ligado al cobro, solicitud `A`;
  rollback dejó los datos intactos (0 residuales).
  > Bug corregido en el camino: `PRC_APROBAR` re-validaba con `FN_COBRO_REVERSABLE`,
  > que bloquea por "solicitud P pendiente" — justo la que se está aprobando. Se
  > reemplazó por re-checks de los guards duros (ya reversado / egreso ligado /
  > cuota o CxC anulada), sin el chequeo de pendiente.
- [x] **Hito 2** ✅ (2026-06-24) — P128 modal "Solicitar Reverso": shell del PO
  cableado por Claude (BEFORE_HEADER `FN_COBRO_REVERSABLE` → `P128_BLOQUEO`;
  items display recibo/cliente/cuota/monto; condición de bloqueo en MOTIVO+SOLICITAR;
  validación motivo ≥10; AFTER_SUBMIT `PRC_SOLICITAR_REVERSO_COBRO` + close).
  Importado limpio + capturado en `apex-work/.../page_00128.sql`.
- [x] **Hito 3** ✅ (2026-06-24) — P129 lista (IR sobre `V_SOLICITUDES_REVERSO`,
  ESTADO decodificado en SQL, detail link "Resolver" → P130 con `P130_ID_SOLICITUD`,
  reporte primario que oculta columnas internas) + P130 modal (items display del
  detalle, validación motivo rechazo ≥10 gated `:REQUEST='RECHAZAR'`, procesos
  `PRC_APROBAR`/`PRC_RECHAZAR_REVERSO_COBRO` por botón + close). Importados +
  capturados. Verificado: P128 7 items/3 procesos, P130 8 items/3 procesos, P129 IR OK.
- [x] **Hito 4** ✅ (2026-06-24) — Entry de menú "Reversos de Cobro" → P129
  agregada por el PO en el Builder. Ícono "Solicitar Reverso" en **P99** cableado
  por Claude: columna `REVERSO` (HTML Expression con directiva `{case '&ESTADO.'
  when 'PAGADA' ...}`) que muestra el link a P128 **solo en cuotas PAGADA**,
  pasando el `ID_MOVIMIENTO` del cobro (subquery a `MOVIMIENTOS_CAJA TIPO='COBRO_CXC'`
  agregada al source del IG). Importado + capturado en `apex-work/.../page_00099.sql`.
  Verificado: PAGADA → id cobro presente (link visible), PENDIENTE → sin link.
- [ ] **Hito 5** — Test e2e browser: cobrar cuota (F9) → solicitar → aprobar con
  otro usuario con caja del día → cuota vuelve a PENDIENTE/VENCIDA, saldo sube,
  EGRESO en caja del aprobador; rechazo no hace nada; doble solicitud bloqueada.
- [ ] **Hito 6** — Re-test de flujos destrabados: anular factura crédito con cuota
  previamente cobrada (F11) y NC total/parcial que excedía saldo (F14), **después**
  de aprobar el reverso.
- [ ] **Hito 7** — Cierre: re-export, `CLAUDE.md`, commit `feat(F15)`, actualizar
  notas de deuda en F9/F11/F14, tag `f15-reverso-cobro`.

---

## 6. Test plan

| Caso | Escenario | Esperado |
|------|-----------|----------|
| A | Solicitar + aprobar (feliz) | Solicitud `P→A`; EGRESO en caja del día del aprobador; cuota → PENDIENTE; `CUENTAS_COBRAR.SALDO` sube; `ESTADO='PENDIENTE'`; recibo intacto. |
| B | Cuota ya vencida al reactivar | Cuota → `VENCIDA`. |
| C | Doble solicitud sobre el mismo cobro | Bloqueo `-20991` / índice único parcial. |
| D | Aprobar sin caja abierta / caja de otro día | `-20993` / `-20994`. |
| E | Motivo vacío o corto (solicitar/rechazar) | `-20992` / `-20998`. |
| F | Rechazo | Solicitud `R`; cobro intacto; sin EGRESO. |
| G | **Destrabe F11:** anular factura crédito con 1 cuota cobrada → solicitar+aprobar reverso → la anulación procede. | F11 deja de bloquear. |
| H | **Destrabe F14:** NC total sobre factura crédito con cuotas cobradas → reverso aprobado → NC procede sin `-20982`. | OK. |
| I | Idempotencia: correr `F15_reverso_cobro.sql` 2× | Sin error. |

---

## 7. Riesgos

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | El EGRESO va a la caja del aprobador, no a la original (cerrada). | Decisión #2, contablemente correcto. Trazabilidad por `ID_MOVIMIENTO_EGRESO` en la solicitud + observación. |
| R2 | Doble reverso concurrente. | Índice único parcial `UQ_SRC_MOV_PEND` + `FOR UPDATE` del cobro al aprobar + re-check. |
| R3 | Revertir un cobro cuya CxC ya fue `ANULADA` por NC/anulación previa. | `FN_COBRO_REVERSABLE` bloquea si la cuota/CxC está `ANULADA`. |
| R4 | El recibo impreso (P119) sigue existiendo tras el reverso. | Aceptable (número RC quemado, filosofía F11/F14). Opcional futuro: watermark "REVERSADO" en P119. |
| R5 | Signo del EGRESO en `DETALLE_MOVIMIENTO_CAJA` y su impacto en `CERRAR_CAJA` v2. | `CERRAR_CAJA` ya resta `TIPO='EGRESO'`; validar en Hito 5 que el cierre del día dé el neto correcto. |
| R6 | Aprobador sin caja abierta no puede aprobar reversos contado. | Mensaje claro `-20993`/`-20994` en P130: "abrí caja del día para aprobar". |

---

## 8. Fuera de alcance

- Reverso parcial de una cuota (hoy 1 recibo = 1 cuota; no hay cobros parciales).
- Reverso de movimientos `INGRESO_VENTA` (venta contado) — lo cubre la anulación
  de factura (F11).
- Watermark "REVERSADO" en el recibo P119 (deuda cosmética futura).
- Autoaprobación enforzada (4 ojos estricto) — MVP permite mismo usuario, como F11.

---

## 9. Aprobación

> Plan propuesto el 2026-06-21, workflow definido con el PO el 2026-06-24
> (aprobación de 4 ojos + EGRESO en caja del día del aprobador). Backend (Hito 1)
> aplicado y verificado el 2026-06-24. Resta la capa APEX (Hitos 2–4, §10).

---

## 10. Guía de construcción de la capa APEX (Builder paso a paso)

**Modelo de trabajo (igual que F14):** el PO arma los *shells* en el App Builder
(estructura mínima: página + items + región + botones) y **Claude cablea** el
resto (procesos PL/SQL, SQL de la región, validaciones, condiciones, links,
LOVs) y captura al repo.

> **Regla del PO:** re-exportar cada página del Builder **antes** de que Claude la
> edite, y re-importar verificando. No usar `@@` en `install_component.sql` para
> el menú (shared components no soportan upsert — ver R8 de F11).

**Números de página (verificados libres 2026-06-24):** P128, P129, P130.

Objetos de BD que ya existen y se usan (Hito 1, todos `VALID`):
`FN_COBRO_REVERSABLE`, `PRC_SOLICITAR_REVERSO_COBRO`,
`PRC_APROBAR_REVERSO_COBRO`, `PRC_RECHAZAR_REVERSO_COBRO`, `V_SOLICITUDES_REVERSO`.

---

### 10.1 — P128 "Solicitar Reverso de Cobro" (modal)

**Shell que arma el PO en el Builder:**
1. App Builder → App 100 → **Create Page** → **Blank Page**.
2. Name: `Solicitar Reverso de Cobro`. Page Number: `128`. Page Mode: **Modal Dialog**.
3. **Create items** en la página:
   - `P128_ID_MOVIMIENTO` → tipo **Hidden** (es el parámetro de entrada: el `ID_MOVIMIENTO` del cobro).
   - `P128_MOTIVO` → tipo **Textarea**, Label `Motivo del reverso`.
4. **Create Region** tipo **Static Content**, Name `Datos del cobro` (queda vacía; Claude la rellena con items display-only).
5. **Create Button** `SOLICITAR` → Action **Submit Page**, template hot/primary.
6. Guardar.

**Lo que cablea Claude después:**
- Items display-only `P128_NRO_RECIBO`, `P128_CLIENTE`, `P128_NRO_CUOTA`,
  `P128_MONTO` + ítem `P128_BLOQUEO` (display-only).
- Proceso **BEFORE_HEADER** "Cargar datos + bloqueo": puebla los display-only
  desde `MOVIMIENTOS_CAJA` + cuota, y setea
  `:P128_BLOQUEO := WKSP_WORKPLACE.FN_COBRO_REVERSABLE(:P128_ID_MOVIMIENTO)`.
- `P128_MOTIVO` y el botón `SOLICITAR` con **condición server-side**
  `Item is NULL` sobre `P128_BLOQUEO` (si hay bloqueo, desaparecen y solo se ve
  el aviso) — mismo patrón que F14/P125.
- Validación: `P128_MOTIVO` requerido y ≥10 chars, **When Button Pressed = SOLICITAR**.
- Proceso **AFTER_SUBMIT** "Solicitar reverso" (Request = `SOLICITAR`):
  ```sql
  DECLARE v_id NUMBER;
  BEGIN
    WKSP_WORKPLACE.PRC_SOLICITAR_REVERSO_COBRO(
      :P128_ID_MOVIMIENTO, :P128_MOTIVO, :APP_USER, v_id);
  END;
  ```
  (Los errores `-20991/-20992` de la procedure llegan al submit como notificación.)
- Proceso **Close Dialog** (Request = `SOLICITAR`).

---

### 10.2 — P129 "Reversos de Cobro" (lista IR)

**Shell que arma el PO en el Builder:**
1. **Create Page** → **Blank Page**. Name: `Reversos de Cobro`. Page Number: `129`. Page Mode: **Normal**.
2. **Create Region** tipo **Interactive Report**. Name `Reversos de Cobro`.
   - Source → Type **SQL Query**: `SELECT * FROM WKSP_WORKPLACE.V_SOLICITUDES_REVERSO`
3. Guardar.

**Lo que cablea Claude después:**
- Decodificar `ESTADO` (`P`=Pendiente / `A`=Aprobado / `R`=Rechazado) **en el SQL
  del IR** con `CASE` (no con LOV de columna — en IR ese patrón falla con
  PLS-00306, hallazgo de F14/P124). Badges por estado.
- **Link de fila** a P130 sobre `ESTADO='P'`: `P130_ID_SOLICITUD = #ID_SOLICITUD_RC#`,
  Clear Cache `130`. (Las resueltas no llevan link.)
- Reporte primario que **oculta** columnas internas (`ID_MOVIMIENTO`,
  `ID_CLIENTE`, `ID_MOVIMIENTO_EGRESO`) + filtros default (Pendientes).

---

### 10.3 — P130 "Aprobar/Rechazar Reverso" (modal)

**Shell que arma el PO en el Builder:**
1. **Create Page** → **Blank Page**. Name: `Aprobar/Rechazar Reverso`. Page Number: `130`. Page Mode: **Modal Dialog**.
2. **Create items**:
   - `P130_ID_SOLICITUD` → **Hidden** (parámetro: `ID_SOLICITUD_RC`).
   - `P130_MOTIVO_RECHAZO` → **Textarea**, Label `Motivo de rechazo`.
3. **Create Region** Static Content `Detalle de la solicitud` (Claude la rellena).
4. **Create Buttons**:
   - `APROBAR` → Submit Page, template success (verde).
   - `RECHAZAR` → Submit Page, template danger (rojo).
5. Guardar.

**Lo que cablea Claude después:**
- Items display-only del detalle (recibo, monto, cliente, cuota, motivo del
  pedido, solicitante) poblados en **BEFORE_HEADER** desde `V_SOLICITUDES_REVERSO`.
- `P130_MOTIVO_RECHAZO` visible solo cuando se va a rechazar (DA o condición);
  validación ≥10 chars **When Button Pressed = RECHAZAR**.
- Proceso **AFTER_SUBMIT** según request:
  - Request `APROBAR` → `WKSP_WORKPLACE.PRC_APROBAR_REVERSO_COBRO(:P130_ID_SOLICITUD, :APP_USER);`
  - Request `RECHAZAR` → `WKSP_WORKPLACE.PRC_RECHAZAR_REVERSO_COBRO(:P130_ID_SOLICITUD, :P130_MOTIVO_RECHAZO, :APP_USER);`
- Proceso **Close Dialog** (Request en `APROBAR,RECHAZAR`).
- Recordatorio de la regla de negocio: aprobar exige **caja abierta del día** del
  aprobador (`-20993/-20994` si no la tiene) — el mensaje llega al submit.

---

### 10.4 — Punto de entrada desde P99/P95 + menú

- **P99 (Detalle de Cuotas)** y/o **P95 (Cobros)**: agregar un **ícono/columna
  "Solicitar Reverso"** visible sobre cuotas `PAGADA`, que abra P128 pasando el
  `ID_MOVIMIENTO` del cobro asociado. El cobro se ubica con
  `MOVIMIENTOS_CAJA TIPO='COBRO_CXC'` por `ID_CUENTA_COBRAR_DET` (ese join ya está
  en P99 para mostrar recibo/fecha de pago). Lo cablea Claude; si requiere una
  columna nueva en el IG/IR, el PO la agrega en el shell.
- **Menú** (`navigation_menu`): el PO agrega en el Builder la entry
  `Reversos de Cobro` → P129 bajo el header **Cuentas a Cobrar**, con
  `security_pkg.can_access(:APP_ID,:APP_USER,129,NULL)`. Re-exportar manual
  (no `@@`).

---

### 10.5 — Captura al repo (cuando funcione en browser)

Re-exportar P128/P129/P130 (y P99 si se tocó) a `apex-work/` y agregar los
`delete_00128.sql + page_00128.sql` (y 129/130) a `install_page.sql`. El
`navigation_menu.sql` queda solo como referencia (no se importa por la
limitación de shared components).

### 10.6 — Fixes post-test en browser (2026-06-24/25) ✅

Hallazgos al probar P99/P128 en el navegador, con sus correcciones:

- **Ícono de reverso en P99 — checksum + render.** Primer intento con columna
  Link nativa + `link_text` `\&REVERSO_ICON.\` falló doble: (1) el `link_text`
  no procesa esa substitución (saca los `\` literales y escapa el HTML); (2) una
  URL `f?p=...` armada a mano dispara `APEX.SESSION_STATE.SSP_CHECKSUM_MISSING`
  porque P128 es página protegida (`protection_level='C'`). **Fix:** columna
  **HTML Expression** cuyo `<a>` se construye en el SQL con
  `APEX_PAGE.GET_URL(p_page=>128, p_clear_cache=>'128', p_items=>'P128_ID_MOVIMIENTO', p_values=>...)`
  (genera el checksum en runtime) y se renderiza con `&REVERSO!RAW.` (sin
  escapar). El ancla se arma **solo para cuotas `PAGADA`** (NULL en las demás).
  > Pitfall capturado: la directiva `{case ... end}` **no** se interpreta en una
  > HTML Expression de IG (se muestra como texto literal); el HTML literal sí
  > renderiza. Conviene construir el HTML condicional en el SQL, no con `{case}`.
- **Display de Fecha Pago / Nro Recibo tras reversar.** Los subqueries de P99 que
  derivan el recibo/fecha por cuota seguían mostrando el cobro reversado (el cobro
  no se borra: historia + recibo quemado). **Fix:** los 3 subqueries (Fecha Pago,
  Nro Recibo y el id del ícono de reverso) excluyen cobros con EGRESO de reversión:
  `AND NOT EXISTS (SELECT 1 FROM MOVIMIENTOS_CAJA r WHERE r.ID_MOVIMIENTO_REVERSADO = mc.ID_MOVIMIENTO)`.
  Verificado: una cuota reversada vuelve a `VENCIDA/PENDIENTE` **y** sin recibo;
  un re-pago muestra el recibo nuevo.

---

## 11. F15.1 — Reimpresión de recibos + watermark "REVERSADO"

**Estado:** EN CURSO (2026-06-25).

> Cierra dos huecos detectados al probar el reverso: (1) no había forma de
> **reimprimir** un recibo (P119 solo se abría desde P100 al cobrar — deuda
> diferida de `PLAN_FACTURACION.md §F9.F`); (2) un recibo reversado se reimprime
> igual que uno vigente, sin señal visual.

### 11.1 Backend — `db/F15_1_recibos_reimpresion.sql` (idempotente)

1. **Vista `V_RECIBOS_LISTA`** (fuente del IR de P131): sobre `V_RECIBOS_COBRO`
   + nombre de cliente + `FACTURA_NRO` + flag
   `REVERSADO` = `'S'` si existe un EGRESO con `ID_MOVIMIENTO_REVERSADO = ID_RECIBO`.
2. **`FN_KUDE_RECIBO_HTML` v2 (watermark):** si el recibo está reversado, inyecta
   un watermark CSS "REVERSADO" (rotado, absolute, con `@media print` +
   `print-color-adjust:exact` para que sobreviva al PDF) + footer de auditoría
   (motivo + usuario que aprobó + fecha), leídos de `SOLICITUDES_REVERSO_COBRO`.
   El `<style>` solo se carga en recibos reversados (HTML del recibo vigente
   intacto). Mismo patrón que el watermark "ANULADA" de la factura (F12).

### 11.2 APEX

| Página | Tipo | Rol |
|--------|------|-----|
| **P131** (nueva) | IR | "Recibos de Cobro". Source `V_RECIBOS_LISTA`. Columnas: nro recibo, fecha, cliente, cuota/CxC, factura origen, monto, **estado (Vigente/Reversado)** con badge. Ícono 🖨 por fila → P119 (`P119_ID_RECIBO`). Filtros por cliente/fecha. Entry de menú bajo "Cuentas a Cobrar" (PO en Builder, R8). |
| **P99** (mod) | IG | Ícono 🖨 "Imprimir recibo" en cuotas PAGADA → P119 con el `ID_MOVIMIENTO` del cobro vigente (mismo patrón HTML Expression + `APEX_PAGE.GET_URL` que el ícono de reverso). |

### 11.3 Hitos
- [x] **H1** ✅ (2026-06-25) — Backend `db/F15_1_recibos_reimpresion.sql` aplicado:
  vista `V_RECIBOS_LISTA` (con `CLIENTE_NOMBRE`, `FACTURA_NRO`, flag `REVERSADO`) +
  `FN_KUDE_RECIBO_HTML` v2 con watermark. Smoke OK: recibo reversado (21) trae
  watermark, recibo vigente (6) no.
- [x] **H2** ✅ (2026-06-25) — P99: columna 🖨 "Recibo" (HTML Expression +
  `APEX_PAGE.GET_URL` a P119) en cuotas PAGADA con cobro vigente. Importado +
  capturado. Mismo patrón que el ícono de reverso.
- [x] **H3** ✅ (2026-06-25) — P131 "Recibos de Cobro": shell del PO (IR sobre
  `V_RECIBOS_LISTA`) cableado por Claude — `REVERSADO` decodificado a
  Vigente/Reversado en el SQL, detail link 🖨 "Recibo" → P119
  (`P119_ID_RECIBO=#ID_RECIBO#`), reporte primario que oculta columnas internas
  (IDs). Importado + capturado + agregado a `install_page.sql`. Entry de menú
  agregado por el PO. Verificado: la vista lista 7 recibos, el 0010 marcado REVERSADO.
- [ ] **H4** — Test browser: reimprimir un recibo vigente (sin watermark) y uno
  reversado (con watermark + footer) desde P131.

### 11.4 Spec del shell de P131 (lo arma el PO en el Builder)

1. **Create Page → Blank Page**. Name: `Recibos de Cobro`. Page Number: `131`.
   Page Mode: **Normal**.
2. **Create Region** tipo **Interactive Report**. Name `Recibos`.
   - Source → SQL Query: `SELECT * FROM WKSP_WORKPLACE.V_RECIBOS_LISTA`
3. Guardar.

**Lo que cablea Claude después:** decode de `REVERSADO` (S/N → badge
Vigente/Reversado) en el SQL del IR, columna 🖨 (link a P119 con
`P119_ID_RECIBO = #ID_RECIBO#`), ocultar columnas internas (IDs), filtros default
por fecha. Entry de menú "Recibos de Cobro" → P131 bajo "Cuentas a Cobrar" lo
agrega el PO (R8).

---

## 12. F15.2 — Módulo OCULTO (interruptor reversible, 2026-06-29)

**Motivo.** Tras cerrar F14.2 (la NC reconcilia las cuotas pendientes de la CxC) y la
regla del PO **"nunca se devuelve dinero al cliente"**, el reverso de cobro —que
genera un `EGRESO` de caja, es decir **devuelve efectivo**— se oculta de la UI. **No
se borra nada**: backend (`PRC_*`, `FN_COBRO_REVERSABLE`, `V_SOLICITUDES_REVERSO`,
tablas, índice), páginas P128/P129/P130 y captura en `apex-work` quedan **intactos**.

> Importante: la NC **no** reemplaza al reverso para cuotas **ya cobradas** — ahí
> bloquea con `-20982`. Ocultar el reverso implica aceptar que, hoy, esa parte ya
> cobrada **no se acredita ni se devuelve** (queda con la empresa). El reemplazo
> correcto es el **saldo a favor del cliente** (proyecto aparte, aún sin construir).

**Mecanismo — interruptor maestro `PARAMETROS.REVERSO_COBRO_ACTIVO`** (`db/F15_2_ocultar_reverso.sql`,
idempotente; default `'N'`=oculto). Las guardas de UI lo leen con
`FN_GET_PARAMETRO('REVERSO_COBRO_ACTIVO','TEXTO')`:
- **P99 (ícono "Solicitar reverso", `fa-undo`):** el `case` que arma `REVERSO_HTML`
  ahora exige además `... = 'S'` → con `'N'` la columna queda NULL (sin ícono). El
  ícono 🖨 de reimpresión de recibo (P119) **no se tocó**. Capturado en
  `apex-work/.../page_00099.sql`.
- **Menú "Reversos de Cobro" → P129 (paso del PO, shared component):** condicionar la
  entrada en el Builder con `Condition = PL/SQL Expression`:
  `WKSP_WORKPLACE.FN_GET_PARAMETRO('REVERSO_COBRO_ACTIVO','TEXTO')='S'` (o desmarcarla).
  No se importa por `@@` (R8).
- **P128/P129/P130:** quedan inalcanzables vía UI al ocultar las dos entradas. No se
  les puso guarda de URL (decisión: ocultar, no bloqueo duro). Si se quiere bloqueo
  por URL directo, agregar un Before-Header que lea el parámetro.
- **P131 "Recibos de Cobro"** (reimpresión) y el badge "Reversado": **se mantienen**
  (son independientes del reverso; informan estado histórico).

**Reversible con un solo cambio:**
```sql
UPDATE WKSP_WORKPLACE.PARAMETROS SET VALOR_TEXTO='S' WHERE CLAVE='REVERSO_COBRO_ACTIVO';
COMMIT;
```
(+ re-mostrar la entrada de menú en el Builder). Verificado 2026-06-29: con `'S'` el
ícono reaparece en cuotas PAGADA; con `'N'` desaparece; el backend nunca se tocó.

**Textos cruzados suavizados (2026-06-29) ✅.** Los mensajes que sugerían "reversá el
cobro primero" se reescribieron para no apuntar al módulo oculto:
- **F14 `-20982`** (`PRC_APROBAR_NOTA_CREDITO`): "…supera el saldo pendiente (Y). Solo
  puede acreditarse hasta el saldo pendiente; la parte ya cobrada no se acredita."
- **F11 `-20934`** (`PRC_SOLICITAR_ANULACION`) y **`FN_MOTIVO_BLOQUEO_ANULACION`** (aviso
  P122): "…la factura tiene N cuota(s) ya cobrada(s)… Para ajustar el saldo pendiente,
  emití una Nota de Crédito." → redirige al camino real (NC) en vez del reverso.

Verificado en `ALL_SOURCE`: ningún procedure menciona ya "revers*/revierta los cobros".
(Cuando exista el módulo de **saldo a favor**, estos textos se volverán a revisar para
ofrecer esa vía sobre la parte ya cobrada.)

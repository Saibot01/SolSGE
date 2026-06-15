# Plan de implementación — Anulación de Facturas (F11)

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace:** `WKSP_WORKPLACE`
**Estado del plan:** aprobado 2026-06-08, implementación en curso.

> Plan separado de `PLAN_FACTURACION.md`. Aquel cubre F8 (Facturación
> contado) y F9 (Cobros), ambas cerradas. Este plan cierra la deuda
> explícita de F8 §9: la pantalla de anulación de comprobante.

## 1. Context

F8 (Facturación contado) y F9 (Cobros) están cerradas y el módulo Caja opera
end-to-end. La columna `COMPROBANTES.ESTADO` quedó como **Display Only** en
P67 con la pantalla de anulación deliberadamente diferida (decisión §3 #8 de
`PLAN_FACTURACION.md` y B19 retirado del alcance F8). Esta feature cierra esa
deuda: permite **revertir** una factura emitida (devolviendo stock, dejando
la OV nuevamente facturable y compensando el movimiento de caja) **bajo un
workflow de aprobación de 4 ojos**, sin tocar el nro de comprobante (que es
quemado por diseño fiscal).

Es un cambio transversal: toca BD (1 script nuevo), reversiones de stock vía
`MOVIMIENTOS_STOCK ENTRADA` y caja vía `MOVIMIENTOS_CAJA TIPO='EGRESO'`, 3
páginas nuevas APEX (lista + 2 modales), 2 modificaciones a páginas
existentes (P66 lista de facturas + P67 form factura) y una nota visual en
P96 (factura print). No requiere nuevo modelo de roles.

## 2. Decisiones tomadas (con el PO, 2026-06-08)

| # | Decisión |
|---|----------|
| 1 | **Workflow con aprobación.** Cajero `SOLICITA` → factura pasa a `ESTADO='P'` (pendiente). Supervisor `APRUEBA` (→ `ESTADO='N'`, anulada, se ejecutan reversiones) o `RECHAZA` (→ `ESTADO='A'`, vuelve a activa con motivo de rechazo registrado). |
| 2 | **Bloquear anulación si existe alguna cuota cobrada.** Si la factura es a crédito y `EXISTS (SELECT 1 FROM CUENTAS_COBRAR_DET WHERE ID_CXC=... AND ESTADO='PAGADA')` → no permitir `SOLICITAR`. El usuario debe revertir cobros primero (deuda futura: pantalla de "reverso de cobro"). |
| 3 | **OV vuelve a `APROBADO`** al aprobar la anulación. Queda disponible para re-facturar. **Reservas no se reactivan** (ya fueron `ANULADA`). |
| 4 | **Ventana temporal = mismo mes calendario.** Solo se puede solicitar si `TRUNC(c.FECHA,'MM') = TRUNC(SYSDATE,'MM')`. Coherente con cierres mensuales. |
| 5 | **Aprobador = cualquier usuario con acceso a P121** (auth estándar APEX, sin nuevo modelo de roles). Patrón coherente con P110/P112 (aprobación órdenes de compra). |
| 6 | **Contado: EGRESO de reversión** (contramovimiento). Se inserta `MOVIMIENTOS_CAJA TIPO='EGRESO'` por el monto contra la caja abierta del aprobador. El `INGRESO_VENTA` original queda intacto (auditoría limpia). |
| 7 | **Crédito (FORMA_PAGO=1):** al aprobar se marcan `CUENTAS_COBRAR.ESTADO='ANULADA'` y todas sus `CUENTAS_COBRAR_DET.ESTADO='ANULADA'`. No se borra historia. |
| 8 | **Nro de comprobante queda quemado.** `TALONARIOS.NRO_ACTUAL` no se decrementa. La factura anulada conserva su número con watermark en P96. |
| 9 | **Estados codificados en `CHAR(1)`** (la columna ya existe): `A`=Activo, `P`=Pendiente de anulación, `N`=Anulada. Se reutiliza el `'N'` que ya estaba precableado en el LOV de P67 (`Anular;N,Activo;A`). |

## 3. Estado actual relevado

### 3.1 BD

- `COMPROBANTES.ESTADO CHAR(1) DEFAULT 'A'`, sin CK actualmente.
- Auditoría de anulación inexistente: hay que **agregar** `MOTIVO_ANULACION`,
  `USUARIO_SOLICITA`, `FECHA_SOLICITUD`, `USUARIO_APRUEBA`, `FECHA_RESOLUCION`,
  `MOTIVO_RECHAZO` (todas `NULL` para filas históricas).
- Triggers de INSERT existentes (`TRG_FACTURA_ORDEN`, `TRG_INS_CUENTAS_COBRAR`,
  `TRG_MOV_STOCK_DETALLE`, `TRG_OV_LIBERA_RESERVA`) **no manejan UPDATE de
  `COMPROBANTES.ESTADO`** — todo el efecto inverso lo va a tener que hacer
  la procedure `PRC_APROBAR_ANULACION`.
- `TRG_ACTUALIZAR_STOCK_MOVIMIENTO` ya soporta `TIPO='ENTRADA'` y suma stock
  (existente, se reutiliza).
- `MOVIMIENTOS_CAJA.CK_MOVCAJA_TIPO` ya incluye `'EGRESO'` (definido en
  `db/F8_facturacion.sql`).

### 3.2 APEX

- IDs libres altos: **P108, P109, P111, P113–P118, P120+**.
- Páginas usadas más altas: P107, P110, P112, P119.
- **Patrón a seguir (referencia P110/P112 — Aprobación de Órdenes de Compra)**:
  IR de pendientes + form modal con items `MOTIVO_RECHAZO`, `FECHA_APROBACION`,
  `ID_APROBADOR`, validación `PRC_VAL_MOTIVO_RECHAZO`. Replicar para facturas.
- `P67_ESTADO` ya tiene LOV `Anular;N,Activo;A` precableado (legacy) — se
  cambia a Display Only de los 3 estados.

## 4. Diseño

### 4.1 Backend BD — `db/F11_anulacion_facturas.sql`

Script idempotente. Pasos:

**Paso 1 — Schema changes a `COMPROBANTES`**

```sql
ALTER TABLE COMPROBANTES ADD (
  MOTIVO_ANULACION  VARCHAR2(500),
  USUARIO_SOLICITA  VARCHAR2(60),
  FECHA_SOLICITUD   DATE,
  USUARIO_APRUEBA   VARCHAR2(60),
  FECHA_RESOLUCION  DATE,
  MOTIVO_RECHAZO    VARCHAR2(500)
);

ALTER TABLE COMPROBANTES ADD CONSTRAINT CK_COMPROBANTES_ESTADO
  CHECK (ESTADO IN ('A','P','N'));

-- Coherencia: si está pendiente o anulada deben tener auditoría
ALTER TABLE COMPROBANTES ADD CONSTRAINT CK_COMPROBANTES_AUDIT
  CHECK (
    (ESTADO='A' AND USUARIO_APRUEBA IS NULL AND MOTIVO_ANULACION IS NULL)
    OR (ESTADO='P' AND USUARIO_SOLICITA IS NOT NULL AND MOTIVO_ANULACION IS NOT NULL)
    OR (ESTADO='N' AND USUARIO_APRUEBA IS NOT NULL AND FECHA_RESOLUCION IS NOT NULL)
  );
```

**Paso 2 — Procedure `PRC_SOLICITAR_ANULACION`**

Valida pre-condiciones y mueve `ESTADO='A' → 'P'`.

- Comprobante existe y `ESTADO='A'`.
- `TRUNC(c.FECHA,'MM') = TRUNC(SYSDATE,'MM')` (ventana mes).
- Si `FORMA_PAGO='1'` (crédito) → no debe haber `CUENTAS_COBRAR_DET.ESTADO='PAGADA'` asociadas.
- Motivo obligatorio (≥10 chars).
- `UPDATE COMPROBANTES SET ESTADO='P', MOTIVO_ANULACION=p_motivo, USUARIO_SOLICITA=p_usuario, FECHA_SOLICITUD=SYSDATE`.

**Paso 3 — Procedure `PRC_APROBAR_ANULACION`**

Reversión atómica `ESTADO='P' → 'N'`. En orden:

1. Lock de la fila `COMPROBANTES` (`FOR UPDATE`). Re-verificar pre-condiciones (ventana, sin cuotas pagadas).
2. **Stock**: por cada `DETALLE_COMPROBANTE`, INSERT `MOVIMIENTOS_STOCK` con `TIPO='ENTRADA'`, `CANTIDAD = SALIDA original`, `OBSERVACION='Reversión por anulación factura #NRO_COMPROBANTE'`. El trigger `TRG_ACTUALIZAR_STOCK_MOVIMIENTO` repone `STOCK_PRODUCTO`.
3. **Caja (si CONTADO)**: el aprobador debe tener caja abierta. INSERT `MOVIMIENTOS_CAJA` con `TIPO='EGRESO'`, `ID_CAJA = FN_CAJA_ABIERTA_USUARIO(p_usuario_aprueba)`, `ID_COMPROBANTE = p_id_comprobante`, totales, `USUARIO=p_usuario_aprueba`, `OBSERVACION='Anulación factura …'`. + `DETALLE_MOVIMIENTO_CAJA` espejo del original.
4. **CxC (si CRÉDITO)**: `UPDATE CUENTAS_COBRAR SET ESTADO='ANULADA' WHERE ID_COMPROBANTE = p_id_comprobante` + `UPDATE CUENTAS_COBRAR_DET SET ESTADO='ANULADA' WHERE ID_CXC = ...`. Agregar `'ANULADA'` a los CKs (`CK_CXC_ESTADO`, `CK_CCD_ESTADO`).
5. **Orden de Venta**: si `c.ID_ORDEN_VENTA IS NOT NULL` → `UPDATE ORDENES_VENTA SET ESTADO='APROBADO' WHERE ID_ORDEN = c.ID_ORDEN_VENTA`. **Requiere relajar** `FN_PUEDE_TRANSICION_OV` para permitir `FACTURADO → APROBADO` solo cuando exista una factura asociada en `ESTADO='N'`.
6. **Cabecera**: `UPDATE COMPROBANTES SET ESTADO='N', USUARIO_APRUEBA=p_usuario, FECHA_RESOLUCION=SYSDATE`.
7. `COMMIT`. Si cualquier paso falla → `ROLLBACK` y reraise.

**Paso 4 — Procedure `PRC_RECHAZAR_ANULACION`**

- Valida `ESTADO='P'` y `p_motivo_rechazo` no nulo.
- `UPDATE COMPROBANTES SET ESTADO='A', USUARIO_APRUEBA=p_usuario, FECHA_RESOLUCION=SYSDATE, MOTIVO_RECHAZO=p_motivo`.
- No revierte nada (la factura nunca dejó de estar activa).

**Paso 5 — Actualizar `FN_PUEDE_TRANSICION_OV`**

Agregar caso `OLD='FACTURADO' AND NEW='APROBADO'` → permitido (la guarda real está en `PRC_APROBAR_ANULACION` que solo emite ese UPDATE cuando hay factura `'N'`).

**Paso 6 — Vista `V_ANULACIONES_FACTURAS`** (fuente del IR en P120)

```sql
CREATE OR REPLACE VIEW V_ANULACIONES_FACTURAS AS
SELECT c.ID_COMPROBANTE,
       c.NRO_COMPROBANTE,
       c.FECHA,
       c.TOTAL_MONEDA_LOCAL,
       c.MONEDA,
       c.ESTADO,
       c.MOTIVO_ANULACION,
       c.USUARIO_SOLICITA,
       c.FECHA_SOLICITUD,
       c.USUARIO_APRUEBA,
       c.FECHA_RESOLUCION,
       c.MOTIVO_RECHAZO,
       p.NOMBRE          AS CLIENTE_NOMBRE,
       c.FORMA_PAGO,
       o.DESCRIPCION     AS OFICINA
  FROM COMPROBANTES c
  LEFT JOIN PERSONAS p ON p.ID_PERSONA = c.ID_CLIENTE
  LEFT JOIN OFICINAS o ON o.ID_OFICINA = c.ID_OFICINA
 WHERE c.ESTADO IN ('P','N');
```

**Paso 7 — Verificación final** (counts de objetos creados, idempotencia).

### 4.2 APEX — Páginas nuevas

| Página | Tipo | Rol |
|--------|------|-----|
| **P120** | IR normal | Lista de anulaciones. Source = `V_ANULACIONES_FACTURAS`. Filtros por `ESTADO` (Pendientes / Anuladas / Histórico mes). Link "Aprobar/Rechazar" sobre filas `ESTADO='P'` → P121. Link "Ver factura" → P96. Badge en ESTADO (`P` ámbar, `N` rojo). |
| **P121** | Modal Dialog | Detalle de la solicitud + APROBAR/RECHAZAR. Form sobre `COMPROBANTES`. Items display only: factura, cliente, fecha, total, motivo, solicitante. Items editables: `P121_MOTIVO_RECHAZO` (visible solo si pulsa RECHAZAR). Botones: **APROBAR** (request `APROBAR`) + **RECHAZAR** (request `RECHAZAR`) + Cancelar. Validación: `ESTADO='P'`; si rechaza, `MOTIVO_RECHAZO` no nulo (≥10 chars). Procesos AFTER_SUBMIT que invocan `PRC_APROBAR_ANULACION` / `PRC_RECHAZAR_ANULACION` según request. |
| **P122** | Modal Dialog | Solicitar anulación. Form sobre `COMPROBANTES`. Items display only: factura, fecha, total. Item editable obligatorio: `P122_MOTIVO_ANULACION` (TEXTAREA, validación ≥10 chars). Botón **SOLICITAR ANULACIÓN**. Pre-validación BEFORE_HEADER: pre-checks (ventana, sin cuotas cobradas) y mostrar inline si bloquea. AFTER_SUBMIT invoca `PRC_SOLICITAR_ANULACION`. |

### 4.3 APEX — Páginas modificadas

| Página | Cambio |
|--------|--------|
| **P66** (lista facturas) | Agregar columna icono "Solicitar Anulación" visible cuando `ESTADO='A'` y ventana mes válida → abre P122 con `P122_ID_COMPROBANTE`. Mostrar badge en `ESTADO` (A/P/N). |
| **P67** (form factura) | `P67_ESTADO`: Select List → **Display Only** mostrando A/P/N. Agregar botón **"Solicitar Anulación"** visible solo si `ESTADO='A'` y `TRUNC(FECHA,'MM')=TRUNC(SYSDATE,'MM')` → redirige a P122. Mostrar región read-only "Información de Anulación" con motivo + auditoría cuando `ESTADO IN ('P','N')`. |
| **P96** (factura print) | Renderizar watermark `<div class="t-watermark">ANULADA</div>` (CSS rotated absolute) cuando `ESTADO='N'`. Footer adicional con motivo + usuario aprueba + fecha resolución. |
| **Menú** (`navigation_menu`) | Agregar entry "Anulaciones de Facturas" bajo header "Ventas" como hermano de "Proceso Ventas" → P120. Con condición `security_pkg.can_access(:APP_ID,:APP_USER,120,NULL)` igual que el resto. |

## 5. Hitos y flujo de implementación

Marcamos `[ ]` pendiente, `[x]` cerrado.

### Hito 1 — Backend BD `db/F11_anulacion_facturas.sql` ✅ (2026-06-08)
- [x] Schema changes COMPROBANTES (6 columnas auditoría + 2 CKs).
- [x] `CK_CXC_ESTADO` y `CK_CCD_ESTADO` extendidos con `'ANULADA'`.
- [x] Procedure `PRC_SOLICITAR_ANULACION`.
- [x] Procedure `PRC_APROBAR_ANULACION` (con guarda `TRG_OV_VALIDA_REVERSO_FACT`).
- [x] Procedure `PRC_RECHAZAR_ANULACION`.
- [x] `FN_PUEDE_TRANSICION_OV` extendido para `FACTURADO → APROBADO`.
- [x] Vista `V_ANULACIONES_FACTURAS`.
- [x] Script idempotente (corre 2 veces sin error) + verificación final pasa OK.

### Hito 2 — P122 Modal Solicitar Anulación ✅ (2026-06-09, hecha en Builder)
- [x] Página modal con form sobre `COMPROBANTES` (hidden ID + textarea motivo + Display Only de datos factura).
- [x] Proceso AFTER_SUBMIT `PRC_SOLICITAR_ANULACION` + Close Dialog.
- [ ] ~~Validaciones BEFORE_HEADER~~ — deuda (la BD valida igual desde la procedure, errores `-20932/-20933/-20934` llegan al submit). Ver §10.
- [x] Capturado en `apex-work/.../page_00122.sql` + entry en `install_page.sql`.

### Hito 3 — P120 Lista de Anulaciones ✅ (2026-06-10, hecha en Builder)
- [x] Página IR sobre `V_ANULACIONES_FACTURAS`.
- [x] Link a P121 para resolver pendientes.
- [x] Capturado al repo.
- [ ] ~~Badges + filtros default + link a P96~~ — deuda cosmética (§10).

### Hito 4 — P121 Modal Aprobación ✅ (2026-06-10, hecha en Builder)
- [x] Modal Dialog con datos de la solicitud + textarea motivo de rechazo.
- [x] Botones APROBAR / RECHAZAR.
- [x] Procesos invocan `PRC_APROBAR_ANULACION` / `PRC_RECHAZAR_ANULACION`.
- [x] Capturado al repo.

### Hito 5 — Ajustes a P66 + P67
- [x] P66: ícono "Solicitar Anulación" → P122 (con link target `\&ID_COMPROBANTE.\` corregido el 2026-06-09).
- [ ] ~~P66 badge en ESTADO~~ — deuda (§10).
- [ ] ~~P67: ESTADO Display Only + botón "Solicitar Anulación" + región info auditoría~~ — deuda (§10). La anulación se solicita desde P66, P67 sigue mostrando ESTADO como Select List legacy.
- [x] Re-export P66 a `apex-work/.../page_00066.sql` (la nueva versión sobreescribe la previa).

### Hito 6 — P96 Watermark "ANULADA" ✅ (2026-06-14)
- [x] Watermark + footer de auditoría inyectados desde `FN_KUDE_FACTURA_HTML`
  cuando `COMPROBANTES.ESTADO='N'`. Solo se carga el `<style>` en facturas
  anuladas (HTML activo intacto, ~700 bytes menos). Incluye `@media print`
  con `print-color-adjust:exact` para que el watermark sobreviva al PDF.
  Footer: motivo + usuario aprueba + fecha resolución. Verificado en browser
  con factura 86 (anulada) y 85 (activa). Sin tocar la página APEX.

### Hito 7 — Menú entry "Anulaciones de Facturas"
- [ ] **Deuda** — no implementado. Ver §10. Acceso a P120 hoy solo vía URL directa (`f?p=100:120`) o link desde P66.

### Hito 8 — Test plan end-to-end ✅ parcial (2026-06-10)
- [x] Caso A — anulación contado feliz: factura `001-001-0000027` (ID 86) solicitada y aprobada por TCASCO. Verificado: `COMPROBANTES.ESTADO='N'`, `USUARIO_APRUEBA=TCASCO`, `FECHA_RESOLUCION=2026-06-10`. Reversiones aplicadas por `PRC_APROBAR_ANULACION` (stock, OV, EGRESO de caja).
- [ ] ~~Caso B (crédito sin cobros) / Caso C (crédito con cobro) / Caso D (fuera de mes) / Caso E (rechazo)~~ — no probados manualmente; la BD los valida igual con `-20934/-20933/-20952`.

### Hito 9 — Cierre F11 ✅ parcial (2026-06-10)
- [x] Commit `feat(F11): pantallas APEX P120/P121/P122 + P66 link` + re-export.
- [ ] ~~Tag `f11-anulacion-facturas`~~ — opcional; el módulo no está "cerrado" porque resta la deuda visual (§10). Crear al cierre real.
- [ ] ~~Actualizar `PLAN_FACTURACION.md` §9~~ — pendiente al cierre real.

## 5.1 P123 bonus

P123 "Movimientos Caja" (creada por el PO el 2026-06-08, fuera del plan original) fue capturada al repo junto con las páginas F11 — vista de movimientos de caja útil para verificar los EGRESO de anulación. Documentada acá para no perderla.

## 6. Riesgos

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | Reverso de stock vía `MOVIMIENTOS_STOCK ENTRADA` mete una fila por línea pero no la "ata" a la salida original — auditoría de pares queda implícita. | `OBSERVACION` con texto `'Reversión factura #NRO_COMPROBANTE'`. Suficiente para trazabilidad manual. Una tabla puente formal es over-engineering para esta escala. |
| R2 | El EGRESO de reversión va a la caja abierta del **aprobador**, no a la caja original. Si aprobador y cajero original son distintos, el dinero "vuelve" a la caja equivocada. | Aceptable y documentado: el motivo es que la caja original pudo cerrarse. Si el PO quiere reabrirla, es decisión manual. La auditoría queda con `USUARIO_APRUEBA` + observación. |
| R3 | `FN_PUEDE_TRANSICION_OV` ahora permite `FACTURADO → APROBADO` siempre — alguien podría usarlo fuera de `PRC_APROBAR_ANULACION` y mover la OV sin anular la factura. | Guarda en `TRG_FACTURA_ORDEN` (BEFORE UPDATE): si la transición es `FACTURADO → APROBADO`, debe existir un comprobante asociado en `ESTADO='N'`. Implementar en Paso 5 de F11. |
| R4 | El `INGRESO_VENTA` original queda intacto pero el `EGRESO` lo compensa al cerrar caja → el reporte de caja del día queda "inflado en ambos sentidos". | Es el comportamiento contable correcto: bruto + reverso. Si el PO quiere reporte neto, agregar columna calculada en P62 (deuda menor). |
| R5 | Una factura puede solicitar anulación, ser rechazada y luego volver a solicitarse (`A → P → A → P → …`). Histórico no se preserva. | Aceptable para F11. Si más adelante se quiere auditoría completa de intentos, crear tabla `COMPROBANTES_ANULACION_LOG`. |
| R6 | `MOVIMIENTOS_CAJA TIPO='EGRESO'` requiere que el aprobador tenga caja abierta del día. Si no la tiene → no se puede aprobar contado. | Validación en P121 con mensaje claro: "Para aprobar anulaciones contado necesitas tener caja abierta. Abrí caja primero (P65)". |
| R7 | El watermark "ANULADA" en P96 puede mostrarse sobre facturas históricas si quedaron con `ESTADO='A'` pero estaban en otro flujo. | No aplica — hoy todas las históricas son `'A'`. Solo facturas que pasen por F11 cambian de estado. |
| R8 | Re-importar el `navigation_menu.sql` con `@@` puede fallar (memoria APEX: shared components no-upsert). | Editar el menú desde APEX Builder y re-exportar manualmente. No agregar al `install_component.sql`. |

## 7. Test plan end-to-end

### Caso A — Anulación contado feliz
1. Login `TCASCO`, caja 1 abierta. Emitir factura contado de OV pendiente (golden path F8). Esperado: factura #001-001-NNNN, `ESTADO='A'`.
2. P66 → ícono "Solicitar Anulación" → P122 modal. Llenar motivo "Cliente devolvió mercadería". Submit.
3. Verificar BD: `ESTADO='P'`, `USUARIO_SOLICITA='TCASCO'`, `FECHA_SOLICITUD=SYSDATE`.
4. Logout. Login `CBARRIOS`, abrir caja. P120 → ver pendiente. Click → P121 modal. APROBAR.
5. Esperado:
   - `COMPROBANTES.ESTADO='N'`, `USUARIO_APRUEBA='CBARRIOS'`, `FECHA_RESOLUCION=hoy`.
   - `STOCK_PRODUCTO.CANTIDAD` recuperado.
   - `MOVIMIENTOS_STOCK` con N filas `ENTRADA`.
   - `ORDENES_VENTA.ESTADO='APROBADO'`.
   - `MOVIMIENTOS_CAJA` nueva fila `TIPO='EGRESO'`, `ID_COMPROBANTE` apuntando a la anulada, `ID_CAJA = caja abierta CBARRIOS`.
6. P96 sobre la factura → watermark "ANULADA" visible + footer auditoría.
7. P67 sobre la OV: facturable de nuevo (re-emitir factura nueva, ok).

### Caso B — Crédito sin cuotas cobradas
1. Emitir factura crédito (`TRG_INS_CUENTAS_COBRAR` crea CXC+cuotas).
2. Solicitar + aprobar anulación.
3. Esperado: `CUENTAS_COBRAR.ESTADO='ANULADA'`, todas las `CUENTAS_COBRAR_DET.ESTADO='ANULADA'`, **sin** `MOVIMIENTOS_CAJA` nuevo (porque no había ingreso de caja).

### Caso C — Crédito con cuota cobrada (bloqueo)
1. Emitir factura crédito, cobrar 1 cuota (F9).
2. P66 → "Solicitar Anulación" → P122. Submit.
3. Esperado: error inline "No se puede anular: hay 1 cuota cobrada. Reversar cobro primero."

### Caso D — Fuera de mes (bloqueo)
1. Factura emitida el 2026-05-XX (mes anterior).
2. P66 → ícono "Solicitar Anulación" debería NO aparecer; si se manipula URL → P122 BEFORE_HEADER bloquea.

### Caso E — Rechazo
1. Repetir Caso A pasos 1–4 pero RECHAZAR con motivo "Devolución no procede".
2. Esperado: `ESTADO='A'`, `MOTIVO_RECHAZO='Devolución no procede'`, `USUARIO_APRUEBA=CBARRIOS`. Sin reversiones aplicadas. Stock y caja sin cambios.

### Edge cases
- Race: dos supervisores aprueban a la vez → `FOR UPDATE` en `PRC_APROBAR_ANULACION` serializa.
- Re-imprimir factura anulada desde P66 → P96 con watermark.

## 8. Aprobación

> Plan aprobado por el PO el 2026-06-08. Implementación pausada el 2026-06-10
> con el flujo end-to-end funcionando para venta contado. Deuda técnica
> consolidada en §10 para retomar más adelante.

## 9. Estado real al 2026-06-10

**Funciona end-to-end**:
- Cajero hace click en ícono de P66 → P122 modal solicita motivo → factura
  pasa a `ESTADO='P'`.
- Supervisor entra a P120 (lista) → P121 (detalle) → APROBAR → factura pasa
  a `'N'`, stock vuelve, OV vuelve a `APROBADO`, EGRESO en caja.
- Test caso A pasado con factura `001-001-0000027` el 2026-06-10.

**Lo aprobado por PO con autoaprobación**: el aprobador puede ser el mismo
usuario que solicitó (no se está enforzando "4 ojos" — el PO lo prefirió
así para no bloquearse en el MVP).

**Lo que NO está**:
- UI no avisa "fuera de mes" / "hay cuotas cobradas" antes del submit —
  el error llega como mensaje técnico de Oracle desde la procedure BD.
  La factura igual no se anula (la BD bloquea), solo es UX rugosa.
- ~~P96 no marca visualmente las facturas anuladas.~~ **Resuelto 2026-06-14**
  vía `FN_KUDE_FACTURA_HTML` (D5 cerrada).
- P67 no muestra el estado correctamente cuando una factura está anulada.
- Sin entry de menú: hay que entrar a P120 escribiendo `f?p=100:120` en
  la URL.

## 10. Deuda técnica F11 (para retomar)

| # | Descripción | Página | Severidad |
|---|-------------|--------|-----------|
| D1 | Validaciones BEFORE_HEADER en P122 que avisen pre-submit: factura fuera de mes / con cuotas cobradas / no en estado `'A'`. Hoy el error llega como ORA-20933 etc. al apretar SOLICITAR. | P122 | Media (UX) |
| D2 | Badge de ESTADO en columnas de P66 (Activa verde / Pendiente ámbar / Anulada rojo) y P120. Mejor lectura visual. | P66 + P120 | Baja |
| D3 | Filtros default + saved report "Pendientes del mes" en P120. Link a P96 desde columna print. | P120 | Baja |
| D4 | P67 ESTADO como Display Only de los 3 estados (`A`/`P`/`N`) en vez del legacy `Anular;N,Activo;A`. Botón "Solicitar Anulación" en P67 y región read-only "Información de Anulación". | P67 | Media |
| ~~D5~~ | ~~P96 watermark "ANULADA" + footer con motivo + usuario aprueba + fecha.~~ **Cerrada 2026-06-14** — implementada server-side en `WKSP_WORKPLACE.FN_KUDE_FACTURA_HTML` (`db/F12_kude_factura.sql`); P96 sin cambios. | ~~P96~~ | ~~Alta~~ |
| D6 | Entry de menú "Anulaciones de Facturas" → P120 bajo "Ventas" con `security_pkg.can_access`. | Menú | Media |
| D7 | Aprobación de "4 ojos": validar en `PRC_APROBAR_ANULACION` que `p_usuario_aprueba <> USUARIO_SOLICITA`. Hoy el mismo usuario que solicita puede aprobar (decisión MVP del PO). | BD | Baja (decisión consciente) |
| D8 | Probar casos B/C/D/E del test plan §7 manualmente en browser. La BD los valida pero no se probaron end-to-end por UI. | Manual | Baja |

Cuando se retome F11 → priorizar **D4** (P67 ESTADO + botón anular) y **D6**
(menú) por UX, después D1/D2/D3 (cosmético).

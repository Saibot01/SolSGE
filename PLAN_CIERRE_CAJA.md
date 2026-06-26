# Plan de implementación — F17: Estado y Cierre de Caja

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE`
**Estado del plan:** pendiente de aprobación (2026-06-26).

> Cierra el **módulo de Caja** abierto en `PLAN_FACTURACION.md` (F8). Aquel
> implementó apertura/cierre/movimientos a nivel backend; éste corrige un bug
> de dinero en el cierre y agrega las pantallas que faltaban: **estado de caja
> en vivo**, **movimientos en vivo** y **documento de arqueo/cierre con
> desglose**. Dependencias hacia F8/F9/F15 se marcan como [F#].

---

## 1. Objetivo

Dejar el módulo de Caja **cerrado y confiable**:

1. **Corregir el cierre** — hoy subvalúa el efectivo real (ver §2.2).
2. **Pantalla Estado de Caja** — saldo esperado en vivo por moneda.
3. **Movimientos en vivo** — listado de `MOVIMIENTOS_CAJA` de la caja, auto-refresh.
4. **Documento de Arqueo/Cierre** — con conteo declarado, diferencia y desglose,
   vía función HTML + página de impresión (estilo P96/P119, **sin** ser KuDE).

---

## 2. Estado actual relevado (verificado contra la BD en vivo, 2026-06-26)

### 2.1 Lo que ya existe (F8)

| Objeto | Rol |
|--------|-----|
| `MOVIMIENTOS_CAJA` | Movimientos `TIPO IN ('INGRESO_VENTA','COBRO_CXC','EGRESO','AJUSTE')` |
| `DETALLE_MOVIMIENTO_CAJA` | Desglose por forma de pago (`ID_FORMA_PAGO`, `MONTO_LOCAL/ORIGEN`, `ID_METODO_PAGO`) |
| `CAJAS` | Sesión (`ESTADO 'A'/'C'`, `FEC_APERTURA/CIERRE`, `USU_APERTURA/CIERRE`) |
| `CAJA_MONEDAS` | Saldo por moneda: solo `MONTO_APERTURA`, `MONTO_CIERRE` |
| `CERRAR_CAJA(p_id_caja, p_usuario)` | Cierra la sesión y calcula `MONTO_CIERRE` por moneda |
| `FN_CAJA_ABIERTA_USUARIO(:APP_USER)` | Caja abierta del usuario (NULL si ninguna) |

Pantallas: **P61** Cierre (modal), **P62** "Caja" (IR, hoy **vacía**), **P63/P64**
Config, **P65** Apertura. **No existe** pantalla de estado/movimientos en vivo ni
documento de cierre.

`MONEDAS`: `'1'`→`PYG`, `'2'`→`USD`. Multi-moneda casi sin uso (todo PYG en datos reales).

### 2.2 BUG CRÍTICO — el cierre subvalúa el efectivo (confirmado con datos)

**Causa raíz:** `CERRAR_CAJA` une `MOVIMIENTOS_CAJA.MONEDA = CAJA_MONEDAS.MONEDA`
con igualdad estricta. Pero — inconsistencia ya documentada en CLAUDE.md (F13) —
`MOVIMIENTOS_CAJA` guarda la moneda como **texto** (`'PYG'`) en los `COBRO_CXC` y
en los `EGRESO` de reverso (F15), mientras `CAJA_MONEDAS` guarda el **código**
(`'1'`). Esos movimientos **no matchean** y quedan fuera del cierre. Las funciones
KuDE recibieron el fix `(CODIGO_MONEDA = x OR DESCRIPCION = x)`; `CERRAR_CAJA` no.

Evidencia (cierre guardado vs. correcto, en guaraníes):

| Caja | Apertura | Cierre guardado | Cierre real | Faltante |
|------|----------|-----------------|-------------|----------|
| 65 | 100.000 | 162.400 | 946.425 | **−784.025** |
| 66 | 100.000 | 2.429.200 | 2.478.340 | **−49.140** |
| 67 | 100.000 | **100.000** | 1.815.470 | **−1.715.470** |

- Las cajas con solo ventas contado (`INGRESO_VENTA`, que sí guarda `'1'`) cerraron
  bien → por eso pasó desapercibido. Las que cobraron cuotas (`COBRO_CXC`) están
  subvaluadas.
- **Caja 121 (abierta hoy, TCASCO):** tiene un EGRESO de reverso de 784.025 con
  `MONEDA='PYG'`. Con el proc actual cerraría en **1.000.000** en vez de **215.975**.

Secundario: `INGRESO_VENTA` guarda `TOTAL_MONEDA_ORIGEN = NULL`; la v2 ya lo cubre
con `NVL(TOTAL_MONEDA_ORIGEN, TOTAL_MONEDA_LOCAL)`.

---

## 3. Decisiones tomadas

| # | Decisión |
|---|----------|
| 1 | **Normalizar moneda en `CERRAR_CAJA`** con el criterio de las funciones KuDE: tratar `'PYG'`/`'1'` (y `'USD'`/`'2'`) como la misma moneda, resolviendo contra `MONEDAS`. |
| 2 | **Recalcular las cajas ya cerradas** con la lógica corregida (script idempotente) **dejando registro de auditoría** del valor anterior. |
| 3 | **Documento = Arqueo de Caja** (control interno, **NO** Documento Electrónico SIFEN → sin CDC/QR/leyenda KuDE). Reusa la identidad visual de P96/P119 solo por coherencia. Título: "Arqueo y Cierre de Caja". |
| 4 | **Conteo declarado**: el cajero ingresa el efectivo contado por moneda al cerrar; el sistema calcula `esperado − declarado = diferencia` (sobrante/faltante). |
| 5 | **Entrega**: función `FN_CIERRE_CAJA_HTML(p_id_caja)` + página de impresión (mismo patrón que P96/P119). |
| 6 | El **saldo esperado en vivo** (pantalla de estado) usa la misma vista normalizada que el cierre — una sola fuente de verdad. |

---

## 4. Pasos de implementación (DB)

Archivo: `db/F17_cierre_caja.sql` (idempotente, con bloque de verificación al final,
según `db/README.md`). Orden sugerido:

**Paso 1 — Columnas de arqueo en `CAJA_MONEDAS`**
```sql
-- MONTO_CIERRE = esperado por el sistema (ya existe)
ALTER TABLE CAJA_MONEDAS ADD (MONTO_DECLARADO NUMBER);   -- contado por el cajero
ALTER TABLE CAJA_MONEDAS ADD (MONTO_DIFERENCIA NUMBER);  -- declarado - esperado
-- (add-column idempotente con helper add_col_if_missing, ver F8)
```

**Paso 2 — Vista de saldo normalizado (fuente única estado + cierre)**
```sql
CREATE OR REPLACE VIEW V_CAJA_SALDO AS
WITH mov AS (
  SELECT mc.ID_CAJA,
         m.CODIGO_MONEDA AS MONEDA,        -- normalizada al código
         mc.TIPO,
         NVL(mc.TOTAL_MONEDA_ORIGEN, mc.TOTAL_MONEDA_LOCAL) AS MONTO
    FROM MOVIMIENTOS_CAJA mc
    JOIN MONEDAS m
      ON (m.CODIGO_MONEDA = mc.MONEDA OR m.DESCRIPCION = mc.MONEDA)
)
SELECT cm.ID_CAJA, cm.MONEDA, cm.MONTO_APERTURA,
       NVL(SUM(CASE WHEN mv.TIPO IN ('INGRESO_VENTA','COBRO_CXC') THEN mv.MONTO END),0) AS INGRESOS,
       NVL(SUM(CASE WHEN mv.TIPO = 'EGRESO' THEN mv.MONTO END),0)                       AS EGRESOS,
       cm.MONTO_APERTURA
         + NVL(SUM(CASE WHEN mv.TIPO IN ('INGRESO_VENTA','COBRO_CXC') THEN mv.MONTO
                        WHEN mv.TIPO = 'EGRESO' THEN -mv.MONTO END),0)                  AS SALDO_ESPERADO,
       cm.MONTO_CIERRE, cm.MONTO_DECLARADO, cm.MONTO_DIFERENCIA
  FROM CAJA_MONEDAS cm
  LEFT JOIN mov mv ON mv.ID_CAJA = cm.ID_CAJA AND mv.MONEDA = cm.MONEDA
 GROUP BY cm.ID_CAJA, cm.MONEDA, cm.MONTO_APERTURA, cm.MONTO_CIERRE,
          cm.MONTO_DECLARADO, cm.MONTO_DIFERENCIA;
```

**Paso 3 — `CERRAR_CAJA` v3 (join normalizado + conteo declarado)**
- Firma nueva: `CERRAR_CAJA(p_id_caja, p_usuario, p_declarado SYS.ODCINUMBERLIST DEFAULT NULL)`
  o sobrecarga que reciba el declarado por moneda (definir interfaz con P61).
- `MONTO_CIERRE` se computa desde `V_CAJA_SALDO.SALDO_ESPERADO` (join ya correcto).
- Si se pasa declarado: setear `MONTO_DECLARADO` y `MONTO_DIFERENCIA = declarado − esperado`.
- Mantiene `UPDATE MOVIMIENTOS_CAJA SET ESTADO='C'` y el `RAISE -20030` si no hay caja abierta.

**Paso 4 — Recalcular cajas históricas (decisión #2)**
```sql
-- Auditoría: guardar el valor previo antes de pisar
ALTER TABLE CAJA_MONEDAS ADD (MONTO_CIERRE_PREV NUMBER);  -- idempotente
UPDATE CAJA_MONEDAS cm
   SET MONTO_CIERRE_PREV = NVL(MONTO_CIERRE_PREV, MONTO_CIERRE),
       MONTO_CIERRE = (SELECT v.SALDO_ESPERADO FROM V_CAJA_SALDO v
                        WHERE v.ID_CAJA=cm.ID_CAJA AND v.MONEDA=cm.MONEDA)
 WHERE cm.ID_CAJA IN (SELECT ID_CAJA FROM CAJAS WHERE ESTADO='C')
   AND MONTO_CIERRE <> (SELECT v.SALDO_ESPERADO FROM V_CAJA_SALDO v
                         WHERE v.ID_CAJA=cm.ID_CAJA AND v.MONEDA=cm.MONEDA);
```
Re-ejecutable: `MONTO_CIERRE_PREV` se setea una sola vez (NVL), el filtro evita updates redundantes.

**Paso 5 — `FN_CIERRE_CAJA_HTML(p_id_caja)`**
- Cabecera: caja, oficina, cajero (`USU_APERTURA`), fechas apertura/cierre.
- Por moneda: apertura, ingresos, egresos, **saldo esperado**, declarado, diferencia.
- Desglose por **tipo** de movimiento y por **forma de pago** (join `DETALLE_MOVIMIENTO_CAJA` → `FORMAS_PAGO`).
- Estilo visual P96/P119 reutilizado; **sin** CDC/QR; leyenda "Documento de control interno — sin validez fiscal".
- Vive en `db/F17_cierre_caja.sql` (hogar de la función), análogo a `FN_KUDE_*`.

---

## 5. Pantallas APEX

> Recordatorio: re-exportar la página desde el Builder antes de validar/modificar
> (el PO edita desde APEX). Patch vía `apex-work/` + `install_page.sql`.

| Pág | Acción | Detalle |
|-----|--------|---------|
| **P62** "Caja" (hoy vacía) | **Reconstruir como Estado de Caja** | Selector "mi caja abierta" / `ID_CAJA`. Region cards: saldo esperado por moneda desde `V_CAJA_SALDO`. Region "Movimientos en vivo": IR sobre `MOVIMIENTOS_CAJA` filtrado por caja, con **Auto-refresh** y filtro por `TIPO`. Botón "Cerrar caja" → P61. Botón "Ver arqueo" → P-doc. |
| **P61** Cierre | **Agregar conteo declarado** | IG/items de monto declarado por moneda; el proceso llama `CERRAR_CAJA` v3 pasando el declarado; muestra diferencia antes de confirmar. Fix C4 (pasar `:APP_USER`, no el id) si sigue presente. |
| **P-doc** (nueva) | **Documento de Arqueo/Cierre** | Página de impresión que renderiza `FN_CIERRE_CAJA_HTML(:Pxxx_ID_CAJA)`, patrón idéntico a P96/P119. Link desde P62 y P61 post-cierre. |
| Menú | Entrada "Estado de Caja" apuntando a P62 |

---

## 6. Manejo de errores

Rango `-20940..-20952` (libre entre F16 `-20953..` y bloques previos). P. ej.:
- `-20940` caja inexistente / no abierta en cierre.
- `-20941` declarado negativo o moneda no reconocida.

---

## 7. Verificación

1. Smoke del fix: `CERRAR_CAJA` sobre una caja con `COBRO_CXC` → `MONTO_CIERRE` =
   `V_CAJA_SALDO.SALDO_ESPERADO`.
2. Recalc histórico: tras Paso 4, las cajas 65/66/67 muestran los valores de §2.2
   y `MONTO_CIERRE_PREV` conserva el viejo.
3. Caja 121: cerrarla (en pruebas) → 215.975, no 1.000.000.
4. `FN_CIERRE_CAJA_HTML` corre sin error para una caja cerrada y una abierta.
5. e2e en APEX: abrir → facturar/cobrar → ver estado en vivo → cerrar con conteo →
   imprimir arqueo con diferencia.

---

## 8. Fuera de alcance

- Multi-moneda real (USD) más allá de que el modelo lo soporte — datos en PYG.
- Integración SIFEN (el arqueo no es DE).
- Egresos manuales con UI dedicada (el modelo ya soporta `TIPO='EGRESO'`).
- Re-amortización de intereses (heredado de F16).

---

## 9. Hitos / Checklist de avance

Marcar `[x]` a medida que se completa y verifica cada ítem. Los hitos siguen el
**flujo de la aplicación** (apertura → operación → estado → cierre → documento),
con el fix de backend como prerrequisito transversal.

### H0 — Fix del cierre (prerrequisito, urgente) ✅ 2026-06-26
- [x] `db/F17_cierre_caja.sql` creado, idempotente, con bloque de verificación.
- [x] Vista `V_CAJA_SALDO` con join de moneda normalizado (`MONEDAS`).
- [x] `CERRAR_CAJA` v3 calcula `MONTO_CIERRE` desde `V_CAJA_SALDO` (Paso 3).
- [x] Smoke: caja con `COBRO_CXC` cierra correcto (no subvalúa) — caja 67: 100.000 → 1.815.470.
- [x] Recalculo histórico (Paso 4) + `MONTO_CIERRE_PREV` con valor previo (cajas 65/66/67).
- [x] Verificado: cajas 65/66/67 quedan con el saldo real de §2.2; caja 121 abierta cerraría en 215.975 (no 1.000.000).
- Nota: columnas de arqueo `MONTO_DECLARADO`/`MONTO_DIFERENCIA` ya creadas en `CAJA_MONEDAS` (Paso 1, adelantado para H4).

### H1 — Apertura de caja (P65)
- [ ] Revisar/confirmar que P65 sigue funcional tras el fix (sin regresión).
- [ ] Conteo/montos de apertura por moneda cargan en `CAJA_MONEDAS`.

### H2 — Operación (facturar / cobrar) alimenta la caja
- [ ] `INGRESO_VENTA` (P67) y `COBRO_CXC` (P100) impactan `MOVIMIENTOS_CAJA`.
- [ ] `EGRESO` de reversos (F15) se refleja en el saldo esperado.
- [ ] `V_CAJA_SALDO.SALDO_ESPERADO` coincide con el conteo manual de movimientos.

### H3 — Estado de Caja en vivo (P62) ✅ 2026-06-26
- [x] P62 reconstruida: selector "mi caja abierta" / `ID_CAJA` (`P62_ID_CAJA`, default `FN_CAJA_ABIERTA_USUARIO`).
- [x] Saldo esperado por moneda (region "Saldo por Moneda" sobre `V_CAJA_SALDO`: apertura/ingresos/egresos/esperado/declarado/diferencia). *Nota: implementado como Classic Report en vez de Cards — más robusto de importar; el PO puede migrar a Cards en Builder.*
- [x] Region "Movimientos en vivo" (Classic Report sobre `MOVIMIENTOS_CAJA` filtrado por caja, moneda normalizada).
- [x] Auto-refresh (JS `setInterval` 20s, `apex.region("mov_caja").refresh()`) + filtro por `TIPO` (`P62_TIPO`) funcionando vía DA.
- [x] Botón "Cerrar caja" (→ P61). Botón "Ver arqueo" → diferido a H5 (P-doc aún no existe).
- [x] Región extra "Datos de la Caja" (estado/cajero/fechas).
- [ ] Entrada de menú "Estado de Caja" → **la agrega el PO en el Builder** (no se toca el shared component del menú).
- Import: aislado vía export temporal (solo P62), para no re-importar otras páginas de `install_page.sql`. Verificado: 5 regiones + 2 items + 1 botón + 2 DAs registrados; las 3 queries corren OK contra datos reales.

### H4 — Cierre con conteo declarado (P61) ✅ 2026-06-26
- [x] Columnas `MONTO_DECLARADO` / `MONTO_DIFERENCIA` en `CAJA_MONEDAS` (hecho en H0).
- [x] P61 captura el efectivo declarado (`P61_MONTO_DECLARADO`, Number Field). *Single-field para la moneda de la caja (multi-moneda fuera de alcance §8); en la práctica todo PYG.*
- [x] Proceso "Cerrar caja" guarda `MONTO_DECLARADO` en `CAJA_MONEDAS` antes de llamar `CERRAR_CAJA` v3, que calcula `MONTO_DIFERENCIA = declarado − esperado`.
- [x] Muestra `P61_SALDO_ESPERADO` (display only, desde `V_CAJA_SALDO` de la caja abierta del cajero) antes de confirmar — verificado: 215.975 para TCASCO/caja 121.
- [x] C4 ya estaba resuelto en la versión viva (el proceso pasa `V('APP_USER')`, no el id) — se mantiene.
- Pendiente de validación e2e real (cerrar una caja con conteo) → se cubre en H6 (no se cerró la caja 121 viva en pruebas).

### H5 — Documento de Arqueo/Cierre (P132) ✅ 2026-06-26
- [x] `FN_CIERRE_CAJA_HTML(p_id_caja)` (`db/F17_1_arqueo_html.sql`) corre sin error — smoke caja 67/121/inexistente OK.
- [x] Cabecera (emisor + caja/oficina/cajero/fechas/estado) + desglose por moneda (apertura/ingresos/egresos/esperado/declarado/diferencia, con coloreo sobrante/faltante).
- [x] Desglose por **tipo** de movimiento y por **forma de pago** (`DETALLE_MOVIMIENTO_CAJA` → `FORMAS_PAGO`).
- [x] Leyenda "control interno — sin validez fiscal"; sin CDC/QR. Título "Arqueo y Cierre de Caja".
- [x] **P132** (modal de impresión) renderiza el HTML vía región `NATIVE_DYNAMIC_CONTENT`, patrón idéntico a P119 (mismo CSS `kude`).
- [x] Link desde P62 (botón "Ver arqueo", condicionado a `P62_ID_CAJA`). Link post-cierre desde P61 → se conecta en H4.

### H6 — Cierre del módulo
- [x] e2e: estado en vivo → cerrar con conteo declarado → arqueo. **Validado por el PO el 2026-06-26** cerrando la caja 121 (esperado 215.975, declarado 200.000, diferencia −15.975 faltante; cierre = saldo real, no la apertura).
- [x] Validado por el PO en la app en vivo.
- [x] Commit `feat(F17)` (1b96146) + tag `f17-cierre-arqueo-caja`, pusheados a `main`; `CLAUDE.md` actualizado (Planes activos). **2026-06-26**

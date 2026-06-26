# Plan de implementación — Interés de Financiación en la Factura (F16)

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db`
**Estado del plan:** APROBADO 2026-06-25 — opción B (interés en cabecera) + scope minimal. En implementación.
**Rango de error reservado:** `-20953 … -20969` (hueco libre entre F11 y F14).

> Plan separado. Corrige una **inconsistencia fiscal** detectada al revisar el
> flujo de venta a crédito: hoy el interés de financiación se suma a la cuenta
> por cobrar y a las cuotas, pero **no aparece en la factura**. La factura
> documenta un monto menor al que el cliente realmente debe y paga.

---

## 1. Problema detectado (verificado en `tesis_db`, 2026-06-21)

`TRG_INS_CUENTAS_COBRAR` (AFTER INSERT en `COMPROBANTES`, cuando `FORMA_PAGO='1'`):

```sql
v_total_interes := (:NEW.TOTAL_MONEDA_LOCAL * v_tasa_interes) / 100;  -- ej. 5%
v_total_a_pagar := :NEW.TOTAL_MONEDA_LOCAL + v_total_interes;         -- bienes + interés
-- CUENTAS_COBRAR.TOTAL_A_PAGAR = SALDO = v_total_a_pagar
-- cuotas = v_total_a_pagar / nro_cuotas
```

Pero `COMPROBANTES.TOTAL_MONEDA_LOCAL` = **solo los bienes**, sin interés.
Resultado:

| Concepto | Valor |
|---|---|
| Total de la **factura** (`COMPROBANTES`) | bienes (sin interés) |
| **CxC** (`CUENTAS_COBRAR.SALDO`) y suma de cuotas | bienes **+ interés** |

Datos vivos: `PLANES_CUOTA` → Plan A, 6 cuotas, **tasa 5%**.

### Por qué está mal (SIFEN, Manual Técnico)

1. **Reconciliación rota.** La factura electrónica declara la *condición de venta
   a crédito* (grupo `gPagCred`/`gCuotas`): cantidad de cuotas y monto de cada
   una. **La suma de las cuotas debe cuadrar con el total de la factura**
   (`dTotGralOpe`). Hoy las cuotas suman `total + 5%` y la factura solo `total` →
   no concilian.
2. **Interés no documentado.** El **interés de financiación está gravado con IVA
   10%** en Paraguay (es un servicio financiero). Cobrar un 5% que no figura en
   ningún documento fiscal es ingreso gravado sin facturar.

> Matiz de alcance: el sistema es **representación sin validez fiscal** (no
> integra SIFEN). Aun así, como F11/F14 ya se alinearon a SIFEN, corresponde
> dejar la factura **internamente consistente** (factura = CxC = Σ cuotas) y
> mostrar el interés con su IVA.

---

## 2. Decisiones tomadas

| # | Tema | Decisión |
|---|------|----------|
| 1 | **Cómo se representa el interés en la factura** | ✅ **Opción B (cabecera) — elegida por el PO (2026-06-25).** El interés se guarda como **columna en `COMPROBANTES`** (`INTERES_FINANCIACION`) y se suma a `TOTAL_MONEDA_LOCAL`/`TOTAL_IVA_10`/`TOTAL_IVA`. El detalle (`DETALLE_COMPROBANTE`) queda **solo con los bienes**. El KuDE lo dibuja como una fila "Interés de financiación". **Se descartó la opción A** (línea de detalle con producto-servicio) porque obligaba a un producto falso y, sobre todo, porque `TRG_MOV_STOCK_DETALLE` hace `SELECT CANTIDAD INTO ... FROM STOCK_PRODUCTO` **sin manejar `NO_DATA_FOUND`** → una línea de servicio sin stock **rompe la factura**; evitarlo exigía un flag `MANEJA_STOCK` + cirugía en el trigger de stock + revisar compras/transferencias. B esquiva todo eso sin tocar ningún trigger de stock. |
| 2 | **IVA del interés** | **Gravado 10%** (servicio financiero, PY). IVA del interés = `interes × 10/110` (el interés es un importe IVA-incluido). |
| 3 | **Dónde se calcula** | En **P67 (facturación)**, no en el trigger. P67 setea la columna + los totales financiados; `TRG_INS_CUENTAS_COBRAR` deja de calcular interés y parte las cuotas desde el total ya financiado. Cálculo en **un solo lugar**. |
| 4 | **Columnas gravada/exenta de cabecera** | **Scope minimal (PO 2026-06-25):** `TOTAL_GRAVADA_*`/`TOTAL_EXENTA` quedan como hoy (NULL, sin uso — el KuDE deriva del detalle). F16 solo asegura `TOTAL_IVA_10`/`TOTAL_IVA` + el desglose impreso del KuDE. Poblar gravada/exenta es un hueco pre-existente, fuera de alcance (§7). |

---

## 3. Diseño (opción B — minimal)

### 3.1 Modelo de datos — `db/F16_interes_financiacion.sql` (idempotente)

**Columna nueva en `COMPROBANTES`** (nullable; solo la llena la venta a crédito):
```sql
ALTER TABLE COMPROBANTES ADD (INTERES_FINANCIACION NUMBER);
-- monto del interes (IVA incluido). NULL/0 en contado.
```
No hace falta una columna para el IVA del interés: es derivable
(`INTERES_FINANCIACION × 10/110`) y ya está sumado dentro de `TOTAL_IVA_10`.

**`TRG_INS_CUENTAS_COBRAR` v2** — deja de re-sumar el interés (la factura ya viene
financiada):
```sql
-- antes: v_total_a_pagar := :NEW.TOTAL_MONEDA_LOCAL + (TOTAL * tasa/100);
v_total_a_pagar := :NEW.TOTAL_MONEDA_LOCAL;   -- ya incluye interes
v_monto_cuota   := ROUND(v_total_a_pagar / v_cuotas, 2);
```
Así **factura total = CxC.SALDO = Σ cuotas** (mismo monto que paga el cliente hoy,
ahora reconciliando con la factura).

> **No se toca ningún trigger de stock** (esa es la ventaja de B).

### 3.2 Facturación (P67) — setear interés + totales cuando es crédito

Un proceso AFTER_SUBMIT **antes** del `Process form COMPROBANTES` (el INSERT),
**solo si `FORMA_PAGO='1'`**:
1. `v_interes := ROUND(:P67_TOTAL_MONEDA_LOCAL * tasa/100, 0)` (tasa del `PLANES_CUOTA` elegido).
2. `:P67_INTERES_FINANCIACION := v_interes`.
3. `:P67_TOTAL_MONEDA_LOCAL := :P67_TOTAL_MONEDA_LOCAL + v_interes`.
4. `:P67_TOTAL_IVA_10 := :P67_TOTAL_IVA_10 + ROUND(v_interes*10/110, 0)`;
   `:P67_TOTAL_IVA := :P67_TOTAL_IVA + ROUND(v_interes*10/110, 0)`.

El detalle de bienes (`Detalle Factura Cursor`) **no se toca** — sigue insertando
solo los productos físicos. La CxC se arma luego del total ya financiado (§3.1).

### 3.3 KuDE P96 (`FN_KUDE_FACTURA_HTML`)

Cuando `COMPROBANTES.INTERES_FINANCIACION > 0`:
1. Dibujar una **fila extra "Interés de financiación"** en la tabla de ítems, con
   el monto en la columna **IVA 10%** (es un cargo gravado al 10%).
2. Sumar el interés al **subtotal gravada-10** y al **IVA 10%** de la liquidación
   (el KuDE deriva los subtotales del detalle, que no incluye el interés → hay
   que agregarlo desde la columna de cabecera).
3. (Liviano) Bloque **condición de crédito** al pie: cantidad de cuotas y monto de
   cada una (lee de `CUENTAS_COBRAR_DET`), estilo `gPagCred` de SIFEN.

### 3.4 Migración de datos existentes

**No se tocan los históricos.** El cambio aplica a facturas nuevas; las viejas son
inmutables (filosofía fiscal). Las facturas a crédito ya emitidas conservan su
inconsistencia conocida (factura < CxC) y se documenta.

---

## 4. Hitos

- [x] **H1** — Backend `db/F16_interes_financiacion.sql`: columna
  `COMPROBANTES.INTERES_FINANCIACION` + `TRG_INS_CUENTAS_COBRAR` v2 + verificación.
  Smoke con `ROLLBACK`. **Hecho 2026-06-25.** El trigger arma la CxC desde
  `:NEW.TOTAL_MONEDA_LOCAL` (sin re-sumar interés); cuotas en enteros PYG
  (`ROUND(...,0)`, SIFEN) con la última cuota absorbiendo el remanente →
  `factura == CxC.SALDO == Σ cuotas` exacto.
- [x] **H2** — P67: ítem oculto `P67_INTERES_FINANCIACION` (source = columna
  `INTERES_FINANCIACION`, mapeado al form DML) + proceso AFTER_SUBMIT
  `Calcular interes financiacion` (seq 9, antes del form DML seq 10): cuando
  `FORMA_PAGO='1'` setea interés + financia `TOTAL_MONEDA_LOCAL`/`TOTAL_IVA_10`/
  `TOTAL_IVA`. **Hecho 2026-06-25** (live + smoke integración con `ROLLBACK`).
- [x] **H3** — `FN_KUDE_FACTURA_HTML`: fila "Interés de financiación" (monto en
  columna IVA 10%) + interés sumado al subtotal gravada-10 (reconcilia tabla vs.
  Total a Pagar) + bloque "Condición de Venta: Crédito" con las cuotas (gPagCred).
  **Hecho 2026-06-25.** El cambio vive en `db/F12_kude_factura.sql` (hogar de la
  función); para desplegar F16 completo hay que re-correr F12. Verificado sobre la
  factura real 001-001-0000032 (subtotal IVA10 = 65.520 = Total a Pagar; contado
  sin cambios).
- [x] **H4** — Test e2e: factura crédito real **001-001-0000032** (Plan A, Mouse
  62.400) → `factura.total = CxC.SALDO = Σ cuotas = 65.520`, interés 3.120, IVA 10%
  incluye el interés (5.957 = 5.673 + 284), KuDE muestra fila de interés + cuotas;
  **contado** (ID 143) sin cambios. **Hecho 2026-06-25** (validado por el PO en el
  navegador + datos verificados en BD).
- [x] **H5** — Cierre: P67 re-exportado y sincronizado a `apex-work`, `CLAUDE.md`
  actualizado, commit `feat(F16)` + tag `f16-interes-financiacion`. **Hecho 2026-06-25.**

---

## 5. Riesgos

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | Doble conteo si se cambia P67 pero no el trigger (o viceversa). | H1 y H2 van juntos; H4 valida `factura == CxC == Σ cuotas`. |
| R2 | Interacción con F14 (NC) y F15 (reverso): operan sobre `CUENTAS_COBRAR.SALDO`. | Al quedar `factura == CxC`, NC y reverso siguen cuadrando. La NC acredita **líneas de bienes** (detalle); el interés vive en cabecera y no es acreditable por NC (documentado en §6). |
| R3 | Redondeo del interés y su IVA vs. suma de cuotas (PYG sin centavos). | `ROUND(...,0)`; si la suma de cuotas difiere por centavos, ajustar la última cuota. |
| R4 | Históricos inconsistentes (factura < CxC). | No se tocan (decisión §3.4); documentado. |
| R5 | KuDE: el subtotal gravada-10 derivado del detalle no incluiría el interés. | El KuDE suma explícitamente el interés (columna de cabecera) al bucket 10% — parte de H3. |

---

## 6. Fuera de alcance

- **Poblar `TOTAL_GRAVADA_*` / `TOTAL_EXENTA`** en `COMPROBANTES` (hueco
  pre-existente: hoy NULL en todas las facturas; el KuDE deriva del detalle). Scope
  minimal lo deja como está.
- **Fix `DETALLE_COMPROBANTE.ID_TIPO_IVA`** (el cursor de P67 lo deja NULL): deuda
  separada, no se toca el cursor en B.
- Backfill de facturas a crédito históricas.
- NC que acredite la porción de interés (la NC opera sobre líneas de bienes).
- Interés compuesto o tasas por cliente/segmento (hoy tasa única por plan).
- Integración SIFEN real (`gPagCred` en XML firmado).

---

## 7. Aprobación

> Plan aprobado por el PO el 2026-06-25: **opción B (interés en cabecera) + scope
> minimal** (sin tocar triggers de stock ni columnas gravada/exenta). Arranca por
> `db/F16_interes_financiacion.sql` (H1).

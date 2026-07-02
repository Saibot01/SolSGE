# Plan de implementación — Cuentas por Pagar → Orden de Pago — F24

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db` (conectás como ADMIN; los datos viven en `WKSP_WORKPLACE` → usar `ALL_*`, no `USER_*`)
**Estado del plan:** EN VALIDACIÓN — 2026-07-02.
**Rango de error reservado:** `-20935 … -20939`.
**Páginas APEX nuevas:** **P146** (Deuda a Proveedores) · **P147** (Generar Orden de Pago) · **P148** (Órdenes de Pago).
**Dependencia inversa:** desbloquea la capa de deuda/aging (H) de **F25** (`PLAN_REPORTES_COMPRAS.md §1.4`), que consume la CxP **real** que este feature genera.

> Feature **transaccional** (no gerencial): el sistema, a partir de los comprobantes
> de proveedor (facturas de compra), genera la **deuda a proveedores**
> (`CUENTAS_PAGAR`) y permite emitir la **Orden de Pago** que la salda. Espeja el
> patrón de Ventas → Cuentas por Cobrar (`TRG_INS_CUENTAS_COBRAR`), adaptado a
> pago **único** (sin cuotas) y con **modelo de dos pasos** (autorización ≠ pago).

---

## 1. Contexto verificado en `tesis_db` (2026-07-02)

| Objeto | Estado real |
|---|---|
| `CUENTAS_PAGAR` (PK `ID_CXP` identity) | **0 filas**, ningún trigger la puebla. Columnas: `ID_CXP`, `ID_PROVEEDOR`, `ID_COMPROBANTE`, `TOTAL_A_PAGAR`, `SALDO`, `FECHA_REGISTRO` (def SYSDATE), `ESTADO` (def `'PENDIENTE'`). **Falta `FECHA_VENCIMIENTO`.** Sin tabla `_DET` → pago único. |
| `COMPROBANTES_PROVEEDOR` | 8 filas, todas `FA`. **Sin columna de condición/forma de pago.** Tiene `ID_FAC_ORIGEN` (hook NC), `MONEDA`/`TIPO_CAMBIO`. 7 backfilleables (`ESTADO<>'A'` + `TOTAL`/`FECHA` no NULL); el **21** se excluye solo (NULL). Proveedores 1 (×7) y 101 (×1). |
| `PROVEEDORES` (PK `ID_PERSONA`) | 2 filas (1, 101). Columnas: `CODIGO_USUARIO`, `ESTADO`, `FECHA_REGISTRO`, `CATEGORIA`. **Sin plazo de pago.** |
| `TRG_INS_CUENTAS_COBRAR` | Patrón a espejar: `AFTER INSERT ON COMPROBANTES FOR EACH ROW`, solo si `FORMA_PAGO='1'`, inserta cabecera (`ID_CLIENTE→ID_PERSONA`, `TOTAL_MONEDA_LOCAL`, `FN_AHORA`) + cuotas. |
| `SEQ_ORDEN_PAGO_ID` | **Secuencia ya existe** (sin usar, `last_number=1`), pero **no hay tabla de orden de pago** → scaffold a medias. La **reutilizamos**. |
| `MOVIMIENTOS_CAJA` | `ID_CLIENTE` y `ID_CAJA` **NOT NULL**; sin `ID_PROVEEDOR`/`ID_CXP`. Por eso el egreso de caja queda **fuera de F24** (impactaría el arqueo/cierre F17). |
| `FORMAS_PAGO` | `1`=Crédito, `21`=Contado. `METODOS_PAGO`: 1 Efectivo, 2 Tarjeta, 3 Transferencia, 4 QR. |
| `FN_HOY` / `FN_AHORA` | Presentes (fecha/hora local UTC-3). |

---

## 2. Decisiones del PO (2026-07-02)

| # | Tema | Decisión |
|---|------|----------|
| 1 | **¿Qué genera CxP?** | **Solo crédito.** Se agrega columna de condición a `COMPROBANTES_PROVEEDOR` (espeja `FORMA_PAGO` de ventas: `'1'`=crédito, `'21'`=contado). Solo crédito genera CxP. Requiere selector en P69/P70 y setear la condición en el backfill. **Históricos: los 7 comprobantes van a crédito → todos generan CxP** (confirmado PO 2026-07-02). |
| 2 | **Origen de `FECHA_VENCIMIENTO`** | **Plazo por proveedor.** Nueva columna `PROVEEDORES.PLAZO_PAGO_DIAS`. `FECHA_VENCIMIENTO = FECHA_EMISION + NVL(plazo, 30)`. Requiere exponer el plazo en el ABM de proveedores: **P42 (Form)** para cargar/editar y **P41 (IR)** para visualizar. |
| 3 | **Modelo de Orden de Pago** | **Dos pasos.** OP se emite en `BORRADOR` (documento de autorización, **NO baja saldo**). Un segundo paso **Confirmar pago** baja el `SALDO` de las CxP aplicadas y marca la OP `PAGADA`. |
| 4 | **Impacto en caja** | **Fuera de F24.** El pago solo mueve la CxP; no escribe en `MOVIMIENTOS_CAJA` ni toca el arqueo/cierre F17. Follow-up posible. |
| 5 | **NC de proveedor (P94)** | **Fuera de alcance, con hook.** El diseño tolera una futura NC que baje `SALDO` vía `ID_FAC_ORIGEN`, pero no se construye ahora (P94 sin datos). |

---

## 3. Diseño

### 3.1 Cambios de esquema (DDL idempotente) — `db/F24_cuentas_pagar.sql`

1. `ALTER TABLE PROVEEDORES ADD PLAZO_PAGO_DIAS NUMBER DEFAULT 30` (si no existe).
2. `ALTER TABLE COMPROBANTES_PROVEEDOR ADD FORMA_PAGO VARCHAR2(2) DEFAULT '21'`
   (contado por defecto → **no** genera CxP salvo elección explícita de crédito;
   evita crear CxP sorpresa en comprobantes nuevos hasta que P69/P70 tengan el selector).
3. `ALTER TABLE CUENTAS_PAGAR ADD FECHA_VENCIMIENTO DATE` (para el aging).
4. **`TRG_INS_CUENTAS_PAGAR`** (`AFTER INSERT OR UPDATE ON COMPROBANTES_PROVEEDOR
   FOR EACH ROW`), espejo de `TRG_INS_CUENTAS_COBRAR` adaptado a pago único.
   **Momento de la deuda (decisión PO 2026-07-02):** nace **al registrar la factura**
   (`ESTADO='R'`), sin esperar recepción de mercadería — la deuda es la factura, no
   los bienes; `R/PR/C` es el eje de recepción, independiente de la obligación de
   pago. `AFTER INSERT OR UPDATE` + guard `NOT EXISTS` (idempotente) para cubrir el
   caso en que P69/P70 cree el comprobante y setee condición/total después:
   ```
   IF :NEW.FORMA_PAGO = '1'                 -- crédito
      AND :NEW.ESTADO <> 'A'
      AND :NEW.TOTAL_COMPROBANTE IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM CUENTAS_PAGAR
                      WHERE ID_COMPROBANTE = :NEW.ID_COMPROBANTE) THEN
     SELECT NVL(PLAZO_PAGO_DIAS,30) INTO v_plazo
       FROM PROVEEDORES WHERE ID_PERSONA = :NEW.ID_PROVEEDOR;
     INSERT INTO CUENTAS_PAGAR (ID_PROVEEDOR, ID_COMPROBANTE, TOTAL_A_PAGAR,
        SALDO, FECHA_REGISTRO, FECHA_VENCIMIENTO, ESTADO)
     VALUES (:NEW.ID_PROVEEDOR, :NEW.ID_COMPROBANTE, :NEW.TOTAL_COMPROBANTE,
        :NEW.TOTAL_COMPROBANTE, WKSP_WORKPLACE.FN_AHORA,
        TRUNC(:NEW.FECHA_EMISION) + v_plazo, 'PENDIENTE');
   END IF;
   ```
   > No colisiona con `TRG_ACTUALIZAR_COSTO_COMPRA` (AFTER UPDATE, único trigger hoy).
   > **Edge (hook, fuera de alcance):** si el comprobante se anula (`ESTADO='A'`) y su
   > CxP no tiene pagos (`SALDO=TOTAL`), convendría marcarla `ANULADA`; se documenta
   > como follow-up, no se construye ahora.

### 3.2 Orden de Pago (tablas + procs) — `db/F24_1_ordenes_pago.sql`

**Tablas (reusan `SEQ_ORDEN_PAGO_ID`):**
```
ORDENES_PAGO (
  ID_ORDEN_PAGO  NUMBER DEFAULT SEQ_ORDEN_PAGO_ID.NEXTVAL PRIMARY KEY,
  ID_PROVEEDOR   NUMBER NOT NULL REFERENCES PROVEEDORES(ID_PERSONA),
  FECHA_EMISION  DATE,                       -- emisión del borrador (FN_AHORA)
  FECHA_PAGO     DATE,                        -- NULL hasta confirmar
  TOTAL_PAGO     NUMBER,                      -- Σ detalle
  ID_METODO_PAGO NUMBER REFERENCES METODOS_PAGO(ID_METODO_PAGO),  -- se completa al confirmar
  ESTADO         VARCHAR2(20) DEFAULT 'BORRADOR',   -- BORRADOR / PAGADA / ANULADA
  USUARIO        VARCHAR2(60),
  OBSERVACION    VARCHAR2(255)
)
ORDEN_PAGO_DET (
  ID_DETALLE     NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  ID_ORDEN_PAGO  NUMBER NOT NULL REFERENCES ORDENES_PAGO(ID_ORDEN_PAGO) ON DELETE CASCADE,
  ID_CXP         NUMBER NOT NULL REFERENCES CUENTAS_PAGAR(ID_CXP),
  MONTO_APLICADO NUMBER NOT NULL
)
```

**Procedimientos (standalone `PRC_`, estilo F14). Rango `-20935..-20939`:**
- **`PRC_GENERAR_ORDEN_PAGO`** (proveedor + detalle [(id_cxp, monto)] + obs → out id_op):
  valida que cada CxP sea del proveedor y no esté `PAGADA`, y `0 < monto ≤ SALDO`
  actual (`-20935` monto inválido, `-20936` CxP no corresponde); inserta cabecera
  `BORRADOR` (`FECHA_EMISION=FN_AHORA`, `USUARIO=V('APP_USER')`) + detalle;
  `TOTAL_PAGO=Σ`. **No baja saldo** (paso 1).
- **`PRC_CONFIRMAR_ORDEN_PAGO`** (id_op + método):
  exige `ESTADO='BORRADOR'` (`-20937`); por cada detalle `SELECT … FOR UPDATE` de la
  CxP, revalida `monto ≤ SALDO` (concurrencia, `-20938` saldo insuficiente),
  `UPDATE CUENTAS_PAGAR SET SALDO=SALDO-monto, ESTADO=CASE WHEN saldo_nuevo<=0 THEN
  'PAGADA' ELSE 'PARCIAL' END`; marca OP `PAGADA`, `FECHA_PAGO=FN_AHORA`,
  `ID_METODO_PAGO`. **Sin caja** (fuera de alcance). (Paso 2.)
- **`PRC_ANULAR_ORDEN_PAGO`** (id_op): solo si `BORRADOR` → `ANULADA` (`-20939`
  no se puede anular una OP ya pagada; la reversa de saldos queda como hook).

### 3.3 Backfill idempotente — `db/F24_2_backfill_cxp.sql`

1. **Seed plazo demo:** `UPDATE PROVEEDORES SET PLAZO_PAGO_DIAS=30/45` (prov 1 / 101)
   donde esté NULL.
2. **Condición de los históricos:** `UPDATE COMPROBANTES_PROVEEDOR SET FORMA_PAGO='1'`
   en los **7** comprobantes no basura → **todos** a crédito (decisión PO 2026-07-02),
   para que generen CxP y haya aging real.
3. **Poblar `CUENTAS_PAGAR`** desde los 7 comprobantes con `INSERT … WHERE NOT EXISTS`
   (idempotente): `TOTAL_A_PAGAR=SALDO=TOTAL_COMPROBANTE`, `FECHA_VENCIMIENTO=
   TRUNC(FECHA_EMISION)+plazo`, `FECHA_REGISTRO=FN_AHORA`, `ESTADO='PENDIENTE'`.
   Las fechas reales (jun-2025 … jun-2026) reparten el aging naturalmente.
4. **Verificación** final: CxP = 7, `SALDO=TOTAL`, `FECHA_VENCIMIENTO` no NULL;
   `RAISE_APPLICATION_ERROR(-20935)` si falla.

### 3.4 APEX (import **aislado** por página; el menú lo agrega el PO)

- **P146 "Deuda a Proveedores"** — Interactive Report sobre `CUENTAS_PAGAR` (join
  `PROVEEDORES`→`PERSONAS`, `COMPROBANTES_PROVEEDOR`): proveedor, nro comprobante,
  total, saldo, vencimiento, **días de atraso** (`FN_HOY − FECHA_VENCIMIENTO`),
  estado. Botón "Generar Orden de Pago" → P147.
- **P147 "Generar Orden de Pago"** — selector de proveedor (LOV) → **Interactive
  Grid / tabular** de sus CxP con `SALDO>0` y columna editable "monto a aplicar";
  botón Guardar → `PRC_GENERAR_ORDEN_PAGO` (crea OP `BORRADOR`). Contenedor plano
  para los ítems (evita `ORA-01403`).
- **P148 "Órdenes de Pago"** — IR sobre `ORDENES_PAGO`: estado, total, fechas.
  Acciones: **Confirmar pago** (pide método → `PRC_CONFIRMAR_ORDEN_PAGO`) y
  **Anular** (`PRC_ANULAR_ORDEN_PAGO`). Detalle de la OP en región/modal.
- **P42 "Proveedores Form" (Form sobre `PROVEEDORES`):** agregar Number Field
  mapeado a `PLAZO_PAGO_DIAS` (cargar/editar el plazo de pago). **P41 "Proveedores
  IG" (es un Interactive Report, no IG):** agregar la columna `PLAZO_PAGO_DIAS` al
  SQL del reporte (visualizar). Sin esto el plazo solo se puede setear por SQL.
- **P69/P70 (comprobante de compra):** agregar selector "Condición" (Contado/Crédito)
  mapeado a `FORMA_PAGO`. Sin este selector, los comprobantes nuevos quedan contado
  (no generan CxP) — los históricos ya quedan cubiertos por el backfill.
- **Regla del PO:** todas estas páginas ya existentes (P41/P42/P69/P70) se
  **re-exportan antes de tocar** (memorias `reexport-apex-before-editing` /
  `apex-import-aislado`) y se importan aisladas; si preferís, los cambios chicos de
  ítem/columna los hacés vos en el Builder.

### 3.5 Despliegue

- DB (stdin redirect, por el bug del `@file`): `sql -S -name tesis_db < db/F24_cuentas_pagar.sql`,
  luego `F24_1_ordenes_pago.sql`, luego `F24_2_backfill_cxp.sql`.
- APEX: `install_p146/147/148.sql` aislados (`set_environment` + `delete`/`page` +
  `end_environment`), **no** el `install_page.sql` completo (pisa cambios del PO).

---

## 4. Hitos

- [x] **H1 — DDL + trigger** (`db/F24_cuentas_pagar.sql`): plazo, condición,
  `FECHA_VENCIMIENTO`, `TRG_INS_CUENTAS_PAGAR`. Aplicado + smoke test OK (2026-07-02).
- [x] **H2 — OP tablas + procs** (`db/F24_1_ordenes_pago.sql`): `ORDENES_PAGO`/
  `ORDEN_PAGO_DET` (reusa `SEQ_ORDEN_PAGO_ID`) + `PRC_GENERAR/CONFIRMAR/ANULAR`.
  Aplicado + flujo 2 pasos + errores probados.
- [x] **H3 — Backfill** (`db/F24_2_backfill_cxp.sql`): 7 CxP históricas (todas
  crédito), plazos demo, idempotente. Aplicado. + `db/F24_3_vista_cxp.sql`
  (`V_CXP_DEUDA`).
- [x] **H4 — APEX** P146 (Deuda IR) / P147 (Generar OP) / P148 (Órdenes de Pago) +
  **P149 + `FN_ORDEN_PAGO_HTML`** (documento, a pedido del PO) + `PLAZO_PAGO_DIAS`
  en P42/P41 + selector Condición en **P70**. Import aislado. **P69 (IG) sin tocar**
  (P70 form cubre la condición). Validado por el PO.
- [ ] **H5 — Cierre:** `CLAUDE.md` (entrada F24) ✔, plan ✔, memoria, avisar a F25.
  Commit `feat(F24)` pendiente de OK del PO.

---

## 5. Riesgos

| # | Riesgo | Mitigación |
|---|--------|------------|
| R1 | El `UPDATE` del backfill no dispara el trigger `AFTER INSERT` → CxP no se puebla. | El backfill inserta CxP explícitamente (`WHERE NOT EXISTS`), no depende del trigger. |
| R2 | Comprobantes nuevos por P69/P70 sin `FORMA_PAGO` → no generan CxP. | Default `'21'` (contado, no rompe); selector de condición en P69/P70 cierra el loop. |
| R3 | Concurrencia: dos OP sobre la misma CxP dejan saldo negativo. | `SELECT … FOR UPDATE` + revalidación de saldo en `PRC_CONFIRMAR_ORDEN_PAGO` (`-20938`). |
| R4 | Fecha en UTC. | `FN_HOY`/`FN_AHORA` (UTC-3) en trigger/procs/vistas, nunca `SYSDATE`. |
| R5 | Import por `install_page.sql` completo pisa cambios del PO. | Import aislado por página (memoria `apex-import-aislado`). |
| R6 | Editar P41/P42/P69/P70 (páginas existentes) pisa cambios del PO. | Re-exportar antes de tocar + import aislado (memorias `reexport-apex-before-editing`/`apex-import-aislado`); cambios chicos de ítem/columna los puede hacer el PO en el Builder. |

---

## 6. Fuera de alcance

- **Egreso de caja** al pagar (impactaría arqueo/cierre F17) — follow-up.
- **NC de proveedor** que reduzca CxP (P94 sin datos) — solo hook vía `ID_FAC_ORIGEN`.
- **Cuotas** de CxP (pago único, a diferencia de CxC).
- **Reversa de saldos** al anular una OP ya `PAGADA` (solo se anula `BORRADOR`).
- ~~Documento imprimible de la OP (KuDE-style)~~ **→ agregado a pedido del PO
  (2026-07-02):** `FN_ORDEN_PAGO_HTML` (`db/F24_4_orden_pago_html.sql`) + página
  **P149** "Documento Orden de Pago" (Dynamic Content, estilo `kude`, **no es DE
  SIFEN** — sin CDC/QR, leyenda "sin validez fiscal"); link "Documento" en la
  columna Acciones de P148. Espeja el arqueo P132/F17.
- Multi-moneda real (todo PYG en datos).

---

## 8. Ajustes post-validación (2026-07-02, pedidos del PO)

- **Resolución de la OP rediseñada al patrón P124/P126 (NC):** en vez de acciones
  inline en P148, ahora **P148 es un Interactive Report** con detail-link
  **"Resolver"** → **P150 "Resolver Orden de Pago"** (modal) que muestra el detalle
  de comprobantes aplicados y los botones **Confirmar** (elige `METODOS_PAGO`) /
  **Anular** (pide **motivo**, guardado en `ORDENES_PAGO.MOTIVO_ANULACION`, columna
  nueva + `PRC_ANULAR_ORDEN_PAGO(p_motivo)`); botones condicionados a
  `ESTADO='BORRADOR'`. El N° de OP en P148 enlaza al documento **P149**. DA refresca
  P148 al cerrar el modal.
- **P97 "Factura de Proveedor" remaquetada al estilo `kude`** vía
  `FN_KUDE_FACTURA_PROV_HTML` (`db/kude_factura_proveedor.sql`): del lado compra
  (emisor = proveedor, receptor = nuestra empresa desde `PARAMETROS` EMPRESA),
  condición + vencimiento de la CxP, y **desglose de IVA derivado del producto**
  (`PRODUCTOS.ID_TIPO_IVA`→`TIPO_IVA.PORCENTAJE`, precio IVA incluido: 5%=base·5/105,
  10%=base·10/110), ya que `DETALLE_COMPROBANTE_PROV` no guarda IVA por línea.
  Reemplazó el HTML inline viejo con emisor hardcodeado. No es F24 estricto (doc de
  compras), versionado junto a esta feature.

# Plan — Documentos impresos como Representación Gráfica KuDE (F12 + F13)

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`) · Workspace/Schema `WKSP_WORKPLACE`
**Conexión:** `tesis_db`
**Estado:** ✅ implementado y aplicado (F12 el 2026-06-10, F13 el 2026-06-11).
Commiteado en `main` (`feat(F12+F13): P96 y P119 como representacion grafica KuDE`).
Verificación visual en browser confirmada por el PO el 2026-06-14.

> Plan separado de `PLAN_FACTURACION.md`. Aquel cierra el flujo de facturación
> y cobros; éste cubre **solo la representación gráfica impresa** de la factura
> (P96) y el recibo (P119). Cierra la deuda anotada en `PLAN_FACTURACION.md §F9.G`
> ("P96 datos emisor hardcoded").

---

## 1. Contexto y objetivo

Las páginas modales de impresión P96 (Documento Factura) y P119 (Documento
Recibo) eran maquetas genéricas: P96 tenía los datos del emisor **hardcodeados**
y ninguna se parecía al **KuDE** (Representación Gráfica del Documento
Electrónico) que define la SET de Paraguay.

Objetivo: **remaquetar P96 al layout KuDE** usando los datos que el sistema ya
tiene, y darle a **P119 la misma identidad visual** para coherencia de marca.

### Matiz SIFEN (decisión de alcance)

El sistema **NO está integrado a SIFEN**: no hay firma digital, ni envío de XML,
ni CDC/QR reales emitidos por la SET. Por eso, decidido con el PO:

- **Solo réplica visual.** No se genera CDC ni QR. Se imprime la numeración SET
  (EST-PE-NRO, que sí existe) y la leyenda legal, con una nota
  **"representación de demostración — sin validez fiscal"**.
- **La factura electrónica SÍ es un Documento Electrónico SIFEN** → P96 se titula
  "KuDE de Factura Electrónica".
- **El recibo de cobro NO es un Documento Electrónico SIFEN** (SIFEN solo cubre
  factura, NC/ND, nota de remisión y autofactura) → P119 se titula
  **"Recibo de Dinero"**, sin CDC/QR ni la palabra "KuDE"; reusa el estilo visual
  solo por coherencia.

---

## 2. Decisiones tomadas

| # | Decisión |
|---|----------|
| 1 | **Solo representación visual** (sin CDC/QR; sistema no integrado a SIFEN). |
| 2 | **HTML generado en funciones de BD**, no inline en la página. Evita el doble-escape de acentos del export APEX (pitfall del repo) y permite testear con `SELECT FN_..._HTML(id) FROM DUAL`. La región APEX queda como un `RETURN FN_..._HTML(:Pxx_ID)`. |
| 3 | **Acentos por entidades HTML** (`&oacute;`, etc.) para mantener el fuente PL/SQL ASCII; los datos en runtime fluyen en UTF-8 normal. |
| 4 | **Emisor parametrizado** en `PARAMETROS` `TIPO_PARAMETRO='EMPRESA'` vía `FN_GET_PARAMETRO`, igual que P119 ya hacía para RUC/RAZON_SOCIAL/DIRECCION. |
| 5 | **Subtotales por tasa calculados desde `DETALLE_COMPROBANTE.PORCENTAJE_IVA`** — las columnas `COMPROBANTES.TOTAL_GRAVADA_*` y `TOTAL_EXENTA` están NULL en los datos reales (P67 no las llena); solo `TOTAL_IVA_5/10/TOTAL_IVA` se poblan. |
| 6 | **Detalle del recibo = medio de pago** (`Método de Pago \| Monto \| Nro. Referencia`). Se descartó la columna "Forma de Pago" (Contado/Crédito) por redundante en un recibo. |
| 7 | **Numeración a letras propia** (`FN_NUMERO_A_LETRAS`) — no existía función en la BD. |

---

## 3. Hallazgos del modelo de datos (relevados contra `tesis_db`)

- `COMPROBANTES.MONEDA` guarda el **código** (`'1'` → tabla `MONEDAS`), pero
  `MOVIMIENTOS_CAJA.MONEDA` guarda el **texto** (`'PYG'`). Inconsistencia entre
  tablas → el join a `MONEDAS` en ambas funciones es robusto:
  `ON (CODIGO_MONEDA = x OR DESCRIPCION = x)`.
- `COMPROBANTES.TOTAL_GRAVADA_*` / `TOTAL_EXENTA` → **NULL** en datos reales.
- `FORMA_PAGO`: `'1'`=Crédito, `'21'`=Contado (`FORMAS_PAGO`).
- Receptor: `PERSONAS` (nombres, `NRO_DOCUMENTO`, `CORREO`); teléfono en
  `TELEFONOS`, dirección en `DIRECCIONES` (frecuentemente vacíos → se muestra `-`).
- Timbrado + vigencia: `TALONARIOS.TIMBRADO`, `FECHA_INICIO`.

---

## 4. Implementación

### F12 — Factura (P96) · `db/F12_kude_factura.sql`

Script idempotente (MERGE + CREATE OR REPLACE). Contiene:

1. **Parámetros de emisor** nuevos en `PARAMETROS` EMPRESA: `TELEFONO`, `CIUDAD`,
   `ACTIVIDAD_ECONOMICA`, `TIPO_CONTRIBUYENTE` (el MERGE **no pisa** `VALOR_TEXTO`
   si ya existe — respeta ediciones del admin).
2. **`FN_NUMERO_A_LETRAS(p_monto, p_moneda DEFAULT 'GUARANÍES')`** — entero a
   texto en español hasta cientos de miles de millones; guaraní sin centavos.
3. **`FN_KUDE_FACTURA_HTML(p_id_comprobante)`** — arma el HTML del KuDE:
   título, cabecera emisor + timbrado/vigencia + Nº EST-PE-NRO, caja de receptor,
   tabla de ítems (`Cant. \| Descripción \| Precio Unitario \| Desc. \| Exentas
   \| IVA 5% \| IVA 10%`), subtotales, total a pagar (en letras + número),
   liquidación de IVA y leyenda legal.

**APEX:** `apex-work/f100/application/pages/page_00096.sql` — CSS KuDE + región
`RETURN FN_KUDE_FACTURA_HTML(:P96_ID_COMPROBANTE)`. Par `delete_00096.sql` e
import efímero `install_f12_pages.sql`.

### F13 — Recibo (P119) · `db/F13_kude_recibo.sql`

Script idempotente. Contiene:

- **`FN_KUDE_RECIBO_HTML(p_id_recibo)`** — mismo estilo visual que la factura,
  titulado **"Recibo de Dinero"**. Lee de `V_RECIBOS_COBRO` +
  `DETALLE_MOVIMIENTO_CAJA`; reusa `FN_GET_PARAMETRO` y `FN_NUMERO_A_LETRAS` de
  F12. Incluye la línea "Cobro de cuota N° X de la cuenta corriente #Y (factura
  origen N° …)" y el detalle `Método de Pago \| Monto \| Nro. Referencia`.

**APEX:** `apex-work/f100/application/pages/page_00119.sql` — CSS KuDE + región
`RETURN FN_KUDE_RECIBO_HTML(:P119_ID_RECIBO)`. Reusa `delete_00119.sql`; import
efímero `install_f13_pages.sql`.

### Origen del `Nro. Referencia` (recibo)

Lo **carga manualmente el cajero en P100** ("Cobro de Cuotas") al cobrar, y solo
cuando el medio de pago **no es efectivo** (item `P100_NRO_REFERENCIA`, visible
por DA "Visibilidad Nro Referencia" cuando `P100_ID_METODO_PAGO != '1'`). En el
submit se pasa a `FN_COBRAR_CUOTA(p_nro_ref => :P100_NRO_REFERENCIA)`
(`db/F9_cobros.sql`), que lo persiste en `DETALLE_MOVIMIENTO_CAJA.NRO_REFERENCIA`.
P119 solo lo lee de vuelta (efectivo → queda NULL → muestra `-`).

---

## 5. Archivos

| Archivo | Acción |
|---|---|
| `db/F12_kude_factura.sql` | nuevo — params emisor + `FN_NUMERO_A_LETRAS` + `FN_KUDE_FACTURA_HTML` |
| `db/F13_kude_recibo.sql` | nuevo — `FN_KUDE_RECIBO_HTML` |
| `apex-work/f100/application/pages/page_00096.sql` (+ `delete_00096.sql`) | P96 al layout KuDE |
| `apex-work/f100/application/pages/page_00119.sql` | P119 con estilo KuDE |
| `apex-work/f100/install_f12_pages.sql` / `install_f13_pages.sql` | imports efímeros (no pisan `install_page.sql`) |
| `CLAUDE.md`, `PLAN_FACTURACION.md` | notas (F9.G/F9.F resueltas; pitfalls) |

**Orden de aplicación:** aplicar `db/F12_*.sql` y `db/F13_*.sql` (las páginas
invocan sus funciones) → importar P96/P119 con los `install_f1X_pages.sql`.

---

## 6. Verificación

- **BD:** cada script trae bloque de verificación (funciones VALID + smoke test
  `FN_..._HTML(<id real>)` genera HTML). Confirmado OK.
- **`FN_NUMERO_A_LETRAS`:** casos 0, 100, 17850, 1.000.000, 2.220.000, 1.234.567.
- **Browser (PO, 2026-06-14):** P96 y P119 renderizan correctamente, incl. impresión.
  Pendiente menor: probar un cobro con transferencia para ver el Nro. Referencia poblado.

---

## 7. Fuera de alcance

- CDC real, firma digital XAdES, generación/envío de XML a SIFEN, QR con CSC →
  requieren integración real con la SET (proyecto aparte).
- P6 (presupuesto): no se tocó.
- Cambios en el flujo/numeración de facturación (P67) y en triggers.

# Plan de implementación — Nota de Crédito Electrónica (F14)

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace:** `WKSP_WORKPLACE` · **Conexión:** `tesis_db`
**Estado del plan:** ✅ implementado y cerrado (aprobado por el PO 2026-06-17,
cierre 2026-06-21). Backend `db/F14_nota_credito.sql` aplicado + P124–P127 capturadas
+ link en P66 + entry de menú P124. Capa APEX verificada (menú confirmado 2026-06-21).

> Plan separado. Continúa la línea fiscal de `PLAN_ANULACION_FACTURAS.md`:
> aquel cubre el **Evento de Cancelación** SIFEN (ventana de 48 h, F11). Este
> cubre la **Nota de Crédito Electrónica (NCE)**, que es el camino válido para
> revertir/ajustar una factura **fuera** de esas 48 h, o para devoluciones y
> descuentos parciales en general.

---

## 1. Contexto

F11 cerró la anulación de facturas mediante el Evento de Cancelación SIFEN
(factura → `ESTADO='N'`, reversiones de stock/caja/CxC, dentro de 48 h). El
groundwork de la NC ya quedó sembrado en F11.2 (`db/F11_2_motivos_nc.sql`):
la tabla catálogo **`MOTIVOS_NOTA_CREDITO`** con los 8 códigos `iMotEmi` de
SIFEN. Esta feature construye el módulo completo de NC encima de ese catálogo.

**Diferencia conceptual central con F11:** una Nota de Crédito **NO anula la
factura** — la factura sigue siendo un documento válido emitido (`ESTADO='A'`).
La NC es un **documento electrónico nuevo y separado** (tipo SIFEN 5) que
*credita* total o parcialmente a la factura referenciada. Por eso la NC no
reusa el estado de la factura: se materializa como una fila propia en
`COMPROBANTES` con `TIPO_COMPROBANTE='NC'`.

---

## 2. Alineación SIFEN (Manual Técnico v150)

| Aspecto | Regla SIFEN | Cómo lo cubre SolSGE |
|---|---|---|
| **Tipo de DE** | NC = documento electrónico tipo **5** | `TIPO_COMPROBANTE='NC'` (ya en uso, hay datos legacy + talonario NC #21) |
| **Motivo (`iMotEmi`)** | Lista **codificada cerrada** de 8 motivos, obligatoria | FK `COMPROBANTES.COD_MOTIVO` → `MOTIVOS_NOTA_CREDITO` (a crear) |
| **Referencia al DTE asociado (`gCamDEAsoc`)** | Obligatoria: CDC (electrónico) o timbrado+estab+punto+número (impreso) | Sin integración SIFEN (sin CDC) → caso "documento asociado impreso". Vínculo autoritativo: **`ID_COMPROBANTE_ORIGEN`** (FK por ID, a crear). Timbrado/estab/punto/número/fecha del documento asociado se **derivan por join** a la factura origen. (`ID_FAC_ORIGEN` string queda legacy.) |
| **Numeración** | Talonario/timbrado **propio**, independiente de la factura | Talonario NC #21 ya existe; `FN_OBTENER_COMPROBANTE(talonario)` reserva número atómicamente (reusable) |
| **Importes** | Subtotales por tasa (exenta/5/10) + IVA 5/10 + total | `DETALLE_COMPROBANTE` + `TOTAL_IVA_5/10` (misma estructura que factura) |
| **Efecto fiscal** | Crédito que revierte total/parcial al DTE original; el original **sigue válido** | NC es fila propia; la factura queda `ESTADO='A'` |
| **Plazo** | La NC **no** tiene la ventana de 48 h del evento de cancelación | Permitida sin importar plazo; si la factura está aún dentro de 48 h, la UI **sugiere** usar Anulación (no bloquea) |

---

## 3. Decisiones tomadas (con el PO, 2026-06-15)

| # | Decisión |
|---|----------|
| 1 | **Alcance total y parcial, modelo SIFEN por ítem.** La NC puede acreditar el 100 % de la factura, o por línea con **cantidad Y precio a acreditar** editables (default = precio factura, tope = precio factura). Cubre los 3 casos SIFEN: devolución (precio original), ajuste de precio (precio = diferencia por unidad), descuento. El total se calcula de `Σ(cantidad × precio_a_acreditar)+IVA` (SIFEN exige cantidad y precio unitario obligatorios por ítem; no hay descuento global sin ítems). **Decisión 2026-06-17 tras feedback del PO.** |
| 2 | **Workflow con aprobación (4 ojos), patrón F11.** El usuario `SOLICITA` → queda solicitud pendiente; un aprobador `APRUEBA` (se materializa la NC + efectos) o `RECHAZA`. |
| 3 | **La solicitud NO vive en `COMPROBANTES`.** Una NC pendiente quemaría un número de talonario que se perdería si se rechaza. Se usa una **tabla de staging** (`SOLICITUDES_NOTA_CREDITO` + detalle); el número NC se reserva **recién al aprobar**. |
| 4 | **Caja (contado): EGRESO en la caja abierta del aprobador** (espejo F11). La caja original casi siempre está cerrada (NC ocurre fuera de 48 h); postear a una caja cerrada rompe el arqueo congelado. El reembolso sale del cajón de hoy → el EGRESO pertenece a la caja/día del aprobador. Caja original intacta. Requiere caja abierta al aprobar. |
| 5 | **Crédito: la NC reconcilia `CUENTAS_COBRAR` + cuotas** (no toca caja: el dinero nunca entró). Se mantiene el invariante del sistema **`SALDO = Σ MONTO_CUOTA de cuotas PENDIENTE/VENCIDA`**: no basta con bajar `SALDO`, hay que aplicar el crédito contra las cuotas (ver §5.1 Paso 7). Total → toda la CxC y sus cuotas pendientes a `ANULADA`, `SALDO=0`; parcial → absorber el monto NC desde la última cuota hacia la primera (anulando completas y reduciendo la cuota límite). |
| 6 | **Stock condicional según motivo.** Devolución (motivos 1 y 2) → `MOVIMIENTOS_STOCK TIPO='ENTRADA'`. Descuento/Bonificación/Ajuste de precio/Recuperos (3–8) → **no** mueve stock. |
| 7 | **La factura origen queda `ESTADO='A'`.** La NC no la anula. |
| 8 | **`FORMA_PAGO` de la NC ≠ '1'.** Se setea NULL/sentinela para no disparar `TRG_INS_CUENTAS_COBRAR` (que crearía una CxC fantasma para la NC). |
| 9 | **Aprobador = cualquier usuario con acceso a la página de aprobación** (auth estándar APEX, sin nuevo modelo de roles), igual que F11/P121. |

---

## 4. Estado actual relevado (BD, 2026-06-15)

### 4.1 Tablas y datos
- `COMPROBANTES`: `TIPO_COMPROBANTE CHAR(2)`, `ID_FAC_ORIGEN VARCHAR2(100)` (ya
  guarda el nro impreso de la factura origen en las NC legacy), columnas de
  totales por tasa, columnas de auditoría de F11. **No** tiene `COD_MOTIVO` ni
  referencia por ID a la factura origen.
- **NC legacy:** 3 filas `TIPO_COMPROBANTE='NC'` (IDs 2, 41, 42), todas
  `ESTADO='A'`, 1 línea c/u, total idéntico (3.312.144) → datos de prueba/seed
  inertes. Una quedó con `FORMA_PAGO='1'` (confirma el riesgo de la decisión #8).
- **Talonario NC #21:** timbrado `987654321`, estab/punto `001-001`,
  `NRO_ACTUAL=4`, `NRO_FINAL=100`, `ACTIVO='S'`, `ID_CAJA_CONF=1`.
- `MOTIVOS_NOTA_CREDITO`: 8 motivos activos (F11.2). Sin FK entrante todavía.

### 4.2 Triggers (clave para el diseño)
Los triggers de venta **ya discriminan por tipo**, así que insertar una NC no
dispara efectos automáticos no deseados:
- `TRG_MOV_STOCK_DETALLE` (AFTER INSERT `DETALLE_COMPROBANTE`): descuenta stock
  **solo si `ESTADO='A' AND TIPO_COMPROBANTE='FA'`** → para NC es no-op. El
  retorno de stock se hace **explícito** en la procedure.
- `TRG_INS_CUENTAS_COBRAR` (AFTER INSERT `COMPROBANTES`): crea CxC **solo si
  `FORMA_PAGO='1'`** → la NC usa otro `FORMA_PAGO` (decisión #8).
- `TRG_FACTURA_ORDEN` (AFTER INSERT `COMPROBANTES`): actúa **solo si
  `ID_ORDEN_VENTA NOT NULL`** → la NC deja `ID_ORDEN_VENTA` en NULL.
- `TRG_COMPROBANTE_FECHA_HORA` (F11): setea `FECHA_HORA_EMISION` server-side
  (también aplicará a la NC, sin problema).

### 4.3 Reutilizables
- `FN_OBTENER_COMPROBANTE(p_id_talonario)` — reserva atómica de número.
- `FN_CAJA_ABIERTA_USUARIO(p_usuario)` — caja abierta del aprobador (para EGRESO).
- `FN_GET_PARAMETRO`, `FN_NUMERO_A_LETRAS` — para el KuDE.
- `FN_KUDE_FACTURA_HTML` como molde del KuDE NC. **Ojo:** hoy figura `INVALID`
  en la BD (sin errores reales en `all_errors` → solo dependencia obsoleta,
  revalida con `ALTER ... COMPILE`). Conviene recompilarla en el Paso 0.

---

## 5. Diseño

### 5.1 Modelo de datos — `db/F14_nota_credito.sql` (idempotente)

**Paso 0 — ✅ HECHO (2026-06-15).** `FN_KUDE_FACTURA_HTML` y `FN_KUDE_RECIBO_HTML`
estaban INVALID por metadata obsoleta (F11 alteró `COMPROBANTES`); las 12
dependencias estaban todas VALID. Recompiladas con `ALTER FUNCTION ... COMPILE`
→ ambas `VALID`. No requirió cambios de código.

**Paso 1 — Columnas nuevas en `COMPROBANTES`** (nullable; solo las llena la NC):
```sql
COD_MOTIVO            NUMBER(2)   -- FK MOTIVOS_NOTA_CREDITO(COD_MOTIVO)
ID_COMPROBANTE_ORIGEN NUMBER      -- FK COMPROBANTES(ID_COMPROBANTE) (la factura)
```
> **¿Por qué un FK nuevo si ya existe `ID_FAC_ORIGEN`?** `ID_FAC_ORIGEN` es un
> `VARCHAR2(100)` con el **número impreso** (`001-001-0000007`). No sirve como
> clave de join confiable: `NRO_COMPROBANTE` **no tiene UNIQUE** (verificado:
> 20/20 distintos hoy, pero sin constraint), el formato **no incluye timbrado** y
> la numeración es **por talonario** (FA y NC comparten serie `001-001-…`) → el
> mismo string puede recurrir entre tipos/timbrados. Como la reversión de
> CxC/stock/caja depende de ubicar **exactamente** la factura, y P125 ya entra con
> el ID, se persiste el ID como **FK real**. El número impreso para el KuDE se
> **deriva por join** a la factura origen (siempre consistente con el row real);
> `ID_FAC_ORIGEN` **no se puebla** en las NC nuevas (queda legacy), evitando
> duplicar el dato.
- FK `FK_COMP_MOTIVO_NC` y `FK_COMP_ORIGEN_NC`.
**Paso 1b — Limpieza de NC legacy (con permiso del PO, 2026-06-17).** Las 3 NC
de prueba (IDs 2, 41, 42) son datos malformados: atadas a `ID_ORDEN_VENTA`
(82/6/82), totales idénticos, origen no rastreable (ID 41 sin `ID_FAC_ORIGEN`,
ID 2 auto-referenciada). Verificado: solo 1 línea `DETALLE_COMPROBANTE` c/u,
**sin** hijos en `CUENTAS_COBRAR` ni `MOVIMIENTOS_CAJA`. Se eliminan:
```sql
DELETE FROM DETALLE_COMPROBANTE WHERE ID_COMPROBANTE IN
  (SELECT ID_COMPROBANTE FROM COMPROBANTES
    WHERE TIPO_COMPROBANTE='NC' AND ID_ORDEN_VENTA IS NOT NULL);
DELETE FROM COMPROBANTES WHERE TIPO_COMPROBANTE='NC' AND ID_ORDEN_VENTA IS NOT NULL;
```
El predicado `ID_ORDEN_VENTA IS NOT NULL` hace el DELETE **idempotente y seguro**:
las NC del nuevo flujo nacen con `ID_ORDEN_VENTA` NULL (decisión #8), por lo que
re-correr el script nunca toca una NC real. El talonario #21 queda con
`NRO_ACTUAL=4` (números 2-4 quemados, coherente con la filosofía de F11).

- `CK_NC_MOTIVO`: `(TIPO_COMPROBANTE='NC' AND COD_MOTIVO IS NOT NULL) OR
  (TIPO_COMPROBANTE<>'NC' AND COD_MOTIVO IS NULL)` → con la tabla NC ya vacía se
  crea **`ENABLE VALIDATE`** directo, **sin backfill**.
- **`ID_COMPROBANTE_ORIGEN` NO va en un CHECK validado**: la obligatoriedad de la
  referencia se **garantiza en `PRC_APROBAR_NOTA_CREDITO`** (siempre la setea para
  NC nuevas).

**Paso 2 — Tabla `SOLICITUDES_NOTA_CREDITO`** (staging de la solicitud pendiente):
```
ID_SOLICITUD_NC       NUMBER  PK (identity)
ID_COMPROBANTE_ORIGEN NUMBER  NOT NULL  FK COMPROBANTES   -- la factura
COD_MOTIVO            NUMBER(2) NOT NULL FK MOTIVOS_NOTA_CREDITO
TIPO_NC               CHAR(1) NOT NULL  CK ('T','P')      -- total/parcial
DEVUELVE_STOCK        CHAR(1) NOT NULL  CK ('S','N')      -- derivado del motivo
OBSERVACION           VARCHAR2(500)                       -- texto libre opcional
ESTADO                CHAR(1) NOT NULL  CK ('P','A','R')  -- pend/aprob/rechaz
USUARIO_SOLICITA      VARCHAR2(60) NOT NULL
FECHA_SOLICITUD       DATE NOT NULL
USUARIO_APRUEBA       VARCHAR2(60)
FECHA_RESOLUCION      DATE
MOTIVO_RECHAZO        VARCHAR2(500)
ID_NC_GENERADA        NUMBER  FK COMPROBANTES             -- la NC materializada
```

**Paso 3 — Tabla `SOLICITUD_NC_DETALLE`** (líneas a acreditar):
```
ID_SOL_NC_DET     NUMBER PK (identity)
ID_SOLICITUD_NC   NUMBER NOT NULL FK SOLICITUDES_NOTA_CREDITO (ON DELETE CASCADE)
ID_DETALLE_ORIGEN NUMBER NOT NULL FK DETALLE_COMPROBANTE      -- línea de la factura
ID_PRODUCTO       NUMBER NOT NULL
CANTIDAD          NUMBER NOT NULL                              -- ≤ acreditable
PRECIO_UNITARIO   NUMBER(12,2)
PORCENTAJE_IVA    NUMBER(5,2)
```
(En NC total la UI igual carga todas las líneas con la cantidad completa; así el
backend es uniforme total/parcial.)

**Paso 4 — `FN_CANT_ACREDITABLE(p_id_detalle_origen) RETURN NUMBER`**
Cantidad facturada en esa línea − Σ cantidades ya acreditadas por NC **aprobadas**
sobre esa misma línea. Es el tope para parcial y la guarda anti-doble-crédito.

**Paso 5 — `FN_NC_ELEGIBLE(p_id_factura) RETURN VARCHAR2`** (mensaje amigable / NULL)
- Factura inexistente / no es `TIPO='FA'` / `ESTADO='N'` (anulada) → bloquea.
- Ya acreditada 100 % por NC previas → bloquea.
- Dentro de 48 h (`HORAS_LIMITE_CANCELACION`) → **advertencia** (sugiere Anulación), no bloquea.

**Paso 6 — `PRC_SOLICITAR_NOTA_CREDITO(...)`** → crea cabecera+detalle en `ESTADO='P'`
- Valida elegibilidad (Paso 5) y, para parcial, que cada `CANTIDAD ≤ FN_CANT_ACREDITABLE`.
- Deriva `DEVUELVE_STOCK` del motivo (1,2 → 'S'; resto → 'N').
- No reserva número NC todavía.

**Paso 7 — `PRC_APROBAR_NOTA_CREDITO(p_id_solicitud, p_usuario)`** (atómica)
1. Lock solicitud `FOR UPDATE`; validar `ESTADO='P'`.
2. Re-validar cantidades acreditables (otra NC pudo aprobarse en el medio).
3. Reservar número: `FN_OBTENER_COMPROBANTE(<talonario NC>)`. **Talonario NC** =
   el talonario `ACTIVO`, `TIPO_COMPROBANTE='NC'` de la **oficina de la factura**
   (la NC pertenece al mismo establecimiento). Si no hay → error.
4. INSERT `COMPROBANTES`: `TIPO_COMPROBANTE='NC'`, `ESTADO='A'`,
   `ID_CLIENTE`/`ID_OFICINA`/`MONEDA`/`TIPO_CAMBIO` de la factura,
   `ID_ORDEN_VENTA=NULL`, `FORMA_PAGO=NULL` (decisión #8), `COD_MOTIVO`,
   `ID_COMPROBANTE_ORIGEN=<id factura>` (FK; `ID_FAC_ORIGEN` se deja NULL y el
   número impreso se deriva por join al renderizar), `NRO_COMPROBANTE=<nro
   reservado>`, `ID_TALONARIO=<talonario NC>`, totales por tasa recomputados de
   las líneas acreditadas.
5. INSERT `DETALLE_COMPROBANTE` por línea acreditada (no mueve stock: TIPO='NC').
6. **Stock** (si `DEVUELVE_STOCK='S'`): por línea, INSERT `MOVIMIENTOS_STOCK
   TIPO='ENTRADA'` (igual que `PRC_APROBAR_ANULACION`).
7. **Efecto financiero:**
   - Factura **crédito** (`FORMA_PAGO='1'`): reconciliar CxC **manteniendo el
     invariante** `SALDO = Σ MONTO_CUOTA WHERE ESTADO IN ('PENDIENTE','VENCIDA')`.
     - **Cap:** `monto_NC ≤ SALDO pendiente`. Si excede (porque ya se cobraron
       cuotas) → error `-209xx` "la NC excede el saldo pendiente; reverse los
       cobros primero" (deuda futura §8 R4).
     - **NC total:** todas las cuotas `PENDIENTE/VENCIDA → ANULADA`, `SALDO=0`,
       CxC `ESTADO='ANULADA'` (incluye el interés financiero: ya no hay venta).
     - **NC parcial:** recorrer las cuotas `PENDIENTE/VENCIDA` **de la última a
       la primera** (`NRO_CUOTA DESC`) absorbiendo `monto_NC`: si `monto_NC ≥
       MONTO_CUOTA` → cuota `ANULADA` y resto `-= MONTO_CUOTA`; si no → reducir
       `MONTO_CUOTA -= resto` y cortar. Luego `SALDO -= monto_NC`. Así la suma de
       cuotas vigentes vuelve a cuadrar con `SALDO`. (No se recalcula el interés
       sobre el monto acreditado — deuda menor §8.)
   - Factura **contado**: EGRESO en `FN_CAJA_ABIERTA_USUARIO(p_usuario)`; si no
     hay caja abierta → error claro. `ID_COMPROBANTE`=la NC, `OBSERVACION` cita
     NC + factura origen. (+ detalle espejo en `DETALLE_MOVIMIENTO_CAJA` si se
     quiere clonar formas de pago, como F11.)
8. UPDATE solicitud: `ESTADO='A'`, `USUARIO_APRUEBA`, `FECHA_RESOLUCION`,
   `ID_NC_GENERADA`. (Sin COMMIT en la procedure; APEX hace el commit — patrón F11.)

**Paso 8 — `PRC_RECHAZAR_NOTA_CREDITO(p_id_solicitud, p_motivo, p_usuario)`**
`ESTADO='R'` + motivo (≥10 chars). No materializa nada, no reserva número.

**Paso 9 — `FN_KUDE_NOTA_CREDITO_HTML(p_id_nc) RETURN CLOB`**
Modelado sobre `FN_KUDE_FACTURA_HTML`. Título "KuDE de Nota de Crédito
Electrónica", muestra **motivo** (`MOTIVOS_NOTA_CREDITO.DESCRIPCION`) y la
**referencia a la factura origen derivada por join** vía `ID_COMPROBANTE_ORIGEN`
(timbrado + estab + punto + `NRO_COMPROBANTE` + fecha de la factura). Mismos
subtotales por tasa, total en letras, leyenda "sin validez fiscal".

**Paso 10 — Vistas**
- `V_NOTAS_CREDITO`: NC emitidas (cabecera + cliente + motivo + factura origen) → listado/documento.
- `V_SOLICITUDES_NC`: solicitudes (pendientes + histórico) → listado de aprobación.

**Paso 11 — Verificación final** (counts de objetos, idempotencia, smoke del KuDE).

> Rango de error reservado para F14: **-20970 … -20989** (no colisiona con F11 -20930..-20952).

### 5.2 APEX — Páginas nuevas

| Página | Tipo | Rol |
|--------|------|-----|
| **P124** | IR | Solicitudes de NC (`V_SOLICITUDES_NC`). Filtros por estado. Link a P126 sobre pendientes. |
| **P125** | Modal/Form | **Solicitar NC.** Entra con `P125_ID_FACTURA` (desde P66). Display: datos factura. Editable: motivo (LOV `MOTIVOS_NOTA_CREDITO`), tipo total/parcial, IG de líneas (cantidad a acreditar ≤ acreditable) para parcial, observación. Aviso `FN_NC_ELEGIBLE` (BEFORE_HEADER). Botón SOLICITAR → `PRC_SOLICITAR_NOTA_CREDITO`. |
| **P126** | Modal | **Aprobar/Rechazar NC.** Detalle de la solicitud + líneas. APROBAR → `PRC_APROBAR_NOTA_CREDITO`; RECHAZAR (motivo ≥10) → `PRC_RECHAZAR_NOTA_CREDITO`. |
| **P127** | Normal | **Documento NC (KuDE).** `RETURN FN_KUDE_NOTA_CREDITO_HTML(:P127_ID_COMPROBANTE)` (mismo patrón que P96). |

### 5.3 APEX — Páginas modificadas

| Página | Cambio |
|--------|--------|
| **P66** (lista facturas) | Ícono "Emitir Nota de Crédito" visible cuando `ESTADO='A'` y la factura ya **no** es anulable (fuera de 48 h) → abre P125 con `P125_ID_FACTURA`. |
| **Menú** (`navigation_menu`) | Entry "Notas de Crédito" → P124 bajo "Ventas", con `security_pkg.can_access`. **Editar desde el Builder y re-exportar** (no `@@` en `install_component.sql`; ver riesgo R8 de F11). |

> **Regla del PO:** re-exportar cada página del Builder **antes** de editarla,
> y re-importar verificando. Aplica a P66/P124/P125/P126/P127.

---

## 6. Hitos

- [x] **Hito 0** — ✅ Saneo: `FN_KUDE_FACTURA_HTML` + `FN_KUDE_RECIBO_HTML` recompiladas a `VALID` (2026-06-15).
- [x] **Hito 1** — ✅ Backend `db/F14_nota_credito.sql` aplicado (2026-06-17): limpieza legacy + 2 columnas + 2 tablas staging + 5 funciones/procedures + KuDE NC + 2 vistas + verificación (16/16 OK). Smoke test end-to-end pasado (ver §10).
- [x] **Hito 2** — ✅ P125 Solicitar NC (2026-06-17): shell del PO + cableado Claude (LOV inline de motivos, IG editable `u` con `NATIVE_IG_DML`, items display + bloqueo/aviso, BEFORE_HEADER `FN_NC_ELEGIBLE`/`FN_NC_AVISO`, procesos crear-solicitud + volcado de líneas + close). Importado OK.
- [x] **Hito 3** — ✅ P124 (link a P126 vía detail link) + P126 (display items + validación motivo + procesos APROBAR/RECHAZAR + close) (2026-06-17). Importados OK.
- [x] **Hito 4** — ✅ P127 Documento NC (KuDE) (2026-06-17): clon de P96 llamando
  `FN_KUDE_NOTA_CREDITO_HTML`, importado quirúrgicamente, verificado en `apex_application_pages`.
- [x] **Hito 5** — ✅ Link "Emitir Nota de Crédito" en P66 (columna
  `NATIVE_LINK` en el IG → P125 con `P125_ID_FACTURA`, espejo del link de anulación),
  importado OK (2026-06-17). Entry de menú "Notas de Crédito" → P124 **presente**
  en `navigation_menu.sql` (línea 257, `current_for_pages='124'`) — verificado 2026-06-21.
- [x] **Hito 6** — ✅ Test end-to-end por navegador (PO, 2026-06-17..21): solicitar
  total/parcial (devolución/descuento/ajuste), aprobar contado y crédito, rechazar,
  imprimir NC. Ajuste a CxC verificado contablemente (factura 031). Varios bugs
  encontrados y corregidos en el camino (ver §10).
- [x] **Hito 7** — ✅ Cierre (2026-06-21): `CLAUDE.md` actualizado + commit `feat(F14)`.

---

## 7. Test plan

| Caso | Escenario | Esperado |
|------|-----------|----------|
| A | NC **total contado**, motivo Devolución (2) | NC emitida con nro NC; stock vuelve (ENTRADA); EGRESO en caja del aprobador; factura sigue `'A'` |
| B | NC **total crédito**, motivo Devolución | NC emitida; stock vuelve; CxC y cuotas pendientes → `ANULADA`; sin movimiento de caja |
| C | NC **parcial contado**, motivo Descuento (3) | NC por las líneas/cantidades elegidas; **sin** movimiento de stock; EGRESO parcial en caja del aprobador |
| D | NC **parcial crédito**, motivo Ajuste de precio (8) | NC parcial; sin stock; `CUENTAS_COBRAR.SALDO` baja por el monto NC |
| E | **Rechazo** | Solicitud `ESTADO='R'`, sin NC, sin número quemado, sin efectos |
| F | **Doble acreditación** (NC que excede lo acreditable) | Bloqueo por `FN_CANT_ACREDITABLE` (al solicitar y re-check al aprobar) |
| G | Contado **sin caja abierta** al aprobar | Error claro; nada se materializa |
| H | NC sobre factura **anulada** (`'N'`) o ya 100 % acreditada | `FN_NC_ELEGIBLE` bloquea en P125 |
| I | Factura **dentro de 48 h** | Aviso "usá Anulación" pero permite continuar |
| J | Idempotencia: correr `F14_nota_credito.sql` 2× | Sin error, verificación OK |

---

## 8. Riesgos / fuera de alcance (deuda futura)

| # | Tema | Tratamiento |
|---|------|-------------|
| R1 | EGRESO va a la caja del **aprobador**, no a la original (cerrada). | Decisión #4: contablemente correcto (el efectivo sale hoy). Caja original intacta; trazabilidad por `ID_COMPROBANTE`+`OBSERVACION`. |
| R2 | Doble acreditación parcial concurrente. | `FN_CANT_ACREDITABLE` + lock `FOR UPDATE` de la solicitud + re-check al aprobar. |
| R3 | `CK_NC_MOTIVO` vs 3 NC legacy con `COD_MOTIVO` NULL. | **Resuelto vía limpieza (Paso 1b):** las 3 NC legacy malformadas se eliminan (DELETE guardado por `ID_ORDEN_VENTA IS NOT NULL`) → CK `ENABLE VALIDATE` sin backfill. `ID_COMPROBANTE_ORIGEN` se garantiza por procedure. |
| R4 | NC en crédito **sobre cuotas ya cobradas** (monto NC excede saldo pendiente). | **Fuera de alcance MVP:** la NC se capa al saldo pendiente; acreditar lo ya cobrado exige reverso de cobro (pantalla futura, ya anotada como deuda en F11 §2 #2). Con el cap + la reconciliación de cuotas (§5.1 Paso 7), el invariante `SALDO = Σ cuotas vigentes` se mantiene siempre. |
| R7 | NC parcial sobre crédito: el **interés financiero** del monto acreditado no se recalcula. | Deuda menor: se reduce capital/cuotas pero la tasa de interés original no se re-amortiza. Aceptable para el MVP. |
| R5 | Número NC quemado si falla post-reserva. | Todo en una transacción sin commit intermedio → rollback libera `NRO_ACTUAL`. |
| R6 | Re-import del menú con `@@` falla (shared components no-upsert). | Editar menú en Builder + re-exportar manual (igual R8 de F11). |
| — | Integración SIFEN real (CDC/QR/envío del DTE). | Fuera de alcance: SolSGE es representación gráfica "sin validez fiscal" (igual que F12/F13). |

---

## 9. Aprobación

> Plan propuesto el 2026-06-15 y **aprobado por el PO el 2026-06-17**. Alcance:
> parcial+total, con aprobación, caja=espejo F11, stock condicional, FK como
> vínculo y limpieza de NC legacy. Implementación en curso.

## 10. Bitácora de implementación

### Hito 1 — Backend `db/F14_nota_credito.sql` (2026-06-17) ✅
Aplicado y verificado (16/16). Smoke test end-to-end (todo con `ROLLBACK`,
datos intactos): A total contado, B total crédito (anula CxC+cuotas), C parcial
crédito (invariante `SALDO=Σcuotas` se mantiene), E rechazo, G sin caja, cap de
pago parcial, KuDE NC. Todos OK.

**Ajustes al diseño durante la implementación (descubiertos en el smoke):**
1. **ORA-04091 (tabla mutante) en `PRC_SOLICITAR_NOTA_CREDITO`.** El auto-poblado
   de líneas para NC total se había escrito como `INSERT...SELECT` que llamaba a
   `FN_CANT_ACREDITABLE`, la cual lee `SOLICITUD_NC_DETALLE` — la misma tabla del
   INSERT → mutating. **Fix:** se reescribió como loop fila-por-fila (statements
   separados, sin mutating). Funcionalmente equivalente (la función solo cuenta
   solicitudes `ESTADO='A'`, no la 'P' en curso).
2. **Facturas crédito sin `CUENTAS_COBRAR`.** Datos de prueba (facturas 44/45)
   tienen `FORMA_PAGO='1'` pero nunca generaron CxC. `PRC_APROBAR_NOTA_CREDITO`
   reventaba con `NO_DATA_FOUND`. **Fix:** se envolvió el `SELECT ... INTO v_cxc`
   con manejo de `NO_DATA_FOUND` → error claro **`-20987`** ("factura crédito sin
   cuenta por cobrar asociada; no se puede emitir NC de crédito").

**Catálogo de errores F14 (rango -20970..-20989):** -20971 usuario solicitante;
-20972 tipo NC inválido; -20973 factura no elegible; -20974 motivo inexistente;
-20975 sin líneas; -20976 cantidad inválida; -20977 cantidad excede acreditable;
-20978 usuario aprobador; -20979 solicitud no pendiente; -20980 sin talonario NC;
-20981 total NC = 0; -20982 NC excede saldo pendiente (exige reverso de cobro);
-20983 sin caja abierta (contado); -20984/-20985/-20986 rechazo; -20987 factura
crédito sin CxC; **-20988 caja abierta no es del día de hoy (contado)**;
**-20989 precio a acreditar supera el precio facturado**; **-20990 precio nuevo
cargado sin Cant. a Acreditar en una línea** (aviso claro en vez del `-20975`
genérico cuando se hace un descuento sin poner la cantidad).

### Fix post-test UI (2026-06-17) — varios
- **`P125_AVISO` "no existe en la página":** causa real — APEX excluye un item
  display-only que solo se referencia a sí mismo en su condición de display; cuando
  `FN_NC_AVISO` devolvía NULL (factura fuera de 48h), el item se excluía y el
  BEFORE_HEADER `:P125_AVISO := ...` fallaba. (`P125_BLOQUEO` no falla porque el
  botón SOLICITAR lo referencia en su condición → queda registrado.) **Fix:** se
  eliminó el item `P125_AVISO` y luego se **re-agregó como región de "Contenido
  Dinámico PL/SQL"** (`FN_NC_AVISO`) que devuelve el HTML del aviso o NULL — las
  regiones no sufren el problema porque ningún proceso "setea" su valor, así que
  no necesitan estar registradas como ítems. El bloqueo (`P125_BLOQUEO` +
  `FN_NC_ELEGIBLE`) se mantiene.
- **Validación "al menos una línea con Cant. Acreditar > 0":** un descuento/ajuste
  donde el usuario solo cambia el precio sin poner cantidad generaba una solicitud
  vacía (la línea se inserta solo si cantidad>0) que recién fallaba al aprobar. Se
  agregó proceso AFTER_SUBMIT (seq 30, tras el IG DML) que corre
  `PRC_VALIDAR_SOLICITUD_NC` → si no hay líneas, `-20975` y APEX revierte el submit
  (no persiste solicitud vacía). Aplica a parcial; en total siempre hay líneas.
- **Estética P124 (2026-06-18):** Estado/Tipo/Forma de Pago/Devuelve Stock se
  muestran legibles **decodificando en el SQL del IR** (`CASE...`), NO con LOV de
  columna (ese patrón `p_lov_type/p_lov_source` es de **IG**, no de IR — falla en
  `create_worksheet_column` con PLS-00306). Se decodifica manteniendo los mismos
  nombres de columna para no romper el mapeo del worksheet. Se agregó
  `create_worksheet_rpt` (reporte primario) para **ocultar** columnas internas
  (COD_MOTIVO redundante, ID_SOLICITUD_NC, ID_COMPROBANTE_ORIGEN, ID_CLIENTE,
  ID_NC_GENERADA). P126 no se ve afectada (sus items leen la vista cruda, no el SQL del IR).
- **Proceso (recordatorio del PO):** SIEMPRE exportar la página fresca del Builder
  antes de editar/importar, para no pisar cambios hechos en el Builder. Adoptado.
- **Confirmado (probado):** varias solicitudes pendientes y varias NC aprobadas
  contra una misma factura están permitidas; la suma acreditada nunca supera lo
  facturado (cap por cantidad en IG DML + `PRC_VALIDAR` + `FN_NC_ELEGIBLE`). El
  modelo es credit-only y SIFEN-correcto: precio `≤` facturado (`-20989`), líneas
  solo de la factura origen, cantidad `≤` acreditable → no se puede aumentar precio
  ni agregar productos (eso sería Nota de Débito o nueva factura, fuera de alcance).
- **Grid editable de más + Editar/Guardar propios:** se ocultó la toolbar del IG
  (`p_show_toolbar=>false`) y se marcaron read-only todas las columnas salvo
  **Cant. Acreditar** y **Precio a Acreditar**. El guardado es solo vía SOLICITAR.
- **Modelo SIFEN por ítem (cantidad + precio):** el precio de la línea pasó a
  editable ("Precio a Acreditar", default = precio factura). El proceso IG guarda
  el precio elegido con tope `≤ precio factura` (UI) y `PRC_VALIDAR_SOLICITUD_NC`
  lo revalida en backend (`-20989`). El total ya se calculaba de
  `Σ(cantidad×precio)`, así que cubre devolución/descuento/ajuste sin más cambios.
  Smoke verificado: NC a mitad de precio → total = mitad; precio inflado → bloqueo.
  **Limitación conocida:** `FN_CANT_ACREDITABLE` es por **cantidad**; un ajuste de
  precio "consume" la cantidad de la línea (no se podría después devolver esas
  mismas unidades). Aceptable para el MVP; un tracking por monto sería el refinamiento.

### Modelo B "precio nuevo" (2026-06-18, decisión PO)
Validado contable/SIFEN: la NC documenta el **monto acreditado** (lo que sale de
caja / reduce la deuda). La NC por ítem lleva cantidad × precio, donde el precio
es el **importe acreditado por unidad**. Para descuentos/ajustes el usuario tipea
el **precio nuevo** y el sistema acredita la **diferencia**:
- **P125:** columna read-only **Precio Facturado** + editable **Precio Nuevo x
  Unidad** (default = precio factura). El IG DML **ramifica por motivo**:
  - **Devolución** (motivos 1,2): crédito = **valor completo** (`precio_facturado
    × cantidad`); el usuario solo carga la **cantidad**, no usa Precio Nuevo.
  - **Descuento/Ajuste/Bonificación/Recuperos** (3–8): crédito = `(facturado −
    precio_nuevo) × cantidad`; requiere cantidad **y** precio nuevo < facturado.
  - Guarda el crédito por unidad en `SOLICITUD_NC_DETALLE.PRECIO_UNITARIO`.
  - Errores claros: `-20989` (precio fuera de 0..facturado), `-20990` (precio
    nuevo sin cantidad, o descuento con precio nuevo ≥ facturado).
- **Backend sin cambios de cálculo:** `PRC_APROBAR` ya suma `cantidad × crédito`.
- **P126:** región de Contenido Dinámico PL/SQL con **desglose por línea**
  (producto, cant, precio facturado, precio nuevo, crédito x u., subtotal) +
  **Total NC a acreditar** → el aprobador ve el impacto antes de aprobar.
- **Pendiente menor:** total "en vivo" mientras se tipea en P125 (requiere un
  Dynamic Action JS en el IG). Hoy el total autoritativo se ve en P126 (paso de
  revisión). Se puede agregar el live-total a P125 si el PO lo pide.

### Fix post-test UI (2026-06-17) — validación de caja del día
Detectado por el PO probando en navegador: aprobó una NC contado y el EGRESO se
posteó a una caja **abierta pero de un día anterior** (caja 67, apertura 08/06).
El flujo de factura exige caja del día actual; la NC no lo validaba (heredó solo
el `FN_CAJA_ABIERTA_USUARIO` de F11, que devuelve cualquier caja abierta).
**Fix:** `PRC_APROBAR_NOTA_CREDITO` ahora valida `TRUNC(FEC_APERTURA)=TRUNC(SYSDATE)`
de la caja del aprobador → error `-20988` si es de otro día. (F11 tiene el mismo
gap latente; se puede alinear después si el PO quiere.)

### Enfoque capa APEX (decidido con el PO, 2026-06-17)
Modelo F11: **el PO arma los shells en el Builder, Claude cablea** (procesos,
SQL, LOVs, validaciones, links, condiciones) y captura al repo. Razón: hand-
authorear exports — sobre todo el Interactive Grid de P125 — a ciegas es frágil.

- **P127** (documento NC): por ser clon casi exacto de P96 (1 región Dynamic
  Content + 1 item hidden), lo generó Claude directamente. ✅ Hecho.

**Specs de shells que arma el PO en el Builder** (Claude cablea el resto):

- **P124 — "Notas de Crédito"** (página Normal): un **Interactive Report** con
  source `SELECT * FROM V_SOLICITUDES_NC`. (Claude agrega: link a P126 sobre
  `ESTADO='P'`, link "Ver NC" a P127 sobre emitidas, badges, filtros.)

- **P125 — "Solicitar Nota de Crédito"** (Modal Dialog):
  - Items: `P125_ID_FACTURA` (Hidden, param), `P125_COD_MOTIVO` (Select List),
    `P125_TIPO_NC` (Radio/Select), `P125_OBSERVACION` (Textarea).
  - Región "Datos de la factura" (Static Content).
  - Región "Líneas a acreditar": **Interactive Grid editable**, PK
    `ID_DETALLE_ORIGEN`, source:
    ```sql
    SELECT dc.ID_DETALLE AS ID_DETALLE_ORIGEN, dc.ID_PRODUCTO,
           pr.NOMBRE AS PRODUCTO, dc.CANTIDAD AS CANT_FACTURADA,
           WKSP_WORKPLACE.FN_CANT_ACREDITABLE(dc.ID_DETALLE) AS CANT_ACREDITABLE,
           dc.PRECIO_UNITARIO, dc.PORCENTAJE_IVA, 0 AS CANT_ACREDITAR
      FROM WKSP_WORKPLACE.DETALLE_COMPROBANTE dc
      JOIN WKSP_WORKPLACE.PRODUCTOS pr ON pr.ID_PRODUCTO = dc.ID_PRODUCTO
     WHERE dc.ID_COMPROBANTE = :P125_ID_FACTURA
    ```
  - Botón `SOLICITAR` (Submit).
  - (Claude cablea: LOV de motivos, static LOV T/P, columna editable
    `CANT_ACREDITAR` + resto read-only, condición del IG `TIPO_NC='P'`, items
    display-only de bloqueo/aviso vía `FN_NC_ELEGIBLE`/`FN_NC_AVISO`, procesos
    AFTER_SUBMIT que llaman `PRC_SOLICITAR_NOTA_CREDITO` y vuelcan las líneas del
    IG a `SOLICITUD_NC_DETALLE`, validaciones, close dialog.)

- **P126 — "Aprobar/Rechazar Nota de Crédito"** (Modal Dialog):
  - Items: `P126_ID_SOLICITUD` (Hidden, param), `P126_MOTIVO_RECHAZO` (Textarea).
  - Región "Detalle de la solicitud" (Static Content).
  - Botones `APROBAR` (Submit) y `RECHAZAR` (Submit).
  - (Claude cablea: items display-only del detalle, procesos que llaman
    `PRC_APROBAR_NOTA_CREDITO` / `PRC_RECHAZAR_NOTA_CREDITO` según botón,
    validación motivo rechazo ≥10, visibilidad del motivo, close dialog.)

### Hitos 2/3/4 — Páginas APEX cableadas (2026-06-17) ✅
PO armó shells en Builder; Claude exportó, cableó y re-importó quirúrgicamente
(sin tocar P120-123). Capturado a `apex-work` + `install_page.sql`.
- **P127** (doc NC): clon de P96 → `FN_KUDE_NOTA_CREDITO_HTML`.
- **P124** (lista IR sobre `V_SOLICITUDES_NC`): detail link → P126 pasando
  `P126_ID_SOLICITUD` (resolver pendientes); y la columna **NC_NRO es link → P127**
  (`P127_ID_COMPROBANTE = #ID_NC_GENERADA#`) para **imprimir/ver la NC emitida**.
  (Nota: `p_show_detail_link` es CHAR(1) → valor `'C'`, no `'LINK'`.)
- **P126** (aprobar/rechazar): display items desde `V_SOLICITUDES_NC`, validación
  motivo rechazo ≥10 (gated por `:REQUEST='RECHAZAR'`), procesos `PRC_APROBAR`/
  `PRC_RECHAZAR` por botón, close dialog.
- **P125** (solicitar): LOV de motivos pasado a **SQL inline** (no depender de
  named LOV); IG marcado editable (`p_is_editable=>true`, `p_edit_operations=>'u'`,
  `p_edit_mode=>true`); proceso BEFORE_HEADER setea bloqueo/aviso; botón SOLICITAR
  oculto si `P125_BLOQUEO` no es null; AFTER_SUBMIT: (10) `PRC_SOLICITAR_NOTA_CREDITO`
  → `P125_ID_SOLICITUD`, (20) `NATIVE_IG_DML` que vuelca las líneas con
  `CANT_ACREDITAR>0` a `SOLICITUD_NC_DETALLE` (re-fetch de precio/IVA desde la
  factura; guard `TIPO_NC='P'` y `≤ FN_CANT_ACREDITABLE`), (90) close dialog.

**Pendiente para cerrar la capa APEX:** — ✅ todo cerrado (verificado 2026-06-21)
- ~~**Hito 5:**~~ link "Emitir Nota de Crédito" en P66 + entry de menú
  "Notas de Crédito" → P124: **ambos hechos** (entry en `navigation_menu.sql` línea 257).
- ~~**Hito 6:**~~ test end-to-end por navegador: **hecho** (PO, 2026-06-17..21, ver §6 Hito 6).

## 11. Casos de uso (guía detallada)

### 11.0 Concepto base
Una **Nota de Crédito (NC)** es un documento electrónico (SIFEN tipo 5) que
**acredita** (reduce/revierte) total o parcialmente a una **factura** ya emitida.
Reglas que aplican a **todos** los casos:
- La factura origen **NO se anula**: sigue `ESTADO='A'` (sigue siendo un DTE
  válido). La NC es un documento **nuevo y separado** que la credita.
- El **total de la NC = lo que se le devuelve/acredita al cliente** = lo que sale
  de caja (contado) o reduce la deuda (crédito).
- Cada línea de la NC = `cantidad × precio_unitario` (el "precio" de la NC es el
  **importe acreditado por unidad**). El total = Σ líneas (IVA incluido, estilo PYG).
- **Tope:** nunca se acredita más de lo facturado (cantidad ≤ acreditable; precio
  nuevo entre 0 y el facturado). No se pueden **agregar productos** ni **aumentar**
  importes (eso sería Nota de Débito o una factura nueva — fuera de alcance).
- **Workflow:** el cajero **solicita** (P125) → queda pendiente → un aprobador
  **aprueba** (P126, se emite la NC y se aplican efectos) o **rechaza**.

### 11.1 Efectos al aprobar (comunes)
| Efecto | Cuándo | Detalle |
|--------|--------|---------|
| **Stock (ENTRADA)** | Solo motivos **Devolución** (cód. 1 y 2) | Reingresa al inventario la cantidad acreditada por línea. Descuento/ajuste/bonificación/recuperos → **no** tocan stock. |
| **Caja (EGRESO)** | Factura **contado** (`FORMA_PAGO≠'1'`) | Sale de la **caja abierta del aprobador, del día de hoy** (`-20988` si la caja no es de hoy / `-20983` si no hay caja). Monto = total NC. |
| **CxC** | Factura **crédito** (`FORMA_PAGO='1'`) | NC total → cuenta y cuotas pendientes a `ANULADA`, saldo 0. NC parcial → se absorbe el monto desde la última cuota hacia la primera, manteniendo `SALDO = Σ cuotas vigentes`. Tope = saldo pendiente (`-20982` si excede lo ya cobrado → primero reversar cobro). |

### 11.2 Caso A — Devolución TOTAL (contado)
**Situación:** el cliente devuelve toda la mercadería de una factura contado
fuera de las 48 h (ya no se puede Anular).
- **P125:** Motivo = *Devolución* (2); Tipo = **Total**. No se toca el grid.
- **Sistema:** acredita el 100 % de cada línea al precio facturado.
- **Efectos:** stock reingresa (todas las líneas); **EGRESO en caja** por el total
  de la factura; la factura queda `'A'`, la NC documenta la reversión.
- **Ejemplo:** factura contado de 468.000 → NC de 468.000 → EGRESO 468.000, stock
  vuelve completo.

### 11.3 Caso B — Devolución TOTAL (crédito)
- **P125:** Motivo = *Devolución* (2) o *Crédito incobrable* (5); Tipo = **Total**.
- **Efectos:** stock reingresa (si motivo Devolución); **CxC y cuotas → ANULADA,
  saldo 0**; sin movimiento de caja (el dinero nunca entró a caja).
- **Tope:** si ya se cobraron cuotas, la NC total se bloquea (`-20982`): hay que
  reversar el cobro antes (deuda futura). Si está impaga, anula todo.

### 11.4 Caso C — Devolución PARCIAL (devuelve algunas unidades)
- **P125:** Motivo = *Devolución* (1 o 2); Tipo = **Parcial**. En el grid, por
  cada línea a devolver: **solo Cant. a Acreditar** = unidades devueltas. **No
  hace falta tocar "Precio Nuevo"** — con motivo Devolución el sistema acredita el
  **valor completo** de esas unidades automáticamente.
- **Sistema:** crédito por línea = `precio_facturado × cantidad` (valor completo).
- **Efectos:** stock reingresa solo esas unidades; EGRESO (contado) o baja de CxC
  (crédito) por el monto parcial.
- **Ejemplo:** factura con 5 auriculares a 93.600. Devuelve 2 → Cant=2, Precio
  Nuevo=0 → NC = 2 × 93.600 = **187.200**.

### 11.5 Caso D — Descuento / Ajuste de precio (rebaja, NO devuelve)
**Situación:** se acuerda un descuento post-venta o se corrige un precio cobrado
de más; el cliente **conserva** la mercadería.
- **P125:** Motivo = *Descuento* (3) / *Ajuste de precio* (8) / *Bonificación* (4);
  Tipo = **Parcial**. En el grid: **Cant. a Acreditar** = unidades afectadas;
  **Precio Nuevo x Unidad** = el **precio corregido** (menor al facturado).
- **Sistema:** crédito por unidad = `precio_facturado − precio_nuevo`; NC = Σ
  `crédito × cantidad`. **No mueve stock** (no es devolución).
- **Efectos:** EGRESO (contado) o baja de CxC (crédito) por la diferencia.
- **Ejemplo (el del PO):** auriculares facturados a 93.600; precio nuevo 20.000 en
  5 unidades → crédito 73.600/u → **NC = 368.000**. Se le devuelven/acreditan
  368.000 (no 100.000; 100.000 sería si el "monto a acreditar" fuese 20.000/u, que
  **no** es el modelo elegido).

### 11.6 Caso E — Anulación fuera de plazo (NC total como "anulación")
Cuando pasaron las 48 h del Evento de Cancelación, **no** se anula la factura: se
emite una **NC total** que la revierte por completo (mismo efecto económico que
una anulación, pero como documento fiscal separado). Es el Caso A/B con cualquier
motivo aplicable. La factura queda `'A'`; la NC deja constancia de la reversión.

### 11.7 Caso F — Varias NC sobre una misma factura
Permitido y correcto: se pueden emitir **múltiples NC parciales** sobre una
factura (devoluciones/descuentos sucesivos) mientras la **suma acreditada no
supere lo facturado**. `FN_CANT_ACREDITABLE` lleva el saldo por cantidad; al
llegar al 100 % `FN_NC_ELEGIBLE` bloquea nuevas NC. (También se permiten varias
solicitudes *pendientes* a la vez; la aprobación re-valida y nunca deja
sobre-acreditar — decisión: se dejó abierto, sin límite de 1 pendiente.)

### 11.8 Casos de bloqueo (qué NO se puede y por qué)
| Intento | Resultado |
|---------|-----------|
| NC sobre factura inexistente / no-FA / ya anulada (`'N'`) | Bloqueo en P125 (`FN_NC_ELEGIBLE`) |
| Factura ya acreditada al 100 % | Bloqueo (`FN_NC_ELEGIBLE`) |
| Cant. a acreditar > disponible | `-20977` |
| Precio nuevo > precio facturado (o < 0) | `-20989` (no se puede acreditar de más / aumentar) |
| Solicitud parcial sin ninguna línea con cantidad > 0 | `-20975` (al solicitar) |
| NC contado sin caja abierta | `-20983` |
| NC contado con caja abierta de otro día | `-20988` |
| NC crédito que excede el saldo pendiente (cuotas ya cobradas) | `-20982` (reversar cobro primero) |
| Agregar un producto que no estaba en la factura | Imposible: las líneas salen solo de la factura origen |

### 11.9 Qué NO cubre una NC (otros documentos)
| Necesidad | Documento correcto |
|-----------|--------------------|
| Aumentar el importe / agregar cargos sobre una factura | **Nota de Débito** (SIFEN tipo 6) — *no implementada* |
| Vender productos nuevos / nueva operación | **Factura nueva** |
| Cancelar dentro de 48 h | **Evento de Cancelación** (F11) |

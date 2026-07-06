# Plan — Re-anclaje de TALONARIOS a CAJA_CONF (cumplimiento SET Paraguay)

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace / Schema:** `WKSP_WORKPLACE`
**Estado del plan:** ✅ implementado y verificado en `tesis_db` (2026-06-21).
Backend F10 + F10.1 aplicado: columna/FK `ID_CAJA_CONF`, índice único parcial
`UQ_TALONARIO_CAJA_TIPO_ACT` (VALID/UNIQUE), FK `FK_TALONARIO_CAJA_CONF`
(ENABLED/VALIDATED), trigger `TRG_TALONARIO_DERIVA_OFICINA`, `FN_CAJA_CONF_USUARIO`,
`V_TALONARIOS_DISPONIBLES` y `FN_COBRAR_CUOTA` todos VALID. Migración de datos
completa (3 talonarios re-anclados a su caja, sin `ID_CAJA_CONF` NULL).
**Tag esperado al cierre:** `f10-talonarios-set`.

> Plan separado de `PLAN_FACTURACION.md` (cerrado el 2026-06-08 con F9). Cubre
> únicamente la brecha regulatoria SET en `TALONARIOS`. No introduce nuevas
> pantallas: solo modelo de datos, una función helper, una vista y parches en
> P67/P100 ya existentes.

---

## 1. Motivación

La reglamentación de la **SET** (Subsecretaría de Estado de Tributación de
Paraguay) define el número de comprobante como:

```
ESTABLECIMIENTO - PUNTO_EXPEDICION - NUMERO
     001        -       001        - 0000001
```

`PUNTO_EXPEDICION` debe identificar **una sola caja física** (terminal). Hoy
`TALONARIOS.ID_OFICINA` (FK a `OFICINAS`) permite que dos cajeros distintos de
la misma oficina compartan el mismo talonario y, por ende, el mismo
`PUNTO_EXPEDICION` — violación de la norma cuando hay >1 `CAJA_CONF` por
oficina.

Cambio: re-anclar `TALONARIOS` a `CAJA_CONF`. La oficina se deriva por trigger
desde `CAJA_CONF.ID_OFICINA` (la columna `TALONARIOS.ID_OFICINA` se conserva
NOT NULL como derivada, para no romper consultas que la leen directo).

Los comprobantes históricos en `COMPROBANTES` no se tocan
(`NRO_COMPROBANTE` es inmutable y ya fue declarado a SET).

---

## 2. Estado actual relevado

### 2.1 Modelo

| Tabla | Columna clave | FK actual | FK objetivo |
|-------|---------------|-----------|-------------|
| `TALONARIOS` | `ID_OFICINA` | `OFICINAS` | (derivada) |
| `TALONARIOS` | `ID_CAJA_CONF` | — | `CAJA_CONF` (nueva) |

### 2.2 Objetos PL/SQL afectados

| Objeto | Archivo origen | Cambio |
|--------|----------------|--------|
| `V_TALONARIOS_DISPONIBLES` | `db/F8_facturacion.sql:250-259` | Agregar `ID_CAJA_CONF` al SELECT (conservar `ID_OFICINA`). |
| `FN_COBRAR_CUOTA` | `db/F9_cobros.sql:182-296` | Cambiar validación de paso 4 (línea 252) a comparar `ID_CAJA_CONF` en vez de `ID_OFICINA`. |
| `FN_CAJA_CONF_USUARIO` | **nuevo** en F10 | Análogo a `FN_CAJA_ABIERTA_USUARIO` y `FN_OFICINA_USUARIO_V2`. |
| `TRG_TALONARIO_DERIVA_OFICINA` | **nuevo** en F10 | BEFORE INSERT/UPDATE OF `ID_CAJA_CONF` que setea `ID_OFICINA`. |

### 2.3 Páginas APEX afectadas

| Página | Item / Proceso | Cambio |
|--------|---------------|--------|
| P51 (Talonarios — IG) | Columna `ID_OFICINA` (`page_00051.sql:67-98`) | Reemplazar por columna `ID_CAJA_CONF` con shared LOV `CAJA_CONF.DESCRIPCION`. |
| P53 (Talonarios — form) | Item `P53_ID_OFICINA` (`page_00053.sql:137-162`) | Reemplazar por `P53_ID_CAJA_CONF` con `p_source='ID_CAJA_CONF'`, prompt `'Caja'`, shared LOV `CAJA_CONF.DESCRIPCION`. El trigger `TRG_TALONARIO_DERIVA_OFICINA` setea `ID_OFICINA` en el INSERT. |
| P67 (Proceso Ventas) | LOV `P67_ID_TALONARIO` (`page_00067.sql:1349`) | Filtrar por `ID_CAJA_CONF = FN_CAJA_CONF_USUARIO(...)` en vez de `ID_OFICINA`. Quitar `p_lov_cascade_parent_items=>'P67_ID_OFICINA'`. |
| P100 (Cobro de Cuotas) | Source de `P100_ID_TALONARIO_RC` (`page_00100.sql:258`) | Filtrar por `ID_CAJA_CONF` derivado de la caja abierta. |
| P100 | Proceso BEFORE_HEADER "Validar talonario RC vigente" (`page_00100.sql:527`) | Idem. |

Sin impacto: P66 (grid de comprobantes — lee `ID_OFICINA` directo, sigue
funcionando con la columna derivada), P119 (recibo impreso — solo lee
`TIMBRADO`/fechas), `FN_OBTENER_COMPROBANTE` (opera por `ID_TALONARIO`),
`FN_CAJA_ABIERTA_USUARIO`, `FN_OFICINA_USUARIO_V2`.

Shared LOV reutilizada: `CAJA_CONF.DESCRIPCION` (LOV ID `12751376604199345`,
returns `ID_CAJA_CONF`, displays `DESCRIPCION`) — preexistente, no hay que
crearla.

---

## 3. Decisiones arquitectónicas

1. **`TALONARIOS.ID_OFICINA` queda como columna derivada NOT NULL** poblada
   por trigger desde `CAJA_CONF.ID_OFICINA`. Razón: no romper P66 ni queries
   ad-hoc/reportes que asumen la columna; la integridad SET se garantiza por
   la nueva FK + índice único parcial sobre `(ID_CAJA_CONF, TIPO_COMPROBANTE)
   WHERE ACTIVO='S'`.
2. **Migración separada en `db/F10_talonarios_set.sql`**, no apendizada a F8.
   F8/F9 ya están cerrados con tags; F10 es feature nuevo.
3. **Guard histórico**: si la migración reasignaría a otra caja un talonario
   que ya emitió comprobantes (`NRO_ACTUAL > NRO_INICIAL`), el script aborta
   salvo que el operador defina explícitamente `&bypass = 'SI'` al invocarlo.
   Razón: ese cambio implica que un `PUNTO_EXPEDICION` declarado a SET pasa a
   pertenecer a otra terminal — decisión que requiere validación humana.
4. **FK regulatoria** = `FK_TALONARIO_CAJA_CONF` (`ID_CAJA_CONF` → `CAJA_CONF`).
   **Índice único parcial** = `UQ_TALONARIO_CAJA_TIPO_ACT` sobre
   `(CASE WHEN ACTIVO='S' THEN ID_CAJA_CONF END, CASE WHEN ACTIVO='S' THEN TIPO_COMPROBANTE END)`.

---

## 4. Implementación (F10)

### F10.A — Preflight (`db/F10_preflight.sql`)

Script de inspección (solo `SELECT`s + `PROMPT`s) que el operador corre y
revisa **antes** de F10 principal. Reporta:

- Cantidad de `CAJA_CONF` por oficina.
- Talonarios actuales con `ID_OFICINA`, `ESTABLECIMIENTO`, `PUNTO_EXPEDICION`,
  `NRO_ACTUAL`, `NRO_FINAL`, `ACTIVO`.
- Comprobantes emitidos por talonario.

**Veredicto**:
- Todas las oficinas con exactamente 1 `CAJA_CONF` → migración automática.
- Alguna con >1 `CAJA_CONF` → el operador crea
  `TMP_MAP_TALONARIO_CAJA(ID_TALONARIO NUMBER PRIMARY KEY, ID_CAJA_CONF NUMBER)`
  con el mapeo manual antes de correr el script principal.

### F10.B — Script principal (`db/F10_talonarios_set.sql`)

Idempotente, secuencial, con verificación al final:

1. `ALTER TABLE TALONARIOS ADD ID_CAJA_CONF NUMBER` (si no existe).
2. **Populate** (en este orden):
   - Si existe `TMP_MAP_TALONARIO_CAJA` → usar ese mapeo.
   - Si no, intento auto: `UPDATE … SET ID_CAJA_CONF = (única CAJA_CONF de la oficina)`.
   - Si quedan NULL → `RAISE -20950` (operador debe crear el mapeo manual).
   - **Guard histórico**: si algún talonario afectado tiene
     `NRO_ACTUAL > NRO_INICIAL` y `&bypass != 'SI'` → `RAISE -20952`.
3. `ALTER TABLE TALONARIOS MODIFY ID_CAJA_CONF NOT NULL`.
4. `ADD CONSTRAINT FK_TALONARIO_CAJA_CONF FK (ID_CAJA_CONF) REFERENCES CAJA_CONF`.
5. `CREATE UNIQUE INDEX UQ_TALONARIO_CAJA_TIPO_ACT` (parcial via expresiones CASE).
6. `CREATE OR REPLACE TRIGGER TRG_TALONARIO_DERIVA_OFICINA` BEFORE INSERT/UPDATE
   OF `ID_CAJA_CONF` → setea `:NEW.ID_OFICINA`.
7. `CREATE OR REPLACE FUNCTION FN_CAJA_CONF_USUARIO(p_usuario)`.
8. `CREATE OR REPLACE VIEW V_TALONARIOS_DISPONIBLES` (agregar `ID_CAJA_CONF`).
9. `CREATE OR REPLACE FUNCTION FN_COBRAR_CUOTA` (cambia validación línea 252).
10. Bloque de verificación final (cuenta NULLs, FK, índice, función) →
    `RAISE -20951` si falla; `DBMS_OUTPUT 'F10 OK'` si todo está.

### F10.C — Páginas APEX

- `apex-work/f100/application/pages/page_00051.sql`: columna del IG cambia de
  `ID_OFICINA` a `ID_CAJA_CONF` (shared LOV `CAJA_CONF.DESCRIPCION`).
- `apex-work/f100/application/pages/page_00053.sql`: item `P53_ID_OFICINA` se
  reemplaza por `P53_ID_CAJA_CONF` (shared LOV `CAJA_CONF.DESCRIPCION`,
  `p_source='ID_CAJA_CONF'`). El trigger `TRG_TALONARIO_DERIVA_OFICINA` setea
  `ID_OFICINA` automáticamente al hacer INSERT.
- `apex-work/f100/application/pages/page_00067.sql`: LOV de
  `P67_ID_TALONARIO` filtra por `ID_CAJA_CONF = FN_CAJA_CONF_USUARIO(V('APP_USER'))`;
  quitar `p_lov_cascade_parent_items=>'P67_ID_OFICINA'`.
- `apex-work/f100/application/pages/page_00100.sql`: source query de
  `P100_ID_TALONARIO_RC` y validación BEFORE_HEADER pasan a filtrar por
  `ID_CAJA_CONF = FN_CAJA_CONF_USUARIO(:APP_USER)`.

### F10.D — Notas en CLAUDE.md

Pitfall corto que advierte: `TALONARIOS.ID_OFICINA` es **derivado por trigger**
desde `CAJA_CONF.ID_OFICINA` — no setear a mano en INSERT/UPDATE, la FK
regulatoria es `ID_CAJA_CONF`.

---

## 5. Orden de aplicación

1. Backup: exportar DDL de `FN_COBRAR_CUOTA` y `V_TALONARIOS_DISPONIBLES`
   actuales (para rollback).
2. `@db/F10_preflight.sql` — revisar resultados.
3. (Si aplica) Crear `TMP_MAP_TALONARIO_CAJA` con el mapeo manual.
4. (Si aplica) `DEFINE bypass='SI'` para autorizar reasignación de talonarios
   con historial emitido.
5. `@db/F10_talonarios_set.sql`.
6. Exportar P51, P53, P67, P100 a `apex-work/` (LIVE puede tener drift
   respecto a `apex-learn/`; reconciliar antes de re-aplicar los parches).
7. Importar páginas vía `apex-work/install_f10_pages.sql` (efímero, solo P51,
   P53, P67, P100 — `install_page.sql` queda intacto y NO se usa aquí para
   evitar pisar drift en otras páginas no auditadas).
8. Verificar en browser los golden paths (sección 6).
9. Commit: `feat(F10): TALONARIOS por CAJA_CONF (cumplimiento SET)`.
10. Tag: `f10-talonarios-set`.
11. (Opcional) `DROP TABLE TMP_MAP_TALONARIO_CAJA`.

---

## 6. Verificación end-to-end

- **DDL**: verificación interna del script (paso 10).
- **Datos**:
  ```sql
  SELECT COUNT(*) FROM TALONARIOS t JOIN CAJA_CONF cc USING (ID_CAJA_CONF)
  WHERE t.ID_OFICINA <> cc.ID_OFICINA;
  -- esperado: 0
  ```
- **Browser FA (P67)**: login con cajero con caja abierta → P67 muestra el
  talonario FA de su `CAJA_CONF`; emitir factura; verificar `NRO_COMPROBANTE`.
- **Browser RC (P100)**: P95 → P100, cobrar una cuota → `FN_COBRAR_CUOTA` no
  falla con `-20917`; recibo emitido.
- **Browser admin Talonarios (P51 + P53)**: abrir P51, crear talonario nuevo
  desde el botón Create → P53 ofrece dropdown "Caja" (sin "Oficina"). Guardar
  → INSERT pasa, ID_OFICINA queda poblado por trigger, P51 muestra la nueva
  fila con la caja.
- **Negativo caja cerrada**: cerrar la caja del cajero → P67 no debe mostrar
  talonarios disponibles.
- **Negativo SET**: vía SQL, intentar
  `INSERT INTO TALONARIOS (..., ID_CAJA_CONF, TIPO_COMPROBANTE, ACTIVO) VALUES (..., <caja existente con FA activo>, 'FA', 'S')`
  → debe fallar por `UQ_TALONARIO_CAJA_TIPO_ACT`.

---

## 6.b F10.1 — ESTABLECIMIENTO derivado desde OFICINAS

Mini-feature que cierra una brecha pre-existente: hasta F10, el admin podía
asignar a mano el `ESTABLECIMIENTO` al crear un talonario, lo cual permite
que dos talonarios de la misma oficina declaren distinto código fiscal SET.
La SET exige que cada **local físico** tenga un único `ESTABLECIMIENTO`.

### Cambios DB (`db/F10_1_establecimiento.sql`)

1. `ALTER TABLE OFICINAS ADD ESTABLECIMIENTO_SET VARCHAR2(3)` (NULLABLE;
   se permite que oficinas no operativas fiscalmente no lo tengan cargado).
2. Populate auto: por cada oficina con talonarios, copiar el
   `ESTABLECIMIENTO` único. Si una oficina tiene talonarios con valores
   divergentes, abortar con `-20962` (incoherencia pre-existente que el
   operador debe resolver a mano).
3. `CREATE OR REPLACE TRIGGER TRG_TALONARIO_DERIVA_OFICINA` — cuerpo
   expandido: además de `ID_OFICINA`, deriva `ESTABLECIMIENTO` desde
   `OFICINAS.ESTABLECIMIENTO_SET`. Si `ESTABLECIMIENTO_SET` es NULL para la
   oficina del talonario, aborta con `-20961`. **Nombre del trigger se
   mantiene** por historicidad (aunque ahora deriva 2 cosas).

### Cambio APEX (`apex-work/f100/application/pages/page_00053.sql`)

- `P53_ESTABLECIMIENTO` pasa de `NATIVE_TEXT_FIELD` required a
  `NATIVE_DISPLAY_ONLY` no-required (prompt `'Establecimiento (derivado)'`).
  El admin ya no lo tipea; lo setea el trigger desde la oficina de la caja.

### Verificación

Smoke tests confirmados contra `tesis_db`:

- INSERT en TALONARIOS sin pasar `ESTABLECIMIENTO` → trigger deriva el valor
  correcto.
- INSERT cuando `OFICINAS.ESTABLECIMIENTO_SET` es NULL → falla con
  `-20961` y mensaje "OFICINAS.ESTABLECIMIENTO_SET no esta cargado para la
  oficina N. Cargarlo antes de crear talonarios para sus cajas."

### Pendiente operativo — ✅ RESUELTO (verificado 2026-06-21)

- ~~Para empezar a operar fiscalmente la **oficina 2 (Suc - Villarrica)**, el
  admin debe primero `UPDATE OFICINAS SET ESTABLECIMIENTO_SET='<codigo>'
  WHERE CODIGO_OFICINA=2`.~~ **Hecho:** la oficina 2 ya tiene
  `ESTABLECIMIENTO_SET='2'` cargado en `tesis_db` (oficina 1 = `'1'`).
  Villarrica está lista para emitir talonarios cuando se le cree una caja.

## 6.c F27 — PUNTO_EXPEDICION derivado desde CAJA_CONF (2026-07-06)

Cierra la última brecha SET de la misma familia que F10.1, pero para el **punto
de expedición**. Hasta F27, `TALONARIOS.PUNTO_EXPEDICION` se tipeaba a mano en
P53 → dos cajas de la misma oficina podían declarar el mismo punto, o una caja
tener talonarios con puntos distintos (viola que el punto identifique una única
terminal).

### Cambios DB (`db/F27_punto_expedicion_caja.sql`)

1. `ALTER TABLE CAJA_CONF ADD PUNTO_EXPEDICION VARCHAR2(3)` (nullable mientras la
   caja no opere fiscalmente).
2. Populate auto: por cada caja con talonarios, copiar su `PUNTO_EXPEDICION`
   único. Si una caja tiene talonarios con puntos divergentes, abortar `-20931`.
3. `CREATE UNIQUE INDEX UQ_CAJA_CONF_OFI_PUNTO` sobre `(ID_OFICINA,
   PUNTO_EXPEDICION)` (parcial vía CASE, solo filas con punto no NULL) → dos
   cajas de la misma oficina no pueden compartir punto de expedición.
4. `CREATE OR REPLACE TRIGGER TRG_TALONARIO_DERIVA_OFICINA` — cuerpo expandido:
   además de `ID_OFICINA`/`ESTABLECIMIENTO`, deriva `PUNTO_EXPEDICION` desde
   `CAJA_CONF.PUNTO_EXPEDICION`. Si es NULL para la caja, aborta `-20930`.
   **Nombre del trigger se mantiene** por historicidad (ahora deriva 3 cosas).
5. Bloque de verificación (col + índice + trigger + ningún talonario incoherente)
   → `-20932` si falla. Errores F27: `-20930..-20933`.

### Cambios APEX (`apex-work/f100/install_f27_pages.sql`)

- **P53**: `Punto Expedicion` pasa a `NATIVE_DISPLAY_ONLY` no-required (derivado,
  igual que Establecimiento). `Tipo Comprobante` y `Activo` pasan a select list
  con LOV estática (`STATIC:Factura;FA,Nota de Credito;NC,Recibo de Dinero;RC` y
  `STATIC:Si;S,No;N`). Nueva validación `VAL_TALONARIO_UNICO_CAJA_TIPO`
  (FUNC_BODY_RETURNING_ERR_TEXT) con mensaje amigable que respalda al índice
  `UQ_TALONARIO_CAJA_TIPO_ACT` (evita el ORA-00001 crudo y el bypass por
  mayúsculas al forzar valores fijos).
- **P51** (IG display-only): columnas `Tipo Comprobante` y `Activo` con LOV
  estática para mostrar el texto amigable.
- **P64** (Configuración de Cajas): nuevo item `P64_PUNTO_EXPEDICION` mapeado a la
  columna nueva — es donde el admin carga el punto de la caja.

### Pendiente operativo — ✅ RESUELTO (verificado 2026-07-06)

- ~~**Caja 2 (`ID_CAJA_CONF=21`, oficina 1)** aún tiene `PUNTO_EXPEDICION` NULL.~~
  **Hecho por el PO:** Caja 2 tiene `PUNTO_EXPEDICION='2'` cargado en P64. Se le
  creó su primer talonario (FA, `ID_TALONARIO=42`) y el trigger derivó
  `ESTABLECIMIENTO='1'` + `PUNTO_EXPEDICION='2'` correctamente → numera
  `001-002-XXXXXXX`. Caja 1 quedó con punto `'1'` (poblado desde su talonario
  histórico).

### Verificación (contra `tesis_db`, 2026-07-06)

- INSERT de talonario en caja sin punto cargado → `-20930`. ✔
- `UPDATE CAJA_CONF SET PUNTO_EXPEDICION='1' WHERE ID_CAJA_CONF=21` (colisión con
  Caja 1 en oficina 1) → `ORA-00001 (UQ_CAJA_CONF_OFI_PUNTO)`. ✔
- Metadata APEX: P53 tipo/activo select list + punto display-only + validación
  presente; P51 columnas con LOV STATIC; P64 con item punto. ✔

## 7. Rollback

En orden inverso:

1. `CREATE OR REPLACE FUNCTION FN_COBRAR_CUOTA …` (cuerpo original de `db/F9_cobros.sql:182-296`).
2. `CREATE OR REPLACE VIEW V_TALONARIOS_DISPONIBLES …` (cuerpo original de `db/F8_facturacion.sql:250-259`).
3. `git revert` de los commits APEX de P67/P100.
4. `DROP TRIGGER TRG_TALONARIO_DERIVA_OFICINA`.
5. `ALTER TABLE TALONARIOS DROP CONSTRAINT FK_TALONARIO_CAJA_CONF`.
6. `DROP INDEX UQ_TALONARIO_CAJA_TIPO_ACT`.
7. `ALTER TABLE TALONARIOS DROP COLUMN ID_CAJA_CONF`.
8. `DROP FUNCTION FN_CAJA_CONF_USUARIO`.

Los `COMPROBANTES` históricos no se ven afectados ni al aplicar ni al revertir.

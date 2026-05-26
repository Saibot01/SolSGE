# Plan de implementación — Módulo de Ventas (Presupuestos/Pedidos)

**Proyecto:** SolSGE — APEX 24.2 (App 100, alias `f100`)
**Workspace:** `WKSP_WORKPLACE`
**Schema de aplicación:** `WKSP_WORKPLACE`
**Estado del plan:** aprobado (2026-05-26) — en implementación.

---

## 1. Objetivo

Cerrar el cambio cosmético `Orden de Venta → Presupuesto/Pedido` ya iniciado y
agregar al módulo de ventas: caducidad parametrizable, validación de stock por
oficina sin exponer cantidades, ciclo completo de estados
(`PENDIENTE → APROBADO → FACTURADO / ANULADO / VENCIDO`), pantalla dedicada de
cambio de estado, reporte exclusivo de presupuestos anulados y precio de venta
calculado en línea.

Queda fuera de alcance: descuento manual o global (no lo pidió el profesor y
abre riesgos de validación contra costo).

---

## 2. Estado actual relevado

### 2.1 Tablas

| Tabla              | Rol                | Notas                                                                                                                                  |
| ------------------ | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------- |
| `ORDENES_VENTA`    | Cabecera           | `ID_ORDEN, ID_OFICINA, ID_PERSONA, FECHA_ORDEN (def SYSDATE), ESTADO (def 'PENDIENTE', sin CHECK), TOTAL, OBSERVACION`                 |
| `DETALLE_ORDEN`    | Líneas             | `ID_DETALLE, ID_ORDEN, ID_PRODUCTO, CANTIDAD, PRECIO_UNITARIO, TOTAL`                                                                  |
| `RESERVAS_PRODUCTO`| Reservas           | `ID_RESERVA, ID_PRODUCTO, ID_OFICINA, CANTIDAD_RESERVADA, FECHA_RESERVA, ESTADO ('VIGENTE','ANULADA'), OBSERVACION, ID_ORDEN_VENTA`    |
| `STOCK_PRODUCTO`   | Stock por oficina  | `ID_PRODUCTO, ID_OFICINA, CANTIDAD, STOCK_MAXIMO, STOCK_MINIMO`                                                                        |
| `PARAMETROS`       | Parámetros sistema | Tabla genérica con `TIPO_PARAMETRO, CLAVE, VALOR_NUMERICO, VALOR_TEXTO, ACTIVO`. Consultable por `FN_GET_PARAMETRO(clave, tipo)`.      |
| `COMPROBANTES`     | Facturas           | Tiene `ID_ORDEN_VENTA`. El trigger `TRG_FACTURA_ORDEN` mueve la orden a `FACTURADO` al insertar el comprobante.                        |

### 2.2 Triggers existentes

- `TRG_GENERAR_RESERVA_ORDEN` — AFTER INSERT en `DETALLE_ORDEN`. Inserta
  `RESERVAS_PRODUCTO (..., ESTADO='VIGENTE', ID_ORDEN_VENTA)`. **No filtra por
  estado de la orden:** una orden anulada igual genera reserva.
- `TRG_FACTURA_ORDEN` — AFTER INSERT en `COMPROBANTES`. Hace
  `UPDATE ORDENES_VENTA SET ESTADO='FACTURADO' WHERE ID_ORDEN=:NEW.ID_ORDEN_VENTA`.
  **No valida estado origen:** factura sin importar si está pendiente, anulada o
  vencida.

### 2.3 Funciones disponibles

| Función             | Uso                                                                                                            |
| ------------------- | -------------------------------------------------------------------------------------------------------------- |
| `FN_GET_PARAMETRO`  | Lee parámetro por clave. `FN_GET_PARAMETRO('CLAVE', 'NUMERICO'\|'TEXTO')`.                                     |
| `FN_PRECIO_VENTA`   | Precio venta = costo ponderado × (1 + margen%). Ya integrada en P54 (líneas 909 y 995 del export actual).      |
| `FN_COSTO_PONDERADO`| Costo promedio ponderado por ventana de tiempo (parámetro `COSTO_VENTANA_DIAS`).                               |

### 2.4 Páginas APEX involucradas

| Pag. | Nombre                | Title actual    | Rol                                            | Estado renombrado |
| ---- | --------------------- | --------------- | ---------------------------------------------- | ----------------- |
| 30   | Ventas                | Ventas          | Placeholder (solo breadcrumb)                  | sin tocar         |
| 52   | Orden de Venta        | **Presupuesto** | IR principal sobre `ORDENES_VENTA`             | parcial ✅⚠️       |
| 54   | Orden de Venta        | Orden de Venta  | Form + IG `DETALLE_ORDEN` (edición/alta)       | ❌                |
| 6    | Reporte Orden de Venta| Reporte Orden de Venta | Modal printable                           | ❌                |
| 58   | Reporte Orden         | Reporte Orden   | (otro reporte)                                 | revisar           |
| 66/67| Proceso Ventas        | Proceso Ventas  | Emite factura desde la orden                   | revisar           |

### 2.5 Datos heredados en `ORDENES_VENTA.ESTADO`

| Valor       | Filas | Observación                       |
| ----------- | ----- | --------------------------------- |
| `FACTURADO` | 13    | OK                                |
| `Pendiente` | 5     | Mayúsculas inconsistentes         |
| `NULL`      | 2     | A normalizar                      |

Sin valores `APROBADO`, `ANULADO`, `VENCIDO`.

---

## 3. Decisiones tomadas (respuestas del product owner)

| # | Decisión                                                                                                                                  |
| - | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 1 | Oficina del presupuesto = oficina del usuario logueado (resolver vía DA o función).                                                       |
| 2 | `P54_ID_OFICINA` es **read-only**.                                                                                                        |
| 3 | LOV de producto **no filtra** por oficina. Al seleccionar, validar disponibilidad y avisar al usuario si hay stock en otras oficinas.     |
| 4 | Validación de stock es **bloqueo** (no permite guardar la línea).                                                                          |
| 5 | El usuario que carga el presupuesto **no ve cantidades de stock**, solo en qué oficinas hay disponibilidad.                                |
| 6 | Las reservas vigentes **se consideran** al calcular disponibilidad.                                                                        |
| 7 | `APROBADO` es obligatorio. Solo presupuestos aprobados pueden facturarse.                                                                  |
| 8 | Descuento global queda **fuera de alcance** (no lo pidió el profesor, agrega complejidad sin valor en esta fase).                          |
| 9 | Presupuestos vencidos pasan a estado **`VENCIDO`** (distinto de `ANULADO`) para diferenciar anulación humana vs vencimiento automático.   |

---

## 4. Diseño por feature

### Feature 1 — Renombrado Orden de Venta → Presupuesto

**Estado:** ⚠️ parcial. Tablas se mantienen (cambio solo de UI).

**Cambios concretos:**

- **P52:**
  - `page_name` → `Presupuestos`
  - Regions `Orden de Venta` y `Orden de Ventas` (IR) → `Presupuestos`
  - Breadcrumb → `Presupuestos`
- **P54:**
  - `page_name`, `step_title`, region `Orden de Venta` → `Presupuesto`
  - Processes `Process form Orden de Venta` y `Initialize form Orden de Venta` → renombrar
  - Item `P54_ID_ORDEN` label `Id Orden` → `Nº Presupuesto`
- **P6 (modal printable):**
  - `<h1>ORDEN DE VENTA</h1>` → `<h1>PRESUPUESTO</h1>`
  - Nota interna “La validez de esta orden de venta es de 15 días” → usar
    `FN_GET_PARAMETRO('DIAS_VIGENCIA_PRESUPUESTO')` (ver Feature 2).
- **Menú** (`navigation_menu.sql`):
  - Eliminar/ocultar entrada `Ventas → P30` (página placeholder).
  - Mantener `Presupuesto → P52`, `Proceso Ventas → P66`.
- **`CLAUDE.md`:** agregar nota: “Tablas `ORDENES_VENTA`/`DETALLE_ORDEN` se
  conservan; el renombrado a *Presupuesto* es solo de UI”.

**Archivos a tocar en `apex-work/`:**

- `pages/page_00052.sql` (re-exportar tras retocar en APEX o editar in-place)
- `pages/page_00054.sql` (ya está en el árbol; editar antes de importar para que
  no revierta el cambio de título)
- `pages/page_00006.sql` (exportar)
- `shared_components/navigation/lists/navigation_menu.sql` (ya está)
- `install_page.sql` (agregar p52 y p6 con sus `delete_*`)

---

### Feature 2 — Caducidad parametrizable

**Estado:** ❌ no implementado.

**Cambios en BD:**

```sql
-- 1) Parámetro
INSERT INTO PARAMETROS
  (TIPO_PARAMETRO, CLAVE, VALOR_NUMERICO, DESCRIPCION, ACTIVO)
VALUES
  ('VENTA', 'DIAS_VIGENCIA_PRESUPUESTO', 15,
   'Días de validez de un presupuesto desde su fecha de creación', 'S');

-- 2) Columnas auditoría / vencimiento
ALTER TABLE ORDENES_VENTA ADD (
  FECHA_VENCIMIENTO   DATE,
  FECHA_APROBACION    DATE,
  USUARIO_APROBACION  VARCHAR2(60),
  FECHA_ANULACION     DATE,
  USUARIO_ANULACION   VARCHAR2(60),
  MOTIVO_ANULACION    VARCHAR2(400)
);

-- 3) Trigger BEFORE INSERT que setea fecha de vencimiento
CREATE OR REPLACE TRIGGER TRG_OV_FECHA_VENCIMIENTO
BEFORE INSERT ON ORDENES_VENTA
FOR EACH ROW
DECLARE
  v_dias NUMBER;
BEGIN
  IF :NEW.FECHA_VENCIMIENTO IS NULL THEN
    v_dias := TO_NUMBER(FN_GET_PARAMETRO('DIAS_VIGENCIA_PRESUPUESTO','NUMERICO'));
    :NEW.FECHA_VENCIMIENTO := NVL(:NEW.FECHA_ORDEN, TRUNC(SYSDATE)) + NVL(v_dias, 15);
  END IF;
END;
/

-- 4) Job diario de vencimiento
BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name        => 'JOB_VENCER_PRESUPUESTOS',
    job_type        => 'PLSQL_BLOCK',
    job_action      => q'[
      BEGIN
        UPDATE ORDENES_VENTA
           SET ESTADO = 'VENCIDO'
         WHERE ESTADO = 'PENDIENTE'
           AND FECHA_VENCIMIENTO < TRUNC(SYSDATE);
        UPDATE RESERVAS_PRODUCTO
           SET ESTADO = 'ANULADA'
         WHERE ESTADO = 'VIGENTE'
           AND ID_ORDEN_VENTA IN (
             SELECT ID_ORDEN FROM ORDENES_VENTA
              WHERE ESTADO = 'VENCIDO'
                AND FECHA_VENCIMIENTO < TRUNC(SYSDATE)
           );
        COMMIT;
      END;]',
    start_date      => SYSTIMESTAMP,
    repeat_interval => 'FREQ=DAILY;BYHOUR=2;BYMINUTE=0;BYSECOND=0',
    enabled         => TRUE
  );
END;
/
```

**Alcance del vencimiento:** solo aplica a `ESTADO = 'PENDIENTE'`. Aprobados,
facturados y ya anulados no se tocan.

**UI:**

- En el IR de P52 agregar columna `FECHA_VENCIMIENTO` con badge:
  - rojo: `FECHA_VENCIMIENTO < TRUNC(SYSDATE)`
  - amarillo: `FECHA_VENCIMIENTO BETWEEN TRUNC(SYSDATE) AND TRUNC(SYSDATE)+3`
  - normal: caso contrario

---

### Feature 3 — Disponibilidad de stock por oficina

**Estado:** ❌ no implementado.

**Reglas:**

- LOV de `ID_PRODUCTO` queda **sin tocar** (sigue mostrando todos los productos
  activos con margen vigente).
- `P54_ID_OFICINA` es read-only y se resuelve por el usuario logueado.
- Al seleccionar producto en la IG, DA → AJAX → mensaje:
  - **Disponible en tu oficina** (verde, deja avanzar).
  - **Sin disponibilidad en tu oficina. Hay stock en: *lista de oficinas***
    (rojo, bloquea la línea).
  - **Sin disponibilidad en ninguna oficina** (rojo, bloquea).
- El usuario nunca ve cantidades.

**Fórmula de disponibilidad (excluye la propia orden para permitir edición):**

```sql
CREATE OR REPLACE FUNCTION FN_HAY_STOCK (
  p_id_producto IN NUMBER,
  p_id_oficina  IN NUMBER,
  p_id_orden    IN NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS
  v_disp NUMBER;
BEGIN
  SELECT NVL(sp.CANTIDAD,0)
       - NVL((SELECT SUM(rp.CANTIDAD_RESERVADA)
                FROM RESERVAS_PRODUCTO rp
               WHERE rp.ID_PRODUCTO   = p_id_producto
                 AND rp.ID_OFICINA    = p_id_oficina
                 AND rp.ESTADO        = 'VIGENTE'
                 AND (p_id_orden IS NULL
                      OR rp.ID_ORDEN_VENTA <> p_id_orden)), 0)
    INTO v_disp
    FROM STOCK_PRODUCTO sp
   WHERE sp.ID_PRODUCTO = p_id_producto
     AND sp.ID_OFICINA  = p_id_oficina;
  RETURN CASE WHEN v_disp > 0 THEN 'S' ELSE 'N' END;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN 'N';
END;
/
```

**Oficinas alternativas (para el aviso, sin cantidades):**

```sql
CREATE OR REPLACE FUNCTION FN_OFICINAS_CON_STOCK (
  p_id_producto IN NUMBER,
  p_id_orden    IN NUMBER DEFAULT NULL
) RETURN VARCHAR2 IS
  v_lista VARCHAR2(4000);
BEGIN
  SELECT LISTAGG(o.DESCRIPCION, ', ') WITHIN GROUP (ORDER BY o.DESCRIPCION)
    INTO v_lista
    FROM STOCK_PRODUCTO sp
    JOIN OFICINAS o ON o.CODIGO_OFICINA = sp.ID_OFICINA
   WHERE sp.ID_PRODUCTO = p_id_producto
     AND sp.CANTIDAD
       - NVL((SELECT SUM(rp.CANTIDAD_RESERVADA)
                FROM RESERVAS_PRODUCTO rp
               WHERE rp.ID_PRODUCTO   = sp.ID_PRODUCTO
                 AND rp.ID_OFICINA    = sp.ID_OFICINA
                 AND rp.ESTADO        = 'VIGENTE'
                 AND (p_id_orden IS NULL
                      OR rp.ID_ORDEN_VENTA <> p_id_orden)), 0) > 0;
  RETURN v_lista;
END;
/
```

**Resolución de oficina del usuario:**

`EMPLEADOS` no tiene `ID_OFICINA`. Opciones:

- **A (recomendada):** usar la oficina de la caja abierta del usuario
  (`CAJAS.ID_OFICINA WHERE USU_APERTURA = :APP_USER AND ESTADO='A'`). Implica
  que el vendedor debe tener caja abierta para cargar presupuesto.
- **B:** agregar columna `ID_OFICINA` a `EMPLEADOS` y mantener manualmente.

Función auxiliar (alternativa A):

```sql
CREATE OR REPLACE FUNCTION FN_OFICINA_USUARIO (
  p_usuario IN VARCHAR2 DEFAULT NV('APP_USER')
) RETURN NUMBER IS
  v_id NUMBER;
BEGIN
  SELECT MAX(c.ID_OFICINA)
    INTO v_id
    FROM CAJAS c
   WHERE UPPER(c.USU_APERTURA) = UPPER(p_usuario)
     AND c.ESTADO = 'A';
  RETURN v_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN RETURN NULL;
END;
/
```

**Cambios en P54:**

- Item nuevo `P54_ID_OFICINA` (display only) — default
  `FN_OFICINA_USUARIO(:APP_USER)`.
- Items ocultos `P54_AVISO_STOCK_TEXTO`, `P54_AVISO_STOCK_NIVEL` (`OK`/`KO`).
- DA en IG `Detalle Ventas`, evento `Change` sobre `ID_PRODUCTO`:
  1. AJAX → PL/SQL que arma el mensaje usando `FN_HAY_STOCK` y
     `FN_OFICINAS_CON_STOCK`.
  2. Setea `P54_AVISO_STOCK_*` y muestra notificación APEX.
- Validación en submit (server-side): por cada línea, si
  `FN_HAY_STOCK(producto, P54_ID_OFICINA, P54_ID_ORDEN) = 'N'` → error
  bloqueante. Texto: `"Sin disponibilidad de <producto> en tu oficina. Hay stock en: <lista>"`.

---

### Feature 4 — Estados completos

**Estado:** ✅ completado (versionado en `db/F4_estados.sql` el 2026-05-26 — la
implementación ya estaba aplicada en la BD live antes de capturarse). Estados
soportados: `PENDIENTE`, `APROBADO`, `FACTURADO`, `ANULADO`, `VENCIDO`.

**Migración previa (imprescindible):**

```sql
UPDATE ORDENES_VENTA
   SET ESTADO = 'PENDIENTE'
 WHERE ESTADO IS NULL OR UPPER(ESTADO) = 'PENDIENTE';

UPDATE ORDENES_VENTA
   SET ESTADO = 'FACTURADO'
 WHERE UPPER(ESTADO) = 'FACTURADO';

COMMIT;
```

**Constraint:**

```sql
ALTER TABLE ORDENES_VENTA ADD CONSTRAINT CK_OV_ESTADO
  CHECK (ESTADO IN ('PENDIENTE','APROBADO','FACTURADO','ANULADO','VENCIDO'));
```

**Tabla de transiciones permitidas:**

| Desde \\ Hacia | PENDIENTE | APROBADO | FACTURADO | ANULADO | VENCIDO |
| -------------- | :-------: | :------: | :-------: | :-----: | :-----: |
| PENDIENTE      |     —     | ✅ manual | ❌         | ✅ manual| ✅ job   |
| APROBADO       |     ❌    |    —     | ✅ trigger | ✅ manual| ❌      |
| FACTURADO      |     ❌    |    ❌    |    —      |    ❌   |    ❌   |
| ANULADO        |     ❌    |    ❌    |    ❌     |    —    |    ❌   |
| VENCIDO        |     ❌    |    ❌    |    ❌     |    ❌   |    —    |

**Función guardiana:**

```sql
CREATE OR REPLACE FUNCTION FN_PUEDE_TRANSICION_OV (
  p_actual  IN VARCHAR2,
  p_destino IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
  RETURN CASE
    WHEN p_actual = 'PENDIENTE' AND p_destino IN ('APROBADO','ANULADO','VENCIDO') THEN 'S'
    WHEN p_actual = 'APROBADO'  AND p_destino IN ('FACTURADO','ANULADO')          THEN 'S'
    ELSE 'N'
  END;
END;
/
```

**Hardening de triggers existentes:**

- `TRG_FACTURA_ORDEN`: agregar validación previa:

  ```sql
  -- Antes del UPDATE, verificar estado actual
  SELECT ESTADO INTO v_estado_actual
    FROM ORDENES_VENTA
   WHERE ID_ORDEN = :NEW.ID_ORDEN_VENTA;
  IF v_estado_actual <> 'APROBADO' THEN
     RAISE_APPLICATION_ERROR(-20010,
       'Solo se pueden facturar presupuestos en estado APROBADO. Estado actual: '||v_estado_actual);
  END IF;
  ```

- `TRG_GENERAR_RESERVA_ORDEN`: solo crear reserva si la orden está en
  `PENDIENTE` o `APROBADO` (para futuro: edición de orden anulada no debe
  generar reservas zombi).

**Trigger nuevo `TRG_OV_LIBERA_RESERVA`:**

```sql
CREATE OR REPLACE TRIGGER TRG_OV_LIBERA_RESERVA
AFTER UPDATE OF ESTADO ON ORDENES_VENTA
FOR EACH ROW
WHEN (NEW.ESTADO IN ('ANULADO','VENCIDO') AND OLD.ESTADO IN ('PENDIENTE','APROBADO'))
BEGIN
  UPDATE RESERVAS_PRODUCTO
     SET ESTADO = 'ANULADA'
   WHERE ID_ORDEN_VENTA = :NEW.ID_ORDEN
     AND ESTADO = 'VIGENTE';
END;
/
```

---

### Feature 5 — Pantalla de cambio de estado

**Estado:** ✅ completado (2026-05-26 — `apex-work/f100/application/pages/page_00115.sql` + ajuste de P52). Pequeñas desviaciones vs. el spec original:
- **Sin item `P115_NUEVO_ESTADO` select.** El destino se infiere de `:REQUEST` (botón APROBAR → APROBADO, ANULAR → ANULADO). UX más limpia: el usuario no elige de un dropdown un destino al que el botón ya apunta.
- **Detalle como HTML generado por PL/SQL** (`NATIVE_DYNAMIC_CONTENT`), no IG. La app no usa Classic Reports y un IG read-only era overkill; el HTML con `htp.p` da una tabla simple con totales al pie.
- **Link en P52 como columna IR**, no como acción de fila. Aparece en ambos IRs (default y alternativo) con ícono `fa-exchange`.
- VENCIDO sigue siendo solo automático vía job F2 (no botón manual).

**Nueva página propuesta: P115 — “Cambio de Estado de Presupuesto”** (Modal Dialog).

**Estructura:**

- Items:
  - `P115_ID_ORDEN` (oculto, vía link desde P52)
  - `P115_ESTADO_ACTUAL` (display only)
  - `P115_NUEVO_ESTADO` (select, opciones dinámicas según estado actual usando
    `FN_PUEDE_TRANSICION_OV`)
  - `P115_MOTIVO` (textarea, required si `NUEVO_ESTADO='ANULADO'`)
- Regions:
  - **Cabecera**: read-only de `ORDENES_VENTA` + datos del cliente
  - **Detalle**: IG read-only de `DETALLE_ORDEN` con totales
- Botones:
  - `APROBAR` — visible si estado actual = `PENDIENTE`
  - `ANULAR` — visible si estado actual IN (`PENDIENTE`,`APROBADO`)
  - `CERRAR` — siempre
- Proceso PL/SQL `ProcesarCambioEstado`:
  1. Validar transición con `FN_PUEDE_TRANSICION_OV`.
  2. `UPDATE ORDENES_VENTA SET ESTADO=:P115_NUEVO_ESTADO,
     FECHA_APROBACION = CASE WHEN :P115_NUEVO_ESTADO='APROBADO' THEN SYSDATE END,
     USUARIO_APROBACION = CASE WHEN :P115_NUEVO_ESTADO='APROBADO' THEN :APP_USER END,
     FECHA_ANULACION = CASE WHEN :P115_NUEVO_ESTADO='ANULADO' THEN SYSDATE END,
     USUARIO_ANULACION = CASE WHEN :P115_NUEVO_ESTADO='ANULADO' THEN :APP_USER END,
     MOTIVO_ANULACION = CASE WHEN :P115_NUEVO_ESTADO='ANULADO' THEN :P115_MOTIVO END
     WHERE ID_ORDEN=:P115_ID_ORDEN;`
  3. `TRG_OV_LIBERA_RESERVA` se encarga de las reservas.
- Botón nuevo en P52 IR: columna “Acción” o ícono que abra la modal P115.

---

### Feature 6 — Reporte de presupuestos anulados (+ vencidos)

**Estado:** ❌ no implementado.

**Cambios:**

- IR principal de P52: filtro por defecto `WHERE ESTADO NOT IN ('ANULADO','VENCIDO')`.
  Implementación: modificar la consulta del IR o agregar filtro IR “Activos”
  como default.
- **Nueva página P116 — “Presupuestos Anulados y Vencidos”** (Normal):
  - IR sobre `ORDENES_VENTA` con `WHERE ESTADO IN ('ANULADO','VENCIDO')`.
  - Columnas: Nº, Fecha orden, Fecha vencimiento, Fecha anulación, Cliente
    (join `PERSONAS`), Oficina, Monto total, Estado, Usuario anulación,
    Motivo anulación.
  - Filtros IR por defecto: rango de fechas, estado, oficina.
- Entrada de menú “Anulados y Vencidos” anidada bajo “Presupuesto”.

---

### Feature 7 — Precio de venta

**Estado:** ✅ implementado. Sin cambios.

- `FN_PRECIO_VENTA(p_id_producto, p_categoria_cliente)` ya integrada en P54
  líneas 909 y 995.
- Autocompleta `P54_PRE_UNITARIO` y `PRECIO_UNITARIO` en la IG al elegir
  producto y categoría de cliente.

**Descuentos: fuera de alcance** (decisión del PO).

---

## 5. Dependencias y orden de implementación

```
[F4] Estados (migración + CHECK + triggers)
   ├── [F5] Pantalla de cambio de estado
   ├── [F6] Reporte anulados/vencidos + filtro principal
   └── [F2] Caducidad (necesita estado VENCIDO)
                                        │
[F1] Renombrado (independiente, en paralelo desde el día 1)

[F3] Stock por oficina (independiente)
        └── necesita FN_OFICINA_USUARIO; no comparte tocar P54 con F1 si se
            planifica bien (juntarlas en una sola pasada de export/edit de P54)
```

**Orden recomendado:**

1. **Feature 4 — Estados.** Fundacional. Migración + CHECK + ajuste de
   triggers + nueva función de transición + trigger libera reservas.
2. **Feature 1 — Renombrado.** Cosmético, barato. Aprovechar para dejar
   prolijos los textos antes de tocar P54 por features siguientes.
3. **Feature 3 — Stock por oficina.** Crear funciones auxiliares + ajustar P54
   (junto con F1, una sola pasada de edición/import de page_00054.sql).
4. **Feature 5 — Pantalla de cambio de estado.** Página nueva, link desde P52.
5. **Feature 6 — Reporte de anulados/vencidos.** Página nueva + ajuste IR P52
   + menú.
6. **Feature 2 — Caducidad.** Parámetro + columna + trigger fecha venc + job
   diario. Va al final porque depende del estado `VENCIDO` y del trigger
   liberador de reservas (F4).

---

## 6. Riesgos identificados

| # | Riesgo                                                                                                                                                                                                                                                | Mitigación                                                                                                                                          |
| - | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | `TRG_GENERAR_RESERVA_ORDEN` reserva sin importar estado de la orden — hoy puede dejar reservas zombi.                                                                                                                                                  | F4 incluye filtro por estado en el trigger + nuevo trigger liberador en cambio de estado.                                                           |
| 2 | Datos heredados (`NULL`, `Pendiente` camelcase) rompen el `CHECK`.                                                                                                                                                                                     | Script de migración antes del `ALTER TABLE ... ADD CHECK`. Validar `SELECT DISTINCT ESTADO` post-migración.                                          |
| 3 | `page_00054.sql` en `apex-work/` todavía tiene “Orden de Venta” — al importar revierte el title `Presupuesto` que ya está en P52.                                                                                                                       | Editar el export en `apex-work/` antes de importar (F1 + F3 en una sola pasada) o re-exportar primero desde la app live.                            |
| 4 | `TRG_FACTURA_ORDEN` actual permite facturar un presupuesto anulado/vencido.                                                                                                                                                                            | F4 endurece el trigger con `RAISE_APPLICATION_ERROR` si estado actual ≠ `APROBADO`.                                                                  |
| 5 | Resolución de oficina del usuario: `EMPLEADOS` no tiene `ID_OFICINA`.                                                                                                                                                                                  | Usar `CAJAS.ID_OFICINA` con caja abierta (alternativa A). Documentar la dependencia: sin caja abierta no se puede cargar presupuesto.                |
| 6 | El texto “validez de esta orden de venta es de 15 días” en P6 está hardcoded.                                                                                                                                                                          | Reemplazar por `FN_GET_PARAMETRO('DIAS_VIGENCIA_PRESUPUESTO')` cuando F2 esté listo.                                                                 |
| 7 | El job `JOB_VENCER_PRESUPUESTOS` corre como `WKSP_WORKPLACE` — confirmar permisos sobre `RESERVAS_PRODUCTO` y `ORDENES_VENTA`.                                                                                                                         | Validar `USER_SCHEDULER_JOBS` post-creación; testear ejecución manual con `DBMS_SCHEDULER.RUN_JOB`.                                                  |
| 8 | Performance: `FN_HAY_STOCK` se llama por línea en el AJAX del IG. Si el catálogo tiene muchos productos y el IG tiene muchas líneas, podría sumar latencia.                                                                                            | Calcular solo en evento `Change` sobre `ID_PRODUCTO`, no en cada render. Si hace falta, añadir índice `(ID_PRODUCTO, ID_OFICINA, ESTADO)` en RESERVAS_PRODUCTO. |

---

## 7. Checklist de entregables por feature

### F4 — Estados ✅
- [x] Migración de datos heredados (NULL/camelCase → `PENDIENTE`)
- [x] `ALTER TABLE ORDENES_VENTA ADD CONSTRAINT CK_OV_ESTADO`
- [x] Columnas auditoría: `FECHA_APROBACION`, `USUARIO_APROBACION`, `FECHA_ANULACION`, `USUARIO_ANULACION`, `MOTIVO_ANULACION`
- [x] Función `FN_PUEDE_TRANSICION_OV`
- [x] `TRG_FACTURA_ORDEN` endurecido (usa `FN_PUEDE_TRANSICION_OV`, hace `SELECT FOR UPDATE`, tolera `ID_ORDEN_VENTA IS NULL`)
- [x] `TRG_GENERAR_RESERVA_ORDEN` filtrado (sale early si estado ∉ `PENDIENTE`/`APROBADO`)
- [x] Trigger `TRG_OV_LIBERA_RESERVA`
- [x] Script versionado idempotente: `db/F4_estados.sql`

### F1 — Renombrado
- [ ] Edit `page_00052.sql`
- [ ] Edit `page_00054.sql` (ya en árbol)
- [ ] Export + edit `page_00006.sql`
- [ ] Edit `navigation_menu.sql` (limpiar `Ventas` → P30)
- [ ] Actualizar `install_page.sql`
- [ ] Actualizar `CLAUDE.md`

### F3 — Stock por oficina
- [ ] Función `FN_OFICINA_USUARIO`
- [ ] Función `FN_HAY_STOCK`
- [ ] Función `FN_OFICINAS_CON_STOCK`
- [ ] Items `P54_ID_OFICINA`, `P54_AVISO_STOCK_*`
- [ ] DA Change sobre `ID_PRODUCTO` con AJAX callback
- [ ] Validación server-side de submit

### F5 — Pantalla de cambio de estado ✅
- [x] Crear page 115 modal (`page_00115.sql`, 4 regiones, 8 items, 3 botones, 1 validación, 2 procesos AFTER_SUBMIT)
- [x] Link en P52 IR (columna `CAMBIARESTADO` con ícono `fa-exchange` en ambos IRs)
- [x] Proceso `ProcesarCambioEstado` (usa `FN_PUEDE_TRANSICION_OV` + `SELECT FOR UPDATE` + `UPDATE` con CASE para columnas auditoría)
- [x] DA close-dialog en botón CERRAR
- [x] Validación motivo requerido cuando se aprieta ANULAR (atada al botón vía `when_button_pressed`)

### F6 — Reporte anulados/vencidos
- [ ] Modificar IR de P52 (filtro default)
- [ ] Crear page 116
- [ ] Entrada de menú

### F2 — Caducidad
- [ ] Parámetro `DIAS_VIGENCIA_PRESUPUESTO`
- [ ] Columnas nuevas en `ORDENES_VENTA`
- [ ] Trigger `TRG_OV_FECHA_VENCIMIENTO`
- [ ] Job `JOB_VENCER_PRESUPUESTOS`
- [ ] Columna+badge en IR de P52
- [ ] Reemplazo del literal “15 días” en P6

---

## 8. Cosas que NO se hacen (explícito)

- Renombrar tablas/columnas de BD (`ORDENES_VENTA`, `DETALLE_ORDEN`).
- Descuentos manuales o globales.
- Bloquear o reducir el catálogo del LOV por oficina.
- Mostrar cantidades de stock al vendedor.
- Tocar P30 “Ventas” más allá de ocultarla en el menú.

---

## 10. Deuda técnica detectada (fuera de alcance)

- **P30 / P31 — “Orden de Pago” huérfana.** P30 era originalmente el IR de
  `ORDEN_PAGO` (lo delata su `p_alias=>'ORDEN-DE-PAGO1'`); alguien la vació y le
  cambió `p_name` a *Ventas*, dejándola con solo un breadcrumb. P31 (form modal
  sobre `ORDEN_PAGO`) sigue existiendo pero hoy nadie la abre desde el menú ni
  desde un IR padre. La tabla `ORDEN_PAGO` (NRO_ORDEN, ID_PERSONA,
  CODIGO_EJECUTIVO, FECHA_VALOR, MONTO, CONCEPTO, TASA_IVA, MONTO_IVA,
  TOTAL_PAGAR) es claramente de **cuentas por pagar / pago a proveedor**, así
  que el lugar natural sería dentro del grupo **Compras** del menú.
  Pendiente: reconstruir el IR sobre `ORDEN_PAGO` (puede ser sobre P30 misma o
  una página nueva) y reasignar al grupo `Compras`. Mientras tanto, F1 solo
  limpia `current_for_pages=>'30,31'` del header `Ventas` para no apuntar a
  páginas que no corresponden al módulo.

---

## 9. Aprobación

> Este plan queda **pendiente de aprobación**. Una vez confirmado, la
> implementación arranca por la Feature 4 (estados).

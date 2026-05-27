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

### Feature 5 — Aprobación de Presupuestos (rediseñado 2026-05-26)

**Estado:** ❌ pendiente (rediseño). Implementación **manual** vía APEX Builder por el usuario.

#### Por qué se rediseñó

La primera versión (commits `71e72c6`, `74ad06d`, `f4ff7a0` — revertidos en P52, P115 borrada del live el 2026-05-26) intentó:
- Una modal P115 con form sobre `ORDENES_VENTA` + botones APROBAR/ANULAR
- Una columna acción `CAMBIARESTADO` con ícono dentro del IR de P52 que abría la modal

**Problemas detectados al probarla en el browser:**
- ORA-01403 al abrir P115 desde el link (inner joins en items QUERY no toleraban `ID_OFICINA` NULL en 8 órdenes)
- El ícono no renderizaba por `display_text_as=ESCAPE_SC` default
- El re-import de P52 borró el saved report PRIVATE de `TCASCO`
- Patrón inconsistente con el resto del app: el módulo Compras usa **página dedicada** (`P110 Aprobación de Órdenes de Compra` + `P112 Detalle Orden de Compra` modal), no acción dentro del IR principal

**Nueva decisión:** seguir el patrón del módulo Compras. P52 **no se toca más** para esto. Se crean páginas nuevas dedicadas, accesibles desde el menú.

#### Diseño nuevo (a construir vía APEX Builder)

| Página sugerida | Tipo | Rol | Equivalente en Compras |
| --------------- | ---- | --- | ---------------------- |
| **P117 — Aprobación de Presupuestos** | Normal | Lista de presupuestos a procesar (IG sobre `ORDENES_VENTA WHERE ESTADO IN ('PENDIENTE','APROBADO')`) con link de acción por fila al detalle modal | P110 Aprobación de OC |
| **P118 — Detalle Presupuesto** | Modal Dialog | Detalle del presupuesto + botones APROBAR/ANULAR/CERRAR | P112 Detalle Orden de Compra |

> **Por qué no se reutiliza P115:** se borró del live por estar huérfana. El archivo `apex-work/f100/application/pages/page_00115.sql` queda **en el repo como referencia** (proceso `ProcesarCambioEstado` y patrón de validaciones) — copiar el PL/SQL desde ahí cuando se arme P118.

#### Guía manual paso a paso

##### Paso 1 — Crear P117 (lista de presupuestos a aprobar)

1. APEX Builder → App 100 → **Create Page** → **Blank Page**
2. Name: `Aprobación de Presupuestos`. Page Number: `117`. Page Mode: `Normal`.
3. En la nueva page → **Create Region** → Type **Interactive Grid**.
   - Name: `Presupuestos a Aprobar`
   - Source → Type: `SQL Query`
   - SQL:
     ```sql
     select o.ID_ORDEN,
            o.FECHA_ORDEN,
            o.ESTADO,
            o.TOTAL,
            p.PRIMER_NOMBRE || ' ' || p.PRIMER_APELLIDO as cliente,
            f.DESCRIPCION as oficina,
            o.OBSERVACION
       from ORDENES_VENTA o
       left join PERSONAS p on p.ID_PERSONA      = o.ID_PERSONA
       left join OFICINAS f on f.CODIGO_OFICINA  = o.ID_OFICINA
      where o.ESTADO IN ('PENDIENTE','APROBADO')
      order by o.FECHA_ORDEN desc, o.ID_ORDEN desc
     ```
   - En **Attributes** del IG → **Edit Enabled** = `No` (read-only)
4. En el IG → propiedades del Grid → **Initial Sort** opcional (`FECHA_ORDEN` desc).
5. En la columna `ID_ORDEN` (o agregando una columna nueva tipo "Link"):
   - Type: `Link`
   - Link Target → `Page in this application` → Page `118`. Set Items: `P118_ID_ORDEN = ID_ORDEN`. Clear Cache: `118`.
   - Link Text: `<span class="fa fa-edit"></span>` (mostrar como ícono) — y en **Escape** elegir **No** para que el HTML renderice.
6. Guardar.

##### Paso 2 — Crear P118 (modal detalle + acciones)

1. APEX Builder → **Create Page** → **Form** → **Form on a Table**.
2. Tabla: `ORDENES_VENTA`. Page Mode: **Modal Dialog**. Name: `Detalle Presupuesto`. Page Number: `118`.
3. Auto-genera form con todos los items de ORDENES_VENTA. Editar items:
   - `P118_ID_ORDEN` → Display Only (Hidden alternativo si querés no mostrarlo)
   - `P118_ESTADO` → Display Only, no editable
   - `P118_FECHA_ORDEN`, `P118_TOTAL`, `P118_OBSERVACION` → Display Only
   - Hacer Display Only también `P118_FECHA_APROBACION`, `P118_USUARIO_APROBACION`, `P118_FECHA_ANULACION`, `P118_USUARIO_ANULACION`, `P118_MOTIVO_ANULACION` (si aparecen).
4. Agregar item nuevo: `P118_MOTIVO`, type Textarea, required cuando se aprieta ANULAR.
5. Agregar región nueva con el **detalle** de productos. Opciones:
   - **a)** IG read-only sobre `DETALLE_ORDEN d JOIN PRODUCTOS pr` con `WHERE d.ID_ORDEN = :P118_ID_ORDEN`. Set Edit Enabled = No.
   - **b)** Region `PL/SQL Dynamic Content` con HTML generado (copiar el bloque `htp.p` del archivo `page_00115.sql` que dejé en repo — adaptar `:P115_ID_ORDEN` → `:P118_ID_ORDEN`).
6. **Eliminar los botones autogenerados** SAVE / CREATE / DELETE. Mantener CANCEL (renombralo a `CERRAR`).
7. **Crear botón** `APROBAR`:
   - Position: in button region, alignment Right
   - Button template: success (verde)
   - Action: Submit Page
   - Condition: `Value of Item / Column in Expression 1 = Expression 2`. Expression 1 = `P118_ESTADO`. Expression 2 = `PENDIENTE`.
   - Database Action: `Update` (cosmético, no se usa porque hay proceso PL/SQL custom).
8. **Crear botón** `ANULAR`:
   - Button template: danger (rojo)
   - Action: Submit Page
   - Condition: `Type = Expression`. Expression 1 = `:P118_ESTADO IN ('PENDIENTE','APROBADO')`. Expression 2 = `SQL`.
   - Confirm Message: `¿Confirma anular este presupuesto?` (style danger).
9. **Crear validación**: Name `Motivo requerido al anular`. Type `PL/SQL Expression`. Expression = `:P118_MOTIVO IS NOT NULL AND length(trim(:P118_MOTIVO)) > 0`. Error Message: `Debe ingresar el motivo de anulación`. **When Button Pressed** = ANULAR. Associated Item = `P118_MOTIVO`.
10. **Crear proceso PL/SQL** `ProcesarCambioEstado` (After Submit, sequence 20). Copiar el código desde `apex-work/f100/application/pages/page_00115.sql` (sección Region "BEFORE_HEADER" → process body), adaptando todos los `:P115_` por `:P118_`. Condición: `Request Is Contained within Expression 1` = `APROBAR,ANULAR`.
11. **Crear proceso** `Close Dialog`. Type `Close Dialog`. Condición igual al anterior. Sequence 30.

##### Paso 3 — Agregar entry al menú de navegación

**Manualmente** en APEX Builder (recordar: shared components Lists no soportan re-import por SQL — ver memoria `apex-shared-components-no-upsert`):

1. Shared Components → Navigation → Lists → `Navigation Menu` → Create List Entry.
2. Parent List Entry: `Ventas` (el header del grupo).
3. List Entry Label: `Aprobación de Presupuestos`.
4. Target: Page `117` (de esta app).
5. Icon: `fa-thumbs-o-up` (igual al de Aprobación de OC, ver line 551 del export del menu).
6. Authorization: si querés restringir, agregar condition (ej. `security_pkg.can_access(:APP_ID, :APP_USER, 117, NULL)`).

##### Paso 4 — Test funcional en browser (NO SALTAR)

1. Login al app. Click "Ventas" → "Aprobación de Presupuestos". Debe abrir P117 con la lista filtrada.
2. Click ícono editar en una fila PENDIENTE (ej. ID 1). Debe abrir P118 modal.
3. P118 muestra cabecera (cliente, fecha, oficina o "(sin)" si null, total, observación, estado actual), detalle de líneas, textarea motivo, botón verde APROBAR.
4. Apretar APROBAR → confirma. Modal cierra. La fila desaparece del IG si filtramos solo PENDIENTE (o cambia a APROBADO si filtramos ambos). Confirmar `ESTADO=APROBADO`, `FECHA_APROBACION`, `USUARIO_APROBACION` poblados via SQL.
5. Para una fila APROBADA: solo debe aparecer ANULAR (no APROBAR). Apretar ANULAR sin motivo → error inline. Con motivo → confirma y persiste; trigger `TRG_OV_LIBERA_RESERVA` anula reservas vigentes.
6. Para una fila FACTURADA: ningún botón de acción (solo CERRAR).

##### Paso 5 — Capturar al repo (cuando funcione)

Re-exportar P117, P118 y `navigation_menu` desde live:
```bash
sql -S -name $SQLCL_CONNECTION <<'EOF'
apex export -applicationid 100 -split -dir apex-work -expComponents "PAGE:117,PAGE:118,LIST:Navigation Menu"
exit;
EOF
```
Después agregar `@@application/pages/delete_00117.sql + page_00117.sql` y los mismos de 118 a `install_page.sql`. El `navigation_menu.sql` queda solo como referencia (no se importa por la limitación de shared components).

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

### F1 — Renombrado ✅ (con deuda manual)
- [x] Edit `page_00052.sql` → `Presupuestos` / `Presupuesto`
- [x] Edit `page_00054.sql` → `Presupuesto` (page_name, step_title, plug_name, processes)
- [x] Export + edit `page_00006.sql` → `Reporte Presupuesto` + `<h1>PRESUPUESTO</h1>`
- [x] Edit `navigation_menu.sql` (limpiar `current_for_pages='30,31'` del header `Ventas`)
- [x] Actualizar `install_page.sql`
- [x] Actualizar `CLAUDE.md`
- [x] Push P6/P52/P54 al live (commits `578462d` + `1f0e3be`)
- [ ] **Pendiente manual:** aplicar el cambio del `navigation_menu` en APEX UI (Shared Components → Lists → Navigation Menu → item `Ventas` → vaciar `Current For Pages`). No se pudo hacer por SQL: `wwv_flow_imp_shared.create_list` no soporta upsert. Ver memoria `apex-shared-components-no-upsert`.

### F3 — Stock por oficina
- [ ] Función `FN_OFICINA_USUARIO`
- [ ] Función `FN_HAY_STOCK`
- [ ] Función `FN_OFICINAS_CON_STOCK`
- [ ] Items `P54_ID_OFICINA`, `P54_AVISO_STOCK_*`
- [ ] DA Change sobre `ID_PRODUCTO` con AJAX callback
- [ ] Validación server-side de submit

### F5 — Aprobación de Presupuestos (rediseñado)
- [ ] Crear P117 vía APEX Builder (IG sobre `ORDENES_VENTA WHERE ESTADO IN ('PENDIENTE','APROBADO')` + link a P118)
- [ ] Crear P118 vía APEX Builder (modal Form sobre `ORDENES_VENTA` + región detalle + botones APROBAR/ANULAR/CERRAR + validación motivo + proceso PL/SQL)
- [ ] Copiar el código del proceso `ProcesarCambioEstado` desde `apex-work/f100/application/pages/page_00115.sql` (referencia en repo, NO está en live), adaptando `:P115_` → `:P118_`
- [ ] Agregar entry "Aprobación de Presupuestos" al grupo `Ventas` del menú (manual via Shared Components)
- [ ] Test funcional completo en browser (paso 4 de la guía)
- [ ] Re-exportar P117, P118 al repo y agregarlas al `install_page.sql`

> Rollback de la versión anterior aplicado el 2026-05-26: revertí P52 al estado post-F1 (commit `578462d`), borré P115 del workspace WKSP_WORKPLACE, removí `@@page_00115` de `install_page.sql`. El archivo `page_00115.sql` queda en el repo solo como referencia del proceso PL/SQL para reutilizar al armar P118.

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

# Plan: Transferencia de Stock entre Depósitos

**Estado:** COMPLETADO  
**Feature:** Movimiento de stock entre oficinas/depósitos  
**Módulo:** Inventario  
**Páginas APEX nuevas:** 113 (lista) + 114 (modal)

---

## Contexto del modelo actual

### Tablas involucradas

| Tabla | Clave | Descripción |
|-------|-------|-------------|
| `MOVIMIENTOS_STOCK` | `ID_MOVIMIENTO` (seq) | Registro central de todos los movimientos. `TIPO_MOVIMIENTO` = 'ENTRADA' / 'SALIDA' / 'AJUSTE'. `REFERENCIA` vincula movimientos relacionados (ej: "INV:42", "COMPRA - COMPROBANTE 42") |
| `STOCK_PRODUCTO` | `(ID_PRODUCTO, ID_OFICINA)` | Stock actual por producto+oficina |
| `AJUSTES_STOCK` | `ID_AJUSTE` | Ajustes manuales; un trigger los propaga a MOVIMIENTOS_STOCK |
| `OFICINAS` | `CODIGO_OFICINA` | Depósitos/sucursales |

### Triggers relevantes

- `TRG_ACTUALIZAR_STOCK_MOVIMIENTO` (AFTER INSERT on MOVIMIENTOS_STOCK)  
  Aplica ENTRADA (+) o SALIDA (-) a STOCK_PRODUCTO. Valida stock suficiente en SALIDA.  
  Si el registro `(ID_PRODUCTO, ID_OFICINA)` no existe en STOCK_PRODUCTO lo crea con CANTIDAD=0.

- `TRG_AJUSTE_MOVIMIENTO` (AFTER INSERT on AJUSTES_STOCK)  
  Puente: inserta en MOVIMIENTOS_STOCK copiando los campos del ajuste.

### Decisión de diseño

**No se usa trigger** sobre la nueva tabla para disparar los movimientos.  
Se usa un **procedimiento PL/SQL** (`PRC_TRANSFERIR_STOCK`) llamado desde APEX.  
Motivo: evitar encadenamiento de 2 niveles de triggers, centralizar la lógica en un lugar legible y debuggeable.

---

## Cambios de base de datos

### 1. Nueva tabla `TRANSFERENCIAS_STOCK`

```sql
CREATE TABLE WKSP_WORKPLACE.TRANSFERENCIAS_STOCK (
  ID_TRANSFERENCIA    NUMBER          GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ID_PRODUCTO         NUMBER          NOT NULL,
  ID_OFICINA_ORIGEN   NUMBER          NOT NULL,
  ID_OFICINA_DESTINO  NUMBER          NOT NULL,
  CANTIDAD            NUMBER          NOT NULL,
  FECHA               DATE            DEFAULT SYSDATE,
  OBSERVACION         VARCHAR2(255)   NOT NULL,
  USUARIO             VARCHAR2(100),
  HORA                VARCHAR2(10),
  CONSTRAINT FK_TRANS_PROD  FOREIGN KEY (ID_PRODUCTO)       REFERENCES PRODUCTOS(ID_PRODUCTO),
  CONSTRAINT FK_TRANS_ORIG  FOREIGN KEY (ID_OFICINA_ORIGEN) REFERENCES OFICINAS(CODIGO_OFICINA),
  CONSTRAINT FK_TRANS_DEST  FOREIGN KEY (ID_OFICINA_DESTINO)REFERENCES OFICINAS(CODIGO_OFICINA),
  CONSTRAINT CHK_TRANS_DIFS CHECK (ID_OFICINA_ORIGEN <> ID_OFICINA_DESTINO),
  CONSTRAINT CHK_TRANS_CANT CHECK (CANTIDAD > 0)
);
```

> Propósito: tabla de auditoría de transferencias. Cada fila = una transferencia aprobada.  
> Los dos movimientos resultantes en MOVIMIENTOS_STOCK se vinculan con `REFERENCIA = 'TRANS-{ID_TRANSFERENCIA}'`.

### 2. Nuevo procedimiento `PRC_TRANSFERIR_STOCK`

```sql
CREATE OR REPLACE PROCEDURE WKSP_WORKPLACE.PRC_TRANSFERIR_STOCK (
  p_id_producto       IN NUMBER,
  p_oficina_origen    IN NUMBER,
  p_oficina_destino   IN NUMBER,
  p_cantidad          IN NUMBER,
  p_observacion       IN VARCHAR2,
  p_usuario           IN VARCHAR2
) AS
  v_stock_origen  NUMBER;
  v_id_trans      NUMBER;
  v_hora          VARCHAR2(10);
BEGIN
  -- Validar origen <> destino (redundante con constraint, pero mejor mensaje)
  IF p_oficina_origen = p_oficina_destino THEN
    RAISE_APPLICATION_ERROR(-20010, 'El depósito origen y destino no pueden ser el mismo.');
  END IF;

  -- Validar cantidad positiva
  IF p_cantidad <= 0 THEN
    RAISE_APPLICATION_ERROR(-20011, 'La cantidad a transferir debe ser mayor a cero.');
  END IF;

  -- Verificar stock disponible en origen
  BEGIN
    SELECT NVL(CANTIDAD, 0)
    INTO   v_stock_origen
    FROM   STOCK_PRODUCTO
    WHERE  ID_PRODUCTO = p_id_producto
      AND  ID_OFICINA  = p_oficina_origen
    FOR UPDATE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_stock_origen := 0;
  END;

  IF v_stock_origen < p_cantidad THEN
    RAISE_APPLICATION_ERROR(-20012,
      'Stock insuficiente en origen. Disponible: ' || v_stock_origen || ', solicitado: ' || p_cantidad || '.');
  END IF;

  v_hora := TO_CHAR(SYSDATE, 'HH24:MI:SS');

  -- Registrar la transferencia (auditoría)
  INSERT INTO TRANSFERENCIAS_STOCK (
    ID_PRODUCTO, ID_OFICINA_ORIGEN, ID_OFICINA_DESTINO,
    CANTIDAD, FECHA, OBSERVACION, USUARIO, HORA
  ) VALUES (
    p_id_producto, p_oficina_origen, p_oficina_destino,
    p_cantidad, SYSDATE, p_observacion, p_usuario, v_hora
  ) RETURNING ID_TRANSFERENCIA INTO v_id_trans;

  -- Movimiento 1: SALIDA del depósito origen
  INSERT INTO MOVIMIENTOS_STOCK (
    ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
    FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION, USUARIO
  ) VALUES (
    p_id_producto, p_oficina_origen, 'SALIDA', p_cantidad,
    SYSDATE, 'TRANS-' || v_id_trans, p_observacion, p_usuario
  );

  -- Movimiento 2: ENTRADA al depósito destino
  INSERT INTO MOVIMIENTOS_STOCK (
    ID_PRODUCTO, ID_OFICINA, TIPO_MOVIMIENTO, CANTIDAD,
    FECHA_MOVIMIENTO, REFERENCIA, OBSERVACION, USUARIO
  ) VALUES (
    p_id_producto, p_oficina_destino, 'ENTRADA', p_cantidad,
    SYSDATE, 'TRANS-' || v_id_trans, p_observacion, p_usuario
  );

END PRC_TRANSFERIR_STOCK;
/
```

> El trigger `TRG_ACTUALIZAR_STOCK_MOVIMIENTO` existente se encarga automáticamente  
> de actualizar STOCK_PRODUCTO al insertar cada movimiento.

---

## Cambios APEX

### Páginas nuevas

| Página | Tipo | Nombre | Alias |
|--------|------|--------|-------|
| 113 | Normal — IR | Transferencias de Stock | TRANSFERENCIAS-STOCK |
| 114 | Modal | Nueva Transferencia de Stock | NUEVA-TRANSFERENCIA-STOCK |

### Página 113 — Lista (IR sobre TRANSFERENCIAS_STOCK)

Query:
```sql
SELECT
  ts.ID_TRANSFERENCIA,
  p.NOMBRE           AS PRODUCTO,
  o1.DESCRIPCION     AS ORIGEN,
  o2.DESCRIPCION     AS DESTINO,
  ts.CANTIDAD,
  ts.FECHA,
  ts.OBSERVACION,
  ts.USUARIO
FROM TRANSFERENCIAS_STOCK ts
JOIN PRODUCTOS p   ON p.ID_PRODUCTO      = ts.ID_PRODUCTO
JOIN OFICINAS  o1  ON o1.CODIGO_OFICINA  = ts.ID_OFICINA_ORIGEN
JOIN OFICINAS  o2  ON o2.CODIGO_OFICINA  = ts.ID_OFICINA_DESTINO
ORDER BY ts.FECHA DESC
```

Botón: **+ Nueva Transferencia** → abre modal P114.  
Sin botón de edición/eliminación — las transferencias son inmutables una vez registradas.

### Página 114 — Modal (Form de alta)

| Item | Tipo | Notas |
|------|------|-------|
| P114_ID_PRODUCTO | SELECT_LIST | LOV PRODUCTOS.NOMBRE, requerido |
| P114_ID_OFICINA_ORIGEN | SELECT_LIST | LOV OFICINAS.DESCRIPCION, requerido |
| P114_STOCK_DISPONIBLE | DISPLAY_ONLY | Muestra stock actual en origen (DA onChange) |
| P114_ID_OFICINA_DESTINO | SELECT_LIST | LOV OFICINAS.DESCRIPCION, requerido |
| P114_CANTIDAD | NUMBER_FIELD | requerido, virtual_keyboard=decimal |
| P114_OBSERVACION | TEXTAREA | requerido |
| P114_USUARIO | HIDDEN | default :APP_USER |

**Dynamic Actions:**
- `onChange` en P114_ID_PRODUCTO + P114_ID_OFICINA_ORIGEN → EXECUTE_PLSQL  
  `SELECT NVL(CANTIDAD,0) INTO :P114_STOCK_DISPONIBLE FROM STOCK_PRODUCTO WHERE ID_PRODUCTO=:P114_ID_PRODUCTO AND ID_OFICINA=:P114_ID_OFICINA_ORIGEN`  
  → `SET_VALUE` sobre P114_STOCK_DISPONIBLE

**Proceso AFTER_SUBMIT (seq 10) — NATIVE_PLSQL:**
```sql
BEGIN
  PRC_TRANSFERIR_STOCK(
    p_id_producto      => :P114_ID_PRODUCTO,
    p_oficina_origen   => :P114_ID_OFICINA_ORIGEN,
    p_oficina_destino  => :P114_ID_OFICINA_DESTINO,
    p_cantidad         => :P114_CANTIDAD,
    p_observacion      => :P114_OBSERVACION,
    p_usuario          => :APP_USER
  );
END;
```

**Proceso AFTER_SUBMIT (seq 20) — NATIVE_CLOSE_WINDOW:**  
`when REQUEST = 'TRANSFERIR'`

**Botones:**
- CANCEL (DEFINED_BY_DA → NATIVE_DIALOG_CANCEL)
- TRANSFERIR (hot, SUBMIT, p_database_action=>'INSERT')

### Actualización de menú de navegación

Agregar bajo **Inventarios**:
```
Transferencia de Stock (p113)   ← entre "Movimiento de Stock" (p56) y "Existencias" (p88)
```

---

## Orden de implementación

```
PASO 1  DB   → CREATE TABLE TRANSFERENCIAS_STOCK
PASO 2  DB   → CREATE OR REPLACE PROCEDURE PRC_TRANSFERIR_STOCK
PASO 3  DB   → Test manual: EXEC PRC_TRANSFERIR_STOCK(...) y verificar 2 movimientos + stock
PASO 4  APEX → Crear página 113 (lista IR)
PASO 5  APEX → Crear página 114 (modal + DA stock disponible + proceso PRC)
PASO 6  APEX → Actualizar menú de navegación
PASO 7  Test → Flujo completo en app: crear transferencia, verificar página 56, verificar stock
```

---

## Riesgos y dependencias

| Riesgo | Impacto | Mitigación |
|--------|---------|-----------|
| Solo existe 1 oficina en producción | Alto para testing | Crear segunda oficina antes del PASO 3 |
| Números de página 113/114 podrían estar ocupados | Bajo | Verificar con `SELECT page_id FROM apex_application_pages WHERE application_id=100 AND page_id IN (113,114)` antes de crear |
| El procedimiento usa `FOR UPDATE` — posible lock contention | Muy bajo (uso individual) | Aceptable en este contexto |
| Las transferencias son inmutables — no hay UI de corrección | Diseño intencional | Si se necesita corrección, crear transferencia inversa |

---

## Cambios de alcance

_Registrar aquí cualquier modificación al alcance acordado:_

| Fecha | Cambio | Motivo |
|-------|--------|--------|
| 2026-05-22 | Corrección de bug en `TRG_ACTUALIZAR_STOCK_MOVIMIENTO`: reemplazado `SQL%NOTFOUND` (inalcanzable) por `EXCEPTION WHEN NO_DATA_FOUND` | La transferencia a una oficina sin stock previo exponía el bug; `SELECT INTO ... FOR UPDATE` lanza la excepción antes de que `SQL%NOTFOUND` pueda evaluarse |

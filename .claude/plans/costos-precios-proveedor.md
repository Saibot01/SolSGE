# Plan: Gestión de Costos y Precios por Proveedor

**Estado:** COMPLETADO (Fases 1-5 ✅, Fase 6 soft deprecation hecha, DROP físico para futuro)  
**Feature:** Actualización automática de costo al confirmar factura de proveedor + cálculo de precio de venta por margen  
**Módulo:** Compras / Productos  
**Fecha inicio:** 2026-05-25  
**Última actualización:** 2026-05-25  
**Decisión registrada:** Margen → tabla `MARGEN_CATEGORIA` con vigencias (Opción B), pantalla de configuración independiente

---

## Contexto y decisiones de diseño

### Modelo de costo elegido
**Costo por proveedor** — cada proveedor mantiene su propio precio en `PRODUCTO_PROVEEDORES`.
La PK `(ID_PRODUCTO, ID_PERSONA, FECHA_INICIO)` ya fue diseñada para este modelo.

### Momento del disparo
Al confirmar la factura de proveedor: `COMPROBANTES_PROVEEDOR.ESTADO` cambia a `'C'`.
No al registrar (`'R'`) ni al recibir físicamente (eso ya lo maneja `TRG_MOV_STOCK_RECEPCION`).

### Modelo de margen
Configurable por **categoría de producto** (rubro) y **segmento de cliente** (Mayorista/Minorista).
Se implementa en una tabla nueva `MARGEN_CATEGORIA` con diseño de vigencias (igual que `PRODUCTO_PROVEEDORES`):
cada cambio de margen es un INSERT nuevo — el registro anterior se cierra automáticamente.
Esto permite auditoría histórica completa y responder "¿cuál era el margen de Gaming el día X?".
**No se modifican columnas en `CATEGORIAS_PRODUCTOS`.**
La configuración se gestiona desde una **pantalla APEX independiente** — no se toca la pantalla existente de categorías.

### Cierre de registros históricos
Al insertar nuevo precio en `PRODUCTO_PROVEEDORES`, el trigger cierra el registro anterior
con `FECHA_FIN = TRUNC(nueva_FECHA_INICIO) - 1` **y** `ESTADO = 'INACTIVO'`.
Usar ambos campos porque las tres vistas existentes filtran por `ESTADO='ACTIVO'`.

---

## Tablas involucradas

| Tabla | Rol | Cambio requerido |
|---|---|---|
| `PRODUCTO_PROVEEDORES` | Almacena el costo por proveedor | Nuevo trigger de cierre automático |
| `CATEGORIAS_PRODUCTOS` | Categorías de producto (rubro) | **Sin cambios** |
| `MARGEN_CATEGORIA` | Margen de ganancia por categoría y segmento de cliente | **Tabla nueva** — con vigencias históricas |
| `COMPROBANTES_PROVEEDOR` | Cabecera de factura proveedor | Nuevo trigger de actualización de costo |
| `DETALLE_COMPROBANTE_PROV` | Líneas de factura (PRECIO_UNITARIO) | Solo lectura — fuente del costo |
| `PRECIO_POR_CATEGORIA` | Precios de venta por producto/segmento | Se recalcula desde APEX (fase 5) |
| `AUDITORIA_PRODUCTO_PROVEEDOR` | Historial de cambios en PP | Ya funciona vía `TRG_AUD_PP` — sin cambios |

## Vistas existentes (solo lectura, no modificar)

| Vista | Qué hace | Impacto de los cambios |
|---|---|---|
| `V_PRODUCTO_PROVEEDOR_VIGENTE` | Todos los registros PP con columna VIGENCIA calculada | Compatible — registros cerrados pasan a INACTIVO |
| `V_COMPARATIVA_PRECIO_PROVEEDORES` | Ranking y promedio de precios por proveedor activo y vigente | Se corrige el bug actual de duplicados sin FECHA_FIN |
| `V_ALERTAS_CADUCIDAD_PP` | Alertas de registros próximos a vencer (filtro ESTADO='ACTIVO') | Sin ruido — registros reemplazados quedan INACTIVO y salen del filtro |

## Triggers existentes relevantes

| Trigger | Tabla | Estado | Función |
|---|---|---|---|
| `TRG_AUD_PP` | `PRODUCTO_PROVEEDORES` | ENABLED | Audita INSERT/UPDATE/DELETE en PP → `AUDITORIA_PRODUCTO_PROVEEDOR` |
| `TRG_MOV_STOCK_RECEPCION` | `DETALLE_RECEPCION_COMPRA` | ENABLED | Genera entrada de stock al recibir físicamente |
| `TRG_MOV_STOCK_DETALLE_PROV` | `DETALLE_COMPROBANTE_PROV` | **DISABLED** | Intentaba mover stock al registrar factura — lógica incorrecta, no reactivar |
| `STOCK_PRODUCTO_T` | `STOCK_PRODUCTO` | ENABLED | Cuerpo vacío (`begin null; end;`) — dead code |

---

## Fases de implementación

---

### FASE 1 — Normalización de datos existentes
**Estado:** ✅ Completado — 2026-05-25  
**Prerrequisito de:** Fases 2, 3, 4

#### Objetivo
Corregir los registros duplicados activos sin `FECHA_FIN` en `PRODUCTO_PROVEEDORES`
antes de instalar el trigger automático, para partir de datos consistentes.

#### Problema detectado
Proveedor 101, Producto 3 tiene dos filas con `ESTADO='ACTIVO'` y `FECHA_FIN IS NULL`:
- `FECHA_INICIO=10/05/26`, `PRECIO=80.000`
- `FECHA_INICIO=01/06/26`, `PRECIO=78.000`

Ambas pasan el filtro de vigencia en `V_COMPARATIVA_PRECIO_PROVEEDORES`, skewando el promedio.

#### Criterio de resolución
Para cada grupo `(ID_PRODUCTO, ID_PERSONA)` con múltiples registros sin `FECHA_FIN`:
- Conservar vigente el de mayor `FECHA_INICIO` (el más reciente)
- Cerrar los anteriores: `FECHA_FIN = TRUNC(siguiente_FECHA_INICIO) - 1`, `ESTADO = 'INACTIVO'`

#### Script de diagnóstico (ejecutar primero, NO modificar)
```sql
-- Identificar todos los conflictos actuales
SELECT id_producto, id_persona, COUNT(*) cant_sin_fin,
       MIN(fecha_inicio) fecha_min, MAX(fecha_inicio) fecha_max,
       MIN(precio) precio_min, MAX(precio) precio_max
FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
WHERE estado = 'ACTIVO' AND fecha_fin IS NULL
GROUP BY id_producto, id_persona
HAVING COUNT(*) > 1
ORDER BY id_producto, id_persona;
```

#### Script de corrección (ejecutar tras validar diagnóstico)
```sql
-- Cerrar registros duplicados: dejar solo el más reciente por producto-proveedor
UPDATE WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp_old
SET fecha_fin = (
        SELECT TRUNC(MAX(pp2.fecha_inicio)) - 1
        FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp2
        WHERE pp2.id_producto = pp_old.id_producto
          AND pp2.id_persona  = pp_old.id_persona
          AND pp2.estado      = 'ACTIVO'
          AND pp2.fecha_inicio > pp_old.fecha_inicio
    ),
    estado = 'INACTIVO',
    fecha_modificacion = SYSDATE,
    usuario_modificacion = 'NORMALIZACION_2026'
WHERE estado = 'ACTIVO'
  AND fecha_fin IS NULL
  AND EXISTS (
        SELECT 1 FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp2
        WHERE pp2.id_producto = pp_old.id_producto
          AND pp2.id_persona  = pp_old.id_persona
          AND pp2.estado      = 'ACTIVO'
          AND pp2.fecha_inicio > pp_old.fecha_inicio
      );

COMMIT;
```

#### Verificación post-corrección
```sql
-- Debe retornar 0 filas
SELECT id_producto, id_persona, COUNT(*)
FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
WHERE estado = 'ACTIVO' AND fecha_fin IS NULL
GROUP BY id_producto, id_persona
HAVING COUNT(*) > 1;
```

---

### FASE 2 — Tabla `MARGEN_CATEGORIA` con historial de vigencias
**Estado:** ✅ Completado — 2026-05-25  
**Prerrequisito de:** Fases 4 y 5

#### Objetivo
Crear la tabla `MARGEN_CATEGORIA` para almacenar el porcentaje de ganancia
por categoría de producto y segmento de cliente, con historial completo de cambios
usando el mismo patrón de vigencias que `PRODUCTO_PROVEEDORES`.

#### Diseño de la tabla

| Campo | Tipo | Descripción |
|---|---|---|
| `ID_MARGEN` | NUMBER PK | Secuencia |
| `ID_CATEGORIA` | NUMBER FK | → `CATEGORIAS_PRODUCTOS` |
| `CATEGORIA_CLIENTE` | VARCHAR2(20) | `'Mayorista'` / `'Minorista'` |
| `PORCENTAJE` | NUMBER(5,2) | Ej: `15.00` = 15% |
| `FECHA_INICIO` | DATE | Inicio de vigencia |
| `FECHA_FIN` | DATE NULL | Fin de vigencia. NULL = vigente |
| `ESTADO` | VARCHAR2(20) | `'ACTIVO'` / `'INACTIVO'` |
| `USUARIO_CREACION` | VARCHAR2(100) | |
| `FECHA_CREACION` | DATE | |
| `USUARIO_MODIFICACION` | VARCHAR2(100) | |
| `FECHA_MODIFICACION` | DATE | |

#### DDL
```sql
CREATE SEQUENCE WKSP_WORKPLACE.SEQ_MARGEN_CATEGORIA START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE TABLE WKSP_WORKPLACE.MARGEN_CATEGORIA (
    ID_MARGEN             NUMBER         DEFAULT WKSP_WORKPLACE.SEQ_MARGEN_CATEGORIA.NEXTVAL NOT NULL,
    ID_CATEGORIA          NUMBER         NOT NULL,
    CATEGORIA_CLIENTE     VARCHAR2(20)   NOT NULL,   -- 'Mayorista' / 'Minorista'
    PORCENTAJE            NUMBER(5,2)    NOT NULL,
    FECHA_INICIO          DATE           DEFAULT TRUNC(SYSDATE) NOT NULL,
    FECHA_FIN             DATE,
    ESTADO                VARCHAR2(20)   DEFAULT 'ACTIVO' NOT NULL,
    USUARIO_CREACION      VARCHAR2(100),
    FECHA_CREACION        DATE           DEFAULT SYSDATE NOT NULL,
    USUARIO_MODIFICACION  VARCHAR2(100),
    FECHA_MODIFICACION    DATE,
    CONSTRAINT PK_MARGEN_CATEGORIA     PRIMARY KEY (ID_MARGEN),
    CONSTRAINT FK_MC_CATEGORIA         FOREIGN KEY (ID_CATEGORIA)
                                           REFERENCES WKSP_WORKPLACE.CATEGORIAS_PRODUCTOS (ID_CATEGORIA),
    CONSTRAINT CHK_MC_SEG_CLIENTE      CHECK (CATEGORIA_CLIENTE IN ('Mayorista','Minorista')),
    CONSTRAINT CHK_MC_PORCENTAJE       CHECK (PORCENTAJE >= 0 AND PORCENTAJE <= 9999.99),
    CONSTRAINT CHK_MC_ESTADO           CHECK (ESTADO IN ('ACTIVO','INACTIVO'))
);

COMMENT ON TABLE  WKSP_WORKPLACE.MARGEN_CATEGORIA                    IS 'Margen de ganancia por categoría de producto y segmento de cliente, con historial de vigencias.';
COMMENT ON COLUMN WKSP_WORKPLACE.MARGEN_CATEGORIA.PORCENTAJE         IS 'Porcentaje de margen sobre el costo. Ej: 30 = 30%.';
COMMENT ON COLUMN WKSP_WORKPLACE.MARGEN_CATEGORIA.CATEGORIA_CLIENTE  IS 'Segmento de cliente destino: Mayorista o Minorista.';

CREATE INDEX WKSP_WORKPLACE.IDX_MC_CATEGORIA  ON WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, ESTADO);
CREATE INDEX WKSP_WORKPLACE.IDX_MC_VIGENTE    ON WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, ESTADO, FECHA_INICIO, FECHA_FIN);
```

#### Trigger de cierre automático de márgenes anteriores
Al insertar un nuevo margen para el mismo `(ID_CATEGORIA, CATEGORIA_CLIENTE)`,
cierra el registro vigente anterior — mismo patrón que `TRG_CIERRE_PP_ANTERIOR`.

```sql
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_CIERRE_MARGEN_ANTERIOR
BEFORE INSERT ON WKSP_WORKPLACE.MARGEN_CATEGORIA
FOR EACH ROW
BEGIN
  UPDATE WKSP_WORKPLACE.MARGEN_CATEGORIA
  SET  fecha_fin            = TRUNC(:NEW.fecha_inicio) - 1,
       estado               = 'INACTIVO',
       fecha_modificacion   = SYSDATE,
       usuario_modificacion = NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER)
  WHERE id_categoria      = :NEW.id_categoria
    AND categoria_cliente  = :NEW.categoria_cliente
    AND estado             = 'ACTIVO'
    AND fecha_fin          IS NULL;
END TRG_CIERRE_MARGEN_ANTERIOR;
/
```

#### Query estándar para obtener margen vigente
```sql
-- Usar esta query en triggers y procesos APEX para leer el margen actual
SELECT porcentaje
FROM   WKSP_WORKPLACE.MARGEN_CATEGORIA
WHERE  id_categoria      = :id_categoria
  AND  categoria_cliente  = :segmento          -- 'Mayorista' o 'Minorista'
  AND  estado             = 'ACTIVO'
  AND  fecha_fin          IS NULL;
```

#### Carga inicial de márgenes (ajustar valores con el negocio antes de ejecutar)
```sql
-- Un INSERT por categoría x segmento — el trigger no aplica aún (tabla vacía)
-- Valores de ejemplo: CONFIRMAR CON EL NEGOCIO antes de ejecutar
INSERT ALL
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (1,  'Mayorista', 15, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (1,  'Minorista', 30, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (2,  'Mayorista', 20, USER)  -- Gaming
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (2,  'Minorista', 40, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (3,  'Mayorista', 15, USER)  -- Gadgets
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (3,  'Minorista', 35, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (4,  'Mayorista', 18, USER)  -- Audio
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (4,  'Minorista', 35, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (5,  'Mayorista', 15, USER)  -- Cámaras
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (5,  'Minorista', 30, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (6,  'Mayorista', 12, USER)  -- Electrodomésticos
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (6,  'Minorista', 25, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (7,  'Mayorista', 20, USER)  -- Accesorios
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (7,  'Minorista', 40, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (8,  'Mayorista', 12, USER)  -- Televisores
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (8,  'Minorista', 25, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (9,  'Mayorista', 10, USER)  -- Laptops
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (9,  'Minorista', 22, USER)
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (10, 'Mayorista', 15, USER)  -- Smartphones
  INTO WKSP_WORKPLACE.MARGEN_CATEGORIA (ID_CATEGORIA, CATEGORIA_CLIENTE, PORCENTAJE, USUARIO_CREACION) VALUES (10, 'Minorista', 30, USER)
SELECT 1 FROM dual;

COMMIT;
```

#### Pantalla APEX de configuración de márgenes (nueva, independiente)
- **No modificar** la pantalla existente de `CATEGORIAS_PRODUCTOS`
- Nueva página con:
  - **Lista:** categorías con margen mayorista y minorista vigente a hoy
  - **Formulario de cambio:** seleccionar categoría + segmento + nuevo porcentaje + fecha de inicio
    - Al guardar: INSERT en `MARGEN_CATEGORIA` (trigger cierra el anterior automáticamente)
  - **Historial por categoría:** subregión con todos los registros de `MARGEN_CATEGORIA` para la categoría seleccionada, ordenados por fecha descendente

#### Verificación
```sql
-- Tras la carga inicial, verificar 20 filas (10 categorías x 2 segmentos), todas ACTIVO y sin FECHA_FIN
SELECT id_categoria, categoria_cliente, porcentaje, fecha_inicio, fecha_fin, estado
FROM WKSP_WORKPLACE.MARGEN_CATEGORIA
ORDER BY id_categoria, categoria_cliente;

-- Debe retornar 0 filas (no debe haber duplicados vigentes)
SELECT id_categoria, categoria_cliente, COUNT(*)
FROM WKSP_WORKPLACE.MARGEN_CATEGORIA
WHERE estado = 'ACTIVO' AND fecha_fin IS NULL
GROUP BY id_categoria, categoria_cliente
HAVING COUNT(*) > 1;
```

---

### FASE 3 — Trigger de cierre automático en `PRODUCTO_PROVEEDORES`
**Estado:** ✅ Completado — 2026-05-25  
**Prerrequisito:** Fase 1 completada

#### Objetivo
Al insertar un nuevo precio para un producto-proveedor, cerrar automáticamente
el registro activo anterior para evitar duplicados y mantener las vistas consistentes.

#### DDL del trigger
```sql
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_CIERRE_PP_ANTERIOR
BEFORE INSERT ON WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
FOR EACH ROW
BEGIN
  -- Cerrar todos los registros activos sin FECHA_FIN del mismo producto-proveedor
  UPDATE WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
  SET  fecha_fin            = TRUNC(:NEW.fecha_inicio) - 1,
       estado               = 'INACTIVO',
       fecha_modificacion   = SYSDATE,
       usuario_modificacion = NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER)
  WHERE id_producto = :NEW.id_producto
    AND id_persona  = :NEW.id_persona
    AND estado      = 'ACTIVO'
    AND fecha_fin   IS NULL;
END TRG_CIERRE_PP_ANTERIOR;
/
```

#### Notas
- El trigger `TRG_AUD_PP` (ya existente) registrará automáticamente el UPDATE en `AUDITORIA_PRODUCTO_PROVEEDOR`
- Si `:NEW.FECHA_INICIO` es anterior o igual a un registro existente, `TRUNC - 1` puede generar `FECHA_FIN` en el pasado — es correcto semánticamente pero hay que validar en APEX que la `FECHA_INICIO` del nuevo registro sea > a la del vigente

#### Verificación
```sql
-- Insertar registro de prueba y verificar que el anterior quede INACTIVO
-- (ejecutar en sesión de prueba, luego ROLLBACK)
INSERT INTO WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
    (id_producto, id_persona, fecha_inicio, precio, estado)
VALUES (3, 101, TRUNC(SYSDATE), 85000, 'ACTIVO');

SELECT id_producto, id_persona, fecha_inicio, fecha_fin, precio, estado
FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES
WHERE id_producto = 3 AND id_persona = 101
ORDER BY fecha_inicio DESC;

ROLLBACK;
```

---

### FASE 4 — Trigger de actualización de costo al confirmar factura
**Estado:** ✅ Completado — 2026-05-25  
**Prerrequisito:** Fases 1 y 3 completadas

#### Objetivo
Al confirmar una factura de proveedor (`ESTADO → 'C'`), actualizar el `PRECIO`
en `PRODUCTO_PROVEEDORES` para cada producto del detalle, usando el `PRECIO_UNITARIO`
de `DETALLE_COMPROBANTE_PROV`. Si no existe relación producto-proveedor previa, crearla.

#### Flujo
```
COMPROBANTES_PROVEEDOR.ESTADO → 'C'
    ↓ TRG_ACTUALIZAR_COSTO_COMPRA (nuevo)
    ↓ Para cada línea en DETALLE_COMPROBANTE_PROV:
        ↓ Si existe registro ACTIVO en PRODUCTO_PROVEEDORES:
            INSERT nuevo registro (cierre del anterior lo hace TRG_CIERRE_PP_ANTERIOR)
        ↓ Si NO existe:
            INSERT primer registro para ese producto-proveedor
```

#### DDL del trigger
```sql
CREATE OR REPLACE TRIGGER WKSP_WORKPLACE.TRG_ACTUALIZAR_COSTO_COMPRA
AFTER UPDATE OF ESTADO ON WKSP_WORKPLACE.COMPROBANTES_PROVEEDOR
FOR EACH ROW
WHEN (OLD.ESTADO != 'C' AND NEW.ESTADO = 'C')
DECLARE
  v_user VARCHAR2(100);
BEGIN
  v_user := NVL(SYS_CONTEXT('APEX$SESSION','APP_USER'), USER);

  FOR linea IN (
    SELECT dcp.id_producto, dcp.precio_unitario
    FROM   WKSP_WORKPLACE.DETALLE_COMPROBANTE_PROV dcp
    WHERE  dcp.id_comprobante = :NEW.id_comprobante
  ) LOOP

    -- Verificar si ya existe relación activa para este producto-proveedor
    MERGE INTO WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp
    USING (SELECT linea.id_producto id_prod,
                  :NEW.id_proveedor id_prov
           FROM dual) src
    ON (pp.id_producto = src.id_prod
        AND pp.id_persona = src.id_prov
        AND pp.estado = 'ACTIVO'
        AND pp.fecha_fin IS NULL)
    WHEN MATCHED THEN
      -- Existe registro vigente: insertar nuevo (el trigger TRG_CIERRE_PP_ANTERIOR
      -- cerrará el actual automáticamente al hacer el INSERT)
      INSERT (id_producto, id_persona, fecha_inicio, precio, estado,
              usuario_creacion, fecha_creacion)
      VALUES (linea.id_producto, :NEW.id_proveedor, TRUNC(SYSDATE),
              linea.precio_unitario, 'ACTIVO', v_user, SYSDATE)
    WHEN NOT MATCHED THEN
      INSERT (id_producto, id_persona, fecha_inicio, precio, estado,
              usuario_creacion, fecha_creacion)
      VALUES (linea.id_producto, :NEW.id_proveedor, TRUNC(SYSDATE),
              linea.precio_unitario, 'ACTIVO', v_user, SYSDATE);

  END LOOP;

END TRG_ACTUALIZAR_COSTO_COMPRA;
/
```

> **Nota:** MERGE con INSERT en WHEN MATCHED puede requerir ajuste según versión Oracle.
> Alternativa: usar cursor + IF EXISTS → INSERT, ELSE → INSERT (ambos casos insertan, 
> la diferencia es que TRG_CIERRE_PP_ANTERIOR cierra el anterior en el BEFORE INSERT).
> Evaluar en pruebas.

#### Moneda extranjera
Si `COMPROBANTES_PROVEEDOR.MONEDA != 'PYG'`, el `PRECIO_UNITARIO` en el detalle
puede estar en moneda de origen. Decisión pendiente de confirmar con el negocio:
- **Opción A:** guardar el precio en la moneda de la factura + campo MONEDA en PP
- **Opción B:** convertir siempre a PYG usando `TIPO_CAMBIO` de la cabecera (más simple)

**Recomendación provisional: Opción B** hasta que surja necesidad de multi-moneda en PP.

#### Verificación
```sql
-- Tras confirmar una factura de prueba, verificar:
SELECT pp.id_producto, p.nombre, pp.precio, pp.fecha_inicio, pp.estado
FROM WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp
JOIN WKSP_WORKPLACE.PRODUCTOS p ON p.id_producto = pp.id_producto
WHERE pp.id_persona = <id_proveedor_de_la_factura>
ORDER BY pp.id_producto, pp.fecha_inicio DESC;
```

---

### FASE 5 — Función `FN_PRECIO_VENTA` + integración APEX
**Estado:** 🔄 En progreso — función creada, integración APEX pendiente  
**Prerrequisito:** Fases 2, 3 y 4 completadas

#### Decisión de diseño
`PRECIO_POR_CATEGORIA` almacena datos derivados (costo × margen) — dos fuentes de verdad
con riesgo permanente de desincronía. Se reemplaza por una **función determinista** que
calcula el precio en tiempo real. `PRECIO_POR_CATEGORIA` pasa a Fase 6 (deprecación).

No se necesita `TRG_RECALCULAR_PRECIO_VENTA` — la función elimina esa necesidad.

#### Fórmula
```
FN_PRECIO_VENTA(id_producto, categoria_cliente)
  = ROUND(costo_vigente × (1 + margen_vigente / 100))
```
- **Costo vigente**: registro más reciente en `PRODUCTO_PROVEEDORES` con
  `ESTADO='ACTIVO'`, `FECHA_FIN IS NULL`, `FECHA_INICIO <= TRUNC(SYSDATE)`
- **Margen vigente**: registro en `MARGEN_CATEGORIA` con `ESTADO='ACTIVO'`,
  `FECHA_FIN IS NULL`, para la categoría del producto y el segmento de cliente
- Retorna `NULL` si no hay costo o margen configurado — APEX debe manejar ese caso

#### DDL de la función
```sql
CREATE OR REPLACE FUNCTION WKSP_WORKPLACE.FN_PRECIO_VENTA(
    p_id_producto       IN NUMBER,
    p_categoria_cliente IN VARCHAR2
) RETURN NUMBER
IS
    v_costo  NUMBER;
    v_margen NUMBER;
BEGIN
    -- Costo vigente: el más reciente entre todos los proveedores activos del producto
    SELECT pp.precio
    INTO   v_costo
    FROM   WKSP_WORKPLACE.PRODUCTO_PROVEEDORES pp
    WHERE  pp.id_producto  = p_id_producto
      AND  pp.estado       = 'ACTIVO'
      AND  pp.fecha_fin    IS NULL
      AND  pp.fecha_inicio <= TRUNC(SYSDATE)
    ORDER BY pp.fecha_inicio DESC
    FETCH FIRST 1 ROW ONLY;

    -- Margen vigente para la categoría del producto y el segmento
    SELECT mc.porcentaje
    INTO   v_margen
    FROM   WKSP_WORKPLACE.MARGEN_CATEGORIA mc
    JOIN   WKSP_WORKPLACE.PRODUCTOS p ON p.id_categoria = mc.id_categoria
    WHERE  p.id_producto        = p_id_producto
      AND  mc.categoria_cliente = p_categoria_cliente
      AND  mc.estado            = 'ACTIVO'
      AND  mc.fecha_fin         IS NULL;

    RETURN ROUND(v_costo * (1 + v_margen / 100));

EXCEPTION
    WHEN NO_DATA_FOUND  THEN RETURN NULL;
    WHEN TOO_MANY_ROWS  THEN RETURN NULL;
END FN_PRECIO_VENTA;
```

#### Relevamiento de impacto en APEX (app f100)

`PRECIO_POR_CATEGORIA` está referenciada en exactamente 3 páginas:

| Página | Tipo | Uso actual | Acción |
|---|---|---|---|
| **p8** | Interactive Grid | Listado/ABM de PRECIO_POR_CATEGORIA | **Deprecar** — sin sentido con la función |
| **p15** | Form | Edición de PRECIO_POR_CATEGORIA | **Deprecar** junto con p8 |
| **p54** | IG detalle orden de venta | **Bug**: JOIN inútil sin recuperar campos, sin filtrar `CATEGORIA_CLIENTE` → duplica filas | **Rehacer query + Dynamic Action** |

Segmento de cliente para órdenes: `ORDENES_VENTA.ID_PERSONA → CLIENTES.CATEGORIA_CLIENTE`.

#### A. Cambios en p54 (orden de venta)

**A.1 — Limpiar query del IG `Detalle Ventas`** ✅ Completado 2026-05-25

Reemplazado en APEX e importado. Archivo actualizado en `apex-work/f100/application/pages/page_00054.sql`.

```sql
-- Antes (con JOIN buggy):
from DETALLE_ORDEN DE, PRECIO_POR_CATEGORIA CA
where DE.ID_PRODUCTO = CA.ID_PRODUCTO
  AND ID_ORDEN = :P54_ID_ORDEN

-- Después:
from DETALLE_ORDEN DE
where DE.ID_ORDEN = :P54_ID_ORDEN
```

**A.2 — Dynamic Actions: auto-completar precio al elegir producto** ✅ Completado 2026-05-25

La página ya tenía 2 DAs y 2 LOVs que consultaban directamente `PRECIO_POR_CATEGORIA`.
Actualizadas para usar `FN_PRECIO_VENTA`:

| Componente | Antes | Después |
|---|---|---|
| DA "Carga de Productoss" (IG columna ID_PRODUCTO) | SELECT desde precio_por_categoria | `:PRECIO_UNITARIO := FN_PRECIO_VENTA(:ID_PRODUCTO, :P54_TIP_CLIENTE)` |
| DA "Carga de Productos" (item P54_PRODUCTO) | SELECT desde precio_por_categoria (filtro categoría comentado) | `:P54_PRE_UNITARIO := FN_PRECIO_VENTA(:P54_PRODUCTO, :P54_TIP_CLIENTE)` |
| LOV columna IG `ID_PRODUCTO` | JOIN con precio_por_categoria | EXISTS sobre PRODUCTO_PROVEEDORES (costo activo) + EXISTS sobre MARGEN_CATEGORIA (margen vigente) |
| LOV item `P54_PRODUCTO` | JOIN con precio_por_categoria | mismo patrón EXISTS |

El item `P54_TIP_CLIENTE` ya existía y se popula vía la DA "Tipo Cliente" cuando cambia `P54_ID_PERSONA` (lee `CLIENTES.CATEGORIA_CLIENTE`).

**A.3 — Validación al guardar (pendiente)**

Si `FN_PRECIO_VENTA` retorna NULL, el precio queda en NULL y APEX permite guardar.
Falta agregar validación a nivel de proceso o columna para bloquear líneas con precio NULL.

#### B. Deprecar p8 y p15

1. Verificar que no estén referenciadas en menús/navegación (`Lists`, `Navigation`)
2. Eliminar las entradas de menú antes de eliminar las páginas
3. Borrar las páginas del export y reimportar la app

#### C. Pantalla ABM de `MARGEN_CATEGORIA` (faltante de Fase 2)

**Implementación:** opción C — spec entregada para que el usuario cree las páginas
en APEX Builder UI (los wizards generan el SQL boilerplate en segundos vs cientos de
líneas si se hace desde cero). Después se exporta y versiona.

**Diseño (implementado en p108 y p109):**

| Página | Tipo | Rol | Estado |
|---|---|---|---|
| **p108** | NORMAL | "Márgenes por Categoría" — IR vigentes + IR historial + botón Nuevo Margen | ✅ Creada 2026-05-25 |
| **p109** | MODAL | "Cambiar Margen" — INSERT nuevo registro (el trigger `TRG_CIERRE_MARGEN_ANTERIOR` cierra el anterior) | ✅ Creada 2026-05-25 |
| Menú | Entrada bajo "Productos" | Label "Márgenes por Categoría", target p108, icon fa-coins | ✅ Agregada 2026-05-25 |

Archivos versionados en `apex-work/f100/application/pages/page_00108.sql`, `page_00109.sql`, y menú actualizado en `apex-work/f100/application/shared_components/navigation/lists/navigation_menu.sql`.

**Nota menor:** p109 tiene items `P109_FECHA_FIN` y `P109_ESTADO` visibles que no son usados por el proceso INSERT (que solo inserta id_categoria, categoria_cliente, porcentaje, fecha_inicio, usuario_creacion). El INSERT funciona correctamente; podrían ocultarse para mejor UX en una iteración futura.

**p115 — Margenes Vigentes (NORMAL)**
- Region 1: IR "Margenes Vigentes" — query:
  ```sql
  select mc.id_margen, c.nombre as categoria, mc.categoria_cliente,
         mc.porcentaje, mc.fecha_inicio, mc.usuario_creacion
  from MARGEN_CATEGORIA mc
  join CATEGORIAS_PRODUCTOS c on c.id_categoria = mc.id_categoria
  where mc.estado = 'ACTIVO' and mc.fecha_fin is null
  order by c.nombre, mc.categoria_cliente
  ```
  - Link de fila → abre p116 con `P116_ID_CATEGORIA` y `P116_CATEGORIA_CLIENTE` precargados
- Region 2: IR "Historial" — todos los registros, ordenados por categoría/segmento/fecha DESC
- Botón "Nuevo Margen" → p116 sin parámetros

**p116 — Cambiar Margen (MODAL)**
- Form region con items:
  - `P116_ID_CATEGORIA` (select list LOV CATEGORIAS_PRODUCTOS)
  - `P116_CATEGORIA_CLIENTE` (select list estático: Mayorista/Minorista)
  - `P116_PORCENTAJE` (number field, requerido)
  - `P116_FECHA_INICIO` (date picker, default TRUNC(SYSDATE))
- Botones: CANCEL (DA dialog cancel), CREATE (INSERT process)
- Process AFTER_SUBMIT: INSERT en MARGEN_CATEGORIA — el trigger `TRG_CIERRE_MARGEN_ANTERIOR` cierra el anterior automáticamente
- Close Dialog AFTER_SUBMIT con REQUEST = CREATE

**Navegación:** agregar entrada en menú Administración (o Productos) apuntando a p115.

#### D. Alerta post-confirmación de factura proveedor (página de comprobante)

Informativa, no requiere acción (todo se actualiza por triggers):
- Success Message tras confirmar: "Costo actualizado — precio de venta recalculado automáticamente"
- Región opcional con tabla comparativa (costo anterior vs nuevo, precio de venta resultante por segmento)
  usando `AUDITORIA_PRODUCTO_PROVEEDOR` + `FN_PRECIO_VENTA`

---

### FASE 6 — Limpieza de objetos obsoletos (opcional)
**Estado:** 🔄 Parcialmente completado — 2026-05-25 (soft deprecation hecha, DROP físico pendiente)  
**Prerrequisito:** Todas las fases anteriores

#### Trigger vacío a eliminar
```sql
-- STOCK_PRODUCTO_T tiene cuerpo "begin null; end;" — dead code
DROP TRIGGER WKSP_WORKPLACE.STOCK_PRODUCTO_T;
```

#### `PRECIO_POR_CATEGORIA` — deprecar
La función `FN_PRECIO_VENTA` reemplaza a esta tabla como fuente de precios de venta.

**Soft deprecation completada 2026-05-25:**
- Entrada de menú "Precio por Categoría" eliminada del navigation_menu por el usuario
- p8 y p15 ya no son accesibles desde la UI
- Las páginas siguen existiendo en APEX pero sin acceso desde el menú

**DROP físico pendiente (futuro):**
1. Verificar que ninguna pantalla APEX la siga referenciando (post Fase 5 ✓ ya verificado)
2. Eliminar las páginas APEX p8 y p15 si se confirma que no son necesarias
3. Archivar datos históricos si se requiere (`INSERT INTO` tabla de archivo o export CSV)
4. `DROP TABLE WKSP_WORKPLACE.PRECIO_POR_CATEGORIA`

#### Tablas de backup a revisar
- `PRODUCTO_PROVEEDORES_BACKUP` — verificar si puede eliminarse o archivarse
- `PRODUCTO_PROVEEDORES_OLD` — ídem

---

## Registro de progreso

| Fase | Descripción | Estado | Fecha | Observaciones |
|---|---|---|---|---|
| 1 | Normalización de datos duplicados en PP | ✅ Completado | 2026-05-25 | 2 registros cerrados: Proveedor 101 (10/05/26→INACTIVO) y Proveedor 1 (10/05/26→INACTIVO) |
| 2 | Tabla MARGEN_CATEGORIA + trigger cierre + carga inicial + pantalla APEX | ✅ Completado | 2026-05-25 | 20 filas cargadas (10 cat × 2 seg). Pantalla APEX pendiente para siguiente iteración |
| 3 | Trigger TRG_CIERRE_PP_ANTERIOR | ✅ Completado | 2026-05-25 | Fix aplicado: AND FECHA_INICIO <= :NEW.FECHA_INICIO para respetar CK_PP_FECHAS |
| 4 | Trigger TRG_ACTUALIZAR_COSTO_COMPRA | ✅ Completado | 2026-05-25 | MERGE reemplazado por INSERT simple. Conversión a PYG via TIPO_CAMBIO incluida. Probado con comprobante 42 |
| 5 | FN_PRECIO_VENTA + integración APEX | ✅ Completado | 2026-05-25 | Función + p54 fix query/DAs/LOVs + p108/p109 ABM Márgenes. Falta: alerta post-confirmación (D) y validación NULL (A.3) |
| 6 | Limpieza de objetos obsoletos | 🔄 Parcial | 2026-05-25 | Soft deprecation completa (menú): p8/p15 sin acceso UI. DROP físico pendiente para futuro |

---

## Decisiones pendientes de confirmar con el negocio

1. **Moneda extranjera en costo:** ¿guardar precio en moneda de factura o convertir siempre a PYG?
2. **Valores de margen por categoría:** confirmar porcentajes reales con el negocio para completar el INSERT de Fase 2 antes de ejecutar
3. **Recálculo de precio de venta:** ¿manual asistido (recomendado) o automático puro al confirmar factura?
4. **Precio de venta con múltiples proveedores:** si un producto tiene dos proveedores con distintos costos, ¿el precio de venta se basa en el costo del proveedor de la última factura confirmada o en el más bajo/alto?

---

## Notas técnicas

- **`INSERT ALL` con `DEFAULT seq.NEXTVAL`:** evitar — Oracle puede generar PK duplicadas dentro de la misma sentencia. Usar `INSERT INTO ... SELECT seq.NEXTVAL, ... FROM (SELECT ... UNION ALL ...)` en su lugar.
- **`TRG_CIERRE_PP_ANTERIOR` y registros futuros:** el trigger no cierra registros con `FECHA_INICIO > :NEW.FECHA_INICIO` para respetar `CK_PP_FECHAS` (que exige `FECHA_FIN >= FECHA_INICIO`). Si coexisten un registro activo de hoy y uno futuro, las queries de "precio vigente" deben filtrar por `FECHA_INICIO <= TRUNC(SYSDATE)` — las tres vistas existentes ya lo hacen.
- **Auto-commit en conexión `tesis_db`:** activo a nivel de driver, no se puede desactivar desde SQLcl. Usar DELETE manual para limpiar datos de test o aceptar que los datos de prueba quedan confirmados.
- **MERGE descartado en TRG_ACTUALIZAR_COSTO_COMPRA:** como siempre se hace INSERT (nuevo precio = nueva fila), el MERGE no agrega valor. `TRG_CIERRE_PP_ANTERIOR` maneja el cierre del anterior en ambos casos (existía o no existía registro previo).
- Los scripts de cada fase deben ejecutarse en el schema `WKSP_WORKPLACE`
- El usuario de conexión para desarrollo es `tesis_db` (ADMIN)
- Siempre ejecutar el script de diagnóstico/verificación antes de confirmar cada fase
- `TRG_AUD_PP` cubre auditoría de todos los cambios en `PRODUCTO_PROVEEDORES` — no requiere lógica adicional de historial
- `TRG_MOV_STOCK_DETALLE_PROV` está DISABLED y **no reactivar** — el stock de compras lo maneja `TRG_MOV_STOCK_RECEPCION`
- En caso de cambio de alcance, documentar en el plan
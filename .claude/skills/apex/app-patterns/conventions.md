# App 100 Conventions — SolSGE

## Template IDs

### Region Templates
| ID | Name / Usage | Typical Context |
|----|--------------|-----------------|
| `4501440665235496320` | NATIVE_FORM container | Region raíz de formularios (query_type TABLE, editable) |
| `4072358936313175081` | Standard region (t-Region--scrollBody) | Sub-secciones dentro de form: Cabecera, Detalle, Totalizador |
| `2126429139436695430` | Buttons bar | Barra de botones en modales (REGION_POSITION_03) |
| `2100526641005906379` | Interactive Grid region | IGs dentro de secciones (t-IRR-region--hideHeader) |

### Page Templates
| ID | Name / Usage |
|----|--------------|
| `2100407606326202693` | Modal dialog (ui-dialog--stretch, resizable) |
| (default) | Páginas normales (no especifican step_template) |

### Label Templates
| ID | Usage |
|----|-------|
| `1609122147107268652` | Campo **requerido** (`p_is_required=>true`) |
| `1609121967514267634` | Campo **opcional** |

### Button Template
| ID | Usage |
|----|-------|
| `4072362960822175091` | Todos los botones sin excepción |

---

## Naming Conventions

- **Items:** `P<page>_<COLUMN_NAME>` — confirmado en todas las páginas (P10_ID_PERSONA, P72_ID_ORDEN_COMPRA)
- **Botones:** CANCEL / DELETE / SAVE / CREATE — nombres en mayúsculas, en inglés, consistentes
- **Regiones de sección:** Cabecera / Detalle / Totalizador — en español, siempre hijos del NATIVE_FORM
- **IGs:** nombre descriptivo del objeto (Detalle_Orden_Compra, Detalle_V, Detalle_Venta) — usado como `p_region_name` para referencia JS
- **DAs:** Cancel Dialog / Carga de Productos / Totalizador / Recalcular Total IG — en español o descriptivo
- **Procesos:** Initialize form <Nombre> / Process form <Nombre> / Close Dialog — patrón fijo

---

## Sequence Style

- **Items:** incremento de 10 (10, 20, 30...), PK hidden siempre en seq 10
- **Botones:** incremento de 10 (10 CANCEL, 20 DELETE, 30 SAVE, 40 CREATE)
- **DAs:** incremento de 10
- **Procesos:** BEFORE_HEADER seq 10; AFTER_SUBMIT: DML en seq 10, IG DML en seq 20, Close Dialog en seq 30

---

## Patrón Modal (list + form)

Todas las entidades siguen el patrón par de páginas:
- **Página impar / lista**: IR o IG, botón Create que abre modal
- **Página par / modal**: NATIVE_FORM, botones CANCEL+DELETE+SAVE+CREATE

Ejemplos: 9↔10 (Personas), 71↔72 (OC), 13↔14 (Roles), 21↔22 (Oficinas)

---

## Botones estándar en modales

```sql
-- CANCEL (siempre presente)
p_button_name=>'CANCEL', p_button_action=>'DEFINED_BY_DA',
p_button_position=>'CLOSE', p_warn_on_unsaved_changes=>null

-- DELETE (solo si PK no nula)
p_button_name=>'DELETE', p_button_action=>'SUBMIT',
p_button_position=>'DELETE', p_confirm_style=>'danger',
p_button_condition=>'P<N>_<PK>', p_button_condition_type=>'ITEM_IS_NOT_NULL',
p_database_action=>'DELETE'

-- SAVE (hot, solo si PK no nula)
p_button_name=>'SAVE', p_button_is_hot=>'Y',
p_button_action=>'SUBMIT', p_button_position=>'NEXT',
p_button_condition_type=>'ITEM_IS_NOT_NULL', p_database_action=>'UPDATE'

-- CREATE (hot, solo si PK nula)
p_button_name=>'CREATE', p_button_is_hot=>'Y',
p_button_action=>'SUBMIT', p_button_position=>'NEXT',
p_button_condition_type=>'ITEM_IS_NULL', p_database_action=>'INSERT'
```

---

## Defaults de items frecuentes

```sql
-- Empleado del usuario logueado
p_item_default_type=>'SQL_QUERY'
p_item_default=>'SELECT ID_EMPLEADO FROM EMPLEADOS WHERE UPPER(CODIGO_USUARIO) = UPPER(:APP_USER)'

-- Fecha actual (zona horaria Argentina)
p_item_default_type=>'SQL_QUERY'
p_item_default=>'SELECT CURRENT_TIMESTAMP AT TIME ZONE ''America/Argentina/Buenos_Aires'' AS FECHA FROM dual'

-- Estado inicial borrador
p_item_default=>'B'   -- (B=borrador, P=pendiente, A=aprobado, etc.)

-- Usuario display-only
p_item_default_type=>'EXPRESSION', p_item_default_language=>'PLSQL'
p_item_default=>':APP_USER'
```

---

## Dynamic Actions comunes

| Nombre | Trigger | Acciones |
|--------|---------|---------|
| Cancel Dialog | Clic en CANCEL | NATIVE_DIALOG_CANCEL |
| Carga de Productos | Change en columna ID_PRODUCTO (IG) | EXECUTE_PLSQL → JavaScript recalculaImporte() |
| Totalizador | Change en región IG (DEBOUNCE 500ms) | JavaScript recalculaImporte() → EXECUTE_PLSQL TOTAL=CANT*PRECIO |
| Recalcular Total IG | interactivegridselectionchange | JavaScript recalculaImporte() |
| REFRESCAR | Change en ID_PROVEEDOR/FK | NATIVE_REFRESH sobre IG dependiente |

---

## Patrón recalculaImporte() (JavaScript en página)

Presente en páginas con IG de detalle (Ventas, Compras). Itera el modelo del IG, suma TOTAL_DETALLE (o TOTAL), y setea items APEX con `apex.item('P<N>_TOTAL').setValue(Math.round(total))`.

La versión de Ventas (P67) también desglosa IVA 5% e IVA 10% por columna PORCENTAJE.

---

## Procesos estándar de formulario

```
BEFORE_HEADER, seq 10:  NATIVE_FORM_INIT  (Initialize form <Nombre>)
AFTER_SUBMIT,  seq 10:  NATIVE_FORM_DML   (Process form <Nombre>)
AFTER_SUBMIT,  seq 20:  NATIVE_IG_DML     (si hay IG editable — PL/SQL APEX$ROW_STATUS)
AFTER_SUBMIT,  seq 30:  NATIVE_CLOSE_WINDOW (Close Dialog, when REQUEST IN CREATE,SAVE,DELETE)
```

### IG DML — patrón PL/SQL

```sql
begin
  case :APEX$ROW_STATUS
    WHEN 'C' THEN INSERT INTO <tabla>(...) VALUES (...);
    WHEN 'U' THEN UPDATE <tabla> SET ... WHERE ID = :<PK_COLUMN>;
    WHEN 'D' THEN DELETE <tabla> WHERE <PK> = :<PK_COLUMN>;
  END CASE;
end;
```

---

## Seguridad y autorización

- **Esquema:** `AUTH_PAGE_BY_PRIV` — llama `security_pkg.can_access(:APP_ID, :APP_USER, :APP_PAGE_ID, NULL)`
- **Menú:** cada item usa `security_pkg.can_access(:APP_ID, :APP_USER, <page_id>, NULL)` como condición de display
- **Autenticación:** `AUT_PKG.AUTENTICACION_LOGIN` (NATIVE_CUSTOM)
- **Roles:** tabla ROLES → ROLES_PRIVILEGIOS → PRIVILEGIOS → RECURSOS (page_id + component)

---

## Vistas y funciones de negocio

| Objeto | Tipo | Uso |
|--------|------|-----|
| `V_PRODUCTO_PROVEEDOR_VIGENTE` | Vista | Precios vigentes por producto-proveedor (columna VIGENCIA='VIGENTE') |
| `V_COMPARATIVA_PRECIO_PROVEEDORES` | Vista | Precio mínimo por producto (RANKING_PRECIO=1) |
| `FN_GET_LIMITE_OC_MENSUAL(mes, año)` | Función | Límite mensual de órdenes de compra (desde PARAMETROS) |
| `security_pkg.can_access()` | Package | Control de acceso por página/componente |
| `AUT_PKG.AUTENTICACION_LOGIN` | Package | Autenticación custom |

---

## LOVs más usados

| LOV Name | Tabla fuente | Usado en páginas |
|----------|-------------|------------------|
| PROVEEDORES.NOMBRE | PROVEEDORES + PERSONAS | 72, 70, 36 |
| OFICINAS.DESCRIPCION | OFICINAS | 22, 53, 64, 72 |
| PRODUCTOS.NOMBRE | PRODUCTOS + PRECIO_POR_CATEGORIA | 67 (filtrado por categoria cliente) |
| PRODUCTOS.PROVEEDOR.PRECIO | V_PRODUCTO_PROVEEDOR_VIGENTE + V_COMPARATIVA | 72 (popup LOV multicol) |
| DOCUMENTOS.DESCRIPCION | DOCUMENTOS | 10 |
| PERSONAS.TIPO_PERSONAS | Referencia dinámica | 10 |
| GENERO.PERSONAS | Referencia dinámica | 10 |

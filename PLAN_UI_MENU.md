# PLAN_UI_MENU — Ediciones ABM + Reorganización del menú (2026-07)

Trabajo de UI sobre pantallas existentes (no toca backend/DB) + reorganización completa
del **menú de navegación** (`Navigation Menu`, list id `7706470273831245`) por procesos de
negocio. Todo importado **aislado** (páginas con `install_pXX.sql`; menú con
`install_component.sql`) y validado en vivo.

> **Gotcha de importación (recordar):** cuando un `page_*.sql` o el `navigation_menu.sql`
> contiene caracteres acentuados o la `ñ` (columna `EMPLEADOS."CONTRASEÑA"`, labels con
> tildes), importar forzando UTF-8: `export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"`
> antes de `sql -S -name tesis_db @install_...`. Si no, SQLcl lee el archivo con otra
> codificación y falla (`ORA-00904`) o corrompe el texto. Los acentos en el menú se guardan
> con `unistr('...\00F3...')` (ó=00F3, í=00ED, é=00E9, á=00E1, Ñ=00D1), igual que el resto
> del export — no "arreglar" a literal.

## 1. Ediciones de páginas (ABM / display)

### Clientes — P4 (grilla) + P48 (form)
- **P4 (IG `CLIENTES`):** se agregó columna **Editar** (`APEX$LINK` / `NATIVE_LINK`) que abre
  el form modal P48 pasando `P48_ID_PERSONA` (patrón de P9). Se cambió la fuente de TABLA a
  **SQL** con join a `PERSONAS` para mostrar la columna **Nombre**
  (`TRIM(REGEXP_REPLACE(nombres||apellidos,' +',' '))`).
- **P48 (form `CLIENTES`):** fix del LOV de **Estado** (guardaba la palabra `Activo/Inactivo`
  cuando la BD usa `A/I` → `STATIC:Activo;A,Inactivo;I`); **botón Eliminar removido**;
  **Fecha Registro** solo lectura (Always); **Persona** solo lectura en edición
  (`ITEM_IS_NOT_NULL` sobre `P48_ID_PERSONA`) → en edición solo se cambian Estado y Categoría.
- Instalador: `install_p4_p48.sql`.

### Empleados — P16 (IR) + P20 (form)
- Campo `EMPLEADOS.ACTIVO` guarda `S/N` pero se mostraba crudo.
- **P16 (IR):** la columna de un IR no traduce por LOV → se cambió la región a **SQL** con
  `CASE ACTIVO WHEN 'S' THEN 'Activo' WHEN 'N' THEN 'Inactivo' END`. La query incluye
  `e."CONTRASEÑA"` (columna con ñ) → **importar con UTF-8 forzado**.
- **P20 (form):** `P20_ACTIVO` pasó de campo de texto a **select list**
  `STATIC:Activo;S,Inactivo;N` (default `S`).
- Instalador: `install_p16_p20.sql`.

### Proveedores — P41 (IR) + Contactos — P43 (IG)
- **P41 "Proveedores"** (antes "Proveedores IG"): renombrado; se agregó columna-link
  **Ver contactos** (`p_column_link` → P43 filtrada por `P43_ID_PROVEEDOR = #ID_PERSONA#`).
  Respetada la columna `PLAZO_PAGO_DIAS` que el PO agregó en el Builder.
- **P43 "Contactos"** (antes "Contactos IG"): renombrado; región IG pasó a **SQL** con
  `WHERE (:P43_ID_PROVEEDOR IS NULL OR ID_PROVEEDOR = :P43_ID_PROVEEDOR)` + ítem oculto
  `P43_ID_PROVEEDOR` → se abre filtrada desde P41 o completa desde el menú. La columna
  "Id Proveedor" (que mostraba el `CODIGO_USUARIO` vía LOV) se reconvirtió a **Proveedor**
  (display-only con el **nombre** desde `PERSONAS`, subquery por `ID_PROVEEDOR = ID_PERSONA`).
- Relación confirmada: `PROVEEDOR_CONTACTOS.ID_PROVEEDOR` → `PROVEEDORES.ID_PERSONA`
  (FK `FK_CONTACTO_PROVEEDOR`), 1:N. Se decidió **mantener** ambas páginas (no fusionar) y
  conectarlas con "Ver contactos".
- Instaladores: `install_p41_p43.sql`, `install_p43.sql`.

## 2. Reorganización del menú de navegación

Se reagrupó por **procesos de negocio** (antes eran grupos sueltos). Cambios:

- **Personas** absorbe **Clientes** y **Proveedores** como subgrupos.
- **Ventas** absorbe el ciclo de ingresos: subgrupos **Cobranzas** (antes "Cuentas a Cobrar")
  y **Caja**. La entrada **Reversos de Cobro** (p129) se **eliminó del menú** (el módulo
  sigue oculto por `PARAMETROS.REVERSO_COBRO_ACTIVO='N'`; la página existe).
- **Compras** → **"Compras y Pagos"** (ya contenía Deuda a Proveedores / Órdenes de Pago).
- **Inventarios** → **"Productos e Inventario"** (paraguas) con **Productos** como subgrupo.
- **Reportes** (en Ventas) y **Reporte Inventario** quedaron como **agrupadores** (sin link).
- **Administration** → **"Configuración"** (en español).
- **Metas** movidas a su dominio: *Metas de Venta* → Ventas; *Metas de Cobranza* → Cobranzas.
- **Typos** corregidos (con `unistr`): Categoría, Configuración de Cajas, Conteo Físico,
  Cotización, Métodos de Pago, Revisión, y "Dashboard **interactivo** Ventas".
- **Íconos** de grupos: Caja `fa-cash-register`, Compras y Pagos `fa-shopping-cart`,
  Seguridad `fa-shield`, Productos e Inventario `fa-package`, Configuración `fa-cog`,
  Proveedores (subgrupo) `fa-truck`.

> **Gotcha de íconos (recordar):** **Font APEX ≠ Font Awesome** en los nombres. `fa-boxes`
> **NO existe** en Font APEX → el ícono queda en blanco (sin error). `fa-cog`, `fa-truck`,
> `fa-package`, `fa-cash-register`, `fa-shield` sí son válidos. Ante la duda, usar un ícono
> ya presente en la app o validarlo en el selector del Builder.

> **Gotcha de orden en el import del menú (recordar):** al importar la lista, APEX crea los
> `create_list_item` **en orden de archivo** y valida la FK del padre
> (`PARENT_LIST_ITEM_FK`). Si un ítem referencia como padre a otro que aparece **más abajo**
> en el archivo → `ORA-02291`. El padre debe estar **antes** que el hijo en el `.sql`
> (reordenar el bloque si hace falta). El import es todo-o-nada (rollback), así que un fallo
> no deja el menú a medias.

### Árbol final del menú
```
Home [p1]
Personas (grupo)
├─ Empleados [p2] (oculto, NEVER)
├─ Empleados Roles [p11]
├─ Empleados [p16]
├─ Personas [p9]
├─ Clientes (subgrupo)
│   ├─ Oficinas [p21] · Departamentos [p23] · Ciudades [p26] · Clientes [p4]
└─ Proveedores (subgrupo)
    ├─ Proveedores [p41] · Contactos [p43]
Ventas (grupo)
├─ Proceso Ventas [p66] · Presupuesto [p52]
├─ Reportes (agrupador)
│   ├─ Reservas de Productos [p59] · Presupuestos Anulados y Vencidos [p111]
│   └─ Dashboard interactivo Ventas [p133] · Dashboard de Cobros [p136]
├─ Aprobación de Presupuestos [p117] · Anulaciones de Facturas [p120] · Notas de Crédito [p124]
├─ Metas de Venta [p140]
├─ Cobranzas (subgrupo)
│   ├─ Cobros [p95] · Recibos de Cobro [p131] · Metas de Cobranza [p138]
└─ Caja (subgrupo)
    ├─ Configuración de Cajas [p63] · Apertura de Caja [p65] · Cierre de Caja [p61]
    └─ Movimientos Caja [p123] · Estado de Caja [p62]
Productos e Inventario (grupo)
├─ Productos (subgrupo)
│   ├─ Productos [p5] · Producto Proveedor [p25] · Marcas [p37] · Categoría [p40] · Márgenes por Categoría [p108]
├─ Ajuste Manual de Stock [p32] · Stock de Productos [p47] · Transferencia de Stock [p113]
├─ Reporte Inventario (agrupador)
│   ├─ Movimiento de Stock [p56] · Existencias [p88] · Dashboard de Inventario [p142]
└─ Proceso de Inventario [p79] · Conteo Físico [p73] · Revisión [p80]
Compras y Pagos (grupo)
├─ Proceso de Compras [p69] · Orden de Compra [p71] · Nota de Credito Proveedor [p94]
├─ Recepción de Orden de Compra [p107] · Aprobación de Órdenes de Compra [p110]
└─ Deuda a Proveedores [p146] · Órdenes de Pago [p148] · Dashboard de Compras [p144]
reset-password [p102]   (técnica; no visible en la práctica)
Configuración (grupo)
├─ Roles [p13] · Monedas [p17] · Planes Cuota [p38] · Talonarios [p51]
└─ Métodos de Pago [p57] · Formas de Pago [p89] · Cotización [p101] · Parámetros [p103]
Seguridad (grupo)
└─ Privilegios [p75] · Roles - Privilegios [p81] · Recursos [p77]
```

## 3. Pendientes / no hechos (a propósito)
- **Íconos basura en hojas** (autogenerados, quedan feos): Clientes p4 `fa-head-ai-sparkle`,
  Productos p5 `fa-ai-sparkle-generate-audio`, Oficinas p21 `fa-coffee`. No tocados.
- **Empleados p2** (IG vieja) sigue en el menú pero oculta (`NEVER`); candidata a borrar.
- **reset-password p102** sigue como entrada de 1er nivel (técnica).
- P43: el botón "Crear" contacto no pre-carga el proveedor cuando la grilla está filtrada.

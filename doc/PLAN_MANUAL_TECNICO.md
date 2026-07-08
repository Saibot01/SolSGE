# PLAN_MANUAL_TECNICO — Manual Técnico para el libro de tesis

**Objetivo:** producir el **Manual Técnico** de **SolSGE** (Oracle APEX, App 100 — ver
`CLAUDE.md`), dirigido al **desarrollador/mantenedor** del sistema. Documenta arquitectura,
modelo de datos, backend, seguridad, integración fiscal, despliegue y mantenimiento, con el
**formato visual de la cátedra** (portada, banner UNA-FP, A4) reutilizando la infra de los diagramas.

> **Cómo usar este plan en una sesión nueva:** *"Leé `doc/PLAN_MANUAL_TECNICO.md` y arrancá por
> el diagrama ER + el diccionario de datos."* Todo el contexto necesario está acá.

---

## Contexto: el "libro de tesis" (4 documentos)

1. **Diagramas UML** — ✅ **HECHO** (`doc/diagramas/Diagramas_UML_SOLSGE.docx`, 95 págs; `doc/PLAN_DIAGRAMAS.md`).
2. **Anteproyecto** — ✅ **HECHO** (`doc/Final 2026/Anteproyecto - Proyecto I.docx`; `doc/PLAN_ANTEPROYECTO.md`).
3. **Manual de Usuario** — pendiente (plan futuro; enfoque paso-a-paso con capturas, orientado al usuario final).
4. **Manual Técnico** — 👈 **ESTE plan**.

Debe quedar **consistente** con los otros tres: mismos módulos, actores, nombre del sistema
(**"Sole – Sistema de Gestión Empresarial"**, sigla **SOLSGE**, empresa "Sole Informática") y
vocabulario. **Reutiliza** los diagramas ya hechos (no los rehace).

---

## Fuente de verdad (nunca inventar)

- **La BD en vivo** (conexión SQLcl `tesis_db`, esquema `WKSP_WORKPLACE`): 76 tablas, 117 FK,
  1053 columnas. Diccionario, ER, índices y constraints se **leen** de ahí
  (`ALL_TABLES`, `ALL_TAB_COLUMNS`, `ALL_CONSTRAINTS`, `ALL_CONS_COLUMNS`, `ALL_INDEXES`).
- **`db/*.sql`** (47 scripts, F2–F27): DDL, paquetes, procs, triggers, vistas, funciones KuDE.
  Cada feature tiene su archivo → la sección de backend referencia el archivo fuente.
- **`apex-learn/f100/`**: export read-only de la app (118 páginas, componentes compartidos,
  auth schemes) = fuente para la sección APEX. **No** `apex-work/` (es staging de parches).
- **`CLAUDE.md` + los `PLAN_*.md`**: contexto de negocio, decisiones y gotchas por feature.
- **Los diagramas ya hechos** (`doc/diagramas/`): se referencian para la vista lógica.

---

## Decisiones tomadas (2026-07-08, con el alumno)

1. **Plantilla:** no hay plantilla obligatoria del profesor para el Manual Técnico → **estructura
   estándar** (índice de abajo) con el **formato visual de la cátedra** (portada, banner UNA-FP, pie, A4).
2. **Diccionario de datos: EXHAUSTIVO**, leído de la BD — todas las tablas de negocio con sus
   columnas, tipos, PK/FK y constraints, **agrupadas por módulo**. (Complementa el alto nivel del anteproyecto.)
3. **Código PL/SQL: solo descripción + referencia.** Describir qué hace cada componente
   (paquete/proc/función/trigger/vista), sus parámetros y efectos, y **referenciar el archivo en `db/`**;
   **sin volcar el fuente** (ya está versionado en el repo). Snippets solo si son imprescindibles para entender algo.
4. **Capturas: mínimas** — solo técnicas puntuales (App Builder, esquema de despliegue, config).
   El grueso de capturas de la app va en el Manual de Usuario.
5. **Diagrama ER (NUEVO, pedido por el alumno):** incluir un **modelo entidad-relación** del esquema.
6. **Carga inicial de datos (NUEVO):** documentar los **datos maestros/paramétricos obligatorios**
   para dejar el sistema operativo (PARAMETROS, roles/privilegios, oficinas/cajas/talonarios,
   catálogos), separados de los datos demo. Ver §8.x.
7. **"Instalación" en la nube (aclaración):** el usuario final **no instala nada** (solo navegador +
   URL). Lo que se documenta es el **despliegue/puesta en marcha del entorno** para el mantenedor. Ver §8.

---

## Diagrama ER — análisis y decisión

**Factibilidad verificada (2026-07-08).** El esquema es 100% introspectable y el toolchain ya está.

- **Herramienta elegida: PlantUML auto-generado desde la BD.**
  - `java 17` + `plantuml.jar` ya instalados y probados (rendearon los 54 diagramas sin GraphViz,
    vía el motor **Smetana** — no requiere `dot`).
  - El `.puml` se **genera automáticamente** con una query a `ALL_TAB_COLUMNS` + `ALL_CONSTRAINTS`
    + `ALL_CONS_COLUMNS` que emite `entity` (columnas con marca PK/FK) y relaciones **crow's-foot**
    (notación IE, p. ej. `}o--||`) desde las FK reales. **Cero dibujo manual, cero invención.**
  - Mismo pipeline (`plantuml.jar -tpng`) y mismo `docxlib.js` que el resto del libro.
- **Partición: por módulo** (76 tablas/117 FK es ilegible en un solo diagrama; se hace lo mismo que
  con las clases). Módulos: Ventas, Facturación/Caja, Cobros/CxC, Compras/CxP, Inventario,
  Fiscal/Talonarios, Seguridad, (Reportes = metas/vistas). Opcional: un **mapa global** de entidades
  agrupadas por módulo (cajas sin columnas) como portada de la sección.
- **Distinción clave:** el ER es el esquema **físico** (tablas/columnas/FK reales); los diagramas de
  **clases** ya hechos son la vista **lógica**. Son complementarios → el Manual Técnico enlaza a los
  de clases y aporta el ER físico.
- **Descartados:** SchemaSpy (necesita GraphViz, no instalado); mermaid-cli (no instalado).
- **Fallback (versión interactiva/estética):** emitir **DBML** desde la misma query y pegarlo en
  **dbdiagram.io** para una vista web; es un paso manual (no automatizable en sesión) → solo si el
  alumno quiere además una versión online. El entregable del libro es el PlantUML embebido.

---

## Estructura propuesta del Manual Técnico

1. **Introducción** — propósito del manual, alcance, audiencia (desarrollador/mantenedor), documentos relacionados.
2. **Arquitectura del sistema**
   - Stack tecnológico: Oracle APEX 24.2, Oracle Autonomous Database 23ai, ORDS, wallet SSL, navegador.
   - Arquitectura en capas (BD/PL-SQL ↔ metadatos APEX ↔ navegador) y por qué "low-code".
   - Diagrama de despliegue / componentes (nube de Oracle, workspace, esquema de parseo).
3. **Modelo de datos**
   - **Diagrama ER por módulo** (PlantUML auto-generado, ver sección ER).
   - **Diccionario de datos exhaustivo** por módulo (tabla → columnas, tipo, nulabilidad, PK/FK, comentario).
   - Secuencias e índices relevantes; convenciones de nombres de objetos.
4. **Componentes del backend (PL/SQL)** — *descripción + referencia a `db/`, sin fuente completo*
   - Convenciones: catálogo de errores `-20xxx` por rango/feature; regla de fecha/hora
     (`FN_HOY`/`FN_AHORA`, BD en UTC — `GUIA_FECHA_HORA.md`); idempotencia de `db/`.
   - Paquetes (p. ej. `PKG_EMPLEADOS`, `INVENTARIO_PKG`, funciones en `WKSP_WORKPLACE`).
   - Procedimientos/funciones clave por módulo (facturar, `FN_COBRAR_CUOTA`, `CERRAR_CAJA` v3,
     `PRC_SOLICITAR/APROBAR_NOTA_CREDITO`, `PRC_GENERAR/CONFIRMAR_ORDEN_PAGO`, `PRC_REGISTRAR_NC_COMPRA`…).
   - Triggers (`TRG_INS_CUENTAS_COBRAR/PAGAR`, stock, `TRG_TALONARIO_DERIVA_OFICINA`…).
   - Vistas (`V_CAJA_SALDO`, `V_VENTAS_*`, `V_COBROS_*`, `V_INV_*`, `V_CMP_*`, `V_CXP_DEUDA`…) como source of truth de reportes.
   - Funciones de documentos (KuDE HTML: factura/recibo/NC/arqueo/orden de pago) y su alcance.
5. **Aplicación APEX**
   - App 100 / alias `f100`, workspace `WKSP_WORKPLACE`, `IMAGE_PREFIX` (CDN Oracle), release 24.2.17.
   - **Mapa de páginas por módulo** (P## → función) leído de `apex-learn/f100`.
   - Componentes compartidos: LOVs, listas de navegación (menú), plantillas, procesos de aplicación.
   - Autenticación y autorización (esquemas, control por rol en páginas/regiones/botones).
6. **Seguridad**
   - Modelo RBAC: `EMPLEADOS` / `ROLES` / `PRIVILEGIOS` (+ `EMPLEADOS_ROLES`, `ROLES_PRIVILEGIOS`).
   - Login: bloqueo por intentos fallidos, manejo de tokens (`PKG_EMPLEADOS`).
   - Buenas prácticas aplicadas (parámetros, datos sensibles).
7. **Integración fiscal (SET / SIFEN)**
   - Talonarios timbrados: numeración establecimiento-punto-expedición, derivación desde `CAJA_CONF` (F10/F27).
   - KuDE (representación gráfica) y su **alcance real**: sin CDC/QR, "sin validez fiscal", no integrado a SIFEN.
8. **Despliegue y puesta en marcha** *(NO es "instalación en el cliente")*
   - **Aclaración clave (nube):** el **usuario final no instala nada** — accede por navegador con la
     URL del sistema (APEX en Oracle Cloud). Esta sección es para el **desarrollador/mantenedor**:
     describe cómo **reproducir/desplegar el entorno** desde cero (recuperación ante desastres,
     migración a otra cuenta de Oracle Cloud, ambiente de evaluación), no cómo instalar en cada PC.
   - Requisitos del entorno: ADB 23ai, APEX 24.2, wallet SSL (vence 2031-03-26), SQLcl.
   - Desplegar la app APEX en el workspace (`apex-work/f100` + `install_page.sql`/`install_component.sql`;
     `set/end_environment`). Crear el esquema y correr las migraciones `db/` en orden por SQLcl
     (idempotentes, con bloque de verificación).
   - **8.x Carga inicial de datos (bootstrap)** — sin esto el sistema no opera. Distinguir:
     - **Datos maestros/paramétricos OBLIGATORIOS** (leídos de la BD real):
       - `PARAMETROS`: **EMPRESA** (emisor del KuDE: `RAZON_SOCIAL`, `RUC`, `DIRECCION`, `CIUDAD`,
         `TELEFONO`, `ACTIVIDAD_ECONOMICA`, `TIPO_CONTRIBUYENTE`) y **reglas de negocio**
         (`HORAS_LIMITE_CANCELACION`=48, `DIAS_VIGENCIA_PRESUPUESTO`=15, `LIMITE_MONTO_OC_MENSUAL`,
         `COSTO_VENTANA_DIAS`=90, `VALIDAR_STOCK_MAXIMO_EN_OC`, `REVERSO_COBRO_ACTIVO`=N).
       - **Seguridad** (para poder entrar): `ROLES`, `PRIVILEGIOS`, `ROLES_PRIVILEGIOS` y al menos
         un usuario administrador en `EMPLEADOS`.
       - **Estructura fiscal:** `OFICINAS` (con establecimiento SET), `CAJA_CONF` (con punto de
         expedición) y `TALONARIOS` timbrados — prerequisito para facturar.
       - **Catálogos de referencia:** `MONEDAS`, `METODOS_PAGO`, `TIPO_IVA`, `MOTIVOS_NOTA_CREDITO`.
     - **Datos demo/transaccionales (NO obligatorios):** productos demo, metas demo, seeds de
       Ventas/Cobros/Inventario/Compras (`db/F18/F22/F23/F25_seed_*`) — solo para la defensa; se listan
       aparte y se aclara que no son necesarios para operar.
   - Configuración final: timezone/`FN_HOY` (BD en UTC), conexión wallet, `IMAGE_PREFIX`.
9. **Mantenimiento y operación**
   - Versionado: dos árboles APEX (`apex-learn` read-only vs `apex-work` staging) y cuándo usar cada uno.
   - Gotchas documentados: BD en UTC, `MOVIMIENTOS_CAJA.MONEDA` texto vs `COMPROBANTES.MONEDA` código,
     `MOVIMIENTOS_CAJA.ESTADO` = abierta/cerrada (no activo/anulado), módulo Reverso oculto a propósito.
   - Respaldo/restauración y re-export de la app.
10. **Anexos** — catálogo completo de errores `-20xxx`, glosario técnico, índice de scripts `db/`.

---

## Toolchain (mismo que el libro — ya verificado)

- **Generación del `.docx`:** infra compartida `doc/diagramas/_build/docxlib.js` (portada, banner UNA-FP,
  pie con nº de página, A4, `portrait/landscapeSection`, `buildDoc`). Crear
  `doc/manual_tecnico/build.js` que la requiera (patrón de `doc/diagramas/<modulo>/build.js`).
  Node v20 + `docx` ya instalados en `_build/node_modules`.
- **ER:** query SQL → `.puml` (uno por módulo) en `doc/manual_tecnico/er/` →
  `java -jar plantuml.jar -tpng -charset UTF-8` → `.png` embebidos por `docxlib`.
- **Diccionario:** query a la BD → generar las tablas del diccionario (una fila por columna) programáticamente.
- **Preview/validación (gotchas de esta máquina — ver memoria):**
  - `PYTHONUTF8=1` obligatorio en los scripts de la skill `docx`.
  - El `soffice.py` de la skill NO corre en Windows → usar `soffice.exe` directo para PDF; `pypdf` para
    contar páginas/extraer texto; 1 hoja → PNG con `soffice --convert-to png` para verificación visual.
  - **Cerrar Word** antes de re-generar el `.docx` (si no, `EBUSY`; deja `~$*.docx`, ya gitignored).
- **Orientación:** ER anchos → landscape (A4 apaisado); texto y diccionario → portrait. Agrupar por bloque
  (una sola rotación), igual que en los diagramas.
- Trabajo en `main` (como quedó definido con el alumno para el anteproyecto), commits `docs(manual-tecnico): …`.

---

## Pasos sugeridos

1. **Piloto primero** (validar formato/nivel con el alumno antes de escalar), sobre **un módulo** (p. ej. Facturación/Caja):
   - Generar su **ER** (query → `.puml` → `.png`).
   - Escribir su **diccionario de datos** (desde la BD) y su sección de **backend** (descripción + refs a `db/`).
   - Armar un `.docx` de muestra (portada + esa sección) y mostrarlo para aprobar estilo.
2. Aprobado el molde, generar los **ER de todos los módulos** y el **diccionario exhaustivo** completo.
3. Redactar las secciones 1–2 y 5–10 (arquitectura, APEX, seguridad, fiscal, despliegue, mantenimiento, anexos).
4. Ensamblar el documento combinado con `docxlib` (bloque vertical: texto+diccionario; bloque apaisado: ER).
5. `pack`/validar → preview PDF (soffice.exe + pypdf) → abrir en Word para el alumno.
6. Commit en `main`.

## Fuera de alcance (de este plan)

- **Manual de Usuario** (documento 3; plan aparte, orientado al usuario final con capturas paso a paso).
- Rehacer diagramas UML o el anteproyecto (ya hechos).
- Integración SIFEN real / CDC / QR (nunca estuvo en alcance del sistema).

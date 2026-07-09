# Manual Técnico — SOLSGE

Cuarto documento del libro de tesis (junto con Diagramas UML, Anteproyecto y Manual de
Usuario). Dirigido al **desarrollador/mantenedor**: arquitectura, modelo de datos, backend,
seguridad, integración fiscal, despliegue y mantenimiento del sistema.

**Entregable:** `Manual_Tecnico_SOLSGE.docx` (A4, formato de la cátedra: portada, banner
UNA-FP, Times New Roman 12, interlineado 1.5). Se genera con `node build_manual.js`.

## Estructura del documento

1. Introducción · 2. Arquitectura · **3. Modelo de datos** (diccionario exhaustivo por módulo)
· **4. Backend** (paquetes/funciones/procedimientos/triggers/vistas por módulo) · 5. Aplicación
APEX · 6. Seguridad · 7. Integración fiscal (SET/SIFEN) · 8. Despliegue y carga inicial · 9.
Mantenimiento · 10. Anexos · **Anexo A** (los 7 modelos ER, en bloque apaisado al final).

Regla de orientación: el cuerpo va vertical y **todos los ER se agrupan en horizontal al final**
(una sola transición de orientación).

## Fuente de verdad

Todo se lee de la **BD real** (esquema `WKSP_WORKPLACE`) y del export APEX read-only
(`apex-learn/f100`). No se inventa nada, no se citan archivos de migración ni fases de
implementación, no se documentan conteos de filas ni historia: se describe el sistema **tal como
está desplegado**.

## Pipeline (todo reproducible)

```
1. _data/dump_schema.sql   ── SQLcl (SPOOL) ─▶  _data/*.csv   (columnas, PK, FK, checks, comments)
2. node _gen/generate.js   ── valida cobertura de tablas y emite er/*.puml,
                              luego renderiza er/*.png con PlantUML
3. node build_manual.js    ── ensambla Manual_Tecnico_SOLSGE.docx
```

### 1. Volcar el esquema (solo si cambió la BD)

```
sql -S -name tesis_db @doc/manual_tecnico/_data/dump_schema.sql
```

### 2. Generar los ER

```
node doc/manual_tecnico/_gen/generate.js
```

Valida que **cada tabla de negocio quede en exactamente un módulo** (sin duplicados ni
faltantes; las vistas y las tablas de infraestructura se excluyen) y genera `er/er_<modulo>.puml`
+ su PNG.

> **Importante:** el render usa `-DPLANTUML_LIMIT_SIZE=16384`. Con el límite por defecto (4096 px)
> PlantUML **recorta** los ER grandes (Facturación, Compras) al generar el PNG.

### 3. Ensamblar el `.docx`

```
node doc/manual_tecnico/build_manual.js
```

### Preview (Windows)

```
soffice.exe --headless --convert-to pdf --outdir . Manual_Tecnico_SOLSGE.docx   # requiere Word cerrado
```

## Archivos

| Ruta | Rol |
|---|---|
| `_data/dump_schema.sql` | vuelca la estructura del esquema a CSV |
| `_data/*.csv` | estructura leída de la BD (entrada del generador) |
| `_gen/schema.js` | parser de los CSV + heurística de descripciones (override curado → comentario BD → patrón) |
| `_gen/modules.js` | partición dueña de cada tabla + propósito + descripciones de columnas de negocio |
| `_gen/er.js` | emite el `.puml` del ER (crow's-foot) de un módulo |
| `_gen/generate.js` | valida cobertura, genera los `.puml` y renderiza los PNG |
| `_gen/backend.js` | objetos PL/SQL (paquetes/funciones/procedimientos/triggers/vistas) por módulo |
| `_gen/narrative.js` | capítulos de prosa (§1–2, §5–10) + mapa de páginas APEX |
| `build_manual.js` | ensambla el documento completo |
| `build.js` | piloto del molde (solo módulo Facturación y Caja), ya aprobado |
| `er/*.puml`, `er/*.png` | diagramas ER generados |

Reutiliza la infraestructura compartida `../diagramas/_build/docxlib.js` (portada, banner, A4,
tablas, secciones portrait/landscape).

## Partición en módulos

Ventas · Facturación y Caja · Compras y Cuentas por Pagar · Inventario · Reportes Gerenciales ·
Seguridad y Personas · Catálogos base y configuración. 71 tablas de negocio (las 5 de
infraestructura/backup se excluyen). Las vistas de reporte (`V_VENTAS_*`, `V_COBROS_*`,
`V_INV_*`, `V_CMP_*`) se documentan en Reportes; las operativas quedan en su módulo funcional.

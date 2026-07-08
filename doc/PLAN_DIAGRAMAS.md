# PLAN_DIAGRAMAS — Diagramas UML para la documentación final (tesis)

**Objetivo:** rehacer los diagramas UML del sistema **SolSGE** (Oracle APEX, App 100 — ver
`CLAUDE.md`) para el Word de la tesis, ahora que el sistema está **funcional y completo**.
Debe **cumplir la plantilla del profesor**.

> **Cómo usar este plan en una sesión nueva:** *"Leé `doc/PLAN_DIAGRAMAS.md` y arrancá por
> el módulo piloto."* Todo el contexto necesario está acá.

---

## Documentos de referencia

En `SOLSGE/doc/Final 2026/`:

- **`Plantilla de Diagramas - Proyecto I.docx`** → lo que **EXIGE** el profesor. Obligatorio cumplir.
- **`Diagramas - Proyecto I.docx`** → versión vieja del alumno. **OJO:** se hizo **ANTES**
  de construir el sistema; es **genérica y de juguete** (clases `Usuario`/`Producto` con
  `id:int`, casos de uso de 4 pasos). Sirve **solo como referencia de ESTRUCTURA**, su
  contenido **NO se copia** — no refleja el sistema real.
- `Anteproyecto - Proyecto I.docx` → propuesta inicial, contexto histórico.

**Hallazgo clave:** el sistema real tiene ~40+ tablas (`COMPROBANTES`, `ORDENES_VENTA`,
`MOVIMIENTOS_CAJA`, `CUENTAS_COBRAR`, `TALONARIOS`, `ORDENES_PAGO`, `CUENTAS_PAGAR`…) y
flujos ricos (26 features F1–F26). El diagrama viejo tiene 11 clases genéricas que no se
parecen en nada. **Se conserva la estructura de la plantilla; el contenido se rehace entero.**

---

## Herramienta y salida

- **PlantUML** — archivos `.puml` versionados en `SOLSGE/doc/diagramas/`, **uno por diagrama**,
  organizados por módulo.
- **Tema CLARO** (`!theme plain` o fondo blanco), **no** el tema oscuro del doc viejo →
  imprime y se lee mucho mejor en Word.
- **La sesión RENDERIZA los PNG ella misma** (no depender de `Alt+D` manual). Hay Java 17 +
  el `.jar` de la extensión instalados:
  ```
  java -jar "C:\Users\NB01\.vscode\extensions\jebbs.plantuml-2.18.1\plantuml.jar" -tpng doc/diagramas/*.puml
  ```
  Deja los `.png` junto a los `.puml`. (Alternativa manual: extensión PlantUML de VS Code,
  `Alt+D` preview / botón derecho → *Export Current Diagram*.)
- **Idioma:** español (nombres, labels, actores).
- **FUENTE DE VERDAD = el sistema real**, nunca inventar ni copiar del doc viejo:
  - **Clases / ER** → leer la BD en vivo (conexión SQLcl `tesis_db`): tablas, columnas,
    PK/FK reales (`ALL_TAB_COLUMNS`, `ALL_CONSTRAINTS`).
  - **Secuencias** → leer los **procs/triggers reales** en `db/*.sql` y en la BD.
  - Contexto de negocio → los `PLAN_*.md`.

Diagramas grandes: **partir por módulo** (Ventas, Facturación/Caja, Cobros, Compras,
Inventario, Seguridad), nada de un mega-diagrama ilegible — es lo que el tribunal espera.

---

## Lo que exige la plantilla (5 secciones + carátula)

**Carátula:**
- Sistema: **"Sol - Sistema de Gestión Empresarial"**
- Sigla: **SOLSGE**
- Órgano usuario: **[CONFIRMAR con el alumno]** (en el doc viejo estaba vacío)
- Ciudad: **Asunción**
- Fecha: **Julio 2026**
- **Facultad Politécnica — Universidad Nacional de Asunción**

**1. Diagrama de Clases** — con relaciones tipadas: asociación, agregación, composición,
dependencia, herencia. Partido por módulo.

**2. Casos de Uso — CON ESPECIFICACIONES detalladas.** Usar el **formato exacto** de la plantilla:
- **Descripción** (funcionalidad, actores, entorno de invocación).
- **Flujo de Eventos → Flujo Básico.**
- **Flujos Alternativos.**
- **Precondiciones.**
- **Pos-condiciones.**
- **Puntos de Extensión** (si aplican).

**3. Diagramas de Estados** — solo objetos con **más de un estado**, indicando el evento
que dispara cada transición.

**4. Diagramas de Secuencia** — derivados de la descripción de un caso de uso, mostrando
los módulos/clases y las llamadas reales.

**5. Diagramas de Actividades** — flujo de control de los procesos complejos.

---

## Actores reales (del menú y de roles/privilegios)

Vendedor · Cajero · Supervisor · Comprador · Gerente (reportes) · Administrador.

---

## Casos de uso significativos a documentar

(Reflejan la lógica real del sistema — no los genéricos del doc viejo.)

| Caso de uso | Actor | Nota de la lógica real |
|---|---|---|
| Crear presupuesto/pedido | Vendedor | Reserva stock (`RESERVAS_PRODUCTO`) |
| Aprobar presupuesto | Supervisor | Transición de estado con auditoría |
| Facturar contado | Cajero | Valida caja abierta + talonario SET vigente + descuenta stock |
| Facturar a crédito | Cajero | Genera `CUENTAS_COBRAR` + cuotas con interés de financiación (F16) |
| Cobrar cuota | Cajero | `FN_COBRAR_CUOTA`, emite recibo |
| Anular factura | Cajero solicita / Supervisor aprueba | Ventana 48 h SIFEN (F11) |
| Emitir Nota de Crédito | Supervisor | Fuera de 48 h; workflow de aprobación (F14) |
| Abrir caja | Cajero | 1 caja abierta por empleado |
| Cerrar y arquear caja | Cajero | `CERRAR_CAJA` v3 + conteo declarado (F17) |
| Crear orden de compra | Comprador | Embudo de OC |
| Recepcionar orden de compra | Comprador | Entra stock (`MOVIMIENTOS_STOCK`) |
| Registrar factura de proveedor | Comprador | Genera `CUENTAS_PAGAR` (F24) |
| Generar + Confirmar orden de pago | Comprador | `PRC_GENERAR/CONFIRMAR_ORDEN_PAGO` (F24) |
| Registrar NC de compra | Comprador | Baja CxP / devuelve stock (F26) |
| Ver dashboards / generar informes | Gerente | 4 dashboards gerenciales (F18/F22/F23/F25) |
| Administrar usuarios / roles / privilegios | Administrador | Seguridad |

---

## Estados (candidatos con >1 estado)

- **Presupuesto** (`ORDENES_VENTA.ESTADO`): PENDIENTE → APROBADO → FACTURADO / ANULADO / VENCIDO.
- **Comprobante / Factura** (`COMPROBANTES.ESTADO`): `A` activa → `P` pendiente anulación → `N` anulada.
- **Cuenta por Cobrar** (`CUENTAS_COBRAR.ESTADO`): VIGENTE → PARCIAL → PAGADA.
- **Orden de Pago** (`ORDENES_PAGO.ESTADO`): BORRADOR → CONFIRMADA / ANULADA.
- **Orden de Compra** (`ORDENES_COMPRA.ESTADO`): B → P → C / X / A.

## Secuencias (las transaccionales, con PL/SQL real)

- Facturar contado.
- Cobrar cuota (`FN_COBRAR_CUOTA`).
- Anular factura (`PRC_SOLICITAR_ANULACION` / `PRC_APROBAR_ANULACION`).
- Nota de Crédito (`PRC_SOLICITAR_NOTA_CREDITO` / `PRC_APROBAR_NOTA_CREDITO`).
- Cierre / arqueo de caja (`CERRAR_CAJA` v3).
- Orden de pago (`PRC_GENERAR_ORDEN_PAGO` / `PRC_CONFIRMAR_ORDEN_PAGO`).

## Actividades (procesos complejos)

- Facturación completa (presupuesto aprobado → factura → stock → caja → CxC).
- Ciclo de compra (OC → recepción → factura proveedor → orden de pago).
- Cierre de caja (apertura → movimientos → conteo declarado → arqueo).

---

## Ensamblado final del Word — **CAMINO A+ (elegido, con skill `docx`)**

**Decisión (2026-07-06):** la sesión **sí arma el `.docx` final**, usando la skill oficial
**`docx`** de Anthropic (instalada en `SOLSGE/.claude/skills/docx`). Pipeline completo:

```
.puml  →  (java + plantuml.jar)  →  .png  →  [skill docx: docx-js]  →  Documento.docx con imágenes embebidas
```

La sesión entrega el `.docx` **terminado** (carátula + especificaciones de casos de uso en
el formato de la plantilla + diagramas embebidos). El alumno solo revisa/ajusta.

### Toolchain VERIFICADO end-to-end (2026-07-06)

Todo probado y funcionando en esta máquina:

| Herramienta | Estado | Uso |
|---|---|---|
| Java 17 + `plantuml.jar` | ✅ | `.puml` → `.png` |
| Node v20 + `docx-js` 9.7.1 | ✅ | crear el `.docx` con imágenes |
| `pandoc` 3.10 (`C:\Users\NB01\AppData\Local\Pandoc\pandoc.exe`) | ✅ | leer `.docx` existentes / convertir |
| `python-docx` 1.2.0 + `lxml` + `defusedxml` | ✅ | editar XML / validar |
| LibreOffice `soffice` | ✅ | `.doc`→`.docx`, `.docx`→imágenes, accept changes |
| skill `docx` (`.claude/skills/docx`) | ✅ | orquesta todo lo anterior |

### Notas operativas (gotchas de esta máquina)

- **`PYTHONUTF8=1` obligatorio** al correr los scripts de la skill (`validate.py`, etc.):
  la consola Windows es cp1252 y los scripts imprimen `→`/Unicode → si no, `UnicodeEncodeError`.
- **`docx-js`: instalar LOCAL** en la carpeta de build (`npm install docx` ahí), NO depender
  del global (`require('docx')` global es poco confiable en Windows aun con `NODE_PATH`).
- Para la **carátula**: partir de una **copia** de `doc/Final 2026/Plantilla de Diagramas -
  Proyecto I.docx` (path *edit existing*: unpack XML → editar → repack) para heredar el
  formato exacto de la cátedra, o recrearla en `docx-js` replicando los campos de la
  plantilla. Preferir editar la copia si el estilo del profesor importa.

**Fallback (manual):** si algo del ensamblado automático no cuadra, siempre queda el camino
manual — la sesión deja igual los `.png` + el texto en Markdown, y el alumno pega en el Word.

---

## Cómo arrancar — módulo PILOTO (Facturación + Caja)

Antes de generar los ~20 diagramas del sistema, **generar SOLO el piloto** y validar
estilo/nivel de detalle:

1. Diagrama de **clases / ER** del módulo Facturación+Caja, leyendo la BD real.
2. **Especificaciones** de caso de uso **"Facturar contado"** y **"Cobrar cuota"** en el
   formato de la plantilla.
3. Sus **2 diagramas de secuencia**, leyendo los procs reales.
4. **Renderizar los `.puml` a `.png`** (java + jar) y **armar un `.docx` de muestra** del
   piloto con la skill `docx` (carátula + specs + diagramas embebidos), para validar el
   pipeline A+ completo, no solo los diagramas.

Mostrar al alumno para aprobar estilo y ensamblado **antes** de escalar al resto.

---

## ✅ PILOTO CERRADO (2026-07-07) — formato aprobado por el PO

El piloto **Facturación + Caja** fue aprobado. Documento: `doc/diagramas/MUESTRA_Piloto_Facturacion_Caja.docx`.
Todo el resto del sistema se hace **con este mismo molde**.

### Formato del Word (definido con el PO, verificado contra la plantilla real)

- **Página A4** (11906×16838 twips). Márgenes de la cátedra: sup/inf 1417, izq/der 1701 twips.
- **NO es APA estricto** — sigue la **plantilla del profesor** (`doc/Final 2026/Plantilla…docx`):
  Times New Roman **12 pt**, interlineado **1.5**, **títulos negros** (H1 14 / H2 13 / H3 12 pt).
- **Portada** réplica exacta de la plantilla: todo centrado, TNR **18 pt sin negrita**
  (DISEÑO DE DIAGRAMAS / sistema / sigla / órgano usuario / ciudad / mes-año / FACULTAD
  POLITÉCNICA / UNIVERSIDAD NACIONAL DE ASUNCIÓN). **Órgano usuario = "Facultad Politécnica – UNA".**
- **Encabezado**: banner oficial UNA-FP (`doc/diagramas/_assets/logo_fpuna.png`, extraído del
  `header1.xml` de la plantilla) en **todas** las páginas. **Pie**: nº de página (la portada
  lleva encabezado pero **sin** pie).
- **Orientación AGRUPADA por bloque** (pedido del profesor: no intercalar vertical/horizontal
  página a página; agrupar para no rotar el doc a cada rato). Orden elegido por el PO:
  **bloque vertical primero, horizontal después.** Numeración resultante (aplica a cada módulo):
  1. **Casos de Uso** (especificaciones) · 2. **Estados** · 3. **Actividades**  → *vertical*
  4. **Clases** · 5. **Secuencia**  → *horizontal (A4 apaisado)*
  Las **figuras se numeran según el orden de lectura** (estados 1-2, actividades 3-4, clases 5,
  secuencia 6-7 en el piloto).
- Diagramas anchos (clases, secuencia) → landscape; texto y diagramas altos/cuadrados
  (estados, actividades) → portrait. Las imágenes landscape se escalan **por alto**
  (`imgFitH`, ~390-470 px) para que entren con título+intro+caption en **una sola hoja**
  (si son muy altas, el caption se orfana a otra página).

### Pipeline (versionado en el repo)

```
BD real / procs / triggers  →  .puml (uno por diagrama, tema claro !theme plain)
   →  java -jar plantuml.jar -tpng -charset UTF-8   →  .png
   →  node <modulo>/build.js  (usa doc/diagramas/_build/docxlib.js)  →  .docx A4
```

Layout de archivos:
- `doc/diagramas/_build/docxlib.js` — **librería compartida**: helpers (P, H1/H2/H3, bullet,
  num, imgFit/imgFitH, caption), portada, banner/pie, tamaños A4, `portraitSection` /
  `landscapeSection`, `buildDoc({outPath, sections})`. **No duplicar esto por módulo.**
- `doc/diagramas/_build/` tiene el `package.json` + `node_modules/docx` (instalar una vez con
  `npm install docx`; node lo resuelve desde ahí).
- `doc/diagramas/_assets/logo_fpuna.png` — banner del encabezado (compartido).
- `doc/diagramas/<modulo>/` — un `.puml` + `.png` por diagrama **y** `build.js` con el
  **contenido** del módulo (specs + estructura de secciones) que hace `require('../_build/docxlib')`.
  Ver `doc/diagramas/facturacion_caja/build.js` como plantilla a copiar.
- Salida: `doc/diagramas/MUESTRA_<Modulo>.docx` (o el nombre final de la tesis).

### Cómo previsualizar/verificar en esta máquina (Windows)

- **El `soffice.py` de la skill docx NO corre** (usa `socket.AF_UNIX`). Usar `soffice.exe` directo:
  `& "C:\Program Files\LibreOffice\program\soffice.exe" --headless --convert-to pdf --outdir <dir> <docx>`.
- Contar páginas / verificar orientación: `pypdf` (`pip install pypdf`). Para ver una página como
  imagen: extraerla a un PDF de 1 hoja con pypdf y convertirla con `soffice.exe --convert-to png`
  (soffice png solo exporta la 1ª hoja). No hay `pdftoppm`/`magick`/`mutool`.
- **Cerrar Word antes de re-buildear** (`Stop-Process WINWORD`) o node tira `EBUSY`.
- El PO prefiere revisar abriendo en **Word** (`Start-Process winword.exe <ruta>`); el preview
  por imágenes es autoverificación del agente.

### Modelo de cobertura por módulo — "MAPA GENERAL + CASOS PRINCIPALES" (aprobado 2026-07-07)

Decisión del PO tras revisar el piloto ampliado. Cada tipo de diagrama tiene su **unidad natural**
(no se hace "todos × todos" — eso sería incorrecto en UML):

| Sección | Unidad | Regla de cobertura |
|---|---|---|
| **1. Casos de Uso** | 1 diagrama por módulo **+** N specs | **Diagrama de casos de uso** (mapa general: actores + TODOS los casos del módulo, con «include»/«extend») **+ especificación de cada caso principal** (formato plantilla). Es el "de lo general a lo particular". |
| **2. Estados** | 1 por objeto con >1 estado | Solo objetos con ciclo de vida real (p. ej. Factura, Cuota, Caja). Transiciones = eventos reales de los procs. |
| **3. Actividades** | 1 por proceso transaccional/complejo | **Solo** para los casos transaccionales/complejos (no CRUD trivial). Swimlanes actor\|sistema con decisiones y caminos de error. |
| **4. Clases** | **1 por módulo** | Vista estructural (compartida por todos los casos). NO se hace una por caso de uso. |
| **5. Secuencia** | 1 por caso transaccional | **Solo** los transaccionales. Derivados de los procs/triggers reales. |

**Por qué NO "todos × todos":** el diagrama de clases es estructural (1 por módulo, compartido);
los estados pertenecen a un objeto, no a un caso de uso; secuencia y actividad sí son por caso de uso
pero solo para los transaccionales. Un "listar/consultar" no necesita secuencia ni actividad.

**Referencia canónica:** `doc/diagramas/facturacion_caja/` — 7 specs + diagrama de casos de uso +
3 estados + 4 actividades + 4 secuencias + 1 clases (26 págs). Copiar su `build.js` como plantilla.

### Procedimiento para cada módulo

1. Leer su `PLAN_*.md` + `CLAUDE.md` para el contexto de negocio y los procs/tablas.
2. **Casos de uso**: listar actores + casos principales → `casos_uso_<modulo>.puml` (mapa) + specs de cada uno.
3. **Clases/ER**: leer la BD real (tablas, PK/FK) → `.puml` (reusar los `skinparam` del piloto).
4. **Estados**: solo objetos con >1 estado.
5. **Secuencia/Actividad**: solo los casos transaccionales/complejos.
6. Renderizar PNG, escribir `<modulo>/build.js` (copiar del piloto), `node build.js`, verificar con pypdf/soffice.
7. **Orientación**: la membresía de cada sección a un bloque (vertical/horizontal) depende de la **forma real**
   del diagrama (ancho → apaisado; alto/cuadrado → vertical), pero **siempre agrupado** (una sola rotación).

### Estado de los módulos

Cada `<modulo>/build.js` genera su `doc/diagramas/MUESTRA_<Modulo>.docx` (standalone) y **exporta
sus `especificaciones`**; el **documento combinado** `doc/diagramas/Diagramas_UML_SOLSGE.docx` lo arma
`_build/build_combined.js` reuniendo todo **por tipo de diagrama**.

**Documento combinado (entregable final, 95 págs, A4) — organizado POR TIPO DE DIAGRAMA:**
1. Casos de Uso · 2. Estados · 3. Actividades (vertical) → 4. Clases · 5. Secuencia (apaisado).
Dentro de cada sección, por módulo. **Una sola rotación** en todo el documento (pág. 71). Numeración
de figuras continua (1–54). El PO eligió esta división (por tipo, no por módulo) el 2026-07-07.

Actores reales por módulo (corregidos con el PO 2026-07-07):
- **Ventas:** Vendedor (crea); **Supervisor _o_ Vendedor** aprueban (el vendedor, previa confirmación del cliente).
- **Compras:** Comprador (crea OC / factura / genera OP); **Supervisor** aprueba OC y confirma OP;
  **Encargado de Depósito** recepciona (conteo). Todo flujo con doble validación tiene un Supervisor.
- **Inventario:** **Encargado de Depósito** (existencias, historial de movimientos, inventario físico);
  **Supervisor** aprueba el inventario; **Gerente** (dashboard/informe). **NO** usar la palabra «kardex»
  → «historial de movimientos». Referirse a **reporte/página de existencias** y **dashboard/reporte
  gerencial de inventario**, no a «la página de inventarios».

Estado de módulos (todos con diagrama de casos de uso + specs de casos principales):
- [x] **Facturación + Caja** — 7 casos + estados Factura/Cuota/Caja + 4 act + 4 sec + clases.
- [x] **Ventas** — Crear + Aprobar presupuesto + estados Presupuesto/Reserva + 2 act + 2 sec + clases.
- [x] **Compras** — 6 casos (Crear OC, Aprobar OC, Recepcionar, Factura prov, Generar/Confirmar OP, NC
      compra) + estados OC/Comprobante/CxP/OrdenPago + 3 act + 4 sec + clases.
- [x] **Inventario** — 6 casos (Existencias, Historial mov., **Realizar inventario físico**, **Aprobar
      inventario**, Dashboard, Informe) + **estados Inventario** (BORRADOR→ENVIADO→APROBADO/RECHAZADO,
      `INVENTARIO_PKG`) + 2 act + 3 sec + clases (con INVENTARIO/INVENTARIO_DETALLE).
- [x] **Seguridad** — 4 casos (Autenticarse, Registrar usuario, Asignar roles, Privilegios de rol) +
      estados Usuario + 2 act + 2 sec + clases (RBAC).
- [x] **Reportes Gerenciales** — 2 specs (Ver dashboard, Generar informe) sobre 4 áreas (F18/F22/F23/F25),
      actor Gerente; clases = capa de reportes (dashboards/funciones → vistas → hechos + metas); 1 act + 2 sec. Sin estados.
- **Cobros** = "Cobrar cuota" ya cubierto en Facturación + Caja (no se duplica).

---

## Gotchas del repo que aplican

- **`FN_HOY`/`FN_AHORA`, nunca `SYSDATE`** al modelar fechas de negocio (BD en UTC).
- Los nombres de tabla reales mandan (`COMPROBANTES` no `Factura`, `ORDENES_VENTA` no
  `OrdenVenta`, `MOVIMIENTOS_CAJA` no `Pago`).
- Inconsistencias de datos conocidas a tener presentes si aparecen en el modelo:
  `MOVIMIENTOS_CAJA.MONEDA` guarda texto (`'PYG'`) vs `COMPROBANTES.MONEDA` guarda código;
  `MOVIMIENTOS_CAJA.ESTADO` es abierta/cerrada de caja (`A`/`C`), no activo/anulado.

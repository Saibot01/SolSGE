# PLAN_MANUAL_USUARIO — Manual de Usuario para el libro de tesis

**Objetivo:** producir el **Manual de Usuario** de **SolSGE** (Oracle APEX, App 100 — ver
`CLAUDE.md`), dirigido al **usuario final** que opera el sistema. Es un manual **task-oriented y con
capturas**: cada tarea se documenta como objetivo → rol → pasos numerados → captura(s), con el
**formato visual de la cátedra** (portada, banner UNA-FP, A4) reutilizando la infra del libro.

> **Cómo usar este plan en una sesión nueva:** *"Leé `doc/PLAN_MANUAL_USUARIO.md` y arrancá por el
> piloto (Facturación/Caja)."* Todo el contexto necesario está acá.

---

## Contexto: el "libro de tesis" (4 documentos)

1. **Diagramas UML** — ✅ **HECHO** (`doc/diagramas/Diagramas_UML_SOLSGE.docx`; `doc/PLAN_DIAGRAMAS.md`).
2. **Anteproyecto** — ✅ **HECHO** (`doc/Final 2026/Anteproyecto - Proyecto I.docx`; `doc/PLAN_ANTEPROYECTO.md`).
3. **Manual de Usuario** — 👈 **ESTE plan** (usuario final, con capturas).
4. **Manual Técnico** — planificado (`doc/PLAN_MANUAL_TECNICO.md`; desarrollador/mantenedor).

Debe quedar **consistente** con los otros: mismo nombre del sistema (**"Sole – Sistema de Gestión
Empresarial"**, sigla **SOLSGE**, empresa "Sole Informática"), mismos módulos y actores, mismo vocabulario.

**Diferencia con el Manual Técnico:** el de Usuario enseña a **operar** (paso a paso, con capturas);
el Técnico documenta **cómo está construido y cómo se despliega**. No se duplican.

---

## Fuente de verdad (nunca inventar)

- **La app en vivo** (APEX en `/ords/apex`, App 100 / `f100`): los flujos y pantallas reales.
- **Las capturas que provee el alumno** (ver "Guía de captura" abajo).
- **Los casos de uso ya documentados** en `doc/diagramas/` y el alcance de cada módulo en
  `CLAUDE.md` + los `PLAN_*.md` (para describir los pasos correctamente y con los nombres reales).
- **Actores reales:** Vendedor, Cajero, Supervisor, Comprador, Encargado de Depósito, Gerente, Administrador.

---

## Decisiones tomadas (2026-07-08, con el alumno)

1. **Capturas: las provee el alumno** siguiendo la guía de captura de este plan. **No hay automatización
   de browser disponible** (ni Playwright/puppeteer; `WebFetch` no sirve para app con login ni captura
   imágenes) y la app está protegida por RBAC en un ORDS remoto → la captura automática no es viable.
   El alumno captura; la sesión **redacta los pasos y ensambla** el `.docx`.
2. **Organización: por módulo/función** (Ventas, Facturación/Caja, Cobranzas, Compras, Inventario, etc.),
   indicando en cada tarea el rol que la ejecuta. Al inicio, una **matriz rol → tareas** para orientar.
3. **Cobertura: casos principales** (los mismos casos de uso de los diagramas), no las 118 páginas.
4. **Plantilla:** no hay plantilla del profesor → **estructura estándar** con formato de la cátedra.

---

## Formato del documento

- **A4**, fuente y estilos de la cátedra (igual que los otros 3 docs), **portada** réplica, **banner
  UNA-FP** en todas las páginas + **pie** con nº de página.
- Cada tarea: **título de la tarea** · *(Rol: …)* · **objetivo** (1 línea) · **pasos numerados** ·
  **captura(s)** con epígrafe "**Figura N:** …" (numeración continua).
- Capturas mayormente **vertical (portrait)**; las anchas (dashboards, reportes) en **apaisado**, agrupadas
  (una sola rotación por bloque, como en los diagramas).
- Recuadros **Nota / Importante** para reglas y advertencias (p. ej. "requiere caja abierta",
  "solo dentro de las 48 h", "una caja abierta por empleado").
- Generación con `doc/diagramas/_build/docxlib.js` (portada, banner, secciones, `imgFit`).

---

## Estructura propuesta (índice)

1. **Introducción** — propósito, a quién va dirigido, convenciones del manual (íconos de Nota/Importante).
2. **Acceso al sistema** — navegador y URL (sin instalar nada), inicio de sesión, bloqueo por intentos
   fallidos, la **pantalla principal** (menú de navegación), cómo cerrar sesión.
3. **Roles del sistema** — matriz **rol → qué puede hacer** (Vendedor, Cajero, Supervisor, Comprador,
   Encargado de Depósito, Gerente, Administrador).
4. **Ventas** — crear presupuesto/pedido, aprobar/rechazar, consultar y su vencimiento.
5. **Facturación y Caja** — abrir caja, facturar al contado, facturar a crédito, anular factura,
   estado de caja, cerrar y arquear caja.
6. **Cobranzas** — cobrar cuota y emitir recibo, reimpresión, estado de cuenta del cliente.
7. **Notas de crédito (venta)** — solicitar y aprobar/rechazar, imprimir la NC.
8. **Compras** — crear orden de compra, aprobar, recepcionar, registrar factura de proveedor,
   generar y confirmar orden de pago, nota de crédito de compra.
9. **Inventario** — consultar existencias, historial de movimientos, realizar y aprobar inventario físico.
10. **Documentos fiscales** — imprimir KuDE (factura/recibo/NC); gestión de talonarios (Administrador).
11. **Reportes gerenciales** — dashboards de ventas, cobros, inventario y compras; generar informes; metas.
12. **Administración** — usuarios, roles y privilegios; parámetros del sistema; configuración de cajas/oficinas.
13. **Errores frecuentes y preguntas comunes** (opcional) — mensajes típicos y cómo resolverlos.

---

## Guía de captura de pantallas (para el alumno)

**Convención de nombres:** `NN_modulo_tarea_SS.png` — `NN` = nº de capítulo, `SS` = secuencia del paso.
Ejemplos: `02_acceso_login_01.png`, `05_facturacion_contado_03.png`, `11_dashboard_ventas_01.png`.

**Dónde dejarlas:** `doc/manual_usuario/capturas/`.

**Cómo capturar (consistencia):**
- Navegador maximizado, **zoom 100%**, ventana de ancho estándar (idealmente ~1366–1440 px).
- Recortar al **contenido de la región** relevante (no toda la pantalla si sobra cromo del navegador).
- Formato **PNG**. Datos de demo coherentes (los mismos que se muestran en la defensa).
- Evitar datos sensibles reales; usar los de demo.
- Para pantallas anchas (dashboards): captura completa; irán en apaisado.

**Capturas necesarias por módulo (casos principales — se refina en el piloto):**

| Cap. | Módulo | Pantallas a capturar |
|---|---|---|
| 2 | Acceso | login; pantalla principal con el menú; (opcional) mensaje de bloqueo |
| 4 | Ventas | lista de presupuestos; alta/edición de presupuesto con ítems; presupuesto aprobado |
| 5 | Facturación y Caja | apertura de caja; pantalla de facturación (contado y crédito); factura KuDE impresa; anulación; estado de caja; cierre/arqueo y documento de arqueo |
| 6 | Cobranzas | selección de cuota a cobrar; recibo emitido (KuDE); estado de cuenta |
| 7 | Notas de crédito | solicitar NC (selección de ítems); aprobar/rechazar; NC impresa |
| 8 | Compras | alta de OC; aprobación; recepción; factura de proveedor; generar OP; resolver/confirmar OP; documento OP; NC de compra |
| 9 | Inventario | existencias; historial de movimientos; inventario físico (conteo); aprobación del inventario |
| 10 | Documentos fiscales | KuDE de factura/recibo/NC; ABM de talonarios |
| 11 | Reportes | dashboard de ventas, cobros, inventario, compras; generador de informe; ABM de metas |
| 12 | Administración | ABM de usuarios; roles y privilegios; parámetros; configuración de cajas/oficinas |

---

## Toolchain (mismo que el libro — ya verificado)

- **Generación del `.docx`:** `doc/diagramas/_build/docxlib.js` (portada, banner UNA-FP, pie, A4,
  `portrait/landscapeSection`, `imgFit/imgFitH`, `buildDoc`). Crear `doc/manual_usuario/build.js`
  que la requiera (patrón de `doc/diagramas/<modulo>/build.js` y del manual técnico).
- **Capturas:** las provistas en `doc/manual_usuario/capturas/`, embebidas con `imgFit` y epígrafe.
- **Preview/validación (gotchas de esta máquina — ver memoria):**
  - `PYTHONUTF8=1` en los scripts de la skill `docx`.
  - El `soffice.py` de la skill NO corre en Windows → `soffice.exe` directo para PDF; `pypdf` para
    contar páginas/extraer texto; 1 hoja → PNG para verificación visual.
  - **Cerrar Word** antes de re-generar el `.docx` (si no, `EBUSY`; deja `~$*.docx`, gitignored).
- Trabajo en `main`, commits `docs(manual-usuario): …`.

---

## Pasos sugeridos

1. **Piloto primero** (validar formato/nivel con el alumno antes de escalar), sobre **Facturación/Caja**:
   - Redactar las tareas del módulo (objetivo + rol + pasos numerados), dejando slots de figura.
   - El alumno entrega las capturas de ese módulo según la guía.
   - Ensamblar un `.docx` de muestra (portada + intro + acceso + ese módulo) y mostrarlo para aprobar estilo.
2. Aprobado el molde, el alumno entrega el resto de capturas por módulo; la sesión redacta y ensambla.
3. Escribir la introducción, el acceso y la matriz de roles (cap. 1–3).
4. Ensamblar el documento combinado con `docxlib` (bloque vertical general; dashboards/reportes en apaisado).
5. `pack`/validar → preview PDF (soffice.exe + pypdf) → abrir en Word para el alumno.
6. Commit en `main`.

## Fuera de alcance (de este plan)

- **Manual Técnico** (documento 4; `doc/PLAN_MANUAL_TECNICO.md`).
- Rehacer diagramas o el anteproyecto (ya hechos).
- Capturas automáticas (no hay herramienta disponible; las provee el alumno).

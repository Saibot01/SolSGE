# PLAN_ANTEPROYECTO — Actualizar el Anteproyecto para el libro de tesis

**Objetivo:** actualizar el **Anteproyecto** (`doc/Final 2026/Anteproyecto - Proyecto I.docx`,
Agosto 2024, fase de propuesta) para que su **alcance sea coherente con el sistema realmente
construido** (SolSGE, funcional y completo — ver `CLAUDE.md`), sin perder su naturaleza de
documento de propuesta.

> **Cómo usar este plan en una sesión nueva:** *"Leé `doc/PLAN_ANTEPROYECTO.md` y arrancá."*
> Todo el contexto necesario está acá.

---

## Contexto: el "libro de tesis"

Es un recopilado de **4 documentos**:
1. **Diagramas** — ✅ **HECHO** (`doc/diagramas/Diagramas_UML_SOLSGE.docx`, 95 págs; ver `doc/PLAN_DIAGRAMAS.md`).
2. **Anteproyecto** — 👈 **ESTE plan** (actualizarlo).
3. **Manual de Usuario** — pendiente (plan futuro).
4. **Manual Técnico** — pendiente (plan futuro).

El anteproyecto y los diagramas deben quedar **consistentes entre sí** (mismos módulos, actores,
casos de uso, nombre del sistema).

---

## Fuente de verdad (nunca inventar)

- **El sistema real:** `CLAUDE.md` (índice de features F1–F27), los `PLAN_*.md`, y la BD en vivo
  (conexión SQLcl `tesis_db`).
- **Los diagramas ya hechos:** `doc/diagramas/` (casos de uso, actores, clases, estados reales).
  El anteproyecto actualizado debe alinear su alcance y su vocabulario con esto.

---

## Análisis de brechas (anteproyecto 2024 vs sistema real)

### Lo que el anteproyecto NO menciona pero SÍ se construyó
- **Módulo de Caja:** apertura, cierre y **arqueo** con conteo declarado (F8/F17). Una caja abierta por empleado.
- **Seguridad / RBAC:** usuarios–roles–privilegios (`EMPLEADOS`/`ROLES`/`PRIVILEGIOS`), login con
  bloqueo por intentos. En el anteproyecto figura solo como requisito no funcional de "autenticación".
- **Presupuestos/Pedidos:** el "orden de venta" real es un **presupuesto** con **reserva de stock**,
  **aprobación** (Supervisor/Vendedor), **vencimiento** parametrizable (F1–F7).
- **Venta a crédito y cuotas:** **cuentas por cobrar**, plan de cuotas, **interés de financiación**
  (F16), **cobro de cuotas** con **recibo** (F9).
- **Cuentas por pagar y órdenes de pago** a proveedores (F24), con generar/confirmar (doble validación).
- **Notas de crédito** de venta (F14) y de compra (F26).
- **Documentos fiscales KuDE / SIFEN:** **talonarios** con timbrado y numeración
  establecimiento-punto-expedición (F10), representación gráfica **KuDE** de factura/recibo/NC (F12/F13).
- **Inventario físico (conteo):** workflow BORRADOR→ENVIADO→APROBADO/RECHAZADO con **ajustes** de stock
  (`INVENTARIO_PKG`), además de existencias e historial de movimientos.
- **4 dashboards gerenciales** (Ventas F18, Cobros F22, Inventario F23, Compras F25) con **metas** e informes imprimibles.

### Lo que está desactualizado
- **Nombre del sistema:** el anteproyecto dice *"Sole Sistema Gestion Empresarial"* / empresa *"Sole
  Informática"*; el sistema entregado y los diagramas usan **"Sol – Sistema de Gestión Empresarial"
  (SOLSGE)**. ⚠️ **CONFIRMAR con el alumno** cuál es el correcto (¿empresa "Sole Informática",
  sistema "Sol/SolSGE"?) y unificar. Faltan acentos en todo el doc (Gestion, Asuncion, Solucion…).
- **Actores:** el anteproyecto lista Administrador, Ventas, Compras, Reportes(Gerente). Los **reales**
  son: **Vendedor, Cajero, Supervisor, Comprador, Encargado de Depósito, Gerente, Administrador**.
- **Requisitos funcionales (§7.1):** muy genéricos → expandir por módulo con lo real (caja, crédito/cuotas,
  CxC/CxP, NC, talonarios, KuDE, inventario físico, dashboards con metas, RBAC).
- **Diagrama de casos de uso de alto nivel (§7.3):** la lista de casos es genérica → alinear con los
  casos reales ya documentados en `doc/diagramas/` (los mismos nombres).
- **Diccionario de datos (§8):** entidades genéricas (Productos, Clientes, Ventas…) → actualizar a las
  entidades reales (COMPROBANTES, ORDENES_VENTA, MOVIMIENTOS_CAJA, CUENTAS_COBRAR/PAGAR, TALONARIOS,
  RESERVAS_PRODUCTO, INVENTARIO, EMPLEADOS/ROLES/PRIVILEGIOS…). **Nivel de detalle a confirmar**
  (alto nivel vs. las ~40 tablas reales).
- **Recursos/Software (§9):** ajustar a lo real — **Oracle APEX 24.2.17**, **Oracle Autonomous Database
  23ai**, wallet SSL. (Dice "Oracle Database 19c o superior": aceptable pero se puede precisar.)
- **Numeración de secciones rota:** la §7 tiene subsecciones "8.1–8.7"; la §9 tiene "10.1/10.2".
  Renumerar coherente.
- **Términos de aprobación (§10):** **Órgano usuario** vacío → "Facultad Politécnica – UNA"
  (mismo dato de la carátula de los diagramas); revisar fecha.

---

## Decisiones a confirmar con el alumno (antes de editar)

1. **Encuadre temporal:** ¿mantener el anteproyecto como **propuesta** (tiempo futuro, "el sistema
   permitirá…") pero con el **alcance real**, o reescribirlo como sistema ya entregado? *Recomendado:*
   mantener el encuadre de propuesta (es el documento de la etapa de anteproyecto) y solo **alinear el
   alcance** (módulos, actores, requisitos, casos de uso) con lo construido, para que no contradiga al
   resto del libro.
2. **Nombre del sistema/empresa** (ver brecha arriba). Unificar con los diagramas.
3. **Detalle del diccionario de datos:** alto nivel (una entidad por concepto) o exhaustivo (tablas reales).
4. **Fecha/portada:** ¿conservar "Agosto 2024" (fecha original de la etapa) o "Julio 2026" (versión del libro)?

---

## Toolchain (mismo que diagramas — ya verificado)

- **Leer:** `pandoc … -t markdown` (ya usado; `scratchpad/anteproyecto.md`).
- **Editar preservando el formato de la cátedra:** ruta *edit existing* de la skill `docx`
  (`.claude/skills/docx`): `unpack.py` → editar el XML de `word/document.xml` → `pack.py`. **Preferir
  editar el docx existente** para heredar el estilo del documento; NO regenerar desde cero (perdería el formato).
- **Preview/validación (gotchas de esta máquina, ver memoria):**
  - `PYTHONUTF8=1` obligatorio en los scripts de la skill.
  - El `soffice.py` de la skill **NO corre** en Windows → usar `soffice.exe` directo para convertir a PDF;
    `pypdf` para contar páginas / extraer texto; extraer 1 página y `soffice --convert-to png` para ver imágenes.
  - **Cerrar Word** antes de re-escribir el `.docx` (si no, `EBUSY`/lock; y se generan `~$*.docx` — ya gitignored).
- Rama de trabajo separada de `main` (como se hizo con los diagramas: `docs/diagramas-uml`).

---

## Pasos sugeridos

1. Confirmar las 4 decisiones de arriba con el alumno.
2. Releer `CLAUDE.md` + los `PLAN_*.md` para el alcance real por módulo; usar los **mismos nombres** de
   casos de uso/actores que `doc/diagramas/`.
3. `unpack` del anteproyecto → editar §§ 1–10:
   - §1–6 (Introducción, Objetivos, Situación, Problemas, Solución): retoques menores + agregar los
     módulos faltantes (Caja, Seguridad, Crédito/CxC, CxP, NC, KuDE, Inventario físico, Dashboards).
   - §7.1 Requisitos funcionales: reescribir por módulo con lo real.
   - §7.3 Casos de uso de alto nivel + actores: alinear con los diagramas.
   - §8 Diccionario de datos: actualizar entidades (según decisión de detalle).
   - §9 Recursos: precisar stack (APEX 24.2.17 / ADB 23ai).
   - Renumerar secciones; corregir acentos y nombre del sistema.
   - §10 Términos: órgano usuario + fecha.
4. `pack` → validar → preview PDF (soffice.exe + pypdf) → abrir en Word para el PO.
5. Commit en la rama de docs.

## Fuera de alcance (de este plan)
- Manual de Usuario y Manual Técnico (planes aparte).
- Rehacer los diagramas (ya hechos).

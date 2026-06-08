# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**SolSGE** — *Sol, Sistema de Gestión Empresarial*. An Oracle APEX 24.2 business-management application (App ID **100**, alias `f100`) running on Oracle Autonomous Database. UI strings, page names, columns, and PL/SQL comments are in Spanish — preserve that language when editing.

**Planes activos:**
- `PLAN_VENTAS.md` — módulo Presupuestos/Ventas (F1–F7 cerradas; deuda P30/P31 + P5 menú).
- `PLAN_FACTURACION.md` — módulo Facturación + Caja. **F8 cerrada el 2026-06-07** (tag `f8-facturacion-contado`, commit `a67ccf3`). **F9 pendiente** (cobro de cuotas + recibo).

## Environment

Configured in `.claude/settings.json`:

- `SQLCL_CONNECTION=tesis_db` — named SQLcl connection used by the APEX/SQLcl skills.
- `APEX_APP_ID=100`
- `APEX_WORKSPACE=WKSP_WORKPLACE`

Credentials live in `wallet/` (Oracle Cloud wallet, gitignored). The DB is the Autonomous Database at `GD48788B1691042-ORAPDBTES.adb.sa-vinhedo-1.oraclecloudapps.com` and APEX is reached at `/ords/apex` on that host. The SSL wallet expires **2031-03-26** — re-download before then.

## Two parallel APEX trees

The repo intentionally keeps two separate exports of the same app side-by-side. Know which one you are editing:

- **`apex-learn/f100/`** — *Read-only reference.* Full export of the live app, including `create_application.sql`, `delete_application.sql`, every shared component, all pages, files, plugin settings, etc. Treat this as the baseline / source of truth for what production currently looks like. Do not edit by hand; refresh it by re-exporting.
- **`apex-work/f100/`** — *Patch staging area.* A pared-down tree that is built up file-by-file as we change things, then imported selectively via the two install scripts in its root:
  - `install_page.sql` — imports only the pages currently listed inside it (each page paired with its `delete_NNNNN.sql`). Edit this file to control which pages get pushed.
  - `install_component.sql` — imports only the shared components currently listed (today: `navigation_menu`).
  Both scripts wrap their work between `application/set_environment.sql` and `application/end_environment.sql`, which call `wwv_flow_imp.import_begin` / `import_end` with the workspace + app ID + offset. Never bypass them.

When adding a page or component to the work tree, you must also add the matching `@@…` line(s) to the relevant install script — exports placed in `apex-work/` are dead weight until referenced there.

Other directories:
- `db/` — versioned SQL migrations (DDL/DML/PLSQL outside APEX). One file per feature: `db/F4_estados.sql`, etc. Each script must be idempotent and end with a verification block. See `db/README.md`. Apply via `sql -S -name $SQLCL_CONNECTION @db/<file>.sql`.
- `export-prev/` — older full exports kept as historical backups (includes a large `f100.sql`, zips, and `readable/`). Ignore unless explicitly asked.
- `apexlang/` — empty placeholder.

## Common workflow

1. Use the `apex-export` / `apex-describe` skill to pull the current state of a component out of the live app into `apex-work/f100/application/...`.
2. Edit the exported `.sql` (page, region, shared component) in `apex-work/`.
3. Add it (and its `delete_NNNNN.sql` pair, for pages) to `install_page.sql` or `install_component.sql`.
4. Use the `apex` / `sqlcl` skill (which goes through SQLcl MCP using `SQLCL_CONNECTION=tesis_db`) to run the install script against the workspace.
5. Verify in the live APEX app.

Commit messages follow Conventional Commits in Spanish (`feat:`, `fix:`, `style:`, `cleanup:` …) — match the existing style.

## Skills to prefer

This repo is set up for the APEX toolchain. For anything touching the application, prefer these over hand-rolled SQLcl commands:

- `apex-export`, `apex-describe`, `apex-learn` — read-only exploration of the live app.
- `apex` — exporting/patching/importing components (pages, regions, items, processes, DAs, validations, LOVs, IR/IG, auth schemes, templates, etc.).
- `sqlcl` — direct SQL/PLSQL, schema inspection, Liquibase, Data Pump.

## Pitfalls specific to this repo

- The `delete_NNNNN.sql` file for a page is **required** before its `page_NNNNN.sql` — APEX import needs the page dropped first. Untracked `page_*.sql` files in `apex-work/.../pages/` without a matching `delete_*.sql` indicate an in-progress export.
- `wallet/`, `*.env`, and `export-prev/festive-varahamihira-3893ce/` are gitignored — do not stage them.
- Page exports embed JavaScript with Spanish identifiers and `unistr(...)` escapes for accented characters. When editing, preserve the `wwv_flow_string.join(wwv_flow_t_varchar2(...))` chunking and the `unistr('...\00EDsmbolo...')` form; do not "fix" them to plain strings.
- The export header pins `p_version_yyyy_mm_dd=>'2024.11.30'`, `p_release=>'24.2.17'` (Oracle aplicó patch 24.2.15→24.2.17 al ATP el 2026-06-06), `p_default_workspace_id=>7697821598969118`, `p_default_application_id=>100`. If a re-export changes these, the workspace was upgraded — flag it before importing.
- **Renombrado “Orden de Venta” → “Presupuesto/Pedido” es solo UI.** Las tablas `ORDENES_VENTA` y `DETALLE_ORDEN` se conservan con sus nombres originales y todas sus columnas (`ID_ORDEN`, `FECHA_ORDEN`, etc.). El cambio aplica únicamente a `p_name`, `p_step_title`, `p_plug_name`, labels y textos visibles de las páginas P52/P54/P6 y al menú. No renombrar objetos de BD ni columnas como parte de este renombrado. Ver `PLAN_VENTAS.md` Feature 1.
- **Renombre de tabla aplicado en F8**: `RECIBOS_COBRO` ahora es `MOVIMIENTOS_CAJA` (y `DETALLE_RECIBO_COBRO` es `DETALLE_MOVIMIENTO_CAJA`). Se agregaron columnas `TIPO`, `ID_COMPROBANTE`, `USUARIO`, y campos del documento recibo (`NRO_RECIBO`, `ID_TALONARIO_RECIBO`, `FECHA_EMISION_RECIBO`, `ID_CUENTA_COBRAR_DET`). La PK pasó de `ID_RECIBO` a `ID_MOVIMIENTO`. Ver `PLAN_FACTURACION.md` §4 F8.A.
- **`IMAGE_PREFIX` apunta a CDN público de Oracle** (`https://static.oracle.com/cdn/apex/24.2.17/`), no a `/i/`. Es un workaround del 2026-06-07 porque el ORDS embebido del ATP no expone `/i/` post-upgrade. Si Oracle alguna vez arregla el deploy, revertir con `apex_instance_admin.set_parameter('IMAGE_PREFIX', '/i/')`. NO es algo que rompimos nosotros — fue side-effect del patch APEX 24.2.15→24.2.17.
- **Regla "1 caja abierta por empleado"** (no "1 caja por día"). El trigger `TRG_CAJA_UNA_POR_DIA` (nombre engañoso, mantengo por historicidad) bloquea apertura solo si el empleado ya tiene una caja con `ESTADO='A'`. Se pueden abrir múltiples cajas del mismo día si las anteriores están cerradas. La factura sí valida que la caja sea del día actual.
- **El export APEX (`apex export -split`) sobreescribe `install_page.sql`** dejando solo la página exportada. Si vas a re-exportar, restaurá el `install_page.sql` completo después (los demás @@ de páginas previas se pierden si no se restauran).

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**SolSGE** — *Sol, Sistema de Gestión Empresarial*. An Oracle APEX 24.2 business-management application (App ID **100**, alias `f100`) running on Oracle Autonomous Database. UI strings, page names, columns, and PL/SQL comments are in Spanish — preserve that language when editing.

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
- The export header pins `p_version_yyyy_mm_dd=>'2024.11.30'`, `p_release=>'24.2.15'`, `p_default_workspace_id=>7697821598969118`, `p_default_application_id=>100`. If a re-export changes these, the workspace was upgraded — flag it before importing.

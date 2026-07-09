// ============================================================================
// generate.js — valida cobertura de tablas y genera los .puml del ER por módulo.
// Ejecutar: node doc/manual_tecnico/_gen/generate.js
// ============================================================================
const path = require("path");
const { execFileSync } = require("child_process");
const S = require("./schema");
const { MODULES } = require("./modules");
const { emitPuml } = require("./er");

const ER_DIR = path.join(__dirname, "..", "er");
const PLANTUML_JAR = "C:\\Users\\NB01\\.vscode\\extensions\\jebbs.plantuml-2.18.1\\plantuml.jar";
// OJO: -DPLANTUML_LIMIT_SIZE alto es obligatorio; con el default (4096) PlantUML
// RECORTA los ER grandes (Facturación, Compras) al generar el PNG.

// tablas de infraestructura/backup que NO van al manual
const EXCLUDE = new Set([
  "DBTOOLS$MCP_LOG", "HTMLDB_PLAN_TABLE",
  "PRODUCTO_PROVEEDORES_BACKUP", "PRODUCTO_PROVEEDORES_OLD",
  "REFERENCIAS_DINAMICAS",
]);

// --- 1. cobertura -----------------------------------------------------------
const allTables = Object.keys(S.COLS).sort();
const owned = [];
const dup = [];
for (const m of MODULES) for (const { t } of m.tables) {
  if (owned.includes(t)) dup.push(t);
  owned.push(t);
}
const ownedSet = new Set(owned);
// las vistas (V_*) se documentan en el backend, no en el diccionario de datos
const isView = (t) => /^V_/.test(t);
const missing = allTables.filter((t) => !ownedSet.has(t) && !EXCLUDE.has(t) && !isView(t));
const ghost = owned.filter((t) => !S.exists(t));

console.log("Tablas en el dump:", allTables.length);
console.log("Tablas asignadas :", owned.length, "(únicas:", ownedSet.size + ")");
console.log("Excluidas (infra):", EXCLUDE.size);
if (dup.length) console.log("!! DUPLICADAS:", dup);
if (missing.length) console.log("!! SIN ASIGNAR:", missing);
if (ghost.length) console.log("!! NO EXISTEN EN LA BD:", ghost);
if (!dup.length && !missing.length && !ghost.length)
  console.log("OK: cobertura completa, sin duplicados ni fantasmas.");

// --- 2. generar .puml por módulo -------------------------------------------
const pumls = [];
for (const m of MODULES) {
  const p = emitPuml({
    key: m.key,
    title: "Modelo Entidad-Relacion — Modulo " + m.name + " (SOLSGE)",
    owned: m.tables.map((x) => x.t),
    outDir: ER_DIR,
  });
  pumls.push(p);
  console.log("puml ->", path.basename(p));
}

// --- 3. renderizar PNG (con límite de tamaño alto para no recortar) ---------
try {
  execFileSync("java", ["-DPLANTUML_LIMIT_SIZE=16384", "-jar", PLANTUML_JAR,
    "-tpng", "-charset", "UTF-8", ...pumls], { stdio: "inherit" });
  console.log("PNG renderizados (PLANTUML_LIMIT_SIZE=16384).");
} catch (e) {
  console.log("!! No se pudo renderizar con java. Correr manualmente:\n" +
    '   java -DPLANTUML_LIMIT_SIZE=16384 -jar "' + PLANTUML_JAR + '" -tpng -charset UTF-8 doc/manual_tecnico/er/er_*.puml');
}

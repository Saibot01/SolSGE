// ============================================================================
// schema.js — carga la estructura del esquema (CSV volcados de la BD) y expone
// helpers para el generador del Manual Técnico. Fuente: _data/*.csv (BD real).
// ============================================================================
const fs = require("fs");
const path = require("path");
const DATA = path.join(__dirname, "..", "_data");

// --- parser CSV mínimo (comillas dobles, campos entre comillas) -------------
function parseCSV(file) {
  const txt = fs.readFileSync(path.join(DATA, file), "utf8").replace(/\r/g, "");
  const lines = txt.split("\n").filter((l) => l.length);
  const rows = [];
  for (const line of lines) {
    const cells = [];
    let i = 0, cur = "", q = false;
    while (i < line.length) {
      const ch = line[i];
      if (q) {
        if (ch === '"' && line[i + 1] === '"') { cur += '"'; i += 2; continue; }
        if (ch === '"') { q = false; i++; continue; }
        cur += ch; i++; continue;
      }
      if (ch === '"') { q = true; i++; continue; }
      if (ch === ",") { cells.push(cur); cur = ""; i++; continue; }
      cur += ch; i++;
    }
    cells.push(cur);
    rows.push(cells);
  }
  rows.shift(); // header
  return rows;
}

// --- índices en memoria -----------------------------------------------------
const COLS = {};   // table -> [{name, tipo, nullable}]
for (const [t, , name, tipo, nul] of parseCSV("cols.csv")) {
  (COLS[t] = COLS[t] || []).push({ name, tipo, nullable: nul });
}
const PK = {};     // table -> Set(col)
for (const [t, c] of parseCSV("pk.csv")) { (PK[t] = PK[t] || new Set()).add(c); }
const FK = {};     // table -> { col -> refTable }
for (const [t, c, ref] of parseCSV("fk.csv")) { (FK[t] = FK[t] || {})[c] = ref; }
const COMMENT = {}; // table -> { col -> comment }
for (const [t, c, cm] of parseCSV("comments.csv")) { (COMMENT[t] = COMMENT[t] || {})[c] = cm; }
const CHECK = {};  // table -> [cond]
for (const [t, cond] of parseCSV("checks.csv")) { (CHECK[t] = CHECK[t] || []).push(cond); }

const exists = (t) => !!COLS[t];
const clave = (t, c) => {
  const pk = PK[t] && PK[t].has(c);
  const fk = FK[t] && FK[t][c];
  if (pk && fk) return "PK, FK→" + fk;
  if (pk) return "PK";
  if (fk) return "FK→" + fk;
  return "—";
};

// --- descripción: override curado > comentario BD > heurística fiel ---------
function descripcion(t, c, overrides) {
  if (overrides && overrides[c] !== undefined) return overrides[c];
  if (COMMENT[t] && COMMENT[t][c]) return COMMENT[t][c];
  const pk = PK[t] && PK[t].has(c);
  const fk = FK[t] && FK[t][c];
  if (pk && !fk) return "Identificador único.";
  if (fk) return "Referencia a " + fk + ".";
  const n = c.toUpperCase();
  const map = [
    [/^(OBSERVACION|OBSERVACIONES|OBS)$/, "Comentario libre."],
    [/^DESCRIPCION$/, "Descripción."],
    [/^NOMBRE$/, "Nombre."],
    [/^(ACTIVO|ES_ACTIVO)$/, "Indicador de vigencia (S/N)."],
    [/^ESTADO$/, "Estado del registro."],
    [/^(FECHA_CREACION|FEC_CREACION|FECHA_ALTA)$/, "Fecha de alta del registro."],
    [/^(FECHA_MODIFICACION|FEC_MODIFICACION)$/, "Fecha de última modificación."],
    [/^(USUARIO_CREACION|USUARIO_CREA|USU_CREACION)$/, "Usuario que creó el registro."],
    [/^(USUARIO_MODIFICACION|USU_MODIFICACION)$/, "Usuario de la última modificación."],
  ];
  for (const [re, d] of map) if (re.test(n)) return d;
  return "—";
}

// filas del diccionario para una tabla: [col, tipo, nulo, clave, desc]
function dictRows(t, overrides) {
  if (!exists(t)) throw new Error("Tabla inexistente en el dump: " + t);
  return COLS[t].map((col) => [
    col.name, col.tipo, col.nullable === "N" ? "No" : "Sí",
    clave(t, col.name), descripcion(t, col.name, overrides),
  ]);
}

module.exports = { COLS, PK, FK, COMMENT, CHECK, exists, clave, descripcion, dictRows };

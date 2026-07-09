// ============================================================================
// er.js — genera el .puml del ER (esquema físico) de un módulo desde el dump.
// Entidades del módulo con columnas (PK/FK marcadas); entidades frontera (otro
// módulo) compactas con su PK; relaciones crow's-foot (IE) desde las FK reales.
// ============================================================================
const fs = require("fs");
const path = require("path");
const S = require("./schema");

const HEADER = `!theme plain
skinparam dpi 150
skinparam backgroundColor #FFFFFF
skinparam shadowing false
skinparam roundcorner 4
skinparam linetype ortho
skinparam DefaultFontName Segoe UI
skinparam entityFontSize 12
skinparam entityAttributeFontSize 10
skinparam entity {
  BackgroundColor #FFFFFF
  BorderColor #2E5A88
  ArrowColor #34506B
}
skinparam entity {
  BackgroundColor<<frontera>> #EFEFEF
  BorderColor<<frontera>> #9AA5B1
}
hide circle`;

function entity(t, owned) {
  const cols = S.COLS[t] || [];
  if (!owned) {
    // frontera: solo la PK
    const pk = cols.filter((c) => S.PK[t] && S.PK[t].has(c.name));
    const body = (pk.length ? pk : cols.slice(0, 1))
      .map((c) => `  * ${c.name} : ${c.tipo} <<PK>>`).join("\n");
    return `entity "${t}" as ${t} <<frontera>> {\n${body}\n}`;
  }
  const lines = cols.map((c) => {
    const mark = S.clave(t, c.name);
    const key = mark === "—" ? "" : ` <<${mark.replace("→", "-")}>>`;
    const req = c.nullable === "N" ? "* " : "";
    return `  ${req}${c.name} : ${c.tipo}${key}`;
  });
  return `entity "${t}" as ${t} {\n${lines.join("\n")}\n}`;
}

// emitPuml({ key, title, owned:[tabla], outDir })
function emitPuml({ key, title, owned, outDir }) {
  const ownedSet = new Set(owned);
  const frontier = new Set();
  const rels = [];
  for (const t of owned) {
    const fks = S.FK[t] || {};
    for (const [col, ref] of Object.entries(fks)) {
      if (!ownedSet.has(ref)) frontier.add(ref);
      // relación: ref (1) ||--o{ (muchos) t
      if (ref === t) rels.push(`${t} ||--o{ ${t} : (auto-referencia)`);
      else rels.push(`${ref} ||--o{ ${t}`);
    }
  }
  // entidades frontera que no existan en el dump se omiten
  const frontierValid = [...frontier].filter((t) => S.exists(t));

  const parts = [`@startuml er_${key}`, HEADER,
    `title ${title}\\nEsquema físico: PK (llave), FK (#), * = obligatorio`, ""];
  parts.push("' --- entidades del módulo ---");
  for (const t of owned) parts.push(entity(t, true), "");
  parts.push("' --- entidades frontera ---");
  for (const t of frontierValid) parts.push(entity(t, false), "");
  parts.push("' --- relaciones (crow's-foot desde FK reales) ---");
  // dedup relaciones
  parts.push(...[...new Set(rels)]);
  parts.push("@enduml", "");

  const outPath = path.join(outDir, `er_${key}.puml`);
  fs.writeFileSync(outPath, parts.join("\n"));
  return outPath;
}

module.exports = { emitPuml };

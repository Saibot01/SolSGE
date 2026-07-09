// ============================================================================
// build_manual.js — Manual Técnico SolSGE (documento combinado, todos los módulos).
// §3 Modelo de datos (ER + diccionario exhaustivo) y §4 Backend, data-driven
// desde la BD (_data/*.csv + _gen/*). Reutiliza ../diagramas/_build/docxlib.js.
// Ejecutar: node doc/manual_tecnico/build_manual.js
// ============================================================================
const path = require("path");
const lib = require(path.join(__dirname, "..", "diagramas", "_build", "docxlib.js"));
const { P, Field, H1, H2, H3, SubBold, bullet, caption, pageBreak,
        makeImg, makeCaratula, portraitSection, landscapeSection, buildDoc, dataTable } = lib;
const { PORT_PX } = lib.SIZES;
const S = require("./_gen/schema");
const { MODULES } = require("./_gen/modules");
const backend = require("./_gen/backend");
const N = require("./_gen/narrative");

const { imgFit, imgFitBox } = makeImg(path.join(__dirname, "er"));
const OUT = path.join(__dirname, "Manual_Tecnico_SOLSGE.docx");

// ratios reales de cada ER (ancho/alto del PNG)
const ER_RATIO = {
  ventas: 1.076, facturacion_caja: 1.271, compras: 1.922, inventario: 1.181,
  reportes: 1.964, seguridad: 2.048, catalogos: 1.747,
};

// diccionario: tabla de columnas de una tabla de negocio
const DW = [24, 14, 6, 21, 35];
const HEAD = ["Columna", "Tipo", "Nulo", "Clave", "Descripción"];
const tablaDic = (t, prop, ov) => [
  H3(t),
  P(prop, { after: 100 }),
  dataTable({ headers: HEAD, rows: S.dictRows(t, ov), widths: DW, fontSize: 17 }),
  P("", { after: 120 }),
];
// número de figura del ER de cada módulo dentro del Anexo A (orden de módulos)
const figER = (i) => "A." + (i + 1);

// ---- §3 Modelo de datos (solo diccionario; los ER van en el Anexo A) -------
function seccionModeloDatos() {
  const kids = [
    H1("3. Modelo de datos"),
    P("Esta sección documenta el esquema físico del sistema: las tablas reales, sus columnas, tipos, nulabilidad y las relaciones de clave foránea, leídas directamente de la base de datos (esquema WKSP_WORKPLACE). Se organiza por módulo mediante el diccionario de datos exhaustivo de sus tablas."),
    P("El modelo entidad-relación (esquema físico: tablas y FK reales) de cada módulo se presenta agrupado en el Anexo A, en formato apaisado. Complementa la vista lógica (diagramas de clases) del libro de Diagramas UML.", { after: 120 }),
  ];
  MODULES.forEach((m, i) => {
    if (i > 0) kids.push(pageBreak());
    kids.push(H2("3." + (i + 1) + ". Módulo " + m.name));
    if (m.intro) kids.push(P(m.intro, { after: 100 }));
    kids.push(P("El modelo entidad-relación de este módulo se presenta en el Anexo A (Figura " + figER(i) + ").", { after: 100 }));
    kids.push(H3("Diccionario de datos"));
    kids.push(P("Detalle de cada tabla del módulo: columnas con tipo, nulabilidad, clave (PK/FK y tabla referida) y descripción.", { after: 100 }));
    m.tables.forEach((tb) => kids.push(...tablaDic(tb.t, tb.prop, tb.ov)));
  });
  return kids;
}

// ---- Anexo A: todos los ER, agrupados en un bloque apaisado ----------------
function anexoER() {
  const kids = [
    H1("Anexo A. Modelos entidad-relación (esquema físico)"),
    P("Diagrama entidad-relación de cada módulo, generado desde las claves foráneas reales de la base de datos (notación crow's-foot). Las entidades en gris son entidades frontera de otros módulos, incluidas solo para mostrar las claves foráneas que cruzan el límite del módulo.", { after: 120 }),
  ];
  MODULES.forEach((m, i) => {
    if (i > 0) kids.push(pageBreak());
    kids.push(H2("Figura " + figER(i) + ". Módulo " + m.name));
    kids.push(imgFitBox("er_" + m.key + ".png", 915, 470, ER_RATIO[m.key]));
    kids.push(caption("Modelo entidad-relación (físico) — Módulo " + m.name + "."));
  });
  return kids;
}

// ---- §4 Backend ------------------------------------------------------------
function seccionBackend() {
  const kids = [
    H1("4. Componentes del backend (PL/SQL)"),
    P("La lógica de negocio vive en la base de datos como funciones, procedimientos, triggers y vistas. Esta sección describe cada componente y sus efectos, organizado por módulo. No se transcribe el código fuente: la definición autoritativa reside en el propio esquema de la base de datos."),
    H2("4.1. Convenciones"),
    bullet("**Catálogo de errores −20xxx por rango**: cada componente reserva un rango de RAISE_APPLICATION_ERROR para señalar violaciones de reglas de negocio."),
    bullet("**Regla de fecha/hora**: la base corre en UTC. Para toda fecha/hora de negocio o auditoría se usan **FN_HOY** (fecha) y **FN_AHORA** (fecha+hora), en zona America/Argentina/Buenos_Aires (UTC−3). Nunca SYSDATE/SYSTIMESTAMP salvo excepciones documentadas."),
    bullet("**Vistas como fuente de verdad**: los reportes e informes consumen vistas (V_*) que centralizan las reglas de cálculo, en lugar de repetir la lógica en cada página."),
  ];
  MODULES.forEach((m, i) => {
    const b = backend[m.key];
    if (!b) return;
    kids.push(pageBreak());
    kids.push(H2("4." + (i + 2) + ". Módulo " + m.name));
    for (const [grupo, items] of Object.entries(b)) {
      if (!items.length) continue;
      kids.push(H3(grupo));
      items.forEach(([nombre, desc]) => kids.push(Field(nombre + " — ", desc)));
    }
  });
  return kids;
}

buildDoc({
  outPath: OUT,
  sections: [
    portraitSection(makeCaratula({
      titulo: "MANUAL TÉCNICO",
      subtitulo: "Modelo de datos y backend — Sistema completo",
      sistema: "Sole – Sistema de Gestión Empresarial",
      sigla: "SOLSGE", organo: "Facultad Politécnica – UNA",
      ciudad: "Asunción", fecha: "Julio 2026",
    }), true),
    portraitSection([...N.cap1(), pageBreak(), ...N.cap2()]),
    portraitSection(seccionModeloDatos()),
    portraitSection(seccionBackend()),
    portraitSection([
      ...N.cap5(), pageBreak(), ...N.cap6(), pageBreak(), ...N.cap7(),
      pageBreak(), ...N.cap8(), pageBreak(), ...N.cap9(), pageBreak(), ...N.cap10(),
    ]),
    landscapeSection(anexoER()),
  ],
});

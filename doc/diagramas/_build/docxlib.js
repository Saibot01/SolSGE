// ============================================================================
// docxlib.js — Librería compartida para armar los Word de diagramas UML (tesis SolSGE)
// Formato APROBADO por el PO (2026-07-07) con el piloto Facturación+Caja:
//   - A4 (11906x16838), márgenes cátedra (sup/inf 1417, izq/der 1701)
//   - Times New Roman 12, interlineado 1.5, títulos NEGROS
//   - Portada réplica de la plantilla del profesor (centrado, TNR 18pt)
//   - Encabezado: banner UNA-FP en todas las páginas; pie: nº de página (portada sin pie)
//   - Orientación AGRUPADA por bloque (vertical primero, horizontal después)
// Uso: cada módulo hace require('./docxlib') y llama buildDoc({ outPath, sections }).
// Requiere: npm install docx   (ya instalado en este directorio _build)
// ============================================================================
const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, ImageRun, AlignmentType,
  HeadingLevel, PageOrientation, PageNumber, Header, Footer, BorderStyle, LineRuleType,
  Table, TableRow, TableCell, WidthType, ShadingType, VerticalAlign,
} = require("docx");

const FONT = "Times New Roman";
const LOGO = path.join(__dirname, "..", "_assets", "logo_fpuna.png");

// --- párrafos de texto -----------------------------------------------------
const L15 = { line: 360, lineRule: LineRuleType.AUTO };

const P = (text, opts = {}) =>
  new Paragraph({
    spacing: { after: opts.after ?? 160, before: opts.before ?? 0, ...L15 },
    alignment: opts.align ?? AlignmentType.JUSTIFIED,
    children: [new TextRun({ text, bold: opts.bold, italics: opts.italics, size: opts.size })],
  });

const Field = (label, body) =>
  new Paragraph({
    spacing: { after: 160, ...L15 }, alignment: AlignmentType.JUSTIFIED,
    children: [new TextRun({ text: label, bold: true }), new TextRun({ text: body })],
  });

const H1 = (text) => new Paragraph({ heading: HeadingLevel.HEADING_1, spacing: { before: 240, after: 160 }, children: [new TextRun({ text, bold: true })] });
const H2 = (text) => new Paragraph({ heading: HeadingLevel.HEADING_2, spacing: { before: 200, after: 120 }, children: [new TextRun({ text, bold: true })] });
const H3 = (text) => new Paragraph({ heading: HeadingLevel.HEADING_3, spacing: { before: 160, after: 60 }, children: [new TextRun({ text, bold: true })] });

const SubBold = (text) => new Paragraph({ spacing: { before: 120, after: 60, ...L15 }, children: [new TextRun({ text, bold: true, italics: true })] });

const bullet = (text) => new Paragraph({ numbering: { reference: "vinetas", level: 0 }, spacing: { after: 60, ...L15 }, children: parseRuns(text) });
const num = (text) => new Paragraph({ numbering: { reference: "pasos", level: 0 }, spacing: { after: 60, ...L15 }, children: parseRuns(text) });

// **negrita** inline dentro de listas
function parseRuns(text) {
  const runs = [];
  for (const part of text.split(/(\*\*[^*]+\*\*)/g)) {
    if (!part) continue;
    if (part.startsWith("**") && part.endsWith("**")) runs.push(new TextRun({ text: part.slice(2, -2), bold: true }));
    else runs.push(new TextRun({ text: part }));
  }
  return runs;
}

const pageBreak = () => new Paragraph({ pageBreakBefore: true, children: [new TextRun("")] });

// --- tablas (diccionario de datos, catálogos) ------------------------------
// dataTable({ headers:[str], rows:[[str|{t,b}]], widths:[pct], fontSize })
//   headers -> fila de cabecera (negrita, fondo azul cátedra)
//   rows    -> cada celda es string o {t:texto, b:bool negrita, mono:bool}
//   widths  -> porcentajes por columna (suman 100); default equiespaciado
const TB = { style: BorderStyle.SINGLE, size: 2, color: "AAB4C0" };
const cellBorders = { top: TB, bottom: TB, left: TB, right: TB };
function tCell(content, { header = false, size = 18, align = AlignmentType.LEFT, width } = {}) {
  const items = Array.isArray(content) ? content : [content];
  const runs = items.map((it) => {
    const o = typeof it === "string" ? { t: it } : it;
    return new TextRun({ text: o.t, bold: header || o.b, size, font: o.mono ? "Consolas" : FONT });
  });
  return new TableCell({
    borders: cellBorders,
    verticalAlign: VerticalAlign.CENTER,
    shading: header ? { type: ShadingType.CLEAR, fill: "DCE9F5" } : undefined,
    margins: { top: 20, bottom: 20, left: 70, right: 70 },
    ...(width ? { width: { size: width, type: WidthType.PERCENTAGE } } : {}),
    children: [new Paragraph({ alignment: align, spacing: { after: 0, line: 240, lineRule: LineRuleType.AUTO }, children: runs })],
  });
}
function dataTable({ headers, rows, widths, fontSize = 18 }) {
  const w = widths || headers.map(() => Math.round(100 / headers.length));
  const headRow = new TableRow({
    tableHeader: true,
    children: headers.map((h, i) => tCell(h, { header: true, size: fontSize, width: w[i], align: AlignmentType.CENTER })),
  });
  const bodyRows = rows.map((r) => new TableRow({
    children: r.map((c, i) => tCell(c, { size: fontSize, width: w[i] })),
  }));
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: [headRow, ...bodyRows],
  });
}
const caption = (text) => new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 200 }, children: [new TextRun({ text, italics: true, size: 20 })] });

// --- imágenes (escaladas por ancho o por alto) -----------------------------
// makeImg(dir) devuelve helpers ligados a la carpeta de PNGs del módulo.
function makeImg(dir) {
  const run = (file, w, h) => new Paragraph({
    alignment: AlignmentType.CENTER, spacing: { before: 120, after: 80 },
    children: [new ImageRun({ type: "png", data: fs.readFileSync(path.join(dir, file)),
      transformation: { width: w, height: h },
      altText: { title: file, description: file, name: file } })],
  });
  return {
    imgFit: (file, maxW, ratio) => run(file, maxW, Math.round(maxW / ratio)),   // por ancho
    imgFitH: (file, maxH, ratio) => run(file, Math.round(maxH * ratio), maxH),  // por alto
    // ajusta dentro de una caja (maxW x maxH) preservando el ratio — evita desbordes
    imgFitBox: (file, maxW, maxH, ratio) => {
      let w = Math.round(maxH * ratio), h = maxH;
      if (w > maxW) { w = maxW; h = Math.round(maxW / ratio); }
      return run(file, w, h);
    },
  };
}

// --- encabezado (banner UNA-FP) + pie (nº de página) -----------------------
const bannerHeader = new Header({
  children: [new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 40 },
    children: [new ImageRun({ type: "png", data: fs.readFileSync(LOGO),
      transformation: { width: 360, height: 74 },
      altText: { title: "UNA-FP", description: "Universidad Nacional de Asunción - Facultad Politécnica", name: "logo" } })] })],
});
const pageFooter = new Footer({
  children: [new Paragraph({ alignment: AlignmentType.CENTER,
    border: { top: { style: BorderStyle.SINGLE, size: 4, color: "999999", space: 6 } },
    children: [new TextRun({ children: ["Página ", PageNumber.CURRENT], size: 20 })] })],
});

// --- páginas A4 + márgenes cátedra -----------------------------------------
const A4_W = 11906, A4_H = 16838;
const M  = { top: 1720, right: 1701, bottom: 1417, left: 1701, header: 400, footer: 708 };
const ML = { top: 1720, right: 1417, bottom: 900,  left: 1417, header: 400, footer: 540 };
const PORTRAIT = { size: { width: A4_W, height: A4_H }, margin: M };
const LAND     = { size: { width: A4_W, height: A4_H, orientation: PageOrientation.LANDSCAPE }, margin: ML };
// alturas máximas recomendadas para que la imagen entre con título+intro+caption en una hoja
const SIZES = { PORT_PX: 560, ACT_H: 640, LAND_H_CLASS: 395, LAND_H_SEQ: 390 };

// --- portada (réplica de la plantilla) -------------------------------------
const cBlank = (size = 36) => new Paragraph({ alignment: AlignmentType.CENTER, spacing: L15, children: [new TextRun({ text: "", size })] });
const cLine = (text, opts = {}) => new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: opts.after ?? 0, ...L15 }, children: [new TextRun({ text, size: 36 })] });

// makeCaratula({ titulo, subtitulo, sistema, sigla, organo, ciudad, fecha })
function makeCaratula(c) {
  return [
    cBlank(24), cBlank(24),
    cLine(c.titulo || "DISEÑO DE DIAGRAMAS", { after: 200 }),
    ...(c.subtitulo ? [cLine("(" + c.subtitulo + ")")] : []),
    cBlank(),
    cLine(c.sistema || "Sole – Sistema de Gestión Empresarial"),
    cBlank(),
    cLine(c.sigla || "SOLSGE"),
    cBlank(),
    cLine(c.organo || "Facultad Politécnica – UNA"),
    cBlank(),
    cLine(c.ciudad || "Asunción"),
    cBlank(),
    cLine(c.fecha || "Julio 2026"),
    cBlank(), cBlank(),
    cLine("FACULTAD POLITÉCNICA"),
    cLine("UNIVERSIDAD NACIONAL DE ASUNCIÓN"),
  ];
}

// helpers para envolver los children de cada sección con su config de página
const portraitSection = (children, first = false) => ({
  properties: { page: PORTRAIT, ...(first ? {} : { type: "nextPage" }) },
  headers: { default: bannerHeader },
  ...(first ? {} : { footers: { default: pageFooter } }),
  children,
});
const landscapeSection = (children) => ({
  properties: { page: LAND, type: "nextPage" },
  headers: { default: bannerHeader }, footers: { default: pageFooter },
  children,
});

// --- ensamblado ------------------------------------------------------------
// buildDoc({ outPath, sections }) — sections ya vienen envueltas (portraitSection/landscapeSection)
function buildDoc({ outPath, sections }) {
  const doc = new Document({
    creator: "SOLSGE",
    styles: {
      default: {
        document: { run: { font: FONT, size: 24 }, paragraph: { spacing: { ...L15, after: 160 } } },
      },
      paragraphStyles: [
        { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
          run: { size: 28, bold: true, font: FONT, color: "000000" }, paragraph: { spacing: { before: 240, after: 160 }, outlineLevel: 0 } },
        { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
          run: { size: 26, bold: true, font: FONT, color: "000000" }, paragraph: { spacing: { before: 200, after: 120 }, outlineLevel: 1 } },
        { id: "Heading3", name: "Heading 3", basedOn: "Normal", next: "Normal", quickFormat: true,
          run: { size: 24, bold: true, font: FONT, color: "000000" }, paragraph: { spacing: { before: 140, after: 60 }, outlineLevel: 2 } },
      ],
    },
    numbering: {
      config: [
        { reference: "vinetas", levels: [{ level: 0, format: "bullet", text: "•", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
        { reference: "pasos", levels: [{ level: 0, format: "decimal", text: "%1.", alignment: AlignmentType.LEFT, style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      ],
    },
    sections,
  });
  return Packer.toBuffer(doc).then((buf) => { fs.writeFileSync(outPath, buf); console.log("OK ->", outPath); });
}

module.exports = {
  P, Field, H1, H2, H3, SubBold, bullet, num, caption, pageBreak, parseRuns,
  makeImg, makeCaratula, portraitSection, landscapeSection, buildDoc, dataTable,
  bannerHeader, pageFooter, PORTRAIT, LAND, SIZES, AlignmentType, Paragraph, TextRun,
};

// The `math-check` build hook (tola.toml): warns about formulas that cannot
// copy as LaTeX and copy as a placeholder instead (templates/latex.typ),
// pointing at them in the source like a compiler warning.
//
// Tola shows a hook's output only when the hook fails (and without colour),
// so under `tola dev` the report exits 1: Tola prints it after the rebuild,
// and the site updates as usual. `tola build` skips the report, since a
// failing hook would fail the build, and with it a deployment.
//
// Formulas from utils/mitex.typ copy their own source and are fine.
import { existsSync, readFileSync } from "node:fs";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";

const { TOLA_HOOK_INPUT_DIR: site, TOLA_BUILD_MODE: mode } = process.env;
if (!site) {
  console.error("Run by Tola as the `math-check` build hook; use `tola dev`.");
  process.exit(1);
}
if (mode !== "dev") process.exit(0);
const content = "content"; // build.content-dir in tola.toml

// ============================================================================
// Pages
// ============================================================================

const decode = (s) =>
  s.replace(/&(lt|gt|quot|#39|amp);/g, (_, e) => ({ lt: "<", gt: ">", quot: '"', "#39": "'", amp: "&" })[e]);
const attr = (tag, name) => tag.match(new RegExp(`\\s${name}="([^"]*)"`))?.[1];
const core = (w) => w.toLowerCase().replace(/[^\p{L}\p{N}]/gu, "");
const words = (text) => text.split(/\s+/).map(core).filter(Boolean);

/// The text between the previous formula (or tag soup) and `at`.
const textBefore = (html, from, at) =>
  decode(
    html
      .slice(from, at)
      .replace(/^[\s\S]*<\/svg>/, "")
      .replace(/^[^<]*>/, "")
      .replace(/<\/?span[^>]*>/g, "")
      .replace(/<[^>]*>/g, " "),
  )
    .replace(/\s+/g, " ")
    .trim();

/// The page's formulas in order: (issues, text before, moved). A formula
/// from utils/mitex.typ counts once, and never has issues. `moved` marks one
/// that is not where its source puts it: in the notes after the text, or a
/// heading's copy in the table of contents.
const pageFormulas = (html) => {
  const out = [];
  const elsewhere = [/<section class="endnotes"[\s\S]*?<\/section>/g, /<aside class="toc"[\s\S]*?<\/aside>/g]
    .flatMap((re) => [...html.matchAll(re)])
    .map((m) => [m.index, m.index + m[0].length]);
  let prev = 0;
  for (const m of html.matchAll(/<(?:span|div) role="math"[^>]*>/g)) {
    const wrapped = /<(?:span|div) data-latex="[^"]*">$/.test(html.slice(Math.max(0, m.index - 4000), m.index));
    const issues = wrapped ? null : attr(m[0], "data-latex-issues");
    out.push({
      issues: issues && decode(issues),
      before: textBefore(html, Math.max(prev, m.index - 3000), m.index),
      moved: elsewhere.some(([a, b]) => m.index > a && m.index < b),
    });
    prev = m.index;
  }
  return out;
};

// ============================================================================
// Sources
// ============================================================================

const sourceOf = (page) => {
  const base = join(content, page.replace(/\/$/, ""));
  return [base + ".typ", join(base, "index.typ")].find(existsSync);
};

/// Formulas in Typst source, in order, as [start, end) offsets: `$...$`
/// (with anything nested inside it), `#mi(...)` / `#mitex(...)`. Comments and
/// raw text are skipped; `$` inside strings counts, as `eval` turns such
/// strings into formulas.
const sourceFormulas = (src) => {
  const out = [];
  const skipRaw = (i) => {
    const ticks = src.slice(i).match(/^`+/)[0];
    const end = src.indexOf(ticks, i + ticks.length);
    return end === -1 ? src.length : end + ticks.length;
  };
  const balanced = (i, open, close) => {
    let depth = 0;
    for (; i < src.length; i++) {
      if (src[i] === "`") i = skipRaw(i) - 1;
      else if (src[i] === open) depth++;
      else if (src[i] === close && --depth === 0) return i + 1;
    }
    return src.length;
  };
  for (let i = 0; i < src.length; i++) {
    const c = src[i];
    if (c === "\\") i++;
    else if (c === "/" && src[i + 1] === "/" && (i === 0 || /\s/.test(src[i - 1]))) i = src.indexOf("\n", i) >>> 0 || src.length;
    else if (c === "/" && src[i + 1] === "*") i = src.indexOf("*/", i) + 1 || src.length;
    else if (c === "`") i = skipRaw(i) - 1;
    else if (c === "#" && /^#(mi|mitex|mimath)\(/.test(src.slice(i, i + 9))) {
      const end = balanced(src.indexOf("(", i), "(", ")");
      out.push([i, end]);
      i = end - 1;
    } else if (c === "$") {
      let j = i + 1;
      for (; j < src.length && src[j] !== "$"; j++) {
        if (src[j] === "\\") j++;
        else if (src[j] === "[" && /#[\w.-]*(\([^)]*\))?$/.test(src.slice(Math.max(i, j - 80), j))) j = balanced(j, "[", "]") - 1;
      }
      out.push([i, j + 1]);
      i = j;
    }
  }
  return out;
};

/// Where the formula `n` of a page sits in its source, or null: by order
/// when page and source have the same formulas in the same order, else by
/// searching the source for the words before it.
const locate = (src, formulas, page, n) => {
  if (formulas.length === page.length && !page.some((f) => f.moved)) return formulas[n];
  const said = words(page[n].before);
  const tokens = [...src.matchAll(/\S+/g)].map((m) => ({ core: core(m[0]), end: m.index + m[0].length })).filter((t) => t.core);
  for (let k = Math.min(5, said.length); k > 0; k--) {
    const tail = said.slice(-k);
    for (let t = 0; t + k <= tokens.length; t++) {
      if (!tail.every((w, d) => tokens[t + d].core === w)) continue;
      const end = tokens[t + k - 1].end;
      const next = formulas.find(([s]) => s >= end && s - end < 300);
      if (next) return next;
    }
  }
  return null;
};

// ============================================================================
// Report
// ============================================================================

const placeholder = "\\text{[unsupported formula]}";

const frame = (file, src, [start, end], issues) => {
  const lineStart = src.lastIndexOf("\n", start - 1) + 1;
  const lineEnd = src.indexOf("\n", start) === -1 ? src.length : src.indexOf("\n", start);
  const line = src.slice(0, start).split("\n").length;
  const col = [...src.slice(lineStart, start)].length;
  const text = src.slice(lineStart, lineEnd).replace(/\r$/, "").replace(/\t/g, " ");
  const width = Math.max(1, [...src.slice(start, Math.min(end, lineEnd))].length);
  const pad = " ".repeat(String(line).length);
  return {
    pad,
    lines: [
      `${pad} ┌─ ${file}:${line}:${col + 1}`,
      `${pad} │`,
      `${line} │ ${text}`,
      `${pad} │ ${" ".repeat(col)}${"^".repeat(width)} no LaTeX for ${issues}`,
      `${pad} │`,
    ],
  };
};

const blocks = [];
for (const file of (await readdir(site, { recursive: true })).sort()) {
  if (!file.endsWith(".html")) continue;
  const page = pageFormulas(await readFile(join(site, file), "utf8"));
  if (!page.some((f) => f.issues)) continue;
  const url = "/" + file.split(/[\\/]/).join("/").replace(/index\.html$/, "");
  const path = sourceOf(url);
  const src = path ? readFileSync(path, "utf8") : null;
  const formulas = src ? sourceFormulas(src) : [];
  page.forEach((f, n) => {
    if (!f.issues) return;
    const at = src ? locate(src, formulas, page, n) : null;
    // Without a source position: the page, and the text before the formula.
    const { pad, lines } = at
      ? frame(path, src, at, f.issues)
      : {
          pad: "",
          lines: [
            ` ┌─ ${url}${path ? ` (${path})` : ""}`,
            ` │`,
            ` │ …${f.before.slice(-60)} ⟨formula⟩ no LaTeX for ${f.issues}`,
            ` │`,
          ],
        };
    blocks.push([
      "warning: formula cannot copy as LaTeX",
      ...lines,
      `${pad} = it copies as ${placeholder}`,
      `${pad} = help: write it with \`mi\` / \`mitex\` to copy as written`,
    ].join("\n"));
  });
}

if (blocks.length) {
  const count = blocks.length === 1 ? "1 formula" : `${blocks.length} formulas`;
  process.stderr.write(`${count} cannot copy as LaTeX\n\n` + blocks.join("\n\n") + "\n");
  process.exit(1);
}

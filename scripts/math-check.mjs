// The `math-check` build hook (tola.toml): warns about formulas that cannot
// copy as LaTeX and copy as a placeholder instead (templates/latex.typ),
// pointing at them in the source like a compiler warning.
//
// Tola shows a hook's output only when the hook fails (and without colour),
// so under `tola dev` the report exits 1: Tola prints it after the rebuild,
// and the site updates as usual. `tola build` skips the report, since a
// failing hook would fail the build, and with it a deployment.
//
// Formulas from utils/mitex.typ copy their own source and are fine. A page
// that shows unconvertible formulas on purpose opts out with a line
// `// math-check: ignore` in its source.
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

/// The page's formulas in order: { issues, latex, before, where }. A
/// formula from utils/mitex.typ counts once, never has issues, and its
/// `latex` is the source it was written in. `where` is "text", "notes" (the
/// notes and terms after the text, in the order their sources run), or
/// "toc" (a heading's copy in the table of contents).
const pageFormulas = (html) => {
  const ranges = (re) => [...html.matchAll(re)].map((m) => [m.index, m.index + m[0].length]);
  const within = (spans, i) => spans.some(([a, b]) => i > a && i < b);
  const notes = ranges(/<section class="endnotes[^"]*"[\s\S]*?<\/section>/g);
  const toc = ranges(/<aside class="toc"[\s\S]*?<\/aside>/g);
  const out = [];
  let prev = 0;
  for (const m of html.matchAll(/<(?:span|div) role="math"[^>]*>/g)) {
    const wrapper = html.slice(Math.max(0, m.index - 4000), m.index).match(/<(?:span|div) data-latex="([^"]*)">$/);
    const issues = wrapper ? null : attr(m[0], "data-latex-issues");
    out.push({
      issues: issues && decode(issues),
      latex: decode(wrapper ? wrapper[1] : (attr(m[0], "data-latex") ?? "")),
      before: textBefore(html, Math.max(prev, m.index - 3000), m.index),
      where: within(toc, m.index) ? "toc" : within(notes, m.index) ? "notes" : "text",
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

/// A line `// math-check: ignore` anywhere in a source leaves its page out
/// of the report, for pages that show such formulas on purpose.
const ignored = (src) => /^[ \t]*\/\/[ \t]*math-check:[ \t]*ignore[ \t]*$/m.test(src);

/// Formulas in Typst source, in order, as { start, end, raw } offsets:
/// `$...$` (with anything nested inside it), `#mi(...)` / `#mitex(...)`.
/// Comments and raw text are skipped, except ```typst blocks, whose formulas
/// count with `raw` set, since `demo` and the like render them; `$` inside
/// strings counts, as `eval` turns such strings into formulas.
const sourceFormulas = (src, from = 0, to = src.length, raw = false) => {
  const out = [];
  const rawEnd = (i) => {
    const ticks = src.slice(i).match(/^`+/)[0];
    const end = src.indexOf(ticks, i + ticks.length);
    return end === -1 ? to : end + ticks.length;
  };
  const balanced = (i, open, close) => {
    let depth = 0;
    for (; i < to; i++) {
      if (src[i] === "`") i = rawEnd(i) - 1;
      else if (src[i] === open) depth++;
      else if (src[i] === close && --depth === 0) return i + 1;
    }
    return to;
  };
  for (let i = from; i < to; i++) {
    const c = src[i];
    if (c === "\\") i++;
    else if (c === "/" && src[i + 1] === "/" && (i === 0 || /\s/.test(src[i - 1]))) i = src.indexOf("\n", i) >>> 0 || to;
    else if (c === "/" && src[i + 1] === "*") i = src.indexOf("*/", i) + 1 || to;
    else if (c === "`") {
      const end = rawEnd(i);
      const block = src.slice(i).match(/^(`{3,})(typst|typ)\b[^\n]*\n/);
      if (block) out.push(...sourceFormulas(src, i + block[0].length, end - block[1].length, true));
      i = end - 1;
    } else if (c === "#" && /^#(mi|mitex|mimath)\(/.test(src.slice(i, i + 9))) {
      const end = balanced(src.indexOf("(", i), "(", ")");
      out.push({ start: i, end, raw });
      i = end - 1;
    } else if (c === "$") {
      let j = i + 1;
      for (; j < to && src[j] !== "$"; j++) {
        if (src[j] === "\\") j++;
        else if (src[j] === "[" && /#[\w.-]*(\([^)]*\))?$/.test(src.slice(Math.max(i, j - 80), j))) j = balanced(j, "[", "]") - 1;
      }
      out.push({ start: i, end: j + 1, raw });
      i = j;
    }
  }
  return out;
};

// ============================================================================
// Matching
// ============================================================================
// Page and source rarely have the same formulas: `demo` shows a formula's
// source and renders it, a footnote's formula moves to the notes, a string
// is drawn only by `eval`. So the two lists are aligned as a diff aligns
// lines, keeping their order and pairing the formulas that look most alike.

/// Words, and LaTeX command names without their backslash.
const tokens = (s) => new Set(s.replace(/\\([a-zA-Z]+)/g, " $1 ").toLowerCase().match(/[\p{L}\p{N}]+/gu) ?? []);

/// Share of the tokens two sets have in common (Jaccard index).
const overlap = (a, b) => {
  let n = 0;
  for (const t of a) if (b.has(t)) n++;
  return n ? n / (a.size + b.size - n) : 0;
};

/// How many of the last five words two word lists end with, from 0 to 1.
const sameEnding = (a, b) => {
  let k = 0;
  while (k < 5 && k < a.length && k < b.length && a[a.length - 1 - k] === b[b.length - 1 - k]) k++;
  return k / 5;
};

/// How likely page formula `f` was written as source formula `s`: any pair
/// scores a little, so formulas pair up in order; what they contain, the
/// words before them, and the source naming what stopped the conversion
/// ("box", "augment", "⧺") add to it. Formulas in ```typst blocks come last,
/// as most such blocks are only shown.
const likeness = (f, s) =>
  0.1 +
  overlap(f.tokens, s.tokens) +
  sameEnding(f.words, s.words) +
  (f.issues?.split(", ").some((issue) => s.text.includes(issue)) ? 0.5 : 0) -
  (s.raw ? 0.05 : 0);

/// Pairs of indices into `fs` and `ss`, in order, with the highest total
/// likeness.
const align = (fs, ss) => {
  const [m, n] = [fs.length, ss.length];
  const best = Array.from({ length: m + 1 }, () => new Float64Array(n + 1));
  const pair = Array.from({ length: m }, (_, i) => ss.map((s) => likeness(fs[i], s)));
  for (let i = m - 1; i >= 0; i--) {
    for (let j = n - 1; j >= 0; j--) {
      best[i][j] = Math.max(best[i + 1][j], best[i][j + 1], pair[i][j] + best[i + 1][j + 1]);
    }
  }
  const out = [];
  for (let i = 0, j = 0; i < m && j < n; ) {
    if (best[i][j] === pair[i][j] + best[i + 1][j + 1]) out.push([i++, j++]);
    else if (best[i][j] === best[i + 1][j]) i++;
    else j++;
  }
  return out;
};

/// Map from the index of each page formula with issues to its source
/// formula, where one is found. Formulas in the text are aligned first, then
/// those in the notes against the source formulas left over.
const locate = (src, page) => {
  const formulas = sourceFormulas(src).sort((a, b) => a.start - b.start);
  const ss = formulas.map((s, k) => {
    const text = src.slice(s.start, s.end);
    const before = src.slice(k > 0 ? formulas[k - 1].end : Math.max(0, s.start - 3000), s.start);
    return { ...s, text, tokens: tokens(text), words: words(before.replace(/[#*_=\[\](){}"`]/g, " ")) };
  });
  const fs = page.map((f) => ({ ...f, tokens: f.issues ? new Set() : tokens(f.latex), words: words(f.before) }));
  const found = new Map();
  const used = new Set();
  for (const where of ["text", "notes"]) {
    const here = fs.map((f, n) => [f, n]).filter(([f]) => f.where === where);
    const free = ss.filter((_, k) => !used.has(k));
    const index = ss.map((_, k) => k).filter((k) => !used.has(k));
    for (const [i, j] of align(here.map(([f]) => f), free)) {
      used.add(index[j]);
      if (here[i][0].issues) found.set(here[i][1], free[j]);
    }
  }
  return found;
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
  // A heading's copy in the table of contents is reported at the heading.
  const page = pageFormulas(await readFile(join(site, file), "utf8"));
  if (!page.some((f) => f.issues && f.where !== "toc")) continue;
  const url = "/" + file.split(/[\\/]/).join("/").replace(/index\.html$/, "");
  const path = sourceOf(url);
  const src = path ? readFileSync(path, "utf8") : null;
  if (src && ignored(src)) continue;
  const found = src ? locate(src, page) : new Map();
  page.forEach((f, n) => {
    if (!f.issues || f.where === "toc") return;
    const at = found.get(n);
    // Without a source position: the page, and the text before the formula.
    const { pad, lines } = at
      ? frame(path, src, [at.start, at.end], f.issues)
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
      `${pad} = help: write it with \`mi\` / \`mitex\` to copy as written, or put \`// math-check: ignore\` in the source to leave the page out`,
    ].join("\n"));
  });
}

if (blocks.length) {
  const count = blocks.length === 1 ? "1 formula" : `${blocks.length} formulas`;
  process.stderr.write(`${count} cannot copy as LaTeX\n\n` + blocks.join("\n\n") + "\n");
  process.exit(1);
}

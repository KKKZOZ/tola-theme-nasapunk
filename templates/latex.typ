// LaTeX for Typst formulas, so a copied selection can carry them as text.
// Import: #import "/templates/latex.typ": to-latex
//
// A formula's source text is gone once Typst has parsed it; what remains is
// its content tree (attach, frac, lr, ...). `to-latex` walks that tree and
// writes equivalent LaTeX: `$sum_(i=1)^n x_i$` gives `\sum_{i=1}^{n} x_{i}`,
// not the text as typed. Symbols come from latex-symbols.typ. A formula with
// any part that has no LaTeX counterpart (an element without a rule, a symbol
// not in the table, ...) becomes `placeholder` as a whole, and the parts are
// reported as issues. base.typ `math-svg` stores the result as `data-latex` /
// `data-latex-issues`, read by assets/scripts/copy.js.

#import "/templates/latex-symbols.typ": operators, symbols

#let _sequence = [].func()
#let _space = [ ].func()
#let _styled = math.bold[x].func()
#let _align-point = $&$.body.func()
#let _primes = $x'$.body.tr.func()

/// `alt` of the formulas laid out to tell font styles apart; base.typ
/// `math-svg` leaves them to Typst, so they can be measured.
#let probe = "latex-probe"

/// What a formula that cannot be converted copies as.
#let placeholder = "\\text{[unsupported formula]}"

// A rule that cannot convert its part leaves a marker naming it in the
// output; `to-latex` collects them. Private-use characters, so they cannot
// clash with a formula's own text.
#let _issue(name) = "\u{E000}" + name + "\u{E001}"
#let _issue-pattern = regex("\u{E000}([^\u{E001}]*)\u{E001}")
#let _bare(s) = s.replace(_issue-pattern, "")

// ============================================================================
// Characters
// ============================================================================

#let _escapes = (
  "{": "\\{", "}": "\\}", "#": "\\#", "%": "\\%", "$": "\\$", "_": "\\_",
  "&": "\\&", "~": "\\sim", "\\": "\\backslash", "−": "-", "′": "'",
)

// Text as \text{...}, written for KaTeX and MathJax: MathJax shows escapes
// inside \text{} as typed and KaTeX rejects the bare characters, so the
// characters both read only in math mode step out of it (`~` and `^` as
// their nearest math symbols). LaTeX reads all of it too.
#let _text-out = ("_": "\\_", "%": "\\%", "#": "\\#", "&": "\\&", "\\": "\\backslash", "^": "\\hat{}", "~": "\\sim")
#let _text-in = ("$": "\\$", "{": "\\{", "}": "\\}")
#let _in-text(t) = {
  let (out, run) = ("", "")
  for c in t.clusters() {
    if c in _text-out {
      if run != "" { out += "\\text{" + run + "}" }
      (out, run) = (out + _text-out.at(c), "")
    } else {
      run += _text-in.at(c, default: c)
    }
  }
  if run != "" { out += "\\text{" + run + "}" }
  out
}

/// Whether `node` is quoted text (`"if"`), which Typst sets upright. A
/// letter of the formula itself is a symbol instead.
#let _quoted(node) = node.func() == text and node.text.match(regex("\\p{L}")) != none

// Typst's `space.*` symbols, as the spacing LaTeX has closest to them.
#let _spacing = (
  "\u{2000}": "\\enspace", "\u{2001}": "\\quad", "\u{2002}": "\\enspace", "\u{2003}": "\\quad",
  "\u{2004}": "\\;", "\u{2005}": "\\:", "\u{2006}": "\\,", "\u{2007}": "\\phantom{0}",
  "\u{2008}": "\\phantom{.}", "\u{2009}": "\\,", "\u{200A}": "\\hspace{0.04em}", "\u{202F}": "\\,",
  "\u{205F}": "\\:", "\u{200B}": "", "\u{2060}": "",
)

/// `c` as U+XXXX, which names it where the character itself would not show.
#let _codepoint(c) = {
  let hex = upper(str(str.to-unicode(c.codepoints().first()), base: 16))
  "U+" + "0" * calc.max(0, 4 - hex.len()) + hex
}

// ℂ ℍ ℕ ℙ ℚ ℝ ℤ sit in Letterlike Symbols; the other double-struck letters
// and digits in Mathematical Alphanumeric Symbols.
#let _bb-letterlike = ("ℂ": "C", "ℍ": "H", "ℕ": "N", "ℙ": "P", "ℚ": "Q", "ℝ": "R", "ℤ": "Z")
#let _double-struck(c) = {
  if c in _bb-letterlike { return _bb-letterlike.at(c) }
  let n = str.to-unicode(c)
  if n >= 0x1D538 and n <= 0x1D551 { str.from-unicode(n - 0x1D538 + 65) }
  else if n >= 0x1D552 and n <= 0x1D56B { str.from-unicode(n - 0x1D552 + 97) }
  else if n >= 0x1D7D8 and n <= 0x1D7E1 { str.from-unicode(n - 0x1D7D8 + 48) }
}

// Symbols whose command in the table KaTeX or MathJax lacks (found by
// rendering every entry with KaTeX 0.16 and MathJax 3.2 as configured out of
// the box): both read the character itself.
#let _as-is = "£©¶‘’“”ÆßæŒœϐ∌∯∰∹≔≕⊶⊷⟦⟧⦃⦄⦵⩴".clusters()

#let _char(c) = {
  if c in _as-is { return c }
  if c in symbols { return symbols.at(c) }
  if c in _escapes { return _escapes.at(c) }
  if c in _spacing { return _spacing.at(c) }
  if c.len() > 1 and c.clusters().len() == 1 {
    let letter = _double-struck(c)
    if letter != none { return "\\mathbb{" + letter + "}" }
  }
  if c.match(regex("^[\\x00-\\x7F]*$")) != none { return c }
  // A letter LaTeX math has no command for (é, 中): upright text.
  if c.match(regex("^\\p{L}")) != none { return _in-text(c) }
  // Spaces and other invisible characters go by their code point.
  c + _issue(if c.match(regex("^[\\p{Z}\\p{C}]")) != none { _codepoint(c) } else { c })
}

/// A text node: one symbol, a number, or quoted text (as \text, upright
/// like Typst sets it).
#let _text(t) = {
  let t = t.replace("\u{FE0E}", "").replace("\u{FE0F}", "")
  if t.clusters().len() <= 1 { return _char(t) }
  if t.match(regex("^[\\d.,]+$")) != none { return t }
  if t.match(regex("\\p{L}")) != none { return _in-text(t) }
  t.clusters().map(_char).join()
}

// ============================================================================
// Joining
// ============================================================================

/// Concatenate LaTeX pieces, with a space where a command name would
/// otherwise run into the letters after it (`\alpha x`, not `\alphax`).
#let _join(parts) = parts.fold("", (acc, p) => {
  if _bare(acc).match(regex("\\\\[a-zA-Z]+$")) != none and p.match(regex("^[a-zA-Z]")) != none {
    acc + " " + p
  } else {
    acc + p
  }
})

#let _group(s) = {
  let s = s.trim()
  if _bare(s).clusters().len() == 1 { s } else { "{" + s + "}" }
}

// ============================================================================
// Font styles
// ============================================================================
// `bold(x)`, `bb(R)`, ... come out as `styled` content whose styles cannot
// be read, so each candidate is laid out and the one whose size matches the
// original names the style. Plain content matching means the style does not
// change the glyphs (a colour); no match at all (bold(cal(x))) drops the
// style, reported as an issue.

#let _variants = (
  (none, x => x),
  ("\\mathbf", x => math.bold(math.upright(x))),
  ("\\boldsymbol", math.bold),
  ("\\mathrm", math.upright),
  ("\\mathbb", math.bb),
  ("\\mathcal", math.cal),
  ("\\mathscr", math.scr),
  ("\\mathfrak", math.frak),
  ("\\mathsf", math.sans),
  ("\\mathtt", math.mono),
  ("\\displaystyle", math.display),
  ("\\textstyle", math.inline),
  ("\\scriptstyle", math.script),
  ("\\scriptscriptstyle", math.sscript),
)

#let _style-of(node) = {
  let size(c) = { let m = measure(math.equation(c, alt: probe)); (m.width, m.height) }
  let target = size(node)
  for (cmd, apply) in _variants {
    if size(apply(node.child)) == target { return cmd }
  }
  auto
}

// ============================================================================
// Delimiters
// ============================================================================

#let _delims = (
  "(": "(", ")": ")", "[": "[", "]": "]", "{": "\\{", "}": "\\}", "|": "|", "‖": "\\|",
  "⟨": "\\langle", "⟩": "\\rangle", "⌊": "\\lfloor", "⌋": "\\rfloor", "⌈": "\\lceil", "⌉": "\\rceil",
)

/// The matrix environment drawn with `delim`, or none when LaTeX has none.
#let _matrix-env(delim) = {
  let open = if type(delim) == array { delim.first() } else { delim }
  if open == none { return "matrix" }
  (
    "(": "pmatrix", "[": "bmatrix", "{": "Bmatrix", "|": "vmatrix", "‖": "Vmatrix",
  ).at(str(open), default: none)
}

/// Whether `node` holds something taller than a line (fractions, matrices,
/// ...), which LaTeX delimiters need \left / \right to grow around.
#let _tall(node) = {
  if type(node) != content { return false }
  if node.func() in (math.frac, math.binom, math.mat, math.vec, math.cases) { return true }
  if node.func() == _sequence { return node.children.any(_tall) }
  for key in ("body", "child", "base", "num") {
    if node.has(key) and _tall(node.at(key)) { return true }
  }
  false
}

// ============================================================================
// Conversion
// ============================================================================

#let _accents = (
  "\u{300}": "\\grave", "\u{301}": "\\acute", "\u{302}": "\\hat", "\u{303}": "\\tilde",
  "\u{304}": "\\bar", "\u{305}": "\\bar", "\u{306}": "\\breve", "\u{307}": "\\dot",
  "\u{308}": "\\ddot", "\u{30A}": "\\mathring", "\u{30C}": "\\check", "\u{20D7}": "\\vec",
)

#let _spaces = (
  (0.17, "\\,"), (0.22, "\\:"), (0.28, "\\;"), (0.5, "\\enspace"), (1.0, "\\quad"), (2.0, "\\qquad"),
  (-0.17, "\\!"),
)

// Arrows `stretch` lengthens under a label: these as KaTeX and MathJax
// stretch them, ...
#let _xarrows = (
  "→": "\\xrightarrow", "⟶": "\\xrightarrow", "←": "\\xleftarrow", "⟵": "\\xleftarrow",
  "↦": "\\xmapsto", "⟼": "\\xmapsto",
)
// ... and these, whose stretching commands (mathtools') MathJax lacks, as an
// arrow of fixed length with the labels set over and under it.
#let _labelled-arrows = (
  "⇒": "\\Longrightarrow", "⟹": "\\Longrightarrow", "⇐": "\\Longleftarrow", "⟸": "\\Longleftarrow",
  "↔": "\\longleftrightarrow", "⟷": "\\longleftrightarrow", "⇔": "\\Longleftrightarrow",
  "⟺": "\\Longleftrightarrow", "↪": "\\hookrightarrow", "↩": "\\hookleftarrow",
)

#let _classes = (
  normal: "\\mathord", binary: "\\mathbin", relation: "\\mathrel", large: "\\mathop",
  punctuation: "\\mathpunct", opening: "\\mathopen", closing: "\\mathclose",
)

#let _conv(node) = {
  let conv = _conv
  if node == none { return "" }
  if type(node) == str { return _text(node) }
  if type(node) == array { return node.map(conv).join(", ") }
  if type(node) != content { return "" }
  let f = node.func()

  if f == _sequence {
    // LaTeX drops spaces outside \text{}: a word set off by spaces from a
    // letter or number (`x^2 "if" x`) keeps them inside. Operators space
    // themselves.
    let kids = node.children
    let spaced(i) = i >= 0 and i < kids.len() and kids.at(i).func() == _space
    let ordinary(i) = {
      if i < 0 or i >= kids.len() { return false }
      let k = kids.at(i)
      not (k.has("text") and type(k.text) == str and k.text.clusters().len() == 1
        and k.text.match(regex("^[\\p{L}\\p{N}]$")) == none)
    }
    return _join(kids.enumerate().map(((i, k)) => {
      if not _quoted(k) { return conv(k) }
      let before = if spaced(i - 1) and ordinary(i - 2) { " " } else { "" }
      let after = if spaced(i + 1) and ordinary(i + 2) { " " } else { "" }
      _in-text(before + k.text + after)
    }))
  }
  if f == _space { return " " }
  if f == math.equation { return conv(node.body) }
  if f == _align-point { return "&" }
  if f == linebreak { return " \\\\ " }

  if f == math.attach {
    // A stretched arrow with labels: \xrightarrow[below]{above}, or
    // \underset{below}{\overset{above}{\Longrightarrow}}.
    if node.base.func() == math.stretch and node.base.body.has("text") {
      let arrow = node.base.body.text.replace("\u{FE0E}", "")
      let keys = node.fields().keys().filter(k => k != "base")
      if (arrow in _xarrows or arrow in _labelled-arrows) and keys.all(k => k in ("t", "tr", "b", "br")) {
        let label(ks) = ks.filter(k => node.has(k)).map(k => conv(node.at(k))).join(default: "")
        let (above, below) = (label(("t", "tr")), label(("b", "br")))
        if arrow in _xarrows {
          return _xarrows.at(arrow) + if below != "" { "[" + below + "]" } + "{" + above + "}"
        }
        let out = _labelled-arrows.at(arrow)
        if above != "" { out = "\\overset{" + above + "}{" + out + "}" }
        if below != "" { out = "\\underset{" + below + "}{" + out + "}" }
        return out
      }
    }
    let base = conv(node.base)
    if node.base.func() == math.attach { base = "{" + base + "}" }
    let out = ""
    if node.has("tl") or node.has("bl") {
      out += "{}"
      if node.has("tl") { out += "^" + _group(conv(node.tl)) }
      if node.has("bl") { out += "_" + _group(conv(node.bl)) }
    }
    out += base
    // Primes go straight after the base: f''(x).
    let sup = ()
    for key in ("tr", "t") {
      if not node.has(key) { continue }
      let s = node.at(key)
      if s.func() == _primes { out += "'" * s.count } else { sup.push(conv(s)) }
    }
    let sub = ("br", "b").filter(k => node.has(k)).map(k => conv(node.at(k)))
    if sub.len() > 0 { out += "_" + _group(sub.join()) }
    if sup.len() > 0 { out += "^" + _group(sup.join()) }
    return out
  }
  if f == _primes { return "'" * node.count }
  if f == math.frac {
    let (num, denom) = (conv(node.num), conv(node.denom))
    let style = node.at("style", default: math.frac.style)
    if style == "horizontal" {
      // a/b; a numerator or denominator of more than one symbol in
      // parentheses, which a slash needs to keep the meaning.
      let single(s) = _bare(s).clusters().len() == 1 or _bare(s).match(regex("^\\\\[a-zA-Z]+$")) != none
      return (num, denom).map(s => if single(s) { s } else { "(" + s + ")" }).join("/")
    }
    if style == "skewed" { return "{}^{" + num + "}/_{" + denom + "}" }
    return "\\frac{" + num + "}{" + denom + "}"
  }
  if f == math.binom {
    return "\\binom{" + conv(node.upper) + "}{" + node.lower.map(conv).join(", ") + "}"
  }
  if f == math.root {
    let index = if node.has("index") and node.index != none { "[" + conv(node.index) + "]" } else { "" }
    return "\\sqrt" + index + "{" + conv(node.radicand) + "}"
  }

  if f == math.lr {
    let parts = if node.body.func() == _sequence { node.body.children } else { (node.body,) }
    let is-delim(p) = p.has("text") and type(p.text) == str and p.text in _delims
    if parts.len() >= 2 and is-delim(parts.first()) and is-delim(parts.last()) {
      let inner = _join(parts.slice(1, -1).map(conv)).trim()
      let (open, close) = (_delims.at(parts.first().text), _delims.at(parts.last().text))
      if _tall(node.body) {
        return "\\left" + open + " " + inner + " \\right" + close
      }
      return _join((open, inner, close))
    }
    return conv(node.body)
  }
  if f == math.mid { return conv(node.body) }

  // Matrix rows and cases; LaTeX's environments draw no dividing lines
  // (`augment`) and only the delimiters _matrix-env knows.
  let env(name, rows) = {
    if name == none { return rows.join(" \\\\ ") + _issue("delimiter") }
    "\\begin{" + name + "} " + rows.join(" \\\\ ") + " \\end{" + name + "}"
  }
  if f == math.mat {
    let delim = if node.has("delim") { node.delim } else { math.mat.delim }
    let rows = node.rows.map(row => row.map(c => conv(c).trim()).join(" & "))
    let out = env(_matrix-env(delim), rows)
    return if node.at("augment", default: none) != none { out + _issue("augment") } else { out }
  }
  if f == math.vec {
    let delim = if node.has("delim") { node.delim } else { math.vec.delim }
    return env(_matrix-env(delim), node.children.map(c => conv(c).trim()))
  }
  if f == math.cases {
    let delim = node.at("delim", default: math.cases.delim)
    let delim = if type(delim) == array { delim.first() } else { delim }
    let rows = node.children.map(c => conv(c).trim())
    if delim == none or str(delim) != "{" { return env(none, rows) }
    if not node.at("reverse", default: math.cases.reverse) { return env("cases", rows) }
    // The brace on the right: rcases is mathtools', which MathJax lacks.
    return "\\left.\\begin{array}{ll} " + rows.join(" \\\\ ") + " \\end{array}\\right\\}"
  }

  if f == math.accent {
    let accent = node.accent
    let accent = if type(accent) == str { accent } else { str(accent) }
    let cmd = _accents.at(accent, default: none)
    if cmd == none { return conv(node.base) + _issue("accent " + _codepoint(accent)) }
    return cmd + "{" + conv(node.base) + "}"
  }
  if f == math.overline { return "\\overline{" + conv(node.body) + "}" }
  if f == math.underline { return "\\underline{" + conv(node.body) + "}" }
  if f == math.cancel {
    let cmd = if node.at("cross", default: math.cancel.cross) { "\\xcancel" } else if node.at("inverted", default: math.cancel.inverted) { "\\bcancel" } else { "\\cancel" }
    return cmd + "{" + conv(node.body) + "}"
  }
  // Square brackets over and under (mathtools' \overbracket) are in neither
  // KaTeX nor MathJax, and stay issues.
  for (fn, cmd, script) in (
    (math.overbrace, "\\overbrace", "^"), (math.underbrace, "\\underbrace", "_"),
  ) {
    if f == fn {
      let note = if node.has("annotation") and node.annotation != none { script + "{" + conv(node.annotation) + "}" } else { "" }
      return cmd + "{" + conv(node.body) + "}" + note
    }
  }

  if f == math.op {
    let name = if node.text.has("text") { node.text.text } else { conv(node.text) }
    if name == "mod" { return "\\bmod" }
    if name in operators { return "\\" + name }
    return if node.at("limits", default: false) { "\\operatorname*{" } else { "\\operatorname{" } + name + "}"
  }
  if f == math.class {
    let cmd = _classes.at(node.class, default: none)
    return if cmd == none { conv(node.body) } else { cmd + "{" + conv(node.body) + "}" }
  }
  // Scripts above and below / beside, which LaTeX sets on operators.
  if f == math.limits { return "\\mathop{" + conv(node.body) + "}\\limits" }
  if f == math.scripts { return "\\mathop{" + conv(node.body) + "}\\nolimits" }
  if f == h {
    let amount = node.amount
    if type(amount) != length { return " " }
    let (em, pt) = (calc.round(amount.em, digits: 2), calc.round(amount.abs.pt(), digits: 2))
    if pt == 0 {
      for (size, cmd) in _spaces { if em == size { return cmd } }
      return "\\hspace{" + str(em) + "em}"
    }
    return if em == 0 { "\\hspace{" + str(pt) + "pt}" } else { " " }
  }

  if f == _styled {
    let cmd = _style-of(node)
    let child = conv(node.child)
    if cmd == auto { return child + _issue("font style") }
    if cmd == none { return child }
    // \displaystyle and friends are switches, not commands with an argument.
    return if cmd.ends-with("style") { "{" + cmd + " " + child + "}" } else { cmd + "{" + child + "}" }
  }

  if _quoted(node) { return _in-text(node.text) }
  if node.has("text") and type(node.text) == str { return _text(node.text) }
  // An element without a rule: keep what it holds, and say so.
  let name = repr(f)
  for key in ("body", "child") {
    if node.has(key) { return conv(node.at(key)) + _issue(name) }
  }
  if node.has("children") { return _join(node.children.map(conv)) + _issue(name) }
  _issue(name)
}

/// LaTeX for the body of a math.equation, as `(latex: str, issues: array)`:
/// `issues` names the parts LaTeX has no counterpart for, each once; when
/// there are any, `latex` is `placeholder`. Needs `context`: font styles are
/// told apart by measuring.
#let to-latex(body) = {
  let out = _conv(body)
  // Rows and alignment points need an environment in LaTeX.
  let kids = if body.func() == _sequence { body.children } else { (body,) }
  if kids.any(k => k.func() == _align-point) {
    out = "\\begin{aligned} " + out + " \\end{aligned}"
  } else if kids.any(k => k.func() == linebreak) {
    out = "\\begin{gathered} " + out + " \\end{gathered}"
  }
  let issues = out.matches(_issue-pattern).map(m => m.captures.first()).dedup()
  (
    latex: if issues.len() > 0 { placeholder } else { _bare(out).replace(regex(" {2,}"), " ").trim() },
    issues: issues,
  )
}

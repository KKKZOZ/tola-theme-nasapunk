#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout
#import "/utils/mitex.typ": mi, mitex
#import "/templates/latex.typ": to-latex

#tola-meta((
  title: "[Tour 06] Math and Copying as LaTeX",
  date: "2026-10-29",
  summary: "Typst math and LaTeX through MiTeX, how formulas copy as LaTeX, and the ones that cannot.",
  tags: ("example", "series", "math"),
  series: "Theme Tour",
))

// Each row starts from Typst source: the table shows it, renders it, and
// asks templates/latex.typ what it copies as, so the post cannot drift from
// the converter.
#let example(src) = {
  let out = eval(src, mode: "markup", scope: (mi: mi))
  let eq = if out.func() == math.equation { out } else { out.children.find(c => c.func() == math.equation) }
  (src: raw(src, lang: "typst"), shown: out, body: eq.body)
}

Formulas render as SVG at 1.15 times the size of the text around them, in
New Computer Modern Math. A comma or full stop after an inline formula stays
on its line. Select text around a formula and copy, and the formula comes out
as LaTeX: `$...$` inline, `$$...$$` display. Double-click a formula to select
just that one.

= Try it

Select this paragraph and the formula under it, copy, and paste somewhere.
This sum converts: $sum_(i=1)^n x_i^2$. So do this fraction, $(a + b)/2$,
and this labelled arrow, $a stretch(->)^"f" b$. This one is not convertible:
$bold(cal(A))$, and neither is this boxed one:
$x + #box(stroke: .5pt, inset: 2pt)[$y$]$. Written with `mi` instead, the
first converts after all, exactly as typed: #mi(`\boldsymbol{\mathcal{A}}`).
The display formula converts too, its two rows in an `aligned` block:

$ (a + b)^2 &= a^2 + 2 a b + b^2 \
  &>= 4 a b $

The convertible formulas paste as LaTeX; the two that are not paste as
`\text{[unsupported formula]}`, and a tip at the foot of the window names
what stopped them: font style and box.

= Writing math

Write Typst's own math between dollar signs, or LaTeX with `mi` (inline) and
`mitex` (display) from `utils/mitex.typ`. Both render the same:
$e^(i pi) + 1 = 0$ and #mi(`e^{i\pi} + 1 = 0`).

```typst
#import "/utils/mitex.typ": mi, mitex

Typst $e^(i pi) + 1 = 0$ and LaTeX #mi(`e^{i\pi} + 1 = 0`).
#mitex(`\int_0^\infty e^{-x^2} \, dx = \frac{\sqrt{\pi}}{2}`)
```

#mitex(`\int_0^\infty e^{-x^2} \, dx = \frac{\sqrt{\pi}}{2}`)

= Copying as LaTeX

A formula written with `mi` or `mitex` copies as the LaTeX you wrote,
exactly. Typst's own math has lost its source text by the time the page is
built, so the theme rebuilds LaTeX from the parsed formula: the same maths,
with its own spacing and braces.

#table(
  columns: 3,
  table.header[Typst][Renders][Copies as],
  ..(
    "$sum_(i=1)^n x_i^2$",
    "$f(x) = cases(x^2 \"if\" x > 0, 0 \"otherwise\")$",
    "$(a + b)/2 + sqrt(x) + root(3, y)$",
    "$bold(v) + bb(R)^n + cal(L)$",
    "$lim_(x -> 0) (sin x)/x = 1$",
    "$mat(1, 2; 3, 4) vec(x, y)$",
    "$integral_0^1 f(x) dif x$",
    "$a stretch(->)^\"f\" b$",
    "$hat(x) + overline(z) + abs(x) + norm(v)$",
  ).map(example).map(e => (e.src, e.shown, context raw(to-latex(e.body).latex))).flatten(),
)

The converter covers scripts and primes, fractions, roots, binomials,
brackets (with `\left` / `\right` around tall content), matrices and
vectors, `cases`, rows and alignment (in `aligned` / `gathered`), accents,
over- and underbraces, labelled arrows (`\xrightarrow`), operators such as
`\sin` and `\lim`, font styles (`\mathbf`, `\mathbb`, `\mathcal`, ...),
spacing, and about 430 symbols taken from MiTeX's command table. Quoted text
copies as `\text{...}`, escaped for LaTeX.

#callout(kind: "info", title: [EXACT TEXT])[If the copy has to match what
you typed, write the formula with `mi` or `mitex`. A copied `mitex` formula is
its source verbatim.]

= What cannot be converted

Some formulas have parts LaTeX has no counterpart for. Rather than copy LaTeX
that is wrong or will not compile, the whole formula copies as
`\text{[unsupported formula]}`, and a tip at the foot of the window names the
parts.

#table(
  columns: 3,
  table.header[Typst][Renders][Stopped by],
  ..(
    "$bold(cal(A))$",
    "$mat(1, 2; 3, 4; augment: #1)$",
    "$x + #box(stroke: .5pt, inset: 2pt)[$y$]$",
    "$a ⧺ b$",
  ).map(example).map(e => (e.src, e.shown, context raw(to-latex(e.body).issues.join(", ")))).flatten(),
)

- *Font style*: two styles stacked, such as bold calligraphic, match none of
  the single LaTeX styles the converter tells apart.
- *augment*: a matrix's dividing line, which LaTeX's matrix environments do
  not draw.
- *box*: an element with no LaTeX counterpart the converter knows.
- *⧺*: a symbol missing from the table; LaTeX has no standard command for it.

While `tola dev` runs, the terminal lists every such formula after each
rebuild, pointing at its line in the source like a compiler warning, so it
can be rewritten before anyone copies it. The examples on this page are
listed there too.

When a formula has to copy cleanly, write it in LaTeX with `mi`:
#mi(`\boldsymbol{\mathcal{A}}`) and #mi(`x + \boxed{y}`) render the same as
the first and third rows and copy as written.

= Design choices

A copied formula usually lands in Markdown, notes or a chat, where KaTeX or
MathJax draws it (GitHub, Obsidian and Typora use MathJax). Where LaTeX has
more than one spelling, the theme writes the one both read as they come, with
no extra packages or settings; pasting into a full LaTeX document comes
second.

#table(
  columns: 2,
  table.header[Choice][Trade-off],
  [Equivalent LaTeX, rebuilt from the formula],
  [The same maths, not the text you typed. Write `mi` / `mitex` to copy your
    own text.],
  [A whole formula or a placeholder],
  [A formula with one part LaTeX lacks copies as
    `\text{[unsupported formula]}`, never as LaTeX that is wrong.],
  [Symbols one of the two lacks, as the character itself],
  [`≔`, `⟦` and `∯` paste as Unicode, which both draw; pdfLaTeX rejects
    them.],
  [Special characters in quoted text, outside `\text{}`],
  [`"snake_case"` copies as `\text{snake}\_\text{case}`, since MathJax shows
    escapes inside `\text{}` as typed. `~` and `^` become `\sim` and `\hat{}`,
    which look close.],
  [Labelled `⇒`, `⇔` and `↪` with `\overset` / `\underset`],
  [MathJax lacks their stretching commands, so the arrow keeps its length
    under a long label. `→`, `←` and `↦` stretch (`\xrightarrow`).],
  [Spacing as the nearest command],
  [`space.thin` and its kind become `\,`, `\:`, `\;` or `\quad`; the rest
    `\hspace` or `\phantom`.],
)

Colour and the numbers of numbered equations are not copied. In a full LaTeX
document, some commands need `amsmath`, `amssymb`, `mathtools`, `cancel` or
`mathrsfs`.

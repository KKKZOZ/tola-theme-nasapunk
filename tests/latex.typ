// Cases for templates/latex.typ, the LaTeX a copied formula carries. Run
// with `npm test` (scripts/test-latex.mjs), which needs the Typst CLI.
//
// Each case is a formula, as Typst source or as LaTeX given to MiTeX's own
// `mi` (what a post gets when it imports @preview/mitex instead of
// utils/mitex.typ), and either the LaTeX it should copy as or, for one that
// cannot copy, `(issues: (...))`: the parts that stop it.

#import "/templates/latex.typ": placeholder, to-latex
#import "@preview/mitex:0.2.7" as mitex

#let typst-cases = (
  "characters": (
    (`$x$`, `x`),
    (`$alpha + beta$`, `\alpha + \beta`),
    (`$alpha x$`, `\alpha x`),
    (`$alpha beta$`, `\alpha \beta`),
    (`$x <= y != z$`, `x \leq y \neq z`),
    (`$x in RR$`, `x \in \mathbb{R}`),
    (`$NN subset ZZ$`, `\mathbb{N} \subset \mathbb{Z}`),
    (`$3.14$`, `3.14`),
    (`$x - y$`, `x - y`),
    (`$f'(x)$`, `f'(x)`),
    (`$a dot b times c$`, `a \cdot b \times c`),
    (`$dots.h$`, `\ldots`),
    (`$\# \$ \_$`, `\# \$ \_`),
    (`$é$`, `\text{é}`),
    (`$x#"\u{2062}"y$`, (issues: ("U+2062",))),
  ),
  "text": (
    (`$a "if" b$`, `a \text{ if } b`),
    (`$"if" x$`, `\text{if } x`),
    (`$x "else"$`, `x \text{ else}`),
    (`$x + "if"$`, `x + \text{if}`),
    (`$"50%"$`, `50\%`),
    (`$"a_b"$`, `\text{a}\_\text{b}`),
    (`$"{x}"$`, `\text{\{x\}}`),
    (`$"a^b"$`, `\text{a}\hat{}\text{b}`),
    (`$"a~b"$`, `\text{a}\sim\text{b}`),
    (`$"$5"$`, `\$5`),
  ),
  "scripts": (
    (`$x^2$`, `x^2`),
    (`$x_i^2$`, `x_i^2`),
    (`$x^(n+1)$`, `x^{n+1}`),
    (`$x_(i j)$`, `x_{i j}`),
    (`$e^(i pi)$`, `e^{i \pi}`),
    (`$x^alpha$`, `x^{\alpha}`),
    (`$f''(x)$`, `f''(x)`),
    (`$f'^2$`, `f'^2`),
    (`$attach(x^2, t: 3)$`, `{x^2}^3`),
    (`$attach(X, tl: a, bl: b)$`, `{}^a_bX`),
    (`$sum_(i=1)^n x_i$`, `\sum_{i=1}^n x_i`),
    (`$limits(A)_x$`, `\mathop{A}\limits_x`),
    (`$scripts(sum)_x$`, `\mathop{\sum}\nolimits_x`),
  ),
  "fractions and roots": (
    (`$a/b$`, `\frac{a}{b}`),
    (`$(a + b)/2$`, `\frac{a + b}{2}`),
    (`$frac(a, b, style: "horizontal")$`, `a/b`),
    (`$frac(a + b, c, style: "horizontal")$`, `(a + b)/c`),
    (`$frac(alpha, 2, style: "horizontal")$`, `\alpha/2`),
    (`$frac(a, b, style: "skewed")$`, `{}^{a}/_{b}`),
    (`$binom(n, k)$`, `\binom{n}{k}`),
    (`$binom(n, k_1, k_2)$`, `\binom{n}{k_1, k_2}`),
    (`$sqrt(x)$`, `\sqrt{x}`),
    (`$root(3, x)$`, `\sqrt[3]{x}`),
    (`$root(n + 1, x)$`, `\sqrt[n + 1]{x}`),
  ),
  "delimiters": (
    (`$(x)$`, `(x)`),
    (`$[x]$`, `[x]`),
    (`${x}$`, `\{x\}`),
    (`$f(x, y)$`, `f(x, y)`),
    (`$( x )$`, `(x)`),
    (`$[a, b)$`, `[a, b)`),
    (`$abs(x)$`, `|x|`),
    (`$norm(v)$`, `\|v\|`),
    (`$floor(x) + ceil(y)$`, `\lfloor x\rfloor + \lceil y\rceil`),
    (`$chevron.l x chevron.r$`, `\langle x\rangle`),
    (`$(1/2)$`, `\left( \frac{1}{2} \right)`),
    (`$[mat(1; 2)]$`, `\left[ \begin{pmatrix} 1 \\ 2 \end{pmatrix} \right]`),
    (`$abs(x/2)$`, `\left| \frac{x}{2} \right|`),
  ),
  "matrices and cases": (
    (`$mat(1, 2; 3, 4)$`, `\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}`),
    (`$mat(delim: "[", 1, 2)$`, `\begin{bmatrix} 1 & 2 \end{bmatrix}`),
    (`$mat(delim: "{", 1)$`, `\begin{Bmatrix} 1 \end{Bmatrix}`),
    (`$mat(delim: "|", 1)$`, `\begin{vmatrix} 1 \end{vmatrix}`),
    (`$mat(delim: "‖", 1)$`, `\begin{Vmatrix} 1 \end{Vmatrix}`),
    (`$mat(delim: #none, 1)$`, `\begin{matrix} 1 \end{matrix}`),
    (`$mat(delim: "⟨", 1)$`, (issues: ("delimiter",))),
    (`$mat(1, 2; 3, 4, augment: #1)$`, (issues: ("augment",))),
    (`$vec(x, y)$`, `\begin{pmatrix} x \\ y \end{pmatrix}`),
    (`$vec(delim: "[", x, y)$`, `\begin{bmatrix} x \\ y \end{bmatrix}`),
    (`$cases(1 "if" x > 0, 0 "otherwise")$`, `\begin{cases} 1 \text{ if } x > 0 \\ 0 \text{ otherwise} \end{cases}`),
    (`$cases(0 & "otherwise")$`, `\begin{cases} 0 & \text{otherwise} \end{cases}`),
    (`$cases(x "if" y & "else")$`, `\begin{cases} x \text{ if } y & \text{else} \end{cases}`),
    (`$cases(reverse: #true, a, b)$`, `\left.\begin{array}{ll} a \\ b \end{array}\right\}`),
    (`$cases(delim: "[", a, b)$`, (issues: ("delimiter",))),
  ),
  "rows and alignment": (
    (`$ a &= b \ &= c $`, `\begin{aligned} a &= b \\ &= c \end{aligned}`),
    (`$ a &= "if" b \ "else" & c $`, `\begin{aligned} a &= \text{if } b \\ \text{else} & c \end{aligned}`),
    (`$ a \ b $`, `\begin{gathered} a \\ b \end{gathered}`),
  ),
  "accents and lines": (
    (`$hat(x)$`, `\hat{x}`),
    (`$tilde(x) + dot(x) + dot.double(x)$`, `\tilde{x} + \dot{x} + \ddot{x}`),
    (`$arrow(v)$`, `\vec{v}`),
    (`$macron(x)$`, `\bar{x}`),
    (`$accent(x, "\u{20D6}")$`, (issues: ("accent U+20D6",))),
    (`$overline(z)$`, `\overline{z}`),
    (`$underline(z)$`, `\underline{z}`),
    (`$overbrace(a + b, n)$`, `\overbrace{a + b}^{n}`),
    (`$underbrace(a + b)$`, `\underbrace{a + b}`),
    (`$overbracket(x)$`, (issues: ("overbracket",))),
    (`$cancel(x)$`, `\cancel{x}`),
    (`$cancel(x, cross: #true)$`, `\xcancel{x}`),
    (`$cancel(x, inverted: #true)$`, `\bcancel{x}`),
  ),
  "operators": (
    (`$sin x$`, `\sin x`),
    (`$lim_(x -> 0) f$`, `\lim_{x \to 0} f`),
    (`$a mod b$`, `a \bmod b`),
    (`$op("rank") A$`, `\operatorname{rank} A`),
    (`$op("rank")(A)$`, `\operatorname{rank}(A)`),
    (`$op("argmax", limits: #true)_x$`, `\operatorname*{argmax}_x`),
    (`$op(upright(r a n k))$`, `\operatorname{rank}`),
    (`$op(s i n) x$`, `\sin x`),
    (`$op(a r g thin m a x)$`, `\operatorname{arg\,max}`),
    (`$op(a r g quad m a x)$`, `\operatorname{arg\quad max}`),
    (`$op(cal(L))$`, `\operatorname{\mathcal{L}}`),
    (`$class("relation", x)$`, `\mathrel{x}`),
    (`$class("binary", x)$`, `\mathbin{x}`),
  ),
  "font styles": (
    (`$bold(v)$`, `\boldsymbol{v}`),
    (`$upright(x)$`, `\mathrm{x}`),
    (`$bb(R)$`, `\mathbb{R}`),
    (`$cal(L)$`, `\mathcal{L}`),
    (`$scr(L)$`, `\mathscr{L}`),
    (`$frak(g)$`, `\mathfrak{g}`),
    (`$sans(x)$`, `\mathsf{x}`),
    (`$mono(x)$`, `\mathtt{x}`),
    (`$display(sum)$`, `{\displaystyle \sum}`),
    (`$#text(fill: red, $x$)$`, `x`),
    (`$bold(cal(A))$`, (issues: ("font style",))),
  ),
  "arrows": (
    (`$a stretch(->)^"f" b$`, `a \xrightarrow{\text{f}} b`),
    (`$stretch(->)_x$`, `\xrightarrow[x]{}`),
    (`$stretch(<-)^a_b$`, `\xleftarrow[b]{a}`),
    (`$stretch(|->)^x$`, `\xmapsto{x}`),
    (`$stretch(=>)^x_y$`, `\underset{y}{\overset{x}{\Longrightarrow}}`),
    (`$stretch(<=>)^x$`, `\overset{x}{\Longleftrightarrow}`),
    (`$x -> y$`, `x \to y`),
  ),
  "spacing": (
    (`$a thin b$`, `a \, b`),
    (`$a quad b$`, `a \quad b`),
    (`$a #h(1em) b$`, `a \quad b`),
    (`$a #h(2em) b$`, `a \qquad b`),
    (`$a #h(-0.17em) b$`, `a \! b`),
    (`$a #h(0.3em) b$`, `a \hspace{0.3em} b`),
    (`$a #h(5pt) b$`, `a \hspace{5pt} b`),
    (`$a #h(1fr) b$`, `a b`),
  ),
  "unsupported": (
    (`$x + #box(stroke: .5pt)[$y$]$`, (issues: ("box",))),
    (`$#rect[x]$`, (issues: ("rect",))),
    (`$x + #box[$y$] + bold(cal(A))$`, (issues: ("box", "font style"))),
  ),
)

#let mitex-cases = (
  "mitex": (
    (`x`, `x`),
    (`e^{i\pi} + 1 = 0`, `e^{i \pi} + 1 = 0`),
    (`\frac{a+b}{2}`, `\frac{a + b}{2}`),
    (`\int_0^\infty e^{-x^2} \, dx = \frac{\sqrt{\pi}}{2}`, `\int_0^{\infty} e^{- x^2} \, d x = \frac{\sqrt{\pi}}{2}`),
    (`\sum_{i=1}^n x_i^2`, `\sum_{i = 1}^n x_i^2`),
    (`\alpha\beta + \gamma`, `\alpha \beta + \gamma`),
    (`\mathbb{R}^n`, `\mathbb{R}^n`),
    (`\sqrt[3]{y}`, `\sqrt[3]{y}`),
    (`(A)`, `(A)`),
    (`\{ x \}`, `\{x\}`),
    (`[a, b)`, `[a, b)`),
    (`\langle x \rangle`, `\langle x\rangle`),
    (`f(x, y)`, `f (x, y)`),
    (`\left( \frac{1}{x} \right)`, `\left( \frac{1}{x} \right)`),
    (`\left[ \frac{1}{2} \right]`, `\left[ \frac{1}{2} \right]`),
    (`\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}`, `\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}`),
    (`\operatorname{rank}(A)`, `\operatorname{rank}(A)`),
    (`\operatorname{sin} x`, `\sin x`),
    (`\operatorname*{arg\,max}_x f`, `\operatorname*{arg\,max}_x f`),
    (`\sin x + \log y`, `\sin x + \log y`),
    (`\hat{x} + \overline{z}`, `\hat{x} + \overline{z}`),
    (`\mathbf{v} + \mathcal{L}`, `\mathbf{v} + \mathcal{L}`),
    (`x \text{ if } y`, `x \text{ if } y`),
    (`\left\{ x \right\}`, `\{x\}`),
    (`\lim_{x \to 0} f(x)`, `\lim_{x \to 0} f (x)`),
    (`x \in \mathbb{R}`, `x \in \mathbb{R}`),
    (`\binom{n}{k}`, `\binom{n}{k}`),
    (`\vec{v} \cdot \hat{u}`, `\vec{v} \cdot \hat{u}`),
    (`a_1, \dots, a_n`, `a_1, \ldots, a_n`),
    (`\mathrm{d}x`, `\mathrm{d}x`),
    (`\begin{cases} 1 & x > 0 \\ 0 & \text{otherwise} \end{cases}`, `\begin{cases} 1 & x > 0 \\ 0 & \text{otherwise} \end{cases}`),
    (`\boldsymbol{\mathcal{A}}`, (issues: ("font style",))),
    (`x + \boxed{y}`, (issues: ("box",))),
  ),
)

#let check(section, src, eq, want) = {
  let got = to-latex(eq.body)
  let want = if type(want) == content { (latex: want.text, issues: ()) } else { (latex: placeholder, ..want) }
  let ok = got.latex == want.latex and got.issues == want.issues
  [#metadata((section: section, src: src, ok: ok, want: want, got: got)) <case>]
}

#context for (section, cases) in typst-cases {
  for (src, want) in cases {
    let out = eval(src.text, mode: "markup")
    let eq = if out.func() == math.equation { out } else { out.children.find(c => c.func() == math.equation) }
    check(section, src.text, eq, want)
  }
}

#context for (section, cases) in mitex-cases {
  for (src, want) in cases {
    check(section, "mi(`" + src.text + "`)", mitex.mi(src), want)
  }
}

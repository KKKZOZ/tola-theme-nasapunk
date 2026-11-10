// Drop-in replacement for `@preview/mitex` that keeps the LaTeX source on
// the page.
//
// Formulas render as SVG like any other equation (base.typ `math-svg`), and
// a copied selection carries them as LaTeX (assets/scripts/copy.js). For
// Typst's own math that LaTeX is rebuilt from the parsed formula
// (templates/latex.typ); in HTML export each formula here is wrapped in an
// element carrying its source as `data-latex`, so it copies exactly as
// written. Everything else (`mitext`, `mitex-convert`, ...) is re-exported
// as-is.
//
// Usage:
// ```typst
// #import "/utils/mitex.typ": mi, mitex
//
// The formula is #mi(`a + b`).
// #mitex(`\sum_{i=1}^n x_i`)
// ```

#import "@preview/mitex:0.2.7": *
#import "@preview/mitex:0.2.7" as _mitex

#let _source(it) = if type(it) == str { it } else { it.text }

/// Same signature as mitex's `mimath`. Unless `alt` says otherwise, screen
/// readers read the source.
#let mimath(it, block: true, ..args) = context {
  let eq = _mitex.mimath(it, block: block, alt: _source(it), ..args)
  if target() != "html" { return eq }
  html.elem(if block { "div" } else { "span" }, attrs: (data-latex: _source(it)), eq)
}

#let mi = mimath.with(block: false)

#let mitex(it, mode: "math", ..args) = {
  if mode == "math" { mimath(it, ..args) } else { _mitex.mitext(it, ..args) }
}

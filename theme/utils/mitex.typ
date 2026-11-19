// Drop-in replacement for `@preview/mitex` that keeps the LaTeX source on
// the page.
//
// Formulas render as SVG like any other equation (base.typ `math-svg`), and
// a copied selection carries them as LaTeX (assets/scripts/copy.js). For
// Typst's own math that LaTeX is rebuilt from the parsed formula
// (templates/latex.typ); each formula here is an equation labelled
// <nasapunk-mitex> with its source as `alt`, which `math-svg` puts in
// `data-latex`, so it copies exactly as written. Being a plain equation (no
// `context`), it also reads as text in a heading or caption. Everything else
// (`mitext`, `mitex-convert`, ...) is re-exported as-is.
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

/// Same signature as mitex's `mimath`. Screen readers read the source. A
/// formula given its own `alt` is left unlabelled, so it copies as LaTeX
/// rebuilt from the formula, like Typst's own math.
#let mimath(it, block: true, ..args) = {
  if "alt" in args.named() { return _mitex.mimath(it, block: block, ..args) }
  // No space before the label: it would stay in the content as a space.
  [#_mitex.mimath(it, block: block, alt: _source(it), ..args)<nasapunk-mitex>]
}

#let mi = mimath.with(block: false)

#let mitex(it, mode: "math", ..args) = {
  if mode == "math" { mimath(it, ..args) } else { _mitex.mitext(it, ..args) }
}

// Drop-in replacement for `@preview/cetz` that survives HTML export.
//
// Typst's HTML export silently drops layout-only content such as canvases,
// so `canvas` here renders through `html.frame()` (inline SVG) when the
// target is HTML, and falls back to the regular canvas in paged export.
// Everything else (`draw`, `vector`, `palette`, ...) is re-exported as-is.
//
// Usage:
// ```typst
// #import "/utils/cetz.typ" as cetz
//
// #cetz.canvas(length: 1pt, {
//   import cetz.draw: *
//   circle((0, 0), radius: 10)
// })
// ```

#import "@preview/cetz:0.5.2": *
#import "@preview/cetz:0.5.2" as _cetz

/// Render `body` as a block-level inline SVG in HTML export.
/// Works for any layout-only content (cetz, fletcher, lilaq, ...).
///
/// - `align`: horizontal placement, one of `left`, `center`, `right`.
/// - `class`: CSS class on the wrapping `<div>` for further styling.
#let svg-frame(body, align: center, class: "svg-frame") = context {
  if target() == "html" {
    let text-align = if align == left { "left" } else if align == right { "right" } else { "center" }
    html.div(
      class: class,
      style: "text-align: " + text-align + "; overflow-x: auto; margin: 1em 0;",
      html.frame(body),
    )
  } else {
    std.align(align, body)
  }
}

/// Same signature as `cetz.canvas`, plus `align` and `class` from `svg-frame`.
#let canvas(..args, align: center, class: "cetz") = {
  svg-frame(_cetz.canvas(..args), align: align, class: class)
}

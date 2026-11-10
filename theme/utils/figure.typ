// Style kit for detailed cetz figures: colours, text, arrows, pills, grids,
// bars and legends that match the theme.
// Import: #import "/utils/figure.typ": c, txt, tag, arrow, curve-arrow, pill, cells, seg, legend, box-swatch, line-swatch
//
// Coordinates are in points (`cetz.canvas(length: 1pt, ...)`, y grows
// upward). Keep a figure under ~560pt wide so it renders at true scale in the
// text column.
//
// Every colour in `c` has a night value (templates/colors.typ), as a fill
// (text included) and as a stroke, so a figure drawn with them follows the
// day / night switch. A colour outside colors.typ keeps its value in both
// themes.
// A walkthrough with examples: content/posts/theme-tour/03-cetz-figures.typ.

#import "/utils/cetz.typ" as cetz
#import "/templates/base.typ": palette

// ============================================================================
// Colours
// ============================================================================

#let c = (
  ink: palette.ink, muted: palette.muted, blue: palette.blue, orange: palette.orange,
  teal: palette.hint-emphasis, danger: palette.danger,
  line: palette.line, hair: palette.hairline, panel: palette.pre-bg,
  blue1: palette.blue1, blue2: palette.blue2,
  orange1: palette.orange1, orange2: palette.orange2,
  teal1: palette.teal1, teal2: palette.teal2,
  grey1: palette.grey1, grey2: palette.grey2,
)

// ============================================================================
// Text
// ============================================================================

#let txt(body, size: 8pt, fill: c.muted, weight: 400, style: "normal") = text(
  size: size, fill: fill, weight: weight, style: style, body,
)

/// Small uppercase label, e.g. a panel title.
#let tag(body, fill: c.orange) = text(size: 7.5pt, weight: 600, tracking: .8pt, fill: fill, upper(body))

// ============================================================================
// Shapes
// ============================================================================

/// A line with an arrow head (unless `head: false`).
#let arrow(..pts, color: c.line, w: .7pt, dash: none, head: true) = cetz.draw.line(
  ..pts,
  stroke: (paint: color, thickness: w, dash: dash),
  mark: if head { (end: "stealth", fill: color, scale: .5) } else { none },
)

/// A curved arrow from `a` to `b` with control points `c1`, `c2`.
#let curve-arrow(a, b, c1, c2, color: c.line, w: .7pt, dash: none) = cetz.draw.bezier(
  a, b, c1, c2,
  stroke: (paint: color, thickness: w, dash: dash),
  mark: (end: "stealth", fill: color, scale: .5),
)

#let pill-tones = (
  blue: (fill: palette.paper, stroke: .7pt + c.blue, text: c.ink),
  orange: (fill: c.orange1, stroke: .7pt + c.orange, text: c.ink),
  teal: (fill: c.teal1, stroke: .7pt + c.teal, text: c.ink),
  dark: (fill: c.ink, stroke: .7pt + c.ink, text: palette.paper),
  pale: (fill: c.blue1, stroke: .7pt + c.blue, text: c.ink),
  muted: (fill: palette.paper, stroke: (paint: c.grey2, thickness: .7pt, dash: "dashed"), text: c.muted),
)

/// A rounded op / step label; anchors come from its bounding box.
#let pill(pos, body, name: none, tone: "blue", anchor: "center", size: 8pt) = {
  let t = pill-tones.at(tone)
  cetz.draw.content(pos, name: name, anchor: anchor, box(
    fill: t.fill, stroke: t.stroke, radius: 7pt, inset: (x: 6pt, y: 3.5pt),
    text(size: size, weight: 600, fill: t.text, body),
  ))
}

/// A rows x cols grid of cells; `o` is the top-left corner, rows grow downward.
#let cells(o, rows, cols, w, h, paint: (r, k) => c.grey1) = {
  import cetz.draw: *
  let (x, y) = o
  for r in range(rows) {
    for k in range(cols) {
      rect((x + k * w, y - r * h), (x + (k + 1) * w, y - (r + 1) * h), fill: paint(r, k), stroke: .5pt + palette.paper)
    }
  }
}

// Bar segments: tone -> (fill, text color).
#let seg-tones = (
  blue1: (c.blue1, c.ink), blue2: (c.blue2, c.ink), blue: (c.blue, palette.paper),
  orange: (c.orange, palette.paper), orange1: (c.orange1, c.ink),
  teal1: (c.teal1, c.ink), teal2: (c.teal2, c.ink), grey: (c.grey1, c.muted), ink: (c.ink, palette.paper),
)

/// A bar from x0 to x1 whose top edge is at y.
#let seg(x0, x1, y, tone, body: none, h: 16) = {
  import cetz.draw: *
  let (fill, ink) = seg-tones.at(tone)
  rect((x0, y), (x1, y - h), fill: fill, stroke: .5pt + palette.paper)
  if body != none { content(((x0 + x1) / 2, y - h / 2), txt(body, size: 7pt, fill: ink, weight: 600)) }
}

// ============================================================================
// Legend
// ============================================================================

/// A legend entry: swatch drawn by `swatch` at (x, y), label to its right.
#let legend(x, y, body, swatch) = {
  import cetz.draw: *
  swatch
  content((x + 16, y), txt(body), anchor: "west")
}
#let box-swatch(x, y, fill, stroke: none) = cetz.draw.rect((x, y + 4), (x + 11, y - 4), fill: fill, stroke: stroke)
#let line-swatch(x, y, color, dash: none, w: 1pt) = arrow((x, y), (x + 12, y), color: color, dash: dash, w: w)

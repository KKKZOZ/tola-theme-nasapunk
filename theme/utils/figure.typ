// Style kit for detailed cetz figures: colours, text, arrows, pills, grids,
// bars, legends and chart parts that match the theme.
// Import: #import "/utils/figure.typ": c, txt, tag, num, arrow, curve-arrow, brace, pill, card, cells, seg, lanes, legend, box-swatch, line-swatch, coord, grid-stroke, axis-stroke, y-grid, x-ticks, x-grid, frame, series, hbars
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
#let tag(body, fill: c.orange, size: 7.5pt, weight: 600, tracking: .8pt) = text(
  size: size, weight: weight, tracking: tracking, fill: fill, upper(body),
)

/// A number as a string, rounded to `digits` decimals; `fixed: true` pads
/// it to exactly `digits` decimals (2 -> "2.0"). Negative numbers get a real
/// minus sign, as `str` gives them.
#let num(v, digits: 1, fixed: false) = {
  let s = str(calc.round(v, digits: digits))
  if fixed and digits > 0 {
    let parts = s.split(".")
    let frac = if parts.len() > 1 { parts.at(1) } else { "" }
    s = parts.at(0) + "." + frac + "0" * (digits - frac.len())
  }
  s
}

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

/// A bracket under x0..x1 whose ends rise to height y; `body` is placed
/// below it, `tip: true` adds a short stem at its middle instead.
#let brace(x0, x1, y, body: none, color: c.line, inset: 0, tip: false) = {
  import cetz.draw: *
  let (a, b, m) = (x0 + inset, x1 - inset, (x0 + x1) / 2)
  line((a, y), (a, y - 4), (b, y - 4), (b, y), stroke: .7pt + color)
  if tip { line((m, y - 4), (m, y - 9), stroke: .7pt + color) }
  if body != none { content((m, y - 7), body, anchor: "north") }
}

/// A rectangle from `a` to `b` with a few centred lines of content, `pitch`
/// points apart.
#let card(a, b, lines, fill: c.blue1, stroke: c.blue, radius: 3, pitch: 11) = {
  // No `import cetz.draw: *`: it would shadow `fill` and `stroke`.
  cetz.draw.rect(a, b, fill: fill, stroke: .7pt + stroke, radius: radius)
  let (cx, cy) = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
  for (i, l) in lines.enumerate() {
    cetz.draw.content((cx, cy + (lines.len() - 1) * pitch / 2 - i * pitch), l)
  }
}

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

// A value or, when it is a function, its value at (row, col).
#let _at(v, r, k) = if type(v) == function { v(r, k) } else { v }

/// A rows x cols grid of cells; `o` is the top-left corner, rows grow
/// downward, and `gap` is the width of the page-coloured lines between
/// cells. `paint`, `ink` and `weight` are a value or a function of
/// (row, col). `labels` is an array of rows or a function of (row, col); a
/// `none` label leaves its cell blank, a number is written with `str`.
/// `row-labels` go right-aligned `index-gap` left of the grid and
/// `col-labels` centred one cell height above it, both in muted `txt`.
#let cells(
  o, rows, cols, w, h, paint: (r, k) => c.grey1, gap: .5pt,
  labels: none, ink: c.ink, size: 7.5pt, weight: 400,
  row-labels: none, col-labels: none, index-gap: 5,
) = {
  let (rect, content) = (cetz.draw.rect, cetz.draw.content)
  let (x, y) = o
  for r in range(rows) {
    for k in range(cols) {
      rect((x + k * w, y - r * h), (x + (k + 1) * w, y - (r + 1) * h), fill: _at(paint, r, k), stroke: gap + palette.paper)
      let l = if labels == none { none } else if type(labels) == function { labels(r, k) } else { labels.at(r).at(k) }
      if l != none {
        let l = if type(l) in (int, float) { str(l) } else { l }
        content((x + (k + .5) * w, y - (r + .5) * h), txt(l, size: size, fill: _at(ink, r, k), weight: _at(weight, r, k)))
      }
    }
  }
  if row-labels != none {
    for (r, l) in row-labels.enumerate() { content((x - index-gap, y - (r + .5) * h), txt(l, size: size), anchor: "east") }
  }
  if col-labels != none {
    for (k, l) in col-labels.enumerate() { content((x + (k + .5) * w, y + h / 2), txt(l, size: size)) }
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

/// The lanes of a timeline or Gantt chart, one per row `(label, spans)`,
/// top lane first: lane i is `h` tall with its top edge at y - i * pitch.
/// `X` maps time to x. A span is `(t0, t1, fill)` or `(t0, t1, fill, body)`;
/// the body is set in `txt(body-size)` and centred on the span, or with
/// `anchor: "west"` starts `inset` after t0.
/// Labels go right-aligned `gap` left of X(0). `track` fills each lane over
/// `extent`, a (t0, t1) range, behind its spans.
#let lanes(
  rows, X, y: 0, h: 15, pitch: 20, gap: 8, size: 7.5pt, fill: c.ink, body-size: 7pt,
  stroke: .5pt + palette.paper, track: none, extent: none, anchor: "center", inset: 4,
) = {
  // No `import cetz.draw: *`: it would shadow `fill` and `stroke`.
  let (rect, content) = (cetz.draw.rect, cetz.draw.content)
  for (i, (label, spans)) in rows.enumerate() {
    let (top, mid) = (y - i * pitch, y - i * pitch - h / 2)
    if label != none { content((X(0) - gap, mid), txt(label, size: size, fill: fill), anchor: "east") }
    if track != none {
      let (t0, t1) = extent
      rect((X(t0), top), (X(t1), top - h), fill: track, stroke: none)
    }
    for s in spans {
      let (t0, t1, color) = s.slice(0, 3)
      rect((X(t0), top), (X(t1), top - h), fill: color, stroke: stroke)
      if s.len() > 3 and s.at(3) != none {
        let body = txt(s.at(3), size: body-size, fill: c.ink)
        if anchor == "west" { content((X(t0) + inset, mid), body, anchor: "west") } else { content(((X(t0) + X(t1)) / 2, mid), body) }
      }
    }
  }
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

// ============================================================================
// Charts
// ============================================================================
// The parts every hand-drawn chart repeats. Each draws into the current
// canvas. A chart maps values to points with functions of its own, made by
// hand (`let X(v) = v / xmax * w`) or with `coord`.

/// A function mapping lo..hi onto at..at + len, linearly or, with
/// `log: true`, logarithmically, e.g. `let X = coord(0, 35, w)` or
/// `let Y = coord(0.02, 1, h, log: true)`.
#let coord(lo, hi, len, log: false, at: 0) = if log {
  let (a, b) = (calc.log(lo), calc.log(hi))
  v => at + (calc.log(v) - a) / (b - a) * len
} else {
  v => at + (v - lo) / (hi - lo) * len
}

#let grid-stroke = (paint: c.hair, thickness: .5pt, dash: "dotted")
#let axis-stroke = .6pt + c.line

// A tick is a value or a (value, label) pair; a bare value is labelled with
// `format(value)` (`str` by default, e.g. `v => str(v) + "%"`), and a `none`
// label draws the line without one.
#let _tick(t, format) = if type(t) == array { t } else { (t, format(t)) }

/// Horizontal grid lines from x0 to x1 at each tick, labelled left of x0.
/// `Y` maps a value to y. The line at `axis` (by default the first tick) is
/// drawn as the axis; `axis: none` draws grid lines only.
#let y-grid(ticks, Y, x0, x1, axis: auto, gap: 6, size: 7.5pt, fill: c.ink, format: str) = {
  let (line, content) = (cetz.draw.line, cetz.draw.content)
  let ticks = ticks.map(t => _tick(t, format))
  let axis = if axis == auto { ticks.first().first() } else { axis }
  for (v, label) in ticks {
    line((x0, Y(v)), (x1, Y(v)), stroke: if v == axis { axis-stroke } else { grid-stroke })
    if label != none { content((x0 - gap, Y(v)), txt(label, size: size, fill: fill), anchor: "east") }
  }
}

/// Tick marks hanging `len` below y at each tick, labelled `gap` below y.
/// `X` maps a value to x.
#let x-ticks(ticks, X, y: 0, len: 3, gap: 11, size: 7.5pt, fill: c.ink, anchor: "center", format: str) = {
  let (line, content) = (cetz.draw.line, cetz.draw.content)
  for (v, label) in ticks.map(t => _tick(t, format)) {
    if len > 0 { line((X(v), y), (X(v), y - len), stroke: axis-stroke) }
    if label != none { content((X(v), y - gap), txt(label, size: size, fill: fill), anchor: anchor) }
  }
}

/// Vertical grid lines from y0 up to y1 at each tick, labelled `gap` above
/// y1. `X` maps a value to x.
#let x-grid(ticks, X, y0, y1, stroke: grid-stroke, gap: 2, size: 7.5pt, fill: c.ink, format: str) = {
  let (line, content) = (cetz.draw.line, cetz.draw.content)
  for (v, label) in ticks.map(t => _tick(t, format)) {
    line((X(v), y1), (X(v), y0), stroke: stroke)
    if label != none { content((X(v), y1 + gap), txt(label, size: size, fill: fill), anchor: "south") }
  }
}

/// The titles around a w x h plot whose bottom-left corner is `at`: `title`
/// as a tag above the top-left corner (offset `title-at`), `unit` at the top
/// of the y axis, `x-title` centred `x-gap` below the x axis and `y-title`
/// turned along the y axis, `y-gap` left of it.
#let frame(
  w, h, title: none, unit: none, x-title: none, y-title: none, at: (0, 0),
  title-at: (-34, 16), x-gap: 25, y-gap: 30, size: 8pt, fill: c.muted,
) = {
  let content = cetz.draw.content
  let (x, y) = at
  if title != none { content((x + title-at.at(0), y + h + title-at.at(1)), tag(title), anchor: "west") }
  if unit != none { content((x - 6, y + h + 4), txt(unit, size: size - 1pt, fill: fill), anchor: "south-east") }
  if x-title != none { content((x + w / 2, y - x-gap), txt(x-title, size: size, fill: fill)) }
  if y-title != none { content((x - y-gap, y + h / 2), txt(y-title, size: size, fill: fill), angle: 90deg) }
}

/// A polyline through `pts` with a marker on every point: "circle",
/// "square", "hollow" or none. `r` is the marker radius, `ring` the width of
/// the page-coloured outline that separates markers from the lines below.
#let series(pts, color, dash: none, w: 1.2pt, marker: "circle", r: 2.3, ring: .6pt) = {
  import cetz.draw: *
  let paper = palette.paper
  line(..pts, stroke: (paint: color, thickness: w, dash: dash, join: "round"))
  for p in pts {
    let (x, y) = p
    if marker == "circle" { circle(p, radius: r, fill: color, stroke: ring + paper) }
    if marker == "square" { rect((x - r, y - r), (x + r, y + r), fill: color, stroke: ring + paper) }
    if marker == "hollow" { circle(p, radius: r, fill: paper, stroke: 1pt + color) }
  }
}

/// Horizontal bars, one per row `(label, value, fill, note)`, top row first;
/// `sx` is points per unit. Labels go left of the axis at x = 0, notes right
/// of each bar. `unit` is written under the axis; `ref` draws a dashed
/// reference line at that value with `ref-label` under it.
#let hbars(
  rows, sx, pitch: 20, h: 14, size: 8pt, note-size: auto, note-fill: c.muted,
  stroke: .5pt + c.line, axis: axis-stroke, unit: none,
  ref: none, ref-label: none, ref-color: c.danger,
) = {
  // No `import cetz.draw: *`: it would shadow `stroke`.
  let (line, rect, content) = (cetz.draw.line, cetz.draw.rect, cetz.draw.content)
  let n = rows.len()
  let note-size = if note-size == auto { size } else { note-size }
  for (i, (label, v, color, note)) in rows.enumerate() {
    let y = (n - 1 - i) * pitch
    content((-8, y + h / 2), txt(label, size: size, fill: c.ink), anchor: "east")
    rect((0, y), (v * sx, y + h), fill: color, stroke: stroke)
    content((v * sx + 5, y + h / 2), txt(note, size: note-size, fill: note-fill), anchor: "west")
  }
  line((0, -4), (0, n * pitch), stroke: axis)
  if unit != none { content((0, -12), txt(unit, size: size - .5pt), anchor: "west") }
  if ref != none {
    line((ref * sx, -6), (ref * sx, n * pitch + 2), stroke: (paint: ref-color, dash: "dashed", thickness: 1pt))
    if ref-label != none {
      content((ref * sx, -15), txt(ref-label, size: size - 2pt, fill: ref-color, weight: 700))
    }
  }
}

// Box-and-arrow diagrams in the site style, drawn with cetz.
// Import: #import "/utils/diagram.typ": flow, flows, n, divider, diagram, node, edge, note, timeline
//
// Node boxes size themselves to their text; positions are in points (flow) or
// grid cells (diagram). Everything renders through /utils/cetz.typ, so it
// becomes an inline SVG in HTML export.

#import "/utils/cetz.typ" as cetz
#import "/templates/base.typ": palette

// ============================================================================
// Style
// ============================================================================

#let ink = palette.ink
#let muted = palette.muted
#let hairline = palette.hairline
#let edge-stroke = .7pt + palette.line
#let arrow = (end: "stealth", fill: palette.line, scale: .55)

#let tones = (
  plain: (fill: palette.pre-bg, bar: palette.blue, text: ink, sub: muted, border: hairline),
  accent: (fill: palette.tint, bar: palette.orange, text: ink, sub: palette.accent-sub, border: palette.accent-line),
  dark: (fill: ink, bar: palette.orange, text: palette.paper, sub: palette.grey2, border: ink),
  muted: (fill: palette.paper, bar: none, text: muted, sub: muted, border: hairline),
  ghost: (fill: none, bar: none, text: muted, sub: muted, border: none),
)

#let label-text(body) = text(size: 8.5pt, fill: muted, style: "italic", body)

/// The box drawn for a node. `width: auto` hugs the text.
#let node-box(body, sub: none, num: none, tone: "plain", width: auto, align: left) = {
  let t = tones.at(tone)
  let stroke = if t.border == none { none } else if tone == "muted" {
    (paint: t.border, thickness: .6pt, dash: "dashed")
  } else if t.bar != none {
    (left: 2.5pt + t.bar, rest: .5pt + t.border)
  } else { .5pt + t.border }
  block(
    fill: t.fill,
    stroke: stroke,
    inset: (left: if t.bar != none { 10pt } else { 9pt }, right: 10pt, y: 7pt),
    width: width,
    breakable: false,
    {
      set std.align(align)
      set par(leading: .45em, justify: false)
      set text(size: 10pt, fill: t.text, weight: 600)
      if num != none { text(fill: palette.orange)[#num] + h(.6em) }
      body
      if sub != none {
        v(3pt, weak: true)
        block(text(size: 8.5pt, weight: 400, fill: t.sub, sub))
      }
    },
  )
}

// ============================================================================
// flow: a chain of nodes
// ============================================================================
// flow(n[A], [label], n[B], n[C], divider[Frontend][Backend], n[D])
// Content between two nodes labels the edge; `none` or nothing = no label.

/// A flow step. Same arguments as `node-box`.
#let n(body, ..args) = (kind: "node", body: body, args: args.named())

/// A dashed boundary across the flow, with labels above and below it.
#let divider(above, below) = (kind: "divider", above: above, below: below)

// Normalize steps into ((node, label-to-next, divider-to-next), ...).
#let _parse(steps) = {
  let items = ()
  let pending-label = none
  let pending-div = none
  for s in steps {
    if type(s) == dictionary and s.at("kind", default: none) == "node" {
      if items.len() > 0 {
        items.at(-1).label = pending-label
        items.at(-1).div = pending-div
      }
      items.push((node: s, label: none, div: none))
      pending-label = none
      pending-div = none
    } else if type(s) == dictionary and s.at("kind", default: none) == "divider" {
      pending-div = s
    } else {
      pending-label = s
    }
  }
  items
}

// Draw one flow into the current canvas. Returns nothing; names nodes
// `prefix + str(i)`. `x` is the center line (ttb) or start (ltr).
#let _draw-flow(items, dir, width, prefix: "f", x: 0, y: 0) = {
  import cetz.draw: *
  for (i, it) in items.enumerate() {
    let name = prefix + str(i)
    let box = node-box(it.node.body, width: width, ..it.node.args)
    if i == 0 {
      content((x, y), box, anchor: if dir == "ttb" { "north" } else { "west" }, name: name)
    } else {
      let prev = items.at(i - 1)
      let prev-name = prefix + str(i - 1)
      if dir == "ttb" {
        let gap = prev.gap
        content((rel: (0, -gap), to: prev-name + ".south"), box, anchor: "north", name: name)
        line(prev-name + ".south", name + ".north", stroke: edge-stroke, mark: arrow)
        if prev.label != none {
          content(
            (rel: (7, 0), to: (prev-name + ".south", 50%, name + ".north")),
            label-text(prev.label),
            anchor: "west",
          )
        }
        if prev.div != none {
          let mid = ((x, 0), "|-", (prev-name + ".south", 50%, name + ".north"))
          let half = prev.span / 2 + 24
          line((rel: (-half, 0), to: mid), (rel: (half, 0), to: mid),
            stroke: (paint: palette.orange, thickness: .7pt, dash: "dashed"))
          let tag(body) = text(size: 8pt, weight: 600, tracking: 1pt, fill: palette.orange, upper(body))
          content((rel: (half, 4), to: mid), tag(prev.div.above), anchor: "south-east")
          content((rel: (half, -4), to: mid), tag(prev.div.below), anchor: "north-east")
        }
      } else {
        content((rel: (prev.gap, 0), to: prev-name + ".east"), box, anchor: "west", name: name)
        line(prev-name + ".east", name + ".west", stroke: edge-stroke, mark: arrow)
        if prev.label != none {
          content(
            (rel: (0, 4), to: (prev-name + ".east", 50%, name + ".west")),
            label-text(prev.label),
            anchor: "south",
          )
        }
      }
    }
  }
}

// Measure gaps so edge labels fit; ttb gaps grow with label height.
#let _layout(steps, dir, uniform) = {
  let items = _parse(steps)
  let widths = items.map(it => measure(node-box(it.node.body, ..it.node.args)).width)
  let width = if uniform and dir == "ttb" { calc.max(..widths) } else { auto }
  let span = if width == auto { calc.max(..widths) } else { width }
  let items = items.map(it => {
    let l = if it.label == none { 0pt } else if dir == "ttb" {
      measure(label-text(it.label)).height
    } else { measure(label-text(it.label)).width }
    let gap = if dir == "ttb" {
      calc.max(22, l.pt() + 12) + if it.div != none { 22 } else { 0 }
    } else { calc.max(26, l.pt() + 14) }
    it + (gap: gap, span: span.pt())
  })
  // How far edge labels reach right of the center line (ttb only).
  let reach = calc.max(0, ..items.filter(it => it.label != none).map(it => 7 + measure(label-text(it.label)).width.pt()))
  (items.map(it => it + (reach: reach)), width)
}

/// A chain of nodes, top-to-bottom (`dir: "ttb"`) or left-to-right ("ltr").
/// `uniform: true` gives every node in a vertical flow the same width.
#let flow(..steps, dir: "ttb", uniform: true) = context {
  let (items, width) = _layout(steps.pos(), dir, uniform)
  cetz.canvas(length: 1pt, _draw-flow(items, dir, width))
}

/// Several vertical flows side by side, each with an optional caption.
/// flows(([Caption], (n[A], [label], n[B])), ...)
#let flows(..columns, gap: 40) = context {
  let laid = columns.pos().map(((cap, steps)) => (cap, .._layout(steps, "ttb", true)))
  cetz.canvas(length: 1pt, {
    import cetz.draw: *
    let x = 0
    for (i, (cap, items, width)) in laid.enumerate() {
      let w = items.at(0).span
      let right = calc.max(w / 2, items.at(0).reach)
      let cx = x + w / 2
      let top = 0
      if cap != none {
        content((cx, 0), text(size: 8.5pt, weight: 600, tracking: .8pt, fill: palette.orange, cap), anchor: "south")
        top = -8
      }
      _draw-flow(items, "ttb", width, prefix: "c" + str(i) + "-", x: cx, y: top)
      x += w / 2 + right + gap
    }
  })
}

// ============================================================================
// diagram: free layout on a grid
// ============================================================================
// diagram(
//   node("a", (0, 0), [A]),
//   node("b", (1, 1), [B], sub: [...]),
//   edge("a", "b", label: [...], route: "ortho"),
// )
// Grid cell (x, y): x grows right, y grows down; `col` / `row` set the spacing.

#let node(id, pos, body, ..args) = (kind: "node", id: id, pos: pos, body: body, args: args.named())

/// route: "straight" | "ortho" (vertical, horizontal, vertical) | "hvh"
/// (horizontal, vertical, horizontal). `from` / `to` accept "id" or "id.anchor".
#let edge(from, to, label: none, route: "straight", arrow: true, dashed: false, label-side: auto) = (
  kind: "edge", from: from, to: to, label: label, route: route, arrow: arrow, dashed: dashed,
  label-side: label-side,
)

/// Free text at a grid position (e.g. a "+" between nodes).
#let note(pos, body, anchor: "center") = (kind: "note", pos: pos, body: body, anchor: anchor)

#let diagram(..elems, col: 150, row: 58) = cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let elems = elems.pos()
  let at(pos) = (pos.at(0) * col, -pos.at(1) * row)
  let pos-of = (:)
  for e in elems.filter(e => e.kind == "node") {
    pos-of.insert(e.id, e.pos)
    content(at(e.pos), node-box(e.body, ..e.args), anchor: "center", name: e.id)
  }
  for e in elems.filter(e => e.kind == "note") {
    content(at(e.pos), text(size: 9.5pt, fill: muted, e.body), anchor: e.anchor)
  }
  for e in elems.filter(e => e.kind == "edge") {
    let (fid, tid) = (e.from.split(".").at(0), e.to.split(".").at(0))
    let (fp, tp) = (pos-of.at(fid), pos-of.at(tid))
    let (dx, dy) = (tp.at(0) - fp.at(0), tp.at(1) - fp.at(1))
    let vertical = if e.route == "hvh" { false } else if e.route == "ortho" { true } else {
      calc.abs(dy) >= calc.abs(dx)
    }
    let pick(id, given, out) = if "." in given { given } else if vertical {
      id + if (dy >= 0) == out { ".south" } else { ".north" }
    } else {
      id + if (dx >= 0) == out { ".east" } else { ".west" }
    }
    let a = pick(fid, e.from, true)
    let b = pick(tid, e.to, false)
    let mid = (a, 50%, b)
    let pts = if e.route == "ortho" {
      (a, (a, "|-", mid), (b, "|-", mid), b)
    } else if e.route == "hvh" {
      (a, (mid, "|-", a), (mid, "|-", b), b)
    } else { (a, b) }
    let stroke = if e.dashed { (paint: palette.line, thickness: .7pt, dash: "dashed") } else { edge-stroke }
    line(..pts, stroke: stroke, mark: if e.arrow { arrow } else { none })
    if e.label != none {
      let side = if e.label-side != auto { e.label-side } else if vertical { "right" } else { "above" }
      let (off, anc) = (
        right: ((6, 0), "west"), left: ((-6, 0), "east"),
        above: ((0, 4), "south"), below: ((0, -4), "north"),
      ).at(side)
      let lmid = if e.route == "straight" { mid } else { (pts.at(1), 50%, pts.at(2)) }
      content((rel: off, to: lmid), label-text(e.label), anchor: anc)
    }
  }
})

// ============================================================================
// timeline
// ============================================================================
// timeline((version: [2.6], items: ([...], [...]), note: [...], major: true), ...)

#let timeline(..entries, spacing: 14) = context {
  let entries = entries.pos()
  let item-block(e) = block(width: 400pt, {
    set text(size: 9.5pt, fill: ink)
    set par(leading: .5em)
    for it in e.items { block(spacing: 5pt)[#text(fill: palette.orange)[▸] #it] }
  })
  let heights = entries.map(e => calc.max(measure(item-block(e)).height.pt(), 14))
  cetz.canvas(length: 1pt, {
    import cetz.draw: *
    let y = 0
    let ys = ()
    for (e, h) in entries.zip(heights) {
      ys.push(y)
      y -= h + spacing + if e.at("note", default: none) != none { 12 } else { 0 }
    }
    line((0, 4), (0, ys.at(-1) - 6), stroke: 1.2pt + hairline)
    for (e, y) in entries.zip(ys) {
      let major = e.at("major", default: false)
      let note = e.at("note", default: none)
      circle((0, y - 6), radius: if major { 4.5 } else { 3 },
        fill: if major { palette.orange } else { palette.paper },
        stroke: 1pt + if major { palette.orange } else { muted })
      content((-12, y - 6), text(size: 10.5pt, weight: 700, fill: if major { palette.orange } else { ink }, e.version), anchor: "east")
      let top = y
      if note != none {
        content((14, y), text(size: 8pt, weight: 600, tracking: .8pt, fill: palette.orange, note), anchor: "north-west")
        top = y - 12
      }
      content((14, top), item-block(e), anchor: "north-west")
    }
  })
}

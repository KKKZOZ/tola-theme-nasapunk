#import "@tola/source:0.0.0": tola-meta
#import "/utils/cetz.typ" as cetz
#import "/utils/figure.typ" as kit: arrow, box-swatch, c, cells, curve-arrow, legend, line-swatch, pill, seg, tag, txt
#import "/utils/ui.typ": callout, xref

#tola-meta((
  title: "[Tour 04] The Figure Kit",
  date: "2026-03-08",
  summary: "Every helper in utils/figure.typ, with what it draws and how to call it.",
  tags: ("guide", "series", "cetz", "diagram"),
  series: "Theme Tour",
))

// Each example is shown as source, then evaluated to draw it, so the code
// on the page is exactly what produced the figure below it.
#let scope = (
  cetz: cetz, c: c, txt: txt, tag: tag, arrow: arrow, curve-arrow: curve-arrow,
  pill: pill, cells: cells, seg: seg, legend: legend, box-swatch: box-swatch, line-swatch: line-swatch,
)
#let demo(src) = {
  raw(src, lang: "typst", block: true)
  eval(src, mode: "markup", scope: scope)
}

`utils/figure.typ` is a small kit for detailed CeTZ drawings in the theme's
style: a palette that follows the day / night switch, and helpers for the
shapes that technical figures keep needing. #xref("cetz-figures") is built
with it; this post goes through it one helper at a time.

```typst
#import "/utils/cetz.typ" as cetz
#import "/utils/figure.typ": *   // or name the helpers you use
```

Draw on a canvas with `length: 1pt`, so coordinates are points and y grows
upward. Keep a figure under about 560pt wide and it renders at true scale in
the text column; wider figures shrink to fit.

= Colours

`c` is a dictionary of colours. The strong tones are the theme's own; the
pale ones are tints for fills. Each has a night value in the stylesheet, so a
figure drawn with `c` needs no dark version.

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let names = c.keys()
  for (i, name) in names.enumerate() {
    let (x, y) = (calc.rem(i, 6) * 92, -calc.floor(i / 6) * 50)
    rect((x, y), (x + 84, y - 22), fill: c.at(name), stroke: .5pt + c.hair, radius: 2)
    content((x, y - 28), txt(raw("c." + name), size: 7.5pt, fill: c.ink, weight: 600), anchor: "north-west")
    content((x + 84, y - 28), txt(c.at(name).to-hex(), size: 7pt), anchor: "north-east")
  }
})

#callout(kind: "info")[Every colour in `c` changes at night as a fill, and
text counts as a fill. As a stroke, all but `panel` and the pale tints
(`blue1`, `orange1`, `orange2`, `teal1`, `teal2`, `grey1`) change. Any colour
outside `c` keeps its day value; map it at the end of
`assets/styles/site.css` if you need it.]

= Text

`txt` sets figure text: 8pt, muted, regular unless told otherwise. `tag` is
the small uppercase label used for panel titles and markers.

#demo("#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  content((0, 0), txt[default: 8pt, muted], anchor: \"west\")
  content((0, -16), txt(fill: c.ink, weight: 600)[ink, semibold], anchor: \"west\")
  let big = txt.with(size: 10pt, fill: c.blue, style: \"italic\")
  content((0, -32), big[10pt, blue, italic], anchor: \"west\")
  content((220, 0), tag[event log], anchor: \"west\")
  content((220, -16), tag(fill: c.ink)[Δv budget], anchor: \"west\")
  content((220, -32), tag(fill: c.teal)[float4 store], anchor: \"west\")
})")

```typst
txt(body, size: 8pt, fill: c.muted, weight: 400, style: "normal")
tag(body, fill: c.orange)
```

= Arrows

`arrow` draws a line through any number of points with a small stealth head.
`color`, `w` (thickness) and `dash` style it; `head: false` drops the head.
Points can be coordinates or anchors such as `"a.east"`.

#demo("#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  arrow((0, 0), (90, 0))
  arrow((0, -20), (90, -20), color: c.orange, w: 1.4pt)
  arrow((0, -40), (90, -40), color: c.teal, dash: \"dashed\")
  arrow((0, -60), (90, -60), color: c.ink, head: false)
  arrow((140, 0), (140, -30), (230, -30), (230, -60), color: c.blue)
  content((150, -10), txt[polyline: any number of points], anchor: \"west\")
})")

`curve-arrow` is a cubic Bézier from `a` to `b` with control points `c1` and
`c2`: each control point pulls the curve towards it as it leaves or enters.

#demo("#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let (a, b, c1, c2) = ((0, 0), (220, 0), (40, 60), (180, 60))
  curve-arrow(a, b, c1, c2, color: c.orange)
  for p in (c1, c2) { circle(p, radius: 2, fill: c.grey2, stroke: none) }
  line(a, c1, stroke: (paint: c.grey2, thickness: .5pt, dash: \"dotted\"))
  line(b, c2, stroke: (paint: c.grey2, thickness: .5pt, dash: \"dotted\"))
  let (d, e) = ((260, 30), (360, -20))
  curve-arrow(d, e, (360, 30), (260, -20), color: c.blue, dash: \"dashed\")
})")

```typst
arrow(..points, color: c.line, w: .7pt, dash: none, head: true)
curve-arrow(a, b, c1, c2, color: c.line, w: .7pt, dash: none)
```

= Pills

`pill` places a rounded label. Give it a `name` and its edges become anchors
(`"name.east"`, `"name.north"`, ...) for arrows. `anchor` sets which point of
the pill sits at `pos`; `tone` picks one of six styles.

#demo("#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let tones = (\"blue\", \"pale\", \"orange\", \"teal\", \"dark\", \"muted\")
  for (i, tone) in tones.enumerate() {
    pill((i * 88, 0), raw(tone), tone: tone)
  }
  pill((0, -44), \"request\", name: \"a\", anchor: \"west\")
  pill((150, -44), \"cache\", name: \"b\", tone: \"teal\")
  pill((290, -44), \"origin\", name: \"c\", tone: \"dark\")
  arrow(\"a.east\", \"b.west\")
  arrow(\"b.east\", \"c.west\", color: c.orange)
  content((214, -40), txt(style: \"italic\")[miss], anchor: \"south\")
})")

```typst
pill(pos, body, name: none, tone: "blue", anchor: "center", size: 8pt)
```

= Cells

`cells` draws a `rows × cols` grid of `w × h` cells from its top-left corner
`o`; rows grow downward. `paint` is a function of the row and column that
returns each cell's fill, which is where the drawing's logic goes.

#demo("#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let half(r, k) = if r == 1 and k == 5 { c.orange }
    else if k < 8 { c.blue1 } else { c.orange1 }
  cells((0, 0), 4, 16, 12, 12, paint: half)
  content((48, 6), txt(fill: c.blue)[lo], anchor: \"south\")
  content((144, 6), txt(fill: c.orange)[hi], anchor: \"south\")
  let stripes(r, k) = (c.teal1, c.teal2, c.teal).at(calc.rem(r + k, 3))
  cells((240, 0), 4, 4, 12, 12, paint: stripes)
  arrow((66, -18), (66, -60), (264, -60), (264, -48), color: c.ink)
  content((96, -64), txt[element (1, 5)], anchor: \"north-west\")
})")

```typst
cells(o, rows, cols, w, h, paint: (r, k) => c.grey1)
```

= Bars

`seg` draws one bar from `x0` to `x1` with its top edge at `y`, optionally
labelled. Rows of bars make Gantt charts, memory maps and budgets. It takes
a tone rather than a colour so the label stays readable.

#demo("#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let tones = (\"blue1\", \"blue2\", \"blue\", \"orange1\", \"orange\",
    \"teal1\", \"teal2\", \"grey\", \"ink\")
  for (i, tone) in tones.enumerate() {
    seg(i * 58, i * 58 + 56, 0, tone, body: tone)
  }
  content((0, -26), tag(fill: c.ink)[CPU], anchor: \"north-west\")
  seg(40, 140, -24, \"blue1\", body: \"parse\")
  seg(140, 250, -24, \"blue2\", body: \"schedule\")
  content((0, -46), tag(fill: c.ink)[GPU], anchor: \"north-west\")
  seg(250, 400, -44, \"orange\", body: \"kernel\")
  arrow((250, -40), (250, -44), color: c.grey2, w: .5pt)
})")

```typst
seg(x0, x1, y, tone, body: none, h: 16)
// tones: blue1 blue2 blue orange1 orange teal1 teal2 grey ink
```

= Legends

`legend` writes a label to the right of a swatch at `(x, y)`. Pass it the
swatch to draw: `box-swatch` for fills, `line-swatch` for lines. Use the
same coordinates for the legend and its swatch.

#demo("#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  legend(0, 0, \"must keep\", box-swatch(0, 0, c.blue))
  legend(90, 0, \"flexible\", box-swatch(90, 0, c.orange1, stroke: .7pt + c.orange))
  legend(180, 0, \"read\", line-swatch(180, 0, c.line))
  legend(250, 0, \"write\", line-swatch(250, 0, c.orange))
  legend(320, 0, \"index map\", line-swatch(320, 0, c.teal, dash: \"dashed\"))
})")

```typst
legend(x, y, body, swatch)
box-swatch(x, y, fill, stroke: none)
line-swatch(x, y, color, dash: none, w: 1pt)
```

= Putting it together

A figure is these helpers plus plain CeTZ (`rect`, `circle`, `arc`, `line`,
`content`) on one canvas. Define it as a function, in the post or in a module
of its own, and call it where it goes:

#demo("#let fig-cache() = cetz.canvas(length: 1pt, {
  import cetz.draw: *
  content((0, 26), tag[read path], anchor: \"south-west\")
  pill((0, 0), \"load\", name: \"cpu\", tone: \"dark\", anchor: \"west\")
  pill((120, 0), \"L1 · 4 cycles\", name: \"l1\", tone: \"teal\")
  pill((260, 0), \"L2 · 12 cycles\", name: \"l2\")
  pill((400, 0), \"DRAM · ~200\", name: \"mem\", tone: \"orange\")
  arrow(\"cpu.east\", \"l1.west\", color: c.ink)
  arrow(\"l1.east\", \"l2.west\")
  arrow(\"l2.east\", \"mem.west\")
  content((190, 4), txt(style: \"italic\")[miss], anchor: \"south\")
  content((330, 4), txt(style: \"italic\")[miss], anchor: \"south\")
  let back = (color: c.orange, dash: \"dashed\")
  curve-arrow(\"mem.south\", \"l1.south\", (400, -40), (120, -40), ..back)
  content((260, -36), txt(fill: c.orange)[fill 64 B line], anchor: \"north\")
  seg(0, 60, -58, \"teal1\", body: \"hit 92%\")
  seg(60, 76, -58, \"blue2\")
  seg(76, 82, -58, \"orange\")
  legend(100, -66, \"L1 hit\", box-swatch(100, -66, c.teal1))
  legend(160, -66, \"L2 hit\", box-swatch(160, -66, c.blue2))
  legend(220, -66, \"DRAM\", box-swatch(220, -66, c.orange))
})

#fig-cache()")

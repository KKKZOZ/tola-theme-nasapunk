#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/nasapunk:0.0.0": cetz, arrow, box-swatch, c, cells, curve-arrow, legend, line-swatch, pill, seg, tag, txt, callout, demo, hint

#tola-meta((
  title: "[Tour 03] Figures with CeTZ",
  date: "2026-02-14",
  summary: "Detailed CeTZ drawings, themed for day and night, and every helper in the theme's figure kit that builds them.",
  tags: ("example", "series", "cetz", "diagram"),
  series: "Theme Tour",
))

#let demo = demo.with(scope: (
  cetz: cetz, c: c, txt: txt, tag: tag, arrow: arrow, curve-arrow: curve-arrow, pill: pill,
  cells: cells, seg: seg, legend: legend, box-swatch: box-swatch, line-swatch: line-swatch,
))

CeTZ draws through the regular `@preview/cetz` package. Import `cetz` from
the theme instead, and `canvas` renders the drawing as inline SVG in HTML
export:

#demo(```typst
#import "@tola-modules/nasapunk:0.0.0": cetz

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  circle((0, 0), radius: 10)
})
```)

Everything else in CeTZ (`draw`, `vector`, `palette`, ...) is re-exported
unchanged. Text inside the figure is set by Typst with the theme's fonts, and
the SVG scales down on narrow screens.

The theme also carries a small kit for detailed drawings in its
style: a palette that follows the day / night switch, and helpers for the
shapes that technical figures keep needing. The two figures below are built
with it; the sections after them go through it one helper at a time.

```typst
#import "@tola-modules/nasapunk:0.0.0": *   // or name the helpers you use, cetz among them
```

Draw on a canvas with `length: 1pt`, so coordinates are points and y grows
upward. Keep a figure under about 560pt wide and it renders at true scale in
the text column; wider figures shrink to fit.

= Arcs, ellipses and curves

A Hohmann transfer from Earth to Mars. The orbits are circles; the transfer
and Mars's motion are arcs, one of them elliptical; the event log and the
budget bar are `rect` and `content` calls laid out in a loop.

#demo(fold: true, ```typst
#import "@tola-modules/nasapunk:0.0.0": cetz, arrow, box-swatch, c, curve-arrow, legend, line-swatch, pill, seg, tag, txt

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let (r1, r2) = (50, 110)
  let at(r, deg) = (r * calc.cos(deg * 1deg), r * calc.sin(deg * 1deg))
  // Transfer ellipse: periapsis on the inner orbit at 0°, apoapsis on the
  // outer orbit at 180°.
  let (a, b) = ((r1 + r2) / 2, calc.sqrt(r1 * r2))
  let centre = ((r1 - r2) / 2, 0)

  circle((0, 0), radius: r1, stroke: .7pt + c.blue2)
  circle((0, 0), radius: r2, stroke: .7pt + c.grey2)
  arc(centre, start: 180deg, stop: 360deg, radius: (a, b), anchor: "origin",
    stroke: (paint: c.grey2, thickness: .6pt, dash: "dashed"))
  arc(centre, start: 0deg, stop: 180deg, radius: (a, b), anchor: "origin",
    stroke: 1.1pt + c.ink, mark: (end: "stealth", fill: c.ink, scale: .6))
  content((centre.at(0), b + 4), txt("transfer · 259 d", fill: c.ink, weight: 600), anchor: "south")

  // The Sun and the phase angle at launch.
  circle((0, 0), radius: 7, fill: c.orange1, stroke: .7pt + c.orange)
  line((0, 0), at(r2, 44), stroke: (paint: c.grey2, thickness: .5pt, dash: "dotted"))
  line((0, 0), at(r1, 0), stroke: (paint: c.grey2, thickness: .5pt, dash: "dotted"))
  arc(at(17, 0), start: 0deg, stop: 44deg, radius: 17, stroke: .6pt + c.orange)
  content(at(20, 26), txt("φ 44°", fill: c.orange, weight: 600), anchor: "west")

  // Mars runs 136° along its orbit while the craft coasts.
  arc(at(r2 + 9, 48), start: 48deg, stop: 172deg, radius: r2 + 9,
    stroke: (paint: c.orange, thickness: .6pt, dash: "dashed"), mark: (end: "stealth", fill: c.orange, scale: .45))
  content(at(r2 + 13, 112), txt("Mars · +136°", fill: c.orange), anchor: "south-east")
  circle(at(r2, 44), radius: 4, fill: white, stroke: .8pt + c.orange)
  circle(at(r2, 180), radius: 4.5, fill: c.orange, stroke: none)

  // Earth at launch and at arrival.
  circle(at(r1, 0), radius: 4, fill: c.blue, stroke: none)
  circle(at(r1, 255), radius: 3.5, fill: white, stroke: .8pt + c.blue)
  content(at(r1 + 8, 262), txt("Earth at MOI", fill: c.blue), anchor: "north")

  // Burns, tangent to the orbit.
  arrow(at(r1, 0), (r1, 32), color: c.orange, w: 1.6pt)
  pill((r1 + 6, 28), [Δv#sub[1] TMI], anchor: "west", tone: "orange")
  arrow(at(r2, 180), (-r2, -32), color: c.orange, w: 1.6pt)
  pill((-r2 + 6, -28), [Δv#sub[2] MOI], anchor: "west", tone: "orange")

  // Event log on the right, one row per event; burns marked in orange.
  let (px, pw, rh) = (165, 240, 24)
  let top = r2 - 6
  content((px, top + 4), tag("Event log"), anchor: "south-west")
  let rows = (
    ("T+000 d", "TMI burn", "2.94 km/s", true),
    ("T+012 d", "TCM-1", "4.1 m/s", false),
    ("T+120 d", "TCM-2", "0.8 m/s", false),
    ("T+259 d", "MOI burn", "2.65 km/s", true),
  )
  for (i, (t, name, dv, burn)) in rows.enumerate() {
    let y = top - i * rh - rh / 2
    rect((px, y + rh / 2), (px + pw, y - rh / 2), fill: if calc.rem(i, 2) == 0 { c.panel } else { white }, stroke: none)
    if burn {
      circle((px + 9, y), radius: 3, fill: c.orange, stroke: none)
    } else {
      circle((px + 9, y), radius: 2.5, fill: white, stroke: .7pt + c.line)
    }
    content((px + 20, y), txt(t), anchor: "west")
    content((px + 76, y), txt(name, size: 8.5pt, fill: c.ink, weight: 600), anchor: "west")
    content((px + pw - 8, y), txt(dv, fill: if burn { c.orange } else { c.ink }), anchor: "east")
  }
  let bottom = top - rows.len() * rh
  line((px, bottom), (px + pw, bottom), stroke: .5pt + c.hair)
  // Each correction is tiny next to the burns, hence the timeline gap.
  curve-arrow((px + pw + 4, top - 1.5 * rh), (px + pw + 4, top - 2.5 * rh), (px + pw + 22, top - 1.5 * rh), (px + pw + 22, top - 2.5 * rh))
  content((px + pw + 22, top - 2 * rh), txt("108 d", size: 7pt), anchor: "west")

  // Budget bar: the two burns dominate; corrections are a sliver.
  let by = bottom - 30
  content((px, by + 6), tag("Δv budget · 5.60 km/s", fill: c.ink), anchor: "south-west")
  let x1 = px + 2.94 / 5.6 * pw
  seg(px, x1, by, "orange", body: "TMI 2.94")
  seg(x1, x1 + 3, by, "ink")
  seg(x1 + 3, px + pw, by, "orange1", body: "MOI 2.65")
  arrow((x1 + 1.5, by - 26), (x1 + 1.5, by - 18), color: c.ink, w: .6pt)
  content((x1 + 1.5, by - 28), txt("TCM 0.005", size: 7pt), anchor: "north")

  // Phase-angle note under the budget.
  let ny = by - 56
  content((px, ny), txt("Launch when Mars leads Earth by φ, so both", fill: c.ink), anchor: "north-west")
  content((px, ny - 11), txt("meet at apoapsis after the 259-day coast.", fill: c.ink), anchor: "north-west")

  let ly = -r2 - 22
  legend(-r2, ly, "Earth", box-swatch(-r2, ly, c.blue))
  legend(-r2 + 52, ly, "Mars", box-swatch(-r2 + 52, ly, c.orange))
  legend(-r2 + 100, ly, "launch / arrival", box-swatch(-r2 + 100, ly, white, stroke: .7pt + c.line))
  legend(px, ly, "transfer coast", line-swatch(px, ly, c.ink))
  legend(px + 100, ly, "burn", line-swatch(px + 100, ly, c.orange, w: 1.6pt))
})
```)

= Grids and zooms

The bit layout of a telemetry transfer frame header. A loop of `rect` calls
draws the 48 bits, each field coloured by a lookup; dashed lines zoom from the
frame into its header, and Bézier arrows route the frame by its channel id.

#demo(fold: true, ```typst
#import "@tola-modules/nasapunk:0.0.0": cetz, c, cells, curve-arrow, pill, seg, tag, txt

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  // The frame, not to scale: header, three packets and idle fill, then the
  // operational control field and the frame check sequence.
  content((0, 26), tag("Transfer frame · 1115 B", fill: c.ink), anchor: "south-west")
  seg(0, 66, 0, "ink", body: "header", h: 18)
  seg(66, 186, 0, "blue1", body: "packet · APID 0x021", h: 18)
  seg(186, 290, 0, "blue2", body: "packet · APID 0x005", h: 18)
  seg(290, 400, 0, "blue1", body: "packet · APID 0x021", h: 18)
  seg(400, 450, 0, "grey", body: "idle", h: 18)
  seg(450, 500, 0, "teal1", body: "OCF", h: 18)
  seg(500, 540, 0, "orange", body: "FECF", h: 18)
  content((33, -22), txt("6 B"), anchor: "north")
  line((67, 4), (67, 9), (449, 9), (449, 4), stroke: .5pt + c.line)
  content((258, 12), txt("data field · 1103 B"), anchor: "south")
  content((475, -22), txt("4 B"), anchor: "north")
  content((520, -22), txt("2 B"), anchor: "north")

  // Zoom: the 48 header bits.
  let (y, w, h) = (-72, 11, 14)
  let zoom = (paint: c.grey2, thickness: .5pt, dash: "dashed")
  line((0, -18), (0, y), stroke: zoom)
  line((66, -18), (48 * w, y), stroke: zoom)
  // (name, bits, fill, label line, bit values written in the cells)
  let fields = (
    ("ver", 2, c.grey2, 0, "00"),
    ("spacecraft id", 10, c.blue1, 0, "1010100101"),
    ("VC id", 3, c.orange1, 1, "001"),
    ("OCF", 1, c.teal1, 0, "1"),
    ("MC count", 8, c.blue1, 0, none),
    ("VC count", 8, c.blue2, 0, none),
    ("data field status", 16, c.grey1, 0, none),
  )
  let start = ()
  let k = 0
  for f in fields { start.push(k); k += f.at(1) }
  let field-of(bit) = start.enumerate().filter(((i, s)) => bit >= s).last().at(0)
  cells((0, y), 1, 48, w, h, paint: (r, bit) => fields.at(field-of(bit)).at(2))
  for bit in (0, 16, 32, 47) {
    content(((bit + .5) * w, y + 3), txt(str(bit), size: 6.5pt), anchor: "south")
  }
  content((7 * w, y + 14), txt("SCID = 0x2A5", fill: c.blue, weight: 600), anchor: "south")
  for (i, (name, n, _, row, bits)) in fields.enumerate() {
    let (x0, x1) = (start.at(i) * w, (start.at(i) + n) * w)
    if bits != none {
      for (j, b) in bits.clusters().enumerate() {
        content((x0 + (j + .5) * w, y - h / 2), txt(b, size: 6.5pt, fill: c.ink, weight: 600))
      }
    }
    line((x0 + 1, y - h - 4), (x1 - 1, y - h - 4), stroke: .6pt + c.line)
    let ly = y - h - 7 - row * 12
    if row > 0 { line(((x0 + x1) / 2, y - h - 4), ((x0 + x1) / 2, ly), stroke: .5pt + c.line) }
    content(((x0 + x1) / 2, ly), txt(name + " · " + str(n), size: 7pt, fill: c.ink), anchor: "north")
  }

  // The virtual channel id routes the frame on the ground.
  let vx = 13.5 * w
  let vc = (vx, y - h - 34)
  circle(vc, radius: 2.5, fill: c.orange, stroke: none)
  line((vx, y - h - 28), vc, stroke: .7pt + c.orange)
  let py = y - h - 92
  let dests = (
    ("VC 0 · housekeeping", 250, false),
    ("VC 1 · science", 370, true),
    ("VC 7 · idle, dropped", 480, false),
  )
  for (i, (body, x, taken)) in dests.enumerate() {
    pill((x, py), body, tone: if taken { "orange" } else { "muted" }, name: "vc" + str(i))
    curve-arrow(vc, "vc" + str(i) + ".north", (vx, py + 20), (x, py + 50),
      color: if taken { c.orange } else { c.grey2 }, dash: if not taken { "dashed" }, w: if taken { 1pt } else { .7pt })
  }
  content((vx + 8, vc.at(1)), txt("VC id = 1 → science", fill: c.orange, style: "italic"), anchor: "west")
})
```)

= Colours

#hint[Switch the theme with the toggle in the header: every figure on this
page follows it.]

`c` is a dictionary of colours. The strong tones are the theme's own; the
pale ones are tints for fills. Each has a night value in
`theme/templates/colors.typ`, so a figure drawn with `c` needs no dark version.

#demo(fold: true, ```typst
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
```)

#callout(kind: "info")[Every colour in `c` changes at night, as a fill (text
included) and as a stroke. A colour of your own keeps its day value in both
themes; to give it a night value, add it to `theme/templates/colors.typ` and draw
with `palette.<name>`, imported from the theme.]

= Text

`txt` sets figure text: 8pt, muted, regular unless told otherwise. `tag` is
the small uppercase label used for panel titles and markers.

#demo(```typst
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  content((0, 0), txt[default: 8pt, muted], anchor: "west")
  content((0, -16), txt(fill: c.ink, weight: 600)[ink, semibold], anchor: "west")
  let big = txt.with(size: 10pt, fill: c.blue, style: "italic")
  content((0, -32), big[10pt, blue, italic], anchor: "west")
  content((220, 0), tag[event log], anchor: "west")
  content((220, -16), tag(fill: c.ink)[Δv budget], anchor: "west")
  content((220, -32), tag(fill: c.teal)[float4 store], anchor: "west")
})
```)

```typst
txt(body, size: 8pt, fill: c.muted, weight: 400, style: "normal")
tag(body, fill: c.orange)
```

= Arrows

`arrow` draws a line through any number of points with a small stealth head.
`color`, `w` (thickness) and `dash` style it; `head: false` drops the head.
Points can be coordinates or anchors such as `"a.east"`.

#demo(```typst
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  arrow((0, 0), (90, 0))
  arrow((0, -20), (90, -20), color: c.orange, w: 1.4pt)
  arrow((0, -40), (90, -40), color: c.teal, dash: "dashed")
  arrow((0, -60), (90, -60), color: c.ink, head: false)
  arrow((140, 0), (140, -30), (230, -30), (230, -60), color: c.blue)
  content((150, -10), txt[polyline: any number of points], anchor: "west")
})
```)

`curve-arrow` is a cubic Bézier from `a` to `b` with control points `c1` and
`c2`: each control point pulls the curve towards it as it leaves or enters.

#demo(```typst
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let (a, b, c1, c2) = ((0, 0), (220, 0), (40, 60), (180, 60))
  curve-arrow(a, b, c1, c2, color: c.orange)
  for p in (c1, c2) { circle(p, radius: 2, fill: c.grey2, stroke: none) }
  line(a, c1, stroke: (paint: c.grey2, thickness: .5pt, dash: "dotted"))
  line(b, c2, stroke: (paint: c.grey2, thickness: .5pt, dash: "dotted"))
  let (d, e) = ((260, 30), (360, -20))
  curve-arrow(d, e, (360, 30), (260, -20), color: c.blue, dash: "dashed")
})
```)

```typst
arrow(..points, color: c.line, w: .7pt, dash: none, head: true)
curve-arrow(a, b, c1, c2, color: c.line, w: .7pt, dash: none)
```

`arrow` draws one head. For two, or for the end bars of a dimension line,
give a plain `line` its own `mark`:

#demo(```typst
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  line((0, 0), (120, 0), stroke: .7pt + c.ink, mark: (start: ">", end: ">", fill: c.ink))
  content((60, 4), txt[both ways], anchor: "south")
  line((180, 0), (300, 0), stroke: .6pt + c.orange, mark: (start: "|", end: "|", scale: .5))
  content((240, 4), txt(fill: c.orange)[120 pt], anchor: "south")
})
```)

= Pills

`pill` places a rounded label. Give it a `name` and its edges become anchors
(`"name.east"`, `"name.north"`, ...) for arrows. `anchor` sets which point of
the pill sits at `pos`; `tone` picks one of six styles.

#demo(```typst
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let tones = ("blue", "pale", "orange", "teal", "dark", "muted")
  for (i, tone) in tones.enumerate() {
    pill((i * 88, 0), raw(tone), tone: tone)
  }
  pill((0, -44), "request", name: "a", anchor: "west")
  pill((150, -44), "cache", name: "b", tone: "teal")
  pill((290, -44), "origin", name: "c", tone: "dark")
  arrow("a.east", "b.west")
  arrow("b.east", "c.west", color: c.orange)
  content((214, -40), txt(style: "italic")[miss], anchor: "south")
})
```)

```typst
pill(pos, body, name: none, tone: "blue", anchor: "center", size: 8pt)
```

= Cells

`cells` draws a `rows × cols` grid of `w × h` cells from its top-left corner
`o`; rows grow downward. `paint` is a function of the row and column that
returns each cell's fill, which is where the drawing's logic goes.

#demo(```typst
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let half(r, k) = if r == 1 and k == 5 { c.orange }
    else if k < 8 { c.blue1 } else { c.orange1 }
  cells((0, 0), 4, 16, 12, 12, paint: half)
  content((48, 6), txt(fill: c.blue)[lo], anchor: "south")
  content((144, 6), txt(fill: c.orange)[hi], anchor: "south")
  let stripes(r, k) = (c.teal1, c.teal2, c.teal).at(calc.rem(r + k, 3))
  cells((240, 0), 4, 4, 12, 12, paint: stripes)
  arrow((66, -18), (66, -60), (264, -60), (264, -48), color: c.ink)
  content((96, -64), txt[element (1, 5)], anchor: "north-west")
})
```)

```typst
cells(o, rows, cols, w, h, paint: (r, k) => c.grey1)
```

= Bars

`seg` draws one bar from `x0` to `x1` with its top edge at `y`, optionally
labelled. Rows of bars make Gantt charts, memory maps and budgets. It takes
a tone rather than a colour so the label stays readable.

#demo(```typst
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let tones = ("blue1", "blue2", "blue", "orange1", "orange",
    "teal1", "teal2", "grey", "ink")
  for (i, tone) in tones.enumerate() {
    seg(i * 58, i * 58 + 56, 0, tone, body: tone)
  }
  content((0, -26), tag(fill: c.ink)[CPU], anchor: "north-west")
  seg(40, 140, -24, "blue1", body: "parse")
  seg(140, 250, -24, "blue2", body: "schedule")
  content((0, -46), tag(fill: c.ink)[GPU], anchor: "north-west")
  seg(250, 400, -44, "orange", body: "kernel")
  arrow((250, -40), (250, -44), color: c.grey2, w: .5pt)
})
```)

```typst
seg(x0, x1, y, tone, body: none, h: 16)
// tones: blue1 blue2 blue orange1 orange teal1 teal2 grey ink
```

= Legends

`legend` writes a label to the right of a swatch at `(x, y)`. Pass it the
swatch to draw: `box-swatch` for fills, `line-swatch` for lines. Use the
same coordinates for the legend and its swatch.

#demo(```typst
#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  legend(0, 0, "must keep", box-swatch(0, 0, c.blue))
  legend(90, 0, "flexible", box-swatch(90, 0, c.orange1, stroke: .7pt + c.orange))
  legend(180, 0, "read", line-swatch(180, 0, c.line))
  legend(250, 0, "write", line-swatch(250, 0, c.orange))
  legend(320, 0, "index map", line-swatch(320, 0, c.teal, dash: "dashed"))
})
```)

```typst
legend(x, y, body, swatch)
box-swatch(x, y, fill, stroke: none)
line-swatch(x, y, color, dash: none, w: 1pt)
```

= Putting it together

A figure is these helpers plus plain CeTZ (`rect`, `circle`, `arc`, `line`,
`content`) on one canvas. Define it as a function and place it with
`#figure`, which numbers it, sets the caption under it and gives it a label
to cite:

#demo(```typst
#let fig-cache() = cetz.canvas(length: 1pt, {
  import cetz.draw: *
  content((0, 26), tag[read path], anchor: "south-west")
  pill((0, 0), "load", name: "cpu", tone: "dark", anchor: "west")
  pill((120, 0), "L1 · 4 cycles", name: "l1", tone: "teal")
  pill((260, 0), "L2 · 12 cycles", name: "l2")
  pill((400, 0), "DRAM · ~200", name: "mem", tone: "orange")
  arrow("cpu.east", "l1.west", color: c.ink)
  arrow("l1.east", "l2.west")
  arrow("l2.east", "mem.west")
  content((190, 4), txt(style: "italic")[miss], anchor: "south")
  content((330, 4), txt(style: "italic")[miss], anchor: "south")
  let back = (color: c.orange, dash: "dashed")
  curve-arrow("mem.south", "l1.south", (400, -40), (120, -40), ..back)
  content((260, -36), txt(fill: c.orange)[fill 64 B line], anchor: "north")
  seg(0, 60, -58, "teal1", body: "hit 92%")
  seg(60, 76, -58, "blue2")
  seg(76, 82, -58, "orange")
  legend(100, -66, "L1 hit", box-swatch(100, -66, c.teal1))
  legend(160, -66, "L2 hit", box-swatch(160, -66, c.blue2))
  legend(220, -66, "DRAM", box-swatch(220, -66, c.orange))
})

#figure(fig-cache(), caption: [A load that misses L1 and L2.]) <fig-cache>

In @fig-cache, DRAM fills the whole 64-byte line back into L1.
```)

A post with more than a couple of figures reads better with them in a module
of its own, one per post, and only `#figure` calls in the text. Helpers that
only that post needs go in the module too, next to the figures that use them:

```typst
// figures/caches.typ
#import "@tola-modules/nasapunk:0.0.0": cetz
#import "@tola-modules/nasapunk:0.0.0": *

#let fig-cache() = cetz.canvas(length: 1pt, { ... })
```

```typst
// content/posts/caches.typ
#import "/figures/caches.typ" as fig

#figure(fig.fig-cache(), caption: [A load that misses L1 and L2.]) <fig-cache>
```

The three figures below come from posts written this way. Each defines a few
helpers of its own at the top of its source, folded under the drawing.

== Math in labels

An LSTM cell. Any label can be Typst math: `txt($c_(t-1)$)` sets it in the
figure's size and colour. Three small helpers draw the glyphs the figure
repeats: a dark square for elementwise × and +, a disc for each activation,
and a dot where a line branches.

#demo(fold: true, ```typst
#import "@tola-modules/nasapunk:0.0.0": cetz, arrow, box-swatch, c, legend, txt

// A label, ink unless told otherwise; often math.
#let lbl(pos, body, anchor: "center", fill: c.ink) = cetz.draw.content(
  pos, txt(body, size: 9pt, fill: fill), anchor: anchor,
)
// A small caption under part of the figure.
#let note(pos, body, fill: c.muted) = cetz.draw.content(
  pos, align(center, txt(body, size: 7pt, fill: fill)), anchor: "north",
)
// Elementwise × or +: a dark square.
#let op(pos, sym, name: none, s: 7) = {
  import cetz.draw: *
  let (x, y) = pos
  rect((x - s, y - s), (x + s, y + s), fill: c.ink, stroke: none, radius: 2, name: name)
  content(pos, text(size: 9pt, weight: 700, fill: white, sym))
}
// An activation: σ gates are orange, tanh is teal.
#let act(pos, body, name: none, gate: false, r: 11) = {
  import cetz.draw: *
  circle(pos, radius: r, fill: if gate { c.orange } else { c.teal }, stroke: none, name: name)
  content(pos, text(size: if gate { 9pt } else { 6.5pt }, weight: 600, fill: white, body))
}
#let junction(pos, color: c.line) = cetz.draw.circle(pos, radius: 1.8, fill: color, stroke: none)
#let wire(..pts, color: c.line, w: .7pt) = arrow(..pts, color: color, w: w, head: false)

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let (yc, yg, yh) = (100, 40, 0)
  let (xf, xi, xg, xo, xn) = (120, 170, 220, 280, 370)
  rect((44, -22), (414, 124), fill: c.panel, stroke: none, radius: 10)

  // Cell state: the line along the top.
  lbl((4, yc + 6), $c_(t-1)$, anchor: "south-west", fill: c.orange)
  arrow((0, yc), (476, yc), color: c.orange, w: 1.2pt)
  lbl((476, yc + 6), $c_t$, anchor: "south-east", fill: c.orange)
  op((xf, yc), "×", name: "mf")
  op((xg, yc), "+", name: "add")
  content((300, yc + 6), txt("cell state: only × and +", size: 7pt, fill: c.orange), anchor: "south")

  // Hidden state, joined by the input.
  lbl((4, yh + 6), $h_(t-1)$, anchor: "south-west", fill: c.blue)
  wire((0, yh), (xo, yh), color: c.blue, w: 1.2pt)
  wire((70, -52), (70, yh), color: c.ink, w: 1.2pt)
  line((62, yh), (78, yh), stroke: 1.6pt + c.ink)
  lbl((78, -50), $x_t$, anchor: "west")
  note((70, -58), [concat $[h_(t-1), x_t]$])

  // The four gates.
  for x in (xf, xi, xg, xo) { wire((x, yh), (x, yg - 11), color: c.blue) }
  act((xf, yg), "σ", name: "f", gate: true)
  act((xi, yg), "σ", name: "i", gate: true)
  act((xg, yg), "tanh", name: "g")
  act((xo, yg), "σ", name: "o", gate: true)
  for (x, body) in ((xf, [forget $f_t$]), (xi, [input $i_t$]), (xg, [candidate $tilde(c)_t$]), (xo, [output $o_t$])) {
    note((x, -28), body, fill: c.ink)
  }

  // Forget: c_(t-1) × f_t.
  arrow("f.north", "mf.south", color: c.teal)
  // Write: i_t × candidate, added to the cell state.
  op((xg, 70), "×", name: "mi")
  arrow("g.north", "mi.south", color: c.teal)
  arrow("i.north", (xi, 70), "mi.west", color: c.teal)
  arrow("mi.north", "add.south", color: c.ink)

  // Read: h_t = o_t × tanh(c_t).
  junction((xn, yc), color: c.orange)
  act((xn, 70), "tanh", name: "tc", r: 10)
  op((xn, yg), "×", name: "mo")
  arrow((xn, yc), "tc.north", color: c.orange)
  arrow("tc.south", "mo.north", color: c.teal)
  arrow("o.east", "mo.west", color: c.teal)
  arrow("mo.south", (xn, yh), (476, yh), color: c.blue, w: 1.2pt)
  lbl((476, yh + 6), $h_t$, anchor: "south-east", fill: c.blue)
  note((440, yh - 6), "out, on to t + 1")

  let ly = -84
  legend(0, ly, "elementwise × / +", box-swatch(0, ly, c.ink))
  legend(130, ly, "σ: gate, in [0, 1]", box-swatch(130, ly, c.orange))
  legend(260, ly, "tanh: content, in [-1, 1]", box-swatch(260, ly, c.teal))
})
```)

== Drawn from data

A `Q2_K` super-block from llama.cpp's quantization: 256 weights in 16
groups, each with a 4-bit scale and offset. The cells, the highlighted
groups and the axis are all computed from the two arrays at the top, so
changing a number redraws the figure. `txt.with(size: 9pt)` raises the
kit's default text size for this one figure.

#demo(fold: true, ```typst
#import "@tola-modules/nasapunk:0.0.0": cetz, arrow, c, txt

#let txt = txt.with(size: 9pt)
#let head(body) = text(size: 9pt, weight: 700, tracking: .6pt, fill: c.ink, upper(body))
#let dotted = (paint: c.line, thickness: .5pt, dash: "dotted")

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let (x0, cw, n) = (112, 26.5, 16)
  let x1 = x0 + n * cw
  let cx(j) = x0 + (j + .5) * cw
  let (d, dmin) = (0.01, 0.005)
  let s = (7, 4, 9, 2, 11, 5, 8, 6, 10, 3, 6, 13, 6, 7, 9, 5)
  let m = (3, 8, 2, 10, 6, 9, 1, 4, 5, 7, 3, 2, 4, 4, 6, 8)
  let hl = (3, 12)
  let fmt(v) = {
    let r = calc.round(v, digits: 3)
    if r < 0 { "−" + str(-r) } else { str(r) }
  }
  // Two decimals, so the levels read 0.10, not 0.1.
  let fmt2(v) = {
    let t = str(calc.round(calc.abs(v) * 100))
    let t = if t.len() < 3 { "0" * (3 - t.len()) + t } else { t }
    (if v < -0.0001 { "−" } else { "" }) + t.slice(0, -2) + "." + t.slice(-2)
  }
  let level-label(y, name, note) = {
    content((0, y + 6), txt(name, size: 9.5pt, fill: c.ink, weight: 700), anchor: "west")
    content((0, y - 7), txt(note, size: 8pt), anchor: "west")
  }
  content((0, 0), head("one Q2_K super-block · 256 weights = 16 groups × 16"), anchor: "west")

  // Level 1: two fp16 values shared by all 16 groups.
  let (yd, ym, bh) = (-16, -40, 22)
  rect((x0, yd), (x1, yd - bh), fill: c.blue2, stroke: .6pt + white)
  content(((x0 + x1) / 2, yd - bh / 2), txt[*d = 0.01* (fp16)  ·  multiplies every $s_j$])
  rect((x0, ym), (x1, ym - bh), fill: c.orange2, stroke: .6pt + white)
  content(((x0 + x1) / 2, ym - bh / 2), txt[*dmin = 0.005* (fp16)  ·  multiplies every $m_j$])
  level-label(-39, "per super-block", "2 × fp16 = 4 B")

  // Level 2: one byte per group, s_j in the low nibble, m_j in the high one.
  let (yi, ys, rh) = (-76, -84, 20)
  for j in range(n) {
    let on = j in hl
    let weight = if on { 700 } else { 400 }
    let ink = if on { c.ink } else { c.muted }
    content((cx(j), yi), txt(str(j), size: 8pt, fill: ink, weight: weight))
    rect((x0 + j * cw, ys), (x0 + (j + 1) * cw, ys - rh), fill: if on { c.blue2 } else { c.blue1 }, stroke: .6pt + white)
    rect((x0 + j * cw, ys - rh), (x0 + (j + 1) * cw, ys - 2 * rh), fill: if on { c.orange2 } else { c.orange1 }, stroke: .6pt + white)
    content((cx(j), ys - rh / 2), txt(str(s.at(j)), fill: ink, weight: weight))
    content((cx(j), ys - 1.5 * rh), txt(str(m.at(j)), fill: ink, weight: weight))
  }
  content((x0 - 6, yi), txt("group j", size: 8pt), anchor: "east")
  content((x0 - 6, ys - rh / 2), txt($s_j$, fill: c.blue, weight: 700), anchor: "east")
  content((x0 - 6, ys - 1.5 * rh), txt($m_j$, fill: c.orange, weight: 700), anchor: "east")
  level-label(ys - rh, "per group", "4 + 4 bit = 1 B")
  for j in hl {
    rect((x0 + j * cw, yi + 8), (x0 + (j + 1) * cw, ys - 2 * rh), stroke: 1.1pt + c.ink)
  }

  // The decoded scale and offset of the two highlighted groups.
  let (yb, bw, bh2) = (-146, 196, 38)
  for j in hl {
    arrow((cx(j), ys - 2 * rh - 2), (cx(j), yb + 1), color: c.ink, w: .8pt)
    rect((cx(j) - bw / 2, yb), (cx(j) + bw / 2, yb - bh2), fill: c.panel, stroke: .6pt + c.hair)
    content((cx(j), yb - 11), txt([$"scale"_#j$ = d · #s.at(j) = #fmt(d * s.at(j))], fill: c.blue, weight: 600))
    content((cx(j), yb - 27), txt([$"offset"_#j$ = dmin · #m.at(j) = #fmt(dmin * m.at(j))], fill: c.orange, weight: 600))
  }

  // Level 3: the 4 values each group can encode, on one shared axis.
  let (v0, v1) = (-0.06, 0.18)
  let X(v) = x0 + (v - v0) / (v1 - v0) * (x1 - x0)
  let (yr, ya) = ((-220, -258), -290)
  line((X(0), yb - bh2 - 8), (X(0), ya), stroke: dotted)
  for (r, j) in hl.enumerate() {
    let y = yr.at(r)
    let lv = range(4).map(q => d * s.at(j) * q - dmin * m.at(j))
    arrow((cx(j), yb - bh2 - 1), (cx(j), y + 16), color: c.ink, w: .8pt)
    line((X(lv.first()), y), (X(lv.last()), y), stroke: 1.4pt + c.grey2)
    for (q, v) in lv.enumerate() {
      circle((X(v), y), radius: 3.6, fill: c.ink, stroke: 1pt + white)
      content((X(v), y + 10), txt("q=" + str(q), size: 7.5pt))
      content((X(v), y - 11), txt(fmt2(v), size: 8.5pt, fill: c.ink, weight: 600))
    }
    content((x0 - 6, y), txt("group " + str(j), size: 8.5pt, fill: c.ink), anchor: "east")
  }
  level-label(-239, "per weight", "2-bit q → 1 of 4")
  line((x0, ya), (x1, ya), stroke: .7pt + c.line)
  for t in range(-1, 5) {
    let v = t * 0.04
    line((X(v), ya), (X(v), ya - 4), stroke: .7pt + c.line)
    content((X(v), ya - 12), txt(fmt(v), size: 8pt))
  }

  content(((x0 + x1) / 2, ya - 34), txt([w = $"scale"_j$ · q − $"offset"_j$ = d · $s_j$ · q − dmin · $m_j$], size: 10pt, fill: c.ink, weight: 600))
})
```)

== Panels from shared helpers

`git merge` and `git rebase` side by side. Three helpers draw a commit, the
line from a parent to its child, and a branch name; each panel then only
lists its commits. The panels are the same drawing shifted right: `P` turns
a commit's column and row into a point inside the current panel.

#demo(fold: true, ```typst
#import "@tola-modules/nasapunk:0.0.0": cetz, c, tag, txt

#let commit-tones = (
  grey: (c.grey1, c.line), blue: (c.blue1, c.blue), orange: (c.orange1, c.orange),
  teal: (c.teal1, c.teal), ghost: (white, c.grey2),
)
// A commit dot with its hash below it, or above with `up: true`.
#let commit(p, label, tone: "grey", up: false) = {
  import cetz.draw: *
  let (fill, stroke) = commit-tones.at(tone)
  let ghost = tone == "ghost"
  circle(p, radius: 5.5, fill: fill, stroke: (paint: stroke, thickness: .9pt, dash: if ghost { "dashed" }))
  let (x, y) = p
  content((x, if up { y + 9 } else { y - 9 }), txt(label, size: 6pt, fill: if ghost { c.grey2 } else { c.muted }),
    anchor: if up { "south" } else { "north" })
}
// Parent to child, stopping at the rims of the two dots.
#let parent(a, b, ghost: false) = {
  import cetz.draw: *
  let ((ax, ay), (bx, by)) = (a, b)
  let d = calc.sqrt(calc.pow(bx - ax, 2) + calc.pow(by - ay, 2))
  let (ux, uy) = ((bx - ax) / d * 5.5, (by - ay) / d * 5.5)
  line((ax + ux, ay + uy), (bx - ux, by - uy),
    stroke: (paint: if ghost { c.grey2 } else { c.line }, thickness: .9pt, dash: if ghost { "dashed" }))
}
// A branch name beside a commit.
#let branch(p, body, side: "right") = {
  let (x, y) = p
  let (pos, anchor) = (right: ((x + 10, y), "west"), down: ((x, y - 20), "north")).at(side)
  cetz.draw.content(pos, anchor: anchor, box(fill: c.ink, radius: 2pt, inset: (x: 4pt, y: 2.5pt),
    text(size: 6.5pt, weight: 600, fill: white, body)))
}

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  let s = 36
  let (ym, yf) = (-12, -50)
  let panel(ox, title, sub) = {
    content((ox, 44), tag(title, fill: c.ink), anchor: "south-west")
    content((ox, 40), txt(sub, size: 6.5pt), anchor: "north-west")
  }

  let ox = 0
  let P(i, y) = (ox + 10 + i * s, y)
  panel(ox, "Start", [feature branched off an older main])
  parent(P(0, ym), P(1, ym)); parent(P(1, ym), P(2, ym))
  parent(P(0, ym), P(1, yf)); parent(P(1, yf), P(2, yf))
  commit(P(0, ym), "a0b1")
  commit(P(1, ym), "f5e7", tone: "blue", up: true)
  commit(P(2, ym), "g6h8", tone: "blue", up: true)
  commit(P(1, yf), "b1d4", tone: "orange")
  commit(P(2, yf), "c3f2", tone: "orange")
  branch(P(2, ym), [main])
  branch(P(2, yf), [feature])

  let ox = 186
  let P(i, y) = (ox + 10 + i * s, y)
  panel(ox, "git merge main", [one new commit with two parents])
  parent(P(0, ym), P(1, ym)); parent(P(1, ym), P(2, ym))
  parent(P(0, ym), P(1, yf)); parent(P(1, yf), P(2, yf))
  parent(P(2, yf), P(3, yf)); parent(P(2, ym), P(3, yf))
  commit(P(0, ym), "a0b1")
  commit(P(1, ym), "f5e7", tone: "blue", up: true)
  commit(P(2, ym), "g6h8", tone: "blue", up: true)
  commit(P(1, yf), "b1d4", tone: "orange")
  commit(P(2, yf), "c3f2", tone: "orange")
  commit(P(3, yf), "M", tone: "teal")
  branch(P(2, ym), [main])
  branch(P(3, yf), [feature])

  let ox = 372
  let P(i, y) = (ox + 10 + i * s, y)
  panel(ox, "git rebase main", [feature's commits rebuilt after main])
  parent(P(0, ym), P(1, ym)); parent(P(1, ym), P(2, ym))
  parent(P(2, ym), P(3, ym)); parent(P(3, ym), P(4, ym))
  parent(P(0, ym), P(1, yf), ghost: true); parent(P(1, yf), P(2, yf), ghost: true)
  commit(P(0, ym), "a0b1")
  commit(P(1, ym), "f5e7", tone: "blue", up: true)
  commit(P(2, ym), "g6h8", tone: "blue", up: true)
  commit(P(3, ym), "b1d4′", tone: "orange", up: true)
  commit(P(4, ym), "c3f2′", tone: "orange", up: true)
  commit(P(1, yf), "b1d4", tone: "ghost")
  commit(P(2, yf), "c3f2", tone: "ghost")
  branch(P(2, ym), [main], side: "down")
  branch(P(4, ym), [feature], side: "down")
  content((P(2, yf).at(0) + 12, yf), txt("no longer referenced", size: 6pt, fill: c.grey2), anchor: "west")
})
```)

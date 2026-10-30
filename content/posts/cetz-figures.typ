#import "@tola/source:0.0.0": tola-meta
#import "/utils/cetz.typ" as cetz
#import "/utils/figure.typ": arrow, box-swatch, c, cells, curve-arrow, legend, line-swatch, pill, seg, tag, txt
#import "/utils/ui.typ": hint

#tola-meta((
  title: "[Tour 03] Figures with CeTZ",
  date: "2026-02-14",
  summary: "Detailed CeTZ drawings, rendered to inline SVG and themed for day and night.",
  tags: ("example", "series", "cetz", "diagram"),
  series: "Theme Tour",
))

#let fig-transfer() = cetz.canvas(length: 1pt, {
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

#let fig-frame() = cetz.canvas(length: 1pt, {
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

CeTZ draws through the regular `@preview/cetz` package. Import it from
`/utils/cetz.typ` instead, and `canvas` renders the drawing as inline SVG in
HTML export:

```typst
#import "/utils/cetz.typ" as cetz

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  circle((0, 0), radius: 10)
})
```

Everything else in CeTZ (`draw`, `vector`, `palette`, ...) is re-exported
unchanged. Text inside the figure is set by Typst with the theme's fonts, and
the SVG scales down on narrow screens.

= Arcs, ellipses and curves

A Hohmann transfer from Earth to Mars. The orbits are circles; the transfer
and Mars's motion are arcs, one of them elliptical; the event log and the
budget bar are `rect` and `content` calls laid out in a loop.

#fig-transfer()

= Grids and zooms

The bit layout of a telemetry transfer frame header. A loop of `rect` calls
draws the 48 bits, each field coloured by a lookup; dashed lines zoom from the
frame into its header, and Bézier arrows route the frame by its channel id.

#fig-frame()

= Colours for both themes

#hint[Switch the theme with the toggle in the header: both figures follow it.]

The figures take their colours from `c` in `utils/figure.typ`. The
stylesheet swaps each of those colours for a night value, so a drawing in
them needs no second version. The same module holds the helpers used here:

```typst
#import "/utils/figure.typ": c, txt, tag, arrow, curve-arrow, pill, cells, seg, legend

#cetz.canvas(length: 1pt, {
  import cetz.draw: *
  pill((0, 0), "ground", name: "a")
  pill((120, 0), "craft", name: "b", tone: "orange")
  arrow("a.east", "b.west")
  seg(0, 160, -24, "blue1", body: "pass · 42 min")
})
```

A colour outside `c` keeps its day value at night. Add a mapping for it to
the end of `assets/styles/site.css` if you need one.

#import "@tola/source:0.0.0": tola-meta
#import "/utils/diagram.typ": diagram, divider, edge, flow, flows, n, node, note, timeline
#import "/utils/ui.typ": demo

#tola-meta((
  title: "[Tour 02] Diagrams and Timelines",
  date: "2025-07-04",
  summary: "Part two of a sample series: flows, grid diagrams and timelines from utils/diagram.typ.",
  tags: ("example", "series", "diagram"),
  series: "Theme Tour",
))

#let demo = demo.with(scope: (
  diagram: diagram, divider: divider, edge: edge, flow: flow, flows: flows, n: n, node: node,
  note: note, timeline: timeline,
))

Diagrams are drawn by Typst at build time and embedded as inline SVG. Their
colors come from the theme palette, so they follow the day / night switch.
Each one below is shown as its source, then as what that source draws.

= Flow

`flow` draws a chain of nodes, top to bottom (or left to right with
`dir: "ltr"`). `n` makes a node: `sub` adds a smaller second line and `tone`
picks its style (`"plain"` by default, `"accent"`, `"dark"`, `"muted"`,
`"ghost"`). Plain content between two nodes labels the edge; `divider` draws
a boundary across the flow, naming the side before and after it.

#demo(```typst
#import "/utils/diagram.typ": flow, n, divider

#flow(
  n([Source], sub: [`content/*.typ`]),
  [tola-meta],
  n([Site program], sub: [`site.typ`], tone: "accent"),
  divider[Typst][Output],
  n([HTML pages], sub: [`public/`], tone: "dark"),
  [build hook],
  n[Search index],
)
```)

`dir: "ltr"` lays the chain out left to right, with edge labels above the
arrows. `num` puts an orange step number before a node's text. In a vertical
flow every node takes the width of the widest; `uniform: false` lets each
one hug its own text.

#demo(```typst
#import "/utils/diagram.typ": flow, n

#flow(
  dir: "ltr",
  n([Write], num: [01]),
  [save],
  n([Build], num: [02], tone: "accent"),
  n([Publish], num: [03], tone: "dark"),
)
```)

= Side by side

`flows` sets vertical flows next to each other, for comparing two ways of
doing a thing. Pass one `(caption, steps)` pair per column, the steps written
as in `flow`; `none` leaves a column without a caption. `gap` sets the space
between columns.

#demo(```typst
#import "/utils/diagram.typ": flows, n

#flows(
  ([STATIC SITE], (n[Request], [CDN], n([HTML file], tone: "accent"))),
  ([SERVER-RENDERED], (
    n[Request],
    [app server],
    n[Template],
    [query],
    n([Database], tone: "dark"),
  )),
)
```)

= Diagram

`diagram` places nodes on a grid. `node` takes an id, a `(column, row)`
position and its text; `edge` joins two ids, with an optional `label` and
`dashed: true`. `col` and `row` on `diagram` set the grid spacing.

#demo(```typst
#import "/utils/diagram.typ": diagram, node, edge

#diagram(
  node("repo", (0, 0), [Repo]),
  node("ci", (1, 0), [CI], tone: "accent"),
  node("pages", (2, 0), [Pages], tone: "dark"),
  node("log", (1, 1), [Build log], tone: "muted"),
  edge("repo", "ci", label: [push]),
  edge("ci", "pages"),
  edge("ci", "log", dashed: true),
)
```)

An edge between two nodes is a straight line unless `route` bends it:
`"ortho"` runs vertical, horizontal, vertical, and `"hvh"` horizontal,
vertical, horizontal. `arrow: false` drops the head, and `label-side`
(`"above"`, `"below"`, `"left"` or `"right"`) moves the label off a line it
would sit on. An end written as `"id.east"` (or `north`, `south`, `west`)
picks the side the edge leaves or enters by. `note` writes free text at a
grid position. `num`, `width` and `align` work on `node` as on `n`.

#demo(```typst
#import "/utils/diagram.typ": diagram, node, edge, note

#diagram(
  col: 130,
  row: 64,
  node("cfg", (0, 0), [`tola.toml`], tone: "ghost"),
  node("src", (1, 0), [Source], num: [01]),
  node("pages", (0, 1), [Pages], sub: [`content/`]),
  node("assets", (2, 1), [Assets], sub: [`assets/`]),
  node("site", (1, 2), [Site], num: [02], tone: "dark"),
  node("cdn", (2, 3), [CDN], tone: "muted"),
  note((1, 1), [+]),
  edge("cfg", "src", arrow: false, dashed: true),
  edge("src", "pages", route: "ortho"),
  edge("src", "assets", route: "ortho", label: [copy], label-side: "above"),
  edge("pages", "site", route: "ortho"),
  edge("assets", "site", route: "ortho"),
  edge("site.east", "cdn.west", route: "hvh", label: [deploy], label-side: "right"),
)
```)

= Timeline

`timeline` takes one dictionary per release: its `version`, the `items` it
brought, and optionally a `note` and `major: true` to make it stand out.
`spacing` sets the gap between releases.

#demo(```typst
#import "/utils/diagram.typ": timeline

#timeline(
  (version: [0.1], items: ([First layout],)),
  (version: [1.0], items: ([Search], [Night theme]), note: [RELEASE], major: true),
  (version: [1.1], items: ([Series navigation],)),
)
```)

= Quick reference

Tones for `n` and `node`: `plain` (the default), `accent`, `dark`, `muted`
and `ghost`.

```typst
flow(..steps, dir: "ttb", uniform: true)
flows(..columns, gap: 40)   // each column: (caption, (steps))
n(body, sub: none, num: none, tone: "plain", width: auto, align: left)
divider(above, below)

diagram(..elems, col: 150, row: 58)
node(id, (col, row), body, sub: none, num: none, tone: "plain",
  width: auto, align: left)
edge(from, to, label: none, route: "straight", arrow: true,
  dashed: false, label-side: auto)
note((col, row), body, anchor: "center")

timeline(..entries, spacing: 14)   // each entry: (version:, items:, note:, major:)
```

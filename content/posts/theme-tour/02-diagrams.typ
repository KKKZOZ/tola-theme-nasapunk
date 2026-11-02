#import "@tola/source:0.0.0": tola-meta
#import "/utils/diagram.typ": diagram, divider, edge, flow, n, node, timeline
#import "/utils/ui.typ": demo

#tola-meta((
  title: "[Tour 02] Diagrams and Timelines",
  date: "2025-07-04",
  summary: "Part two of a sample series: diagrams and timelines from utils/diagram.typ.",
  tags: ("example", "series", "diagram"),
  series: "Theme Tour",
))

#let demo = demo.with(scope: (
  diagram: diagram, divider: divider, edge: edge, flow: flow, n: n, node: node, timeline: timeline,
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

= Timeline

`timeline` takes one dictionary per release: its `version`, the `items` it
brought, and optionally a `note` and `major: true` to make it stand out.

#demo(```typst
#import "/utils/diagram.typ": timeline

#timeline(
  (version: [0.1], items: ([First layout],)),
  (version: [1.0], items: ([Search], [Night theme]), note: [RELEASE], major: true),
  (version: [1.1], items: ([Series navigation],)),
)
```)

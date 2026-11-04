// Every colour of the theme, by day and by night: the one place to change
// them. The page stylesheet, Typst drawings (html.frame, cetz, diagrams) and
// the social preview image all read them from here.
// Import: #import "/templates/colors.typ": colors, palette, colors-css
//
// `layout.head` writes `colors-css` into every page: each entry becomes a
// CSS custom property, `--ink`, `--tint-info`, ..., which
// assets/styles/site.css uses. Drawings use the day values (`palette`);
// `colors-css` also maps each day value found in inline SVG to its property,
// so a drawing follows the day / night switch without a dark version.

/// Name -> (day, night), or a single colour for both themes.
///
/// Inline SVG carries its colours as hex `fill` / `stroke` attributes, so a
/// day value maps back to one name only: the first entry with it wins
/// (`bar` draws as `ink`). Colours with transparency, and those that do not
/// change at night, are not mapped.
#let colors = (
  // Page
  paper: (rgb("#ffffff"), rgb("#15191b")),
  ink: (rgb("#222a2d"), rgb("#dde2dc")),
  orange: (rgb("#cb4b22"), rgb("#ec6e42")),
  muted: (rgb("#65716f"), rgb("#919c99")),
  rule: (rgb("#c5c9be"), rgb("#3b4447")),
  panel: (rgb("#e6e7dd"), rgb("#20282b")),
  blue: (rgb("#286379"), rgb("#7db4c8")),
  emphasis: (rgb("#b44020"), rgb("#f2875b")),
  success: (rgb("#35665b"), rgb("#79b8a8")),
  hint-emphasis: (rgb("#326d65"), rgb("#7fc2b6")),
  warning: (rgb("#8a5b13"), rgb("#d9a24c")),
  danger: (rgb("#a73434"), rgb("#e57373")),
  hairline: (rgb("#b7c5c5"), rgb("#3f4b4d")),
  tint: (rgb("#fcf0e7"), rgb("#3a2419")),
  code-bg: (rgb("#f0f3f2"), rgb("#232b2e")),
  pre-bg: (rgb("#f5f7f6"), rgb("#1b2225")),
  cell-line: (rgb("#d6deda"), rgb("#2f393c")),
  cell-key: (rgb("#edf1ef"), rgb("#1f272a")),
  cell-key-alt: (rgb("#e5ebe8"), rgb("#252e31")),
  shadow: (rgb(34, 42, 45, 12%), rgb(0, 0, 0, 50%)),

  // Ink bars (series head, table header, search bar, targeted channel):
  // dark in both themes, lifted off the page at night, with the text and
  // highlights set on them.
  bar: (rgb("#222a2d"), rgb("#303b3f")),
  on-bar: (rgb("#ffffff"), rgb("#e8ebe4")),
  dark-strong: rgb("#ffb17c"),
  dark-emph: rgb("#9fd4dc"),

  // Callout backgrounds (`callout` in utils/ui.typ), one per kind.
  tint-note: (rgb("#fcf2ec"), rgb("#2a1d17")),
  tint-info: (rgb("#edf4f7"), rgb("#172429")),
  tint-warning: (rgb("#fcf5e5"), rgb("#2a2416")),
  tint-success: (rgb("#edf4ef"), rgb("#172520")),
  tint-danger: (rgb("#faeeee"), rgb("#2c1a1a")),

  // The livery: five stacked bands (`.rail`, the social preview image).
  band-1: rgb("#b84636"),
  band-2: rgb("#de783c"),
  band-3: rgb("#e3b65a"),
  band-4: rgb("#719c98"),
  band-5: rgb("#355b70"),

  // Drawings only (`c` in utils/figure.typ, utils/diagram.typ): connector
  // lines, greys and the pale tints of the strong tones.
  line: (rgb("#7d8987"), rgb("#84908e")),
  grey1: (rgb("#ecefee"), rgb("#232b2e")),
  grey2: (rgb("#c9d0ce"), rgb("#4a5457")),
  blue1: (rgb("#e1ecef"), rgb("#1a2c33")),
  blue2: (rgb("#a3c3ce"), rgb("#3e6676")),
  orange1: (rgb("#fbece3"), rgb("#3a2419")),
  orange2: (rgb("#ebb39b"), rgb("#7a4630")),
  teal1: (rgb("#dceae6"), rgb("#1a2c28")),
  teal2: (rgb("#95bfb6"), rgb("#3d6b62")),
  accent-line: (rgb("#debba6"), rgb("#6e4a38")),
  accent-sub: (rgb("#6b4a3c"), rgb("#d4a58f")),
)

/// Other day values drawings carry, by the name they map to: Typst's default
/// black text.
#let aliases = (ink: (rgb("#000000"),))

/// The day value of every colour, for Typst drawings.
#let palette = colors.pairs().map(((name, value)) => (name, if type(value) == array { value.first() } else { value })).to-dict()

/// The stylesheet `layout.head` writes into every page: the custom
/// properties, then the inline SVG mapping.
#let colors-css = {
  let value(v) = if type(v) == array { "light-dark(" + v.first().to-hex() + "," + v.last().to-hex() + ")" } else { v.to-hex() }
  let props = colors.pairs().map(((name, v)) => "--" + name + ":" + value(v) + ";").join()

  // hex -> name, the first entry with that day value winning.
  let mapped = (:)
  for (name, v) in colors.pairs() {
    if type(v) != array or v.first() == v.last() { continue }
    let hex = v.first().to-hex()
    if hex.len() == 7 and hex not in mapped { mapped.insert(hex, name) }
  }
  for (name, extra) in aliases.pairs() {
    for c in extra { mapped.insert(c.to-hex(), name) }
  }
  let rules = mapped.pairs().map(((hex, name)) => {
    for attr in ("fill", "stroke") { "svg [" + attr + "=\"" + hex + "\"]{" + attr + ":var(--" + name + ")}" }
  })
  ":root{" + props + "}" + rules.join()
}

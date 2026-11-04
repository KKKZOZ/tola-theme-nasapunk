#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout, demo, gallery, hint, img, related, xref
#import "/utils/mitex.typ": mi, mitex

#tola-meta((
  title: "[Tour 04] Style Reference",
  date: "2026-10-18",
  summary: "Every element the template styles, on one page.",
  tags: ("example", "series"),
  series: "Theme Tour",
))

#let demo = demo.with(scope: (
  callout: callout, gallery: gallery, hint: hint, img: img, related: related, xref: xref,
  mi: mi, mitex: mitex,
))

Each element below is shown as the Typst you write, then as what it renders.
Copy a source block with its button and paste it into a post to start from.

= Typography

Body text is IBM Plex Mono; headings are Rajdhani. *Strong text* takes the
emphasis color, _emphasis_ goes blue, and the two together turn teal however
they are nested.

#demo(```typst
*Strong text*, _emphasis_, and bold italic either way round:
*_strong then emph_* and _*emph then strong*_.
Links look like #link("https://typst.app")[this], inline code like `tola serve`.
```)

Headings are `=` for a section and `==` for a subsection; sections are
numbered and listed in the table of contents.

```typst
= Section
== Subsection
```

== Lists

`-` starts a bullet, `+` a numbered item. Indent a line to nest it.

#demo(```typst
- Prefer flexible neurons already selected by another token.
- Keep must-keep neurons fixed.

+ Collect per-token masks.
+ Align flexible slots.
+ Take the union.
```)

== Math

Write formulas in LaTeX with `mi` (inline) and `mitex` (display) from
`utils/mitex.typ`. Inline math sits on the baseline, and display math is
centered:

#demo(```typst
#import "/utils/mitex.typ": mi, mitex

Inline #mi(`a^2 + b^2 = c^2`) sits on the baseline.

#mitex(`\sum_{i=1}^n \lvert m_i \rvert \geq \left| \bigcup_{i=1}^n m_i \right|`)
```)

#callout(kind: "info", title: [WRITE MATH WITH MI / MITEX])[Select text
around a formula and copy, and the formula comes out as LaTeX: `$...$`
inline, `$$...$$` display. Written with `mi` or `mitex`, it is your LaTeX
exactly as typed. Typst's own math such as $sum_(i=1)^n x_i$ copies too, but
its source is gone by the time the page is built, so the theme rebuilds
equivalent LaTeX from the formula (`\sum_{i=1}^n x_i`): same maths, not
necessarily the same text. A formula with parts LaTeX has no counterpart
for copies as `\text{[unsupported formula]}`, and a tip says which parts.
#xref("05-math") has examples of both.]

= Blocks

== Callouts

`callout` boxes a short message. `kind` picks the colour and status label:
`note` (the default), `info`, `warning`, `success` or `danger`. `title`
replaces the label.

#demo(```typst
#import "/utils/ui.typ": callout

#callout[Callouts default to *note*.]
#callout(kind: "info")[Neutral context with _emphasis_.]
#callout(kind: "warning")[Check the cache before trusting latency numbers.]
#callout(kind: "success", title: [BUILD PASSED])[Custom titles keep the code tag.]
#callout(kind: "danger")[Do not mutate the shared mask in place.]
```)

== Hints

`hint` is an open annotation beside the text rather than a boxed panel.

#demo(```typst
#import "/utils/ui.typ": hint

#hint[An open engineering annotation: *key term* and _aside_ in mono italic.]
```)

== Quotes and code

#demo(````typst
#quote(block: true)[A plain blockquote for citations.]

```python
def union(masks):
    return set().union(*masks)
```
````)

= Links Between Posts

Plain Typst links work with any site path; relative ones also survive a
`base-path`. To link a post by its title, use `xref` with a permalink or the
last segment of one; `body` overrides the text. Tola checks these links at
build time, and `xref` fails loudly if the post is missing.

#demo(```typst
#import "/utils/ui.typ": xref

A relative link to #link("../../getting-started/")[the getting-started guide],
a post by its title: #xref("03-cetz-figures"),
and with other text: #xref("03-cetz-figures", body: [this post]).
```)

`related` closes a post with cards for others, by the same names:

#demo(```typst
#import "/utils/ui.typ": related

#related("03-cetz-figures", "getting-started")
```)

= Images

Put files under `assets/images/` and reference them site-absolute. `img`
emits a real `<img>` tag; Typst's own `image()` would inline the file as base64.
A PNG or JPEG is served as WebP at a few widths (`srcset`), with its size
reserved on the page so nothing jumps as it loads; SVG and GIF are linked as
they are.

`img` and `gallery` are figures: each is numbered with the page's other
figures, a caption or not, and a label after it lets the text point at it.
The label below is cited as `@fig-telemetry`, which renders as
@fig-telemetry; the link jumps to `#fig-telemetry`. Typst only uses a label
as the anchor when it is a valid HTML id, so write `<fig-x>` rather than
`<fig:x>`, which still links but as `#loc-3`.

#demo(```typst
#import "/utils/ui.typ": img

#img(
  "/assets/images/telemetry.png",
  alt: "Three decaying telemetry curves on a dark grid",
  caption: [Full column width with a caption.],
) <fig-telemetry>
```)

`width` makes a figure narrower and centers it:

#demo(```typst
#img("/assets/images/telemetry.png", alt: "Telemetry curves", width: "55%",
  caption: [`width: "55%"` centers a smaller figure.])
```)

`gallery` places images side by side. Each is a path, or a
`(path, label)` pair to label it:

#demo(```typst
#import "/utils/ui.typ": gallery

#gallery(
  columns: 2,
  caption: [`gallery` places images side by side, with optional per-image labels.],
  ("/assets/images/telemetry.png", "Channel A"),
  ("/assets/images/telemetry.png", "Channel B"),
)
```)

`bleed: true` lets a figure reach past the text column on wide screens:

#demo(```typst
#img("/assets/images/telemetry.png", alt: "Telemetry curves", bleed: true,
  caption: [`bleed: true` extends past the text column on wide screens.])
```)

Plain `#figure(...)` (a CeTZ drawing, code) is numbered and captioned the
same way, and `numbering: none` on any of them leaves it unnumbered:

```typst
#figure(cetz.canvas(...), caption: [...]) <fig-y>
#img("/assets/images/logo.png", numbering: none)   // no number
As @fig-x and @fig-y show, ...
```

= Table

Tables are numbered on their own count, with the caption above. Put a table
in a `figure` to give it a caption, and label the figure to cite it, as
@tab-strategies is: Typst cannot reference a bare table.

#demo(```typst
#figure(
  table(
    columns: 3,
    table.header[Strategy][Neurons][Note],
    [Independent], [4], [Each token picks freely],
    [Aligned], [3], [Shares flexible slots],
    [Oracle], [2], [_Lower bound_],
  ),
  caption: [Neurons each routing strategy needs.],
) <tab-strategies>
```)

A bare `#table(...)` gets its number with no caption:

#demo(```typst
#table(
  columns: 2,
  table.header[Channel][Rate],
  [A], [1 Hz],
  [B], [10 Hz],
)
```)

To drop the number too, wrap it as `#figure(numbering: none, table(...))`.

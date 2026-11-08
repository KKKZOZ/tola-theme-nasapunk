// Social preview images: 1200 × 630 PNGs that link previews show when a
// page is shared (`social-image: auto` in config.typ). The site's card is
// drawn from its title, description, author and address, so it follows
// tola.toml; each post's from its title, summary, document number, date and
// tags. site.typ emits the site's, post.typ each post's.
// Import: #import "/templates/social.typ": social-card, post-card

#import "@tola/site:0.0.0": site
#import "/templates/base.typ": body-font, palette, title-font
#import "/config.typ": social-image
#import "/templates/layout.typ": author, orbital-glyph, social-output

/// The livery bands (templates/colors.typ), top to bottom.
#let bands = range(1, 6).map(i => palette.at("band-" + str(i)))

/// Five stacked bands, each `stripe` tall, as the `.rail` class.
#let rail(width, stripe) = stack(..bands.map(c => rect(width: width, height: stripe, fill: c, stroke: none)))

/// Small uppercase mono annotation, as the `.label` class.
#let label(body, fill: palette.muted) = text(font: body-font, size: 8.5pt, weight: 500, tracking: .1em, fill: fill, upper(body))

/// "example.com/blog": the site's address without the scheme, or `none`.
#let host = if site.url != none { site.url.replace(regex("^https?://"), "").trim("/", at: end) }

/// Width of the text beside the orbital mark.
#let text-width = 330pt

/// `s`, or as much of it as `render` sets in `lines` lines, cut short with
/// "…". Needs `context`.
#let clamp(s, render, lines) = {
  let chars = s.clusters()
  // Line height is measured in the text's own script. Mixed fonts (CJK text,
  // a Latin "…") make lines a little taller, so the bar sits halfway between
  // `lines` and `lines + 1` lines.
  let block-of(n) = measure(render(((chars.at(0, default: "x"),) * n).join("\n"))).height
  let bar = (block-of(lines) + block-of(lines + 1)) / 2
  let fits(s) = measure(render(s)).height < bar
  if fits(s) { return s }
  // The most characters that fit with the ellipsis, by bisection, then back
  // to a word boundary if the cut splits a Latin word.
  let cut(n) = {
    let head = chars.slice(0, n).join(default: "")
    if chars.at(n, default: " ").match(regex("[\p{Latin}\p{N}]")) != none {
      head = head.replace(regex("\s+[\p{Latin}\p{N}'-]+$"), "")
    }
    head.trim() + "…"
  }
  let (lo, hi) = (0, chars.len())
  while hi - lo > 1 {
    let mid = calc.div-euclid(lo + hi, 2)
    if fits(cut(mid)) { lo = mid } else { hi = mid }
  }
  cut(lo)
}

/// A 600 × 315pt card, which exports at 2 px/pt: 1200 × 630, the size Open
/// Graph and most link previews ask for. `eyebrow` is the orange label over
/// the title; the title is set at `size.at(0)`, shrunk to as little as
/// `size.at(1)` so it fits one line, and wraps to at most `title-lines`.
/// Title and body share four lines, the body getting at least one.
#let card(output, eyebrow: none, title: "", body: "", size: (56pt, 34pt), title-lines: 2, foot: (none, none)) = document(output, format: "png")[
  #set page(width: 600pt, height: 315pt, margin: (x: 40pt, top: 50pt, bottom: 26pt), fill: palette.paper)
  #set text(font: body-font, fill: palette.ink)
  // Spacing is set with `v` below: the default `1.2em` would scale with the title.
  #set par(spacing: 0pt)
  #set block(spacing: 0pt)

  #place(top + left, dx: -40pt, dy: -50pt, rail(600pt, 2pt))
  #place(right + horizon, dx: 4pt, dy: -12pt, scale(140%, reflow: true, orbital-glyph))

  // A fixed height, clipped, so a long title or description never pushes
  // the card onto a second page (which fails the build).
  #block(width: text-width, height: 205pt, clip: true, {
    if eyebrow != none { label(eyebrow, fill: palette.orange); v(18pt) }
    context {
      let (largest, smallest) = size
      let width = measure(text(font: title-font, size: largest, weight: 700, title)).width
      let size = calc.max(smallest, calc.min(largest, largest * (text-width / width)))
      let set-title(s) = block(width: text-width, {
        set par(leading: .35em)
        text(font: title-font, size: size, weight: 700, s)
      })
      let shown = clamp(title, set-title, title-lines)
      // n lines are n line heights plus n - 1 leadings.
      let (one, lead) = (measure(set-title("x")).height, .35 * size)
      let lines = int(calc.round((measure(set-title(shown)).height + lead) / (one + lead)))
      set-title(shown)
      v(18pt)
      rail(48pt, 1.2pt)
      v(20pt)

      let set-body(s) = block(width: text-width, {
        set par(leading: .9em)
        text(size: 12pt, fill: palette.muted, s)
      })
      if body not in (none, "") { set-body(clamp(body, set-body, calc.max(1, 4 - lines))) }
    }
  })

  // The site footer: a hairline led out in blue and two bands, then labels.
  #v(1fr)
  #grid(
    columns: (1fr, 30pt, 10pt, 4pt),
    column-gutter: 2pt,
    align: horizon,
    line(length: 100%, stroke: .4pt + palette.rule),
    ..(palette.blue, bands.at(3), bands.at(2)).map(c => rect(width: 100%, height: 1pt, fill: c, stroke: none)),
  )
  #v(9pt)
  #grid(
    columns: (1fr, auto),
    column-gutter: 12pt,
    ..foot.map(it => if it != none { label(it) } else { [] }),
  )
]

/// The site's card, for every page but posts.
#let social-card() = if social-image == auto {
  card(
    social-output,
    eyebrow: host,
    title: site.title,
    body: site.description,
    title-lines: 3,
    foot: (if author != none { "by " + author }, "Typst / Tola"),
  )
}

/// A post's card, written to `output`: its document number and date over
/// the title, the summary under it, and the site and up to three tags at
/// the foot. `doc` and `date` are strings or `none`.
#let post-card(output, title: "", summary: none, doc: none, date: none, tags: ()) = card(
  output,
  eyebrow: (doc, date).filter(x => x != none).join(" / "),
  title: title,
  body: summary,
  size: (40pt, 30pt),
  title-lines: 3,
  foot: (
    if host != none { host } else { site.title },
    if tags.len() > 0 { tags.slice(0, calc.min(3, tags.len())).join(" / ") } else { "Typst / Tola" },
  ),
)

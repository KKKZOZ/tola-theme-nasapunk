// The social preview image: a 1200 × 630 PNG that link previews show when a
// page is shared (`social-image: auto` in config.typ). It is drawn from the
// site's title, description, author and address, so it follows tola.toml.
// site.typ emits it.
// Import: #import "/templates/social.typ": social-card

#import "@tola/site:0.0.0": site
#import "/templates/base.typ": body-font, palette, title-font
#import "/templates/config.typ": social-image
#import "/templates/layout.typ": author, orbital-glyph, social-output

/// Day values of the livery `--band-*` tokens in assets/styles/site.css.
#let bands = (rgb("#B84636"), rgb("#DE783C"), rgb("#E3B65A"), rgb("#719C98"), rgb("#355B70"))

/// Five stacked bands, each `stripe` tall, as the `.rail` class.
#let rail(width, stripe) = stack(..bands.map(c => rect(width: width, height: stripe, fill: c, stroke: none)))

/// Small uppercase mono annotation, as the `.label` class.
#let label(body, fill: palette.muted) = text(font: body-font, size: 8.5pt, weight: 500, tracking: .1em, fill: fill, upper(body))

/// "example.com/blog": the site's address without the scheme, or `none`.
#let host = if site.url != none { site.url.replace(regex("^https?://"), "").trim("/", at: end) }

/// 600 × 315pt pages export at 2 px/pt: 1200 × 630, the size Open Graph and
/// most link previews ask for.
#let social-card() = if social-image == auto {
  document(social-output, format: "png")[
    #set page(width: 600pt, height: 315pt, margin: (x: 40pt, top: 50pt, bottom: 26pt), fill: palette.paper)
    #set text(font: body-font, fill: palette.ink)
    // Spacing is set with `v` below: the default `1.2em` would scale with the title.
    #set par(spacing: 0pt)
    #set block(spacing: 0pt)

    #place(top + left, dx: -40pt, dy: -50pt, rail(600pt, 2pt))
    #place(right + horizon, dx: 4pt, dy: -12pt, scale(140%, reflow: true, orbital-glyph))

    // A fixed height, clipped, so a long title or description never pushes
    // the card onto a second page (which fails the build).
    #block(width: 330pt, height: 205pt, clip: true, {
      if host != none { label(host, fill: palette.orange); v(18pt) }
      context {
        let title(s, size) = block(width: 330pt, {
          set par(leading: .35em)
          text(font: title-font, size: size, weight: 700, s)
        })
        // 56pt, shrunk to as little as 34pt so a long title fits one line.
        let width = measure(text(font: title-font, size: 56pt, weight: 700, site.title)).width
        let size = calc.max(34pt, calc.min(56pt, 56pt * (330pt / width)))
        // n lines are n line heights plus n - 1 leadings.
        let (one, lead) = (measure(title("x", size)).height, .35 * size)
        let title-lines = int(calc.round((measure(title(site.title, size)).height + lead) / (one + lead)))
        title(site.title, size)
        v(18pt)
        rail(48pt, 1.2pt)
        v(20pt)

        // Four lines between title and description: a longer description is
        // cut short with "…". Line height is measured in its own script.
        let body(s) = block(width: 330pt, {
          set par(leading: .9em)
          text(size: 12pt, fill: palette.muted, s)
        })
        let chars = site.description.clusters()
        let lines = calc.max(1, 4 - title-lines)
        let fits(s) = measure(body(s)).height <= measure(body(((chars.at(0, default: "x"),) * lines).join("\n"))).height
        if fits(site.description) {
          body(site.description)
        } else {
          // The most characters that fit with the ellipsis, by bisection,
          // then back to a word boundary if the cut splits a Latin word.
          let cut(n) = {
            let head = chars.slice(0, n).join()
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
          body(cut(lo))
        }
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
      if author != none { label("by " + author) },
      label("Typst / Tola"),
    )
  ]
}

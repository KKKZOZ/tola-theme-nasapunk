// Site chrome: header, footer, home hero, post / archive / tag listings.
// Import: #import "/templates/layout.typ" as layout

#import "/templates/base.typ": palette
#import "/templates/config.typ": content-width, head-extra, mission, social-image, social-links
#import "/templates/feeds.typ": feed-output, has-feed
#import "/templates/util.typ": cls, social-tags
#import "@tola/web:0.0.0": head-metadata
#import "@tola/address:0.0.0": asset-url, output-url
#import "@tola/document:0.0.0": current-document
#import "@tola/site:0.0.0": site

// ============================================================================
// Configuration
// ============================================================================

/// Header navigation: (label, output file).
#let nav-items = (
  ("Home", "index.html"),
  ("Archive", "archive/index.html"),
  ("Tags", "tags/index.html"),
  ("Search", "search/index.html"),
  ("About", "about/index.html"),
)

/// The site author's name, from `[site] authors`.
#let author = site.authors.at(0, default: (name: none)).name

// ============================================================================
// Data
// ============================================================================

#let fmt-date(d) = {
  if d == none { none } else if type(d) == datetime { d.display("[year]-[month]-[day]") } else { str(d).split("T").at(0) }
}

/// Anchor id for a tag on the /tags/ page.
#let tag-slug(t) = lower(t).replace(regex("[^\p{L}\p{N}]+"), "-").trim("-")
#let tag-href(t) = output-url("tags/index.html") + "#" + tag-slug(t)

/// (tag, posts) pairs, most used first, then alphabetical. Spellings that
/// share a slug ("LLM-Serving", "llm-serving") are one tag, named by the
/// spelling most posts use.
#let posts-by-tag(posts) = {
  let groups = (:)
  for p in posts {
    for t in p.at("tags", default: ()) {
      let group = groups.at(tag-slug(t), default: (names: (:), posts: ()))
      group.names.insert(t, group.names.at(t, default: 0) + 1)
      group.posts.push(p)
      groups.insert(tag-slug(t), group)
    }
  }
  groups.values()
    .map(group => (group.names.pairs().sorted(key: ((t, n)) => -n).first().first(), group.posts))
    .sorted(key: ((t, ps)) => (-ps.len(), lower(t)))
}

/// (year, posts) pairs, newest year first; `posts` must already be sorted.
#let posts-by-year(posts) = {
  let groups = ()
  for p in posts {
    let year = fmt-date(p.date).slice(0, 4)
    if groups.len() > 0 and groups.at(-1).at(0) == year {
      groups.at(-1).at(1).push(p)
    } else {
      groups.push((year, (p,)))
    }
  }
  groups
}

// ============================================================================
// Primitives
// ============================================================================

/// Muted aerospace livery: five stacked bands.
#let rail(class: "") = html.div(class: cls("rail", class), role: "presentation")

/// Small uppercase mono annotation. A block element, so Typst never wraps it
/// in a <p> next to sibling blocks.
#let label(body, class: "") = html.div(class: cls("label", class), body)

/// N empty spans for the CSS-drawn rules (footer / hint).
#let spans(n) = for _ in range(n) { html.span() }

/// Vector orbital mark, drawn for a light page: inline SVG on the home page
/// (`orbital-mark`), and on the social preview image (social.typ).
#let orbital-glyph = box(width: 120pt, height: 120pt)[
  #place(center + horizon, circle(width: 106pt, stroke: .6pt + palette.rule))
  #place(center + horizon, circle(width: 73pt, stroke: .6pt + palette.rule))
  #place(center + horizon, circle(width: 36pt, stroke: 1pt + palette.ink))
  #place(center + horizon, line(length: 120pt, stroke: .5pt + palette.rule))
  #place(center + horizon, rotate(-35deg, line(length: 131pt, stroke: 2.5pt + palette.orange)))
  #place(top + right, dx: -16pt, dy: 19pt, circle(width: 8pt, fill: palette.ink, stroke: none))
]

#let orbital-mark() = html.frame(orbital-glyph)

/// The orbital mark after loss of signal (404): dashed rings, a trajectory
/// that breaks off past the core, and a hollow craft.
#let lost-signal-mark() = html.frame(box(width: 120pt, height: 120pt)[
  #let dashed(paint, w) = (paint: paint, thickness: w, dash: (3pt, 3pt))
  #place(center + horizon, circle(width: 106pt, stroke: dashed(palette.rule, .6pt)))
  #place(center + horizon, circle(width: 73pt, stroke: dashed(palette.rule, .6pt)))
  #place(center + horizon, circle(width: 36pt, stroke: 1pt + palette.ink))
  #place(center + horizon, line(length: 120pt, stroke: .5pt + palette.rule))
  // Same -35° course as orbital-mark, drawn as two segments with a gap.
  #place(line(start: (6.3pt, 97.6pt), end: (66.6pt, 55.4pt), stroke: (paint: palette.orange, thickness: 2.5pt, cap: "round")))
  #place(line(start: (79pt, 46.7pt), end: (113.7pt, 22.4pt), stroke: dashed(palette.orange, 1.2pt)))
  #place(top + right, dx: -16pt, dy: 19pt, circle(width: 8pt, stroke: 1pt + palette.ink))
])

// ============================================================================
// <head>
// ============================================================================

/// Scripts every page loads, deferred, in this order.
#let scripts = ("theme.js", "reading.js", "copy.js", "footnotes.js", "zoom.js")

/// Narrowest window, in CSS pixels, where a post's table of contents floats
/// beside the column: the column, then on each side the 48px gap, the 220px
/// TOC (assets/styles/toc-float.css) and 12px to spare.
#let toc-float-at = content-width + 2 * (48 + 220 + 12)

/// The preview image social.typ draws for `social-image: auto`.
#let social-output = "social.png"

/// `social-image` as an `(url:, alt:)` dictionary with an absolute URL, or
/// `none` when there is none or the site has no origin.
#let share-image = if social-image == none or site.url == none {
  none
} else if social-image == auto {
  let alt = if site.description != "" { site.title + ": " + site.description } else { site.title }
  (url: output-url(social-output, origin: site.origin), alt: alt)
} else {
  let src = social-image.src
  (url: if src.starts-with("/") { site.origin + asset-url(src) } else { src }, alt: social-image.alt)
}

/// Shared <head> content for the page written to `output`. Typst only adds
/// charset/viewport when it builds the <head> itself, so templates with a
/// custom head must emit them. `description` falls back to the site's;
/// `article` is a post's `(published:, updated:, tags:)`.
#let head(output, title, description: none, article: none) = html.head({
  // A blocking script keeps the first paint until the stylesheet is in,
  // avoiding a flash of unstyled content. It also settles the theme before
  // that paint: the reader's pick (theme.js), else the system setting.
  html.script("(()=>{let t;try{t=localStorage.getItem(\"theme\")}catch(e){}document.documentElement.dataset.theme=t===\"dark\"||t===\"light\"?t:matchMedia(\"(prefers-color-scheme: dark)\").matches?\"dark\":\"light\"})()")
  let description = if description != none { description } else { site.description }
  head-metadata(
    site,
    title: if title != none { title + " | " + site.title } else { site.title },
    description: description,
  ).join()
  html.meta(name: "color-scheme", content: "light dark")
  if author != none { html.meta(name: "author", content: author) }
  html.link(rel: "icon", type: "image/svg+xml", href: asset-url("/assets/favicon.svg"))
  html.link(rel: "stylesheet", href: asset-url("/assets/styles/site.css"))
  html.style(":root { --measure: " + str(content-width) + "px; }")
  html.link(
    rel: "stylesheet",
    href: asset-url("/assets/styles/toc-float.css"),
    media: "(min-width: " + str(toc-float-at) + "px)",
  )
  for name in scripts { html.script("", src: asset-url("/assets/scripts/" + name), defer: true) }
  // Lets feed readers find the feed from any page.
  if has-feed {
    html.link(rel: "alternate", type: "application/rss+xml", title: site.title, href: output-url(feed-output))
  }
  // Link previews when the page is shared.
  social-tags(
    title: if title != none { title } else { site.title },
    url: if site.url != none { output-url(output, origin: site.origin) },
    description: description,
    site-name: site.title,
    image: share-image,
    article: if article != none { article + (author: author) },
  )
  head-extra
})

// ============================================================================
// Header / Footer
// ============================================================================
// Children are joined in code mode (markup inserts whitespace spans), and
// siblings of block elements are blocks too: Typst wraps a lone inline
// element (<a>, <span>) next to a block in <p>.

#let site-header() = html.header(class: "site-header", {
  rail()
  html.div(class: "wrap header-bar", {
    html.div(class: "brand", html.a(href: output-url("index.html"), {
      html.div(class: "brand-title", site.title)
      if mission != none { label(mission, class: "accent") }
    }))
    html.nav(class: "site-nav", context {
      let here = current-document().output
      for (name, output) in nav-items {
        // Home stays lit on the home page's following pages (page/2/, ...).
        let active = here == output or (output == "index.html" and here.starts-with("page/"))
        html.a(class: cls("label", if active { "is-active" }), href: output-url(output), name)
      }
      // Day / night switch, wired up by assets/scripts/theme.js.
      html.elem("button", attrs: (type: "button", class: "theme-toggle", aria-label: "Dark theme", aria-pressed: "false"))
    })
  })
  html.div(class: "wrap", html.div(class: "divider"))
})

#let site-footer() = html.footer(class: "site-footer wrap", {
  html.div(class: "footer-rule", role: "presentation", spans(4))
  html.div(class: "footer-row", {
    label[© #author]
    html.div(class: "footer-links", {
      // html.elem: the typed html.a rejects rel="me".
      for (name, url) in social-links { html.elem("a", attrs: (class: "label", href: url, rel: "me"), name) }
      if has-feed { html.a(class: "label", href: output-url(feed-output), "RSS") }
      label[Typst / Tola]
    })
  })
})

/// Page skeleton shared by all templates.
#let shell(body, main-class: "") = {
  // The first Tab stop: past the header, straight to the page's text.
  html.div(class: "skip", html.a(class: "skip-link", href: "#main", "Skip to content"))
  site-header()
  html.main(id: "main", class: cls("wrap", main-class), body)
  site-footer()
}

// ============================================================================
// Home
// ============================================================================

/// Light intro under the header: the site description as a lead line, then
/// author / meta, with the orbital mark on the right. The header already
/// carries the title, so it is not repeated.
#let hero(subtitle: none, meta: none) = html.section(class: "hero", {
  html.div({
    if subtitle != none { html.p(class: "hero-lead", subtitle) }
    html.div(class: "hero-meta", {
      label("by " + author)
      if meta != none { label(meta, class: "accent") }
    })
  })
  html.div(class: "hero-mark", role: "presentation", orbital-mark())
})

/// Tag chips. `linked: false` inside another <a>, where links cannot nest.
#let tag-list(tags, linked: true) = if tags.len() > 0 {
  html.div(class: "tags", for t in tags {
    if linked { html.a(class: "tag", href: tag-href(t), t) } else { html.span(class: "tag", t) }
  })
}

/// Numbered post listing, counting down from `start` (default: the count).
#let post-list(posts, start: auto) = html.ol(class: "entry-list", for (i, p) in posts.enumerate() {
  let n = if start == auto { posts.len() } else { start } - i
  let code = "/" + if n < 10 { "0" } + str(n)
  html.li(class: "entry-item", html.a(href: p.permalink, {
    label(code, class: "entry-code")
    html.div(class: "entry-body", {
      label(fmt-date(p.at("date", default: none)), class: "accent")
      html.h3(class: "entry-title", p.title)
      if p.at("summary", default: none) != none { html.p(class: "entry-summary", p.summary) }
      tag-list(p.at("tags", default: ()), linked: false)
    })
  }))
})

/// Compact one-line rows: date + title, and `code(p)` (a document number)
/// on the right when given.
#let index-rows(posts, date-format: d => fmt-date(d), code: none) = html.ol(class: cls("index-list", if code != none { "has-code" }), for p in posts {
  html.li(html.a(href: p.permalink, {
    label(date-format(p.date))
    html.div(class: "index-title", p.title)
    if code != none { label(code(p), class: "index-code") }
  }))
})

/// Section heading with an orange count tag on the right. A `code` ("CH-01")
/// sets it as a channel bar: code, uppercase mono title, count and `back`, a
/// link up to the index.
#let index-heading(title, count, id: none, code: none, back: none) = {
  let attrs = if id != none { (id: id) } else { (:) }
  html.h2(class: cls("index-heading", if code != none { "is-code" }), ..attrs, {
    if code != none { html.span(class: "index-heading-code", code) }
    html.span(class: "index-heading-title", title)
    html.span(class: "label accent", str(count))
    if back != none { html.a(class: "index-heading-back label", href: back, aria-label: "Back to the channel index", "↑") }
  })
}

/// Page title block shared by archive / tags / about.
#let page-head(title, sub: none) = html.header(class: "post-head", {
  if sub != none { label(sub, class: "accent") }
  html.h1(class: "post-title", title)
  rail(class: "rail-short")
})

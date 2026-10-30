// Blog post layout. A post source declares its metadata and holds the text:
// ```typst
// #import "@tola/source:0.0.0": tola-meta
// #tola-meta((title: "...", date: "2026-10-19", summary: "...", tags: ("a", "b")))
// ```
// site.typ renders it with `post(page, posts)`.

#import "@tola/address:0.0.0": slugify
#import "/templates/base.typ": doc-query, endnotes
#import "/templates/config.typ": doc-prefix
#import "/templates/data.typ": series-parts
#import "/templates/layout.typ" as layout: fmt-date, label, series-href
#import "/templates/page.typ": html-document
#import "/templates/util.typ": to-string

// ============================================================================
// Document control block
// ============================================================================
// The NASA tech-report cover table under the post title: document number,
// date, GMT day-of-year and estimated reading time.

#let pad(n, width) = "0" * calc.max(0, width - str(n).len()) + str(n)

/// "TN-003": publication order, oldest first. Pages outside the post
/// list (lab/) are not numbered.
#let doc-number(posts, output) = {
  let i = posts.position(p => p.output == output)
  if i != none { doc-prefix + "-" + pad(posts.len() - i, 3) }
}

/// "2026:292": year and day of year, as in mission logs.
#let gmt-day(d) = if d == none { none } else { str(d.year()) + ":" + pad(d.ordinal(), 3) }

/// Minutes to read, as Hugo estimates it: ~500 units a minute in CJK-led
/// text (where English words are mostly embedded terms), else ~220 words.
#let read-minutes(body) = {
  let text = to-string(body)
  let cjk = text.matches(regex("\p{Han}|\p{Hiragana}|\p{Katakana}|\p{Hangul}")).len()
  let words = text.matches(regex("[\p{Latin}\p{N}_]+")).len()
  let minutes = if cjk > words { (cjk + words) / 500 } else { words / 220 + cjk / 500 }
  calc.max(1, calc.ceil(minutes))
}

#let doc-control(m, body, posts, output) = html.elem("dl", attrs: (class: "doc-control"), {
  // (label, value, Pagefind metadata key for search results)
  let cells = (
    ("Doc no.", doc-number(posts, output), "doc"),
    ("Date", fmt-date(m.date), "date"),
    ..if m.updated != none { (("Revised", fmt-date(m.updated), none),) },
    ("GMT day", gmt-day(m.date), none),
    ("Est. read", str(read-minutes(body)) + " min", none),
  )
  for (key, value, meta) in cells {
    html.div(class: "doc-cell", {
      html.elem("dt", attrs: (class: "label"), key)
      let attrs = if meta != none { (data-pagefind-meta: meta) } else { (:) }
      html.elem("dd", attrs: attrs, if value != none { value } else { "—" })
    })
  }
})

#let post-nav(posts, output) = {
  // `posts` is newest first.
  let i = posts.position(p => p.output == output)
  if i == none { return }
  let (newer, older) = (if i > 0 { posts.at(i - 1) }, posts.at(i + 1, default: none))
  if older == none and newer == none { return }
  html.nav(class: "post-nav", {
    if older != none {
      html.a(class: "prev", href: older.permalink, { label[← Previous]; html.div(class: "post-nav-title", older.title) })
    }
    if newer != none {
      html.a(class: "next", href: newer.permalink, { label[Next →]; html.div(class: "post-nav-title", newer.title) })
    }
  })
}

// ============================================================================
// Series
// ============================================================================
// A post joins a series with `series: "Name"` (or `("Name",)`, as Hugo
// front matter writes it; only the first entry counts). Parts run in the
// order of data.typ `series-parts`: `part` numbers, then dates. The head
// links to the series on /series/.

/// "[DDIA 02] Chapter 2 ..." -> "Chapter 2 ...": the series box names the series.
#let part-title(p) = p.title.replace(regex("^\[[^\]]*\]\s*"), "")

#let series-box(name, posts, output) = {
  if name == none { return }
  let parts = series-parts(posts, name)
  let i = parts.position(p => p.output == output)
  if i == none or parts.len() < 2 { return }
  let (older, newer) = (if i > 0 { parts.at(i - 1) }, parts.at(i + 1, default: none))
  html.nav(class: "series", aria-label: "Series", {
    html.div(class: "series-head", {
      html.a(href: series-href(name), "Series / " + name)
      html.span("Part " + str(i + 1) + " of " + str(parts.len()))
    })
    html.div(class: "series-nav", {
      if older != none { html.a(class: "prev", href: older.permalink, "← " + part-title(older)) } else { html.span() }
      if newer != none { html.a(class: "next", href: newer.permalink, part-title(newer) + " →") }
    })
    html.elem("details", attrs: (class: "series-all"), {
      html.elem("summary", attrs: (class: "label"), "All parts")
      html.ol(for (j, p) in parts.enumerate() {
        let n = pad(j + 1, 2)
        if j == i {
          html.li(class: "is-current", { html.span(class: "series-num", n); html.span(part-title(p)) })
        } else {
          html.li(html.a(href: p.permalink, { html.span(class: "series-num", n); html.span(part-title(p)) }))
        }
      })
    })
  })
}

// ============================================================================
// Table of contents
// ============================================================================
// Headings get `id = slug of their text`, the ASCII slug Tola 0.7 wrote, so
// existing section links keep working; ToC links use the same slug. Headings
// whose slugs repeat get "-2", "-3", ... in document order.

/// Deepest heading level listed in the ToC (1 = `=`, 2 = `==`, ...).
#let toc-depth = 2

/// Slug of a heading's text.
#let heading-slug(text) = {
  // slugify rejects text with nothing left to slug, such as a lone symbol.
  if text.match(regex("[\p{L}\p{N}]")) == none { "section" } else { slugify(text, mode: "ascii") }
}

/// Fragment id for the `n`th heading with this slug.
#let with-suffix(slug, n) = if n <= 1 { slug } else { slug + "-" + str(n) }

/// Section number shared by headings and the ToC. Level 1: "01", "02", ...;
/// level 2: "1.1", "1.2", ... restarting per section. Needs `context`.
#let heading-num(h) = {
  let (n, m) = (0, 0)
  // `before` is inclusive, so the count includes this heading.
  for x in doc-query(selector(heading).before(h.location())) {
    if x.level == 1 { n += 1; m = 0 } else if x.level == 2 { m += 1 }
  }
  if h.level == 1 { if n < 10 { "0" } + str(n) } else if n > 0 { str(n) + "." + str(m) } else { str(m) }
}

#let heading-with-id(it) = context {
  let slug = heading-slug(to-string(it.body))
  let n = doc-query(selector(heading).before(it.location())).filter(h => heading-slug(to-string(h.body)) == slug).len()
  let tag = "h" + str(calc.min(it.level + 1, 6))
  let id = with-suffix(slug, n)
  html.elem(tag, attrs: (id: id), {
    if it.level <= toc-depth { html.span(class: "heading-num", heading-num(it)) }
    it.body
    // Revealed on hover; copy.js copies the section URL on click.
    html.elem("a", attrs: (class: "heading-anchor", href: "#" + id, aria-label: "Copy link to this section", data-pagefind-ignore: ""), "#")
  })
}

/// Floating on wide screens, a box above the text on narrow ones (see CSS).
#let toc() = context {
  let seen = (:)
  let entries = ()
  for h in doc-query(heading) {
    let slug = heading-slug(to-string(h.body))
    seen.insert(slug, seen.at(slug, default: 0) + 1)
    if h.level <= toc-depth { entries.push((h, with-suffix(slug, seen.at(slug)))) }
  }
  if entries.len() < 2 { return }
  html.aside(class: "toc", html.nav(class: "toc-inner", aria-label: "Table of contents", {
    label("Contents", class: "accent")
    html.ol(class: "toc-list", for (h, id) in entries {
      html.li(class: "toc-l" + str(h.level), html.a(href: "#" + id, {
        html.span(class: "toc-num", heading-num(h))
        // A hand-written footnote ref in a heading carries an id; the heading
        // keeps it, the ToC copy drops it.
        show html.elem.where(tag: "sup"): none
        html.span(h.body)
      }))
    })
  }))
}

/// Write one post. `page` is its `(source:, output:)` record; `posts` the
/// published post records, newest first.
#let post(page, posts) = {
  let m = page.source.meta
  let body = include page.source.file
  let article = (published: m.date, updated: m.updated, tags: m.tags)
  html-document(page.output, m.title, description: m.summary, article: article, posts: posts, {
    show heading: heading-with-id
    layout.shell(html.article(class: "post", {
      // Fixed reading-progress bar at the top of the viewport (reading.js).
      html.div(class: "read-progress", role: "presentation")
      html.header(class: "post-head", {
        html.div(class: "post-meta", {
          label(class: "accent")[Post / #fmt-date(m.date)]
          label(layout.author)
        })
        html.elem("h1", attrs: (class: "post-title", data-pagefind-meta: "title"), m.title)
        if m.summary != none { html.p(class: "post-summary", m.summary) }
        layout.tag-list(m.tags)
        doc-control(m, body, posts, page.output)
        series-box(if m.series != none { m.series.at(0, default: none) }, posts, page.output)
      })
      html.div(class: "post-body", {
        toc()
        // Only the text is indexed for search (Pagefind); title, date and doc
        // number are tagged as result metadata where they are shown above. The
        // id selects the text for the RSS feed (feeds.typ).
        html.elem("div", attrs: (class: "prose", id: "post-content", data-pagefind-body: ""), { body; endnotes() })
      })
      post-nav(posts, page.output)
    }))
  })
}

// Pages built from the post list rather than written as sources: home,
// archive, tags, series, search and the 404 page. site.typ emits each one.
// Import: #import "/templates/pages.typ" as pages

#import "@tola/address:0.0.0": asset-url, output-url
#import "@tola/site:0.0.0": site
#import "/templates/data.typ": series-parts
#import "/templates/layout.typ" as layout
#import "/templates/page.typ": page
#import "/templates/post.typ": doc-number, pad, part-title

/// Posts per home page; the rest go on /page/2/, /page/3/, ...
#let shown = 10

/// The home page's n-th page (from 1): index.html, then page/n/index.html.
#let home-output(n) = if n == 1 { "index.html" } else { "page/" + str(n) + "/index.html" }

/// Previous / next links and "Page n / count" under a home page's list.
#let pager(n, count) = if count > 1 {
  html.nav(class: "pager", aria-label: "Pages", {
    if n > 1 { html.a(class: "label prev", href: output-url(home-output(n - 1)), "← Previous") }
    layout.label("Page " + str(n) + " / " + str(count), class: "pager-count")
    if n < count { html.a(class: "label next", href: output-url(home-output(n + 1)), "Next →") }
  })
}

/// The home page and its following pages, `shown` posts each, by `weight`.
/// The sort is stable, so equal weights stay newest first; other listings
/// and the feed keep date order. The hero is on the first page only.
#let home(posts) = {
  let listed = posts.sorted(key: p => p.weight)
  let count = calc.max(1, calc.ceil(listed.len() / shown))
  for n in range(1, count + 1) {
    let first = (n - 1) * shown
    page(home-output(n), if n > 1 { "Page " + str(n) }, posts: posts, {
      if n == 1 { layout.hero(subtitle: site.description, meta: str(posts.len()) + " posts") }
      html.div(class: "section-label", layout.label(class: "accent")[Recent posts])
      layout.post-list(listed.slice(first, calc.min(listed.len(), first + shown)), start: listed.len() - first)
      pager(n, count)
    })
  }
}

/// Four-cell summary under a listing's title, styled as the post's document
/// control block: (label, value) pairs.
#let index-stats(cells) = html.elem("dl", attrs: (class: "doc-control index-stats"), for (key, value) in cells {
  html.div(class: "doc-cell", {
    html.elem("dt", attrs: (class: "label"), key)
    html.elem("dd", value)
  })
})

/// Segments in the tallest bar of the archive's density chart.
#let density-steps = 8

/// The archive as a flight log: a summary, a posts-per-month density chart
/// (one row per year), then the years, numbered in mission time from the
/// first post's year (T+00). Pointing at a month of the chart reads out its
/// posts under the chart, and a click lands on them in the year's list.
#let archive(posts) = page("archive/index.html", "Archive", posts: posts, {
  let years = layout.posts-by-year(posts)
  let month-of(p) = int(layout.fmt-date(p.date).slice(5, 7))
  let by-month = years.map(((year, items)) => range(1, 13).map(m => items.filter(p => month-of(p) == m)))
  let counts = by-month.map(months => months.map(ps => ps.len()))
  let peak = calc.max(1, ..counts.flatten())
  let month-id(year, m) = "m" + year + "-" + pad(m, 2)
  let posts-word(n) = str(n) + if n == 1 { " post" } else { " posts" }
  let first-year = int(years.at(-1, default: ("0", ())).at(0))
  let mission-time(year) = "T+" + pad(int(year) - first-year, 2)
  layout.page-head("Archive", sub: "All posts")
  index-stats((
    ("Entries", str(posts.len())),
    ("Span", if years.len() > 0 { years.at(-1).at(0) + "–" + years.at(0).at(0) } else { "—" }),
    ("First entry", if posts.len() > 0 { layout.fmt-date(posts.at(-1).date) } else { "—" }),
    ("Latest entry", if posts.len() > 0 { layout.fmt-date(posts.at(0).date) } else { "—" }),
  ))
  html.div(class: "section-label", id: "log", layout.label(class: "accent")[Density / posts per month])
  html.div(class: "density has-readout", {
    for ((year, items), months) in years.zip(by-month) {
      html.div(class: "density-row", {
        html.a(class: "density-year", href: "#y" + year, year)
        html.span(class: "density-bars", for (m, ps) in months.enumerate() {
          let n = ps.len()
          let steps = if n == 0 { 0 } else { calc.max(1, calc.round(n / peak * density-steps)) }
          let style = "--steps: " + str(steps)
          if n == 0 {
            html.span(class: "density-bar", style: style)
          } else {
            let label = year + "-" + pad(m + 1, 2) + " / " + posts-word(n)
            html.a(class: "density-bar", style: style, href: "#" + month-id(year, m + 1), aria-label: label, {
              html.span(class: "readout", { html.span(class: "accent", label); " " + ps.map(p => p.title).join(" / ") })
            })
          }
        })
        html.span(class: "density-count", str(items.len()))
      })
    }
    html.div(class: "density-row density-axis", role: "presentation", {
      html.span()
      html.span(class: "density-bars", for m in "JFMAMJJASOND".clusters() { html.span(m) })
      html.span()
    })
    html.div(class: "readout-idle", "Point at a month to read its log")
  })
  for (year, items) in years {
    html.section(class: "index-section", {
      layout.index-heading(year, items.len(), id: "y" + year, code: mission-time(year), back: "#log")
      // The newest post of each month anchors the chart's link to it.
      let first-of-month(p, i) = if i == 0 or month-of(items.at(i - 1)) != month-of(p) { month-id(year, month-of(p)) }
      layout.index-rows(items, date-format: d => layout.fmt-date(d).slice(5), code: p => doc-number(posts, p.output), id: first-of-month)
    })
  }
})

/// Tags as a telemetry channel index: a traffic summary, a directory with a
/// level meter per tag (scaled to the busiest one), then one section per
/// tag, its posts listed with their document numbers. Pointing at a channel
/// dims the others and reads it out under the directory.
#let tags(posts) = page("tags/index.html", "Tags", posts: posts, {
  let groups = layout.posts-by-tag(posts)
  let channel(i) = "CH-" + pad(i + 1, 2)
  let peak = groups.at(0, default: (none, ())).at(1).len()
  layout.page-head("Tags", sub: "Channel index")
  index-stats((
    ("Channels", str(groups.len())),
    ("Links", str(groups.map(((t, ps)) => ps.len()).sum(default: 0))),
    ("Posts", str(posts.len())),
    ("Peak", if peak > 0 { groups.at(0).at(0) } else { "—" }),
  ))
  html.div(class: "section-label", id: "channels", layout.label(class: "accent")[Directory / by traffic])
  html.div(class: "channel-board has-readout", {
    html.ol(class: "channel-grid", for (i, (tag, items)) in groups.enumerate() {
      let level = str(calc.round(items.len() / peak * 100, digits: 1)) + "%"
      let n = items.len()
      html.li(html.a(class: "channel", href: layout.tag-href(tag), style: "--level: " + level, {
        html.span(class: "channel-code", channel(i))
        html.span(class: "channel-name", tag)
        html.span(class: "channel-count", str(n))
        html.span(class: "readout", {
          html.span(class: "accent", channel(i) + " / " + tag + " / " + str(n) + if n == 1 { " post" } else { " posts" })
          " Latest: " + items.at(0).title
        })
      }))
    })
    html.div(class: "readout-idle", "Point at a channel to read it")
  })
  for (i, (tag, items)) in groups.enumerate() {
    html.section(class: "index-section", {
      layout.index-heading(tag, items.len(), id: layout.tag-slug(tag), code: channel(i), back: "#channels")
      layout.index-rows(items, code: p => doc-number(posts, p.output))
    })
  }
})

/// Series as a mission manifest: a summary, a directory with one card per
/// program, then one section per series, its parts in order (data.typ
/// `series-parts`). The program flown most recently comes first. A card's
/// track has one segment per part: pointing at one reads out the part on the
/// card's last line, and a click opens it.
#let series(posts) = page("series/index.html", "Series", posts: posts, {
  let programs = posts
    .map(p => p.series)
    .filter(s => s != none)
    .dedup()
    .map(name => {
      let parts = series-parts(posts, name)
      (name: name, parts: parts, dates: parts.map(p => p.date).sorted())
    })
    .sorted(key: s => s.dates.last())
    .rev()
  let code(i) = "PRG-" + pad(i + 1, 2)
  let staged = programs.map(s => s.parts.len()).sum(default: 0)
  let longest = programs.sorted(key: s => s.parts.len()).at(-1, default: none)
  let month(d) = layout.fmt-date(d).slice(0, 7)
  layout.page-head("Series", sub: "Mission programs")
  index-stats((
    ("Programs", str(programs.len())),
    ("Stages", str(staged)),
    ("Coverage", str(staged) + " / " + str(posts.len()) + " posts"),
    ("Longest", if longest != none { longest.name } else { "—" }),
  ))
  html.div(class: "section-label", id: "programs", layout.label(class: "accent")[Directory / by last flight])
  if programs.len() == 0 {
    html.p(class: "index-empty", "No series yet: posts that share a series name are listed here.")
  }
  html.ol(class: "program-grid", for (i, s) in programs.enumerate() {
    let n = s.parts.len()
    // Children are blocks or all inline: Typst wraps a lone inline element
    // beside a block in <p>.
    html.li(html.div(class: "program has-readout", {
      html.div(class: "program-head", {
        html.span(class: "program-code", code(i))
        html.span(class: "program-count", str(n) + if n == 1 { " stage" } else { " stages" })
      })
      html.div(class: "program-name", html.a(href: "#" + layout.tag-slug(s.name), s.name))
      html.div(class: "program-track", for (j, p) in s.parts.enumerate() {
        let stage = "Stage " + pad(j + 1, 2)
        html.a(href: p.permalink, aria-label: stage + ": " + part-title(p), {
          html.span(class: "readout", { html.span(class: "accent", stage); " " + part-title(p) })
        })
      })
      html.div(class: "program-foot readout-idle", {
        html.span({
          let (first, last) = (month(s.dates.first()), month(s.dates.last()))
          if first == last { first } else { first + " → " + last }
        })
        html.a(href: s.parts.first().permalink, "Start →")
      })
    }))
  })
  for (i, s) in programs.enumerate() {
    html.section(class: "index-section", {
      layout.index-heading(s.name, s.parts.len(), id: layout.tag-slug(s.name), code: code(i), back: "#programs")
      html.ol(class: "index-list has-code", for (j, p) in s.parts.enumerate() {
        html.li(html.a(href: p.permalink, {
          layout.label("Stage " + pad(j + 1, 2), class: "accent")
          html.div(class: "index-title", part-title(p))
          layout.label(layout.fmt-date(p.date), class: "index-code")
        }))
      })
    })
  }
})

#let search() = page("search/index.html", "Search", {
  layout.page-head("Search", sub: "Query / archive")
  // Wired up by assets/scripts/search.js against the Pagefind index, which
  // the `search` build hook writes to /pagefind/.
  html.div(class: "search", {
    html.elem("label", attrs: (class: "search-bar", "for": "search-input"), {
      html.span(class: "search-prompt", aria-hidden: true, "Query >")
      html.elem("input", attrs: (
        id: "search-input",
        type: "search",
        placeholder: "keywords, 关键词 …",
        autocomplete: "off",
        spellcheck: "false",
        aria-label: "Search posts",
      ))
    })
    html.div(id: "search-status", class: "label search-status", aria-live: "polite", "Standing by")
    html.ol(id: "search-results", class: "search-results")
  })
  html.elem("script", attrs: (type: "module", src: asset-url("/assets/scripts/search.js")))
})

/// The "Loss of signal" page, served for addresses the site does not publish.
#let not-found() = page("404.html", "Signal Lost", {
  html.section(class: "lost", {
    html.div({
      layout.label("Error 404 / LOS", class: "accent")
      html.h1(class: "post-title", "Loss of signal")
      html.p(class: "lost-text", "This page is not on any known trajectory. It may have moved, or never launched.")
      html.div(class: "lost-telemetry", {
        layout.label({ "Requested "; html.span(id: "lost-path", "—") })
        layout.label("Status: no carrier")
      })
      html.a(class: "lost-home label", href: output-url("index.html"), "← Signal lost · Return to base")
    })
    html.div(class: "lost-mark", role: "presentation", layout.lost-signal-mark())
  })
  // Echo the requested path; the page itself is static.
  html.script("document.getElementById('lost-path').textContent = location.pathname;")
})

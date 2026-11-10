// Small helpers shared by the templates.
// Import: #import "/templates/util.typ": cls, social-tags, theme-asset

#import "@tola/module:0.0.0": get-module
#import "@tola/web:0.0.0": canonical, open-graph, plain-text, twitter-card

/// URL of one of the theme's own files, by its path under assets/:
/// `theme-asset("styles/site.css")`. Published under
/// /_tola-modules/<alias>/, with the site's mount and cache-busting suffix.
#let theme-asset(name) = {
  let urls = get-module().assets.urls
  assert(name in urls, message: "no theme asset " + name + " (assets disabled or renamed?)")
  urls.at(name)
}

/// Join CSS classes, skipping `none` and empty strings; arrays are flattened.
/// `cls("base", if active { "active" })` gives "base active" or "base".
#let cls(..args) = {
  let flatten(items) = {
    let result = ()
    for item in items {
      if type(item) == array { result += flatten(item) } else { result.push(item) }
    }
    result
  }
  let raw = flatten(args.pos()).filter(x => x != none and x != "").map(x => str(x)).join(" ")
  raw.split(" ").filter(x => x != "").join(" ")
}

#let _og-meta(prop, content) = {
  if content == none or content == "" { return none }
  let c = if type(content) == datetime { content.display("[year]-[month]-[day]") } else { plain-text(content) }
  // article: entries use `property`, which html.meta does not take.
  html.elem("meta", attrs: (property: prop, content: c))
}

/// Canonical link, Open Graph and Twitter card entries for a page. `url` is
/// the page's absolute address, or `none` when the site has no origin: only
/// the Twitter card is written then, as the others need one. `image` is an
/// `(url:, alt:)` dictionary or `none`; `article`, a post's `(published:,
/// updated:, author:, tags:)`, makes the page an Open Graph article.
#let social-tags(
  title: none,
  url: none,
  description: none,
  site-name: none,
  image: none,
  article: none,
) = {
  let description = if description not in (none, "") { plain-text(description) }
  if url != none {
    canonical(url).join()
    open-graph(
      title: title,
      url: url,
      description: description,
      kind: if article != none { "article" } else { "website" },
      site-name: site-name,
      images: if image != none { (image,) },
    ).join()
  }
  if article != none {
    _og-meta("article:published_time", article.published)
    _og-meta("article:modified_time", article.updated)
    _og-meta("article:author", article.author)
    for tag in article.tags { _og-meta("article:tag", tag) }
  }
  twitter-card(
    card: if image != none { "summary_large_image" } else { "summary" },
    title: title,
    description: description,
    image: image,
  ).join()
}

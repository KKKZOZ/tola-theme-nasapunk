// NASApunk's public Typst API, imported as `@tola-modules/<alias>:0.0.0`
// (the alias the site gives the module in tola.toml, "nasapunk" in the
// examples):
//
// - `render-site`: the site program. The module's own site.typ calls it
//   with no arguments; a site that needs `head-extra` or
//   `post-footer-extra` sets `[build] entry = "site.typ"` and calls it there.
// - In-article components, for content sources: callouts, folds, terms,
//   images, columns, cross-post links, diagrams, CeTZ figures, math.
//
// Sources under content/ declare their metadata with `tola-meta`
// (@tola/source) and hold only their text; posts/ sources get the post
// layout, others the plain page layout. lab/ holds test and reference pages:
// post layout, but they stay out of the post list.

#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": all-sources
#import "/config.typ": extras, search as search-enabled
#import "/templates/data.typ": draft-index, draft-urls, post-records, select-pages
#import "/templates/feeds.typ": feeds
#import "/templates/page.typ": page
#import "/templates/pages.typ" as pages
#import "/templates/post.typ": post
#import "/templates/social.typ": social-card

// Components for content sources.
#import "/utils/ui.typ": callout, cols, demo, fold, gallery, hint, img, related, term, xref
#import "/utils/mitex.typ": mi, mitex
#import "/utils/diagram.typ": diagram, divider, edge, flow, flows, n, node, note, timeline
#import "/utils/figure.typ": arrow, box-swatch, c, cells, curve-arrow, legend, line-swatch, pill, seg, tag, txt
#import "/utils/cetz.typ" as cetz
#import "/templates/colors.typ": palette
#import "/templates/layout.typ": page-head
#import "/templates/latex.typ": to-latex

/// Emit every page of the site.
///
/// - head-extra: content added to every page's <head>, such as an analytics
///   script; `none` for nothing.
/// - post-footer-extra: content placed at the end of every post, after the
///   links to the previous and next posts: comments, a newsletter form. A
///   function that takes the post and returns content (or `none` to skip
///   that post), or `none`. The post is a dictionary: `title`, `output`
///   ("posts/x/index.html"), `permalink` (its path), `url` (its absolute
///   address, `none` without an origin) and `meta` (its tola-meta fields).
#let render-site(head-extra: none, post-footer-extra: none) = {
  set text(
    lang: site.language.lang,
    script: site.language.script,
    region: site.language.region,
  )

  extras.update((head-extra: head-extra, post-footer-extra: post-footer-extra))

  let sources = all-sources()
  let selected = select-pages(sources)
  let posts = post-records(selected)

  draft-index.update(draft-urls(sources))

  for entry in selected {
    if entry.source.id.starts-with("posts/") or entry.source.id.starts-with("lab/") {
      post(entry, posts)
    } else {
      page(entry.output, entry.source.meta.title, include entry.source.file, posts: posts)
    }
  }

  pages.home(posts)
  pages.archive(posts)
  pages.tags(posts)
  pages.series(posts)
  if search-enabled { pages.search() }
  pages.not-found()

  feeds(selected, posts)
  social-card()
}

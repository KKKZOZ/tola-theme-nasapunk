// The site program: every page Tola publishes is emitted here.
//
// Sources under content/ declare their metadata with `tola-meta` and hold
// only their text; posts/ sources get the post layout, others the plain page
// layout. lab/ holds test and reference pages: post layout, but they stay out
// of the post list. Listing pages are built from the post records in
// templates/pages.typ; the RSS feed and sitemap in templates/feeds.typ.

#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": all-sources
#import "/templates/data.typ": draft-index, draft-urls, post-records, select-pages
#import "/templates/feeds.typ": feeds
#import "/templates/page.typ": page
#import "/templates/pages.typ" as pages
#import "/templates/post.typ": post
#import "/templates/social.typ": social-card

#set text(
  lang: site.language.lang,
  script: site.language.script,
  region: site.language.region,
)

#let selected = select-pages(all-sources())
#let posts = post-records(selected)

#draft-index.update(draft-urls(all-sources()))

#for entry in selected {
  if entry.source.id.starts-with("posts/") or entry.source.id.starts-with("lab/") {
    post(entry, posts)
  } else {
    page(entry.output, entry.source.meta.title, include entry.source.file, posts: posts)
  }
}

#pages.home(posts)
#pages.archive(posts)
#pages.tags(posts)
#pages.series(posts)
#pages.search()
#pages.not-found()

#feeds(selected, posts)
#social-card()

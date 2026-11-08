// The HTML document every page is written into, and the plain page layout.
// Import: #import "/templates/page.typ": html-document, page

#import "@tola/site:0.0.0": site
#import "/templates/base.typ": base, endnotes
#import "/templates/data.typ": post-index
#import "/templates/layout.typ" as layout

/// Write `body` to `output` as a complete page. `title: none` is the home
/// page; `description`, `article` and `image` go to the head (`layout.head`);
/// `posts` feeds `post-index` for helpers inside the body.
#let html-document(output, title, body, description: none, article: none, image: auto, posts: ()) = document(
  output,
  format: "html",
  title: if title != none { title } else { site.title },
)[
  #show: base
  #html.html(lang: site.language.tag)[
    #layout.head(output, title, description: description, article: article, image: image)
    #html.body({
      post-index.update(posts)
      body
    })
  ]
]

/// Plain page (home, about, archive, ...): site chrome around prose.
#let page(output, title, body, posts: ()) = html-document(
  output,
  title,
  layout.shell(html.div(class: "prose", { body; endnotes() })),
  posts: posts,
)

// Page metadata and the published post list.
// Import: #import "/templates/data.typ": select-pages, post-records, series-parts, post-index, draft-urls, draft-index, left-out-posts, left-out-index, left-out-note

#import "@tola/address:0.0.0": join-route, output-of, output-url, slugify
#import "@tola/schema:0.0.0": date, nullable, one-or-many, optional, schema
#import "@tola/source:0.0.0": parse-sources
#import "/config.typ": recent-posts, toc-depth

/// The fields a source may declare with `tola-meta`; unknown keys are errors.
#let page-schema = schema((
  title: str,
  date: optional(nullable(date), default: none),
  // Last substantial revision: shown on the post, and the sitemap's lastmod.
  updated: optional(nullable(date), default: none),
  summary: optional(nullable(str), default: none),
  // Preview image when the post is shared, in place of the one the
  // `social-image` option gives: a file the site publishes ("/assets/…") or a URL.
  image: optional(nullable(str), default: none),
  tags: optional(one-or-many(str), default: ()),
  // `series: "Name"` or `("Name",)`, as Hugo front matter writes it;
  // only the first entry counts.
  series: optional(nullable(one-or-many(str)), default: none),
  // Position in the series (`series-parts`): numbered parts first, in
  // number order, then the rest by date.
  part: optional(nullable(int), default: none),
  // Home page order, as Hugo's `weight`: lower first, ties newest first.
  // Posts without one, or with Hugo's "unset" 0, weigh 100, so `weight: 1`
  // pins a post to the top and `weight: 200` sinks it.
  weight: optional(int, default: 100),
  draft: optional(bool, default: false),
  // Deepest heading level numbered and listed in this post's table of
  // contents, in place of the `toc-depth` option (post.typ).
  toc-depth: optional(int, default: toc-depth),
))

/// A source's output file. Routes follow the file layout, each segment
/// slugged the way Tola 0.7 did, so URLs are stable.
#let output-for(source) = output-of(join-route(source.route-segments.map(segment => slugify(segment, mode: "ascii"))))

/// One `(source:, output:)` record per source that is not a draft.
#let _published(sources) = {
  // Every source is validated here, drafts included, before choosing which to publish.
  parse-sources(sources, page-schema)
    .filter(source => not source.meta.draft)
    .map(source => (source: source, output: output-for(source)))
}

/// The outputs of the posts the `recent-posts` option leaves out: every
/// dated post past the newest `recent-posts`, or none.
#let _left-out(pages) = {
  if recent-posts == none { return () }
  let posts = pages
    .filter(page => page.source.id.starts-with("posts/") and page.source.meta.date != none)
    .sorted(key: page => page.source.meta.date)
    .rev()
  posts.slice(calc.min(recent-posts, posts.len())).map(page => page.output)
}

/// One `(source:, output:)` record per published source.
#let select-pages(sources) = {
  let pages = _published(sources)
  let skipped = _left-out(pages)
  pages.filter(page => page.output not in skipped)
}

/// The URLs drafts will publish at. Links to them render as plain text until
/// the draft is published (see `site-link` in base.typ).
#let draft-urls(sources) = {
  parse-sources(sources, page-schema)
    .filter(source => source.meta.draft)
    .map(source => output-url(output-for(source)))
}

/// Dated pages under posts/, newest first, as flat records the templates
/// read: title, date, updated, summary, tags, series, part, weight,
/// permalink, output.
#let post-records(pages) = {
  pages
    .filter(page => page.source.id.starts-with("posts/") and page.source.meta.date != none)
    .map(page => {
      let m = page.source.meta
      (
        title: m.title,
        date: m.date,
        updated: m.updated,
        summary: m.summary,
        tags: m.tags,
        series: if m.series != none { m.series.at(0, default: none) },
        part: m.part,
        weight: if m.weight == 0 { 100 } else { m.weight },
        permalink: output-url(page.output),
        output: page.output,
      )
    })
    .sorted(key: post => post.date)
    .rev()
}

/// The posts the `recent-posts` option leaves out, as `post-records`; empty
/// when it is 0.
#let left-out-posts(sources) = {
  let pages = _published(sources)
  let skipped = _left-out(pages)
  post-records(pages.filter(page => page.output in skipped))
}

/// The tooltip of a link to a post left out of this build.
#let left-out-note = "Not built: this build keeps only the newest posts (recent-posts)"

/// The parts of the series `name`, in order: those with a `part` number by
/// it, then the rest oldest first; ties by date, then by title, so
/// "[DDIA 02]" precedes "[DDIA 03]".
#let series-parts(posts, name) = {
  posts
    .filter(p => p.series == name)
    .sorted(key: p => (if p.part == none { 1 } else { 0 }, if p.part == none { 0 } else { p.part }, p.date, p.title))
}

/// The post records, for helpers that run inside a source's body (`xref`,
/// `related`), which cannot receive arguments from the root. Every document
/// sets it first; read it in `context`.
#let post-index = state("nasapunk-post-index", ())

/// `draft-urls`, for the link rule in base.typ, which cannot receive
/// arguments from the root either. Set like `post-index`; read it in `context`.
#let draft-index = state("nasapunk-draft-index", ())

/// `left-out-posts`, for the link rule in base.typ and for `xref` and
/// `related`, which show a post left out as plain text. Set like
/// `draft-index`; read it in `context`.
#let left-out-index = state("nasapunk-left-out-index", ())

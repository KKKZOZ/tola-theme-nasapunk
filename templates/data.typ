// Page metadata and the published post list.
// Import: #import "/templates/data.typ": select-pages, post-records, series-parts, post-index, draft-urls, draft-index

#import "@tola/address:0.0.0": join-route, output-of, output-url, slugify
#import "@tola/schema:0.0.0": date, nullable, one-or-many, optional, schema
#import "@tola/source:0.0.0": parse-sources

/// The fields a source may declare with `tola-meta`; unknown keys are errors.
#let page-schema = schema((
  title: str,
  date: optional(nullable(date), default: none),
  // Last substantial revision: shown on the post, and the sitemap's lastmod.
  updated: optional(nullable(date), default: none),
  summary: optional(nullable(str), default: none),
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
))

/// A source's output file. Routes follow the file layout, each segment
/// slugged the way Tola 0.7 did, so URLs are stable.
#let output-for(source) = output-of(join-route(source.route-segments.map(segment => slugify(segment, mode: "ascii"))))

/// One `(source:, output:)` record per published source.
#let select-pages(sources) = {
  // Every source is validated here, drafts included, before choosing which to publish.
  parse-sources(sources, page-schema)
    .filter(source => not source.meta.draft)
    .map(source => (source: source, output: output-for(source)))
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

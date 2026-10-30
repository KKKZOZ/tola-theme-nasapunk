#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout, hint, xref

#tola-meta((
  title: "Getting Started with NASApunk",
  date: "2026-10-18",
  updated: "2026-10-25",
  summary: "Install the theme, set your site identity, and write the first post.",
  tags: ("guide", "theme"),
  weight: 1,
))

= Requirements

- #link("https://github.com/tola-rs/tola-ssg")[Tola] 0.8 or newer.
- Node.js, for the #link("https://pagefind.app")[Pagefind] search index. Run
  `npm install` once in the site directory.

```sh
npm install
tola dev       # live reload, search index skipped
tola build     # writes public/, search index included
```

= Site identity

Most values live in `tola.toml` under `[site]`: title, author, description
and language. Two values have no `[site]` key and live in
`templates/config.typ`:

```typst
#let doc-prefix = "TN"   // TN-001, TN-002, ... under each post title
#let mission = none      // e.g. "RESEARCH NOTES" next to the site title
```

Header links are set by `nav-items` in `templates/layout.typ`.

#hint[Set *origin* in `tola.toml` before you deploy: feeds and sitemaps need
the public address.]

= Writing a post

Every `.typ` file under `content/posts/` is a post. It declares its metadata
with `tola-meta` and holds only its text:

```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "Post title",
  date: "2026-10-18",
  updated: "2026-10-25",     // optional; last revision
  summary: "One line for the post list and the Open Graph card.",
  tags: ("systems", "notes"),
  series: "Theme Tour",   // optional
  weight: 1,                 // optional; home page order, default 100
  draft: false,              // optional; drafts are not published
))

= First section

Text.
```

Unknown keys fail the build, so a typo in the metadata is caught early. The
URL follows the file path: `content/posts/foo/bar.typ` publishes at
`/posts/foo/bar/`.

#callout(kind: "info")[Files under `content/lab/` get the post layout but stay
out of the post list. Use them for test pages. The
#link("../style-reference/")[style reference] shows every element the theme styles.]

= Components

`utils/ui.typ` holds the in-article components: `callout`, `hint`, `img`,
`gallery`, `xref` and `related`. `utils/diagram.typ` draws box-and-arrow
diagrams and timelines in the site palette; #xref("02-diagrams") shows both.
`utils/cetz.typ` is a drop-in `cetz` that renders to inline SVG, and
`utils/figure.typ` holds colours and helpers for detailed drawings:
#xref("figure-kit") goes through them, and #xref("cetz-figures") puts them to
work.

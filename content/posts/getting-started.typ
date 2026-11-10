#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/nasapunk:0.0.0": callout, hint, xref

#tola-meta((
  title: "Getting Started with NASApunk",
  date: "2026-10-18",
  updated: "2026-11-10",
  summary: "Install the theme, set your site identity, and write the first post.",
  tags: ("guide", "theme"),
  weight: 1,
))

= Requirements

- #link("https://github.com/tola-rs/tola-ssg")[Tola] 0.8.2 or newer.
- Node.js, for the #link("https://pagefind.app")[Pagefind] search index. Run
  `npm install` once in the site directory.

```sh
npm install
tola dev       # live reload, search index skipped
tola build     # writes public/, search index included
```

= Site identity

Everything lives in `tola.toml`. Title, author, description and language go
under `[site]`; the theme's own settings under `[modules.nasapunk.options]`,
among them:

```toml
[modules.nasapunk.options]
doc-prefix = "TN"          # TN-001, TN-002, ... under each post title
mission = "RESEARCH NOTES" # next to the site title; "" hides it
```

Header links, footer links, posts per page and the feed are set there too.
Every option, with its default, is listed in `theme/tola-module.toml`.
Settings that are Typst values, such as a comments block under each post,
are arguments of `render-site` in `site.typ`.

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
#link("../theme-tour/04-style-reference/")[style reference] shows every element the theme styles.]

= Components

Posts import the theme's components from `@tola-modules/nasapunk:0.0.0`:

```typst
#import "@tola-modules/nasapunk:0.0.0": callout, hint, xref
```

The in-article components are `callout`, `hint`, `fold`, `term`, `img`,
`gallery`, `cols`, `xref` and `related`. `flow`, `diagram` and `timeline`
draw box-and-arrow diagrams and timelines in the site palette;
#xref("02-diagrams") shows them. `cetz` is a drop-in CeTZ that renders to
inline SVG, and `c`, `txt`, `arrow` and their kin are colours and helpers for
detailed drawings; #xref("03-cetz-figures") puts them to work and goes
through them one by one.

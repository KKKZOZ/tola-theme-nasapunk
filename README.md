<div align="center">

<img src="assets/favicon.svg" width="84" alt="">

# NASApunk

**A NASApunk-style blog theme for [Tola](https://github.com/tola-rs/tola-ssg).**

Write posts in Typst. Figures, diagrams and math render as inline SVG in the theme colours, by day and by night.

[![Build](https://github.com/KKKZOZ/tola-theme-nasapunk/actions/workflows/build.yml/badge.svg)](https://github.com/KKKZOZ/tola-theme-nasapunk/actions/workflows/build.yml)
[![Tola](https://img.shields.io/badge/Tola-0.8%2B-cb4b22)](https://github.com/tola-rs/tola-ssg)
[![Typst](https://img.shields.io/badge/Typst-0.15-239dad)](https://typst.app)
[![License: MIT](https://img.shields.io/badge/license-MIT-286379)](LICENSE)

**English** · [简体中文](README.zh-CN.md)

**[Live demo](https://kkkzoz.github.io/tola-theme-nasapunk/)**

<br>

<img src="docs/screenshots/hero.png" alt="NASApunk home page, day and night themes split diagonally">

</div>

> [!NOTE]
> Need slides in the same style? The matching slide template is [touying-nasapunk](https://typst.app/universe/package/touying-nasapunk) on Typst Universe.

## Features

<table>
  <tr>
    <td width="33%" valign="top">
      <img src="docs/features/report.png" alt="Post header with document number and date"><br>
      <b>Post header</b><br>
      <sub>Document number, date, day of year and reading time on every post.</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/archive.png" alt="Archive page with a posts-per-month chart"><br>
      <b>Archive</b><br>
      <sub>Posts grouped by year, with a posts-per-month chart.</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/tags.png" alt="Tags page"><br>
      <b>Tags</b><br>
      <sub>Every tag with its post count and posts.</sub>
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <img src="docs/features/series.png" alt="Series navigation box"><br>
      <b>Series</b><br>
      <sub>Posts sharing a <code>series</code> name link up.</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/figures.png" alt="A CeTZ figure"><br>
      <b>Typst figures</b><br>
      <sub>CeTZ and diagrams as inline SVG, in theme colours.</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/callouts.png" alt="Callouts"><br>
      <b>Callouts</b><br>
      <sub>Five kinds, plus annotations.</sub>
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <img src="docs/features/toc.png" alt="Table of contents"><br>
      <b>Contents</b><br>
      <sub>Numbered headings and a ToC that follows scrolling.</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/search.png" alt="Search results"><br>
      <b>Search</b><br>
      <sub>Full-text search with Pagefind, CJK included.</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/lost.png" alt="404 page"><br>
      <b>404</b><br>
      <sub>A custom page for missing addresses.</sub>
    </td>
  </tr>
</table>

## Screenshots

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/post.png" alt="Post page"></td>
    <td width="50%"><img src="docs/screenshots/cetz-dark.png" alt="A CeTZ figure, night theme"></td>
  </tr>
  <tr>
    <td align="center">Post</td>
    <td align="center">A CeTZ figure, night theme</td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/components.png" alt="Callouts and code"></td>
    <td align="center">
      <img src="docs/screenshots/mobile-light.png" width="45%" alt="Home page on a phone">
      &nbsp;
      <img src="docs/screenshots/mobile-dark.png" width="45%" alt="Post page on a phone, night theme">
    </td>
  </tr>
  <tr>
    <td align="center">Callouts and code</td>
    <td align="center">On a phone, day and night</td>
  </tr>
</table>

## Quick start

You need [Tola](https://github.com/tola-rs/tola-ssg) 0.8 or newer and Node.js (for the search index).

```sh
# 1. Get the theme: click "Use this template" on GitHub, or
git clone https://github.com/KKKZOZ/tola-theme-nasapunk.git my-blog
cd my-blog

# 2. Install Tola (or download a binary from its release page)
cargo install --locked tola

# 3. Install Pagefind and start the dev server
npm install
tola dev
```

Open <http://127.0.0.1:5277>. `tola dev` rebuilds on save; `tola build` writes the finished site, search index included, to `public/`.

Then make it yours:

1. Set your title, name, description and language under `[site]` in `tola.toml`.
2. Set the document-number prefix in `templates/config.typ`.
3. Replace the example posts in `content/posts/` and edit `content/about.typ`.

## Configuration

| What | Where |
| --- | --- |
| Title, author, description, language | `tola.toml` → `[site]` |
| Public address (for the RSS feed, sitemap and link previews) | `tola.toml` → `origin` |
| Sub-path deployment, e.g. `/blog/` | `tola.toml` → `base-path` |
| Document-number prefix (`TN` → `TN-001`) | `templates/config.typ` → `doc-prefix` |
| Orange code next to the site title | `templates/config.typ` → `mission` |
| Footer links (GitHub, email, Mastodon, ...) | `templates/config.typ` → `social-links` |
| Preview image for shared links: drawn (`auto`), your own file, or none | `templates/config.typ` → `social-image` |
| Analytics or other `<head>` additions | `templates/config.typ` → `head-extra` |
| Header links | `templates/layout.typ` → `nav-items` |
| Posts per home page (older ones on `/page/2/`, `/page/3/`, …) | `templates/pages.typ` → `shown` |
| Heading levels in the table of contents | `templates/post.typ` → `toc-depth` |
| Posts in the RSS feed; full text or summaries | `templates/feeds.typ` → `feed-size`, `full-text` |
| Colours | tokens at the top of `assets/styles/site.css`, mirrored by `palette` in `templates/base.typ` |
| Search language | `scripts/search-index.mjs` → `forceLanguage` (see below) |

Search detects the language from `[site] language`. For a site written mostly in Chinese, set `forceLanguage` to `"zh"` in `scripts/search-index.mjs`.

## Writing posts

Every `.typ` file under `content/posts/` is a post, published at the URL its path suggests: `content/posts/notes/cache.typ` → `/posts/notes/cache/`.

```typst
#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout

#tola-meta((
  title: "Cache Coherence Notes",
  date: "2026-10-18",
  summary: "One line for the post list, search results and link previews.",
  tags: ("systems", "notes"),
  series: "Theme Tour",
))

= First section

#callout(kind: "warning")[Check the cache before trusting latency numbers.]
```

| Field | Type | Notes |
| --- | --- | --- |
| `title` | string | Required. |
| `date` | `"YYYY-MM-DD"` | Without a date, the file is published but left out of the post list. |
| `updated` | `"YYYY-MM-DD"` | Date of the last revision: shown under the title, and used by the sitemap and feed. |
| `summary` | string | Post list, search results, Open Graph. |
| `tags` | string or array | Shown as chips; collected on `/tags/`. |
| `weight` | integer | Home page order: lower comes first, posts with equal weight newest first. The default is 100 (0, which Hugo treats as unset, counts as 100 too), so `weight: 1` pins a post to the top and `weight: 200` sinks it. Other listings stay in date order. |
| `series` | string | Posts with the same name form a series, ordered by date. |
| `draft` | bool | Drafts are not published; links to them render as plain text. |

Files under `content/lab/` use the post layout but stay out of the post list. Open `/lab/style-reference/` for every element the theme styles.

## Components

| Module | Provides |
| --- | --- |
| `utils/ui.typ` | `callout`, `hint`, `img`, `gallery`, `xref`, `related` |
| `utils/diagram.typ` | `flow`, `diagram`, `timeline` |
| `utils/cetz.typ` | `cetz` that renders to inline SVG in HTML export |
| `utils/figure.typ` | Theme colours and helpers for detailed CeTZ figures: `pill`, `arrow`, `curve-arrow`, `cells`, `seg`, `legend`, ... |

```typst
#import "/utils/ui.typ": callout, xref
#import "/utils/diagram.typ": flow, n

#callout(kind: "success")[The build passed.]

#flow(n[Source], [compile], n([HTML], tone: "accent"))

See #xref("cetz-figures") for a full CeTZ example.
```

The example posts show each module in use: `content/posts/theme-tour/` for callouts, footnotes, flows and timelines, `content/posts/figure-kit.typ` for every helper in `utils/figure.typ` with its output and signature, and `content/posts/cetz-figures.typ` for complete CeTZ figures built with them.

## Deployment

`tola build` writes plain static files to `public/`, so any static host works.

For GitHub Pages, the repository ships `.github/workflows/deploy.yml`, which publishes the live demo. In your copy:

1. Set **Settings → Pages → Source** to **GitHub Actions**.
2. Delete the `if:` line in `deploy.yml`; it keeps template copies from deploying before they opt in.
3. Push to `main`.

The workflow asks GitHub for the site's address and passes it to `tola build`, so the same file works for a user site (`https://<user>.github.io/`) and a project site (`https://<user>.github.io/<repo>/`). A project site is served under `/<repo>/` and leaves your user site untouched. Links in your posts that start with `/` need that prefix too; relative links and `xref` work anywhere, and the build points out any link it misses.

## Project structure

```
├── site.typ              site program: emits every page
├── tola.toml             site settings
├── typst-fonts/          IBM Plex Mono and Rajdhani for figures
├── scripts/              search index build hook (Pagefind)
├── templates/            layouts, header and footer, listings
│   ├── config.typ        settings tola.toml has no key for
│   ├── feeds.typ         RSS feed, sitemap and robots.txt
│   └── social.typ        preview image for shared links
├── utils/                components for posts (see above)
├── assets/
│   ├── styles/site.css   all styles; colour tokens at the top
│   ├── scripts/          theme toggle, search, copy buttons, footnotes
│   └── webfonts/         IBM Plex Mono and Rajdhani, Latin subsets
├── content/
│   ├── posts/            example posts
│   ├── lab/              test pages, kept out of the post list
│   └── about.typ
└── .github/workflows/    build check and GitHub Pages deployment
```

## Fonts

Body text is IBM Plex Mono and headings are Rajdhani, both self-hosted. Figures and the preview image drawn by Typst use the same two fonts from `typst-fonts/`, so they look the same on every build machine. Chinese, Japanese and Korean text falls back to the system font, in pages and in figures.

> [!NOTE]
> For Chinese text, the theme recommends [Sarasa Gothic SC](https://github.com/be5invis/Sarasa-Gothic/releases) (更纱黑体). Install it on the build machine and set `cjk-font = "Sarasa Gothic SC"` in `templates/config.typ`, and figures and the preview image use it too.

## Acknowledgements

Built on [Tola](https://github.com/tola-rs/tola-ssg) and [Typst](https://typst.app). Figures use [CeTZ](https://github.com/cetz-package/cetz); search uses [Pagefind](https://pagefind.app). Fonts: [IBM Plex Mono](https://github.com/IBM/plex) and [Rajdhani](https://github.com/itfoundry/rajdhani).

## License

The theme is released under the [MIT License](LICENSE). The bundled fonts are under the SIL Open Font License 1.1; their license texts are in `assets/webfonts/`.

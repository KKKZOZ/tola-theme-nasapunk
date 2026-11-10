<div align="center">

<img src="theme/assets/favicon.svg" width="84" alt="">

# NASApunk

**A NASApunk-style blog theme for [Tola](https://github.com/tola-rs/tola-ssg).**

Write posts in Typst. Figures, diagrams and math render as inline SVG in the theme colours, by day and by night.

[![Build](https://github.com/KKKZOZ/tola-theme-nasapunk/actions/workflows/build.yml/badge.svg)](https://github.com/KKKZOZ/tola-theme-nasapunk/actions/workflows/build.yml)
[![Tola](https://img.shields.io/badge/Tola-0.8.2--pre.2%2B-cb4b22)](https://github.com/tola-rs/tola-ssg)
[![Typst](https://img.shields.io/badge/Typst-0.15-239dad)](https://typst.app)
[![License: MIT](https://img.shields.io/badge/license-MIT-286379)](LICENSE)

**English** · [简体中文](README.zh-CN.md)

**[Live demo](https://kkkzoz.github.io/tola-theme-nasapunk/)** · **[My blog](https://blog.kkkzoz.top/)**

<br>

<img src="docs/screenshots/hero.png" alt="NASApunk home page, day and night themes split diagonally">

</div>

> [!NOTE]
> Need slides in the same style? The matching slide template is [touying-nasapunk](https://typst.app/universe/package/touying-nasapunk) on Typst Universe.

## Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Quick start](#quick-start)
- [Documentation](#documentation)
- [Fonts](#fonts)
- [Acknowledgements](#acknowledgements)
- [License](#license)
- [Star History](#star-history)

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
      <sub>Posts sharing a <code>series</code> name link up; <code>/series/</code> lists every series.</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/figures.png" alt="A CeTZ figure"><br>
      <b>Typst figures</b><br>
      <sub>CeTZ and diagrams as inline SVG, in theme colours; click any figure or image to enlarge it.</sub>
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

> [!IMPORTANT]
> This is the `preview` branch, for [Tola 0.8.2-pre.2](https://github.com/tola-rs/tola-ssg/releases/tag/v0.8.2-pre.2) and newer. Tola 0.8.2 turns themes into modules, so the theme now lives in `theme/` and is set up in `tola.toml`. For Tola 0.8.0 and 0.8.1, use the `main` branch.

You need Tola 0.8.2-pre.2 or newer and Node.js (for the search index). Install Tola with [mise](https://mise.jdx.dev) (`mise use -g tola@0.8.2-pre.2`), or download a binary from its [release page](https://github.com/tola-rs/tola-ssg/releases/tag/v0.8.2-pre.2).

### Start from the template

The simplest way: a copy of this repository is a working blog, with the theme in `theme/`.

```sh
# 1. Get the template, its preview branch
git clone --branch preview https://github.com/KKKZOZ/tola-theme-nasapunk.git my-blog
cd my-blog

# 2. Install Pagefind and start the dev server
npm install
tola dev
```

Open <http://127.0.0.1:5277>. `tola dev` rebuilds on save; `tola build` writes the finished site, search index included, to `public/`.

Then make it yours:

1. Set your title, name, description and language under `[site]` in `tola.toml`.
2. Set the theme's options, such as the document-number prefix, under `[modules.nasapunk.options]` in `tola.toml`. Every option, with its default, is listed in `theme/tola-module.toml`.
3. Replace the example posts in `content/posts/` and edit `content/about.typ`.

Everything you own sits outside `theme/`: `tola.toml`, `site.typ`, `content/`, `assets/` and `typst-fonts/`. To update the theme, replace `theme/` with the one from a newer copy, or fetch it from Git as below.

### Use it as a module

A site of your own can take the theme straight from Git; Tola fetches it, and `tola update nasapunk` upgrades it. In `tola.toml`:

```toml
[build]
entry = { module = "nasapunk" }

[modules.nasapunk]
git = { url = "https://github.com/KKKZOZ/tola-theme-nasapunk", branch = "preview", subdir = "theme" }

[modules.nasapunk.options]
doc-prefix = "TN"

[typst.fonts]
paths = ["typst-fonts"]
system = true
```

Copy `typst-fonts/` from this repository into the site so figures are drawn in the theme's fonts, and run `npm install pagefind` there for search (or set `search = false` under `[modules.nasapunk.options]`). Posts go in `content/posts/` and import the theme's components:

```typst
#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/nasapunk:0.0.0": callout

#tola-meta((title: "Hello", date: "2026-11-10", summary: "The first post."))

#callout(kind: "info")[Written with NASApunk.]
```

### Typst-valued settings

Extra `<head>` markup (analytics) and content under every post (comments) are Typst values, not TOML. Set `entry = "site.typ"` under `[build]` and pass them to `render-site` in `site.typ`; the template's `site.typ` shows both.

## Documentation

The full documentation is in the [wiki](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki).

| Page | What it covers |
| --- | --- |
| [Configuration](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Configuration) | Where each setting lives: site identity, layout, feeds, colours, fonts, search |
| [Writing Posts](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Writing-Posts) | Post files and URLs, `tola-meta` fields, series, drafts, math |
| [Components](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Components) | Callouts, folds, terms, images, columns, cross-post links, diagrams, CeTZ figures and LaTeX math |
| [Deployment](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Deployment) | GitHub Pages and other static hosts, sub-path sites |
| [Project Structure](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Project-Structure) | What each file and folder in the theme does |

The [live demo](https://kkkzoz.github.io/tola-theme-nasapunk/) doubles as a tutorial: each post in the [Theme Tour](https://kkkzoz.github.io/tola-theme-nasapunk/series/) shows the Typst source of every example above what it renders.

## Fonts

Body text is IBM Plex Mono and headings are Rajdhani, both self-hosted. Figures and the preview image drawn by Typst use the same two fonts from `typst-fonts/`, so they look the same on every build machine. Chinese, Japanese and Korean text falls back to the system font, in pages and in figures.

> [!NOTE]
> For Chinese text, the theme recommends [Sarasa Gothic SC](https://github.com/be5invis/Sarasa-Gothic/releases) (更纱黑体). Install it on the build machine and set `cjk-font = "Sarasa Gothic SC"` under `[modules.nasapunk.options]` in `tola.toml`, and figures and the preview image use it too.

## Acknowledgements

Built on [Tola](https://github.com/tola-rs/tola-ssg) and [Typst](https://typst.app). Figures use [CeTZ](https://github.com/cetz-package/cetz); search uses [Pagefind](https://pagefind.app). Fonts: [IBM Plex Mono](https://github.com/IBM/plex) and [Rajdhani](https://github.com/itfoundry/rajdhani).

## License

The theme is released under the [MIT License](LICENSE). The bundled fonts are under the SIL Open Font License 1.1; their license texts are in `theme/assets/webfonts/` and `typst-fonts/`.

## Star History

<a href="https://www.star-history.com/#KKKZOZ/tola-theme-nasapunk&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date&theme=dark">
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date">
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date">
  </picture>
</a>

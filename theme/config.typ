// The theme's settings, read once from the module instance: defaults in
// tola-module.toml [options], overridden by the site's
// [modules.<alias>.options]. Parsed here so a misspelt key or a value of
// the wrong kind fails the build with its name.
// Import: #import "/config.typ": doc-prefix, mission, nav-items, ...

#import "@tola/module:0.0.0": get-module
#import "@tola/schema:0.0.0": array-of, enum-of, parse, schema, union

#let _link = schema((label: str, url: str))

#let _options = parse(get-module().options, schema((
  doc-prefix: str,
  mission: str,
  content-width: int,
  posts-per-page: int,
  toc-depth: int,
  feed-size: int,
  feed-full-text: bool,
  social-image: union(enum-of(("auto", "none")), schema((src: str, alt: str))),
  cjk-font: str,
  code-theme: str,
  code-dark-theme: str,
  search: bool,
  search-language: str,
  math-check: bool,
  nav: array-of(schema((label: str, output: str))),
  social-links: array-of(_link),
)))

// ============================================================================
// Identity
// ============================================================================

/// Prefix of post document numbers: TN-001, TN-002, ...
#let doc-prefix = _options.doc-prefix

/// Orange code in the header next to the site title, or `none`.
#let mission = if _options.mission != "" { _options.mission }

/// Header navigation: (label, output file) pairs.
#let nav-items = _options.nav.map(item => (item.label, item.output))

/// Footer links: (label, URL) pairs.
#let social-links = _options.social-links.map(item => (item.label, item.url))

// ============================================================================
// Layout
// ============================================================================

/// Width of the text column in CSS pixels.
#let content-width = _options.content-width

/// Posts per home page.
#let posts-per-page = _options.posts-per-page

/// Deepest heading level numbered and listed in a post's table of contents.
#let toc-depth = _options.toc-depth

// ============================================================================
// Feed
// ============================================================================

#let feed-size = _options.feed-size
#let feed-full-text = _options.feed-full-text

// ============================================================================
// Sharing
// ============================================================================

/// `auto`, `none`, or `(src:, alt:)`: see tola-module.toml.
#let social-image = {
  let value = _options.social-image
  if value == "auto" { auto } else if value == "none" { none } else { value }
}

// ============================================================================
// Code and fonts
// ============================================================================

#let cjk-font = if _options.cjk-font != "" { _options.cjk-font }
#let code-theme = if _options.code-theme == "auto" { auto } else { _options.code-theme }
#let code-dark-theme = _options.code-dark-theme

// ============================================================================
// Search
// ============================================================================

/// Whether /search/ is published and linked; the `search` hook follows the
/// same option.
#let search = _options.search

// ============================================================================
// Extra markup
// ============================================================================

/// The Typst-valued settings `render-site` (lib.typ) takes: `head-extra`,
/// content for every <head>, and `post-footer-extra`, a function from a post
/// to the content after it. Set once before the first page; read in
/// `context`.
#let extras = state("nasapunk-extras", (head-extra: none, post-footer-extra: none))

// Your site's settings that have no key in tola.toml. This file, tola.toml
// and content/ are yours: a newer release of the theme replaces templates/,
// utils/, scripts/ and the theme's files in assets/, and leaves your edits
// here alone.
// Import: #import "/config.typ": doc-prefix, mission, social-links, ...

// ============================================================================
// Identity
// ============================================================================

/// Prefix of post document numbers: TN-001, TN-002, ... Use your initials
/// for a personal series, e.g. "ABC-TN".
#let doc-prefix = "TN"

/// Optional orange code shown in the header next to the site title, e.g.
/// "RESEARCH NOTES"; `none` hides it.
#let mission = none

/// Header navigation: (label, output file) pairs. A page written as
/// content/projects.typ publishes at "projects/index.html".
#let nav-items = (
  ("Home", "index.html"),
  ("Archive", "archive/index.html"),
  ("Tags", "tags/index.html"),
  ("Series", "series/index.html"),
  ("Search", "search/index.html"),
  ("About", "about/index.html"),
)

/// Links in the footer, as (label, URL) pairs, e.g. ("Email",
/// "mailto:you@example.com"). They carry `rel="me"`, so Mastodon and other
/// IndieWeb profiles that link back to the site can verify them.
#let social-links = (
  ("GitHub", "https://github.com/KKKZOZ/tola-theme-nasapunk"),
)

// ============================================================================
// Layout
// ============================================================================

/// Width of the text column in CSS pixels, shared by the header, listings
/// and post text. Wider posts float their table of contents beside the text
/// only on windows with room for both (templates/layout.typ `toc-float-at`).
#let content-width = 760

/// Posts per home page; older ones go on /page/2/, /page/3/, ...
#let posts-per-page = 10

/// Deepest heading level numbered and listed in a post's table of contents
/// (1 = `=`, 2 = `==`).
#let toc-depth = 2

// ============================================================================
// Feed
// ============================================================================

/// Newest posts listed in the RSS feed.
#let feed-size = 20

/// `true` puts each post's full text in the feed, `false` only its summary.
#let feed-full-text = true

// ============================================================================
// Sharing
// ============================================================================

/// Preview image when a page is shared: `auto` draws one from the site's
/// title and description, and one for each post from its title, summary,
/// document number and tags (templates/social.typ); `(src: "/assets/…",
/// alt: "…")` uses a file under assets/ for every page (1200 × 630 suits
/// most sites); `none` gives a text-only card. A post's own `image` field
/// (tola-meta) wins over all three. Needs `origin` in tola.toml, as image
/// URLs are absolute.
#let social-image = auto

// ============================================================================
// Code and fonts
// ============================================================================

/// Font for Chinese, Japanese and Korean text in figures and the preview
/// image drawn by Typst, e.g. "Sarasa Gothic SC" once it is installed on the
/// build machine. `none` uses any system font that has the glyphs. Pages
/// themselves use the browser's fonts (assets/styles/site.css).
#let cjk-font = none

/// Syntax colours for code: a name from @tola/code's `code-themes`
/// (`tola help "@tola/code" code-themes`), or `auto` for Typst's own
/// colours. `code-theme` is the day look, `code-dark-theme` the night one.
#let code-theme = auto
#let code-dark-theme = "github-dark"

// ============================================================================
// Extra markup
// ============================================================================

/// Extra <head> content on every page, such as an analytics script.
/// `html.elem` takes any attribute; Plausible, for example:
/// ```typst
/// #let head-extra = html.elem("script", attrs: (
///   defer: "", src: "https://plausible.io/js/script.js", data-domain: "example.com",
/// ))
/// ```
#let head-extra = none

/// Content placed at the end of every post, after the links to the previous
/// and next posts: comments, a newsletter form, a support link. `none`, or a
/// function that takes the post and returns content (or `none` to skip that
/// post). The post is a dictionary: `title`, `output` ("posts/x/index.html"),
/// `permalink` (its path), `url` (its absolute address, `none` without an
/// origin) and `meta` (its tola-meta fields: `date`, `tags`, `series`, ...).
/// Giscus comments, for example (the values come from https://giscus.app):
/// ```typst
/// #let post-footer-extra = none
///   src: "https://giscus.app/client.js",
///   data-repo: "you/your-blog", data-repo-id: "…",
///   data-category: "Comments", data-category-id: "…",
///   data-mapping: "pathname", data-theme: "preferred_color_scheme",
///   crossorigin: "anonymous", async: "",
/// ))
/// ```
#let post-footer-extra = none

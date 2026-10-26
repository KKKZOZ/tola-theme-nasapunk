// Site values that have no `[site]` key in tola.toml.
// Import: #import "/templates/config.typ": doc-prefix, mission, social-links, ...

/// Prefix of post document numbers: TN-001, TN-002, ... Use your initials
/// for a personal series, e.g. "ABC-TN".
#let doc-prefix = "TN"

/// Optional orange code shown in the header next to the site title, e.g.
/// "RESEARCH NOTES"; `none` hides it.
#let mission = none

/// Links in the footer, as (label, URL) pairs, e.g. ("Email",
/// "mailto:you@example.com"). They carry `rel="me"`, so Mastodon and other
/// IndieWeb profiles that link back to the site can verify them.
#let social-links = (
  ("GitHub", "https://github.com/KKKZOZ/tola-theme-nasapunk"),
)

/// Preview image when a page is shared: `auto` draws one from the site's
/// title and description (templates/social.typ); `(src: "/assets/…", alt:
/// "…")` uses a file under assets/ (1200 × 630 suits most sites); `none`
/// gives a text-only card. Needs `origin` in tola.toml, as image URLs are
/// absolute.
#let social-image = auto

/// Font for Chinese, Japanese and Korean text in figures and the preview
/// image drawn by Typst, e.g. "Sarasa Gothic SC" once it is installed on the
/// build machine. `none` uses any system font that has the glyphs. Pages
/// themselves use the browser's fonts (assets/styles/site.css).
#let cjk-font = none

/// Extra <head> content on every page, such as an analytics script.
/// `html.elem` takes any attribute; Plausible, for example:
/// ```typst
/// #let head-extra = html.elem("script", attrs: (
///   defer: "", src: "https://plausible.io/js/script.js", data-domain: "example.com",
/// ))
/// ```
#let head-extra = none

// An optional site program, for settings that are Typst values rather than
// TOML options. Unused until tola.toml selects it with
// `[build] entry = "site.typ"`; it then builds the same site as the theme's
// own entry, plus whatever is passed below.

#import "@tola-modules/nasapunk:0.0.0": render-site

#render-site(
  // Extra <head> content on every page, such as an analytics script.
  // `html.elem` takes any attribute; Plausible, for example:
  //   html.elem("script", attrs: (
  //     defer: "", src: "https://plausible.io/js/script.js", data-domain: "example.com",
  //   ))
  head-extra: none,

  // Content placed at the end of every post, after the links to the previous
  // and next posts: comments, a newsletter form, a support link. A function
  // that takes the post and returns content (or `none` to skip that post).
  // The post is a dictionary: `title`, `output` ("posts/x/index.html"),
  // `permalink` (its path), `url` (its absolute address, `none` without an
  // origin) and `meta` (its tola-meta fields: `date`, `tags`, `series`, ...).
  // Giscus comments, for example (the values come from https://giscus.app):
  //   post => html.elem("script", attrs: (
  //     src: "https://giscus.app/client.js",
  //     data-repo: "you/your-blog", data-repo-id: "…",
  //     data-category: "Comments", data-category-id: "…",
  //     data-mapping: "pathname", data-theme: "preferred_color_scheme",
  //     crossorigin: "anonymous", async: "",
  //   ))
  post-footer-extra: none,
)

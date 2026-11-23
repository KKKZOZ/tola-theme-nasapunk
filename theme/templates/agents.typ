// Files for AI agents and other programs that read the site: each page's
// Typst source as plain text beside its HTML, and /llms.txt
// (https://llmstxt.org), a Markdown index of the site that links to them.
// The HTML draws formulas and figures as SVG, which text extraction drops;
// the source keeps them as Typst math and CeTZ code, and carries the site
// files a page imports (its figures) after the page's own. `render-site`
// (lib.typ) emits them.
// Import: #import "/templates/agents.typ": agent-files, source-output

#import "@tola/address:0.0.0": output-url
#import "@tola/site:0.0.0": project-path, site
#import "/config.typ": publish-sources
#import "/templates/feeds.typ": feed-output, has-feed

/// The file a page's source is published as, beside its HTML:
/// "posts/x/index.html" -> "posts/x/index.typ.txt". `none` when the
/// `publish-sources` option is off, and for lab/ test pages. `.txt` so
/// static hosts serve it as text/plain: GitHub Pages and others send an
/// unknown `.typ` as a binary download, which some agents refuse.
/// `entry` is a `(source:, output:)` record (data.typ `select-pages`).
#let source-output(entry) = {
  if not publish-sources or entry.source.id.starts-with("lab/") { return none }
  entry.output.replace(regex("\.html$"), "") + ".typ.txt"
}

/// The site files a Typst text imports or includes, as written: `.typ`
/// paths, not packages ("@…"). Raw text and comments are skipped, so code
/// shown in a post (`#include "x.h"` in a C++ block) is not taken for one.
#let local-imports(text) = {
  let text = text
    .replace(regex("```[\s\S]*?```"), "")
    .replace(regex("`[^`\n]*`"), "")
    .replace(regex("/\*[\s\S]*?\*/"), "")
    .replace(regex("(?m)(^|[^:])//.*$"), m => m.captures.at(0))
  text
    .matches(regex("\b(?:import|include)\s+\"([^\"@][^\"]*\.typ)\""))
    .map(m => m.captures.at(0))
}

/// `target` (as written in a file at `from`, a path from the site root
/// such as "/content/posts/x.typ") as a path from the site root.
#let resolve(from, target) = {
  let parts = if target.starts-with("/") { () } else { from.split("/").slice(0, -1) }
  for seg in target.split("/") {
    if seg == "" or seg == "." { continue }
    if seg == ".." { if parts.len() > 0 { let _ = parts.pop() } } else { parts.push(seg) }
  }
  "/" + parts.filter(p => p != "").join("/")
}

/// A page's published source: its own file and, after it, every site file
/// it imports or includes, directly or through another (the figures a post
/// imports, the files those import), each under a comment naming its path.
/// Packages, the theme among them, are left out.
#let source-text(entry) = {
  let page = repr(entry.source.file).match(regex("^path\\(\"(.*)\"\\)$")).captures.at(0)
  let text = read(entry.source.file)
  let seen = (page,)
  let queue = local-imports(text).map(t => resolve(page, t))
  let files = ()
  while queue.len() > 0 {
    let file = queue.remove(0)
    if file in seen { continue }
    seen.push(file)
    let body = read(project-path(file.slice(1)))
    files.push((file, body))
    queue += local-imports(body).map(t => resolve(file, t))
  }
  if files.len() == 0 { return text }
  let header(file) = "// " + "=" * 72 + "\n// " + file + "\n// " + "=" * 72 + "\n\n"
  header(page) + text.trim(at: end) + "\n" + files.map(((file, body)) => "\n" + header(file) + body.trim(at: end) + "\n").join()
}

/// An output's address: absolute with an origin, else from the site root.
#let address(output) = if site.url != none { output-url(output, origin: site.origin) } else { output-url(output) }

/// Markdown-safe one-line text: summaries may span lines in tola-meta.
#let one-line(s) = s.replace(regex("\s+"), " ").trim()

/// One llms.txt list item: a link to the source when published (what an
/// agent wants), else to the page, then the summary and, in parentheses,
/// `details` and the page's address:
/// "- [Title](…/index.typ.txt): Summary. (2026-10-18 · tags: a, b · page: …/)"
#let item(title, entry, summary, details: ()) = {
  let src = source-output(entry)
  let page = address(entry.output)
  let details = details + if src != none { ("page: " + page,) } else { () }
  let notes = (
    if summary != none and summary.trim() != "" { one-line(summary) },
    if details.len() > 0 { "(" + details.join(" · ") + ")" },
  ).filter(n => n != none)
  "- [" + one-line(title) + "](" + if src != none { address(src) } else { page } + ")"
  if notes.len() > 0 { ": " + notes.join(" ") }
  "\n"
}

/// Publish every page's source (`source-output`) and /llms.txt. `pages`
/// are the published `(source:, output:)` records, `posts` the post records,
/// newest first.
#let agent-files(pages, posts) = {
  let pages = pages.filter(entry => not entry.source.id.starts-with("lab/"))
  for entry in pages {
    let out = source-output(entry)
    if out != none { asset(out, source-text(entry)) }
  }

  let by-output = pages.map(entry => (entry.output, entry)).to-dict()
  let post-outputs = posts.map(p => p.output)
  let others = pages.filter(entry => entry.output not in post-outputs)

  let text = "# " + one-line(site.title) + "\n\n"
  if site.description != none and site.description != "" {
    text += "> " + one-line(site.description) + "\n\n"
  }
  text += "A blog written in Typst and built with Tola. "
  text += if publish-sources {
    "Each link below is a page's Typst source, published as plain text beside the page (`index.typ.txt`): it is what the page is compiled from, with formulas as Typst math and figures as CeTZ code, which the HTML draws as SVG. Site files the page imports, such as its figures, follow the page's own source, each under a `// /path/to/file.typ` comment. Calls such as `#callout(...)` and `#img(...)` are the theme's components (NASApunk, https://github.com/KKKZOZ/tola-theme-nasapunk).\n\n"
  } else {
    "Each link below is a page of the site.\n\n"
  }

  if posts.len() > 0 {
    text += "## Posts\n\n"
    for p in posts {
      let details = (p.date.display("[year]-[month]-[day]"),)
      if p.series != none { details.push("series: " + p.series) }
      if p.tags.len() > 0 { details.push("tags: " + p.tags.join(", ")) }
      text += item(p.title, by-output.at(p.output), p.summary, details: details)
    }
    text += "\n"
  }
  if others.len() > 0 {
    text += "## Pages\n\n"
    for entry in others {
      let m = entry.source.meta
      text += item(m.title, entry, m.summary)
    }
    text += "\n"
  }
  text += "## Optional\n\n"
  text += "- [Archive](" + address("archive/index.html") + "): every post by date\n"
  if has-feed { text += "- [RSS feed](" + address(feed-output) + "): the newest posts\n" }

  asset("llms.txt", text)
}

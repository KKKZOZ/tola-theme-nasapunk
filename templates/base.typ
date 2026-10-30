// Shared show rules for every page.
// Import: #import "/templates/base.typ": base, palette

#import "@tola/address:0.0.0": slugify
#import "@tola/document:0.0.0": current-document
#import "/templates/config.typ": cjk-font
#import "/templates/data.typ": draft-index
#import "/templates/latex.typ": probe, to-latex

// Mirrors the day values of the `--*` tokens in assets/styles/site.css, for
// Typst-side drawings (html.frame / cetz) that should match the page. The
// stylesheet maps these colours (and those of utils/diagram.typ) to their
// night values; a drawing in another colour keeps it in both themes.
#let palette = (
  paper: white, ink: rgb("#222A2D"), orange: rgb("#CB4B22"),
  muted: rgb("#65716F"), rule: rgb("#C5C9BE"), panel: rgb("#E6E7DD"),
  blue: rgb("#286379"), emphasis: rgb("#B44020"), success: rgb("#35665B"),
  hint-emphasis: rgb("#326D65"), warning: rgb("#8A5B13"), danger: rgb("#A73434"),
)

// Rajdhani and IBM Plex Mono come from typst-fonts/; CJK text uses
// `cjk-font` (config.typ), else any system font that has the glyphs.
#let cjk = if cjk-font == none { () } else { (cjk-font,) }
#let title-font = ("Rajdhani",) + cjk
#let body-font = ("IBM Plex Mono",) + cjk

/// Elements matching `sel` in the current document only: the site is one
/// Bundle, so a bare `query` would also see every other page. Needs `context`.
#let doc-query(sel) = query(selector(sel).within(current-document().location))

/// An equation as SVG in HTML export, in a `role="math"` wrapper with the
/// stylesheet's math-inline / math-block class; other targets get it as is.
/// Tola 0.8.1 dropped `@tola/web`'s `math-svg`; Tola still aligns inline
/// frames with the text baseline.
///
/// Formulas are drawn 1.15× the surrounding text (13.8pt ≈ 18.4px beside
/// 16px prose), in the Book weight with a hairline stroke of the text colour,
/// so they hold their own next to IBM Plex Mono. The size is set inside the
/// frame: a frame measures itself in em of the text size where it is made,
/// which the browser maps to the CSS font size.
///
/// `data-latex` holds the formula as LaTeX (templates/latex.typ), which
/// assets/scripts/copy.js puts in a copied selection in place of the SVG;
/// a formula it cannot convert holds a placeholder, and `data-latex-issues`
/// names the parts that stopped it. A formula without `alt` has its LaTeX
/// as the label screen readers read.
#let math-svg(it) = context {
  // Laid out only to be measured by latex.typ.
  if it.at("alt", default: none) == probe { return it }
  let body = {
    set text(size: 1.15em, weight: 450, stroke: .2pt + text.fill)
    it
  }
  if target() != "html" { return body }
  let latex = to-latex(it.body)
  let attrs = (
    role: "math",
    class: if it.block { "math-block" } else { "math-inline" },
    data-latex: latex.latex,
  )
  if latex.issues.len() > 0 { attrs.insert("data-latex-issues", latex.issues.join(", ")) }
  // Screen readers read the formula's `alt`, else its LaTeX.
  let alt = it.at("alt", default: math.equation.alt)
  if alt == none and latex.issues.len() == 0 { alt = latex.latex }
  if alt != none { attrs.insert("aria-label", alt) }
  if it.block {
    html.elem("div", attrs: attrs, html.frame(body))
  } else {
    // assets/scripts/math.js keeps it on one line with the punctuation after it.
    html.elem("span", attrs: attrs, box(html.frame(body)))
  }
}

// Footnotes: Typst's HTML export cannot place them under a custom <body>, so
// the show rule in `base` renders only the numbered ref, and `endnotes()`
// lists the notes after the text. Refs and notes link to each other.

/// 1-based number of the footnote at `loc`. Needs `context`.
#let note-number(loc) = doc-query(selector(footnote).before(loc)).len()

/// The "Notes" section; renders nothing when the page has no footnotes.
#let endnotes() = context {
  let notes = doc-query(footnote)
  if notes.len() == 0 { return }
  // html.elem: the typed functions reject DPUB roles such as doc-endnotes.
  html.elem("section", attrs: (class: "endnotes", role: "doc-endnotes"), {
    html.div(class: "label accent", "Notes")
    html.ol(for (i, note) in notes.enumerate() {
      let n = str(i + 1)
      html.li(id: "fn-" + n, {
        note.body
        html.a(class: "fn-back", href: "#fnref-" + n, aria-label: "Back to text", "↩")
      })
    })
  })
}

/// Site links. A link to a draft is plain text until the draft is published,
/// so index pages can list unfinished notes. A fragment is slugged like
/// heading ids, as Tola 0.7 did: `link("#MLP layer")` reaches the heading
/// "MLP layer" (id `mlp-layer`). External links and fragments already in slug
/// form are returned as is.
#let slug-fragment(it) = {
  let dest = it.dest
  let at = dest.position("#")
  if at == none { return it }
  let fragment = dest.slice(at + 1)
  if fragment.match(regex("[\\p{L}\\p{N}]")) == none { return it }
  let slug = slugify(fragment, mode: "ascii")
  if slug == fragment { it } else { link(dest.slice(0, at + 1) + slug, it.body) }
}

#let site-link(it) = {
  let dest = it.dest
  if type(dest) != str or not (dest.starts-with("/") or dest.starts-with("#")) { return it }
  let path = dest.split("#").first()
  if path == "" { return slug-fragment(it) }
  context if path in draft-index.get() {
    html.span(class: "draft-link", title: "Draft: not published yet", it.body)
  } else {
    slug-fragment(it)
  }
}

#let base(body) = {
  show link: site-link

  // Figures keep the `figure` class the stylesheet targets.
  show figure: it => context {
    if target() == "html" { html.figure(class: "figure", it) } else { it }
  }

  // Equations render as SVG (see `math-svg`).
  show math.equation: set text(font: "New Computer Modern Math")
  show math.equation: math-svg

  // 12pt == 16px, the CSS size of `.prose`, so SVG frames (math, cetz) keep true scale.
  // The fonts only affect text inside SVG frames; HTML text is styled by CSS.
  set text(size: 12pt, font: body-font, fill: palette.ink)

  // Code blocks get a bar with the language and a copy button. The button
  // starts hidden and is revealed by assets/scripts/copy.js.
  show raw.where(block: true): it => html.div(class: "code-block", {
    html.elem("div", attrs: (class: "code-head", data-pagefind-ignore: ""), {
      let lang = if it.lang not in (none, "", "text", "txt") { it.lang }
      // A div: Typst wraps a lone <span> beside a block sibling in <p>.
      html.div(class: "code-lang", if lang != none { lang })
      html.elem("button", attrs: (type: "button", class: "code-copy", hidden: ""), "Copy")
    })
    it
  })

  show footnote: it => context {
    let n = str(note-number(it.location()))
    let ref = html.elem("a", attrs: (id: "fnref-" + n, href: "#fn-" + n, role: "doc-noteref"), n)
    html.elem("sup", attrs: (class: "fn-ref"), ref)
  }

  body
}

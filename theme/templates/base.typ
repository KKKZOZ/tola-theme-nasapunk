// Shared show rules for every page.
// Import: #import "/templates/base.typ": base, palette

#import "@tola/address:0.0.0": slugify
#import "@tola/document:0.0.0": current-document
#import "@tola/code:0.0.0": code-themes, render-code
// `palette`: the theme's colours by day (templates/colors.typ), for drawings
// that should match the page; each follows the night theme too.
#import "/templates/colors.typ": palette
#import "/config.typ": bibliography-style, cjk-font, code-dark-theme, code-theme
#import "/templates/data.typ": draft-index
#import "/templates/latex.typ": probe, to-latex

// Rajdhani and IBM Plex Mono come from typst-fonts/ (`[typst] fonts`); CJK text uses
// the `cjk-font` option (config.typ), else any system font that has the glyphs.
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
//
// Terms (`term` in utils/ui.typ) work the same way: the term in the text
// links to its definition in a "Terms" section after the notes. Each
// definition is a `metadata` labelled <nasapunk-term>.

/// 1-based number of the footnote at `loc`. Needs `context`.
#let note-number(loc) = doc-query(selector(footnote).before(loc)).len()

/// Slug of a term: its definition has the id "term-" + slug, and the use
/// that defines it "termref-" + slug.
#let term-slug(name) = slugify(name, mode: "ascii")

/// The "Notes" and "Terms" sections; each renders nothing when the page has
/// no footnotes or terms.
#let endnotes() = context {
  let notes = doc-query(footnote)
  if notes.len() > 0 {
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
  let terms = doc-query(<nasapunk-term>).map(it => it.value)
  let slugs = terms.map(t => term-slug(t.name))
  assert(slugs.dedup().len() == slugs.len(), message: "a term is defined twice: " + terms.map(t => t.name).join(", "))
  if terms.len() > 0 {
    html.elem("section", attrs: (class: "endnotes endterms", role: "doc-glossary"), {
      html.div(class: "label accent", "Terms")
      html.dl(for t in terms {
        let slug = term-slug(t.name)
        // A <div> groups a <dt> with its <dd>, so `:target` lights up both.
        html.div(id: "term-" + slug, {
          html.dt(t.name)
          html.dd({
            t.body
            html.a(class: "fn-back", href: "#termref-" + slug, aria-label: "Back to text", "↩")
            if t.credit != none { html.span(class: "term-credit", t.credit) }
          })
        })
      })
    })
  }
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

/// Records that this page links to the post at `permalink`: the post lists
/// the posts that do under "Referenced by" (`cited-by` in post.typ). Shows
/// nothing.
#let cite-mark(permalink) = context [#metadata((from: current-document().output, to: permalink))<nasapunk-cite>]

#let site-link(it) = {
  let dest = it.dest
  if type(dest) != str or not (dest.starts-with("/") or dest.starts-with("#")) { return it }
  let path = dest.split("#").first()
  if path == "" { return slug-fragment(it) }
  context if path in draft-index.get() {
    html.span(class: "draft-link", title: "Draft: not published yet", it.body)
  } else {
    slug-fragment(it)
    cite-mark(path)
  }
}

// Figures are Typst's own: in HTML export a `figure` is a <figure> whose id
// is its label, numbered per kind, so `@fig-x` reads "Figure 2" (图 2 in
// Chinese) and links to `#fig-x`. A label that is not a valid HTML id, such
// as `<fig:x>`, gets a generated `loc-N` instead. `img` / `gallery`
// (utils/ui.typ) are figures of kind image.
//
// Every figure is numbered, a caption or not: the caption defaults to empty,
// which shows the number alone. A table outside a figure is put in one, so
// it is numbered too; to cite it, write the figure yourself, as
// `#figure(table(...), caption: [...]) <tab-x>`, since Typst cannot
// reference a bare table. `#figure(numbering: none, ...)` opts out.

/// "figure" or "table": the word a figure's kind goes by in ids.
#let figure-word(kind) = if kind == table { "table" } else if kind == raw { "listing" } else { "figure" }

/// Whether a figure has a caption of its own, past its number.
#let captioned(fig) = fig.caption != none and fig.caption.body not in (none, [], [ ])

/// The id of the anchor set before a numbered, captioned figure, which the
/// post's list of figures links to (`toc` in post.typ): "figure-2",
/// "table-1". Needs `context`.
#let figure-anchor(fig) = figure-word(fig.kind) + "-" + str(fig.counter.at(fig.location()).first())

/// Whether the current position is inside a figure; set by `base`.
#let in-figure = state("nasapunk-in-figure", false)

/// A caption that leads with the numbered supplement: "FIGURE 2 — body",
/// or "FIGURE 2" for an empty caption. Unnumbered and empty, it is left out.
#let figure-caption(it) = {
  let empty = it.body in (none, [], [ ])
  if it.numbering == none and empty { return }
  html.figcaption({
    if it.numbering != none {
      let num = it.counter.display(it.numbering)
      html.span(class: "figure-num", if it.supplement in (none, []) { num } else [#it.supplement #num])
      if not empty [ — ]
    }
    it.body
  })
}

// References are Typst's own: `#bibliography("refs.bib")` at the end of a
// post and `@key` in its text. The site is one Bundle, and Typst numbers the
// works of all its bibliographies in one run, so a page's first reference
// would be "[4]" after a page with three. `base` marks where each page
// starts and counts the works cited on the pages before it; the citations
// and the numbers of the list are rewritten without that count.

/// How many works the pages before this one cite; set by `base`.
#let cite-offset = state("nasapunk-cite-offset", 0)

/// A citation with the page's own number: "[5, p. 12]" as "[2, p. 12]".
#let local-cite(it) = context {
  let offset = cite-offset.get()
  if offset == 0 { return it }
  show regex("\[\d+"): m => "[" + str(int(m.text.slice(1)) - offset)
  it
}

#let base(body) = {
  show link: site-link

  // Where this page starts, for `cite-offset`.
  [#metadata(none)<nasapunk-page>]
  context {
    let (count, keys) = (0, ())
    for it in query(selector(cite).or(<nasapunk-page>).before(current-document().location)) {
      if it.func() == metadata { count += keys.dedup().len(); keys = () } else { keys.push(str(it.key)) }
    }
    cite-offset.update(count + keys.dedup().len())
  }
  show cite: local-cite
  set bibliography(title: none, style: bibliography-style)
  show bibliography: it => html.elem("section", attrs: (class: "endnotes references"), {
    html.div(class: "label accent", "References")
    context {
      let offset = cite-offset.get()
      // A work's number is a text of its own: "[4]", never part of a title.
      show regex("^\[\d+\]$"): m => if offset == 0 { m } else { "[" + str(int(m.text.slice(1, -1)) - offset) + "]" }
      it
    }
  })

  // Figures and tables are numbered by default (see `figure-caption`).
  set figure(caption: [])
  show figure: it => {
    // The figure's own id is its label, which most have none of.
    if it.numbering != none and captioned(it) {
      context if target() == "html" { html.div(class: "figure-anchor", id: figure-anchor(it)) }
    }
    in-figure.update(true)
    it
    in-figure.update(false)
  }
  show table: it => context if in-figure.get() { it } else { figure(it) }
  // Tables carry their caption above, as is usual for tables.
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.caption: it => context if target() == "html" { figure-caption(it) } else { it }
  // The site is one Bundle, so counters run on from page to page: restart
  // each figure kind's count on every page.
  context for kind in doc-query(figure).map(f => f.kind).dedup() {
    counter(figure.where(kind: kind)).update(0)
  }

  // Equations render as SVG (see `math-svg`).
  show math.equation: set text(font: "New Computer Modern Math")
  show math.equation: math-svg

  // 12pt == 16px, the CSS size of `.prose`, so SVG frames (math, cetz) keep true scale.
  // The fonts only affect text inside SVG frames; HTML text is styled by CSS.
  set text(size: 12pt, font: body-font, fill: palette.ink)

  // Code is highlighted by @tola/code: Typst's tokens as classes, coloured
  // by its stylesheet (layout.typ `head`) in `code-theme`, and in
  // `code-dark-theme` while the page is in the night theme.
  set raw(theme: if code-theme == auto { auto } else { code-themes.at(code-theme) })
  show raw: render-code.with(dark-theme: code-themes.at(code-dark-theme))

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

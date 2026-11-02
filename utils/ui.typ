// In-article components: callouts, hints, images and cross-post links.
// Import: #import "/utils/ui.typ": callout, hint, img, gallery, xref, related

#import "@tola/address:0.0.0": asset-url
#import "@tola/image:0.0.0": image-metadata, img as responsive-img
#import "/templates/base.typ": palette
#import "/templates/config.typ": content-width
#import "/templates/data.typ": post-index
#import "/templates/layout.typ": fmt-date, label, spans

/// Instrument-panel callout. Color is paired with a readable status label.
/// kind: note | info | warning | success | danger; title: optional content.
#let callout(body, kind: "note", title: auto) = {
  let styles = (
    note: (code: "01", title: [NOTE]),
    info: (code: "02", title: [INFO]),
    warning: (code: "03", title: [CAUTION / CHECK]),
    success: (code: "04", title: [VERIFIED / GO]),
    danger: (code: "05", title: [ALERT / NO-GO]),
  )
  assert(kind in styles, message: "Unknown callout kind: " + kind)
  let style = styles.at(kind)
  html.aside(class: "callout callout-" + kind, {
    html.div(class: "callout-head", {
      html.span(if title == auto { style.title } else { title })
      html.span[/#style.code]
    })
    html.div(class: "callout-body", body)
  })
}

// Registration target; drawn by Typst, embedded as SVG.
#let _target = html.frame(box(width: 30pt, height: 30pt)[
  #place(top + left, dx: 3pt, dy: 3pt, circle(width: 12pt, stroke: 1pt + palette.orange))
  #place(top + left, dy: 9pt, line(length: 23pt, stroke: 1pt + palette.orange))
  #place(top + left, dx: 9pt, line(end: (0pt, 22pt), stroke: 1pt + palette.orange))
  #place(top + left, dx: 9pt, dy: 23pt, line(
    end: (0pt, 7pt),
    stroke: (paint: palette.muted, thickness: .6pt, dash: "dashed"),
  ))
  #place(top + left, dx: 9pt, dy: 30pt, line(length: 15pt, stroke: .6pt + palette.muted))
])

/// Open engineering annotation: a registration target and leader, not a panel.
#let hint(body) = html.aside(class: "hint", {
  html.div(class: "hint-rule", role: "presentation", spans(4))
  html.div(class: "hint-main", {
    html.div(class: "hint-mark", _target)
    html.div(class: "hint-body", body)
  })
  html.div(class: "hint-rule hint-rule-bottom", role: "presentation", spans(4))
})

// ============================================================================
// Images
// ============================================================================
// Typst's `image()` inlines the file as base64 in HTML export. These helpers
// emit an <img> the browser fetches and caches instead. Paths are
// site-absolute, e.g. "/assets/images/x.png".
//
// A raster file goes through @tola/image: the build derives WebP copies at
// a few widths (never past the source's own) under /_tola/images/, and the
// <img> carries `srcset`, `sizes` and the pixel `width` / `height`, so the
// page reserves the space before the image loads. A PNG becomes lossless
// WebP, so screenshots stay crisp; a JPEG, WebP at quality 75. SVG and GIF
// (which may be animated) are linked as they are, through `asset-url`,
// which fails the build when no [assets] declaration publishes the file.
// Any other URL is used as given.

#let _widths = (480, 760, 1140, 1520)
#let _narrow = content-width + 2 * 16 // below this the column spans the window

/// The `sizes` value for an image that fills `share` of the column, or
/// `px` CSS pixels, or the column plus its bleed.
#let _sizes(share: 1, px: none, bleed: false) = {
  let wide = if px != none { "min(" + str(px) + "px, 100vw)" } else if bleed { str(content-width + 160) + "px" } else {
    str(calc.round(content-width * share)) + "px"
  }
  if px != none { wide } else {
    "(max-width: " + str(_narrow) + "px) " + str(calc.round(100 * share, digits: 2)) + "vw, " + wide
  }
}

/// `sizes` for `img`'s `width` ("60%", "320px") and `bleed`.
#let _img-sizes(width, bleed) = {
  if bleed { return _sizes(bleed: true) }
  if width == none { return _sizes() }
  if width.ends-with("%") { return _sizes(share: float(width.trim("%")) / 100) }
  if width.ends-with("px") { return _sizes(px: float(width.trim("px"))) }
  _sizes()
}

#let _img-tag(src, alt, sizes) = {
  let local = src.starts-with("/")
  let ext = lower(src.split(".").last())
  if local and ext not in ("svg", "gif") {
    let meta = image-metadata(src)
    let widths = _widths.filter(w => w < meta.width) + (calc.min(meta.width, _widths.last()),)
    responsive-img(src, alt: alt, widths: widths.dedup(), sizes: sizes, quality: if meta.is-lossy { 75 } else { none })
  } else {
    let url = if local { asset-url(src) } else { src }
    html.elem("img", attrs: (src: url, alt: alt, loading: "lazy", decoding: "async"))
  }
}

// Both are native figures of kind image, numbered with the page's other
// figures; `numbering: none` leaves one out. A label after one makes it a
// target for `@label`, e.g. `#img(...) <fig-telemetry>`. The class (and
// width) sit on a wrapper inside the <figure>; the stylesheet reaches the
// figure through `:has()`.
#let _figure(caption, numbering, body) = figure(
  kind: image,
  ..if caption != none { (caption: caption) },
  ..if numbering != auto { (numbering: numbering) },
  body,
)

/// Single image with optional caption.
/// - `width`: CSS width of the figure, e.g. "60%" or "320px"; none = full column.
/// - `bleed`: let the figure extend past the text column on wide screens.
/// - `numbering`: `none` leaves the figure unnumbered.
#let img(src, alt: "", caption: none, width: none, bleed: false, numbering: auto) = {
  let attrs = (class: if bleed { "img img-bleed" } else { "img" })
  if width != none { attrs.insert("style", "width: " + width) }
  _figure(caption, numbering, html.div(..attrs, _img-tag(src, alt, _img-sizes(width, bleed))))
}

/// Images side by side; each item is a src string or (src, caption).
#let gallery(columns: 2, caption: none, numbering: auto, ..items) = _figure(
  caption,
  numbering,
  html.div(class: "gallery", style: "--cols: " + str(columns), for item in items.pos() {
    let (src, sub) = if type(item) == array { item } else { (item, none) }
    html.div(class: "gallery-item", {
      _img-tag(src, if sub != none { sub } else { "" }, _sizes(share: 1 / columns))
      if sub != none { label(sub) }
    })
  }),
)

// ============================================================================
// Cross-post links
// ============================================================================

#let _trim(s) = s.trim("/")

/// Find a published post by permalink ("/posts/tools/foo/") or by the last
/// segment of its permalink ("foo"), which survives moving the post to
/// another folder. Needs `context`: the post list comes from `post-index`.
#let _find-post(target) = {
  let key = _trim(target)
  let hits = post-index.get().filter(p => _trim(p.permalink) == key)
  if hits.len() == 0 { hits = post-index.get().filter(p => _trim(p.permalink).split("/").last() == key) }
  assert(hits.len() > 0, message: "xref: no post at `" + target + "`")
  assert(hits.len() == 1, message: "xref: `" + target + "` names " + str(hits.len()) + " posts; use its permalink")
  hits.first()
}

/// Inline link to another post; the text defaults to the post title.
#let xref(target, body: auto) = context {
  let p = _find-post(target)
  link(p.permalink, if body == auto { p.title } else { body })
}

/// "See also" cards linking to other posts.
#let related(..targets, title: [See also]) = html.aside(class: "related", context {
  label(title, class: "accent")
  html.div(class: "related-grid", for t in targets.pos() {
    let p = _find-post(t)
    html.a(class: "related-card", href: p.permalink, {
      label(fmt-date(p.date))
      html.div(class: "related-title", p.title)
      if p.at("summary", default: none) != none { html.div(class: "related-summary", p.summary) }
    })
  })
})

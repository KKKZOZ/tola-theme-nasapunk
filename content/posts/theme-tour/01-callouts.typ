#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout

#tola-meta((
  title: "[Tour 01] Callouts and Footnotes",
  date: "2025-03-12",
  summary: "Part one of a sample series: checklists, callouts and footnotes.",
  tags: ("example", "series"),
  series: "Theme Tour",
))

The Theme Tour posts form a series. The box above shows this post's place
in it, links to the parts before and after it, and folds away the full list.
Its head leads to the #link("/series/")[series index], which lists every
series on the site.

= Series

```typst
#tola-meta((
  title: "[Tour 01] Callouts and Footnotes",
  date: "2025-03-12",
  series: "Theme Tour",
  part: 1,   // optional
))
```

- Posts that share a `series` name form a series. The box appears once a
  series has two parts.
- Parts run oldest first. To choose the order instead, number them with
  `part`: numbered parts come first, in number order, then the rest by date.
- A leading tag such as `[Tour 01]` is dropped from titles in the box and on
  `/series/`, which name the series already.

= Checklist

+ Confirm the build passes with `tola build`.
+ Review drafts: links to them render as plain text until they publish.
+ Check both themes with the day / night switch in the header.

#callout(kind: "success", title: [READY])[All three checks pass.]

#callout(kind: "warning")[A broken link, image or section anchor fails the
build. That is deliberate#footnote[See `[build.references]` in `tola.toml`.].]

= Notes

Footnotes are collected at the end of the post, and each one links back to
where it was cited#footnote[Like this one.].

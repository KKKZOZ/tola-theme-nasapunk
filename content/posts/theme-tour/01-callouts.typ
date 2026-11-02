#import "@tola/address:0.0.0": output-url
#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout, demo, hint, term

#let demo = demo.with(scope: (callout: callout, hint: hint, term: term))

#tola-meta((
  title: "[Tour 01] Callouts, Hints, Notes and Terms",
  date: "2025-03-12",
  summary: "Part one of a sample series: checklists, callouts, hints, footnotes and terms.",
  tags: ("example", "series"),
  series: "Theme Tour",
))

The Theme Tour posts form a series. The box above shows this post's place
in it, links to the parts before and after it, and folds away the full list.
Its head leads to the #link(output-url("series/index.html"))[series index], which lists every
series on the site.

= Series

```typst
#tola-meta((
  title: "[Tour 01] Callouts, Hints, Notes and Terms",
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

A numbered list is `+` at the start of a line; `-` gives bullets.

#demo(```typst
+ Confirm the build passes with `tola build`.
+ Review drafts: links to them render as plain text until they publish.
+ Check both themes with the day / night switch in the header.
```)

= Callouts

`callout` from `utils/ui.typ` boxes a short message. `kind` sets the colour
and the status label: `note` (the default), `info`, `warning`, `success` or
`danger`. `title` replaces the label.

#demo(```typst
#import "/utils/ui.typ": callout

#callout(kind: "success", title: [READY])[All three checks pass.]

#callout(kind: "warning")[A broken link, image or section anchor fails the
build. That is deliberate#footnote[See `[build.references]` in `tola.toml`.].]
```)

= Hints

`hint` is lighter than a callout: an engineering annotation with a target
mark and no box, for a tip or an aside next to the text it concerns.

#demo(```typst
#import "/utils/ui.typ": hint

#hint[Run `tola dev` while writing: it rebuilds the site on every *save*.]
```)

= Notes

Footnotes are collected at the end of the post, and each one links back to
where it was cited.

#demo(```typst
Write the note where it belongs#footnote[Like this one.]; it appears
at the foot of the post.
```)

= Terms

`term` marks a word the reader may not know. Its definition goes in the
brackets where the word first appears: the word gets a dotted underline,
hovering it shows the definition, and every term is listed under "Terms" at
the end of the post, after the notes. On touch screens the word links there.

#demo(```typst
#import "/utils/ui.typ": term

The ground station decodes the #term("downlink")[The radio link from a
spacecraft down to the ground.] at 2 Mb/s. When the #term("downlink") drops,
it waits for the next pass.
```)

- Later uses leave the definition out and link to the same entry.
- A term with no definition on the page, or defined twice, fails the build.

`image` puts a picture above the definition, and `credit` an attribution
under it, as licences such as CC BY ask.

#demo(```typst
#import "/utils/ui.typ": term

Each channel of #term(
  "telemetry",
  image: "/assets/images/telemetry.png",
  alt: "Telemetry curves",
  credit: [Plot: sample image bundled with the theme],
)[Measurements a spacecraft sends home: temperatures, voltages, attitude.]
is plotted against mission time.
```)

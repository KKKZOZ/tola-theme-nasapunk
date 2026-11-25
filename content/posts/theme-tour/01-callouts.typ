#import "@tola/address:0.0.0": output-url
#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/nasapunk:0.0.0": callout, cols, demo, fold, hint, qa, term, xref

#let demo = demo.with(scope: (callout: callout, cols: cols, fold: fold, hint: hint, qa: qa, term: term))

#tola-meta((
  title: "[Tour 01] In-Article Components",
  date: "2025-03-12",
  summary: "Part one of a sample series: checklists, callouts, hints, folds, questions and answers, columns, footnotes, terms and references.",
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
  title: "[Tour 01] In-Article Components",
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

`callout` boxes a short message. `kind` sets the colour
and the status label: `note` (the default), `info`, `warning`, `success` or
`danger`. `title` replaces the label.

#demo(```typst
#import "@tola-modules/nasapunk:0.0.0": callout

#callout(kind: "success", title: [READY])[All three checks pass.]

#callout(kind: "warning")[A broken link, image or section anchor fails the
build. That is deliberate#footnote[See `[build.references]` in `tola.toml`.].]
```)

= Hints

`hint` is lighter than a callout: an engineering annotation with a target
mark and no box, for a tip or an aside next to the text it concerns.

#demo(```typst
#import "@tola-modules/nasapunk:0.0.0": hint

#hint[Run `tola dev` while writing: it rebuilds the site on every *save*.]
```)

= Folds

`fold` shuts a panel under its title, for an answer, a long listing or a
detail most readers skip. `title` names it (`Details` by default) and
`open: true` starts it unfolded.

#demo(```typst
#import "@tola-modules/nasapunk:0.0.0": fold

#fold(title: [Why does a broken anchor fail the build?])[
  A link to a missing section looks fine in the source and only shows up
  when a reader clicks it. Failing the build catches it first.
]

#fold(title: [Pre-flight list], open: true)[
  + `tola build` passes.
  + Both themes checked.
]
```)

= Questions and Answers

`qa` sets one question with its answer folded shut under it, for the
questions a reader is likely to ask after a section. The question sits on a
warm tint and the answer under it on the page, framed by an orange rule on
the left. A click on the question opens the answer, and `open: true` starts
it open. The blocks on a page are tagged Q01, Q02, ... in order, and blocks
that follow each other join into one frame. `tag` replaces the number with
your own label.

#demo(```typst
#import "@tola-modules/nasapunk:0.0.0": qa

#qa[
  Does `tola dev` rebuild the whole site on every save?
][
  No. It rebuilds the pages that depend on the changed file, so a post
  shows the edit in about a second.
]

#qa(open: true)[
  Why does a broken anchor fail the build?
][
  A link to a missing section looks fine in the source and only shows up
  when a reader clicks it. Failing the build catches it first.
]
```)

= Columns

`cols` sets blocks side by side, such as two versions of the same code, and
stacks them on screens 600px wide or less. Each block is a trailing `[...]`,
and `labels` puts one label above each, in order.

#demo(````typst
#import "@tola-modules/nasapunk:0.0.0": cols

#cols(labels: ([While writing], [Before pushing]))[
  ```sh
  tola dev
  ```
][
  ```sh
  tola build
  ```
]
````)

Every block shares one row unless `columns` says how many fit in it:

#demo(```typst
#import "@tola-modules/nasapunk:0.0.0": cols

#cols(columns: 2)[
  *Uplink*: commands sent up to the spacecraft.
][
  *Downlink*: telemetry sent back to the ground.
][
  *Pass*: the minutes a ground station can see it.
][
  *Blackout*: the time between passes.
]
```)

- `none` in place of a label leaves that block unlabelled.
- A different number of labels and blocks fails the build.
- For images, use `gallery` (#xref("04-style-reference")), which is a
  numbered figure with a caption.

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
#import "@tola-modules/nasapunk:0.0.0": term

The ground station decodes the #term("downlink")[The radio link from a
spacecraft down to the ground.] at 2 Mb/s. When the #term("downlink") drops,
it waits for the next pass.
```)

- Later uses leave the definition out and link to the same entry.
- A term with no definition on the page, or defined twice, fails the build.

`image` puts a picture above the definition, and `credit` an attribution
under it, as licences such as CC BY ask.

#demo(```typst
#import "@tola-modules/nasapunk:0.0.0": term

Each channel of #term(
  "telemetry",
  image: "/assets/images/telemetry.png",
  alt: "Telemetry curves",
  credit: [Plot: sample image bundled with the theme],
)[Measurements a spacecraft sends home: temperatures, voltages, attitude.]
is plotted against mission time.
```)

= References

Typst's own bibliography works as it does on paper. Keep the works in a
`.bib` file (or a Hayagriva `.yml`) beside the post, cite them with `@key`,
and end the post with `#bibliography`:

```typst
Information can be measured @shannon1948, and so can the cost of an
algorithm @knuth1997[ch. 1].

#bibliography("refs.bib")
```

Information can be measured @shannon1948, and so can the cost of an
algorithm @knuth1997[ch. 1]. Hover a citation for the work, or follow it to
the list under the post; the number there leads back to the first place the
work was cited. `#cite(<shannon1948>, form: "prose")` names the author in
the sentence: #cite(<shannon1948>, form: "prose").

The numbers start at 1 on every page. The theme's `bibliography-style`
option picks the style, `"ieee"` unless you change it.

#bibliography("refs.bib")

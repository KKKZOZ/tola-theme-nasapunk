#import "@tola/address:0.0.0": output-url
#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout

#tola-meta((
  title: "[Tour 06] Keyboard Palette",
  date: "2026-11-15",
  summary: "Shortcuts for one palette that searches the site, runs a command or jumps to a section, and single keys to move between posts.",
  tags: ("example", "series"),
  series: "Theme Tour",
))

Every page answers a few shortcuts, borrowed from code editors. Most open the
same palette, a box in the middle of the window with a list under it. Try them
on this page.

= Shortcuts

On Windows and Linux, hold `Ctrl` in place of `Cmd`.

#figure(
  table(
    columns: 3,
    table.header[Keys][Opens][Lists],
    [`Cmd + K`], [Search], [Posts whose text matches, with the passage that matched],
    [`Cmd + Shift + P`], [Commands], [Pages to go to and things to do on this one],
    [`Cmd + Shift + O`], [Sections], [The headings of this page, and its figures],
    [`?`], [Keys], [The shortcuts on this page],
  ),
  caption: [The four shortcuts that open the palette, and the list each one opens it on.],
)

The `⌘K` keycap in the header opens the search on a click. It is hidden on
touch screens, which have no such key, and in narrow windows.

= One box, four lists

How the query starts picks the list, so any shortcut reaches all of them:

#figure(
  table(
    columns: 2,
    table.header[Starts with][List],
    [nothing], [Search],
    [`>`], [Commands],
    [`@`], [Sections],
    [`?`], [Keys],
  ),
  caption: [The first character of the query picks the list: no prefix searches the site, `>` runs commands, `@` jumps to sections.],
)

Open the search, type `>`, and the commands appear. Delete it and the search
is back.

= Inside the palette

#figure(
  table(
    columns: 2,
    table.header[Key][Does],
    [`↑` `↓`], [Move through the list],
    [`Enter`], [Open the entry, or run the command],
    [`Cmd + Enter`], [Open the entry in a new tab],
    [`Esc`], [Close the palette. So does a click outside it, or the shortcut that
      opened it.],
  ),
  caption: [Keys inside the open palette.],
)

= The lists

== Search

The palette asks the same index as the
#link(output-url("search/index.html"))[search page] and shows the first eight
matches, each with its document number. With more than eight, the last entry
leads to the search page for all of them. On the search page itself,
`Cmd + K` puts the cursor in its box.

#callout(kind: "info", title: "In tola dev")[
  `tola dev` skips the search index, so the search list reports that it is
  not built. Commands and sections work as usual. Run `tola build` to try the
  search.
]

== Commands

- Go to a page of the header: Home, Archive, Tags and the rest.
- Switch between the day and night themes.
- Back to top.
- Copy a link to this page.
- On a post: the next and previous posts, copy its citation as a line of
  text or as BibTeX, and print.

Typing narrows the list. Letters match in order, not only side by side:
`swth` finds "Switch to night theme".

== Sections

On a post, the numbered headings, and the figures and tables that have a
caption: on this page, `@list` finds "The lists". On the archive, the tag and
the series pages, the list holds the years, tags and series instead.

= Single keys

These work on their own, with no palette open and the cursor outside a text
box.

#figure(
  table(
    columns: 2,
    table.header[Key][Does],
    [`j` `k`], [Move to the next or previous post of a list: the home page, the
      archive, a tag, a series, search results. `Enter` opens it.],
    [`[` `]`], [Go to the previous or next post; on the home page, the previous
      or next page of the list.],
    [`?`], [List the keys],
  ),
  caption: [Single keys that work with no palette open, as long as the cursor is outside a text box.],
)

= Citing a post

The `Cite` button beside the document number copies the post as one line:
author, title, number, date and address. The palette has it as a command,
and a second one that copies BibTeX, where a numbered post is a
`@techreport` of the site.

= When a shortcut does nothing

Browsers keep some shortcuts for themselves, and a page never sees them. In
Firefox, `Cmd + Shift + P` opens a private window, for one. The palette is
still a prefix away: open it with another shortcut, or with the keycap, and
type `>` or `@`.

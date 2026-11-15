#import "@tola/address:0.0.0": output-url
#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout

#tola-meta((
  title: "[Tour 06] Keyboard Palette",
  date: "2026-11-15",
  summary: "Three shortcuts open one palette: search the site, run a command, or jump to a section.",
  tags: ("example", "series"),
  series: "Theme Tour",
))

Every page answers three shortcuts, borrowed from code editors. They open the
same palette, a box in the middle of the window with a list under it. Try them
on this page.

= Shortcuts

On Windows and Linux, hold `Ctrl` in place of `Cmd`.

#table(
  columns: 3,
  table.header[Keys][Opens][Lists],
  [`Cmd + K`], [Search], [Posts whose text matches, with the passage that matched],
  [`Cmd + Shift + P`], [Commands], [Pages to go to and things to do on this one],
  [`Cmd + Shift + O`], [Sections], [The headings of this page],
)

The `⌘K` keycap in the header opens the search on a click. It is hidden on
touch screens, which have no such key, and in narrow windows.

= One box, three lists

How the query starts picks the list, so any shortcut reaches all three:

#table(
  columns: 2,
  table.header[Starts with][List],
  [nothing], [Search],
  [`>`], [Commands],
  [`@`], [Sections],
)

Open the search, type `>`, and the commands appear. Delete it and the search
is back.

= Inside the palette

#table(
  columns: 2,
  table.header[Key][Does],
  [`↑` `↓`], [Move through the list],
  [`Enter`], [Open the entry, or run the command],
  [`Cmd + Enter`], [Open the entry in a new tab],
  [`Esc`], [Close the palette. So does a click outside it, or the shortcut that
    opened it.],
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
- On a post: the next and previous posts, and print.

Typing narrows the list. Letters match in order, not only side by side:
`swth` finds "Switch to night theme".

== Sections

On a post, the numbered headings: on this page, `@list` finds "The lists".
On the archive, the tag and the series pages, the list holds the years, tags
and series instead.

= When a shortcut does nothing

Browsers keep some shortcuts for themselves, and a page never sees them. In
Firefox, `Cmd + Shift + P` opens a private window, for one. The palette is
still a prefix away: open it with another shortcut, or with the keycap, and
type `>` or `@`.

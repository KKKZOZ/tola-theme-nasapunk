# The `math-check` build hook (tola-module.toml): under `tola dev`, warns
# about formulas that cannot copy as LaTeX and copy as a placeholder instead
# (templates/latex.typ), pointing at them in the source like a compiler
# warning. Tola shows the warnings after the rebuild; the site updates as
# usual. Production builds skip it, so a deployment is never held up.
#
# Formulas from utils/mitex.typ copy their own source and are fine. A page
# that shows unconvertible formulas on purpose opts out with a line
# `// math-check: ignore` in its source.
#
# Offsets into a source are indices into its list of characters.

use tola [diagnostic get-hook get-site]

const PLACEHOLDER = '\text{[unsupported formula]}'
const HELP = "write it with `mi` / `mitex` to copy as written, or put `// math-check: ignore` in the source to leave the page out"

# ============================================================================
# Pages
# ============================================================================

def decode-html []: string -> string {
  # `&amp;` last, so "&amp;lt;" stays "&lt;".
  str replace --all "&lt;" "<"
  | str replace --all "&gt;" ">"
  | str replace --all "&quot;" '"'
  | str replace --all "&#39;" "'"
  | str replace --all "&amp;" "&"
}

def attr [tag: string, name: string] {
  $tag | parse --regex ('\s' + $name + '="(?<value>[^"]*)"') | get -o 0.value
}

def words []: string -> list<string> {
  split row --regex '\s+'
  | each { str lowercase | str replace --all --regex '[^\p{L}\p{N}]' '' }
  | where $it != ""
}

# The text of the page between the previous formula and the next.
def text-before []: string -> string {
  str replace --regex '(?s)^.*</svg>' ''
  | str replace --regex '^[^<]*>' ''
  | str replace --all --regex '</?span[^>]*>' ''
  | str replace --all --regex '<[^>]*>' ' '
  | decode-html
  | str replace --all --regex '\s+' ' '
  | str trim
}

# Whether text ends inside the element that `open` starts and the first
# `close` after it ends, given whether it starts inside one.
def inside [was: bool, text: string, open: string, close: string] {
  let opened = $text | str index-of --end $open
  let closed = $text | str index-of --end $close
  if $opened == -1 and $closed == -1 { $was } else { $opened > $closed }
}

# The page's formulas in order: {issues, latex, before, place}. A formula
# from utils/mitex.typ never has issues, and its `latex` is the source it was
# written in. `place` is "text", "notes" (the notes and terms after the text,
# in the order their sources run), or "toc" (a heading's copy in the table of
# contents).
def page-formulas [html: string] {
  let math = '<(?:span|div) role="math"[^>]*>'
  let tags = $html | parse --regex ('(?<tag>' + $math + ')') | get tag
  # The text before each formula, back to the one before it.
  let between = $html | split row --regex $math
  mut notes = false
  mut toc = false
  mut out = []
  for k in 0..<($tags | length) {
    let tag = $tags | get $k
    let text = $between | get $k
    $notes = (inside $notes $text '<section class="endnotes' '</section>')
    $toc = (inside $toc $text '<aside class="toc"' '</aside>')
    let wrapper = $text | parse --regex '<(?:span|div) data-latex="(?<latex>[^"]*)">$' | get -o 0.latex
    let issues = if $wrapper == null { attr $tag "data-latex-issues" | default "" } else { "" }
    $out = $out | append {
      issues: (if $issues == "" { null } else { $issues | decode-html })
      latex: ($wrapper | default (attr $tag "data-latex") | default "" | decode-html)
      before: ($text | text-before)
      place: (if $toc { "toc" } else if $notes { "notes" } else { "text" })
    }
  }
  $out
}

# ============================================================================
# Sources
# ============================================================================

def source-of [content: string, url: string] {
  let page = $url | str replace --regex '^/' '' | str replace --regex '/$' ''
  let base = if $page == "" { $content } else { $content | path join $page }
  [$"($base).typ" ($base | path join "index.typ")] | where ($it | path exists) | get -o 0
}

# A line `// math-check: ignore` anywhere in a source leaves its page out of
# the report, for pages that show such formulas on purpose.
def ignored [src: string] {
  $src =~ '(?m)^[ \t]*//[ \t]*math-check:[ \t]*ignore[ \t]*$'
}

# The first index at or after `from` where `needle` (characters) starts.
def find [cs: list<string>, needle: list<string>, from: int] {
  let n = $needle | length
  let first = $needle | first
  let last = ($cs | length) - $n
  mut k = $from
  while $k <= $last {
    if ($cs | get $k) == $first and ($cs | slice $k..<($k + $n)) == $needle { return $k }
    $k += 1
  }
  null
}

# The end of the raw text whose backticks start at `at`.
def raw-end [cs: list<string>, at: int, to: int] {
  mut n = 0
  while ($cs | get -o ($at + $n)) == "`" { $n += 1 }
  let end = find $cs (1..$n | each { "`" }) ($at + $n)
  if $end == null { $to } else { $end + $n }
}

# The end of the bracket that opens at `at`, skipping raw text.
def balanced [cs: list<string>, at: int, to: int, open: string, close: string] {
  mut depth = 0
  mut i = $at
  while $i < $to {
    let c = $cs | get $i
    if $c == "`" {
      $i = (raw-end $cs $i $to) - 1
    } else if $c == $open {
      $depth += 1
    } else if $c == $close {
      $depth -= 1
      if $depth == 0 { return ($i + 1) }
    }
    $i += 1
  }
  $to
}

# Formulas in Typst source, in order, as {start, end, raw}: `$...$` (with
# anything nested inside it), `#mi(...)` / `#mitex(...)`. Comments and raw
# text are skipped, except ```typst blocks, whose formulas count with `raw`
# set, since `demo` and the like render them; `$` inside strings counts, as
# `eval` turns such strings into formulas. `breaks` lists the indices of the
# line breaks.
def source-formulas [cs: list<string>, breaks: list<int>, from: int, to: int, raw: bool] {
  mut out = []
  mut i = $from
  while $i < $to {
    let c = $cs | get $i
    let next = $cs | get -o ($i + 1)
    if $c == "\\" {
      $i += 1
    } else if $c == "/" and $next == "/" and ($i == 0 or ($cs | get ($i - 1)) =~ '^\s$') {
      $i = ($breaks | where $it >= $i | get -o 0 | default $to)
    } else if $c == "/" and $next == "*" {
      let end = find $cs ["*" "/"] $i
      $i = if $end == null { $to } else { $end + 1 }
    } else if $c == "`" {
      let end = raw-end $cs $i $to
      let eol = $breaks | where $it >= $i | get -o 0
      let block = if $eol == null { null } else {
        $cs | slice $i..$eol | str join
        | parse --regex '^(?<ticks>`{3,})(?:typst|typ)\b[^\n]*\n' | get -o 0.ticks
      }
      if $block != null {
        $out = $out | append (source-formulas $cs $breaks ($eol + 1) ($end - ($block | str length)) true)
      }
      $i = $end - 1
    } else if $c == "#" and ($cs | slice $i..<($i + 9) | str join) =~ '^#(mi|mitex|mimath)\(' {
      let end = balanced $cs ($i + ($cs | slice $i..<($i + 9) | str join | str index-of "(")) $to "(" ")"
      $out = $out | append {start: $i, end: $end, raw: $raw}
      $i = $end - 1
    } else if $c == "$" {
      mut j = $i + 1
      while $j < $to and ($cs | get $j) != "$" {
        let d = $cs | get $j
        if $d == "\\" {
          $j += 1
        } else if $d == "[" and ($cs | slice ([$i ($j - 80)] | math max)..<$j | str join) =~ '#[A-Za-z0-9_.-]*(\([^)]*\))?$' {
          $j = (balanced $cs $j $to "[" "]") - 1
        }
        $j += 1
      }
      $out = $out | append {start: $i, end: ($j + 1), raw: $raw}
      $i = $j
    }
    $i += 1
  }
  $out
}

# ============================================================================
# Matching
# ============================================================================
# Page and source rarely have the same formulas: `demo` shows a formula's
# source and renders it, a footnote's formula moves to the notes, a string
# is drawn only by `eval`. So the two lists are aligned as a diff aligns
# lines, keeping their order and pairing the formulas that look most alike.

# Words, and LaTeX command names without their backslash.
def tokens []: string -> list<string> {
  str replace --all --regex '\\([a-zA-Z]+)' ' ${1} '
  | str lowercase
  | parse --regex '(?<token>[\p{L}\p{N}]+)'
  | get token
  | uniq
}

# Share of the tokens two sets have in common (Jaccard index).
def overlap [a: list<string>, b: list<string>] {
  let n = $a | where $it in $b | length
  if $n == 0 { 0.0 } else { $n / (($a | length) + ($b | length) - $n) }
}

# How many of the last five words two word lists end with, from 0 to 1.
def same-ending [a: list<string>, b: list<string>] {
  let a = $a | reverse
  let b = $b | reverse
  mut k = 0
  while $k < 5 and $k < ($a | length) and $k < ($b | length) and ($a | get $k) == ($b | get $k) { $k += 1 }
  $k / 5
}

# How likely page formula `f` was written as source formula `s`: any pair
# scores a little, so formulas pair up in order; what they contain, the
# words before them, and the source naming what stopped the conversion
# ("box", "augment", "⧺") add to it. Formulas in ```typst blocks come last,
# as most such blocks are only shown.
def likeness [f: record, s: record] {
  let named = $f.issues != null and ($f.issues | split row ", " | any {|issue| $s.text | str contains $issue })
  (0.1 + (overlap $f.tokens $s.tokens) + (same-ending $f.words $s.words)
    + (if $named { 0.5 } else { 0.0 }) - (if $s.raw { 0.05 } else { 0.0 }))
}

# Pairs {f, s} of indices into `fs` and `ss`, in order, with the highest
# total likeness.
def align [fs: list, ss: list] {
  let m = $fs | length
  let n = $ss | length
  let pair = $fs | each {|f| $ss | each {|s| likeness $f $s } }
  # best.i.j: the highest total for fs from i and ss from j.
  mut below = 0..$n | each { 0.0 }
  mut best = [$below]
  for i in ($m - 1)..0 {
    if $m == 0 { break }
    let row = $pair | get $i
    mut here = [0.0]
    for j in ($n - 1)..0 {
      if $n == 0 { break }
      let value = [($below | get $j) ($here | last) (($row | get $j) + ($below | get ($j + 1)))] | math max
      $here = $here | append $value
    }
    $below = $here | reverse
    $best = $best | append [$below]
  }
  let best = $best | reverse
  mut out = []
  mut i = 0
  mut j = 0
  while $i < $m and $j < $n {
    let value = $best | get $i | get $j
    if $value == (($pair | get $i | get $j) + ($best | get ($i + 1) | get ($j + 1))) {
      $out = $out | append {f: $i, s: $j}
      $i += 1
      $j += 1
    } else if $value == ($best | get ($i + 1) | get $j) {
      $i += 1
    } else {
      $j += 1
    }
  }
  $out
}

# The source formula of each page formula with issues, where one is found,
# as {page, at}. Formulas in the text are aligned first, then those in the
# notes against the source formulas left over.
def locate [cs: list<string>, breaks: list<int>, page: list] {
  let formulas = source-formulas $cs $breaks 0 ($cs | length) false | sort-by start
  let ss = $formulas | enumerate | each {|e|
    let s = $e.item
    let from = if $e.index > 0 { ($formulas | get ($e.index - 1)).end } else { [0 ($s.start - 3000)] | math max }
    let text = $cs | slice ($s.start)..<($s.end) | str join
    let before = $cs | slice $from..<($s.start) | str join | str replace --all --regex '[#*_=\[\](){}"`]' ' '
    $s | merge {index: $e.index, text: $text, tokens: ($text | tokens), words: ($before | words | last 5)}
  }
  let fs = $page | enumerate | each {|e|
    $e.item | merge {
      index: $e.index
      tokens: (if $e.item.issues != null { [] } else { $e.item.latex | tokens })
      words: ($e.item.before | words | last 5)
    }
  }
  mut found = []
  mut used = []
  for place in ["text" "notes"] {
    let here = $fs | where place == $place
    let free = $ss | where index not-in $used
    for p in (align $here $free) {
      let f = $here | get $p.f
      let s = $free | get $p.s
      $used = $used | append $s.index
      if $f.issues != null { $found = $found | append {page: $f.index, at: $s} }
    }
  }
  $found
}

# ============================================================================
# Report
# ============================================================================

def spaces [width: int] { "" | fill --width $width }

# The colors of Tola's own diagnostics: blue for the frame, yellow for what a
# warning points at. Tola keeps them in a note when it draws in color and
# drops them otherwise (NO_COLOR, a pipe, the log).
const BORDER = (ansi blue)
const MARK = (ansi yellow)
const RESET = (ansi reset)

# The source line at `at`, framed and underlined like a compiler's.
def frame [file: string, cs: list<string>, breaks: list<int>, at: record, issues: string] {
  let line_start = ($breaks | where $it < $at.start | last 1 | get -o 0 | default (-1)) + 1
  let line_end = $breaks | where $it >= $at.start | get -o 0 | default ($cs | length)
  let line = ($breaks | where $it < $at.start | length) + 1
  let col = $at.start - $line_start
  let text = $cs | slice $line_start..<$line_end | str join | str replace --regex '\r$' '' | str replace --all "\t" " " | split chars
  let width = [1 (([$at.end $line_end] | math min) - $at.start)] | math max
  let before = $text | first $col | str join
  let marked = $text | skip $col | first $width | str join
  let after = $text | skip ($col + $width) | str join
  let pad = spaces ($line | into string | str length)
  let carets = "" | fill --character '^' --width $width
  [
    $"($pad) ($BORDER)┌─($RESET) ($file):($line):($col + 1)"
    $"($pad) ($BORDER)│($RESET)"
    $"($BORDER)($line) │($RESET) ($before)($MARK)($marked)($RESET)($after)"
    $"($pad) ($BORDER)│($RESET) (spaces $col)($MARK)($carets) no LaTeX for ($issues)($RESET)"
    $"($pad) ($BORDER)│($RESET)"
  ]
}

def main [] {
  let hook = get-hook
  if $hook.mode != "dev" {
    [] | diagnostic submit
    return
  }
  let site = get-site
  let input = $hook.input-dir

  let pages = do { cd $input; glob "**/*.html" }
    | each {|file| {file: $file, name: ($file | path relative-to $input | str replace --all '\' '/')} }
    | sort-by name
  mut issues = []
  for p in $pages {
    let page = page-formulas (open --raw $p.file | decode utf-8)
    # A heading's copy in the table of contents is reported at the heading.
    if not ($page | any {|f| $f.issues != null and $f.place != "toc" }) { continue }
    let url = "/" + ($p.name | str replace --regex 'index\.html$' '')
    let source = source-of $site.content-root $url
    let src = if $source == null { null } else { open --raw $source | decode utf-8 }
    if $src != null and (ignored $src) { continue }
    # Shown relative to the site root, as Tola shows its own diagnostics.
    let path = if $source == null { null } else {
      try { $source | path relative-to $site.root } catch { $source } | str replace --all '\' '/'
    }
    let cs = if $src == null { [] } else { $src | split chars }
    let breaks = $cs | enumerate | where item == "\n" | get index
    let found = if $src == null { [] } else { locate $cs $breaks $page }

    for e in ($page | enumerate) {
      let f = $e.item
      if $f.issues == null or $f.place == "toc" { continue }
      let at = $found | where page == $e.index | get -o 0.at
      # Without a source position: the page, and the text before the formula.
      let lines = if $at != null { frame $path $cs $breaks $at $f.issues } else {
        let shown = if $path == null { "" } else { " (" + $path + ")" }
        let before = $f.before | split chars | last 60 | str join
        [
          $" ($BORDER)┌─($RESET) ($url)($shown)"
          $" ($BORDER)│($RESET)"
          $" ($BORDER)│($RESET) …($before) ($MARK)⟨formula⟩ no LaTeX for ($f.issues)($RESET)"
          $" ($BORDER)│($RESET)"
        ]
      }
      $issues = $issues | append (diagnostic issue "formula cannot copy as LaTeX"
        --severity warning --code math-check
        --notes [($lines | str join "\n") $"it copies as ($PLACEHOLDER)"]
        --hints [$HELP])
    }
  }
  $issues | diagnostic submit
}

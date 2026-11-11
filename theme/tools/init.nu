# Creates a NASApunk blog:
#   tola init my-blog --from <theme> --alias nasapunk
# Flags after `--` fill in the site, e.g.
#   ... -- --title "My Blog" --author "Ada" --language zh
# Tola replaces the `path` written below with the source the theme came
# from (Git, archive or directory) and locks it in tola.lock.

use tola get-init

const CONFIG = r#'
# Tola configuration
# https://github.com/tola-rs/tola-ssg

# tola help "[site]"
[site]
# origin = ""  # Public address, e.g. "https://example.com"; needed for feeds and sitemaps
base-path = "/"
title = {title}
authors = [{ name = {author} }]
description = {description}
language = {language}

# tola help "[build]"
# The theme builds every page. To give it Typst values (extra <head>
# markup, comments under posts), write a site.typ that calls the theme's
# `render-site` and set `entry = "site.typ"`; see
# https://github.com/KKKZOZ/tola-theme-nasapunk/blob/preview/site.typ
[build]
entry = { module = {alias} }

# tola help "[modules]"
# `tola update {name}` fetches a newer theme and records it in tola.lock.
[modules.{name}]
path = {root}

# The theme's options. All of them, with defaults and notes:
# https://github.com/KKKZOZ/tola-theme-nasapunk/blob/preview/theme/tola-module.toml
[modules.{name}.options]
doc-prefix = "TN"

# tola help "[typst.fonts]"
# Figures and preview images are drawn in the fonts the theme ships. System
# fonts stay on for CJK text (the `cjk-font` option).
[typst.fonts]
paths = []
modules = [{alias}]
system = true

# tola help "[assets]"
# Your own files, such as post images: put them in assets/, uncomment
# `trees` and link them as "/assets/...".
[assets]
cache-busting = true
# trees = [{ source = "assets", url-prefix = "/assets" }]
'#

const HELLO = r#'
#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/{name}:0.0.0": callout

#tola-meta((
  title: "Hello",
  date: "{today}",
  summary: "The first post.",
  tags: ("notes",),
))

= First section

#callout(kind: "info")[Written with NASApunk.]

The theme's components, each with its source, are shown at
https://kkkzoz.github.io/tola-theme-nasapunk/.
'#

const ABOUT = r#'
#import "@tola/source:0.0.0": tola-meta
#tola-meta((title: "About"))

About this blog.
'#

const IGNORE = r#'
/public/
/.public-swap/
/.tola/
/.tola-build.lock
.DS_Store
'#

def main [
  --title: string = "My Blog"           # site title
  --author: string = "Your Name"        # author name
  --description: string = "A blog built with Tola and NASApunk."
  --language: string = "en"             # page language, e.g. en, zh
] {
  let init = get-init
  let out = $init.output-dir
  let name = $init.module.name
  let quote = {|s| $s | to json --raw }

  let config = $CONFIG | str trim --left
    | str replace --all "{title}" (do $quote $title)
    | str replace --all "{author}" (do $quote $author)
    | str replace --all "{description}" (do $quote $description)
    | str replace --all "{language}" (do $quote $language)
    | str replace --all "{alias}" (do $quote $name)
    | str replace --all "{root}" (do $quote $init.module.root)
    | str replace --all "{name}" $name
  let hello = $HELLO | str trim --left
    | str replace --all "{name}" $name
    | str replace --all "{today}" (date now | format date "%Y-%m-%d")

  mkdir ($out | path join "content" "posts")
  $config | save --raw ($out | path join "tola.toml")
  $hello | save --raw ($out | path join "content" "posts" "hello.typ")
  $ABOUT | str trim --left | save --raw ($out | path join "content" "about.typ")
  $IGNORE | str trim --left | save --raw ($out | path join ".gitignore")
  $IGNORE | str trim --left | save --raw ($out | path join ".ignore")
}

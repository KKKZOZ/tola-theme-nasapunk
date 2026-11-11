# The `search` build hook (tola-module.toml): Pagefind indexes the compiled
# pages for /search/. Each run looks up Pagefind's latest release; its
# standalone binary is downloaded once per version and platform into the
# hook's cache (.tola/hooks/...), checked against the SHA-256 the release
# publishes beside it, so a site needs neither Node.js nor npm.

use tola [diagnostic get-hook get-module]

const REPO = "https://github.com/Pagefind/pagefind"

# Report one error and stop: Tola fails the build with the message.
def fail [message: string, ...notes: string] {
  let hint = $"To build without search, set `search = false` under [modules.((get-module).name).options] in tola.toml."
  [(diagnostic issue $message --severity error --code search --notes $notes --hints [$hint])]
  | diagnostic submit
  exit 1
}

# The version of Pagefind's latest release, read from where GitHub's
# /releases/latest redirects to (no API call, so no rate limit).
def latest [] {
  let url = $"($REPO)/releases/latest"
  let response = try { http get --full --redirect-mode manual $url } catch {|err|
    fail "Could not look up Pagefind's latest release." $url $err.msg
  }
  let location = $response.headers.response
    | where ($it.name | str lowercase) == "location"
    | get -o 0.value
    | default ""
  let version = $location | parse --regex '/releases/tag/v(?<version>[^/]+)$' | get -o 0.version
  if $version == null {
    fail "Could not look up Pagefind's latest release." $url $"GitHub answered ($response.status) without a release tag."
  }
  $version
}

# Pagefind's name for this platform, e.g. aarch64-apple-darwin.
def target [] {
  let os = $nu.os-info
  let system = match $os.name {
    "macos" => "apple-darwin"
    "linux" => "unknown-linux-musl"
    "windows" => "pc-windows-msvc"
    "freebsd" => "unknown-freebsd"
    _ => { fail $"Pagefind has no binary for ($os.name)." }
  }
  $"($os.arch)-($system)"
}

# Fetch a release file; a missing one means Pagefind has no build for this
# platform.
def fetch [url: string, version: string] {
  let response = try { http get --raw --full --allow-errors $url } catch {|err|
    fail $"Could not download Pagefind ($version)." $url $err.msg
  }
  if $response.status == 404 {
    fail $"Pagefind ($version) has no binary for ($nu.os-info.name) on ($nu.os-info.arch)." $url
  }
  if $response.status != 200 {
    fail $"Could not download Pagefind ($version)." $url $"GitHub answered ($response.status)."
  }
  $response.body
}

# The binary of Pagefind's latest release, downloaded into the cache when
# that version is not there yet. Older versions are removed from the cache.
def pagefind [hook: record] {
  let version = latest
  let target = target
  let exe = if $nu.os-info.name == "windows" { "pagefind_extended.exe" } else { "pagefind_extended" }
  let dir = $hook.cache-dir | path join $"pagefind-($version)-($target)"
  let binary = $dir | path join $exe
  if ($binary | path exists) { return $binary }

  # The extended build segments Chinese and Japanese.
  let name = $"pagefind_extended-v($version)-($target).tar.gz"
  let url = $"($REPO)/releases/download/v($version)/($name)"
  # "<sha256>  <file name>"
  let expected = fetch $"($url).sha256" $version | decode utf-8 | str trim | split row --regex '\s+' | first
  let file = $hook.temp-dir | path join $name
  fetch $url $version | save --raw $file
  if (open --raw $file | hash sha256) != $expected {
    fail $"The downloaded Pagefind archive does not match its SHA-256." $url
  }

  # Unpack beside the cache and move into place, so an interrupted run never
  # leaves a partial binary behind.
  let unpacked = $hook.temp-dir | path join "pagefind"
  mkdir $unpacked
  let untar = ^tar -xzf $file -C $unpacked | complete
  if $untar.exit_code != 0 {
    fail "Could not unpack the Pagefind archive with tar." ($untar.stderr | str trim)
  }
  ls $hook.cache-dir
  | where type == dir and ($it.name | path basename) =~ '^pagefind-'
  | each {|old| rm --recursive $old.name }
  mv $unpacked $dir
  $binary
}

def main [] {
  let hook = get-hook
  # Pagefind detects the language from each page's `lang`. The
  # `search-language` option, an ISO 639-1 code such as "zh", indexes the
  # whole site as that one language instead.
  let language = (get-module).options | get -o search-language | default ""
  let args = [
    --site $hook.input-dir
    --output-path ($hook.output-dir | path join "pagefind")
  ] ++ (if $language != "" { [--force-language $language] } else { [] })

  let run = run-external (pagefind $hook) ...$args | complete
  if $run.exit_code != 0 {
    fail "Pagefind could not index the site." ($run.stdout + $run.stderr | str trim)
  }
  [] | diagnostic submit
}

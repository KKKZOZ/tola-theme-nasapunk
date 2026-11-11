# The `search` build hook (tola-module.toml): Pagefind indexes the compiled
# pages for /search/. Pagefind's standalone binary is downloaded once per
# version and platform into the hook's cache (.tola/hooks/...) and checked
# against the digests below, so a site needs neither Node.js nor npm.

use tola [diagnostic get-hook get-module]

const VERSION = "1.5.2"

# SHA-256 of pagefind_extended-v<VERSION>-<target>.tar.gz, from the
# release's .sha256 files. The extended build segments Chinese and Japanese.
const DIGESTS = {
  aarch64-apple-darwin: "99c4b882c81c3c0f046ef85d188daeb8f6f4b598344e885cca7224c7670faec4"
  x86_64-apple-darwin: "35239dfab0bd319d4344c0a4fb0f9228481bab52241021fd2e5f1b2b2b8ce42d"
  aarch64-unknown-linux-musl: "3f667f37fb6c03006212cea2a28cd26c0b47eb797c1113cad716dfff712ff19d"
  x86_64-unknown-linux-musl: "aeb135927856e7a49816cf2c9c2e53167f87afa1f61f7288b7d66c234a950d38"
  aarch64-pc-windows-msvc: "4fd44a27ecc7ac517e1293e8d9e31073d1cf16d457f3126c31374c69e836df43"
  x86_64-pc-windows-msvc: "7ba298054764dfb3c5b982a1eb92607bea8ecaec20a923fc8a4dfd68272ae8a2"
  x86_64-unknown-freebsd: "7baf3d83b5c82922dc2759f1f2fd44d4911987b78dc6d576b91a8438441e6f86"
}

# Report one error and stop: Tola fails the build with the message.
def fail [message: string, ...notes: string] {
  let hint = $"To build without search, set `search = false` under [modules.((get-module).name).options] in tola.toml."
  [(diagnostic issue $message --severity error --code search --notes $notes --hints [$hint])]
  | diagnostic submit
  exit 1
}

def target [] {
  let os = $nu.os-info
  let system = match $os.name {
    "macos" => "apple-darwin"
    "linux" => "unknown-linux-musl"
    "windows" => "pc-windows-msvc"
    "freebsd" => "unknown-freebsd"
    _ => ""
  }
  let target = $"($os.arch)-($system)"
  if $target not-in $DIGESTS {
    fail $"Pagefind has no binary for ($os.name) on ($os.arch)."
  }
  $target
}

# The Pagefind binary, downloaded into the cache on first use.
def pagefind [hook: record] {
  let target = target
  let exe = if $nu.os-info.name == "windows" { "pagefind_extended.exe" } else { "pagefind_extended" }
  let dir = $hook.cache-dir | path join $"pagefind-($VERSION)-($target)"
  let binary = $dir | path join $exe
  if ($binary | path exists) { return $binary }

  let name = $"pagefind_extended-v($VERSION)-($target).tar.gz"
  let url = $"https://github.com/CloudCannon/pagefind/releases/download/v($VERSION)/($name)"
  let file = $hook.temp-dir | path join $name
  try { http get --raw $url | save --raw $file } catch {|err|
    fail $"Could not download Pagefind ($VERSION)." $url $err.msg
  }
  if (open --raw $file | hash sha256) != ($DIGESTS | get $target) {
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

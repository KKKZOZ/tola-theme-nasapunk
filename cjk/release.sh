#!/bin/sh
# Publishes Sarasa Gothic SC as the font module release `sarasa-<version>`
# when this repository has no release for that version yet, then points
# README.md, README.zh-CN.md and tola-module.toml at the new archive.
# Older releases stay, so sites that pinned one keep building.
#
#   cjk/release.sh            # the newest upstream version
#   cjk/release.sh 1.0.43     # a given version
#
# Needs an authenticated gh, plus what pack.sh needs. Prints the version it
# published, or nothing when that release already exists.
set -eu

here=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$here/.." && pwd)
cd "$root"

version=${1:-$(gh api repos/be5invis/Sarasa-Gothic/releases/latest --jq .tag_name)}
version=${version#v}
case $version in
  *[!0-9.]* | "") echo "release.sh: unexpected version '$version'" >&2; exit 1 ;;
esac
tag=sarasa-$version

if gh release view "$tag" >/dev/null 2>&1; then
  echo "release.sh: $tag is already published" >&2
  exit 0
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
(cd "$work" && "$here/pack.sh" "$version" >/dev/null)
archive=$work/nasapunk-cjk.tar.gz
sha=$( (shasum -a 256 "$archive" 2>/dev/null || sha256sum "$archive") | cut -d' ' -f1)

gh release create "$tag" "$archive" \
  --target "$(git rev-parse HEAD)" \
  --latest=false \
  --title "Sarasa Gothic SC $version (font module)" \
  --notes "Sarasa Gothic SC $version (Regular, Italic, Bold, Bold Italic, unhinted) as a Tola module, for CJK text in figures and preview images. This is not a theme release.

Setup: README, \"Chinese text in figures\". SHA-256 of nasapunk-cjk.tar.gz: \`$sha\`

The fonts are under the SIL Open Font License 1.1 (fonts/OFL-SarasaGothic.txt). Built by cjk/release.sh from https://github.com/be5invis/Sarasa-Gothic/releases/tag/v$version." >&2

for file in README.md README.zh-CN.md cjk/tola-module.toml; do
  perl -pi -e '
    s{releases/download/sarasa-[0-9.]+/nasapunk-cjk\.tar\.gz}{releases/download/'"$tag"'/nasapunk-cjk.tar.gz}g;
    s{(nasapunk-cjk\.tar\.gz", sha256 = ")[0-9a-f]{64}}{${1}'"$sha"'}g;
  ' "$file"
done
echo "$version"

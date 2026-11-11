#!/bin/sh
# Builds nasapunk-cjk.tar.gz in the current directory: this module with
# Sarasa Gothic SC Regular, Italic, Bold and Bold Italic from the official
# release. Unhinted files: Typst draws outlines and ignores hinting.
#
#   cjk/pack.sh [version]     # default 1.0.43
#
# Needs curl and bsdtar or 7-Zip (7zz / 7z) to read the .7z release.
set -eu

version=${1:-1.0.43}
here=$(cd "$(dirname "$0")" && pwd)
out=$PWD/nasapunk-cjk.tar.gz
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

repo=https://github.com/be5invis/Sarasa-Gothic
files="SarasaGothicSC-Regular.ttf SarasaGothicSC-Italic.ttf SarasaGothicSC-Bold.ttf SarasaGothicSC-BoldItalic.ttf"
fonts=$work/nasapunk-cjk/fonts
mkdir -p "$fonts"

curl -fsSL -o "$work/sc.7z" "$repo/releases/download/v$version/SarasaGothicSC-TTF-Unhinted-$version.7z"
if command -v bsdtar >/dev/null 2>&1; then
  bsdtar -xf "$work/sc.7z" -C "$fonts" $files
elif command -v 7zz >/dev/null 2>&1; then
  (cd "$fonts" && 7zz e -bd "$work/sc.7z" $files >/dev/null)
elif command -v 7z >/dev/null 2>&1; then
  (cd "$fonts" && 7z e -bd "$work/sc.7z" $files >/dev/null)
else
  echo "pack.sh: install bsdtar (libarchive) or 7-Zip to read the .7z release" >&2
  exit 1
fi
curl -fsSL -o "$fonts/OFL-SarasaGothic.txt" "https://raw.githubusercontent.com/be5invis/Sarasa-Gothic/v$version/LICENSE"
cp "$here/tola-module.toml" "$work/nasapunk-cjk/"

# COPYFILE_DISABLE keeps macOS tar from adding ._ metadata files.
(cd "$work" && COPYFILE_DISABLE=1 tar -cf - nasapunk-cjk | gzip -9n > "$out")
echo "$out"
shasum -a 256 "$out" 2>/dev/null || sha256sum "$out"

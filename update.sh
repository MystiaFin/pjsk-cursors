#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused
# Regenerates sources.json from the official download page.
set -euo pipefail
cd "$(dirname "$0")"

base=https://colorfulstage.com
page=$(curl -fsSL -A 'Mozilla/5.0' "$base/media/download/")

prefetch() {
  local path=$1 lower kind name url
  lower=$(basename "$path" .zip | tr 'A-Z' 'a-z')
  case $lower in *anim*) kind=animated ;; *) kind=static ;; esac
  # "ani file-animation-N25", "Kanade Cursor animation", "Mafuyu Static Cursor" -> n25, kanade, mafuyu
  name=$(sed -E 's/(ani file-animation|cur file-static|cursor|animated|animation|static)//g; s/[ -]//g' <<<"$lower")
  url="$base${path// /%20}"
  jq -n --arg n "$name-$kind" --arg u "$url" \
    --arg h "$(nix store prefetch-file --json --name "$name-$kind.zip" "$url" | jq -r .hash)" \
    '{($n): {url: $u, hash: $h}}'
}
export -f prefetch
export base

grep -oE 'href="/upload_images/media/Download/[^"]+\.zip"' <<<"$page" \
  | sed -E 's/^href="|"$//g' | sort -u \
  | xargs -d '\n' -P 8 -I{} bash -c 'prefetch "$1"' _ {} \
  | jq -s 'add | to_entries | sort_by(.key) | from_entries' > sources.json

echo "$(jq length sources.json) themes written to sources.json"

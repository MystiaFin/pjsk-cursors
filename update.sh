#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused
# shellcheck shell=bash
# rewrites sources.json from the official download page
set -euo pipefail
cd "$(dirname "$0")"

SITE=https://colorfulstage.com
DOWNLOAD_PAGE=$SITE/media/download/

# the site is slow, but 8 at once hasn't been refused
PARALLEL_DOWNLOADS=8

# prints one { "<name>-<style>": { url, hash } } object for a zip path from the page
prefetch_set() {
    local path=$1

    local filename
    filename=$(basename "$path" .zip)
    filename=${filename,,}

    local style=static

    if [[ $filename == *anim* ]]; then
        style=animated
    fi

    # "ani file-animation-n25", "kanade cursor animation", "mafuyu static cursor" -> n25, kanade, mafuyu
    local name
    name=$(sed -E 's/(ani file-animation|cur file-static|cursor|animated|animation|static)//g; s/[ -]//g' <<<"$filename")

    if [[ -z $name ]]; then
        echo "failed to read a set name from $path" >&2
        return 1
    fi

    local url=$SITE${path// /%20}

    local hash
    hash=$(nix store prefetch-file --json --name "$name-$style.zip" "$url" | jq -r .hash)

    jq -n --arg key "$name-$style" --arg url "$url" --arg hash "$hash" '{ ($key): { url: $url, hash: $hash } }'
}

export -f prefetch_set
export SITE

page=$(curl -fsSL -A 'Mozilla/5.0' "$DOWNLOAD_PAGE")

paths=$(grep -oE 'href="/upload_images/media/Download/[^"]+\.zip"' <<<"$page" | sed -E 's/^href="|"$//g' | sort -u)

if [[ -z $paths ]]; then
    echo "failed to find any cursor zips on $DOWNLOAD_PAGE" >&2
    exit 1
fi

# written beside the real file first, so a failed download leaves sources.json as it was
# shellcheck disable=SC2016 # $1 is meant for the inner bash, not this one
xargs -d '\n' -P "$PARALLEL_DOWNLOADS" -I{} bash -c 'prefetch_set "$1"' _ {} <<<"$paths" \
    | jq -s 'add | to_entries | sort_by(.key) | from_entries' > sources.json.new

mv sources.json.new sources.json

echo "$(jq length sources.json) sets written to sources.json"

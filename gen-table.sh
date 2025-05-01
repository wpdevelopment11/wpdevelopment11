#!/usr/bin/env bash

# Find tutorials written by <username> and generate Markdown table for them

set -eu

if (( $# < 1 )); then
    echo "Usage: $0 username [dir]..."
    exit 1
fi

name="$1"
shift

dirs=( "./tutorials" )
if (( $# > 0 )); then
    dirs=( "$@" )
fi;

print_header() {
    cat <<EOF
| Date | Title ||
| --- | --- | --- |
EOF
}

# Create temporary file and add cleanup hook
rows="$(mktemp rows.XXXXXX.md)"
trap 'rm -f "$rows"' EXIT

source_prefix="https://github.com/hetzneronline/community-content/blob/master/tutorials"
tutor_prefix="https://community.hetzner.com/tutorials"

# Run for each english tutorial file
for file in $(find "${dirs[@]}" -type f -name "*.en.md" | sort); do

    author=$(yq --front-matter extract '.author_link' "$file")
    author="${author##"https://github.com/"}"

    if [[ "$author" == "$name" ]]; then

        # Extract metadata
        date=$(yq --front-matter extract '.date' "$file")
        slug=$(yq --front-matter extract '.slug' "$file")
        title=$(yq --front-matter extract '.title' "$file")

        echo "| $date | [$title]($tutor_prefix/$slug) | [Source]($source_prefix/$slug/01.en.md) |" >> "$rows"
    fi
done

print_header
sort -r "$rows"

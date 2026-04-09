#!/bin/bash

set -eu

shopt -s globstar

source_prefix="https://github.com/wpdevelopment11/community-content/blob/master/tutorials"
tutor_prefix="https://community.hetzner.com/tutorials"

print_header() {
    cat <<EOF
| Title | Last Updated ||
| --- | --- | --- |
EOF
}

header_extract() {
    res=$(git grep -hoP -m 1 '(?<=^'"$1"': ")[^"]+' -- "$2")
    echo "$res"
}

last_updated() {
    res=$(git log -1 --format='%cs' -- "$1")
    echo "$res"
}

print_header

for file in $(git grep -l 'author: *"wpdevelopment11"' -- **/*.md); do
    title="$(header_extract title "$file")"
    update="$(last_updated "$file")"
    slug="$(header_extract slug "$file")"
    echo "| [${title}](${tutor_prefix}/${slug}) | $update | [Source](${source_prefix}/${slug}/01.en.md) |"
done | sort -brt '|' -k 3,3

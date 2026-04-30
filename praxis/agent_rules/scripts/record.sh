#!/usr/bin/env bash
# Usage: record.sh <matter_ref> <date> <text>
# Appends a free-text 'note' entry to the matter's info/record.md.
# The first line of <text> becomes the summary; remaining lines (if any) become the body.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 3 ]] || die "usage: record.sh <matter_ref> <date> <text>"

MATTER_DIR="$(resolve_matter "$1")"
DATE="$2"
TEXT="$3"

[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "date must be YYYY-MM-DD"
[[ -n "$TEXT" ]] || die "text must not be empty"

SUMMARY="${TEXT%%$'\n'*}"
if [[ "$TEXT" == *$'\n'* ]]; then
    BODY="${TEXT#*$'\n'}"
else
    BODY=""
fi

append_record "$MATTER_DIR" "$DATE" "note" "$SUMMARY" "$BODY"

echo "$MATTER_DIR/info/record.md"

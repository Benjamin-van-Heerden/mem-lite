#!/usr/bin/env bash
# Usage: add_deadline.sh <matter_ref> <date> <type> <description>
# Appends an open deadline to <matter>/info/deadlines.md and updates next_deadline
# in info/status.md to the earliest open deadline.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 4 ]] || die "usage: add_deadline.sh <matter_ref> <date> <type> <description>"

MATTER_DIR="$(resolve_matter "$1")"
DATE="$2"
TYPE="$3"
DESCRIPTION="$4"

[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "date must be YYYY-MM-DD"

FILE="$MATTER_DIR/info/deadlines.md"
ensure_file_from_skeleton "$FILE" deadlines

echo "- [open] $DATE — $TYPE — $DESCRIPTION" >> "$FILE"

# Recompute next_deadline = earliest open deadline.
NEXT="$(grep -E '^- \[open\] ' "$FILE" | awk '{print $3}' | sort | head -n1 || true)"
[[ -z "$NEXT" ]] && NEXT=null

frontmatter_set "$MATTER_DIR/info/status.md" next_deadline "$NEXT"

append_record "$MATTER_DIR" "$(today)" "deadline:added" "$DATE — $TYPE — $DESCRIPTION"

echo "$FILE"

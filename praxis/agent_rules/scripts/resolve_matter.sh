#!/usr/bin/env bash
# Usage: resolve_matter.sh <matter_ref>
# Closes a matter: sets status to 'resolved' in info/status.md frontmatter and moves
# the directory from matters/open/ to matters/resolved/.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 1 ]] || die "usage: resolve_matter.sh <matter_ref>"

MATTER_DIR="$(resolve_matter "$1")"
STATUS_FILE="$MATTER_DIR/info/status.md"

[[ -f "$STATUS_FILE" ]] || die "no info/status.md in $MATTER_DIR"

CURRENT_STATUS="$(frontmatter_get "$STATUS_FILE" status)"
[[ "$CURRENT_STATUS" == "resolved" ]] && die "matter already resolved"

# matters/open/<dirname>  ->  matters/resolved/<dirname>
PARENT="$(dirname "$MATTER_DIR")"
GRANDPARENT="$(dirname "$PARENT")"
[[ "$(basename "$PARENT")" == "open" ]] || die "matter is not under matters/open/: $MATTER_DIR"

DEST="$GRANDPARENT/resolved/$(basename "$MATTER_DIR")"
[[ -d "$DEST" ]] && die "destination already exists: $DEST"

frontmatter_set "$STATUS_FILE" status resolved
append_record "$MATTER_DIR" "$(today)" "matter:resolved" "Matter closed."
mv "$MATTER_DIR" "$DEST"

echo "$DEST"

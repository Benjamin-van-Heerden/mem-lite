#!/usr/bin/env bash
# Usage: new_function.sh <slug>
# Creates functions/<slug>.typ as an empty starter file.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 1 ]] || die "usage: new_function.sh <slug>"
SLUG="$1"
validate_slug "$SLUG"

ROOT="$(praxis_root)"
DEST="$ROOT/functions/$SLUG.typ"
[[ -f "$DEST" ]] && die "function already exists: functions/$SLUG.typ"

cat > "$DEST" <<EOF
// functions/$SLUG.typ
// TODO: describe what this snippet does and how to import it.

EOF

echo "$DEST"

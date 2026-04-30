#!/usr/bin/env bash
# Usage: new_template.sh <source_typ> <category> <slug>
# Copies an existing typst document into templates/<category>/<slug>.typ.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 3 ]] || die "usage: new_template.sh <source_typ> <category> <slug>"

SRC="$1"
CATEGORY="$2"
SLUG="$3"

validate_slug "$SLUG"
case "$CATEGORY" in
    letters|pleadings|opinions|contracts|memos|components) ;;
    *) die "invalid category '$CATEGORY' (letters|pleadings|opinions|contracts|memos|components)" ;;
esac

ROOT="$(praxis_root)"
[[ -f "$SRC" ]] || SRC="$ROOT/$SRC"
[[ -f "$SRC" ]] || die "source not found: $1"

DEST="$ROOT/templates/$CATEGORY/$SLUG.typ"
[[ -f "$DEST" ]] && die "template already exists: templates/$CATEGORY/$SLUG.typ"

mkdir -p "$(dirname "$DEST")"
cp "$SRC" "$DEST"
echo "$DEST"

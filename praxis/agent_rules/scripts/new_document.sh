#!/usr/bin/env bash
# Usage: new_document.sh <matter_ref> <template_path> <document_slug>
# Copies templates/<template_path>.typ into the matter as NN_<slug>.typ where NN
# is the next zero-padded sequence number.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 3 ]] || die "usage: new_document.sh <matter_ref> <template_path> <document_slug>"

MATTER_DIR="$(resolve_matter "$1")"
TEMPLATE_REL="$2"
DOC_SLUG="$3"

validate_slug "$DOC_SLUG"

ROOT="$(praxis_root)"
TEMPLATE_FILE="$ROOT/templates/$TEMPLATE_REL"
[[ "$TEMPLATE_FILE" == *.typ ]] || TEMPLATE_FILE="$TEMPLATE_FILE.typ"
[[ -f "$TEMPLATE_FILE" ]] || die "template not found: templates/$TEMPLATE_REL"

# Determine next sequence number.
existing=$(find "$MATTER_DIR" -maxdepth 1 -type f -name '[0-9][0-9]_*.typ' 2>/dev/null | wc -l | tr -d ' ')
next=$(printf '%02d' $((existing + 1)))

DEST="$MATTER_DIR/${next}_${DOC_SLUG}.typ"
[[ -f "$DEST" ]] && die "destination already exists: $DEST"

cp "$TEMPLATE_FILE" "$DEST"
echo "$DEST"

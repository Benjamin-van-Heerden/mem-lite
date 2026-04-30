#!/usr/bin/env bash
# Usage: claim_todo.sh <slug>
# Sets status: claimed and moves agent_rules/todos/<slug>.md to claimed/.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 1 ]] || die "usage: claim_todo.sh <slug>"
SLUG="$1"
validate_slug "$SLUG"

ROOT="$(praxis_root)"
mkdir -p "$ROOT/agent_rules/todos/claimed"
SRC="$ROOT/agent_rules/todos/$SLUG.md"
DEST="$ROOT/agent_rules/todos/claimed/$SLUG.md"

[[ -f "$SRC" ]] || die "open todo not found: $SLUG"
[[ -f "$DEST" ]] && die "already claimed: $SLUG"

frontmatter_set "$SRC" status claimed
mv "$SRC" "$DEST"

echo "$DEST"

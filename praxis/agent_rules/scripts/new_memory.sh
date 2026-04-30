#!/usr/bin/env bash
# Usage: new_memory.sh <slug> <title>
# Creates agent_rules/memories/<slug>.md from skeleton.
# Body is left as $CONTENT placeholder — the agent fills it in via Edit.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 2 ]] || die "usage: new_memory.sh <slug> <title>"

SLUG="$1"
TITLE="$2"
validate_slug "$SLUG"

ROOT="$(praxis_root)"
mkdir -p "$ROOT/agent_rules/memories"
FILE="$ROOT/agent_rules/memories/$SLUG.md"
[[ -f "$FILE" ]] && die "memory already exists: $SLUG"

render_skeleton memory \
    "SLUG=$SLUG" \
    "TODAY=$(today)" \
    "TITLE=$TITLE" \
    "CONTENT=_TODO_" \
    > "$FILE"

echo "$FILE"

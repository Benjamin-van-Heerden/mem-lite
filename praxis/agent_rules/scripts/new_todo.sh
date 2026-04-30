#!/usr/bin/env bash
# Usage: new_todo.sh <slug> <title> [priority] [matter_ref]
# priority: low | normal | high  (default: normal)
# Creates agent_rules/todos/<slug>.md from skeleton.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -ge 2 && $# -le 4 ]] || die "usage: new_todo.sh <slug> <title> [priority] [matter_ref]"

SLUG="$1"
TITLE="$2"
PRIORITY="${3:-normal}"
MATTER_INPUT="${4:-}"

validate_slug "$SLUG"
case "$PRIORITY" in low|normal|high) ;; *) die "invalid priority '$PRIORITY'" ;; esac

ROOT="$(praxis_root)"
MATTER_REF="null"
if [[ -n "$MATTER_INPUT" ]]; then
    MATTER_DIR="$(resolve_matter "$MATTER_INPUT")"
    MATTER_REF="${MATTER_DIR#"$ROOT/"}"
fi

mkdir -p "$ROOT/agent_rules/todos"
FILE="$ROOT/agent_rules/todos/$SLUG.md"
[[ -f "$FILE" ]] && die "todo already exists: $SLUG"

render_skeleton todo \
    "SLUG=$SLUG" \
    "TODAY=$(today)" \
    "PRIORITY=$PRIORITY" \
    "MATTER_REF=$MATTER_REF" \
    "TITLE=$TITLE" \
    "DESCRIPTION=_TODO_" \
    > "$FILE"

echo "$FILE"

#!/usr/bin/env bash
# Usage: new_log.sh [matter_ref]
# Creates agent_rules/log/<YYYYMMDD-HHMMSS>_log.md from skeleton.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

ROOT="$(praxis_root)"
MATTER_REF="null"
if [[ $# -ge 1 ]] && [[ -n "$1" ]]; then
    MATTER_DIR="$(resolve_matter "$1")"
    # Store path relative to root.
    MATTER_REF="${MATTER_DIR#"$ROOT/"}"
fi

mkdir -p "$ROOT/agent_rules/log"
FILE="$ROOT/agent_rules/log/$(now_stamp)_log.md"

render_skeleton log \
    "TODAY=$(today)" \
    "TIME=$(now_time)" \
    "MATTER_REF=$MATTER_REF" \
    > "$FILE"

echo "$FILE"

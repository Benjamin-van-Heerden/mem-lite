#!/usr/bin/env bash
# Usage: list_matter_todos.sh <matter_ref>
# Lists open todos scoped to the given matter.
# Output: TSV columns — slug | priority | title

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 1 ]] || die "usage: list_matter_todos.sh <matter_ref>"

ROOT="$(praxis_root)"
MATTER_DIR="$(resolve_matter "$1")"
MATTER_REF="${MATTER_DIR#"$ROOT/"}"

TODOS_DIR="$ROOT/agent_rules/todos"
[[ -d "$TODOS_DIR" ]] || { echo "(no todos yet)"; exit 0; }

printf 'slug\tpriority\ttitle\n'

found=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    [[ -d "$f" ]] && continue
    status=$(frontmatter_get "$f" status)
    [[ "$status" == "open" ]] || continue
    matter=$(frontmatter_get "$f" matter)
    [[ "$matter" == "$MATTER_REF" ]] || continue
    slug=$(frontmatter_get "$f" slug)
    priority=$(frontmatter_get "$f" priority)
    title=$(awk '/^# /{sub(/^# /,""); print; exit}' "$f")
    printf '%s\t%s\t%s\n' "$slug" "$priority" "$title"
    found=1
done < <(find "$TODOS_DIR" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort)

if [[ "$found" -eq 0 ]]; then
    echo "(no open todos for this matter)"
fi

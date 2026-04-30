#!/usr/bin/env bash
# Usage: list_open_matters.sh
# Outputs a TSV table of all open matters across all clients.
# Columns: client | matter | type | priority | next_deadline | open_todos | path

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

ROOT="$(praxis_root)"
CLIENTS_DIR="$ROOT/clients"
TODOS_DIR="$ROOT/agent_rules/todos"

[[ -d "$CLIENTS_DIR" ]] || { echo "(no clients yet)"; exit 0; }

# Pre-extract (matter_ref \t 1) for every open todo with a matter, into a temp
# file. Counts per matter are derived later via grep. Avoids associative arrays
# (bash 3.2 on macOS doesn't support them).
TODO_INDEX="$(mktemp)"
trap 'rm -f "$TODO_INDEX"' EXIT
if [[ -d "$TODOS_DIR" ]]; then
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        [[ -d "$f" ]] && continue
        status=$(frontmatter_get "$f" status)
        [[ "$status" == "open" ]] || continue
        matter=$(frontmatter_get "$f" matter)
        [[ -z "$matter" || "$matter" == "null" ]] && continue
        printf '%s\n' "$matter" >> "$TODO_INDEX"
    done < <(find "$TODOS_DIR" -maxdepth 1 -type f -name '*.md' 2>/dev/null)
fi

printf 'client\tmatter\ttype\tpriority\tnext_deadline\topen_todos\tpath\n'

found=0
while IFS= read -r status_file; do
    [[ -z "$status_file" ]] && continue
    found=1
    # status_file = clients/<client>/matters/open/<matter>/info/status.md
    matter_dir="$(dirname "$(dirname "$status_file")")"
    matter_name="$(basename "$matter_dir")"
    client="$(basename "$(dirname "$(dirname "$(dirname "$matter_dir")")")")"
    type=$(frontmatter_get "$status_file" matter_type)
    priority=$(frontmatter_get "$status_file" priority)
    deadline=$(frontmatter_get "$status_file" next_deadline)
    rel="${matter_dir#"$ROOT/"}"
    todos=$(grep -cFx "$rel" "$TODO_INDEX" 2>/dev/null || true)
    [[ -z "$todos" ]] && todos=0
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$client" "$matter_name" "$type" "$priority" "$deadline" "$todos" "$rel"
done < <(find "$CLIENTS_DIR" -mindepth 6 -maxdepth 6 -type f -name status.md -path '*/matters/open/*/info/status.md' 2>/dev/null | sort)

if [[ "$found" -eq 0 ]]; then
    echo "(no open matters)"
fi

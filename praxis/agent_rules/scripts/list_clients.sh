#!/usr/bin/env bash
# Usage: list_clients.sh
# Outputs a TSV table of all clients (open and dormant).
# Columns: slug | display_name | client_type | open_matters | resolved_matters

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

ROOT="$(praxis_root)"
CLIENTS="$ROOT/clients"

[[ -d "$CLIENTS" ]] || { echo "(no clients yet)"; exit 0; }

printf 'slug\tdisplay_name\tclient_type\topen_matters\tresolved_matters\n'

found=0
while IFS= read -r profile; do
    [[ -z "$profile" ]] && continue
    found=1
    slug="$(basename "$(dirname "$profile")")"
    display="$(frontmatter_get "$profile" display_name)"
    type="$(frontmatter_get "$profile" client_type)"
    open_count=$(find "$CLIENTS/$slug/matters/open" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    resolved_count=$(find "$CLIENTS/$slug/matters/resolved" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    printf '%s\t%s\t%s\t%s\t%s\n' "$slug" "$display" "$type" "$open_count" "$resolved_count"
done < <(find "$CLIENTS" -mindepth 2 -maxdepth 2 -type f -name profile.md 2>/dev/null | sort)

if [[ "$found" -eq 0 ]]; then
    echo "(no clients yet)"
fi

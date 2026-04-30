#!/usr/bin/env bash
# Usage: upcoming_deadlines.sh [days]
# Default window: 14 days. Lists all open deadlines within the window across all
# open matters, sorted by date.
# Output: date | matter_path | type | description

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

DAYS="${1:-14}"
ROOT="$(praxis_root)"

# Compute cutoff date (BSD/GNU date compatible).
if date -v +1d >/dev/null 2>&1; then
    CUTOFF="$(date -v +"${DAYS}d" +%Y-%m-%d)"
else
    CUTOFF="$(date -d "+${DAYS} days" +%Y-%m-%d)"
fi
TODAY="$(today)"

printf 'date\tmatter\ttype\tdescription\n'

found=0
while IFS= read -r dfile; do
    [[ -z "$dfile" ]] && continue
    # dfile = clients/<client>/matters/open/<matter>/info/deadlines.md
    matter_dir="$(dirname "$(dirname "$dfile")")"
    rel="${matter_dir#"$ROOT/"}"
    while IFS= read -r line; do
        # Parse: - [open] YYYY-MM-DD — TYPE — DESCRIPTION
        [[ "$line" =~ ^-\ \[open\]\ ([0-9]{4}-[0-9]{2}-[0-9]{2})\ —\ ([^—]+)\ —\ (.+)$ ]] || continue
        d="${BASH_REMATCH[1]}"
        t="${BASH_REMATCH[2]}"
        desc="${BASH_REMATCH[3]}"
        # In window: TODAY <= d <= CUTOFF (string compare works for ISO dates).
        [[ "$d" < "$TODAY" || "$d" > "$CUTOFF" ]] && continue
        # Trim whitespace.
        t="${t%"${t##*[![:space:]]}"}"; t="${t#"${t%%[![:space:]]*}"}"
        printf '%s\t%s\t%s\t%s\n' "$d" "$rel" "$t" "$desc"
        found=1
    done < "$dfile"
done < <(find "$ROOT/clients" -mindepth 6 -maxdepth 6 -type f -name deadlines.md -path '*/matters/open/*/info/deadlines.md' 2>/dev/null | sort)

if [[ "$found" -eq 0 ]]; then
    echo "(no deadlines within $DAYS days)"
fi

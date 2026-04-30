#!/usr/bin/env bash
# Usage: list_unparsed.sh <matter_ref>
# Lists files in the matter's raw/ that have no corresponding file in reference/
# (matched by basename without extension).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 1 ]] || die "usage: list_unparsed.sh <matter_ref>"
MATTER_DIR="$(resolve_matter "$1")"

RAW="$MATTER_DIR/raw"
REF="$MATTER_DIR/reference"

[[ -d "$RAW" ]] || { echo "(no raw/ directory)"; exit 0; }

found=0
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    base="$(basename "$f")"
    stem="${base%.*}"
    if ! find "$REF" -maxdepth 1 -type f -name "$stem.*" 2>/dev/null | grep -q .; then
        echo "$f"
        found=1
    fi
done < <(find "$RAW" -maxdepth 1 -type f 2>/dev/null | sort)

if [[ "$found" -eq 0 ]]; then
    echo "(all raw files have a reference counterpart)"
fi

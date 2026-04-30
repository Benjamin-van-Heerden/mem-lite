#!/usr/bin/env bash
# Usage: find_matter.sh <pattern>
# Substring search across open and resolved matter directory names.
# Outputs matching paths, one per line.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 1 ]] || die "usage: find_matter.sh <pattern>"
PATTERN="$1"
ROOT="$(praxis_root)"

find "$ROOT/clients" -mindepth 4 -maxdepth 4 -type d -name "*$PATTERN*" 2>/dev/null | \
    sed "s|^$ROOT/||" | sort

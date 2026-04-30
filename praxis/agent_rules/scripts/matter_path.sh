#!/usr/bin/env bash
# Usage: matter_path.sh <ref>
# Resolves a matter reference (slug, partial dir name, or path) to a unique full path.
# Errors if zero or multiple matches.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 1 ]] || die "usage: matter_path.sh <ref>"
resolve_matter "$1"

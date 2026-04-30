#!/usr/bin/env bash
# Usage: lint.sh
# Validates frontmatter on all clients and matters. Exits non-zero if any issue.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

ROOT="$(praxis_root)"
errors=0

check_required() {
    local file="$1" key="$2"
    local v
    v=$(frontmatter_get "$file" "$key")
    if [[ -z "$v" ]]; then
        echo "  ✗ $file: missing required key '$key'"
        errors=$((errors + 1))
    fi
}

check_in_set() {
    local file="$1" key="$2" allowed="$3"
    local v
    v=$(frontmatter_get "$file" "$key")
    [[ -z "$v" ]] && return
    if ! grep -qx "$v" <<< "$allowed"; then
        echo "  ✗ $file: '$key' = '$v' (allowed: $(echo "$allowed" | tr '\n' '|' | sed 's/|$//'))"
        errors=$((errors + 1))
    fi
}

# Profiles: required keys + status (drives the active/resolved distinction).
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    check_required "$f" client_slug
    check_required "$f" display_name
    check_required "$f" client_type
    check_in_set "$f" status $'active\nresolved'
done < <(find "$ROOT/clients" -mindepth 2 -maxdepth 2 -type f -name profile.md 2>/dev/null)

# Statuses: required keys + the two enums that drive logic (status, priority).
while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    check_required "$f" matter_type
    check_required "$f" client
    check_required "$f" billing
    check_in_set "$f" status $'active\non_hold\nresolved'
    check_in_set "$f" priority $'low\nnormal\nhigh\nurgent'
done < <(find "$ROOT/clients" -mindepth 6 -maxdepth 6 -type f -name status.md -path '*/matters/*/*/info/status.md' 2>/dev/null)

if [[ "$errors" -eq 0 ]]; then
    echo "✓ all frontmatter valid"
else
    echo ""
    echo "$errors issue(s) found"
    exit 1
fi

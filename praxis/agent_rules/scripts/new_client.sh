#!/usr/bin/env bash
# Usage: new_client.sh <slug> <display_name> <client_type>
# client_type is free-form text (e.g. individual, company, close_corporation,
# trust, estate, voluntary_association, ...). Used as descriptive metadata.
# Creates clients/<slug>/{profile.md, matters/open/, matters/resolved/}.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 3 ]] || die "usage: new_client.sh <slug> <display_name> <client_type>"

SLUG="$1"
DISPLAY_NAME="$2"
CLIENT_TYPE="$3"

validate_slug "$SLUG"

ROOT="$(praxis_root)"
CLIENT_DIR="$ROOT/clients/$SLUG"

[[ -d "$CLIENT_DIR" ]] && die "client already exists: $SLUG"

mkdir -p "$CLIENT_DIR/matters/open" "$CLIENT_DIR/matters/resolved"

render_skeleton profile \
    "CLIENT_SLUG=$SLUG" \
    "DISPLAY_NAME=$DISPLAY_NAME" \
    "CLIENT_TYPE=$CLIENT_TYPE" \
    "TODAY=$(today)" \
    > "$CLIENT_DIR/profile.md"

echo "$CLIENT_DIR/profile.md"

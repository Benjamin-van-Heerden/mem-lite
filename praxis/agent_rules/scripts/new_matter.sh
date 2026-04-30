#!/usr/bin/env bash
# Usage: new_matter.sh <client_slug> <matter_type> <matter_slug> [priority] [billing]
# matter_type: free-form slug (e.g. litigation, transaction, advisory, arbitration,
#              appeal, tax, labour, family, criminal, estate, ...).
# priority:    low | normal | high | urgent       (default: normal — drives onboard sort)
# billing:     free-form (e.g. hourly, fixed, contingent, pro_bono, ...) — default: hourly
# Creates clients/<client>/matters/open/YYYYMMDD-<type>-<slug>/{info/status.md, raw/, reference/}.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -ge 3 && $# -le 5 ]] || die "usage: new_matter.sh <client_slug> <matter_type> <matter_slug> [priority] [billing]"

CLIENT="$1"
MATTER_TYPE="$2"
MATTER_SLUG="$3"
PRIORITY="${4:-normal}"
BILLING="${5:-hourly}"

validate_slug "$CLIENT"
validate_slug "$MATTER_SLUG"
validate_slug "$MATTER_TYPE"

case "$PRIORITY" in
    low|normal|high|urgent) ;;
    *) die "invalid priority '$PRIORITY' (low|normal|high|urgent)" ;;
esac

CLIENT_DIR="$(resolve_client "$CLIENT")"
DIR_NAME="$(date +%Y%m%d)-$MATTER_TYPE-$MATTER_SLUG"
MATTER_DIR="$CLIENT_DIR/matters/open/$DIR_NAME"

[[ -d "$MATTER_DIR" ]] && die "matter already exists: $MATTER_DIR"

mkdir -p "$MATTER_DIR/info" "$MATTER_DIR/raw" "$MATTER_DIR/reference"

render_skeleton status \
    "MATTER_TYPE=$MATTER_TYPE" \
    "PRIORITY=$PRIORITY" \
    "TODAY=$(today)" \
    "CLIENT=$CLIENT" \
    "BILLING=$BILLING" \
    > "$MATTER_DIR/info/status.md"

append_record "$MATTER_DIR" "$(today)" "matter:opened" "$MATTER_TYPE — $MATTER_SLUG (priority $PRIORITY, $BILLING)"

echo "$MATTER_DIR"

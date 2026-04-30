#!/usr/bin/env bash
# Usage: log_communication.sh <matter_ref> <date> <direction> <medium> <counterparty> <subject>
# direction: in | out                    (semantic — kept enforced)
# medium:    free-form (e.g. letter, email, call, meeting, court_filing, sms, whatsapp, ...)
# Appends an entry to <matter>/info/record.md. Body is left as _TODO_ —
# the agent fills it in afterwards via Edit.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=_lib.sh
. "$SCRIPT_DIR/_lib.sh"

[[ $# -eq 6 ]] || die "usage: log_communication.sh <matter_ref> <date> <direction> <medium> <counterparty> <subject>"

MATTER_DIR="$(resolve_matter "$1")"
DATE="$2"
DIRECTION="$3"
MEDIUM="$4"
COUNTERPARTY="$5"
SUBJECT="$6"

case "$DIRECTION" in in|out) ;; *) die "direction must be 'in' or 'out'" ;; esac
[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "date must be YYYY-MM-DD"

KIND="comm:$DIRECTION:$MEDIUM"
SUMMARY="$COUNTERPARTY — $SUBJECT"
BODY="_TODO: body_"

append_record "$MATTER_DIR" "$DATE" "$KIND" "$SUMMARY" "$BODY"

echo "$MATTER_DIR/info/record.md"

#!/usr/bin/env bash
# Shared helpers for praxis scripts. Source this from other scripts.
# Conventions:
#   - All scripts run from the praxis project root (auto-resolved via praxis_root).
#   - All paths returned/printed are relative to project root.
#   - Errors go to stderr with prefix "praxis:". Successful output goes to stdout.

set -euo pipefail

praxis_root() {
    # Walk up from $PWD until we find agent_rules/skeletons/.
    local d
    d="$(pwd)"
    while [[ "$d" != "/" ]]; do
        if [[ -d "$d/agent_rules/skeletons" ]]; then
            echo "$d"
            return 0
        fi
        d="$(dirname "$d")"
    done
    echo "praxis: not inside a praxis project (no agent_rules/skeletons/ found in any parent)" >&2
    return 1
}

die() {
    echo "praxis: $*" >&2
    exit 1
}

today() { date +%Y-%m-%d; }
now_time() { date +%H:%M; }
now_stamp() { date +%Y%m%d-%H%M%S; }

validate_slug() {
    local s="$1"
    if [[ ! "$s" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
        die "invalid slug '$s' (lowercase alphanumeric, underscore, hyphen; must start with letter or digit)"
    fi
}

# Read a top-level scalar value from YAML frontmatter. Outputs raw string.
# Returns empty string if key not present.
frontmatter_get() {
    local file="$1" key="$2"
    awk -v k="$key" '
        BEGIN { in_fm=0; n=0 }
        /^---[[:space:]]*$/ { n++; if (n==1) { in_fm=1; next } else { exit } }
        in_fm && $0 ~ "^"k":" {
            v=$0; sub("^"k":[[:space:]]*", "", v); print v; exit
        }
    ' "$file"
}

# Replace a top-level scalar value in YAML frontmatter. Creates the key if absent.
frontmatter_set() {
    local file="$1" key="$2" value="$3"
    if grep -q "^$key:" "$file"; then
        # Replace in-place (BSD/GNU sed compatible).
        local tmp
        tmp="$(mktemp)"
        awk -v k="$key" -v v="$value" '
            BEGIN { in_fm=0; n=0; replaced=0 }
            /^---[[:space:]]*$/ {
                n++
                print
                if (n==1) in_fm=1
                else if (n==2) in_fm=0
                next
            }
            in_fm && !replaced && $0 ~ "^"k":" {
                print k": "v
                replaced=1
                next
            }
            { print }
        ' "$file" > "$tmp"
        mv "$tmp" "$file"
    else
        die "key '$key' not present in frontmatter of $file"
    fi
}

# Render a skeleton with placeholder substitutions.
# Usage: render_skeleton <skeleton_name> KEY1=value1 KEY2=value2 ...
# Reads agent_rules/skeletons/<name>.md, substitutes $KEY tokens, echoes result.
render_skeleton() {
    local root name content
    root="$(praxis_root)"
    name="$1"
    shift
    local file="$root/agent_rules/skeletons/$name.md"
    [[ -f "$file" ]] || die "skeleton not found: $file"
    content="$(cat "$file")"
    local kv key value
    for kv in "$@"; do
        key="${kv%%=*}"
        value="${kv#*=}"
        content="${content//\$$key/$value}"
    done
    printf '%s\n' "$content"
}

# Resolve a client slug to its directory path (relative to root).
resolve_client() {
    local root slug
    root="$(praxis_root)"
    slug="$1"
    local dir="$root/clients/$slug"
    [[ -d "$dir" ]] || die "client not found: $slug"
    echo "$dir"
}

# Resolve a matter reference to its full path.
# Accepts: full path | partial matter dir name | unique substring of matter dir name.
# Searches both open/ and resolved/ across all clients.
resolve_matter() {
    local root input
    root="$(praxis_root)"
    input="$1"

    # Case 1: full or partial path that already exists.
    if [[ -d "$root/$input" ]] && [[ -f "$root/$input/info/status.md" ]]; then
        echo "$root/$input"
        return 0
    fi
    if [[ -d "$input" ]] && [[ -f "$input/info/status.md" ]]; then
        echo "$input"
        return 0
    fi

    # Case 2: search by substring in matter dir name.
    local matches
    matches=$(find "$root/clients" -mindepth 4 -maxdepth 4 -type d -name "*$input*" 2>/dev/null || true)
    local count
    count=$(echo "$matches" | grep -c . || true)
    if [[ "$count" -eq 0 ]]; then
        die "no matter found matching '$input'"
    fi
    if [[ "$count" -gt 1 ]]; then
        echo "praxis: multiple matters match '$input':" >&2
        echo "$matches" >&2
        exit 1
    fi
    echo "$matches"
}

# Append a line to a file, creating the file from a skeleton if it doesn't exist.
ensure_file_from_skeleton() {
    local file="$1" skeleton="$2"
    if [[ ! -f "$file" ]]; then
        local root
        root="$(praxis_root)"
        mkdir -p "$(dirname "$file")"
        cp "$root/agent_rules/skeletons/$skeleton.md" "$file"
    fi
}

# Append an entry to a matter's info/record.md. Creates the file from skeleton if absent.
# Usage: append_record <matter_dir> <date> <kind> <summary> [body]
# Output format:
#   ## <date> — <kind> — <summary>
#
#   <body if non-empty>
append_record() {
    local matter_dir="$1" date="$2" kind="$3" summary="$4" body="${5:-}"
    local file="$matter_dir/info/record.md"
    ensure_file_from_skeleton "$file" record
    {
        printf '\n## %s — %s — %s\n' "$date" "$kind" "$summary"
        if [[ -n "$body" ]]; then
            printf '\n%s\n' "$body"
        fi
    } >> "$file"
}

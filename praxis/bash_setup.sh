#!/usr/bin/env bash
# Praxis setup script.
#
# Modes:
#   bash_setup.sh                       # Init: scaffold a new praxis project here.
#   bash_setup.sh --update              # Refresh commands, scripts, AGENTS.md core.
#   bash_setup.sh --reset-skeletons     # Restore canonical skeletons from template.
#
# Files always refreshed on --update:
#   AGENTS.md (core block only — user content after </core_instructions> preserved)
#   CLAUDE.md (symlink/copy of AGENTS.md)
#   agent_rules/commands/*.md
#   agent_rules/scripts/*.sh
#
# New skeletons added on --update (existing skeletons preserved):
#   agent_rules/skeletons/*.md  (use --reset-skeletons to restore canonical versions)
#
# Files preserved on --update (lawyer-owned):
#   agent_rules/docs/core/*
#   agent_rules/lawyer_profile.md
#   functions/*.typ
#   templates/**/*.typ

set -euo pipefail

REPO_URL="https://github.com/Benjamin-van-Heerden/mem-lite.git"
CLONE_DIR="/tmp/praxis-setup-$$"
# Praxis is published as a subdirectory of the mem-lite repo (mem-lite/praxis/).
# All template reads happen from $TEMPLATE_ROOT, not $CLONE_DIR directly.
TEMPLATE_SUBPATH="praxis"
TARGET_DIR="$(pwd)"
CORE_END_TAG="</core_instructions>"

MODE="init"
case "${1:-}" in
    --update) MODE="update" ;;
    --reset-skeletons) MODE="reset-skeletons" ;;
    "") MODE="init" ;;
    *) echo "praxis: unknown flag '$1' (expected --update or --reset-skeletons)" >&2; exit 1 ;;
esac

# ── Fetch template ──

echo "📥 Fetching latest praxis templates..."
git clone --depth 1 --quiet "$REPO_URL" "$CLONE_DIR"

TEMPLATE_ROOT="$CLONE_DIR/$TEMPLATE_SUBPATH"
[[ -d "$TEMPLATE_ROOT" ]] || { echo "❌ praxis: template subdirectory '$TEMPLATE_SUBPATH' not found in $REPO_URL" >&2; exit 1; }

cleanup() { rm -rf "$CLONE_DIR"; }
trap cleanup EXIT

# ── Helpers ──

create_directories() {
    local dirs=(
        "agent_rules/commands"
        "agent_rules/scripts"
        "agent_rules/skeletons"
        "agent_rules/docs/core"
        "agent_rules/memories"
        "agent_rules/log"
        "agent_rules/todos/claimed"
        "agent_rules/tmp"
        "functions"
        "templates/components"
        "templates/letters"
        "templates/pleadings"
        "templates/opinions"
        "templates/contracts"
        "templates/memos"
        "clients"
    )
    for d in "${dirs[@]}"; do
        mkdir -p "$TARGET_DIR/$d"
    done
}

# Copy a tree from clone to target. If $overwrite=true, replace existing files.
# If false, only copy files that don't exist at the destination.
copy_tree() {
    local src_rel="$1" dst_rel="$2" overwrite="$3" label="$4"
    local src="$TEMPLATE_ROOT/$src_rel"
    local dst="$TARGET_DIR/$dst_rel"
    [[ -d "$src" ]] || return 0
    mkdir -p "$dst"
    local f rel target
    while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        rel="${f#"$src/"}"
        target="$dst/$rel"
        mkdir -p "$(dirname "$target")"
        if [[ -f "$target" ]] && ! $overwrite; then
            continue
        fi
        cp "$f" "$target"
        if $overwrite || [[ "$MODE" == "init" ]]; then
            echo "  ✅ $dst_rel/$rel"
        fi
    done < <(find "$src" -type f)
    # On update, remove command/script files that no longer exist in template.
    if $overwrite && [[ "$MODE" == "update" ]]; then
        while IFS= read -r f; do
            [[ -z "$f" ]] && continue
            rel="${f#"$dst/"}"
            if [[ ! -f "$src/$rel" ]]; then
                rm "$f"
                echo "  🗑  removed (no longer in template): $dst_rel/$rel"
            fi
        done < <(find "$dst" -type f 2>/dev/null)
    fi
}

setup_agents_md() {
    local target="$TARGET_DIR/AGENTS.md"
    local template="$TEMPLATE_ROOT/AGENTS.md"
    local core
    core="$(<"$template")"

    if [[ "$MODE" == "init" ]]; then
        local existing_user_content=""
        if [[ -f "$target" ]]; then
            existing_user_content="$(<"$target")"
            echo "📄 Existing AGENTS.md found — appending user content after core block."
        fi
        if [[ -n "${existing_user_content// /}" ]]; then
            printf '%s\n%s\n' "$core" "$existing_user_content" > "$target"
        else
            printf '%s\n' "$core" > "$target"
        fi
        echo "  ✅ AGENTS.md"
    else
        # Update: preserve content after </core_instructions>.
        local existing user_content=""
        existing="$(<"$target")"
        if [[ "$existing" == *"$CORE_END_TAG"* ]]; then
            user_content="${existing#*$CORE_END_TAG}"
        fi
        local new_content="$core"
        if [[ -n "${user_content// /}" ]]; then
            new_content="${core}
${user_content}"
        fi
        if [[ "$existing" != "$new_content" ]]; then
            printf '%s\n' "$new_content" > "$target"
            echo "  ✅ AGENTS.md (core block refreshed; user content preserved)"
        fi
    fi
}

setup_claude_md() {
    local agents="$TARGET_DIR/AGENTS.md"
    local claude="$TARGET_DIR/CLAUDE.md"
    local is_windows=false
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        is_windows=true
    fi
    if $is_windows; then
        if [[ ! -e "$claude" ]] || [[ "$MODE" == "update" ]]; then
            cp "$agents" "$claude"
            echo "  ✅ CLAUDE.md (copy of AGENTS.md)"
        fi
    else
        if [[ ! -e "$claude" ]]; then
            ln -s "AGENTS.md" "$claude"
            echo "  ✅ CLAUDE.md → AGENTS.md (symlink)"
        elif [[ ! -L "$claude" ]]; then
            echo "  ⚠  CLAUDE.md exists and is not a symlink — leaving alone"
        fi
    fi
}

set_executable() {
    chmod +x "$TARGET_DIR/agent_rules/scripts/"*.sh 2>/dev/null || true
}

# ── Modes ──

case "$MODE" in
    init)
        if [[ -d "$TARGET_DIR/agent_rules" ]] && [[ -d "$TARGET_DIR/agent_rules/commands" ]] && \
           [[ -n "$(ls -A "$TARGET_DIR/agent_rules/commands" 2>/dev/null)" ]]; then
            echo "❌ Praxis appears to already be initialised here."
            echo "   Use --update to refresh commands and scripts."
            exit 1
        fi

        echo ""
        echo "📂 Creating directory structure..."
        create_directories

        echo ""
        echo "📝 Copying files..."
        copy_tree "agent_rules/commands"   "agent_rules/commands"   true  "commands"
        copy_tree "agent_rules/scripts"    "agent_rules/scripts"    true  "scripts"
        copy_tree "agent_rules/skeletons"  "agent_rules/skeletons"  true  "skeletons"
        copy_tree "agent_rules/docs/core"  "agent_rules/docs/core"  false "docs/core"
        copy_tree "functions"              "functions"              false "functions"
        copy_tree "templates"              "templates"              false "templates"

        # Placeholder for lawyer_profile.md (the agent will warn the lawyer
        # at onboard until they fill it in — see the file itself).
        if [[ ! -f "$TARGET_DIR/agent_rules/lawyer_profile.md" ]]; then
            if [[ -f "$TEMPLATE_ROOT/agent_rules/lawyer_profile.md" ]]; then
                cp "$TEMPLATE_ROOT/agent_rules/lawyer_profile.md" "$TARGET_DIR/agent_rules/lawyer_profile.md"
            else
                echo "TODO: describe the lawyer (name, jurisdiction, specialty, working style)." \
                    > "$TARGET_DIR/agent_rules/lawyer_profile.md"
            fi
            echo "  ✅ agent_rules/lawyer_profile.md"
        fi

        setup_agents_md
        setup_claude_md
        set_executable

        echo ""
        echo "✅ Praxis initialised."
        echo ""
        echo "Next steps:"
        echo "  1. Edit agent_rules/lawyer_profile.md with your details."
        echo "  2. Drop the typst reference into agent_rules/docs/core/typst_reference.typ."
        echo "  3. Start a session with: \"Get onboarded\" or \"Let's get to work\"."
        ;;

    update)
        if [[ ! -f "$TARGET_DIR/AGENTS.md" ]] || [[ ! -d "$TARGET_DIR/agent_rules/commands" ]]; then
            echo "❌ Praxis is not initialised here. Run without --update first."
            exit 1
        fi
        echo ""
        echo "🔄 Updating commands, scripts, and AGENTS.md core..."
        create_directories
        copy_tree "agent_rules/commands"  "agent_rules/commands"  true  "commands"
        copy_tree "agent_rules/scripts"   "agent_rules/scripts"   true  "scripts"
        # Skeletons: copy any new ones, but never overwrite existing (lawyer-edited).
        # Use --reset-skeletons to force-restore canonical versions.
        copy_tree "agent_rules/skeletons" "agent_rules/skeletons" false "skeletons"
        setup_agents_md
        setup_claude_md
        set_executable
        echo ""
        echo "✅ Update complete."
        ;;

    reset-skeletons)
        if [[ ! -d "$TARGET_DIR/agent_rules/skeletons" ]]; then
            echo "❌ Praxis is not initialised here."
            exit 1
        fi
        echo ""
        echo "⚠  This will overwrite agent_rules/skeletons/*.md with canonical versions."
        read -rp "Continue? (y/N) " confirm </dev/tty
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "Aborted."
            exit 0
        fi
        copy_tree "agent_rules/skeletons" "agent_rules/skeletons" true "skeletons"
        echo ""
        echo "✅ Skeletons reset."
        ;;
esac

#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Benjamin-van-Heerden/mem-lite.git"
CLONE_DIR="/tmp/mem-lite-setup-$$"
TARGET_DIR="$(pwd)"
CORE_END_TAG="</core_instructions>"

UPDATE=false
INIT_SUBPROJECT=false
if [[ "${1:-}" == "--update" ]]; then
    UPDATE=true
elif [[ "${1:-}" == "--init-subproject" ]]; then
    INIT_SUBPROJECT=true
fi

# ── Subproject init (early exit) ──

if $INIT_SUBPROJECT; then
    # Walk upward to find the repo root (directory containing agent_rules/)
    search_dir="$TARGET_DIR"
    REPO_ROOT=""
    while [[ "$search_dir" != "/" ]]; do
        if [[ -d "$search_dir/agent_rules" ]] && [[ -f "$search_dir/AGENTS.md" ]]; then
            REPO_ROOT="$search_dir"
            break
        fi
        search_dir="$(dirname "$search_dir")"
    done

    if [[ -z "$REPO_ROOT" ]]; then
        echo "❌ Could not find agent_rules/ in any parent directory."
        echo "   Make sure mem lite is initialized at the repo root first."
        exit 1
    fi

    if [[ "$REPO_ROOT" == "$TARGET_DIR" ]]; then
        echo "❌ You are already at the repo root. No subproject init needed."
        exit 1
    fi

    # Compute relative path from current dir to repo root
    REL_PATH=$(python3 -c "import os; print(os.path.relpath('$REPO_ROOT', '$TARGET_DIR'))")

    echo "📍 Repo root found at: $REPO_ROOT"
    echo "📐 Relative path: $REL_PATH"

    # Create AGENTS.md
    agents_file="$TARGET_DIR/AGENTS.md"
    if [[ -f "$agents_file" ]]; then
        echo "⚠️  AGENTS.md already exists here. Overwrite? (y/N)"
        read -rp "> " confirm </dev/tty
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            echo "Aborted."
            exit 0
        fi
    fi

    cat > "$agents_file" << SUBEOF
# Subproject of monorepo

This directory is a subproject within a larger repository.

**Project root:** \`$REL_PATH/\`

## Instructions

1. Read \`$REL_PATH/AGENTS.md\` and follow all instructions there.
2. All references to \`agent_rules/\` in those instructions refer to \`$REL_PATH/agent_rules/\`.
3. Stay in this directory for all work. When a command references an \`agent_rules/\` path, prefix it with \`$REL_PATH/\`.

## Examples

**Onboarding:** read \`$REL_PATH/agent_rules/commands/c_onboard.md\` and follow it — but read project description from \`$REL_PATH/agent_rules/project_description.md\`, read specs from \`$REL_PATH/agent_rules/spec/\`, etc.

**Logging:** read \`$REL_PATH/agent_rules/commands/c_create_log.md\` and create the log file in \`$REL_PATH/agent_rules/log/\`.

**Creating a spec:** read \`$REL_PATH/agent_rules/commands/c_new_spec.md\` and create the spec file in \`$REL_PATH/agent_rules/spec/\`.

**Reading memories:** read from \`$REL_PATH/agent_rules/memories/\`.

**Creating a todo:** read \`$REL_PATH/agent_rules/commands/c_new_todo.md\` and create the todo file in \`$REL_PATH/agent_rules/todos/\`.

In short: every \`agent_rules/\` path becomes \`$REL_PATH/agent_rules/\`. Everything else works as documented.
SUBEOF
    echo "  ✅ AGENTS.md"

    # Create CLAUDE.md
    claude_file="$TARGET_DIR/CLAUDE.md"
    is_windows=false
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        is_windows=true
    fi

    if $is_windows; then
        cp "$agents_file" "$claude_file"
        echo "  ✅ CLAUDE.md (copy of AGENTS.md)"
    else
        if [[ -e "$claude_file" ]]; then
            rm "$claude_file"
        fi
        ln -s "AGENTS.md" "$claude_file"
        echo "  ✅ CLAUDE.md -> AGENTS.md (symlink)"
    fi

    echo ""
    echo "✅ Subproject initialized. Agent will redirect to repo root at: $REL_PATH/"
    exit 0
fi

# Clone the repo
echo "📥 Fetching latest mem-lite templates..."
git clone --depth 1 --quiet "$REPO_URL" "$CLONE_DIR"

TEMPLATE_AGENTS="$CLONE_DIR/AGENTS.md"
TEMPLATE_COMMANDS="$CLONE_DIR/agent_rules/commands"

cleanup() {
    rm -rf "$CLONE_DIR"
}
trap cleanup EXIT

prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local result
    read -rp "$prompt [$default]: " result </dev/tty
    echo "${result:-$default}"
}

render_template() {
    local content="$1"
    content="${content//\$dev_branch/$DEV_BRANCH}"
    content="${content//\$prod_branch/$PROD_BRANCH}"
    content="${content//\$test_branch/$TEST_BRANCH}"
    echo "$content"
}

detect_branches() {
    DEV_BRANCH="dev"
    PROD_BRANCH="main"
    TEST_BRANCH="test"

    while IFS= read -r line; do
        stripped="${line#"${line%%[![:space:]]*}"}"
        if [[ "$stripped" != "- \`"* ]]; then
            continue
        fi
        branch=$(echo "$stripped" | sed 's/.*`\([^`]*\)`.*/\1/')
        if [[ -z "$branch" ]]; then
            continue
        fi
        if [[ "$stripped" == *"the main working branch"* ]]; then
            DEV_BRANCH="$branch"
        elif [[ "$stripped" == *"production branch"* ]]; then
            PROD_BRANCH="$branch"
        elif [[ "$stripped" == *"test/staging branch"* ]]; then
            TEST_BRANCH="$branch"
        fi
    done < "$TARGET_DIR/AGENTS.md"
}

ensure_gitignore_entry() {
    local entry="$1"
    local gitignore="$TARGET_DIR/.gitignore"
    if [[ -f "$gitignore" ]]; then
        if grep -qxF "$entry" "$gitignore"; then
            return 1
        fi
        echo "$entry" >> "$gitignore"
    else
        echo "$entry" > "$gitignore"
    fi
    return 0
}

create_directories() {
    local dirs=(
        "agent_rules/commands"
        "agent_rules/docs"
        "agent_rules/docs/core"
        "agent_rules/spec"
        "agent_rules/spec/completed"
        "agent_rules/spec/abandoned"
        "agent_rules/log"
        "agent_rules/memories"
        "agent_rules/todos"
        "agent_rules/todos/claimed"
        "agent_rules/tmp"
    )
    for dir in "${dirs[@]}"; do
        mkdir -p "$TARGET_DIR/$dir"
    done
}

copy_commands() {
    local changes=()
    for src_file in "$TEMPLATE_COMMANDS"/*.md; do
        local filename
        filename=$(basename "$src_file")
        local content
        content=$(<"$src_file")
        local rendered
        rendered=$(render_template "$content")
        local dst_file="$TARGET_DIR/agent_rules/commands/$filename"

        if $UPDATE; then
            if [[ -f "$dst_file" ]]; then
                local current
                current=$(<"$dst_file")
                if [[ "$current" == "$rendered" ]]; then
                    continue
                fi
                changes+=("Updated: agent_rules/commands/$filename")
            else
                changes+=("Added: agent_rules/commands/$filename")
            fi
        fi

        echo "$rendered" > "$dst_file"
        if ! $UPDATE; then
            echo "  ✅ agent_rules/commands/$filename"
        fi
    done

    if $UPDATE; then
        # Remove commands that no longer exist in templates
        for existing_file in "$TARGET_DIR/agent_rules/commands"/*.md; do
            [[ -f "$existing_file" ]] || continue
            local filename
            filename=$(basename "$existing_file")
            if [[ ! -f "$TEMPLATE_COMMANDS/$filename" ]]; then
                rm "$existing_file"
                changes+=("Removed (no longer in template): agent_rules/commands/$filename")
            fi
        done

        for change in ${changes[@]+"${changes[@]}"}; do
            echo "  • $change"
        done
    fi

    COMMAND_CHANGES=("${changes[@]+"${changes[@]}"}")
}

setup_agents_md() {
    local agents_file="$TARGET_DIR/AGENTS.md"
    local template_content
    template_content=$(<"$TEMPLATE_AGENTS")
    local rendered
    rendered=$(render_template "$template_content")

    if $UPDATE; then
        local existing
        existing=$(<"$agents_file")
        # Extract user content after </core_instructions>
        local user_content=""
        if [[ "$existing" == *"$CORE_END_TAG"* ]]; then
            user_content="${existing#*$CORE_END_TAG}"
        fi
        local new_agents="$rendered"
        if [[ -n "${user_content// /}" ]]; then
            new_agents="${rendered}
${user_content}"
        fi
        if [[ "$existing" != "$new_agents" ]]; then
            echo "$new_agents" > "$agents_file"
            echo "  • Updated: AGENTS.md (core instructions)"
            AGENTS_CHANGED=true
        fi
    else
        local existing_user_content=""
        if [[ -f "$agents_file" ]]; then
            existing_user_content=$(<"$agents_file")
            echo ""
            echo "📄 Existing AGENTS.md found — appending your content after core instructions"
            rendered="${rendered}
${existing_user_content}"
        fi
        echo "$rendered" > "$agents_file"
        echo "  ✅ AGENTS.md"
    fi
}

setup_claude_file() {
    local claude_file="$TARGET_DIR/CLAUDE.md"
    local agents_file="$TARGET_DIR/AGENTS.md"
    local is_windows=false
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        is_windows=true
    fi

    if $is_windows; then
        # Windows: copy instead of symlink
        if [[ ! -e "$claude_file" ]]; then
            cp "$agents_file" "$claude_file"
            if $UPDATE; then
                echo "  • Created: CLAUDE.md (copy of AGENTS.md)"
                CLAUDE_CHANGED=true
            else
                echo "  ✅ CLAUDE.md (copy of AGENTS.md)"
            fi
        elif $UPDATE && [[ "$AGENTS_CHANGED" == true ]]; then
            cp "$agents_file" "$claude_file"
            echo "  • Updated: CLAUDE.md (re-copied from AGENTS.md)"
            CLAUDE_CHANGED=true
        fi
    else
        # Unix: symlink
        if [[ ! -e "$claude_file" ]]; then
            ln -s "AGENTS.md" "$claude_file"
            if $UPDATE; then
                echo "  • Created: CLAUDE.md -> AGENTS.md (symlink)"
                CLAUDE_CHANGED=true
            else
                echo "  ✅ CLAUDE.md -> AGENTS.md (symlink)"
            fi
        elif [[ -L "$claude_file" ]]; then
            if ! $UPDATE; then
                echo "  ✅ CLAUDE.md symlink already exists"
            fi
        else
            echo "  ⚠️  CLAUDE.md exists and is not a symlink — skipping"
        fi
    fi
}

create_placeholder_files() {
    local changes=()

    for pair in \
        "project_description.md|TODO: Describe your project here" \
        "project_actions.md|TODO: Add project-specific onboarding actions here"
    do
        local filename="${pair%%|*}"
        local content="${pair#*|}"
        local filepath="$TARGET_DIR/agent_rules/$filename"
        if [[ ! -f "$filepath" ]]; then
            echo "$content" > "$filepath"
            if $UPDATE; then
                changes+=("Created: agent_rules/$filename")
            else
                echo "  ✅ agent_rules/$filename"
            fi
        fi
    done

    if $UPDATE; then
        for change in ${changes[@]+"${changes[@]}"}; do
            echo "  • $change"
        done
    fi

    PLACEHOLDER_CHANGES=("${changes[@]+"${changes[@]}"}")
}

flatten_logs() {
    local log_dir="$TARGET_DIR/agent_rules/log"
    [[ -d "$log_dir" ]] || return

    for subdir in "$log_dir"/*/; do
        [[ -d "$subdir" ]] || continue
        for log_file in "$subdir"*.md; do
            [[ -f "$log_file" ]] || continue
            local filename
            filename=$(basename "$log_file")
            local dest="$log_dir/$filename"
            if [[ ! -f "$dest" ]]; then
                mv "$log_file" "$dest"
                echo "  • Moved: agent_rules/log/$(basename "$subdir")/$filename -> agent_rules/log/$filename"
            else
                rm "$log_file"
                echo "  • Removed duplicate: agent_rules/log/$(basename "$subdir")/$filename"
            fi
        done
        if [[ -z "$(ls -A "$subdir" 2>/dev/null)" ]]; then
            rmdir "$subdir"
            echo "  • Removed empty directory: agent_rules/log/$(basename "$subdir")/"
        fi
    done
}

# ── Main ──

if $UPDATE; then
    # Update mode
    if [[ ! -f "$TARGET_DIR/AGENTS.md" ]] || [[ ! -d "$TARGET_DIR/agent_rules/commands" ]]; then
        echo "❌ mem light is not initialized here. Run this script without --update first."
        exit 1
    fi

    detect_branches

    AGENTS_CHANGED=false
    CLAUDE_CHANGED=false
    COMMAND_CHANGES=()
    PLACEHOLDER_CHANGES=()

    echo ""
    copy_commands
    flatten_logs
    create_directories
    if ensure_gitignore_entry "agent_rules/tmp/"; then
        echo "  • Updated: .gitignore (added agent_rules/tmp/)"
        GITIGNORE_CHANGED=true
    else
        GITIGNORE_CHANGED=false
    fi
    create_placeholder_files
    setup_agents_md
    setup_claude_file

    # Check if anything changed
    if [[ ${#COMMAND_CHANGES[@]} -eq 0 ]] && \
       [[ ${#PLACEHOLDER_CHANGES[@]} -eq 0 ]] && \
       [[ "$AGENTS_CHANGED" == false ]] && \
       [[ "$CLAUDE_CHANGED" == false ]] && \
       [[ "$GITIGNORE_CHANGED" == false ]]; then
        echo "✅ Mem light is up to date. No changes needed."
    else
        echo ""
        echo "✅ Update complete."
    fi
else
    # Init mode
    if [[ -f "$TARGET_DIR/AGENTS.md" ]] && [[ -d "$TARGET_DIR/agent_rules/commands" ]]; then
        echo "⚠️  mem light appears to already be initialized here."
        echo "Use --update to update existing files."
        exit 1
    fi

    # Show branches
    branches=$(git branch --format='%(refname:short)' 2>/dev/null || true)
    if [[ -n "$branches" ]]; then
        echo ""
        echo "📋 Existing branches:"
        while IFS= read -r branch; do
            echo "  - $branch"
        done <<< "$branches"
        echo ""
    fi

    PROD_BRANCH=$(prompt_with_default "Which branch is your production branch?" "main")

    # Validate prod branch exists
    if ! echo "$branches" | grep -qxF "$PROD_BRANCH"; then
        echo "❌ Branch '$PROD_BRANCH' does not exist. Cannot proceed without a production branch."
        exit 1
    fi

    DEV_BRANCH=$(prompt_with_default "Which branch is your development branch?" "dev")
    TEST_BRANCH=$(prompt_with_default "Which branch is your test/staging branch?" "test")

    # Create dev branch if needed
    if ! echo "$branches" | grep -qxF "$DEV_BRANCH"; then
        git switch -c "$DEV_BRANCH" "$PROD_BRANCH"
        git push -u origin "$DEV_BRANCH"
        echo "✅ Created branch '$DEV_BRANCH' off '$PROD_BRANCH' and pushed to remote"
    else
        git switch "$DEV_BRANCH"
    fi

    # Create test branch off prod if needed
    if ! echo "$branches" | grep -qxF "$TEST_BRANCH"; then
        git switch -c "$TEST_BRANCH" "$PROD_BRANCH"
        git push -u origin "$TEST_BRANCH"
        git switch "$DEV_BRANCH"
        echo "✅ Created branch '$TEST_BRANCH' off '$PROD_BRANCH' and pushed to remote"
    fi

    echo ""
    echo "📂 Creating agent_rules/ directory..."
    create_directories
    copy_commands
    ensure_gitignore_entry "agent_rules/tmp/" || true
    create_placeholder_files
    setup_agents_md
    setup_claude_file

    echo ""
    echo "✅ mem light initialized with dev branch: $DEV_BRANCH"
    echo ""
    echo "💡 Start a session with: \"Get onboarded\" or \"Let's get to work\""
fi

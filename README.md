# mem lite

A lightweight, agent-driven development workflow using markdown files. Specs, tasks, todos, memories, and work logs — all managed through AI agent commands.

No dependencies. No runtime. Just files and a setup script.

## Setup

### macOS / Linux

```bash
# Init
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/bash_setup.sh)

# Update
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/bash_setup.sh) --update
```

### Windows (PowerShell)

```powershell
# Init
$f = "$env:TEMP\ps_setup.ps1"; Invoke-WebRequest -Uri https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/ps_setup.ps1 -OutFile $f; powershell -ExecutionPolicy Bypass -File $f; Remove-Item $f

# Update
$f = "$env:TEMP\ps_setup.ps1"; Invoke-WebRequest -Uri https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/ps_setup.ps1 -OutFile $f; powershell -ExecutionPolicy Bypass -File $f -Update; Remove-Item $f
```

> **Note:** The `-ExecutionPolicy Bypass` flag is needed because Windows may block `.ps1` scripts by default. This only affects the setup script — it does not change your system's execution policy.

The setup script will prompt you for your development, production, and test/staging branch names. It clones the latest templates, sets everything up, and cleans up after itself.

## What Gets Created

```
my-project/
    AGENTS.md              # Core agent instructions
    CLAUDE.md              # Symlink to AGENTS.md (copy on Windows)
    agent_rules/
        commands/          # Step-by-step agent workflow instructions
        docs/
            core/          # Auto-read during onboard
        spec/              # Feature specs
            completed/
            abandoned/
        log/               # Session work logs
        memories/          # Persistent notes on patterns and conventions
        todos/             # Standalone work items
            claimed/
        tmp/               # Temporary files (git-ignored)
        project_description.md
        project_actions.md
```

## Usage

Once set up, start any AI coding session with:

> "Get onboarded" or "Let's get to work"

This triggers `c_onboard`, which reads your project context — specs, tasks, memories, todos, and recent work logs.

### Available Commands

| Command | Trigger | Description |
|---|---|---|
| `c_onboard` | "Get onboarded", "Let's get to work" | Read project context and sync status |
| `c_create_spec` | "Create a spec" | Create a feature spec with tasks |
| `c_complete_spec` | "Complete the spec" | Finalize spec, create PR if on feature branch |
| `c_merge` | "Merge the spec" | Squash-merge a spec's PR |
| `c_clean_git` | "Clean up branches" | Delete merged branches |
| `c_log_work` | "Log work" | Create a session work log |
| `c_abandon_spec` | "Abandon the spec" | Move spec to abandoned, close PR |
| `c_create_memory` | "Remember this" | Create a persistent note |
| `c_create_todo` | "Create a todo" | Create a standalone work item |
| `c_claim_todo` | "Claim this todo" | Mark a todo as done |
| `c_init_introspect_codebase` | "Introspect the codebase" | Generate a codebase reference doc |
| `c_week_report` | "Week report" | Generate weekly summary from logs |

## How It Works

mem lite is a file-based system — no CLI tool, no database, no runtime. The `agent_rules/commands/` directory contains step-by-step instructions written in a pseudo-code format that AI agents (Claude, Cursor, Copilot, etc.) read and execute.

All state is stored in markdown files within `agent_rules/`. Git is the persistence and version control layer.

## Updating

Running the setup script with `--update` (bash) or `-Update` (PowerShell) will:
- Overwrite command files with the latest versions
- Add new commands, remove deprecated ones
- Update core instructions in AGENTS.md while preserving your custom content (everything after `</core_instructions>`)
- Create any new directories added in newer versions

## License

Copyright (c) 2026 Benjamin van Heerden

This software may only be used with explicit permission from the copyright holder. Redistribution in any form is prohibited.

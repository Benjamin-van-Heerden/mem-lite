# mem lite

A lightweight, agent-driven development workflow using markdown files. Specs, tasks, todos, memories, and work logs — all managed through AI agent commands.

No dependencies. No runtime. Just files and a setup script.

## Prerequisites

- **Git** must be installed (provides `bash` on all platforms including Windows)

## Setup

### macOS / Linux

```bash
# Init
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/bash_setup.sh)

# Update
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/bash_setup.sh) --update
```

### Windows

Run from **Git Bash** (installed with Git for Windows):

```bash
# Init
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/bash_setup.sh)

# Update
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/bash_setup.sh) --update
```

> **Note:** On Windows, CLAUDE.md is created as a copy of AGENTS.md (not a symlink). Running `--update` will keep it in sync.

The setup script will prompt you for your branch names, create any missing branches, and push them to the remote. It clones the latest templates, sets everything up, and cleans up after itself.

## What Gets Created

```
my-project/
    AGENTS.md              # Core agent instructions
    CLAUDE.md              # Symlink to AGENTS.md (copy on Windows, kept in sync by --update)
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

## Monorepo / Subproject Support

For monorepos where developers work in subdirectories (e.g., individual .NET solutions), you can create lightweight pointer files that redirect the agent to the repo root:

```bash
# From within a subdirectory (e.g., src/Gateway/Hexing/)
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/bash_setup.sh) --init-subproject
```

This creates a minimal `AGENTS.md` and `CLAUDE.md` in the current directory that tell the agent:
- Where the repo root is (relative path)
- To prefix all `agent_rules/` paths with the relative path to root
- Concrete examples for onboarding, logging, creating specs, reading memories, etc.

The agent stays in the subdirectory for all work — it simply reaches up to the root `agent_rules/` with relative paths when it needs mem lite files.

This is useful when:
- Your repo contains many independent projects/solutions
- Developers open individual project directories rather than the repo root
- You want to incrementally enable AI workflows per-project without touching the rest

**Requirements:** mem lite must already be initialized at the repo root. The script walks upward from the current directory to find `agent_rules/`.

## How It Works

mem lite is a file-based system — no CLI tool, no database, no runtime. The `agent_rules/commands/` directory contains step-by-step instructions written in a pseudo-code format that AI agents (Claude, Cursor, Copilot, etc.) read and execute.

All state is stored in markdown files within `agent_rules/`. Git is the persistence and version control layer.

## Updating

Running the setup script with `--update` will:
- Overwrite command files with the latest versions
- Add new commands, remove deprecated ones
- Update core instructions in AGENTS.md while preserving your custom content (everything after `</core_instructions>`)
- Create any new directories added in newer versions

## Praxis (typst-first legal practice variant)

A separate but related system for **solo legal practitioners** ships as a
subdirectory of this repo. Praxis is built around the same agent-driven,
file-based philosophy as mem lite, but the primitives are different:
clients, matters, deadlines, communications, records, and typst document
templates instead of specs/tasks. The agent is the entire user interface —
the lawyer never sees the filesystem.

Praxis is published from the same repo (under `praxis/`) so the install
one-liner just points at the praxis subdir of `bash_setup.sh`.

### Prerequisites

- **Git** (same as mem lite — provides `bash` on Windows).
- **Python 3.12+** on `PATH` as `python`. The agent invokes runtime
  helpers as `python agent_rules/scripts/<name>.py ...`. On Windows, the
  python.org installer's "Add to PATH" option is sufficient. On macOS /
  Linux, install Python 3.12+ via your package manager and confirm
  `python --version` works.
- **Typst.** Praxis assumes `typst` is on `PATH` for compiling documents.
  Install from <https://github.com/typst/typst>.

### Setup

#### macOS / Linux

```bash
# Init
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/praxis/bash_setup.sh)

# Update
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/praxis/bash_setup.sh) --update

# Restore canonical skeletons (overwrites any local edits to agent_rules/skeletons/)
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/praxis/bash_setup.sh) --reset-skeletons
```

#### Windows

Run from **Git Bash** (installed with Git for Windows):

```bash
# Init
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/praxis/bash_setup.sh)

# Update
bash <(curl -sL https://raw.githubusercontent.com/Benjamin-van-Heerden/mem-lite/main/praxis/bash_setup.sh) --update
```

> **Note:** install/update only run from bash. The day-to-day commands
> the agent dispatches are Python scripts, not bash — so the agent runs
> them on Windows without needing a working bash shell.

### First session

Open the project in your AI coding tool of choice and say:

> "Get onboarded" or "Let's get to work"

If it's a fresh install, the agent will detect the first-run state
(unfilled `lawyer_profile.md`, missing default template) and walk you
through a guided setup: a brief profile interview, a default document
template designed and test-compiled with you, and an optional pass at
filling in jurisdictional context.

After that, you talk to the agent in plain language ("new client", "Tom
called this morning", "filing is due Friday", "draft a letter to…") and
it translates into the right action.

## License

Copyright (c) 2026 Benjamin van Heerden

This software may only be used with explicit permission from the copyright holder. Redistribution in any form is prohibited.

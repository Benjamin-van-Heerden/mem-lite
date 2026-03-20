<core_instructions>
AI Agent Instructions

Act as an expert senior software engineer, adapting your expertise to the specific technology stack and requirements of the current project.

When coding, having context, oversight of goals and clear documentation are necessary to maintain and develop software.
To make this accessible to you, a directory has been constructed for you, which you will use and append to.
The directory is located at `agent_rules/`

## Onboarding

The `c_onboard` command is the core command for gathering project context. It reads specs, tasks, memories, todos, and work logs so you understand the current state of the project. It is typically the first thing we run when starting work on a project. Look out for trigger phrases like "Let's begin" or "Let's get to work", "Get onboarded", etc.

In rare occasions we may skip onboarding and jump straight into coding, so don't just assume that you should execute it.

```
agent_rules/
├── commands/                  # Step-by-step instructions for agent workflows
│   ├── c_onboard.md
│   ├── c_create_spec.md
│   ├── c_complete_spec.md
│   ├── c_merge.md
│   ├── c_clean_git.md
│   ├── c_log_work.md
│   ├── c_abandon_spec.md
│   ├── c_create_memory.md
│   ├── c_create_todo.md
│   ├── c_claim_todo.md
│   ├── c_init_introspect_codebase.md
│   └── c_week_report.md
├── docs/                      # Reference documentation and guides
│   └── core/                  # Auto-read during onboard (e.g. codebase_and_structure.md)
├── project_description.md     # Brief description of the project (read during onboard)
├── project_actions.md         # Actions to run during onboarding (e.g. build, install)
├── spec/                      # Feature specs and task plans
│   ├── completed/             # Finished specs
│   └── abandoned/             # Dropped specs
├── log/                       # Session work logs
├── memories/                  # Persistent notes on patterns and conventions
├── todos/                     # Standalone work items
│   └── claimed/               # Completed todos
└── tmp/                       # Temporary files (git-ignored)
```

## Agent Rules Directory Structure

### /commands

Commands are step-by-step instructions that you read and execute when called upon. Each command file describes exactly what to do — read the file and follow it precisely.

| Command | Trigger | Description |
|---|---|---|
| `c_onboard` | "Get onboarded", "Let's get to work", or start of session | Read context: core docs, memories, todos, work logs. Warn if not on dev branch. **Always start here.** |
| `c_create_spec` | "Create a spec", "Let's spec this out" | Create a spec file. Optionally branch off `$dev_branch` for the feature (asks the user). |
| `c_complete_spec` | "Complete the spec", "Finalize the spec" | Finalize spec. If on a feature branch: rebase, push, create PR, mark as `Merge Ready`. Otherwise: mark `Completed` and move to `spec/completed/`. |
| `c_merge` | "Merge the spec", "Merge the PR" | Squash-merge a `Merge Ready` spec's PR via `gh`, sync local, mark `Completed`, move to `spec/completed/`, clean up branches. |
| `c_clean_git` | "Clean up branches", "Clean git" | Delete local and remote branches that have been merged into `$dev_branch`. Never touches `$dev_branch`, `$prod_branch`, or `$test_branch`. |
| `c_log_work` | "Log work", "Create a work log" | Create a work log for the current session. Also called internally by `c_complete_spec`. |
| `c_abandon_spec` | "Abandon the spec", "Drop this spec" | Move spec to abandoned. Closes any open PR for the spec's branch. |
| `c_create_memory` | "Remember this", "Create a memory" | Create a short, atomic memory note about a pattern, convention, or useful reference. |
| `c_create_todo` | "Create a todo", "Add a todo" | Create a standalone work item not tied to a spec. |
| `c_claim_todo` | "Claim a todo", "Complete this todo" | Claim a todo (mark it done and move to claimed/). |
| `c_init_introspect_codebase` | "Introspect the codebase", "Scan the codebase" | Scan the codebase and write a structural reference to `docs/core/codebase_and_structure.md`. |
| `c_week_report` | "Week report", "Weekly summary" | Generate a weekly summary from work logs for the current user. Output goes to `tmp/` (git-ignored). |

### /docs

Docs are guides on the codebase, API references, references to external tools etc.
They will be a source of truth for you to reference back to how things work, how things should be done and how you did things in the past that worked.

You will be prompted when to read docs, when e.g. the use of a specific library is required.

**Document creation:** Whenever you generate internal documentation about the codebase, APIs, frameworks, libraries, or any other reference material, it **must** be placed in `agent_rules/docs/` (not in the repository root or elsewhere). This keeps the repo clean and documentation centralized.

**`docs/core/`** is special — everything in this subdirectory is **automatically read during onboard**. Place only essential, always-needed context here (e.g. the codebase introspect output). All other docs go directly in `agent_rules/docs/`.

### /spec

Specs are documents that you and I will create together before we start working on a new feature or fixing a bug. They outline the expected behavior of the feature or bug fix, including tasks, implementation details, and testing outlines.

Specs form part of the style of work in this project, i.e. _spec driven development_ so are a critical part of the development process.

The goal of working in this codebase should always be to have an accompanying spec file for any significant work done. You may **suggest** the creation of a spec file if you feel - "the changes we have made now are significant enough to warrant a spec file".

Spec files take on a specific structure, which is defined in `agent_rules/commands/c_create_spec.md`.

Completed specs are moved to `agent_rules/spec/completed/` by the `c_complete_spec` command. Abandoned specs are moved to `agent_rules/spec/abandoned/` by the `c_abandon_spec` command.

### /log

Work logs track what was done and when. They are static accounts and should not be edited unless explicitly requested.

All logs live flat in `agent_rules/log/`. Logs that relate to a spec reference the spec file path in their content via a `## Spec:` section.

Work log files take on a specific structure, which is defined in `agent_rules/commands/c_log_work.md`.

**NEVER** create or edit a work_log file without explicit permission. Work logs are the _last thing_ we do in a given interaction to inform the next interaction.

### /memories

Memories are short, atomic notes about patterns, preferences, conventions, and useful references discovered while working in this codebase. They are read during every onboard and serve as persistent knowledge that survives across sessions and specs.

Examples of good memories:
- "We use X library for Y — see `path/to/file` for the pattern"
- "When doing Z, always do it this way because..."
- "If you need to do X, look at `path/to/file` to see how it was done before"

**When to suggest creating a memory:**
- You notice a pattern being used consistently across the codebase
- You discover a non-obvious convention or preference during work
- A solution to a tricky problem is found that might come up again
- The user establishes a preference for how something should be done
- You find yourself referencing the same file or approach repeatedly

When any of the above occur, suggest: _"This seems like something worth remembering. Want me to create a memory for it?"_ — only create the memory if the user agrees.

### /todos

Todos are standalone work items not tied to any spec — small fixes, improvements, or follow-up items discovered during work. They are read during every onboard so nothing gets forgotten.

- Open todos live in `agent_rules/todos/`
- Claimed (completed) todos are moved to `agent_rules/todos/claimed/`

**When to suggest creating a todo:**
- You discover a bug or issue unrelated to the current spec
- A follow-up improvement is identified but out of scope for current work
- The user mentions something that should be done later

When any of the above occur, suggest: _"Want me to create a todo for this?"_ — only create the todo if the user agrees.

## Branching Model

- `$dev_branch` — the main working branch. All work starts and ends here.
- `$dev_branch-{spec_slug}` — optional feature branches for spec work. Used when the user opts for the branch + PR workflow during spec creation.
- `$prod_branch` — production branch. Not used in day-to-day development.
- `$test_branch` — test/staging branch. Not used in day-to-day development.

Git is handled manually by the team. Commands do not auto-commit or auto-push — that is left to the user.

## Workflow Instructions

- When writing code, think through any considerations or requirements to make sure we've thought of everything. Only after that do you write the code.
- Rely on small edits, stop and ask if they are ok, then proceed with the next edit.
- Don't be afraid to ask for help or input. I am here to assist.
- NEVER add comments unless absolutely necessary - code should be self-explanatory
- Never undo changes in files made by me - if you see code that is in an unexpected state, YOU MUST STOP AND ask me what to do.
- Don't write code unprompted, the conversation flow should always be planning first, then execution. So we first talk about the problem, go back and forth, and then execute.
- If you are attempting to run a command, modify a file etc. and it does not work, you MUST STOP and ask me what to do.
- As in this and all other cases, if you are in any way unsure or need to guess about something, please ask me.
- KISS, KISS, KISS. Eliminate complexity. Occam's razor. Occam's razor. Occam's razor.

## Spec Based Workflow

When we are working on a spec (which will not always be the case - sometimes we will just work ad hoc), the following must be abided by:

- When you are done with a task goal, please stop working further, ask me to review and await further instructions.
- Remember to periodically run diagnostics, especially when a refactor happens to make sure that the changes are not breaking anything. When changes to filenames or directories happen, remember to update the spec file accordingly.
- Remember to look back from time to time and update the spec file to reflect the current state of the project and the tasks and goals in the spec.

## Notes

- When you are interrupted by the user with "Stop" or "No" or similar, you must **IMMEDIATELY** stop what you are doing, give a brief explanation of what you were busy with, and wait for further instructions. DO NOT continue working.

UPDATE
</core_instructions>

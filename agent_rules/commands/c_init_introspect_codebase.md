## Introspect the Codebase

This is an initialization command. Its purpose is to deeply scan the current codebase and produce a detailed reference document that future sessions can use to quickly understand how the project works.

The output file is `agent_rules/docs/core/codebase_and_structure.md`. If it already exists, read it and then delete it - do this first. Do not let it influence your current output too much, we will be re-creating it from scratch.

---

## Phase 1: Gather Raw Information

@tool@ Run `find . -type f | grep -v -e node_modules -e .git/ -e __pycache__ -e .next -e dist/ -e build/ -e .mem/ -e agent_rules/ -e venv -e .venv -e .env -e '\.lock$' -e '\.png$' -e '\.jpg$' -e '\.svg$' -e '\.ico$' -e '\.woff' | head -300` @into@ --file_tree
[Windows: `Get-ChildItem -Recurse -File | Where-Object { $_.FullName -notmatch 'node_modules|\.git\\|__pycache__|\.next|dist\\|build\\|\.mem\\|agent_rules\\|venv|\.venv|\.env|\.lock$|\.png$|\.jpg$|\.svg$|\.ico$|\.woff' } | Select-Object -First 300 | Resolve-Path -Relative`]

@tool@ Identify and read the project's root configuration and manifest files (e.g. `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `docker-compose.yml`, `.env.example`, etc.) — whatever exists.

@tool@ Find and read all README files in the project (`README.md` at root, and any READMEs in subdirectories). These often contain module-specific documentation critical for understanding the project.

@tool@ Identify the primary entry point(s) of the application (e.g. `main.py`, `index.ts`, `app.py`, `src/main.rs`, etc.) and read them.

---

## Phase 2: Deep Exploration

Work through the codebase methodically. The goal is to understand:

1. **What does this project do?** — Its purpose, what it provides to users/consumers.
2. **How is it structured?** — Directory layout, module boundaries, naming conventions.
3. **What is the tech stack?** — Languages, frameworks, key libraries, infrastructure.
4. **How do the parts connect?** — Which modules call which, where data flows, how requests are handled.
5. **Where are the boundaries?** — API surfaces, database access, external service integrations, shared state.

@tool@ Read key source files across the codebase to trace how components connect. Follow imports, function calls, and data flow. Prioritize:
- Entry points and routers/controllers
- Core business logic modules
- Data models and schemas
- Database/storage access layers
- Configuration and environment setup
- Shared utilities that appear frequently in imports

Do NOT read every file. Use the file tree and imports to navigate strategically. Focus on understanding the architecture, not memorizing implementation details.

---

## Phase 3: Write the Reference Document

@tool@ Ensure the directory `agent_rules/docs/core/` exists (create it if it doesn't)

@tool@ Write `agent_rules/docs/core/codebase_and_structure.md`

@composite action@
  @tools: [write file]@

  ~~ Write an information-dense reference document. This file is read at the start of every session, so it must give an agent enough context to navigate the codebase confidently. Be specific (use real file paths and names), but keep it proportional to the project's size — don't turn a small project into a novel.

  Use the following structure:

  ```md
  # Codebase and Structure

  ## Overview
  {1-2 paragraphs: what this project is, what problem it solves, who/what consumes it. Include any important context from README files.}

  ## Tech Stack
  {Bullet list with brief rationale — not just names:
  - **Language**: {language} {version}
  - **Framework**: {framework} — {what it handles}
  - **Key Libraries**: {name — what it's used for} (one per line, only the important ones)
  - **Database**: {db} — {what data it stores} (if applicable)
  - **Build/Dev Tools**: {package manager, test runner, linter, etc.}}

  ## Directory Layout
  {Annotated tree 2-3 levels deep for important directories. For each directory, a brief description of what lives there and any naming conventions.}

  ## Key Modules
  {For each significant module/component:
  - What it does (2-3 sentences — be specific, not vague)
  - Key files with what each file does
  - Dependencies and dependents (what it uses, what uses it)
  - Any gotchas or non-obvious design decisions}

  ## Data Flow
  {How does data move through the system? Describe the primary paths with file paths and function names. Use numbered steps for each major flow. Cover the main flows, not every edge case.}

  ## Entry Points
  {How is the application started? Commands, scripts, key environment variables. Include dev and production if they differ.}

  ## External Interfaces
  {APIs exposed, external services consumed, database connections — anything that crosses the codebase boundary. For each: what it is, direction (in/out/both), and which files interact with it.

  Omit this section if there are no external interfaces.}

  ## Conventions and Patterns
  {Notable patterns used consistently — with concrete examples referencing actual files. Cover: error handling, naming conventions, configuration, testing patterns, and any project-specific conventions.

  Omit this section if the project has no notable conventions.}
  ```

  Rules:
  - Be specific — use actual file paths, module names, function names
  - Be accurate — only write what you have confirmed by reading the code
  - Be proportional — more detail for complex areas, less for simple ones
  - Do NOT pad with generic advice or boilerplate
  - Do NOT include information about the agent_rules/ system itself
  - If a section is not applicable, omit it entirely
@end composite action@

---

@finally@ Notify the user that the codebase reference has been written to `agent_rules/docs/core/codebase_and_structure.md` and suggest they review it for accuracy before committing.

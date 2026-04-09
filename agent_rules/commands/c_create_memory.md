## Validate the Memory

A memory is a short, atomic note about a pattern, preference, convention, or useful reference in this codebase. Examples:
- "We use X library for Y — see `path/to/file` for the pattern"
- "When doing Z, always do it this way because..."
- "If you need to do X, look at `path/to/file` to see how it was done before"

Memories can be created in two ways:
1. **User requests it** — the user explicitly asks to remember something.
2. **Agent suggests it** — during work, you notice a pattern, convention, or lesson worth preserving. Suggest it to the user and only create it if they agree.

@if (the memory topic is clear and specific)@
  @continue@
@else@
  @stop@ Ask the user to clarify what should be remembered. A memory should be about one specific thing.
@end if@

## Create the Memory File

@tool@ Derive a short descriptive slug from the topic (lowercase, underscores, no special chars) @into@ --memory_slug

@tool@ Check if `agent_rules/memories/m_{--memory_slug}.md` already exists
@if (the file already exists)@
  @stop@ A memory with this slug already exists. Ask the user if they want to:
  - Append a distinguishing word to the slug (e.g., "m_{--memory_slug}_framework")
  - Or update the existing memory instead
  Do NOT proceed until the user confirms how to handle this collision.
@end if@

@tool@ Create a memory file `agent_rules/memories/m_{--memory_slug}.md`

@composite action@
  @tools: [edit file]@

  ~~ Write the memory. Keep it concise — a memory should be readable in under 30 seconds. Structure:

  ```md
  # {Short descriptive title}

  {The actual note — what to do, why, and where to look if more detail is needed. Keep it brief and actionable.}
  ```

  Rules for writing memories:
  - One topic per file
  - Be specific and actionable, not vague
  - Include file paths or code references where relevant
  - State the "why" if it's not obvious
  - Do NOT duplicate information that already lives in spec files or docs
@end composite action@

@finally@ Confirm to the user what was remembered.

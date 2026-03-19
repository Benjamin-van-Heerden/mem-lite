## Validate the Todo

A todo is a standalone work item — a concrete task or reminder that is not tied to a spec.
Todos are useful for tracking small fixes, improvements, or follow-up items discovered during work.

@if (the todo is clear and actionable)@
  @continue@
@else@
  @stop@ Ask the user to clarify. A todo should describe one specific, actionable item.
@end if@

## Create the Todo File

@tool@ Derive a short descriptive slug from the title (lowercase, underscores, no special chars) @into@ --todo_slug

@tool@ Ensure the directory `agent_rules/todos/` exists (create it if it doesn't)

@tool@ Create a todo file `agent_rules/todos/t_{--todo_slug}.md`

@composite action@
  @tools: [edit file]@

  ~~ Write the todo. Structure:

  ```md
  # {Title}

  **Status:** open
  **Created:** {YYYY-MM-DD}

  ## Description

  {What needs to be done and why. Be specific and actionable. Include file paths or references where relevant.}
  ```

  Rules for writing todos:
  - One item per file
  - Be specific about what needs to happen
  - Include file paths or context where relevant
  - If the todo came from work on a spec, mention the spec for context
@end composite action@

@finally@ Confirm to the user what todo was created.

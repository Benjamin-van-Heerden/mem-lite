## Identify the Todo

@tool@ List the contents in `./agent_rules/todos/` (not the claimed/ subdirectory)

@if (no open todo files found)@
  @stop@ No open todos found. Nothing to claim.
@end if@

@if (the user has not specified which todo to claim, OR it is ambiguous)@
  @tool@ Read all open todo files in `./agent_rules/todos/` (not claimed/)
  @stop@ Present the list of open todos to the user. Ask them to confirm which todo they want to claim. Do NOT guess.
@end if@

@tool@ Read the specified todo file @into@ --todo_file

## Claim the Todo

@tool@ Ensure the directory `agent_rules/todos/claimed/` exists (create it if it doesn't)

@tool@ Update the todo file: change `**Status:** open` to `**Status:** claimed` and add `**Claimed:** {YYYY-MM-DD}`

@tool@ Move the todo file to `agent_rules/todos/claimed/`

@finally@ Confirm to the user which todo was claimed.

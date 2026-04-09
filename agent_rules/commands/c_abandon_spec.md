## Identify the Spec to Abandon

This is a destructive action. You must be absolutely certain which spec is being abandoned.

@tool@ List spec files in `agent_rules/spec/` (not completed/ or abandoned/)

@if (no active spec files found)@
  @stop@ No active specs found. Nothing to abandon.
@end if@

@if (the user has not explicitly named which spec to abandon, OR there are multiple specs and it is ambiguous)@
  @stop@ Present the list of active specs to the user. Ask them to confirm exactly which spec should be abandoned by name. Do NOT guess. Do NOT proceed until the user has explicitly confirmed.
@end if@

@tool@ Ask the user for final confirmation: "Are you sure you want to abandon spec `{spec_name}`? This will move the spec file to `spec/abandoned/`."

@if (user did not confirm)@
  @stop@ Abandonment cancelled.
@end if@

## Move Spec to Abandoned

@tool@ Read the spec file

@tool@ Update the spec status to `Abandoned`

## Commit First

@tool@ Run `git add -A && git commit -m "spec: abandon {--spec_slug}"`

@tool@ Run `git push`
@if (push failed)@
  @stop@ Failed to push to remote. Show the user the error output. Do NOT continue.
@end if@

## Then Move to Abandoned

@tool@ Ensure the directory `agent_rules/spec/abandoned/` exists (create it if it doesn't)

@tool@ Move the spec file to `agent_rules/spec/abandoned/`

@tool@ Run `git add -A && git commit -m "spec: move {--spec_slug} to abandoned"`

@tool@ Run `git push`
@if (push failed)@
  @stop@ Failed to push to remote. Show the user the error output. Do NOT continue.
@end if@

## Close PR and Delete Branch if Exists

@tool@ Check the spec file for a `Branch:` line (e.g. `%% Branch: $dev_branch-{slug} %%`)
@if (spec has a branch)@
  @tool@ Run `gh --version` to check if GitHub CLI is installed
  @if (gh is installed)@
    @tool@ Run `gh pr list --head {branch_name} --state open --json number`
    @if (there is an open PR)@
      @tool@ Run `gh pr close {pr_number} --comment "Spec abandoned"`
    @end if@
    @tool@ Run `git push origin --delete {branch_name}` (ignore errors — branch may already be deleted or not pushed)
  @else@
    @tool@ Warn the user: "`gh` (GitHub CLI) is not installed. If there is an open PR for branch `{branch_name}`, it will need to be closed manually. Install `gh` from https://cli.github.com/ for automatic PR management."
  @end if@
@end if@

@finally@ Summarize to the user:
- The spec that was abandoned
- That the spec file has been moved to `spec/abandoned/`
- Whether a PR was closed (if applicable)

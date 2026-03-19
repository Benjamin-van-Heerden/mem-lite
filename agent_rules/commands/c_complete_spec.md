## Gather Context

@tool@ Run `git branch --show-current` @into@ --current_branch

@if (--current_branch starts with "$dev_branch-")@
  @set@ --on_feature_branch = true
  @tool@ Derive the spec slug from --current_branch (strip the `$dev_branch-` prefix) @into@ --spec_slug
@else@
  @set@ --on_feature_branch = false
  @if (the user has not specified which spec to complete, OR it is ambiguous)@
    @tool@ List spec files in `agent_rules/spec/` (not completed/ or abandoned/)
    @stop@ Present the specs and ask the user which one to complete.
  @end if@
  @tool@ Derive the spec slug from the confirmed spec file @into@ --spec_slug
@end if@

@tool@ Find and read the spec file matching --spec_slug in `agent_rules/spec/`

## Check for Incomplete Tasks

@tool@ Check the spec file for any unchecked task items (unchecked checkboxes, tasks not marked as done)

@if (there are incomplete tasks)@
  @stop@ The spec has incomplete tasks. Present the incomplete tasks to the user and ask if they want to proceed anyway or finish the remaining work first. Do NOT continue until the user explicitly confirms.
@end if@

## Create Work Log

@tool@ Execute `c_log_work` — create a work log for this session before finalizing the spec.

## Write Completion Report

@tool@ Edit the spec file's `## Completion Report` section. Write a concise summary of:
- What was built
- Key decisions made during implementation
- Anything a future session should know (gotchas, trade-offs, follow-up work)

This is the permanent record attached to the spec — it should be self-contained and useful to someone encountering this spec for the first time.

@if (--on_feature_branch)@

  ## Mark as Merge Ready

  @tool@ Update the spec status to `Merge Ready`

  ## Commit, Rebase, and Push

  @tool@ Run `git add -A && git commit -m "spec: complete {--spec_slug}"`

  @tool@ Run `git fetch origin && git rebase origin/$dev_branch`
  @if (rebase failed)@
    @stop@ Rebase onto `origin/$dev_branch` failed due to conflicts. Show the user the error output. The rebase is still in progress — they need to resolve conflicts and `git rebase --continue`, or `git rebase --abort` to undo. Do NOT continue.
  @end if@

  @tool@ Run `git push --force-with-lease`
  @if (push failed)@
    @stop@ `git push --force-with-lease` failed. Show the user the error output. They may need to `git fetch origin` and retry. Do NOT continue.
  @end if@

  ## Create Pull Request

  @tool@ Run `which gh` [Windows: `where gh`] to check if GitHub CLI is installed
  @if (gh is not installed)@
    @stop@ `gh` (GitHub CLI) is not installed. It is required for the PR workflow. Install it from https://cli.github.com/ and authenticate with `gh auth login`. Do NOT continue.
  @end if@

  @tool@ Run `gh pr create --base $dev_branch --head $dev_branch-{--spec_slug} --title "spec: {--spec_slug}" --body "{completion report summary}"`
  @if (gh command failed)@
    @stop@ Failed to create PR. Make sure `gh` is authenticated (`gh auth status`). Do NOT continue.
  @end if@

  @finally@ Summarize:
  - Spec status is now `Merge Ready`
  - PR has been created targeting `$dev_branch`
  - Show the PR URL
  - To merge, run `c_merge` when the PR is ready

@else@

  ## Finalize the Spec

  @tool@ Update the spec status to `Completed`

  @tool@ Ensure the directory `agent_rules/spec/completed/` exists (create it if it doesn't)

  @tool@ Move the spec file to `agent_rules/spec/completed/`

  ## Commit and Push

  @tool@ Run `git add -A && git commit -m "spec: complete {--spec_slug}"`

  @tool@ Run `git push`
  @if (push failed)@
    @stop@ Failed to push to remote. Show the user the error output. Do NOT continue.
  @end if@

  @finally@ Summarize: spec completed, moved to `spec/completed/`, and pushed to remote.

@end if@

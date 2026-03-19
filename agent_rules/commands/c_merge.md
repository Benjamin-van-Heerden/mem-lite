## Identify Spec to Merge

@tool@ List spec files in `agent_rules/spec/` (not completed/ or abandoned/) and check for specs with status `Merge Ready`

@if (no specs with status "Merge Ready" found)@
  @stop@ No specs are ready to merge. Complete a spec first with `c_complete_spec`.
@end if@

@if (the user has not specified which spec to merge, OR there are multiple merge-ready specs and it is ambiguous)@
  @stop@ Present the merge-ready specs to the user. Ask them to confirm which one to merge. Do NOT proceed until the user explicitly confirms.
@end if@

@tool@ Derive the spec slug from the confirmed spec file @into@ --spec_slug

## Check for Open PR

@tool@ Run `which gh` [Windows: `where gh`] to check if GitHub CLI is installed
@if (gh is not installed)@
  @stop@ `gh` (GitHub CLI) is not installed. It is required for the merge workflow. Install it from https://cli.github.com/ and authenticate with `gh auth login`. Do NOT continue.
@end if@

@tool@ Run `gh pr list --head $dev_branch-{--spec_slug} --base $dev_branch --state open --json number,title,url`
@if (gh command failed)@
  @stop@ Failed to query PRs. Make sure `gh` is authenticated (`gh auth status`). Do NOT continue.
@end if@

@if (no open PR found)@
  @stop@ No open PR found for branch `$dev_branch-{--spec_slug}`. The PR may have already been merged or closed. Check GitHub or run `gh pr list --state all --head $dev_branch-{--spec_slug}` for more info. Do NOT continue.
@end if@

@tool@ Extract the PR number @into@ --pr_number

## Merge the PR

@tool@ Run `gh pr merge {--pr_number} --squash --delete-branch`
@if (merge failed)@
  @stop@ PR merge failed. Show the user the error output. Common causes: merge conflicts, failing checks, or branch protection rules. The user needs to resolve the issue on GitHub. Do NOT continue.
@end if@

## Sync Local

@tool@ Run `git switch $dev_branch && git pull origin $dev_branch`
@if (switch or pull failed)@
  @stop@ Failed to sync local `$dev_branch`. Show the user the error output. Do NOT continue.
@end if@

## Finalize the Spec

@tool@ Read the spec file

@tool@ Update the spec status to `Completed`

@tool@ Ensure the directory `agent_rules/spec/completed/` exists (create it if it doesn't)

@tool@ Move the spec file to `agent_rules/spec/completed/`

@tool@ Run `git add -A && git commit -m "spec: merge {--spec_slug}"`

## Push

@tool@ Run `git push`
@if (push failed)@
  @stop@ Failed to push to remote. Show the user the error output. Do NOT continue.
@end if@

## Clean Up

@tool@ Execute `c_clean_git` — clean up any leftover branches from merged work.

@finally@ Summarize:
- PR was squash-merged into `$dev_branch`
- Local and remote `$dev_branch` are in sync
- Spec moved to `spec/completed/`
- Branches cleaned up

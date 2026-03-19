## Fetch Latest State

@tool@ Run `git fetch --prune origin`

## Identify Merged Branches

@tool@ Run `git branch --merged $dev_branch` @into@ --merged_branches

@set@ --protected_branches = ["$dev_branch", "$prod_branch", "$test_branch"]

@tool@ Filter --merged_branches to exclude --protected_branches and the current branch @into@ --branches_to_delete

@if (--branches_to_delete is empty)@
  @finally@ No merged branches to clean up. Everything is tidy.
@end if@

## Delete Local Branches

@for each branch in --branches_to_delete@
  @tool@ Run `git branch -d {branch}`
@end for each@

## Delete Remote Branches

@for each branch in --branches_to_delete@
  @tool@ Run `git push origin --delete {branch}` (ignore errors — the remote branch may already be deleted)
@end for each@

@finally@ Summarize:
- Which local branches were deleted
- Which remote branches were deleted
- Any branches that could not be deleted (and why)

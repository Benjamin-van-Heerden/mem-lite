## Project Description

@tool@ Read `./agent_rules/project_description.md`
@if (the file does not exist, is empty, or only contains the placeholder "TODO: Describe your project here")@
  @tool@ Warn the user: "No project description found. Please update `agent_rules/project_description.md` with a brief description of what this project is and what it does. This helps agents understand the project quickly during onboarding."
@else@
  @tool@ Present the project description to the user
@end if@

---

## Check Branch and Sync Status

@tool@ Run `git fetch && git branch --show-current && git status` @into@ --git_output

@if (current branch != "$dev_branch" AND current branch does not start with "$dev_branch-")@
  @tool@ Warn the user: "You are on branch '{current branch}', which is not `$dev_branch` or a `$dev_branch-*` feature branch. Be aware that dev work typically happens on `$dev_branch`."
@end if@

@if (--git_output contains "behind")@
  @stop@ Your branch is behind the remote — there are changes we don't have locally. This must be resolved before we continue.

  Ask the user: "Your branch is behind the remote. I'll pull the latest changes now. Shall I proceed?"

  @if (user confirms)@
    @if (--git_output shows uncommitted changes — staged, unstaged, or untracked files)@
      @tool@ Run `git add -A && git commit -m "wip: save local changes before rebase"`
    @end if@

    @tool@ Run `git pull --rebase origin {current branch}`
    @if (pull/rebase failed due to conflicts)@
      Assist the user in resolving the conflicts. The remote takes precedence, but do NOT discard local work — merge it in where possible. Walk through each conflict with the user, then run `git rebase --continue` once resolved.
    @end if@
  @end if@
@end if@

---

## Check for Open PRs

@tool@ Run `gh --version` to check if GitHub CLI is installed
@if (gh is installed)@
  @tool@ Run `gh pr list --state open --json number,title,headRefName,url`
  @if (there are open PRs)@
    @tool@ Present the open PRs to the user (number, title, branch, URL)
  @end if@
@else@
  @tool@ Warn the user: "`gh` (GitHub CLI) is not installed. Install it from https://cli.github.com/ for PR management features (`c_complete_spec`, `c_merge`)."
@end if@

---

## Read Core Docs

@tool@ List the contents in `./agent_rules/docs/core/`
@if (there are files in docs/core/)@
  @tool@ Read all files in `./agent_rules/docs/core/`
@end if@

---

## Read Memories

@tool@ List the contents in `./agent_rules/memories/`
@if (there are memory files)@
  @tool@ Read all memory files in `./agent_rules/memories/`
@end if@

---

## Read Active Specs

@tool@ List spec files in `./agent_rules/spec/` (not in completed/ or abandoned/ subdirectories)
@if (there are active spec files)@
  @tool@ Read all active spec files
  @tool@ Present the active specs to the user
@end if@

---

## Read Todos

@tool@ List the contents in `./agent_rules/todos/`
@if (there are open todo files, i.e. NOT in the claimed/ subdirectory)@
  @tool@ Read all open todo files in `./agent_rules/todos/` (not claimed/)
  @tool@ Present the open todos to the user
@end if@

---

## Read Work Logs

@tool@ List files in `./agent_rules/log/`
@tool@ Read the _5_ most recent log files (by filename)

---

## Project-Specific Actions

@tool@ Read `./agent_rules/project_actions.md`
@if (the file does not exist, is empty, or only contains the placeholder "TODO: Add project-specific onboarding actions here")@
  @tool@ Warn the user: "No project-specific actions found. If there are actions that should be run during onboarding (e.g. build steps, environment setup, dependency installation), update `agent_rules/project_actions.md` with instructions."
@else@
  @tool@ Execute the actions described in the file
@end if@

---

@finally@ Await further instructions, do not proceed on your own from here

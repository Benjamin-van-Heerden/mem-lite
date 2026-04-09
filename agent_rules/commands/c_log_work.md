## Create the Work Log

@tool@ Get the current date and time

@tool@ Run (`git config user.name` ? `git config user.name` : `whoami` [Windows: `$env:USERNAME`]) |> toLowerCase() |> replaceSpacesWithUnderscores() @into@ --user_name

@tool@ Create a work log file `agent_rules/log/{YYYYMMDDHHmm}_{--user_name}.md`

@composite action@
  @tools: [edit file]@

  ~~ Fill in the work log based on our current interaction.

  ```md
  # Work Log - {short title}

  @if (we were working on a spec)@
  ## Spec: `{spec_file_relative_path}`
  @end if@

  ## Goals
  {what we were trying to achieve}

  ## What Was Accomplished
  {what was done — use subtitles to organize, be technical, include code snippets where useful}

  ## Key Files Affected
  {list of files and what changed}

  @if (there were errors, barriers, or unresolved problems)@
  ## Errors and Barriers
  {what went wrong, what we tried to fix it, and suggestions for solving problems that persist across sessions}
  @end if@

  ## What Comes Next
  {next steps, remaining work, relevant spec files if applicable}
  ```

  Be concise but thorough enough so that someone else can pick up where you left off.
@end composite action@

@if (there is an associated spec file)@
  @tool@ Edit the spec file to:
  - Check off any completed task goals (`- [x] goal`)
  - Update the "Key Files" section with files modified during this session
  - Update any other sections that need to reflect the current state
@end if@

## Commit

@tool@ Run `git add -A && git commit -m "log: {short title}"`

## Push

@stop@ Ask the user: "Would you like to push these changes?"

@if (user wants to push)@
  @tool@ Run `git push`
  @if (push failed)@
    @tool@ Run `git fetch origin && git rebase origin/$(git branch --show-current)` [Windows: run `git branch --show-current` first, then `git fetch origin && git rebase origin/{result}`]
    @if (rebase failed)@
      @stop@ Rebase failed due to conflicts. Show the user the error output. They need to resolve conflicts and `git rebase --continue`, or `git rebase --abort` to undo. Do NOT continue.
    @end if@
    @tool@ Run `git push --force-with-lease`
    @if (push failed)@
      @stop@ Push failed even after rebase. Show the user the error output. Do NOT continue.
    @end if@
  @end if@
@end if@

@finally@ We are done with this session, advise the user that they should start another session to continue work

## Validate Readiness

@if (deliberations allow for spec creation, i.e. enough context about the spec/feature has been discussed)@
  @continue@
@else@
  @stop@ Ask clarifying questions as is deemed necessary. The spec should be fully discussed and agreed upon before proceeding. Go back and forth with the user until the spec is clear and complete.
@end if@

## Create the Spec File

@tool@ Get the current date and time

@tool@ Run (`git config user.name` ? `git config user.name` : `whoami` [Windows: `$env:USERNAME`]) |> toLowerCase() |> replaceSpacesWithUnderscores() @into@ --user_name

@tool@ Derive a short slug from the feature name (lowercase, underscores, no special chars) @into@ --spec_slug

@tool@ Check if the file `agent_rules/spec/s_{YYYYMMDD}_{--user_name}__{--spec_slug}.md` already exists. If it does, use `agent_rules/spec/s_{YYYYMMDD}_{--user_name}__{--spec_slug}_{HHmm}.md` instead (append the time).

@tool@ Create the spec file at the determined path

@composite action@
  @tools: [edit file]@

  ~~ Edit the spec file based on deliberations.
  Spec files take on a specific structure, defined below:

  ```md
  # {Title of the spec}

  `%% Status: Active %%`

  ## Description
  {what we are building and why — enough context for a fresh session to understand the goal}

  ## Tasks

  @for each task@

  ### {task title}
  - [ ] goal 1
  - [ ] goal 2
  - ...

  #### Description
  {detailed description of this task — what needs to happen, why, and how it fits into the larger spec}

  #### Implementation Details
  {approach, algorithms, patterns to use, gotchas — enough detail that an agent can start working without guessing}

  #### Key Files
  {to be filled in as the task progresses — files created, modified, or deleted}

  @end for each@

  ## Completion Report
  {to be written when the spec is completed — summary of what was built, key decisions, and anything a future session should know}
  ```

  Guidelines:
  - The description should be clear enough that a fresh agent can understand the goal without prior context
  - Tasks are concrete and checkable — each goal is a unit of work that can be marked done
  - Each task must have its own Description, Implementation Details, and Key Files sections
  - Implementation Details should be detailed enough that an agent can start working without guessing
  - Key Files is filled in as work progresses — leave empty or with expected files at creation time
  - The completion report is a placeholder until the spec is finalized — `c_complete_spec` fills it in
@end composite action@

## Review with User

@stop@ Present the spec to the user for review. Ask if they are happy with the spec or if changes are needed. Iterate until the user approves. Do NOT proceed until the user explicitly confirms the spec is ready.

## Ask About Branching

@stop@ Ask the user: "Would you like to work in a separate branch with the PR workflow, or just work directly in `$dev_branch`?"

@if (user wants branch + PR workflow)@

  @tool@ Edit the spec file — add `Branch: $dev_branch-{--spec_slug}` on the line directly after the status line, so it reads:
  ```
  `%% Status: Active %%`
  `%% Branch: $dev_branch-{--spec_slug} %%`
  ```

  @tool@ Run `git add -A && git commit -m "spec: create {--spec_slug}"`
  @tool@ Run `git push`
  @tool@ Run `git switch -c $dev_branch-{--spec_slug}`
  @tool@ Run `git push -u origin $dev_branch-{--spec_slug}`

  @finally@ Notify the user:
  - The spec has been created and pushed to branch `$dev_branch-{--spec_slug}`
  - We are now on branch `$dev_branch-{--spec_slug}`
  - The `$dev_branch` branch remains clean
  - We can continue working on the spec

@else@

  @tool@ Run `git add -A && git commit -m "spec: create {--spec_slug}"`
  @tool@ Run `git push`

  @finally@ Notify the user:
  - The spec has been created and pushed to `$dev_branch`
  - We can continue working on the spec

@end if@

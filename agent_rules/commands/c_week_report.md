## Gather Context

@tool@ Get the current date and time @into@ --now

@tool@ Run (`git config user.name` ? `git config user.name` : `whoami` [Windows: `$env:USERNAME`]) |> toLowerCase() |> replaceSpacesWithUnderscores() @into@ --user_name

@tool@ Calculate the Monday and Sunday of the current work week based on --now @into@ --week_start (YYYYMMDD), --week_end (YYYYMMDD)

---

## Find Relevant Logs

@tool@ List all files in `./agent_rules/log/`

@tool@ Filter log files to those that:
1. Contain --user_name in the filename
2. Have a date (from filename prefix) falling within --week_start to --week_end (inclusive)

@if (no matching logs found)@
  @stop@ No work logs found for --user_name between --week_start and --week_end. Nothing to report.
@end if@

@tool@ Read all matching log files

---

## Generate the Report

@tool@ Ensure the directory `agent_rules/tmp/` exists (create it if it doesn't)

@tool@ Create a report file `agent_rules/tmp/{--user_name}_week_report_{--week_start}_{--week_end}.md`

@composite action@
  @tools: [edit file]@

  ~~ Synthesize all the work logs into a concise weekly summary. Structure:

  ```md
  # Week Report: {--week_start} — {--week_end}

  **Author:** {--user_name}
  **Generated:** {--now}
  **Logs reviewed:** {number of logs}

  ## Summary

  {2-3 paragraph high-level summary of what was accomplished this week. Written for a non-technical audience — focus on outcomes and progress, not implementation details.}

  ## Work Done

  @for each day that had work@

  ### {Day, Date}
  {bullet points summarizing what was done, derived from the logs for that day}

  @end for each@

  ## Key Achievements
  {bullet list of the most significant outcomes — things worth highlighting to stakeholders}

  ## Blockers and Issues
  {any errors, barriers, or unresolved problems from the week's logs. Omit this section if there were none.}

  ## Next Steps
  {consolidated next steps from the week's logs — what carries forward into next week}
  ```

  Guidelines:
  - Be concise — this is for reporting, not for session handoff
  - Group related work together rather than repeating across days
  - Focus on outcomes and deliverables, not process
  - If work was tied to specs, mention the spec names
@end composite action@

@finally@ Report generated at `agent_rules/tmp/{--user_name}_week_report_{--week_start}_{--week_end}.md`. This file is in `agent_rules/tmp/` which is git-ignored — copy or move it if you need to keep it.

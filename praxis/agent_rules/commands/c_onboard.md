# Onboard

The first thing to do at the start of every session, before responding to
anything else. Builds context: who the lawyer is, what's open, what's due,
what's in flight, what's been said before.

You run this on the **first message of every session**, regardless of what the
lawyer asked for, unless they explicitly say "skip onboard".

## Actions

Read these in order. Be efficient — don't dump every file's contents to the
lawyer; just internalise the context.

1. **Lawyer profile.** Read `agent_rules/lawyer_profile.md`. As you read,
   check whether the literal string `PLACEHOLDER — NOT YET FILLED IN` appears.
   If it does, set a flag: this file is unfilled. You will warn the lawyer
   prominently in the briefing.
2. **Core docs.** Read every file in `agent_rules/docs/core/`. These are
   always-on reference (typst syntax, jurisdictional legal context). You will
   pull from these throughout the session. As you read each file, check for
   the literal string `PLACEHOLDER — NOT YET FILLED IN`. Track which core
   docs are unfilled — you will warn about those in the briefing.
3. **Clients.** Run `agent_rules/scripts/list_clients.sh`. This is who
   exists. A client may have zero open matters and still need to be on your
   radar.
4. **Open matters.** Run `agent_rules/scripts/list_open_matters.sh`. The
   output includes the `open_todos` count per matter — note matters with
   non-zero scoped todos.
5. **Upcoming deadlines (14 days).** Run `agent_rules/scripts/upcoming_deadlines.sh 14`.
6. **High-priority matters.** For any matter from step 4 with `priority: high`
   or `urgent`, read `info/status.md` (`## Posture` + `## What's next`) and
   the last ~5 entries of `info/record.md`. Don't run the full
   `c_focus_matter` flow yet — just enough to brief.
7. **Recent work logs.** Read the 3 most recent files in `agent_rules/log/`.
8. **Memories.** Read every file in `agent_rules/memories/`.
9. **Open todos.** Read every file in `agent_rules/todos/` (excluding
   `claimed/`).

## Briefing

Print a compact briefing to the lawyer in plain language. Aim for under 30
lines. Structure:

- **Placeholder warnings (if any).** If `lawyer_profile.md` or any core doc
  was flagged as unfilled in steps 1–2, lead with a strong, prominent warning
  block before anything else. Be direct, not apologetic. For example:

  > ⚠ **Setup incomplete.** `agent_rules/lawyer_profile.md` and
  > `agent_rules/docs/core/legal_context.typ` are still placeholders. Until
  > you fill these in, my drafting will be guesswork — wrong tone, wrong
  > citation style, possibly wrong jurisdictional rules. Please fill them in
  > before we draft anything substantive.

  List exactly which files are unfilled. Don't soften — the lawyer needs to
  know. If everything is filled, skip this section entirely.

- **Profile line.** One line: who they are / what they practice (drawn from
  `lawyer_profile.md`). Skip if `lawyer_profile.md` is still a placeholder
  (the warning above already covers it).
- **Where things stand.** Number of clients, number of open matters, count
  of upcoming deadlines, total open todos.
- **Imminent.** Any deadlines in the next 14 days, sorted by date. State
  each in plain language: "_15 May 2026 (16 days) — answering affidavit on
  the Smith / Jones arbitration_".
- **High-priority attention.** For each high or urgent matter, one sentence
  drawn from Posture + What's next, plus the most recent record entry if
  useful.
- **Matters with open todos.** One line per matter that has scoped todos:
  "_Smith / Jones arbitration — 2 open todos_". Skip if none.
- **Recent activity.** Two or three lines summarising the last sessions
  from the recent logs — what was done, what was left for next time.
- **Open todos.** One line each (or "(none)"). Note which matter each is
  scoped to, if any.

End with a single open invitation, e.g. _"Where do you want to start?"_ If
placeholders are unfilled, the natural next move is "let's fill those in
first" — say so explicitly.

## After the briefing

The lawyer will respond. Listen for direction:

- **They name a matter** ("let's work on Smith", "the breach case") → run `c_focus_matter`. Do that **before** continuing with any specific request they tacked on.
- **They mention something that happened** ("Jones called this morning", "we got served yesterday") → suggest the appropriate record (`c_log_communication`, `c_add_deadline`, edit `info/status.md`).
- **They want something drafted** without naming a matter → ask which matter or client it relates to.
- **They want to start something new** ("I have a new client", "open a matter") → run the corresponding `c_new_*` command.
- **They ask a question** → answer from the loaded context, draw on memories.
- **They go quiet or say "let's begin"** → wait for direction; don't start work uninvited.

Throughout, follow the *Common moves* and *How to talk to the lawyer* sections
of `AGENTS.md`.

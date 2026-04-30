# New document

Use when the lawyer asks for something to be drafted: a letter, a notice of
motion, an opinion, a contract, a memo, anything.

## You handle

- **Matter.** Confirm which matter this is for (usually obvious from context — the active matter in the conversation).
- **Template.** Pick the closest one in `templates/`. Browse with `find templates -name '*.typ'` if you're not sure what's available. If nothing fits, copy the closest and edit, or start from `templates/components/style.typ` and build up.
- **Document slug.** Derive from purpose: "letter of demand" → `letter_of_demand`; "answering affidavit" → `answering_affidavit`; "opinion on prescription" → `opinion_prescription`. Short and descriptive.

## Confirm lightly

> "Drafting a letter of demand to Jones from the `letters/demand` template. OK?"

## Action

```
agent_rules/scripts/new_document.sh <matter_ref> <template_path> <document_slug>
```

The script copies the template into the matter as `NN_<slug>.typ` (NN = next
sequence number). Echoes the new file path.

## Then draft

- Read the matter's `info/status.md` for the facts you'll need: client name,
  opposing party, court, case number, dates.
- Read `reference/` if the document depends on inbound material.
- Edit the new typst file:
  - Replace template placeholders with matter-specific content.
  - Use snippets from `functions/` for currency, dates, citations.
  - Use components from `templates/components/` for letterhead and signature.
- Show the lawyer a preview by reading back the key sections in plain language
  ("here's the demand paragraph: ...") rather than dumping typst source.
- The lawyer's typst is typically in watch mode — the PDF rebuilds. If not,
  compile manually when asked.

## After

- Read the rendered PDF path back to the lawyer for review.
- Once finalised and sent, suggest `c_log_communication` to record the
  outbound transmission.
- If the document represents a reusable pattern, after it's been used once or
  twice, suggest promoting it via `c_new_template`.

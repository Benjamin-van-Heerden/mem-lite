# New template

Use when a finished or near-finished document should become reusable.

## You handle

- **Source file.** A typst document in a matter that has stabilised.
- **Category.** One of: `letters`, `pleadings`, `opinions`, `contracts`, `memos`, `components`. Pick by purpose.
- **Slug.** Short, lowercase, descriptive of the template's purpose: `letter_of_demand`, `notice_of_motion`, `answering_affidavit_general`, `sale_of_shares`.

## Sanitise first

Before saving as a template, **edit the source to remove matter-specific
content**:

- Replace client names, opposing parties, case numbers, dates with descriptive
  placeholders or generic illustrative content.
- Strip privileged facts.
- Keep the structure, headings, formatting, and reusable phrasing.

Show the lawyer the sanitised version and ask: "Save this as a template?"

## Action

```
agent_rules/scripts/new_template.sh <source_typ> <category> <slug>
```

## After

- Confirm in plain language: "Saved as `letters/letter_of_demand`. Available
  for future matters."
- If this template represents a way of doing things worth remembering, suggest
  `c_create_memory` describing when to reach for it.

# New function

Use when a small typst snippet is recurring and should be reusable. Currency
formatting, date formatting, table styles, citation helpers, signature blocks.

## You handle

- **Slug.** Short, lowercase, descriptive: `currency_zar`, `sa_date`, `case_citation`, `numbered_clauses`.
- **Description.** What it does, in one sentence.

## Confirm lightly

> "I'll save this as a function called `currency_zar`. Yes?"

## Action

```
agent_rules/scripts/new_function.sh <slug>
```

Creates a stub `functions/<slug>.typ`.

## Then implement

- Edit the new file. Keep it small and focused — one job.
- Add a header comment explaining what it does and how to import it.
- Test by importing into a real document: `#import "../../../functions/<slug>.typ": *` (path depends on where the document lives).

## After

- Confirm in plain language. Mention any document that should now be updated
  to use the new function instead of inline typst.

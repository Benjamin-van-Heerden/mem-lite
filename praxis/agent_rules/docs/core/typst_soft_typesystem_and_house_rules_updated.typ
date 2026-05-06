// AGENT: Read this file before creating or editing `src/types/*.typ` modules.

= Typst Soft Type System

This repository uses a small, explicit soft type system for reusable Typst
business-document templates. Typst does not provide nominal user-defined types,
so we model domain records with constructor functions that return dictionaries
containing a `kind` tag.

The goals are:

- keep public template calls readable and self-documenting;
- avoid anonymous ad hoc dictionaries at call sites;
- validate domain values at template boundaries;
- make Tinymist hover documentation useful;
- keep renderer functions modular and narrow.

== Directory and Naming

Soft type constructors live under `src/types/`.

Default project naming distinguishes callable methods from variables:

- callable functions and methods use `snake_case`;
- variables, parameters, named arguments, and dictionary fields use kebab-case;
- type constructors use `CamelCase`;
- type methods use `{Type}_{method}`, where the type is `CamelCase` and the
  method is `snake_case`.

Type module filenames are the exception to normal underscore file naming. They
use `CamelCase` and match the constructor exported by the file:

```typ
src/types/Client.typ
src/types/BankAccount.typ
src/types/Company.typ
src/types/Money.typ
src/types/ShareHolder.typ
src/types/WorkEntry.typ
```

`src/types/assert.typ` is not a type module. It stays lowercase because it only
exports shared methods that act on soft-typed values, such as `assert_kind`.

The constructor exported by each type file is also capitalized:

```typ
#import "../src/types/Client.typ": Client

#let client = Client(
  "URBTEC (PTY) LTD",
  registration: "2019/409363/07",
)
```

Type operations exported from type modules use `{Type}_{method}`:

```typ
#import "../types/Client.typ": Client_assert
#import "../types/Money.typ": Money_display, Money_sum
```

Validators are type methods named `{Type}_assert`:

```typ
#let Client_assert(value) = assert_kind(value, "Client")
```

This keeps type operations visually tied to their type while preserving the
method naming rule.

Public exported names must not start with `_`. Helpers scoped to the same file
must start with `_`, for example `_client_rows` or `_date_display`.

Do not introduce snake_case variables in new Typst code. If touching existing
Typst code, keep callable names as `snake_case`, but use kebab-case for
variables, parameters, named arguments, and dictionary fields.

Shared soft-type infrastructure lives in `src/types/assert.typ`; its exported
functions follow regular `snake_case`, for example `assert_kind`.

Do not create soft types that only wrap built-in Typst values without adding a
domain invariant. In particular, use Typst's built-in `datetime` directly for
dates and format it at the rendering boundary. Plain display strings are also
acceptable when the date is already presentation text.

Typed constants live under `src/constants/`. Constants that represent domain
records should be constructed with the relevant soft type, for example
`yhat-company = Company(...)` or `default-bank-account = BankAccount(...)`.

Rendering functions live under `src/functions/`. Small generic helpers may live
under `src/functions/helpers/` when the same simple behavior is needed across
multiple rendering modules.

== Constructor Shape

Required fields are positional parameters without defaults. Optional fields are
named parameters with defaults.

Prefer this:

```typ
/// Construct a client record for invoices and business documents.
///
/// - name (str): Legal or trading name of the client.
/// - registration (str, none): Company registration number.
/// -> dictionary
#let Client(
  name,
  registration: none,
) = (
  kind: "Client",
  name: name,
  registration: registration,
)
```

Avoid making required parameters default to `none` just to allow a fully named
call site. Tinymist treats defaulted parameters as named parameters and may
alphabetize them in hover output, which makes the signature harder to read.

Use this call shape for required fields:

```typ
#let client = Client(
  "URBTEC (PTY) LTD",
  registration: "2019/409363/07",
)
```

Not this:

```typ
#let client = Client(
  name: "URBTEC (PTY) LTD",
  registration: "2019/409363/07",
)
```

== Constructor Invariants

Constructors should validate invariants that define the domain record itself.
Do not defer intrinsic consistency checks to templates or renderers.

Examples:

- `ShareHolder(...)` requires exactly one of `number-of-shares` or
  `percentage-ownership`.
- `Company(...)` validates that shareholders all use the same ownership basis.
- If shareholders use `number-of-shares`, `Company(...)` requires
  `number-of-shares` and validates the shareholder share total against it.
- If shareholders use `percentage-ownership`, `Company(...)` validates that the
  percentages add to `100`.
- Optional fields such as `tax-number` should default to `none` rather than
  using empty strings as absence markers.

Preferred ownership model:

```typ
#let company = Company(
  "Yhat Solutions (Pty) Ltd",
  "Yhat Solutions",
  "2023/699445/07",
  "Benjamin van Heerden",
  "49 De Havilland Cres, Persequor, Pretoria, 0020",
  number-of-shares: 180,
  shareholders: (
    ShareHolder("Benjamin van Heerden", number-of-shares: 180),
  ),
)
```

== Documentation Comments

Use Tinymist-style `///` comments immediately before definitions. This applies
to public exports and to private helpers scoped to a file.

Document parameters in the main doc block, not as `///` comments inside the
function parameter list. The parameter-list style was intentionally avoided here
because it produced worse hover output for this project.

Preferred style:

```typ
/// Construct a money value from minor units.
///
/// - cents (int): Amount in minor units.
/// - currency (str): Currency label.
/// - display (str, none): Optional display value.
/// -> dictionary
#let Money(
  cents,
  currency: "ZAR",
  display: none,
) = (
  kind: "Money",
  cents: cents,
  currency: currency,
  display: display,
)
```

Use `str`, `int`, `float`, `array`, `dictionary`, `datetime`, `none`, and
`markup` in docs. Use `markup` when callers may pass a Typst markup block such
as `[Due upon receipt]`. Avoid `content` in human-facing type hints unless the
internal Typst value type itself is the point being discussed.

Required fields should not be documented as nullable. Only optional fields
should include `none`.

Private helper documentation should still be precise and short:

```typ
/// Return display rows for a bank account.
///
/// - bank (dictionary): Bank account. See `src/types/BankAccount.typ`.
/// -> array
#let _bank_rows(bank) = {
  // type checks
  let bank = BankAccount_assert(bank)
  //

  (
    (label: "Bank", value: bank.bank),
    (label: "Account Number", value: bank.account-number),
  )
}
```

== Runtime Validation

Every constructor returns a dictionary with a `kind` tag:

```typ
(
  kind: "Client",
  name: name,
)
```

`src/types/assert.typ` provides `assert_kind(value, expected)`. Each type module
should export a dedicated validator:

```typ
#import "assert.typ": assert_kind

#let Client_assert(value) = assert_kind(value, "Client")
```

Templates validate soft types at their boundaries:

```typ
#import "../types/Client.typ": Client_assert

#let hourly_invoice(client, ..args) = {
  // type checks
  let client = Client_assert(client)
  //

  // render...
}
```

This catches accidental plain dictionaries or wrong soft types early.

Use the explicit `// type checks` block at the start of any function that
accepts soft-typed values. Keep all boundary assertions together, then close the
block with a plain `//` separator before doing derivation or rendering work:

```typ
#let render_invoice(client, total-payable, work, ..args) = {
  // type checks
  let client = Client_assert(client)
  let total-payable = Money_assert(total-payable)
  let work = work.map(WorkEntry_assert)
  //

  let subtitle = if subtitle == none { issue-date } else { subtitle }
  // render...
}
```

Private helpers are not exempt from validation. If a private helper accepts a
soft-typed value, it should assert that value even when its public caller also
asserted it. This keeps helpers self-documenting, copyable, and robust when
they are reused later.

== Template Call Signatures

Templates should use positional parameters for required values so Typst fails
fast when calls omit them or pass arguments in the wrong shape. Optional
parameters should be named. If a parameter expects a soft type, document it by
pointing at the type module, because Tinymist cannot infer the nominal type from
a dictionary.

Example:

```typ
/// Render an hourly-work invoice.
///
/// - client (dictionary): The Client for whom to render the invoice. See `src/types/Client.typ`.
/// - hourly-rate (dictionary): Hourly rate. See `src/types/Money.typ`.
/// - work (array): Logged work entries. Each item must be a WorkEntry. See `src/types/WorkEntry.typ`.
/// -> content
#let hourly_invoice(
  invoice-number,
  client,
  description,
  hourly-rate,
  work,
  billable-hours: none,
) = {
  // validate and render
}
```

Do not make required template parameters default to `none` just to implement
custom `panic` checks. That overrides Typst's own fast signature validation and
makes hover output worse.

Arrays of dictionaries are acceptable for repeated domain values only when each
item is created by a constructor, for example:

```typ
work: (
  WorkEntry("2026-04-02", 8),
  WorkEntry("2026-04-09", 7),
)
```

Avoid arbitrary anonymous dictionaries at public call sites unless the data is
genuinely open-ended extension data, such as `(label: str, value: any)` rows.

== Module Size

Keep `src/functions/` modules small and self-contained. A module should usually
own one rendering primitive, such as payment instructions, invoice details, or a
work log. Do not create broad god files for entire domains.

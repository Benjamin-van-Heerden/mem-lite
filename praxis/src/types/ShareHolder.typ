#import "assert.typ": assert_kind

/// Construct a shareholder record for company ownership metadata.
///
/// Provide either `number-of-shares` or `percentage-ownership`, not both.
///
/// - name (str): Shareholder name.
/// - number-of-shares (int, none): Number of shares held.
/// - percentage-ownership (int, float, none): Percentage ownership.
/// -> dictionary
#let ShareHolder(
  name,
  number-of-shares: none,
  percentage-ownership: none,
) = {
  if number-of-shares == none and percentage-ownership == none {
    panic("ShareHolder requires number-of-shares or percentage-ownership")
  }
  if number-of-shares != none and percentage-ownership != none {
    panic("ShareHolder cannot use both number-of-shares and percentage-ownership")
  }

  (
    kind: "ShareHolder",
    name: name,
    number-of-shares: number-of-shares,
    percentage-ownership: percentage-ownership,
  )
}

/// Validate a `ShareHolder(...)` value.
///
/// - value (dictionary): Value to validate.
/// -> dictionary
#let ShareHolder_assert(value) = assert_kind(value, "ShareHolder")

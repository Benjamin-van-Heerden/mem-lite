#import "assert.typ": assert_kind
#import "Money.typ": Money_assert

/// Construct one hourly work log entry.
///
/// - date (str, datetime): Date or date display for the work entry.
/// - hours (int, float, str): Hours worked.
/// - amount (dictionary): Amount for this work entry. Use `Money(...)`.
/// - description (str, none): Optional short description for this row.
/// -> dictionary
#let WorkEntry(
  date,
  hours,
  amount,
  description: none,
) = {
  let amount = Money_assert(amount)
  (
    kind: "WorkEntry",
    date: date,
    hours: hours,
    amount: amount,
    description: description,
  )
}

/// Validate a `WorkEntry(...)` value.
///
/// - value (dictionary): Value to validate.
/// -> dictionary
#let WorkEntry_assert(value) = assert_kind(value, "WorkEntry")

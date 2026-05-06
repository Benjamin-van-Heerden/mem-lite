#import "assert.typ": assert_kind

/// Construct a money value from minor units.
///
/// `cents` keeps arithmetic predictable. Use `display` when a specific
/// presentation is required, for example `"ZAR 14 000"`.
///
/// - cents (int): Amount in minor units.
/// - currency (str): Currency label.
/// - display (str, none): Optional display value. If omitted, a simple decimal display is generated.
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

/// Validate a `Money(...)` value.
///
/// - value (dictionary): Value to validate.
/// -> dictionary
#let Money_assert(value) = assert_kind(value, "Money")

/// Format a `Money(...)` value for display.
///
/// - money (dictionary): Money value to format.
/// -> str
#let Money_display(money) = {
  let money = Money_assert(money)
  if money.display != none {
    money.display
  } else {
    let sign = if money.cents < 0 { "-" } else { "" }
    let abs-cents = calc.abs(money.cents)
    let whole = calc.quo(abs-cents, 100)
    let cents = calc.rem(abs-cents, 100)
    let cents-text = if cents < 10 { "0" + str(cents) } else { str(cents) }
    sign + money.currency + " " + str(whole) + "." + cents-text
  }
}

/// Sum multiple `Money(...)` values.
///
/// All values must use the same currency. The returned value omits `display`
/// so presentation is generated from the summed cents.
///
/// - monies (array): Money values to add.
/// -> dictionary
#let Money_sum(monies) = {
  if monies.len() == 0 {
    panic("Money_sum requires at least one Money value")
  }

  let monies = monies.map(Money_assert)
  let currency = monies.first().currency
  let cents = monies.fold(0, (total, money) => {
    if money.currency != currency {
      panic("Cannot sum Money values with different currencies")
    }
    total + money.cents
  })

  Money(cents, currency: currency)
}

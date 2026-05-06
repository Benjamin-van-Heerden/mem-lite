#import "assert.typ": assert_kind
#import "ShareHolder.typ": ShareHolder_assert

/// Validate shareholder records against company ownership metadata.
///
/// - shareholders (array): ShareHolder values to validate.
/// -> array

/// Construct a company or firm profile for business documents.
///
/// - name (str): Registered company or firm name.
/// - trading-name (str): Trading or display name.
/// - registration (str): Registration or practice number.
/// - director (str): Primary director, partner, or representative.
/// - registered-address (str): Registered address, usually comma-separated.
/// - tax-number (str, none): Tax registration number.
/// - shareholders (array): ShareHolder values. See `src/types/ShareHolder.typ`.
/// - postal-address (str, none): Postal address.
/// - email (str, none): Contact email.
/// - cell (str, none): Contact number.
/// - website (str, none): Website URL.
/// -> dictionary
#let Company(
  name,
  trading-name,
  registration,
  director,
  registered-address,
  tax-number: none,
  shareholders: (),
  postal-address: none,
  email: none,
  cell: none,
  website: none,
) = {
  let shareholders = shareholders.map(ShareHolder_assert)

  (
    kind: "Company",
    name: name,
    trading-name: trading-name,
    registration: registration,
    tax-number: tax-number,
    director: director,
    registered-address: registered-address,
    shareholders: shareholders,
    postal-address: postal-address,
    email: email,
    cell: cell,
    website: website,
  )
}

/// Validate a `Company(...)` value.
///
/// - value (dictionary): Value to validate.
/// -> dictionary
#let Company_assert(value) = assert_kind(value, "Company")

/// Return registered-address lines for a `Company(...)` value.
///
/// - company (dictionary): Company value to inspect.
/// -> array
#let Company_registered_address_lines(company) = {
  let company = Company_assert(company)
  company.registered-address
    .split(",")
    .map(part => part.trim())
    .filter(part => part != "")
}

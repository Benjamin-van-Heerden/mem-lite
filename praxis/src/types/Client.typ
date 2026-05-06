#import "assert.typ": assert_kind

/// Construct a client record for invoices and business documents.
///
/// - name (str): Legal or trading name of the client.
/// - registration (str, none): Company registration number.
/// - address (str, none): Billing or registered address.
/// - email (str, none): Billing contact email.
/// - details (array): Additional rows to render under standard client fields. Each item should be `(label: str, value: any)`.
/// -> dictionary
#let Client(
  name,
  registration: none,
  address: none,
  email: none,
  details: (),
) = (
  kind: "Client",
  name: name,
  registration: registration,
  address: address,
  email: email,
  details: details,
)

/// Validate a `Client(...)` value.
///
/// - value (dictionary): Value to validate.
/// -> dictionary
#let Client_assert(value) = assert_kind(value, "Client")

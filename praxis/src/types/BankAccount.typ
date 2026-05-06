#import "assert.typ": assert_kind

/// Construct a bank account record for payment instructions.
///
/// - bank (str): Bank name.
/// - account-holder (str): Account holder name.
/// - account-number (str): Account number.
/// - account-type (str, none): Account type.
/// - registered-entity (str, none): Registered entity for the account.
/// -> dictionary
#let BankAccount(
  bank,
  account-holder,
  account-number,
  account-type: none,
  registered-entity: none,
) = (
  kind: "BankAccount",
  bank: bank,
  account-holder: account-holder,
  account-number: account-number,
  account-type: account-type,
  registered-entity: registered-entity,
)

/// Validate a `BankAccount(...)` value.
///
/// - value (dictionary): Value to validate.
/// -> dictionary
#let BankAccount_assert(value) = assert_kind(value, "BankAccount")

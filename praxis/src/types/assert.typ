/// Return the soft type tag stored on a constructed value.
///
/// -> str | none
#let _kind_of(value) = value.at("kind", default: none)

/// Validate that a value was produced by the expected constructor.
///
/// - value (dictionary): Value to validate.
/// - expected (str): Expected soft type tag, for example `"Client"`.
/// -> dictionary
#let assert_kind(value, expected) = {
  let actual = _kind_of(value)
  if actual != expected {
    panic("Expected " + expected + ", got " + str(actual))
  }
  value
}

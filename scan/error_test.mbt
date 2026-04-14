///|
test "scan error message formats line-aware variants" {
  assert_eq(
    ScanError::JsonParse(2, "bad token").message(),
    "json parse error at line 2: bad token",
  )
  assert_eq(
    ScanError::JsonRootNotObject(7).message(),
    "expected JSON object at line 7",
  )
  assert_eq(
    ScanError::TypeMismatch("score", 3, "expected numeric value or null").message(),
    "type mismatch for column score at line 3: expected numeric value or null",
  )
}

///|
test "scan error message preserves direct io and csv messages" {
  assert_eq(ScanError::Io("boom").message(), "boom")
  assert_eq(ScanError::CsvMalformed("bad row").message(), "bad row")
}

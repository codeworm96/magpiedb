///|
test "db error variants are constructible inside the package" {
  let errors = [
    DbError::InvalidArgument("bad input"),
    DbError::SqlSyntax("bad sql"),
    DbError::Bind("bad binding"),
    DbError::Scan("bad scan"),
    DbError::Io("bad io"),
    DbError::Execute("bad execution"),
    DbError::Unsupported("bad feature"),
    DbError::Internal("bad state"),
  ]

  assert_eq(errors.length(), 8)
}

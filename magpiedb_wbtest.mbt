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

///|
async test "database schema catalog is shared across connections" {
  let db = Database::new()
  assert_eq(db.catalog.entry_count(), 0)

  let conn1 = db.connect()
  let conn2 = db.connect()

  ignore(
    conn1.query("SELECT name FROM read_csv('fixtures/csv/people.csv')").unwrap(),
  )
  assert_eq(db.catalog.entry_count(), 1)

  ignore(
    conn2.query("SELECT age FROM read_csv('fixtures/csv/people.csv')").unwrap(),
  )
  assert_eq(db.catalog.entry_count(), 1)

  ignore(
    conn2
    .query("SELECT id FROM read_jsonl('fixtures/jsonl/events.jsonl')")
    .unwrap(),
  )
  assert_eq(db.catalog.entry_count(), 2)
}

///|
async test "database schema catalog rejects kind mismatch for same path" {
  let db = Database::new()
  let conn = db.connect()

  ignore(
    conn.query("SELECT name FROM read_csv('fixtures/csv/people.csv')").unwrap(),
  )
  assert_eq(db.catalog.entry_count(), 1)

  let err = conn
    .query("SELECT id FROM read_jsonl('fixtures/csv/people.csv')")
    .unwrap_err()
  match err {
    DbError::Bind(message) => {
      assert_true(message.contains("fixtures/csv/people.csv"))
      assert_true(message.contains("read_csv"))
      assert_true(message.contains("read_jsonl"))
    }
    _ => fail("expected bind error")
  }
  assert_eq(db.catalog.entry_count(), 1)
}

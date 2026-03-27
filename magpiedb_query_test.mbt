///|
test "query executes projection and filter over read_jsonl" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT id, name FROM read_jsonl('fixtures/jsonl/events.jsonl') WHERE active = true",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "id", data_type: LogicalType::BigInt, nullable: false },
    { name: "name", data_type: LogicalType::Varchar, nullable: true },
  ])
  assert_eq(result.next(), Some([Value::BigInt(1L), Value::Varchar("Ada")]))
  assert_eq(result.next(), Some([Value::BigInt(3L), Value::Null]))
  assert_eq(result.next(), None)
}

///|
test "query supports aliases and literals over read_jsonl" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT id AS event_id, 'ok' AS status FROM read_jsonl('fixtures/jsonl/events.jsonl') WHERE id >= 2",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "event_id", data_type: LogicalType::BigInt, nullable: false },
    { name: "status", data_type: LogicalType::Varchar, nullable: false },
  ])
  assert_eq(result.next(), Some([Value::BigInt(2L), Value::Varchar("ok")]))
  assert_eq(result.next(), Some([Value::BigInt(3L), Value::Varchar("ok")]))
  assert_eq(result.next(), None)
}

///|
test "query rejects unknown columns" {
  let conn = Database::new().connect()
  let err = conn
    .query("SELECT missing FROM read_jsonl('fixtures/jsonl/events.jsonl')")
    .unwrap_err()

  match err {
    DbError::Bind(message) => assert_true(message.contains("missing"))
    _ => fail("expected bind error")
  }
}

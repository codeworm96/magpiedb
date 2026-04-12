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

///|
test "query executes projection and filter over read_csv" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT name, age FROM read_csv('fixtures/csv/people.csv') WHERE age > 18",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "name", data_type: LogicalType::Varchar, nullable: false },
    { name: "age", data_type: LogicalType::BigInt, nullable: true },
  ])
  assert_eq(result.next(), Some([Value::Varchar("Ada"), Value::BigInt(30L)]))
  assert_eq(result.next(), Some([Value::Varchar("Carla"), Value::BigInt(41L)]))
  assert_eq(result.next(), None)
}

///|
test "query executes global aggregate over read_csv" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT COUNT(*) AS total, AVG(age) AS avg_age FROM read_csv('fixtures/csv/people.csv')",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "total", data_type: LogicalType::BigInt, nullable: false },
    { name: "avg_age", data_type: LogicalType::Double, nullable: true },
  ])
  assert_eq(result.next(), Some([Value::BigInt(3L), Value::Double(35.5)]))
  assert_eq(result.next(), None)
}

///|
test "query executes grouped aggregate with having over read_jsonl" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT active, COUNT(*) AS total FROM read_jsonl('fixtures/jsonl/events.jsonl') GROUP BY active HAVING COUNT(*) > 1",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "active", data_type: LogicalType::Boolean, nullable: false },
    { name: "total", data_type: LogicalType::BigInt, nullable: false },
  ])
  assert_eq(result.next(), Some([Value::Boolean(true), Value::BigInt(2L)]))
  assert_eq(result.next(), None)
}

///|
test "query treats division as float division inside aggregates" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT SUM(age / 2) AS half_total FROM read_csv('fixtures/csv/people.csv')",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "half_total", data_type: LogicalType::Double, nullable: true },
  ])
  assert_eq(result.next(), Some([Value::Double(35.5)]))
  assert_eq(result.next(), None)
}

///|
test "query executes csv jsonl inner join with where over joined rows" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT people.name, events.active FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id WHERE events.active = true",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "name", data_type: LogicalType::Varchar, nullable: false },
    { name: "active", data_type: LogicalType::Boolean, nullable: false },
  ])
  assert_eq(result.next(), Some([Value::Varchar("Ada"), Value::Boolean(true)]))
  assert_eq(result.next(), Some([Value::Varchar("Bob"), Value::Boolean(true)]))
  assert_eq(
    result.next(),
    Some([Value::Varchar("Bobby"), Value::Boolean(true)]),
  )
  assert_eq(result.next(), None)
}

///|
test "query executes csv csv inner join" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT people.name, flags.team FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_csv('fixtures/csv/join_flags.csv') AS flags ON people.id = flags.id",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "name", data_type: LogicalType::Varchar, nullable: false },
    { name: "team", data_type: LogicalType::Varchar, nullable: false },
  ])
  assert_eq(
    result.next(),
    Some([Value::Varchar("Ada"), Value::Varchar("alpha")]),
  )
  assert_eq(
    result.next(),
    Some([Value::Varchar("Bob"), Value::Varchar("beta")]),
  )
  assert_eq(
    result.next(),
    Some([Value::Varchar("Bob"), Value::Varchar("gamma")]),
  )
  assert_eq(
    result.next(),
    Some([Value::Varchar("Bobby"), Value::Varchar("beta")]),
  )
  assert_eq(
    result.next(),
    Some([Value::Varchar("Bobby"), Value::Varchar("gamma")]),
  )
  assert_eq(result.next(), None)
}

///|
test "query executes jsonl jsonl inner join" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT events.name, profiles.city FROM read_jsonl('fixtures/jsonl/join_events.jsonl') AS events JOIN read_jsonl('fixtures/jsonl/join_profiles.jsonl') AS profiles ON events.id = profiles.id",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "name", data_type: LogicalType::Varchar, nullable: false },
    { name: "city", data_type: LogicalType::Varchar, nullable: false },
  ])
  assert_eq(
    result.next(),
    Some([Value::Varchar("Launch"), Value::Varchar("A")]),
  )
  assert_eq(
    result.next(),
    Some([Value::Varchar("Review"), Value::Varchar("B")]),
  )
  assert_eq(
    result.next(),
    Some([Value::Varchar("Review"), Value::Varchar("C")]),
  )
  assert_eq(result.next(), Some([Value::Varchar("Retry"), Value::Varchar("B")]))
  assert_eq(result.next(), Some([Value::Varchar("Retry"), Value::Varchar("C")]))
  assert_eq(result.next(), None)
}

///|
test "query executes global aggregate over csv jsonl join" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT COUNT(*) AS total, SUM(events.id) AS total_id FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "total", data_type: LogicalType::BigInt, nullable: false },
    { name: "total_id", data_type: LogicalType::BigInt, nullable: true },
  ])
  assert_eq(result.next(), Some([Value::BigInt(5L), Value::BigInt(9L)]))
  assert_eq(result.next(), None)
}

///|
test "query executes grouped aggregate with having over join" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT people.name, COUNT(*) AS total FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_csv('fixtures/csv/join_flags.csv') AS flags ON people.id = flags.id GROUP BY people.name HAVING COUNT(*) > 1",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "name", data_type: LogicalType::Varchar, nullable: false },
    { name: "total", data_type: LogicalType::BigInt, nullable: false },
  ])
  assert_eq(result.next(), Some([Value::Varchar("Bob"), Value::BigInt(2L)]))
  assert_eq(result.next(), Some([Value::Varchar("Bobby"), Value::BigInt(2L)]))
  assert_eq(result.next(), None)
}

///|
test "query executes grouped aggregate over jsonl jsonl join" {
  let conn = Database::new().connect()
  let result = conn
    .query(
      "SELECT profiles.city, COUNT(*) AS total FROM read_jsonl('fixtures/jsonl/join_events.jsonl') AS events JOIN read_jsonl('fixtures/jsonl/join_profiles.jsonl') AS profiles ON events.id = profiles.id GROUP BY profiles.city HAVING COUNT(*) > 1",
    )
    .unwrap()

  assert_eq(result.schema().columns, [
    { name: "city", data_type: LogicalType::Varchar, nullable: false },
    { name: "total", data_type: LogicalType::BigInt, nullable: false },
  ])
  assert_eq(result.next(), Some([Value::Varchar("B"), Value::BigInt(2L)]))
  assert_eq(result.next(), Some([Value::Varchar("C"), Value::BigInt(2L)]))
  assert_eq(result.next(), None)
}

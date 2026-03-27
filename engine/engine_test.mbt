///|
test "value logical types match the shared logical type enum" {
  assert_eq(Value::Null.logical_type(), LogicalType::Null)
  assert_eq(Value::Boolean(true).logical_type(), LogicalType::Boolean)
  assert_eq(Value::BigInt(42L).logical_type(), LogicalType::BigInt)
  assert_eq(Value::Double(3.14).logical_type(), LogicalType::Double)
  assert_eq(Value::Varchar("hello").logical_type(), LogicalType::Varchar)
}

///|
test "schema tracks column positions by name" {
  let schema : Schema = {
    columns: [
      { name: "id", data_type: LogicalType::BigInt, nullable: false },
      { name: "name", data_type: LogicalType::Varchar, nullable: true },
    ],
  }

  assert_eq(schema.column_count(), 2)
  assert_eq(schema.column_index("id"), Some(0))
  assert_eq(schema.column_index("name"), Some(1))
  assert_eq(schema.column_index("missing"), None)
}

///|
test "empty data chunk mirrors schema shape" {
  let schema : Schema = {
    columns: [
      { name: "active", data_type: LogicalType::Boolean, nullable: true },
      { name: "score", data_type: LogicalType::Double, nullable: true },
    ],
  }

  let chunk = DataChunk::empty(schema)
  assert_true(chunk.is_empty())
  assert_eq(chunk.column_count(), 2)
  assert_eq(chunk.columns[0].logical_type, LogicalType::Boolean)
  assert_eq(chunk.columns[1].logical_type, LogicalType::Double)
  assert_true(!chunk.is_full())
}

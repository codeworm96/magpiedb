///|
test "root package re-exports core shared types" {
  let value = Value::BigInt(7L)
  let row : Row = [value, Value::Null]

  let schema : Schema = {
    columns: [{ name: "id", data_type: LogicalType::BigInt, nullable: false }],
  }

  assert_eq(row.length(), 2)
  assert_eq(schema.column_count(), 1)
  assert_eq(schema.columns[0].data_type, LogicalType::BigInt)
}

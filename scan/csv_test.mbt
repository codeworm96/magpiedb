///|
async test "csv infers schema and materializes a columnar chunk" {
  let scan = read_csv("fixtures/csv/people.csv")

  assert_eq(scan.schema().columns, [
    { name: "name", data_type: LogicalType::Varchar, nullable: false },
    { name: "age", data_type: LogicalType::BigInt, nullable: true },
    { name: "active", data_type: LogicalType::Boolean, nullable: false },
  ])

  let chunk = scan.next_chunk().unwrap()
  assert_eq(chunk.len, 3)
  assert_eq(scan.next_chunk(), None)

  assert_eq(
    chunk.columns[0].values,
    VectorBuffer::Varchar(["Ada", "Bob", "Carla"]),
  )
  assert_eq(chunk.columns[0].validity.bits, [true, true, true])
  assert_eq(chunk.columns[1].values, VectorBuffer::Int64([30L, 0L, 41L]))
  assert_eq(chunk.columns[1].validity.bits, [true, false, true])
  assert_eq(chunk.columns[2].values, VectorBuffer::Bool([true, false, true]))
  assert_eq(chunk.columns[2].validity.bits, [true, true, true])
}

///|
async test "csv preserves quoted commas and escaped quotes" {
  let scan = read_csv("fixtures/csv/quoted.csv")
  assert_eq(scan.schema().columns, [
    { name: "id", data_type: LogicalType::BigInt, nullable: false },
    { name: "note", data_type: LogicalType::Varchar, nullable: false },
  ])

  let chunk = scan.next_chunk().unwrap()
  assert_eq(chunk.columns[0].values, VectorBuffer::Int64([1L, 2L]))
  assert_eq(
    chunk.columns[1].values,
    VectorBuffer::Varchar(["hello,world", "say \"hi\""]),
  )
}

///|
async test "csv widens mixed numeric columns to double" {
  let schema = infer_csv_schema("fixtures/csv/mixed_numeric.csv")
  assert_eq(schema.columns, [
    { name: "score", data_type: LogicalType::Double, nullable: false },
  ])

  let scan = scan_csv("fixtures/csv/mixed_numeric.csv")
  let chunk = scan.next_chunk().unwrap()
  assert_eq(chunk.columns[0].values, VectorBuffer::Double([1.0, 2.5, 3.0]))
}

///|
async test "csv normalizes invalid or duplicate headers" {
  let schema = infer_csv_schema("fixtures/csv/bad_headers.csv")
  assert_eq(schema.columns, [
    { name: "column1", data_type: LogicalType::Varchar, nullable: false },
    { name: "name", data_type: LogicalType::Varchar, nullable: false },
    { name: "name_2", data_type: LogicalType::Varchar, nullable: false },
  ])
}

///|
async test "csv rejects malformed row widths" {
  let result = try? read_csv("fixtures/csv/malformed.csv")
  match result {
    Err(CsvMalformed(_)) => ()
    _ => fail("expected CsvMalformed")
  }
}

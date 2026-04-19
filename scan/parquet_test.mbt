///|
fn write_scan_people_parquet(path : String) -> Unit {
  let file = @parquet.new_parquet_file(
    [
      @parquet.new_column("id", @parquet.Int64, @parquet.Required),
      @parquet.new_column("name", @parquet.String, @parquet.Required),
      @parquet.new_column("age", @parquet.Int64, @parquet.Optional),
    ],
    [
      [
        @parquet.Value::Int64(1L),
        @parquet.Value::String("Ada"),
        @parquet.Value::Int64(30L),
      ],
      [
        @parquet.Value::Int64(2L),
        @parquet.Value::String("Bob"),
        @parquet.Value::Null,
      ],
      [
        @parquet.Value::Int64(3L),
        @parquet.Value::String("Carla"),
        @parquet.Value::Int64(41L),
      ],
    ],
    Some("magpiedb-scan-test"),
  )
  try! @parquet.write_file(path, file)
}

///|
async test "parquet infers schema and materializes a columnar chunk" {
  let path = "/tmp/magpiedb-scan-people.parquet"
  write_scan_people_parquet(path)

  let scan = read_parquet(path)
  assert_eq(scan.schema().columns, [
    { name: "id", data_type: @engine.LogicalType::BigInt, nullable: false },
    { name: "name", data_type: @engine.LogicalType::Varchar, nullable: false },
    { name: "age", data_type: @engine.LogicalType::BigInt, nullable: true },
  ])

  let chunk = scan.next_chunk().unwrap()
  assert_eq(chunk.len, 3)
  assert_eq(scan.next_chunk(), None)

  assert_eq(chunk.columns[0].values, @engine.VectorBuffer::Int64([1L, 2L, 3L]))
  assert_eq(chunk.columns[0].validity.bits, [true, true, true])
  assert_eq(
    chunk.columns[1].values,
    @engine.VectorBuffer::Varchar(["Ada", "Bob", "Carla"]),
  )
  assert_eq(chunk.columns[1].validity.bits, [true, true, true])
  assert_eq(
    chunk.columns[2].values,
    @engine.VectorBuffer::Int64([30L, 0L, 41L]),
  )
  assert_eq(chunk.columns[2].validity.bits, [true, false, true])
}

///|
async test "parquet scanner can close early and reset" {
  let path = "/tmp/magpiedb-scan-reset.parquet"
  write_scan_people_parquet(path)

  let scan = read_parquet(path)
  scan.close()
  assert_eq(scan.next_chunk(), None)

  scan.reset()
  let chunk = scan.next_chunk().unwrap()
  assert_eq(chunk.len, 3)
}

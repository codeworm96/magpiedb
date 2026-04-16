///|
using @engine {type LogicalType, type VectorBuffer}

///|
async test "jsonl infers schema and materializes a columnar chunk" {
  let scan = read_jsonl("fixtures/jsonl/events.jsonl")

  assert_eq(scan.schema().columns, [
    { name: "active", data_type: LogicalType::Boolean, nullable: false },
    { name: "id", data_type: LogicalType::BigInt, nullable: false },
    { name: "meta", data_type: LogicalType::Varchar, nullable: true },
    { name: "name", data_type: LogicalType::Varchar, nullable: true },
  ])
  let chunk = scan.next_chunk().unwrap()
  assert_eq(chunk.len, 3)
  assert_eq(scan.next_chunk(), None)

  let active = chunk.columns[0]
  let ids = chunk.columns[1]
  let meta = chunk.columns[2]
  let names = chunk.columns[3]

  assert_eq(active.values, VectorBuffer::Bool([true, false, true]))
  assert_eq(active.validity.bits, [true, true, true])
  assert_eq(ids.values, VectorBuffer::Int64([1L, 2L, 3L]))
  assert_eq(ids.validity.bits, [true, true, true])
  assert_eq(
    meta.values,
    VectorBuffer::Varchar(["{\"city\":\"A\"}", "", "[1,2]"]),
  )
  assert_eq(meta.validity.bits, [true, false, true])
  assert_eq(names.values, VectorBuffer::Varchar(["Ada", "Bob", ""]))
  assert_eq(names.validity.bits, [true, true, false])
}

///|
async test "jsonl widens mixed numeric columns to double" {
  let schema = infer_jsonl_schema("fixtures/jsonl/mixed_numeric.jsonl")
  assert_eq(schema.columns, [
    { name: "score", data_type: LogicalType::Double, nullable: false },
  ])

  let scan = scan_jsonl("fixtures/jsonl/mixed_numeric.jsonl")
  let chunk = scan.next_chunk().unwrap()
  assert_eq(chunk.columns[0].values, VectorBuffer::Double([1.0, 2.5, 3.0]))
  assert_eq(scan.next_chunk(), None)
}

///|
async test "jsonl scanner can reset and re-stream chunks" {
  let scan = read_jsonl("fixtures/jsonl/events.jsonl")
  ignore(scan.next_chunk().unwrap())
  assert_eq(scan.next_chunk(), None)

  scan.reset()
  let chunk = scan.next_chunk().unwrap()
  assert_eq(chunk.len, 3)
}

///|
async test "jsonl reports malformed input with line numbers" {
  let result = try? read_jsonl("fixtures/jsonl/malformed.jsonl")
  match result {
    Err(JsonParse(line_no, _)) => assert_eq(line_no, 2)
    _ => fail("expected a JsonParse error on line 2")
  }
}

///|
async test "jsonl rejects non-object rows" {
  let result = try? read_jsonl("fixtures/jsonl/not_object.jsonl")
  match result {
    Err(JsonRootNotObject(line_no)) => assert_eq(line_no, 1)
    _ => fail("expected JsonRootNotObject on line 1")
  }
}

///|
test "execute plan produces chunked projection and filter output" {
  let query = @sql.parse_sql(
    "SELECT id, name FROM read_jsonl('fixtures/jsonl/events.jsonl') WHERE active = true",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.schema.columns, [
    { name: "id", data_type: @engine.LogicalType::BigInt, nullable: false },
    { name: "name", data_type: @engine.LogicalType::Varchar, nullable: true },
  ])
  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 2)
  assert_eq(chunk.columns[0].values, @engine.VectorBuffer::Int64([1L, 3L]))
  assert_eq(chunk.columns[0].validity, @engine.ValidityMask::all_valid(2))
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Varchar(["Ada", ""]))
  assert_eq(chunk.columns[1].validity, @engine.ValidityMask::new([true, false]))
}

///|
test "execute plan keeps literal projections chunked until materialization boundary" {
  let query = @sql.parse_sql(
    "SELECT id AS event_id, 'ok' AS status FROM read_jsonl('fixtures/jsonl/events.jsonl') WHERE id >= 2",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.schema.columns, [
    {
      name: "event_id",
      data_type: @engine.LogicalType::BigInt,
      nullable: false,
    },
    { name: "status", data_type: @engine.LogicalType::Varchar, nullable: false },
  ])
  assert_eq(chunk.columns[0].values, @engine.VectorBuffer::Int64([2L, 3L]))
  assert_eq(
    chunk.columns[1].values,
    @engine.VectorBuffer::Varchar(["ok", "ok"]),
  )
  assert_eq(chunk.columns[1].validity, @engine.ValidityMask::all_valid(2))
}

///|
test "execute plan supports csv scan through the same chunk pipeline" {
  let query = @sql.parse_sql(
    "SELECT name, age FROM read_csv('fixtures/csv/people.csv') WHERE age > 18",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.schema.columns, [
    { name: "name", data_type: @engine.LogicalType::Varchar, nullable: false },
    { name: "age", data_type: @engine.LogicalType::BigInt, nullable: true },
  ])
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar(["Ada", "Carla"]),
  )
  assert_eq(chunk.columns[0].validity, @engine.ValidityMask::all_valid(2))
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Int64([30L, 41L]))
}

///|
test "execute plan computes global aggregates" {
  let query = @sql.parse_sql(
    "SELECT COUNT(*) AS total, AVG(age) AS avg_age FROM read_csv('fixtures/csv/people.csv')",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.schema.columns, [
    { name: "total", data_type: @engine.LogicalType::BigInt, nullable: false },
    { name: "avg_age", data_type: @engine.LogicalType::Double, nullable: true },
  ])
  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 1)
  assert_eq(chunk.columns[0].values, @engine.VectorBuffer::Int64([3L]))
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Double([35.5]))
  assert_eq(chunk.columns[1].validity, @engine.ValidityMask::all_valid(1))
}

///|
test "execute plan computes grouped aggregates with having" {
  let query = @sql.parse_sql(
    "SELECT active, COUNT(*) AS total FROM read_jsonl('fixtures/jsonl/events.jsonl') GROUP BY active HAVING COUNT(*) > 1",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 1)
  assert_eq(chunk.columns[0].values, @engine.VectorBuffer::Bool([true]))
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Int64([2L]))
}

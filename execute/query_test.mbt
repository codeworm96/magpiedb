///|
async test "execute plan produces chunked projection and filter output" {
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
async test "execute plan keeps literal projections chunked until materialization boundary" {
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
async test "execute plan supports csv scan through the same chunk pipeline" {
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
async test "execute plan computes global aggregates" {
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
async test "execute plan computes grouped aggregates with having" {
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

///|
async test "execute plan treats division as double in aggregate inputs" {
  let query = @sql.parse_sql(
    "SELECT SUM(age / 2) AS half_total FROM read_csv('fixtures/csv/people.csv')",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.schema.columns, [
    {
      name: "half_total",
      data_type: @engine.LogicalType::Double,
      nullable: true,
    },
  ])
  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 1)
  assert_eq(chunk.columns[0].values, @engine.VectorBuffer::Double([35.5]))
  assert_eq(chunk.columns[0].validity, @engine.ValidityMask::all_valid(1))
}

///|
async test "execute plan applies SQL three-valued logic for boolean operators" {
  let query = @sql.parse_sql(
    "SELECT false AND NULL AS and_result, true OR NULL AS or_result, true AND NULL AS and_unknown, false OR NULL AS or_unknown FROM read_csv('fixtures/csv/people.csv')",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 3)
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Bool([false, false, false]),
  )
  assert_eq(chunk.columns[0].validity, @engine.ValidityMask::all_valid(3))
  assert_eq(
    chunk.columns[1].values,
    @engine.VectorBuffer::Bool([true, true, true]),
  )
  assert_eq(chunk.columns[1].validity, @engine.ValidityMask::all_valid(3))
  assert_eq(
    chunk.columns[2].values,
    @engine.VectorBuffer::Bool([false, false, false]),
  )
  assert_eq(chunk.columns[2].validity, @engine.ValidityMask::all_null(3))
  assert_eq(
    chunk.columns[3].values,
    @engine.VectorBuffer::Bool([false, false, false]),
  )
  assert_eq(chunk.columns[3].validity, @engine.ValidityMask::all_null(3))
}

///|
async test "execute plan performs csv jsonl inner join with deterministic output order" {
  let query = @sql.parse_sql(
    "SELECT people.name, events.name, events.active FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 5)
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar(["Ada", "Bob", "Bob", "Bobby", "Bobby"]),
  )
  assert_eq(
    chunk.columns[1].values,
    @engine.VectorBuffer::Varchar([
      "Launch", "Review", "Retry", "Review", "Retry",
    ]),
  )
  assert_eq(
    chunk.columns[2].values,
    @engine.VectorBuffer::Bool([true, false, true, false, true]),
  )
}

///|
async test "execute plan performs csv csv inner join" {
  let query = @sql.parse_sql(
    "SELECT people.name, flags.team, flags.enabled FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_csv('fixtures/csv/join_flags.csv') AS flags ON people.id = flags.id",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 5)
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar(["Ada", "Bob", "Bob", "Bobby", "Bobby"]),
  )
  assert_eq(
    chunk.columns[1].values,
    @engine.VectorBuffer::Varchar(["alpha", "beta", "gamma", "beta", "gamma"]),
  )
  assert_eq(
    chunk.columns[2].values,
    @engine.VectorBuffer::Bool([true, false, true, false, true]),
  )
}

///|
async test "execute plan performs jsonl jsonl inner join" {
  let query = @sql.parse_sql(
    "SELECT events.name, profiles.city, profiles.score FROM read_jsonl('fixtures/jsonl/join_events.jsonl') AS events JOIN read_jsonl('fixtures/jsonl/join_profiles.jsonl') AS profiles ON events.id = profiles.id",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 5)
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar([
      "Launch", "Review", "Review", "Retry", "Retry",
    ]),
  )
  assert_eq(
    chunk.columns[1].values,
    @engine.VectorBuffer::Varchar(["A", "B", "C", "B", "C"]),
  )
  assert_eq(
    chunk.columns[2].values,
    @engine.VectorBuffer::Int64([10L, 20L, 30L, 20L, 30L]),
  )
}

///|
async test "execute plan does not match null join keys" {
  let query = @sql.parse_sql(
    "SELECT people.name FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id WHERE people.name = 'NoId'",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 0)
}

///|
async test "execute plan computes global aggregate over csv jsonl join" {
  let query = @sql.parse_sql(
    "SELECT COUNT(*) AS total, SUM(events.id) AS total_id FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.schema.columns, [
    { name: "total", data_type: @engine.LogicalType::BigInt, nullable: false },
    { name: "total_id", data_type: @engine.LogicalType::BigInt, nullable: true },
  ])
  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 1)
  assert_eq(chunk.columns[0].values, @engine.VectorBuffer::Int64([5L]))
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Int64([9L]))
}

///|
async test "execute plan computes grouped aggregate over csv csv join with having" {
  let query = @sql.parse_sql(
    "SELECT people.name, COUNT(*) AS total FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_csv('fixtures/csv/join_flags.csv') AS flags ON people.id = flags.id GROUP BY people.name HAVING COUNT(*) > 1",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 2)
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar(["Bob", "Bobby"]),
  )
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Int64([2L, 2L]))
}

///|
async test "execute plan computes grouped aggregate over jsonl jsonl join on right key" {
  let query = @sql.parse_sql(
    "SELECT profiles.city, COUNT(*) AS total FROM read_jsonl('fixtures/jsonl/join_events.jsonl') AS events JOIN read_jsonl('fixtures/jsonl/join_profiles.jsonl') AS profiles ON events.id = profiles.id GROUP BY profiles.city HAVING COUNT(*) > 1",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 2)
  assert_eq(chunk.columns[0].values, @engine.VectorBuffer::Varchar(["B", "C"]))
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Int64([2L, 2L]))
}

///|
async test "execute plan sorts with nulls last and limit" {
  let query = @sql.parse_sql(
    "SELECT name, age FROM read_csv('fixtures/csv/people.csv') ORDER BY age DESC LIMIT 2",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.chunks.length(), 1)
  let chunk = output.chunks[0]
  assert_eq(chunk.len, 2)
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar(["Carla", "Ada"]),
  )
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Int64([41L, 30L]))
}

///|
async test "execute plan sorts stable on duplicate keys" {
  let query = @sql.parse_sql(
    "SELECT name, id FROM read_csv('fixtures/csv/join_people.csv') ORDER BY id ASC",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  let chunk = output.chunks[0]
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar(["Ada", "Bob", "Bobby", "Carla", "NoId"]),
  )
  assert_eq(chunk.columns[0].validity, @engine.ValidityMask::all_valid(5))
  assert_eq(
    chunk.columns[1].validity,
    @engine.ValidityMask::new([true, true, true, true, false]),
  )
}

///|
async test "execute plan sorts join results and limits them" {
  let query = @sql.parse_sql(
    "SELECT people.name, events.name AS event_name FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id ORDER BY event_name DESC, people.name LIMIT 3",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  let chunk = output.chunks[0]
  assert_eq(chunk.len, 3)
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar(["Bob", "Bobby", "Bob"]),
  )
  assert_eq(
    chunk.columns[1].values,
    @engine.VectorBuffer::Varchar(["Review", "Review", "Retry"]),
  )
}

///|
async test "execute plan sorts aggregate over join results" {
  let query = @sql.parse_sql(
    "SELECT people.name, COUNT(*) AS total FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_csv('fixtures/csv/join_flags.csv') AS flags ON people.id = flags.id GROUP BY people.name ORDER BY total DESC, people.name LIMIT 2",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  let chunk = output.chunks[0]
  assert_eq(chunk.len, 2)
  assert_eq(
    chunk.columns[0].values,
    @engine.VectorBuffer::Varchar(["Bob", "Bobby"]),
  )
  assert_eq(chunk.columns[1].values, @engine.VectorBuffer::Int64([2L, 2L]))
}

///|
async test "execute plan limit zero returns empty result with schema" {
  let query = @sql.parse_sql(
    "SELECT name, age FROM read_csv('fixtures/csv/people.csv') LIMIT 0",
  ).unwrap()
  let plan = try! @plan.plan_query(query)
  let output = try! execute_plan(plan)

  assert_eq(output.schema.columns, [
    { name: "name", data_type: @engine.LogicalType::Varchar, nullable: false },
    { name: "age", data_type: @engine.LogicalType::BigInt, nullable: true },
  ])
  assert_eq(output.chunks.length(), 0)
}

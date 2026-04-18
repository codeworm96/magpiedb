///|
async test "optimizer framework preserves scalar plan without rewrites" {
  let query = @sql.parse_sql(
    "SELECT name, age FROM read_csv('fixtures/csv/people.csv') WHERE age > 18 ORDER BY age LIMIT 2",
  ).unwrap()
  let raw = try! bind_query_plan(query, new_schema_catalog())
  let optimized = optimize_query_plan(raw)

  assert_true(optimized == raw)
}

///|
async test "optimizer framework preserves aggregate join plan without rewrites" {
  let query = @sql.parse_sql(
    "SELECT people.name, COUNT(*) AS total FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_csv('fixtures/csv/join_flags.csv') AS flags ON people.id = flags.id GROUP BY people.name HAVING COUNT(*) > 1 ORDER BY total DESC LIMIT 2",
  ).unwrap()
  let raw = try! bind_query_plan(query, new_schema_catalog())
  let optimized = optimize_query_plan(raw)
  let planned = try! plan_query(query)

  assert_true(optimized == raw)
  assert_true(planned == optimized)
}

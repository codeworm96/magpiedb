///|
test "planner binds jsonl scan, filter, and projections" {
  let query = @sql.parse_sql(
    "SELECT id, name AS person_name FROM read_jsonl('fixtures/jsonl/events.jsonl') WHERE active = true",
  ).unwrap()
  let plan = try! plan_query(query)

  match plan {
    Projection(projection_plan) => {
      assert_eq(projection_plan.output_schema.columns, [
        { name: "id", data_type: @engine.LogicalType::BigInt, nullable: false },
        {
          name: "person_name",
          data_type: @engine.LogicalType::Varchar,
          nullable: true,
        },
      ])

      match projection_plan.projections[0].expr {
        ColumnRef(column_ref) => {
          assert_eq(column_ref.index, 1)
          assert_eq(column_ref.column.name, "id")
        }
        _ => fail("expected first projection to be a bound column reference")
      }

      match projection_plan.input {
        Filter(filter_plan) => {
          match filter_plan.predicate {
            Binary(
              @sql.BinaryOp::Equal,
              ColumnRef(column_ref),
              BooleanLiteral(true)
            ) => assert_eq(column_ref.column.name, "active")
            _ => fail("expected bound equality filter")
          }
          match filter_plan.input {
            Scan(scan_plan) =>
              match scan_plan.source {
                Jsonl(scan) => {
                  assert_eq(scan.path, "fixtures/jsonl/events.jsonl")
                  assert_eq(scan.schema.column_index("id"), Some(1))
                  assert_eq(scan.schema.column_index("active"), Some(0))
                }
                _ => fail("expected jsonl scan source")
              }
            _ => fail("expected scan input under filter")
          }
        }
        _ => fail("expected filter input under projection")
      }
    }
    _ => fail("expected projection root")
  }
}

///|
test "planner binds csv scan, filter, and projections" {
  let query = @sql.parse_sql(
    "SELECT name, age FROM read_csv('fixtures/csv/people.csv') WHERE age > 18",
  ).unwrap()
  let plan = try! plan_query(query)

  match plan {
    Projection(projection_plan) => {
      assert_eq(projection_plan.output_schema.columns, [
        {
          name: "name",
          data_type: @engine.LogicalType::Varchar,
          nullable: false,
        },
        { name: "age", data_type: @engine.LogicalType::BigInt, nullable: true },
      ])
      match projection_plan.input {
        Filter(filter_plan) =>
          match filter_plan.input {
            Scan(scan_plan) =>
              match scan_plan.source {
                Csv(scan) => {
                  assert_eq(scan.path, "fixtures/csv/people.csv")
                  assert_eq(scan.schema.column_index("name"), Some(0))
                  assert_eq(scan.schema.column_index("age"), Some(1))
                }
                _ => fail("expected csv scan source")
              }
            _ => fail("expected scan input under filter")
          }
        _ => fail("expected filter input under projection")
      }
    }
    _ => fail("expected projection root")
  }
}

///|
test "planner rejects non boolean where clause" {
  let query = @sql.parse_sql(
    "SELECT id FROM read_jsonl('fixtures/jsonl/events.jsonl') WHERE id",
  ).unwrap()
  let err = (try? plan_query(query)).unwrap_err()

  match err {
    PlanError::Bind(message) =>
      assert_true(message.contains("WHERE clause must evaluate to BOOLEAN"))
    _ => fail("expected bind error")
  }
}

///|
test "planner lowers grouped aggregate with having" {
  let query = @sql.parse_sql(
    "SELECT active, COUNT(*) AS total FROM read_jsonl('fixtures/jsonl/events.jsonl') GROUP BY active HAVING COUNT(*) > 1",
  ).unwrap()
  let plan = try! plan_query(query)

  match plan {
    Projection(projection_plan) => {
      assert_eq(projection_plan.output_schema.columns, [
        {
          name: "active",
          data_type: @engine.LogicalType::Boolean,
          nullable: false,
        },
        {
          name: "total",
          data_type: @engine.LogicalType::BigInt,
          nullable: false,
        },
      ])
      match projection_plan.input {
        Filter(filter_plan) =>
          match filter_plan.input {
            Aggregate(aggregate_plan) => {
              assert_eq(aggregate_plan.group_keys.length(), 1)
              assert_eq(aggregate_plan.aggregates.length(), 1)
              assert_true(aggregate_plan.aggregates[0].kind == CountStar)
            }
            _ => fail("expected aggregate below having filter")
          }
        _ => fail("expected having filter under projection")
      }
    }
    _ => fail("expected projection root")
  }
}

///|
test "planner rejects non grouped column in aggregate query" {
  let query = @sql.parse_sql(
    "SELECT name, COUNT(*) FROM read_csv('fixtures/csv/people.csv') GROUP BY active",
  ).unwrap()
  let err = (try? plan_query(query)).unwrap_err()

  match err {
    PlanError::Bind(message) =>
      assert_true(message.contains("GROUP BY") || message.contains("aggregate"))
    _ => fail("expected bind error")
  }
}

///|
test "planner lowers inner join with qualified columns" {
  let query = @sql.parse_sql(
    "SELECT people.name, events.active FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id WHERE events.active = true",
  ).unwrap()
  let plan = try! plan_query(query)

  match plan {
    Projection(projection_plan) => {
      assert_eq(projection_plan.output_schema.columns, [
        {
          name: "name",
          data_type: @engine.LogicalType::Varchar,
          nullable: false,
        },
        {
          name: "active",
          data_type: @engine.LogicalType::Boolean,
          nullable: false,
        },
      ])
      match projection_plan.input {
        Filter(filter_plan) =>
          match filter_plan.input {
            Join(join_plan) => {
              assert_eq(join_plan.left_key.index, 0)
              assert_eq(join_plan.right_key.index, 1)
              assert_eq(join_plan.output_schema.columns[0].name, "id")
              assert_eq(join_plan.output_schema.columns[4].name, "id")
            }
            _ => fail("expected join under filter")
          }
        _ => fail("expected filter under projection")
      }
    }
    _ => fail("expected projection root")
  }
}

///|
test "planner rejects ambiguous unqualified join columns" {
  let query = @sql.parse_sql(
    "SELECT name FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id",
  ).unwrap()
  let err = (try? plan_query(query)).unwrap_err()

  match err {
    PlanError::Bind(message) => assert_true(message.contains("ambiguous"))
    _ => fail("expected bind error")
  }
}

///|
test "planner rejects invalid join predicate shape" {
  let query = @sql.parse_sql(
    "SELECT people.name FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = 1",
  ).unwrap()
  let err = (try? plan_query(query)).unwrap_err()

  match err {
    PlanError::Bind(message) =>
      assert_true(
        message.contains("column references") || message.contains("JOIN ON"),
      )
    _ => fail("expected bind error")
  }
}

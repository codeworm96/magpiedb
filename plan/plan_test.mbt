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

///|
fn unwrap_source(from : FromItem) -> SourceRef {
  match from {
    Source(source) => source
    Join(_) => panic()
  }
}

///|
fn unwrap_table_function(source_ref : SourceRef) -> TableFunction {
  match source_ref.source {
    RelationSource::TableFunction(source) => source
    RelationSource::PathLiteral(_) => panic()
  }
}

///|
fn unwrap_path_literal(source_ref : SourceRef) -> String {
  match source_ref.source {
    RelationSource::TableFunction(_) => panic()
    RelationSource::PathLiteral(path) => path
  }
}

///|
fn order_by_matches(
  item : OrderByItem,
  expr : Expr,
  direction : SortDirection,
) -> Bool {
  item.expr == expr && item.direction == direction
}

///|
test "parse basic query with where" {
  let query = parse_sql(
    "SELECT name, age AS years FROM read_csv('fixtures/people.csv') WHERE age > 18",
  ).unwrap()
  let source = unwrap_source(query.from)
  let table_function = unwrap_table_function(source)

  assert_eq(query.select_items.length(), 2)
  assert_eq(table_function.name, "read_csv")
  assert_eq(query.select_items[1].output_name, Some("years"))
  assert_eq(table_function.arguments, [
    Expr::StringLiteral("fixtures/people.csv"),
  ])
  assert_eq(query.group_by, [])
  assert_eq(query.having_clause, None)
  assert_eq(query.order_by.length(), 0)
  assert_eq(query.limit, None)
  assert_eq(
    query.where_clause,
    Some(
      Expr::Binary(
        BinaryOp::GreaterThan,
        Expr::ColumnRef(["age"]),
        Expr::IntegerLiteral("18"),
      ),
    ),
  )
}

///|
test "parse precedence and unary expressions" {
  let query = parse_sql(
    "SELECT 1 + 2 * 3, NOT active OR score >= 10 FROM read_jsonl('events.jsonl')",
  ).unwrap()

  assert_eq(
    query.select_items[0].expr,
    Expr::Binary(
      BinaryOp::Add,
      Expr::IntegerLiteral("1"),
      Expr::Binary(
        BinaryOp::Multiply,
        Expr::IntegerLiteral("2"),
        Expr::IntegerLiteral("3"),
      ),
    ),
  )
  assert_eq(
    query.select_items[1].expr,
    Expr::Binary(
      BinaryOp::Or,
      Expr::Unary(UnaryOp::Not, Expr::ColumnRef(["active"])),
      Expr::Binary(
        BinaryOp::GreaterThanOrEqual,
        Expr::ColumnRef(["score"]),
        Expr::IntegerLiteral("10"),
      ),
    ),
  )
}

///|
test "parse cast and is null" {
  let query = parse_sql(
    "SELECT CAST(age AS DOUBLE) value FROM read_csv('people.csv') WHERE nickname IS NOT NULL",
  ).unwrap()

  assert_eq(query.select_items[0].output_name, Some("value"))
  assert_eq(
    query.select_items[0].expr,
    Expr::Cast(Expr::ColumnRef(["age"]), TypeName::Double),
  )
  assert_eq(
    query.where_clause,
    Some(Expr::IsNotNull(Expr::ColumnRef(["nickname"]))),
  )
}

///|
test "parse qualified column names" {
  let query = parse_sql("SELECT people.name FROM read_csv('people.csv')").unwrap()

  assert_eq(query.select_items[0].expr, Expr::ColumnRef(["people", "name"]))
}

///|
test "parse quoted path source" {
  let query = parse_sql(
    "SELECT flight_no FROM 'flights.csv' AS flights",
  ).unwrap()
  let source = unwrap_source(query.from)

  assert_eq(source.alias_name, Some("flights"))
  assert_eq(unwrap_path_literal(source), "flights.csv")
  assert_eq(query.select_items[0].expr, Expr::ColumnRef(["flight_no"]))
}

///|
test "parse aggregate functions and count star" {
  let query = parse_sql(
    "SELECT COUNT(*) AS total, SUM(amount), AVG(score) FROM read_csv('metrics.csv')",
  ).unwrap()

  assert_eq(query.select_items[0].expr, Expr::FunctionCallStar("COUNT"))
  assert_eq(query.select_items[0].output_name, Some("total"))
  assert_eq(
    query.select_items[1].expr,
    Expr::FunctionCall("SUM", [Expr::ColumnRef(["amount"])]),
  )
  assert_eq(
    query.select_items[2].expr,
    Expr::FunctionCall("AVG", [Expr::ColumnRef(["score"])]),
  )
}

///|
test "parse group by and having" {
  let query = parse_sql(
    "SELECT active, COUNT(*) total FROM read_jsonl('events.jsonl') GROUP BY active HAVING COUNT(*) > 1",
  ).unwrap()

  assert_eq(query.group_by, [["active"]])
  assert_eq(
    query.having_clause,
    Some(
      Expr::Binary(
        BinaryOp::GreaterThan,
        Expr::FunctionCallStar("COUNT"),
        Expr::IntegerLiteral("1"),
      ),
    ),
  )
}

///|
test "parse join shorthand with aliases" {
  let query = parse_sql(
    "SELECT l.id, r.name FROM read_csv('a.csv') AS l JOIN read_jsonl('b.jsonl') AS r ON l.id = r.id",
  ).unwrap()

  match query.from {
    Source(_) => fail("expected join")
    Join(join) => {
      assert_true(join.join_kind is JoinKind::Inner)
      assert_eq(join.left.alias_name, Some("l"))
      assert_eq(join.right.alias_name, Some("r"))
      assert_eq(unwrap_table_function(join.left).name, "read_csv")
      assert_eq(unwrap_table_function(join.right).name, "read_jsonl")
      assert_eq(
        join.on,
        Expr::Binary(
          BinaryOp::Equal,
          Expr::ColumnRef(["l", "id"]),
          Expr::ColumnRef(["r", "id"]),
        ),
      )
    }
  }
}

///|
test "parse explicit inner join with where" {
  let query = parse_sql(
    "SELECT left.id FROM read_csv('a.csv') left INNER JOIN read_csv('b.csv') right ON left.id = right.id WHERE right.active = TRUE",
  ).unwrap()

  match query.from {
    Source(_) => fail("expected join")
    Join(join) => {
      assert_eq(join.left.alias_name, Some("left"))
      assert_eq(join.right.alias_name, Some("right"))
    }
  }
  assert_eq(
    query.where_clause,
    Some(
      Expr::Binary(
        BinaryOp::Equal,
        Expr::ColumnRef(["right", "active"]),
        Expr::BooleanLiteral(true),
      ),
    ),
  )
}

///|
test "parse join with quoted path sources" {
  let query = parse_sql(
    "SELECT l.id, r.name FROM 'a.csv' l JOIN 'b.jsonl' r ON l.id = r.id",
  ).unwrap()

  match query.from {
    Source(_) => fail("expected join")
    Join(join) => {
      assert_eq(join.left.alias_name, Some("l"))
      assert_eq(join.right.alias_name, Some("r"))
      assert_eq(unwrap_path_literal(join.left), "a.csv")
      assert_eq(unwrap_path_literal(join.right), "b.jsonl")
      assert_eq(
        join.on,
        Expr::Binary(
          BinaryOp::Equal,
          Expr::ColumnRef(["l", "id"]),
          Expr::ColumnRef(["r", "id"]),
        ),
      )
    }
  }
}

///|
test "parse global aggregate over join" {
  let query = parse_sql(
    "SELECT COUNT(*) AS total, SUM(r.amount) FROM read_csv('orders.csv') o JOIN read_jsonl('payments.jsonl') r ON o.id = r.order_id",
  ).unwrap()

  match query.from {
    Source(_) => fail("expected join")
    Join(join) => {
      assert_eq(join.left.alias_name, Some("o"))
      assert_eq(join.right.alias_name, Some("r"))
      assert_eq(
        join.on,
        Expr::Binary(
          BinaryOp::Equal,
          Expr::ColumnRef(["o", "id"]),
          Expr::ColumnRef(["r", "order_id"]),
        ),
      )
    }
  }
  assert_eq(query.group_by, [])
  assert_eq(query.having_clause, None)
  assert_eq(query.select_items[0].expr, Expr::FunctionCallStar("COUNT"))
  assert_eq(query.select_items[0].output_name, Some("total"))
  assert_eq(
    query.select_items[1].expr,
    Expr::FunctionCall("SUM", [Expr::ColumnRef(["r", "amount"])]),
  )
}

///|
test "parse grouped aggregate over join with where and having" {
  let query = parse_sql(
    "SELECT l.city, COUNT(*) total, MAX(r.score) FROM read_csv('left.csv') AS l JOIN read_jsonl('right.jsonl') AS r ON l.id = r.id WHERE r.active = TRUE GROUP BY l.city HAVING COUNT(*) > 1",
  ).unwrap()

  match query.from {
    Source(_) => fail("expected join")
    Join(join) => {
      assert_eq(join.left.alias_name, Some("l"))
      assert_eq(join.right.alias_name, Some("r"))
    }
  }
  assert_eq(query.group_by, [["l", "city"]])
  assert_eq(
    query.where_clause,
    Some(
      Expr::Binary(
        BinaryOp::Equal,
        Expr::ColumnRef(["r", "active"]),
        Expr::BooleanLiteral(true),
      ),
    ),
  )
  assert_eq(
    query.having_clause,
    Some(
      Expr::Binary(
        BinaryOp::GreaterThan,
        Expr::FunctionCallStar("COUNT"),
        Expr::IntegerLiteral("1"),
      ),
    ),
  )
  assert_eq(query.select_items[1].output_name, Some("total"))
  assert_eq(
    query.select_items[2].expr,
    Expr::FunctionCall("MAX", [Expr::ColumnRef(["r", "score"])]),
  )
}

///|
test "parse order by and limit on scan query" {
  let query = parse_sql(
    "SELECT name, age FROM read_csv('people.csv') ORDER BY age DESC LIMIT 2",
  ).unwrap()

  assert_eq(query.order_by.length(), 1)
  assert_true(
    order_by_matches(
      query.order_by[0],
      Expr::ColumnRef(["age"]),
      SortDirection::Desc,
    ),
  )
  assert_eq(query.limit, Some("2"))
}

///|
test "parse multiple order by items with default asc" {
  let query = parse_sql(
    "SELECT city, score FROM read_csv('scores.csv') ORDER BY city, score DESC",
  ).unwrap()

  assert_eq(query.order_by.length(), 2)
  assert_true(
    order_by_matches(
      query.order_by[0],
      Expr::ColumnRef(["city"]),
      SortDirection::Asc,
    ),
  )
  assert_true(
    order_by_matches(
      query.order_by[1],
      Expr::ColumnRef(["score"]),
      SortDirection::Desc,
    ),
  )
  assert_eq(query.limit, None)
}

///|
test "parse order by projection alias" {
  let query = parse_sql(
    "SELECT age AS years FROM read_csv('people.csv') ORDER BY years",
  ).unwrap()

  assert_eq(query.order_by.length(), 1)
  assert_true(
    order_by_matches(
      query.order_by[0],
      Expr::ColumnRef(["years"]),
      SortDirection::Asc,
    ),
  )
}

///|
test "parse aggregate over join with order by and limit" {
  let query = parse_sql(
    "SELECT l.city, COUNT(*) total FROM read_csv('left.csv') AS l JOIN read_jsonl('right.jsonl') AS r ON l.id = r.id GROUP BY l.city HAVING COUNT(*) > 1 ORDER BY total DESC, l.city LIMIT 5",
  ).unwrap()

  assert_eq(query.order_by.length(), 2)
  assert_true(
    order_by_matches(
      query.order_by[0],
      Expr::ColumnRef(["total"]),
      SortDirection::Desc,
    ),
  )
  assert_true(
    order_by_matches(
      query.order_by[1],
      Expr::ColumnRef(["l", "city"]),
      SortDirection::Asc,
    ),
  )
  assert_eq(query.limit, Some("5"))
}

///|
test "parse multiple group keys" {
  let query = parse_sql(
    "SELECT country, city, MAX(score) FROM read_csv('scores.csv') GROUP BY country, city",
  ).unwrap()

  assert_eq(query.group_by, [["country"], ["city"]])
  assert_eq(
    query.select_items[2].expr,
    Expr::FunctionCall("MAX", [Expr::ColumnRef(["score"])]),
  )
}

///|
test "count star stays distinct from wildcard projection" {
  let query = parse_sql(
    "SELECT COUNT(*) FROM read_csv('people.csv') HAVING COUNT(*) > 0",
  ).unwrap()

  assert_eq(query.select_items[0].expr, Expr::FunctionCallStar("COUNT"))
  assert_true(query.having_clause is Some(_))
}

///|
test "invalid syntax reports location" {
  let sql = "SELECT FROM read_csv('people.csv')"
  let error = parse_sql(sql).unwrap_err()

  let span = error.span(sql)
  assert_eq(span.start.line, 1)
  assert_eq(span.start.column, 8)
}

///|
test "unterminated string literal reports lexer error" {
  let sql = "SELECT name FROM read_csv('oops)"
  let error = parse_sql(sql).unwrap_err()

  assert_true(error is Lex(_))
  let span = error.span(sql)
  assert_eq(span.start.column, 27)
}

///|
test "group by requires column list" {
  let sql = "SELECT COUNT(*) FROM read_csv('people.csv') GROUP BY"
  let error = parse_sql(sql).unwrap_err()

  let span = error.span(sql)
  assert_eq(span.start.line, 1)
}

///|
test "left join is rejected by current grammar" {
  let sql = "SELECT l.id FROM read_csv('a.csv') l LEFT JOIN read_csv('b.csv') r ON l.id = r.id"
  let error = parse_sql(sql).unwrap_err()

  let span = error.span(sql)
  assert_eq(span.start.line, 1)
}

///|
test "negative limit is rejected by grammar" {
  let sql = "SELECT name FROM read_csv('people.csv') LIMIT -1"
  let error = parse_sql(sql).unwrap_err()

  let span = error.span(sql)
  assert_eq(span.start.line, 1)
}

///|
test "offset is rejected by grammar" {
  let sql = "SELECT name FROM read_csv('people.csv') ORDER BY name LIMIT 2 OFFSET 1"
  let error = parse_sql(sql).unwrap_err()

  let span = error.span(sql)
  assert_eq(span.start.line, 1)
}

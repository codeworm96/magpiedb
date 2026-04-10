///|
test "parse basic query with where" {
  let query = parse_sql(
    "SELECT name, age AS years FROM read_csv('fixtures/people.csv') WHERE age > 18",
  ).unwrap()

  assert_eq(query.select_items.length(), 2)
  assert_eq(query.from.name, "read_csv")
  assert_eq(query.select_items[1].output_name, Some("years"))
  assert_eq(query.from.arguments, [Expr::StringLiteral("fixtures/people.csv")])
  assert_eq(query.group_by, [])
  assert_eq(query.having_clause, None)
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

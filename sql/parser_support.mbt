///|
fn push_select_item(
  items : Array[SelectItem],
  item : SelectItem,
) -> Array[SelectItem] {
  let next = items.copy()
  next.push(item)
  next
}

///|
fn push_expr(items : Array[Expr], item : Expr) -> Array[Expr] {
  let next = items.copy()
  next.push(item)
  next
}

///|
fn push_string(items : Array[String], item : String) -> Array[String] {
  let next = items.copy()
  next.push(item)
  next
}

///|
fn make_select_item(expr : Expr, output_name : String?) -> SelectItem {
  { expr, output_name }
}

///|
fn make_query(
  select_items : Array[SelectItem],
  from : TableFunction,
  where_clause : Expr?,
  group_by : Array[Array[String]],
  having_clause : Expr?,
) -> Query {
  { select_items, from, where_clause, group_by, having_clause }
}

///|
fn make_table_function(name : String, arguments : Array[Expr]) -> TableFunction {
  { name, arguments }
}

///|
pub fn parse_sql(sql : String) -> Result[Query, SqlSyntaxError] {
  let tokens = tokenize(sql) catch { err => return Err(Lex(err)) }
  let parsed = query(tokens, initial_pos=0) catch {
    err => return Err(Parse(err))
  }
  Ok(parsed)
}

///|
fn push_group_key(
  items : Array[Array[String]],
  item : Array[String],
) -> Array[Array[String]] {
  let next = items.copy()
  next.push(item)
  next
}

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
) -> Query {
  { select_items, from, where_clause }
}

///|
fn make_table_function(name : String, arguments : Array[Expr]) -> TableFunction {
  { name, arguments }
}

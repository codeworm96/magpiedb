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
  from : FromItem,
  where_clause : Expr?,
  group_by : Array[Array[String]],
  having_clause : Expr?,
  order_by : Array[OrderByItem],
  limit : String?,
) -> Query {
  { select_items, from, where_clause, group_by, having_clause, order_by, limit }
}

///|
fn make_table_function(name : String, arguments : Array[Expr]) -> TableFunction {
  { name, arguments }
}

///|
fn make_source_ref(source : TableFunction, alias_name : String?) -> SourceRef {
  { source: RelationSource::TableFunction(source), alias_name }
}

///|
fn make_path_source_ref(path : String, alias_name : String?) -> SourceRef {
  { source: RelationSource::PathLiteral(path), alias_name }
}

///|
fn make_source_from_item(source : SourceRef) -> FromItem {
  FromItem::Source(source)
}

///|
fn make_join_from_item(
  left : SourceRef,
  right : SourceRef,
  on : Expr,
) -> FromItem {
  FromItem::Join(JoinRelation::{ left, right, join_kind: JoinKind::Inner, on })
}

///|
fn make_order_by_item(expr : Expr, direction : SortDirection) -> OrderByItem {
  { expr, direction }
}

///|
fn push_order_by_item(
  items : Array[OrderByItem],
  item : OrderByItem,
) -> Array[OrderByItem] {
  let next = items.copy()
  next.push(item)
  next
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

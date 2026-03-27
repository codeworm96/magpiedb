///|
pub using @engine {
  type ColumnDef,
  type LogicalType,
  type Row,
  type Schema,
  type Value,
}

///|
pub suberror DbError {
  InvalidArgument(String)
  SqlSyntax(String)
  Bind(String)
  Scan(String)
  Io(String)
  Execute(String)
  Unsupported(String)
  Internal(String)
} derive(Show)

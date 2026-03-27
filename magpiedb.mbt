///|
/// Root re-exports keep the public API small while execution types live in `engine`.
pub using @engine {
  type ColumnDef,
  type LogicalType,
  type Row,
  type Schema,
  type Value,
}

///|
/// Public error surface shared by parsing, binding, scanning, and execution.
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

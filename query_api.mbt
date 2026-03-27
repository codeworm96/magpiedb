///|
pub struct Database {} derive(Eq, Show)

///|
pub struct Connection {} derive(Eq, Show)

///|
pub struct ResultSet {
  schema : Schema
  priv rows : Array[Row]
  priv mut next_row : Int
} derive(Eq, Show)

///|
priv struct JsonlSource {
  path : String
}

///|
pub fn Database::new() -> Database {
  Database::{  }
}

///|
pub fn Database::connect(self : Database) -> Connection {
  ignore(self)
  Connection::{  }
}

///|
pub fn Connection::query(
  self : Connection,
  sql : String,
) -> Result[ResultSet, DbError] {
  ignore(self)
  let parsed = @sql.parse_sql(sql)
  match parsed {
    Ok(query) => Ok(execute_query(query)) catch { err => Err(err) }
    Err(err) => Err(DbError::SqlSyntax(err.to_string()))
  }
}

///|
pub fn ResultSet::schema(self : ResultSet) -> Schema {
  self.schema
}

///|
pub fn ResultSet::next(self : ResultSet) -> Row? {
  guard self.next_row < self.rows.length() else { return None }
  let row = self.rows[self.next_row]
  self.next_row += 1
  Some(row)
}

///|
fn execute_query(query : @sql.Query) -> ResultSet raise DbError {
  let source = bind_jsonl_source(query.from)
  let scanner = @scan.read_jsonl(source.path) catch {
    err => raise map_scan_error(err)
  }
  validate_query(query, scanner.schema())
  let output_schema = project_schema(query, scanner.schema())
  let rows = []
  while true {
    let next_chunk = scanner.next_chunk() catch {
      err => raise map_scan_error(err)
    }
    match next_chunk {
      Some(chunk) => append_projected_rows(rows, query, chunk)
      None => break
    }
  }
  ResultSet::{ schema: output_schema, rows, next_row: 0 }
}

///|
fn bind_jsonl_source(from : @sql.TableFunction) -> JsonlSource raise DbError {
  guard from.name == "read_jsonl" else {
    raise DbError::Unsupported(
      "only read_jsonl(path) is supported in the current MVP",
    )
  }
  guard from.arguments.length() == 1 else {
    raise DbError::InvalidArgument("read_jsonl requires exactly one argument")
  }
  match from.arguments[0] {
    @sql.Expr::StringLiteral(path) => JsonlSource::{ path, }
    _ =>
      raise DbError::InvalidArgument("read_jsonl path must be a string literal")
  }
}

///|
fn validate_query(query : @sql.Query, schema : Schema) -> Unit raise DbError {
  for item in query.select_items {
    ignore(infer_expr_type(item.expr, schema))
  }
  match query.where_clause {
    Some(expr) =>
      match infer_expr_type(expr, schema) {
        LogicalType::Boolean => ()
        LogicalType::Null => ()
        _ => raise DbError::Bind("WHERE clause must evaluate to BOOLEAN")
      }
    None => ()
  }
}

///|
fn project_schema(query : @sql.Query, input : Schema) -> Schema raise DbError {
  let columns = []
  for index in 0..<query.select_items.length() {
    let item = query.select_items[index]
    let data_type = infer_expr_type(item.expr, input)
    let name = match item.output_name {
      Some(output_name) => output_name
      None => default_output_name(item.expr, index)
    }
    columns.push(ColumnDef::{
      name,
      data_type,
      nullable: expr_can_be_null(item.expr, input),
    })
  }
  Schema::{ columns, }
}

///|
fn append_projected_rows(
  rows : Array[Row],
  query : @sql.Query,
  chunk : @engine.DataChunk,
) -> Unit raise DbError {
  for row_index in 0..<chunk.len {
    if row_matches_where(query.where_clause, chunk, row_index) {
      let row = []
      for item in query.select_items {
        row.push(eval_expr(item.expr, chunk, row_index))
      }
      rows.push(row)
    }
  }
}

///|
fn row_matches_where(
  where_clause : @sql.Expr?,
  chunk : @engine.DataChunk,
  row_index : Int,
) -> Bool raise DbError {
  match where_clause {
    None => true
    Some(expr) =>
      match eval_expr(expr, chunk, row_index) {
        Value::Boolean(value) => value
        Value::Null => false
        _ => raise DbError::Execute("WHERE clause did not evaluate to BOOLEAN")
      }
  }
}

///|
fn infer_expr_type(
  expr : @sql.Expr,
  schema : Schema,
) -> LogicalType raise DbError {
  match expr {
    @sql.Expr::ColumnRef(path) => resolve_column(path, schema).data_type
    @sql.Expr::StringLiteral(_) => LogicalType::Varchar
    @sql.Expr::IntegerLiteral(_) => LogicalType::BigInt
    @sql.Expr::DoubleLiteral(_) => LogicalType::Double
    @sql.Expr::BooleanLiteral(_) => LogicalType::Boolean
    @sql.Expr::NullLiteral => LogicalType::Null
    @sql.Expr::Unary(op, inner) =>
      match op {
        @sql.UnaryOp::Not =>
          match infer_expr_type(inner, schema) {
            LogicalType::Boolean => LogicalType::Boolean
            LogicalType::Null => LogicalType::Boolean
            _ => raise DbError::Bind("NOT requires a BOOLEAN expression")
          }
        @sql.UnaryOp::Plus | @sql.UnaryOp::Minus =>
          infer_numeric_type(inner, schema)
      }
    @sql.Expr::Binary(op, left, right) =>
      match op {
        @sql.BinaryOp::Add
        | @sql.BinaryOp::Subtract
        | @sql.BinaryOp::Multiply
        | @sql.BinaryOp::Divide =>
          infer_binary_numeric_type(left, right, schema)
        @sql.BinaryOp::And | @sql.BinaryOp::Or => {
          validate_boolean_expr(left, schema)
          validate_boolean_expr(right, schema)
          LogicalType::Boolean
        }
        _ => {
          ignore(infer_expr_type(left, schema))
          ignore(infer_expr_type(right, schema))
          LogicalType::Boolean
        }
      }
    @sql.Expr::IsNull(_) | @sql.Expr::IsNotNull(_) => LogicalType::Boolean
    @sql.Expr::Cast(_, type_name) => type_name_to_logical_type(type_name)
  }
}

///|
fn validate_boolean_expr(
  expr : @sql.Expr,
  schema : Schema,
) -> Unit raise DbError {
  match infer_expr_type(expr, schema) {
    LogicalType::Boolean => ()
    LogicalType::Null => ()
    _ => raise DbError::Bind("boolean operator requires BOOLEAN operands")
  }
}

///|
fn infer_numeric_type(
  expr : @sql.Expr,
  schema : Schema,
) -> LogicalType raise DbError {
  match infer_expr_type(expr, schema) {
    LogicalType::BigInt => LogicalType::BigInt
    LogicalType::Double => LogicalType::Double
    LogicalType::Null => LogicalType::Null
    _ => raise DbError::Bind("numeric expression requires BIGINT or DOUBLE")
  }
}

///|
fn infer_binary_numeric_type(
  left : @sql.Expr,
  right : @sql.Expr,
  schema : Schema,
) -> LogicalType raise DbError {
  let left_type = infer_numeric_type(left, schema)
  let right_type = infer_numeric_type(right, schema)
  match (left_type, right_type) {
    (LogicalType::Double, _) => LogicalType::Double
    (_, LogicalType::Double) => LogicalType::Double
    (LogicalType::Null, other) => other
    (other, LogicalType::Null) => other
    _ => LogicalType::BigInt
  }
}

///|
fn expr_can_be_null(expr : @sql.Expr, schema : Schema) -> Bool {
  match expr {
    @sql.Expr::ColumnRef(path) =>
      match schema.column_index(path[path.length() - 1]) {
        Some(index) => schema.columns[index].nullable
        None => true
      }
    @sql.Expr::NullLiteral => true
    @sql.Expr::Unary(_, inner) => expr_can_be_null(inner, schema)
    @sql.Expr::Binary(_, left, right) =>
      expr_can_be_null(left, schema) || expr_can_be_null(right, schema)
    @sql.Expr::Cast(inner, _) => expr_can_be_null(inner, schema)
    _ => false
  }
}

///|
fn default_output_name(expr : @sql.Expr, index : Int) -> String {
  match expr {
    @sql.Expr::ColumnRef(path) => path[path.length() - 1]
    _ => "expr\{index + 1}"
  }
}

///|
fn resolve_column(
  path : Array[String],
  schema : Schema,
) -> ColumnDef raise DbError {
  guard path.length() > 0 else { raise DbError::Bind("empty column reference") }
  let name = path[path.length() - 1]
  match schema.column_index(name) {
    Some(index) => schema.columns[index]
    None => raise DbError::Bind("unknown column: \{name}")
  }
}

///|
fn eval_expr(
  expr : @sql.Expr,
  chunk : @engine.DataChunk,
  row_index : Int,
) -> Value raise DbError {
  match expr {
    @sql.Expr::ColumnRef(path) => lookup_column_value(path, chunk, row_index)
    @sql.Expr::StringLiteral(text) => Value::Varchar(text)
    @sql.Expr::IntegerLiteral(text) =>
      Value::BigInt(
        @strconv.parse_int64(text[:]) catch {
          _ => raise DbError::Execute("invalid integer literal: \{text}")
        },
      )
    @sql.Expr::DoubleLiteral(text) =>
      Value::Double(
        @strconv.parse_double(text[:]) catch {
          _ => raise DbError::Execute("invalid double literal: \{text}")
        },
      )
    @sql.Expr::BooleanLiteral(value) => Value::Boolean(value)
    @sql.Expr::NullLiteral => Value::Null
    @sql.Expr::Unary(op, inner) =>
      eval_unary(op, eval_expr(inner, chunk, row_index))
    @sql.Expr::Binary(op, left, right) =>
      eval_binary(
        op,
        eval_expr(left, chunk, row_index),
        eval_expr(right, chunk, row_index),
      )
    @sql.Expr::IsNull(inner) =>
      Value::Boolean(
        match eval_expr(inner, chunk, row_index) {
          Value::Null => true
          _ => false
        },
      )
    @sql.Expr::IsNotNull(inner) =>
      Value::Boolean(
        match eval_expr(inner, chunk, row_index) {
          Value::Null => false
          _ => true
        },
      )
    @sql.Expr::Cast(inner, type_name) =>
      cast_value(
        eval_expr(inner, chunk, row_index),
        type_name_to_logical_type(type_name),
      )
  }
}

///|
fn lookup_column_value(
  path : Array[String],
  chunk : @engine.DataChunk,
  row_index : Int,
) -> Value raise DbError {
  let column = resolve_column(path, chunk.schema)
  let column_index = chunk.schema.column_index(column.name).unwrap()
  vector_value_at(chunk.columns[column_index], row_index)
}

///|
fn vector_value_at(vector : @engine.Vector, row_index : Int) -> Value {
  let is_valid = match vector.validity.is_valid(row_index) {
    Some(value) => value
    None => false
  }
  guard is_valid else { return Value::Null }
  match vector.values {
    @engine.VectorBuffer::Nulls(_) => Value::Null
    @engine.VectorBuffer::Bool(values) => Value::Boolean(values[row_index])
    @engine.VectorBuffer::Int64(values) => Value::BigInt(values[row_index])
    @engine.VectorBuffer::Double(values) => Value::Double(values[row_index])
    @engine.VectorBuffer::Varchar(values) => Value::Varchar(values[row_index])
  }
}

///|
fn eval_unary(op : @sql.UnaryOp, value : Value) -> Value raise DbError {
  match value {
    Value::Null => Value::Null
    _ =>
      match (op, value) {
        (@sql.UnaryOp::Plus, Value::BigInt(v)) => Value::BigInt(v)
        (@sql.UnaryOp::Plus, Value::Double(v)) => Value::Double(v)
        (@sql.UnaryOp::Minus, Value::BigInt(v)) => Value::BigInt(-v)
        (@sql.UnaryOp::Minus, Value::Double(v)) => Value::Double(-v)
        (@sql.UnaryOp::Not, Value::Boolean(v)) => Value::Boolean(!v)
        _ => raise DbError::Execute("invalid unary expression")
      }
  }
}

///|
fn eval_binary(
  op : @sql.BinaryOp,
  left : Value,
  right : Value,
) -> Value raise DbError {
  match op {
    @sql.BinaryOp::And | @sql.BinaryOp::Or =>
      eval_boolean_binary(op, left, right)
    @sql.BinaryOp::Add
    | @sql.BinaryOp::Subtract
    | @sql.BinaryOp::Multiply
    | @sql.BinaryOp::Divide => eval_numeric_binary(op, left, right)
    _ => eval_comparison(op, left, right)
  }
}

///|
fn eval_boolean_binary(
  op : @sql.BinaryOp,
  left : Value,
  right : Value,
) -> Value raise DbError {
  match (left, right) {
    (Value::Null, _) => Value::Null
    (_, Value::Null) => Value::Null
    (Value::Boolean(l), Value::Boolean(r)) =>
      Value::Boolean(
        match op {
          @sql.BinaryOp::And => l && r
          @sql.BinaryOp::Or => l || r
          _ => false
        },
      )
    _ => raise DbError::Execute("boolean operator requires BOOLEAN operands")
  }
}

///|
fn eval_numeric_binary(
  op : @sql.BinaryOp,
  left : Value,
  right : Value,
) -> Value raise DbError {
  match (left, right) {
    (Value::Null, _) => Value::Null
    (_, Value::Null) => Value::Null
    (Value::BigInt(l), Value::BigInt(r)) =>
      match op {
        @sql.BinaryOp::Add => Value::BigInt(l + r)
        @sql.BinaryOp::Subtract => Value::BigInt(l - r)
        @sql.BinaryOp::Multiply => Value::BigInt(l * r)
        @sql.BinaryOp::Divide => Value::Double(l.to_double() / r.to_double())
        _ => raise DbError::Execute("invalid numeric operator")
      }
    _ => {
      let l = value_to_double(left)
      let r = value_to_double(right)
      Value::Double(
        match op {
          @sql.BinaryOp::Add => l + r
          @sql.BinaryOp::Subtract => l - r
          @sql.BinaryOp::Multiply => l * r
          @sql.BinaryOp::Divide => l / r
          _ => raise DbError::Execute("invalid numeric operator")
        },
      )
    }
  }
}

///|
fn eval_comparison(
  op : @sql.BinaryOp,
  left : Value,
  right : Value,
) -> Value raise DbError {
  match (left, right) {
    (Value::Null, _) => Value::Null
    (_, Value::Null) => Value::Null
    (Value::Boolean(l), Value::Boolean(r)) =>
      match op {
        @sql.BinaryOp::Equal => Value::Boolean(l == r)
        @sql.BinaryOp::NotEqual => Value::Boolean(l != r)
        _ => raise DbError::Execute("invalid BOOLEAN comparison")
      }
    (Value::Varchar(l), Value::Varchar(r)) =>
      Value::Boolean(compare_int(op, l.lexical_compare(r)))
    _ => {
      let l = value_to_double(left)
      let r = value_to_double(right)
      Value::Boolean(compare_double(op, l, r))
    }
  }
}

///|
fn compare_int(op : @sql.BinaryOp, ordering : Int) -> Bool raise DbError {
  match op {
    @sql.BinaryOp::Equal => ordering == 0
    @sql.BinaryOp::NotEqual => ordering != 0
    @sql.BinaryOp::LessThan => ordering < 0
    @sql.BinaryOp::LessThanOrEqual => ordering <= 0
    @sql.BinaryOp::GreaterThan => ordering > 0
    @sql.BinaryOp::GreaterThanOrEqual => ordering >= 0
    _ => raise DbError::Execute("invalid comparison operator")
  }
}

///|
fn compare_double(
  op : @sql.BinaryOp,
  left : Double,
  right : Double,
) -> Bool raise DbError {
  match op {
    @sql.BinaryOp::Equal => left == right
    @sql.BinaryOp::NotEqual => left != right
    @sql.BinaryOp::LessThan => left < right
    @sql.BinaryOp::LessThanOrEqual => left <= right
    @sql.BinaryOp::GreaterThan => left > right
    @sql.BinaryOp::GreaterThanOrEqual => left >= right
    _ => raise DbError::Execute("invalid comparison operator")
  }
}

///|
fn value_to_double(value : Value) -> Double raise DbError {
  match value {
    Value::BigInt(v) => v.to_double()
    Value::Double(v) => v
    _ =>
      raise DbError::Execute(
        "numeric operator requires BIGINT or DOUBLE operands",
      )
  }
}

///|
fn cast_value(value : Value, target : LogicalType) -> Value raise DbError {
  match value {
    Value::Null => Value::Null
    _ =>
      match (value, target) {
        (_, LogicalType::Varchar) => Value::Varchar(value.to_string())
        (Value::Boolean(v), LogicalType::Boolean) => Value::Boolean(v)
        (Value::BigInt(v), LogicalType::BigInt) => Value::BigInt(v)
        (Value::BigInt(v), LogicalType::Double) => Value::Double(v.to_double())
        (Value::Double(v), LogicalType::Double) => Value::Double(v)
        (Value::Double(v), LogicalType::BigInt) => Value::BigInt(v.to_int64())
        (Value::Varchar(text), LogicalType::BigInt) =>
          Value::BigInt(
            @strconv.parse_int64(text[:]) catch {
              _ =>
                raise DbError::Execute("cannot cast VARCHAR to BIGINT: \{text}")
            },
          )
        (Value::Varchar(text), LogicalType::Double) =>
          Value::Double(
            @strconv.parse_double(text[:]) catch {
              _ =>
                raise DbError::Execute("cannot cast VARCHAR to DOUBLE: \{text}")
            },
          )
        (Value::Varchar("true"), LogicalType::Boolean) => Value::Boolean(true)
        (Value::Varchar("false"), LogicalType::Boolean) => Value::Boolean(false)
        _ => raise DbError::Execute("unsupported cast")
      }
  }
}

///|
fn type_name_to_logical_type(type_name : @sql.TypeName) -> LogicalType {
  match type_name {
    @sql.TypeName::Null => LogicalType::Null
    @sql.TypeName::Boolean => LogicalType::Boolean
    @sql.TypeName::BigInt => LogicalType::BigInt
    @sql.TypeName::Double => LogicalType::Double
    @sql.TypeName::Varchar => LogicalType::Varchar
  }
}

///|
fn map_scan_error(err : @scan.ScanError) -> DbError {
  match err {
    @scan.ScanError::Io(message) => DbError::Io(message)
    _ => DbError::Scan(err.to_string())
  }
}

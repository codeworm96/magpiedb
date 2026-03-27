///|
pub struct QueryOutput {
  schema : @engine.Schema
  rows : Array[@engine.Row]
} derive(Eq, Show)

///|
pub suberror ExecuteError {
  InvalidArgument(String)
  Bind(String)
  Scan(String)
  Io(String)
  Execute(String)
  Unsupported(String)
} derive(Show)

///|
priv struct JsonlSource {
  path : String
}

///|
pub fn execute_query(query : @sql.Query) -> QueryOutput raise ExecuteError {
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
  QueryOutput::{ schema: output_schema, rows }
}

///|
fn bind_jsonl_source(
  from : @sql.TableFunction,
) -> JsonlSource raise ExecuteError {
  guard from.name == "read_jsonl" else {
    raise ExecuteError::Unsupported(
      "only read_jsonl(path) is supported in the current MVP",
    )
  }
  guard from.arguments.length() == 1 else {
    raise ExecuteError::InvalidArgument(
      "read_jsonl requires exactly one argument",
    )
  }
  match from.arguments[0] {
    @sql.Expr::StringLiteral(path) => JsonlSource::{ path, }
    _ =>
      raise ExecuteError::InvalidArgument(
        "read_jsonl path must be a string literal",
      )
  }
}

///|
fn validate_query(
  query : @sql.Query,
  schema : @engine.Schema,
) -> Unit raise ExecuteError {
  for item in query.select_items {
    ignore(infer_expr_type(item.expr, schema))
  }
  match query.where_clause {
    Some(expr) =>
      match infer_expr_type(expr, schema) {
        @engine.LogicalType::Boolean => ()
        @engine.LogicalType::Null => ()
        _ => raise ExecuteError::Bind("WHERE clause must evaluate to BOOLEAN")
      }
    None => ()
  }
}

///|
fn project_schema(
  query : @sql.Query,
  input : @engine.Schema,
) -> @engine.Schema raise ExecuteError {
  let columns = []
  for index in 0..<query.select_items.length() {
    let item = query.select_items[index]
    let data_type = infer_expr_type(item.expr, input)
    let name = match item.output_name {
      Some(output_name) => output_name
      None => default_output_name(item.expr, index)
    }
    columns.push(@engine.ColumnDef::{
      name,
      data_type,
      nullable: expr_can_be_null(item.expr, input),
    })
  }
  @engine.Schema::{ columns, }
}

///|
fn append_projected_rows(
  rows : Array[@engine.Row],
  query : @sql.Query,
  chunk : @engine.DataChunk,
) -> Unit raise ExecuteError {
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
) -> Bool raise ExecuteError {
  match where_clause {
    None => true
    Some(expr) =>
      match eval_expr(expr, chunk, row_index) {
        @engine.Value::Boolean(value) => value
        @engine.Value::Null => false
        _ =>
          raise ExecuteError::Execute(
            "WHERE clause did not evaluate to BOOLEAN",
          )
      }
  }
}

///|
fn infer_expr_type(
  expr : @sql.Expr,
  schema : @engine.Schema,
) -> @engine.LogicalType raise ExecuteError {
  match expr {
    @sql.Expr::ColumnRef(path) => resolve_column(path, schema).data_type
    @sql.Expr::StringLiteral(_) => @engine.LogicalType::Varchar
    @sql.Expr::IntegerLiteral(_) => @engine.LogicalType::BigInt
    @sql.Expr::DoubleLiteral(_) => @engine.LogicalType::Double
    @sql.Expr::BooleanLiteral(_) => @engine.LogicalType::Boolean
    @sql.Expr::NullLiteral => @engine.LogicalType::Null
    @sql.Expr::Unary(op, inner) =>
      match op {
        @sql.UnaryOp::Not =>
          match infer_expr_type(inner, schema) {
            @engine.LogicalType::Boolean => @engine.LogicalType::Boolean
            @engine.LogicalType::Null => @engine.LogicalType::Boolean
            _ => raise ExecuteError::Bind("NOT requires a BOOLEAN expression")
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
          @engine.LogicalType::Boolean
        }
        _ => {
          ignore(infer_expr_type(left, schema))
          ignore(infer_expr_type(right, schema))
          @engine.LogicalType::Boolean
        }
      }
    @sql.Expr::IsNull(_) | @sql.Expr::IsNotNull(_) =>
      @engine.LogicalType::Boolean
    @sql.Expr::Cast(_, type_name) => type_name_to_logical_type(type_name)
  }
}

///|
fn validate_boolean_expr(
  expr : @sql.Expr,
  schema : @engine.Schema,
) -> Unit raise ExecuteError {
  match infer_expr_type(expr, schema) {
    @engine.LogicalType::Boolean => ()
    @engine.LogicalType::Null => ()
    _ => raise ExecuteError::Bind("boolean operator requires BOOLEAN operands")
  }
}

///|
fn infer_numeric_type(
  expr : @sql.Expr,
  schema : @engine.Schema,
) -> @engine.LogicalType raise ExecuteError {
  match infer_expr_type(expr, schema) {
    @engine.LogicalType::BigInt => @engine.LogicalType::BigInt
    @engine.LogicalType::Double => @engine.LogicalType::Double
    @engine.LogicalType::Null => @engine.LogicalType::Null
    _ =>
      raise ExecuteError::Bind("numeric expression requires BIGINT or DOUBLE")
  }
}

///|
fn infer_binary_numeric_type(
  left : @sql.Expr,
  right : @sql.Expr,
  schema : @engine.Schema,
) -> @engine.LogicalType raise ExecuteError {
  let left_type = infer_numeric_type(left, schema)
  let right_type = infer_numeric_type(right, schema)
  match (left_type, right_type) {
    (@engine.LogicalType::Double, _) => @engine.LogicalType::Double
    (_, @engine.LogicalType::Double) => @engine.LogicalType::Double
    (@engine.LogicalType::Null, other) => other
    (other, @engine.LogicalType::Null) => other
    _ => @engine.LogicalType::BigInt
  }
}

///|
fn expr_can_be_null(expr : @sql.Expr, schema : @engine.Schema) -> Bool {
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
  schema : @engine.Schema,
) -> @engine.ColumnDef raise ExecuteError {
  guard path.length() > 0 else {
    raise ExecuteError::Bind("empty column reference")
  }
  let name = path[path.length() - 1]
  match schema.column_index(name) {
    Some(index) => schema.columns[index]
    None => raise ExecuteError::Bind("unknown column: \{name}")
  }
}

///|
fn eval_expr(
  expr : @sql.Expr,
  chunk : @engine.DataChunk,
  row_index : Int,
) -> @engine.Value raise ExecuteError {
  match expr {
    @sql.Expr::ColumnRef(path) => lookup_column_value(path, chunk, row_index)
    @sql.Expr::StringLiteral(text) => @engine.Value::Varchar(text)
    @sql.Expr::IntegerLiteral(text) =>
      @engine.Value::BigInt(
        @strconv.parse_int64(text[:]) catch {
          _ => raise ExecuteError::Execute("invalid integer literal: \{text}")
        },
      )
    @sql.Expr::DoubleLiteral(text) =>
      @engine.Value::Double(
        @strconv.parse_double(text[:]) catch {
          _ => raise ExecuteError::Execute("invalid double literal: \{text}")
        },
      )
    @sql.Expr::BooleanLiteral(value) => @engine.Value::Boolean(value)
    @sql.Expr::NullLiteral => @engine.Value::Null
    @sql.Expr::Unary(op, inner) =>
      eval_unary(op, eval_expr(inner, chunk, row_index))
    @sql.Expr::Binary(op, left, right) =>
      eval_binary(
        op,
        eval_expr(left, chunk, row_index),
        eval_expr(right, chunk, row_index),
      )
    @sql.Expr::IsNull(inner) =>
      @engine.Value::Boolean(
        match eval_expr(inner, chunk, row_index) {
          @engine.Value::Null => true
          _ => false
        },
      )
    @sql.Expr::IsNotNull(inner) =>
      @engine.Value::Boolean(
        match eval_expr(inner, chunk, row_index) {
          @engine.Value::Null => false
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
) -> @engine.Value raise ExecuteError {
  let column = resolve_column(path, chunk.schema)
  let column_index = chunk.schema.column_index(column.name).unwrap()
  vector_value_at(chunk.columns[column_index], row_index)
}

///|
fn vector_value_at(vector : @engine.Vector, row_index : Int) -> @engine.Value {
  let is_valid = match vector.validity.is_valid(row_index) {
    Some(value) => value
    None => false
  }
  guard is_valid else { return @engine.Value::Null }
  match vector.values {
    @engine.VectorBuffer::Nulls(_) => @engine.Value::Null
    @engine.VectorBuffer::Bool(values) =>
      @engine.Value::Boolean(values[row_index])
    @engine.VectorBuffer::Int64(values) =>
      @engine.Value::BigInt(values[row_index])
    @engine.VectorBuffer::Double(values) =>
      @engine.Value::Double(values[row_index])
    @engine.VectorBuffer::Varchar(values) =>
      @engine.Value::Varchar(values[row_index])
  }
}

///|
fn eval_unary(
  op : @sql.UnaryOp,
  value : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Null => @engine.Value::Null
    _ =>
      match (op, value) {
        (@sql.UnaryOp::Plus, @engine.Value::BigInt(v)) =>
          @engine.Value::BigInt(v)
        (@sql.UnaryOp::Plus, @engine.Value::Double(v)) =>
          @engine.Value::Double(v)
        (@sql.UnaryOp::Minus, @engine.Value::BigInt(v)) =>
          @engine.Value::BigInt(-v)
        (@sql.UnaryOp::Minus, @engine.Value::Double(v)) =>
          @engine.Value::Double(-v)
        (@sql.UnaryOp::Not, @engine.Value::Boolean(v)) =>
          @engine.Value::Boolean(!v)
        _ => raise ExecuteError::Execute("invalid unary expression")
      }
  }
}

///|
fn eval_binary(
  op : @sql.BinaryOp,
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
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
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Null, _) => @engine.Value::Null
    (_, @engine.Value::Null) => @engine.Value::Null
    (@engine.Value::Boolean(l), @engine.Value::Boolean(r)) =>
      @engine.Value::Boolean(
        match op {
          @sql.BinaryOp::And => l && r
          @sql.BinaryOp::Or => l || r
          _ => false
        },
      )
    _ =>
      raise ExecuteError::Execute("boolean operator requires BOOLEAN operands")
  }
}

///|
fn eval_numeric_binary(
  op : @sql.BinaryOp,
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Null, _) => @engine.Value::Null
    (_, @engine.Value::Null) => @engine.Value::Null
    (@engine.Value::BigInt(l), @engine.Value::BigInt(r)) =>
      match op {
        @sql.BinaryOp::Add => @engine.Value::BigInt(l + r)
        @sql.BinaryOp::Subtract => @engine.Value::BigInt(l - r)
        @sql.BinaryOp::Multiply => @engine.Value::BigInt(l * r)
        @sql.BinaryOp::Divide =>
          @engine.Value::Double(l.to_double() / r.to_double())
        _ => raise ExecuteError::Execute("invalid numeric operator")
      }
    _ => {
      let l = value_to_double(left)
      let r = value_to_double(right)
      @engine.Value::Double(
        match op {
          @sql.BinaryOp::Add => l + r
          @sql.BinaryOp::Subtract => l - r
          @sql.BinaryOp::Multiply => l * r
          @sql.BinaryOp::Divide => l / r
          _ => raise ExecuteError::Execute("invalid numeric operator")
        },
      )
    }
  }
}

///|
fn eval_comparison(
  op : @sql.BinaryOp,
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Null, _) => @engine.Value::Null
    (_, @engine.Value::Null) => @engine.Value::Null
    (@engine.Value::Boolean(l), @engine.Value::Boolean(r)) =>
      match op {
        @sql.BinaryOp::Equal => @engine.Value::Boolean(l == r)
        @sql.BinaryOp::NotEqual => @engine.Value::Boolean(l != r)
        _ => raise ExecuteError::Execute("invalid BOOLEAN comparison")
      }
    (@engine.Value::Varchar(l), @engine.Value::Varchar(r)) =>
      @engine.Value::Boolean(compare_int(op, l.lexical_compare(r)))
    _ => {
      let l = value_to_double(left)
      let r = value_to_double(right)
      @engine.Value::Boolean(compare_double(op, l, r))
    }
  }
}

///|
fn compare_int(op : @sql.BinaryOp, ordering : Int) -> Bool raise ExecuteError {
  match op {
    @sql.BinaryOp::Equal => ordering == 0
    @sql.BinaryOp::NotEqual => ordering != 0
    @sql.BinaryOp::LessThan => ordering < 0
    @sql.BinaryOp::LessThanOrEqual => ordering <= 0
    @sql.BinaryOp::GreaterThan => ordering > 0
    @sql.BinaryOp::GreaterThanOrEqual => ordering >= 0
    _ => raise ExecuteError::Execute("invalid comparison operator")
  }
}

///|
fn compare_double(
  op : @sql.BinaryOp,
  left : Double,
  right : Double,
) -> Bool raise ExecuteError {
  match op {
    @sql.BinaryOp::Equal => left == right
    @sql.BinaryOp::NotEqual => left != right
    @sql.BinaryOp::LessThan => left < right
    @sql.BinaryOp::LessThanOrEqual => left <= right
    @sql.BinaryOp::GreaterThan => left > right
    @sql.BinaryOp::GreaterThanOrEqual => left >= right
    _ => raise ExecuteError::Execute("invalid comparison operator")
  }
}

///|
fn value_to_double(value : @engine.Value) -> Double raise ExecuteError {
  match value {
    @engine.Value::BigInt(v) => v.to_double()
    @engine.Value::Double(v) => v
    _ =>
      raise ExecuteError::Execute(
        "numeric operator requires BIGINT or DOUBLE operands",
      )
  }
}

///|
fn cast_value(
  value : @engine.Value,
  target : @engine.LogicalType,
) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Null => @engine.Value::Null
    _ =>
      match (value, target) {
        (_, @engine.LogicalType::Varchar) =>
          @engine.Value::Varchar(value.to_string())
        (@engine.Value::Boolean(v), @engine.LogicalType::Boolean) =>
          @engine.Value::Boolean(v)
        (@engine.Value::BigInt(v), @engine.LogicalType::BigInt) =>
          @engine.Value::BigInt(v)
        (@engine.Value::BigInt(v), @engine.LogicalType::Double) =>
          @engine.Value::Double(v.to_double())
        (@engine.Value::Double(v), @engine.LogicalType::Double) =>
          @engine.Value::Double(v)
        (@engine.Value::Double(v), @engine.LogicalType::BigInt) =>
          @engine.Value::BigInt(v.to_int64())
        (@engine.Value::Varchar(text), @engine.LogicalType::BigInt) =>
          @engine.Value::BigInt(
            @strconv.parse_int64(text[:]) catch {
              _ =>
                raise ExecuteError::Execute(
                  "cannot cast VARCHAR to BIGINT: \{text}",
                )
            },
          )
        (@engine.Value::Varchar(text), @engine.LogicalType::Double) =>
          @engine.Value::Double(
            @strconv.parse_double(text[:]) catch {
              _ =>
                raise ExecuteError::Execute(
                  "cannot cast VARCHAR to DOUBLE: \{text}",
                )
            },
          )
        (@engine.Value::Varchar("true"), @engine.LogicalType::Boolean) =>
          @engine.Value::Boolean(true)
        (@engine.Value::Varchar("false"), @engine.LogicalType::Boolean) =>
          @engine.Value::Boolean(false)
        _ => raise ExecuteError::Execute("unsupported cast")
      }
  }
}

///|
fn type_name_to_logical_type(type_name : @sql.TypeName) -> @engine.LogicalType {
  match type_name {
    @sql.TypeName::Null => @engine.LogicalType::Null
    @sql.TypeName::Boolean => @engine.LogicalType::Boolean
    @sql.TypeName::BigInt => @engine.LogicalType::BigInt
    @sql.TypeName::Double => @engine.LogicalType::Double
    @sql.TypeName::Varchar => @engine.LogicalType::Varchar
  }
}

///|
fn map_scan_error(err : @scan.ScanError) -> ExecuteError {
  match err {
    @scan.ScanError::Io(message) => ExecuteError::Io(message)
    _ => ExecuteError::Scan(err.to_string())
  }
}

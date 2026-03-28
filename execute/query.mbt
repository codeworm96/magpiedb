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
pub fn execute_query(query : @sql.Query) -> QueryOutput raise ExecuteError {
  let plan = @plan.plan_query(query) catch { err => raise map_plan_error(err) }
  execute_plan(plan)
}

///|
pub fn execute_plan(plan : @plan.QueryPlan) -> QueryOutput raise ExecuteError {
  let scan = find_scan_source(plan)
  let scanner = open_scan_source(scan)
  let rows = []
  while true {
    let next_chunk = scanner.next_chunk() catch {
      err => raise map_scan_error(err)
    }
    match next_chunk {
      Some(chunk) => append_rows(rows, plan, chunk)
      None => break
    }
  }
  QueryOutput::{ schema: @plan.query_plan_schema(plan), rows }
}

///|
fn find_scan_source(plan : @plan.QueryPlan) -> @plan.ScanSource {
  match plan {
    @plan.QueryPlan::Scan(scan_plan) => scan_plan.source
    @plan.QueryPlan::Filter(filter_plan) => find_scan_source(filter_plan.input)
    @plan.QueryPlan::Projection(projection_plan) =>
      find_scan_source(projection_plan.input)
  }
}

///|
fn open_scan_source(
  source : @plan.ScanSource,
) -> @scan.JsonlScanner raise ExecuteError {
  match source {
    @plan.ScanSource::Jsonl(scan) =>
      @scan.read_jsonl(scan.path) catch {
        err => raise map_scan_error(err)
      }
  }
}

///|
fn append_rows(
  rows : Array[@engine.Row],
  plan : @plan.QueryPlan,
  chunk : @engine.DataChunk,
) -> Unit raise ExecuteError {
  for row_index in 0..<chunk.len {
    append_row_if_visible(rows, plan, chunk, row_index)
  }
}

///|
fn append_row_if_visible(
  rows : Array[@engine.Row],
  plan : @plan.QueryPlan,
  chunk : @engine.DataChunk,
  row_index : Int,
) -> Unit raise ExecuteError {
  match plan {
    @plan.QueryPlan::Scan(_) => rows.push([])
    @plan.QueryPlan::Filter(filter_plan) =>
      if row_matches_filter(filter_plan.predicate, chunk, row_index) {
        append_row_if_visible(rows, filter_plan.input, chunk, row_index)
      }
    @plan.QueryPlan::Projection(projection_plan) =>
      if row_is_visible(projection_plan.input, chunk, row_index) {
        let row = []
        for item in projection_plan.projections {
          row.push(eval_expr(item.expr, chunk, row_index))
        }
        rows.push(row)
      }
  }
}

///|
fn row_is_visible(
  plan : @plan.QueryPlan,
  chunk : @engine.DataChunk,
  row_index : Int,
) -> Bool raise ExecuteError {
  match plan {
    @plan.QueryPlan::Scan(_) => true
    @plan.QueryPlan::Filter(filter_plan) =>
      row_matches_filter(filter_plan.predicate, chunk, row_index) &&
      row_is_visible(filter_plan.input, chunk, row_index)
    @plan.QueryPlan::Projection(projection_plan) =>
      row_is_visible(projection_plan.input, chunk, row_index)
  }
}

///|
fn row_matches_filter(
  predicate : @plan.PlanExpr,
  chunk : @engine.DataChunk,
  row_index : Int,
) -> Bool raise ExecuteError {
  match eval_expr(predicate, chunk, row_index) {
    @engine.Value::Boolean(value) => value
    @engine.Value::Null => false
    _ => raise ExecuteError::Execute("WHERE clause did not evaluate to BOOLEAN")
  }
}

///|
fn eval_expr(
  expr : @plan.PlanExpr,
  chunk : @engine.DataChunk,
  row_index : Int,
) -> @engine.Value raise ExecuteError {
  match expr {
    @plan.PlanExpr::ColumnRef(column_ref) =>
      vector_value_at(chunk.columns[column_ref.index], row_index)
    @plan.PlanExpr::StringLiteral(text) => @engine.Value::Varchar(text)
    @plan.PlanExpr::IntegerLiteral(text) =>
      @engine.Value::BigInt(
        @strconv.parse_int64(text[:]) catch {
          _ => raise ExecuteError::Execute("invalid integer literal: \{text}")
        },
      )
    @plan.PlanExpr::DoubleLiteral(text) =>
      @engine.Value::Double(
        @strconv.parse_double(text[:]) catch {
          _ => raise ExecuteError::Execute("invalid double literal: \{text}")
        },
      )
    @plan.PlanExpr::BooleanLiteral(value) => @engine.Value::Boolean(value)
    @plan.PlanExpr::NullLiteral => @engine.Value::Null
    @plan.PlanExpr::Unary(op, inner) =>
      eval_unary(op, eval_expr(inner, chunk, row_index))
    @plan.PlanExpr::Binary(op, left, right) =>
      eval_binary(
        op,
        eval_expr(left, chunk, row_index),
        eval_expr(right, chunk, row_index),
      )
    @plan.PlanExpr::IsNull(inner) =>
      @engine.Value::Boolean(
        match eval_expr(inner, chunk, row_index) {
          @engine.Value::Null => true
          _ => false
        },
      )
    @plan.PlanExpr::IsNotNull(inner) =>
      @engine.Value::Boolean(
        match eval_expr(inner, chunk, row_index) {
          @engine.Value::Null => false
          _ => true
        },
      )
    @plan.PlanExpr::Cast(inner, logical_type) =>
      cast_value(eval_expr(inner, chunk, row_index), logical_type)
  }
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
  target_type : @engine.LogicalType,
) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Null => @engine.Value::Null
    _ =>
      match target_type {
        @engine.LogicalType::Null => @engine.Value::Null
        @engine.LogicalType::Boolean => cast_to_boolean(value)
        @engine.LogicalType::BigInt => cast_to_bigint(value)
        @engine.LogicalType::Double => cast_to_double(value)
        @engine.LogicalType::Varchar =>
          @engine.Value::Varchar(value.to_string())
      }
  }
}

///|
fn cast_to_boolean(value : @engine.Value) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Boolean(v) => @engine.Value::Boolean(v)
    @engine.Value::BigInt(v) => @engine.Value::Boolean(v != 0L)
    @engine.Value::Double(v) => @engine.Value::Boolean(v != 0.0)
    @engine.Value::Varchar(text) =>
      match text {
        "true" | "TRUE" => @engine.Value::Boolean(true)
        "false" | "FALSE" => @engine.Value::Boolean(false)
        _ => raise ExecuteError::Execute("cannot cast VARCHAR to BOOLEAN")
      }
    @engine.Value::Null => @engine.Value::Null
  }
}

///|
fn cast_to_bigint(value : @engine.Value) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Boolean(v) => @engine.Value::BigInt(if v { 1L } else { 0L })
    @engine.Value::BigInt(v) => @engine.Value::BigInt(v)
    @engine.Value::Double(v) => @engine.Value::BigInt(v.to_int64())
    @engine.Value::Varchar(text) =>
      @engine.Value::BigInt(
        @strconv.parse_int64(text[:]) catch {
          _ => raise ExecuteError::Execute("cannot cast VARCHAR to BIGINT")
        },
      )
    @engine.Value::Null => @engine.Value::Null
  }
}

///|
fn cast_to_double(value : @engine.Value) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Boolean(v) =>
      @engine.Value::Double(if v { 1.0 } else { 0.0 })
    @engine.Value::BigInt(v) => @engine.Value::Double(v.to_double())
    @engine.Value::Double(v) => @engine.Value::Double(v)
    @engine.Value::Varchar(text) =>
      @engine.Value::Double(
        @strconv.parse_double(text[:]) catch {
          _ => raise ExecuteError::Execute("cannot cast VARCHAR to DOUBLE")
        },
      )
    @engine.Value::Null => @engine.Value::Null
  }
}

///|
fn map_scan_error(err : @scan.ScanError) -> ExecuteError {
  match err {
    @scan.ScanError::Io(message) => ExecuteError::Io(message)
    @scan.ScanError::JsonParse(line_no, message) =>
      ExecuteError::Scan("json parse error at line \{line_no}: \{message}")
    @scan.ScanError::JsonRootNotObject(line_no) =>
      ExecuteError::Scan("expected JSON object at line \{line_no}")
    @scan.ScanError::TypeMismatch(column, line_no, message) =>
      ExecuteError::Scan(
        "type mismatch for column \{column} at line \{line_no}: \{message}",
      )
  }
}

///|
fn map_plan_error(err : @plan.PlanError) -> ExecuteError {
  match err {
    @plan.PlanError::InvalidArgument(message) =>
      ExecuteError::InvalidArgument(message)
    @plan.PlanError::Bind(message) => ExecuteError::Bind(message)
    @plan.PlanError::Scan(message) => ExecuteError::Scan(message)
    @plan.PlanError::Io(message) => ExecuteError::Io(message)
    @plan.PlanError::Unsupported(message) => ExecuteError::Unsupported(message)
  }
}

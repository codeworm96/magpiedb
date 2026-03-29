///|
priv enum ScanOperator {
  Csv(@scan.CsvScanner)
  Jsonl(@scan.JsonlScanner)
}

///|
pub struct QueryOutput {
  schema : @engine.Schema
  chunks : Array[@engine.DataChunk]
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
  let chunks = []
  while true {
    let next_chunk = next_plan_chunk(plan, scanner)
    match next_chunk {
      Some(chunk) => chunks.push(chunk)
      None => break
    }
  }
  QueryOutput::{ schema: @plan.query_plan_schema(plan), chunks }
}

///|
fn next_plan_chunk(
  plan : @plan.QueryPlan,
  scanner : ScanOperator,
) -> @engine.DataChunk? raise ExecuteError {
  match plan {
    @plan.QueryPlan::Scan(_) => next_scan_chunk(scanner)
    @plan.QueryPlan::Filter(filter_plan) =>
      next_filter_chunk(filter_plan, scanner)
    @plan.QueryPlan::Projection(projection_plan) =>
      next_projection_chunk(projection_plan, scanner)
  }
}

///|
fn next_filter_chunk(
  filter_plan : @plan.FilterPlan,
  scanner : ScanOperator,
) -> @engine.DataChunk? raise ExecuteError {
  let mut next_input = next_plan_chunk(filter_plan.input, scanner)
  while next_input is Some(chunk) {
    let filtered = filter_chunk(chunk, filter_plan.predicate)
    if !filtered.is_empty() {
      return Some(filtered)
    }
    next_input = next_plan_chunk(filter_plan.input, scanner)
  }
  None
}

///|
fn next_projection_chunk(
  projection_plan : @plan.ProjectionPlan,
  scanner : ScanOperator,
) -> @engine.DataChunk? raise ExecuteError {
  match next_plan_chunk(projection_plan.input, scanner) {
    None => None
    Some(chunk) =>
      Some(
        project_chunk(
          chunk,
          projection_plan.projections,
          projection_plan.output_schema,
        ),
      )
  }
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
) -> ScanOperator raise ExecuteError {
  match source {
    @plan.ScanSource::Csv(scan) =>
      ScanOperator::Csv(
        @scan.read_csv(scan.path) catch {
          err => raise map_scan_error(err)
        },
      )
    @plan.ScanSource::Jsonl(scan) =>
      ScanOperator::Jsonl(
        @scan.read_jsonl(scan.path) catch {
          err => raise map_scan_error(err)
        },
      )
  }
}

///|
fn next_scan_chunk(
  scanner : ScanOperator,
) -> @engine.DataChunk? raise ExecuteError {
  match scanner {
    ScanOperator::Csv(scanner) =>
      scanner.next_chunk() catch {
        err => raise map_scan_error(err)
      }
    ScanOperator::Jsonl(scanner) =>
      scanner.next_chunk() catch {
        err => raise map_scan_error(err)
      }
  }
}

///|
fn filter_chunk(
  chunk : @engine.DataChunk,
  predicate : @plan.PlanExpr,
) -> @engine.DataChunk raise ExecuteError {
  let predicate_vector = eval_expr_to_vector(predicate, chunk)
  let selected_indices = []
  for row_index in 0..<chunk.len {
    match vector_value_at(predicate_vector, row_index) {
      @engine.Value::Boolean(true) => selected_indices.push(row_index)
      @engine.Value::Boolean(false) | @engine.Value::Null => ()
      _ =>
        raise ExecuteError::Execute("WHERE clause did not evaluate to BOOLEAN")
    }
  }
  if selected_indices.length() == 0 {
    return @engine.DataChunk::empty(chunk.schema)
  }
  let columns = []
  for column in chunk.columns {
    columns.push(take_vector(column, selected_indices))
  }
  @engine.DataChunk::{
    schema: chunk.schema,
    columns,
    len: selected_indices.length(),
  }
}

///|
fn project_chunk(
  chunk : @engine.DataChunk,
  projections : Array[@plan.PlanSelectItem],
  output_schema : @engine.Schema,
) -> @engine.DataChunk raise ExecuteError {
  let columns = []
  for item in projections {
    columns.push(eval_expr_to_vector(item.expr, chunk))
  }
  @engine.DataChunk::{ schema: output_schema, columns, len: chunk.len }
}

///|
fn eval_expr_to_vector(
  expr : @plan.PlanExpr,
  chunk : @engine.DataChunk,
) -> @engine.Vector raise ExecuteError {
  match expr {
    @plan.PlanExpr::ColumnRef(column_ref) => chunk.columns[column_ref.index]
    @plan.PlanExpr::StringLiteral(text) =>
      constant_vector(@engine.Value::Varchar(text), chunk.len)
    @plan.PlanExpr::IntegerLiteral(text) =>
      constant_vector(
        @engine.Value::BigInt(
          @strconv.parse_int64(text[:]) catch {
            _ => raise ExecuteError::Execute("invalid integer literal: \{text}")
          },
        ),
        chunk.len,
      )
    @plan.PlanExpr::DoubleLiteral(text) =>
      constant_vector(
        @engine.Value::Double(
          @strconv.parse_double(text[:]) catch {
            _ => raise ExecuteError::Execute("invalid double literal: \{text}")
          },
        ),
        chunk.len,
      )
    @plan.PlanExpr::BooleanLiteral(value) =>
      constant_vector(@engine.Value::Boolean(value), chunk.len)
    @plan.PlanExpr::NullLiteral =>
      constant_vector(@engine.Value::Null, chunk.len)
    @plan.PlanExpr::Unary(op, inner) => {
      let inner_vector = eval_expr_to_vector(inner, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(eval_unary(op, vector_value_at(inner_vector, row_index)))
      }
      build_vector_from_values(
        infer_unary_type(op, inner_vector.logical_type),
        values,
      )
    }
    @plan.PlanExpr::Binary(op, left, right) => {
      let left_vector = eval_expr_to_vector(left, chunk)
      let right_vector = eval_expr_to_vector(right, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(
          eval_binary(
            op,
            vector_value_at(left_vector, row_index),
            vector_value_at(right_vector, row_index),
          ),
        )
      }
      build_vector_from_values(
        infer_binary_type(
          op,
          left_vector.logical_type,
          right_vector.logical_type,
        ),
        values,
      )
    }
    @plan.PlanExpr::IsNull(inner) => {
      let inner_vector = eval_expr_to_vector(inner, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(
          @engine.Value::Boolean(
            match vector_value_at(inner_vector, row_index) {
              @engine.Value::Null => true
              _ => false
            },
          ),
        )
      }
      build_vector_from_values(@engine.LogicalType::Boolean, values)
    }
    @plan.PlanExpr::IsNotNull(inner) => {
      let inner_vector = eval_expr_to_vector(inner, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(
          @engine.Value::Boolean(
            match vector_value_at(inner_vector, row_index) {
              @engine.Value::Null => false
              _ => true
            },
          ),
        )
      }
      build_vector_from_values(@engine.LogicalType::Boolean, values)
    }
    @plan.PlanExpr::Cast(inner, logical_type) => {
      let inner_vector = eval_expr_to_vector(inner, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(
          cast_value(vector_value_at(inner_vector, row_index), logical_type),
        )
      }
      build_vector_from_values(logical_type, values)
    }
  }
}

///|
fn infer_unary_type(
  op : @sql.UnaryOp,
  inner_type : @engine.LogicalType,
) -> @engine.LogicalType {
  match op {
    @sql.UnaryOp::Not => @engine.LogicalType::Boolean
    @sql.UnaryOp::Plus | @sql.UnaryOp::Minus => inner_type
  }
}

///|
fn infer_binary_type(
  op : @sql.BinaryOp,
  left_type : @engine.LogicalType,
  right_type : @engine.LogicalType,
) -> @engine.LogicalType {
  match op {
    @sql.BinaryOp::And | @sql.BinaryOp::Or => @engine.LogicalType::Boolean
    @sql.BinaryOp::Add
    | @sql.BinaryOp::Subtract
    | @sql.BinaryOp::Multiply
    | @sql.BinaryOp::Divide =>
      match (left_type, right_type) {
        (@engine.LogicalType::Double, _) => @engine.LogicalType::Double
        (_, @engine.LogicalType::Double) => @engine.LogicalType::Double
        (@engine.LogicalType::Null, other) => other
        (other, @engine.LogicalType::Null) => other
        _ => @engine.LogicalType::BigInt
      }
    _ => @engine.LogicalType::Boolean
  }
}

///|
fn constant_vector(value : @engine.Value, len : Int) -> @engine.Vector {
  match value {
    @engine.Value::Null =>
      @engine.Vector::{
        logical_type: @engine.LogicalType::Null,
        values: @engine.VectorBuffer::Nulls(len),
        validity: @engine.ValidityMask::all_null(len),
      }
    @engine.Value::Boolean(value) => {
      let values = []
      for _ in 0..<len {
        values.push(value)
      }
      @engine.Vector::{
        logical_type: @engine.LogicalType::Boolean,
        values: @engine.VectorBuffer::Bool(values),
        validity: @engine.ValidityMask::all_valid(len),
      }
    }
    @engine.Value::BigInt(value) => {
      let values = []
      for _ in 0..<len {
        values.push(value)
      }
      @engine.Vector::{
        logical_type: @engine.LogicalType::BigInt,
        values: @engine.VectorBuffer::Int64(values),
        validity: @engine.ValidityMask::all_valid(len),
      }
    }
    @engine.Value::Double(value) => {
      let values = []
      for _ in 0..<len {
        values.push(value)
      }
      @engine.Vector::{
        logical_type: @engine.LogicalType::Double,
        values: @engine.VectorBuffer::Double(values),
        validity: @engine.ValidityMask::all_valid(len),
      }
    }
    @engine.Value::Varchar(value) => {
      let values = []
      for _ in 0..<len {
        values.push(value)
      }
      @engine.Vector::{
        logical_type: @engine.LogicalType::Varchar,
        values: @engine.VectorBuffer::Varchar(values),
        validity: @engine.ValidityMask::all_valid(len),
      }
    }
  }
}

///|
fn build_vector_from_values(
  logical_type : @engine.LogicalType,
  values : Array[@engine.Value],
) -> @engine.Vector raise ExecuteError {
  match logical_type {
    @engine.LogicalType::Null =>
      @engine.Vector::{
        logical_type,
        values: @engine.VectorBuffer::Nulls(values.length()),
        validity: @engine.ValidityMask::all_null(values.length()),
      }
    @engine.LogicalType::Boolean => build_bool_vector(values)
    @engine.LogicalType::BigInt => build_int64_vector(values)
    @engine.LogicalType::Double => build_double_vector(values)
    @engine.LogicalType::Varchar => build_varchar_vector(values)
  }
}

///|
fn build_bool_vector(
  values : Array[@engine.Value],
) -> @engine.Vector raise ExecuteError {
  let buffer = []
  let validity = []
  for value in values {
    match value {
      @engine.Value::Null => {
        buffer.push(false)
        validity.push(false)
      }
      @engine.Value::Boolean(value) => {
        buffer.push(value)
        validity.push(true)
      }
      _ => raise ExecuteError::Execute("expected BOOLEAN expression result")
    }
  }
  @engine.Vector::{
    logical_type: @engine.LogicalType::Boolean,
    values: @engine.VectorBuffer::Bool(buffer),
    validity: @engine.ValidityMask::new(validity),
  }
}

///|
fn build_int64_vector(
  values : Array[@engine.Value],
) -> @engine.Vector raise ExecuteError {
  let buffer = []
  let validity = []
  for value in values {
    match value {
      @engine.Value::Null => {
        buffer.push(0L)
        validity.push(false)
      }
      @engine.Value::BigInt(value) => {
        buffer.push(value)
        validity.push(true)
      }
      _ => raise ExecuteError::Execute("expected BIGINT expression result")
    }
  }
  @engine.Vector::{
    logical_type: @engine.LogicalType::BigInt,
    values: @engine.VectorBuffer::Int64(buffer),
    validity: @engine.ValidityMask::new(validity),
  }
}

///|
fn build_double_vector(
  values : Array[@engine.Value],
) -> @engine.Vector raise ExecuteError {
  let buffer = []
  let validity = []
  for value in values {
    match value {
      @engine.Value::Null => {
        buffer.push(0.0)
        validity.push(false)
      }
      @engine.Value::Double(value) => {
        buffer.push(value)
        validity.push(true)
      }
      _ => raise ExecuteError::Execute("expected DOUBLE expression result")
    }
  }
  @engine.Vector::{
    logical_type: @engine.LogicalType::Double,
    values: @engine.VectorBuffer::Double(buffer),
    validity: @engine.ValidityMask::new(validity),
  }
}

///|
fn build_varchar_vector(
  values : Array[@engine.Value],
) -> @engine.Vector raise ExecuteError {
  let buffer = []
  let validity = []
  for value in values {
    match value {
      @engine.Value::Null => {
        buffer.push("")
        validity.push(false)
      }
      @engine.Value::Varchar(value) => {
        buffer.push(value)
        validity.push(true)
      }
      _ => raise ExecuteError::Execute("expected VARCHAR expression result")
    }
  }
  @engine.Vector::{
    logical_type: @engine.LogicalType::Varchar,
    values: @engine.VectorBuffer::Varchar(buffer),
    validity: @engine.ValidityMask::new(validity),
  }
}

///|
fn take_vector(
  vector : @engine.Vector,
  indices : Array[Int],
) -> @engine.Vector raise ExecuteError {
  let values = []
  for index in indices {
    values.push(vector_value_at(vector, index))
  }
  build_vector_from_values(vector.logical_type, values)
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
    @scan.ScanError::CsvMalformed(message) => ExecuteError::Scan(message)
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

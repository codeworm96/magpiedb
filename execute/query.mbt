///|
priv enum AggregateState {
  Count(Int64)
  SumInt64(Int64, Bool)
  SumDouble(Double, Bool)
  Avg(Double, Int64)
  Min(@engine.Value)
  Max(@engine.Value)
}

///|
pub struct QueryOutput {
  schema : @engine.Schema
  chunks : Array[@engine.DataChunk]
} derive(Eq, Debug)

///|
pub suberror ExecuteError {
  InvalidArgument(String)
  Bind(String)
  Scan(String)
  Io(String)
  Execute(String)
  Unsupported(String)
} derive(Debug)

///|
pub fn execute_query(query : @sql.Query) -> QueryOutput raise ExecuteError {
  let plan = @plan.plan_query(query) catch { err => raise map_plan_error(err) }
  execute_plan(plan)
}

///|
pub fn execute_plan(plan : @plan.QueryPlan) -> QueryOutput raise ExecuteError {
  let chunks = execute_plan_chunks(plan)
  QueryOutput::{ schema: @plan.query_plan_schema(plan), chunks }
}

///|
fn execute_plan_chunks(
  plan : @plan.QueryPlan,
) -> Array[@engine.DataChunk] raise ExecuteError {
  match plan {
    @plan.QueryPlan::Scan(scan_plan) => scan_source_chunks(scan_plan.source)
    @plan.QueryPlan::Join(join_plan) => join_plan_chunks(join_plan)
    @plan.QueryPlan::Filter(filter_plan) =>
      filter_plan_chunks(filter_plan.input, filter_plan.predicate)
    @plan.QueryPlan::Aggregate(aggregate_plan) =>
      aggregate_plan_chunks(aggregate_plan)
    @plan.QueryPlan::Projection(projection_plan) =>
      project_plan_chunks(
        projection_plan.input,
        projection_plan.projections,
        projection_plan.output_schema,
      )
  }
}

///|
fn scan_source_chunks(
  source : @plan.ScanSource,
) -> Array[@engine.DataChunk] raise ExecuteError {
  match source {
    @plan.ScanSource::Csv(scan) => {
      let scanner = @scan.read_csv(scan.path) catch {
        err => raise map_scan_error(err)
      }
      collect_csv_chunks(scanner)
    }
    @plan.ScanSource::Jsonl(scan) => {
      let scanner = @scan.read_jsonl(scan.path) catch {
        err => raise map_scan_error(err)
      }
      collect_jsonl_chunks(scanner)
    }
  }
}

///|
fn collect_csv_chunks(
  scanner : @scan.CsvScanner,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let chunks = []
  while true {
    let next_chunk = scanner.next_chunk() catch {
      err => raise map_scan_error(err)
    }
    match next_chunk {
      Some(chunk) => chunks.push(chunk)
      None => break
    }
  }
  chunks
}

///|
fn collect_jsonl_chunks(
  scanner : @scan.JsonlScanner,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let chunks = []
  while true {
    let next_chunk = scanner.next_chunk() catch {
      err => raise map_scan_error(err)
    }
    match next_chunk {
      Some(chunk) => chunks.push(chunk)
      None => break
    }
  }
  chunks
}

///|
fn filter_plan_chunks(
  input : @plan.QueryPlan,
  predicate : @plan.PlanExpr,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let output = []
  for chunk in execute_plan_chunks(input) {
    let filtered = filter_chunk(chunk, predicate)
    if !filtered.is_empty() {
      output.push(filtered)
    }
  }
  output
}

///|
fn project_plan_chunks(
  input : @plan.QueryPlan,
  projections : Array[@plan.PlanSelectItem],
  output_schema : @engine.Schema,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let output = []
  for chunk in execute_plan_chunks(input) {
    output.push(project_chunk(chunk, projections, output_schema))
  }
  output
}

///|
fn aggregate_plan_chunks(
  aggregate_plan : @plan.AggregatePlan,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let input_chunks = execute_plan_chunks(aggregate_plan.input)
  let group_indices : Map[String, Int] = {}
  let group_values = []
  let group_states = []

  if aggregate_plan.group_keys.length() == 0 {
    group_indices[""] = 0
    group_values.push([])
    group_states.push(init_aggregate_states(aggregate_plan.aggregates))
  }

  for chunk in input_chunks {
    let group_vectors = []
    for group_key in aggregate_plan.group_keys {
      group_vectors.push(chunk.columns[group_key.index])
    }
    let aggregate_input_vectors = []
    for aggregate in aggregate_plan.aggregates {
      match aggregate.input_expr {
        Some(expr) =>
          aggregate_input_vectors.push(Some(eval_expr_to_vector(expr, chunk)))
        None => aggregate_input_vectors.push(None)
      }
    }

    for row_index in 0..<chunk.len {
      let group_index = if aggregate_plan.group_keys.length() == 0 {
        0
      } else {
        let key_values = []
        for vector in group_vectors {
          key_values.push(vector_value_at(vector, row_index))
        }
        let key = encode_group_key(key_values)
        match group_indices.get(key) {
          Some(index) => index
          None => {
            let index = group_values.length()
            group_indices[key] = index
            group_values.push(key_values)
            group_states.push(init_aggregate_states(aggregate_plan.aggregates))
            index
          }
        }
      }
      let states = group_states[group_index]
      for aggregate_index in 0..<aggregate_plan.aggregates.length() {
        let aggregate = aggregate_plan.aggregates[aggregate_index]
        let next_state = match aggregate_input_vectors[aggregate_index] {
          Some(vector) =>
            update_aggregate_state(
              states[aggregate_index],
              aggregate.kind,
              Some(vector_value_at(vector, row_index)),
            )
          None =>
            update_aggregate_state(
              states[aggregate_index],
              aggregate.kind,
              None,
            )
        }
        states[aggregate_index] = next_state
      }
    }
  }

  if aggregate_plan.group_keys.length() > 0 && group_values.length() == 0 {
    return []
  }

  let rows = []
  for group_index in 0..<group_values.length() {
    let row = []
    for value in group_values[group_index] {
      row.push(value)
    }
    for state in group_states[group_index] {
      row.push(finalize_aggregate_state(state))
    }
    rows.push(row)
  }
  rows_to_chunks(aggregate_plan.output_schema, rows)
}

///|
fn join_plan_chunks(
  join_plan : @plan.JoinPlan,
) -> Array[@engine.DataChunk] raise ExecuteError {
  match join_plan.join_kind {
    @sql.JoinKind::Inner => inner_join_plan_chunks(join_plan)
  }
}

///|
fn inner_join_plan_chunks(
  join_plan : @plan.JoinPlan,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let left_chunks = execute_plan_chunks(join_plan.left)
  let right_chunks = execute_plan_chunks(join_plan.right)
  let right_rows = chunks_to_rows(right_chunks)
  let right_indices : Map[String, Array[Int]] = {}

  for index in 0..<right_rows.length() {
    let key = encode_join_key(
      right_rows[index][join_plan.right_key.index],
      join_plan.left_key.column.data_type,
      join_plan.right_key.column.data_type,
    )
    match key {
      Some(key) =>
        match right_indices.get(key) {
          Some(indices) => indices.push(index)
          None => right_indices[key] = [index]
        }
      None => ()
    }
  }

  let output_rows = []
  for left_chunk in left_chunks {
    for left_row_index in 0..<left_chunk.len {
      let left_row = chunk_row_at(left_chunk, left_row_index)
      let key = encode_join_key(
        left_row[join_plan.left_key.index],
        join_plan.left_key.column.data_type,
        join_plan.right_key.column.data_type,
      )
      match key {
        Some(key) =>
          match right_indices.get(key) {
            Some(indices) =>
              for index in indices {
                let joined_row = []
                for value in left_row {
                  joined_row.push(value)
                }
                for value in right_rows[index] {
                  joined_row.push(value)
                }
                output_rows.push(joined_row)
              }
            None => ()
          }
        None => ()
      }
    }
  }

  rows_to_chunks(join_plan.output_schema, output_rows)
}

///|
fn init_aggregate_states(
  aggregates : Array[@plan.AggregateDef],
) -> Array[AggregateState] {
  let states = []
  for aggregate in aggregates {
    states.push(init_aggregate_state(aggregate))
  }
  states
}

///|
fn init_aggregate_state(aggregate : @plan.AggregateDef) -> AggregateState {
  match aggregate.kind {
    @plan.AggregateKind::CountStar | @plan.AggregateKind::Count =>
      AggregateState::Count(0L)
    @plan.AggregateKind::Sum =>
      match aggregate.result_column.data_type {
        @engine.LogicalType::BigInt => AggregateState::SumInt64(0L, false)
        _ => AggregateState::SumDouble(0.0, false)
      }
    @plan.AggregateKind::Avg => AggregateState::Avg(0.0, 0L)
    @plan.AggregateKind::Min => AggregateState::Min(@engine.Value::Null)
    @plan.AggregateKind::Max => AggregateState::Max(@engine.Value::Null)
  }
}

///|
fn update_aggregate_state(
  state : AggregateState,
  kind : @plan.AggregateKind,
  value : @engine.Value?,
) -> AggregateState raise ExecuteError {
  match (kind, state, value) {
    (@plan.AggregateKind::CountStar, AggregateState::Count(count), _) =>
      AggregateState::Count(count + 1L)
    (
      @plan.AggregateKind::Count,
      AggregateState::Count(count),
      Some(@engine.Value::Null),
    )
    | (@plan.AggregateKind::Count, AggregateState::Count(count), None) =>
      AggregateState::Count(count)
    (@plan.AggregateKind::Count, AggregateState::Count(count), Some(_)) =>
      AggregateState::Count(count + 1L)
    (
      @plan.AggregateKind::Sum,
      AggregateState::SumInt64(sum, _),
      Some(@engine.Value::BigInt(v)),
    ) => AggregateState::SumInt64(sum + v, true)
    (
      @plan.AggregateKind::Sum,
      AggregateState::SumInt64(sum, seen),
      Some(@engine.Value::Null),
    )
    | (@plan.AggregateKind::Sum, AggregateState::SumInt64(sum, seen), None) =>
      AggregateState::SumInt64(sum, seen)
    (
      @plan.AggregateKind::Sum,
      AggregateState::SumDouble(sum, _),
      Some(@engine.Value::BigInt(v)),
    ) => AggregateState::SumDouble(sum + v.to_double(), true)
    (
      @plan.AggregateKind::Sum,
      AggregateState::SumDouble(sum, _),
      Some(@engine.Value::Double(v)),
    ) => AggregateState::SumDouble(sum + v, true)
    (
      @plan.AggregateKind::Sum,
      AggregateState::SumDouble(sum, seen),
      Some(@engine.Value::Null),
    )
    | (@plan.AggregateKind::Sum, AggregateState::SumDouble(sum, seen), None) =>
      AggregateState::SumDouble(sum, seen)
    (
      @plan.AggregateKind::Avg,
      AggregateState::Avg(sum, count),
      Some(@engine.Value::BigInt(v)),
    ) => AggregateState::Avg(sum + v.to_double(), count + 1L)
    (
      @plan.AggregateKind::Avg,
      AggregateState::Avg(sum, count),
      Some(@engine.Value::Double(v)),
    ) => AggregateState::Avg(sum + v, count + 1L)
    (
      @plan.AggregateKind::Avg,
      AggregateState::Avg(sum, count),
      Some(@engine.Value::Null),
    )
    | (@plan.AggregateKind::Avg, AggregateState::Avg(sum, count), None) =>
      AggregateState::Avg(sum, count)
    (@plan.AggregateKind::Min, AggregateState::Min(current), Some(value)) =>
      AggregateState::Min(update_extreme_value(current, value, true))
    (@plan.AggregateKind::Min, AggregateState::Min(current), None) =>
      AggregateState::Min(current)
    (@plan.AggregateKind::Max, AggregateState::Max(current), Some(value)) =>
      AggregateState::Max(update_extreme_value(current, value, false))
    (@plan.AggregateKind::Max, AggregateState::Max(current), None) =>
      AggregateState::Max(current)
    _ => raise ExecuteError::Execute("invalid aggregate state update")
  }
}

///|
fn update_extreme_value(
  current : @engine.Value,
  next : @engine.Value,
  choose_min : Bool,
) -> @engine.Value raise ExecuteError {
  guard next != @engine.Value::Null else { return current }
  guard current != @engine.Value::Null else { return next }
  let ordering = compare_values(current, next)
  if choose_min {
    if ordering <= 0 {
      current
    } else {
      next
    }
  } else if ordering >= 0 {
    current
  } else {
    next
  }
}

///|
fn compare_values(
  left : @engine.Value,
  right : @engine.Value,
) -> Int raise ExecuteError {
  match (left, right) {
    (@engine.Value::Boolean(l), @engine.Value::Boolean(r)) =>
      if l == r {
        0
      } else if !l && r {
        -1
      } else {
        1
      }
    (@engine.Value::BigInt(l), @engine.Value::BigInt(r)) =>
      if l < r {
        -1
      } else if l > r {
        1
      } else {
        0
      }
    (@engine.Value::Double(l), @engine.Value::Double(r)) =>
      if l < r {
        -1
      } else if l > r {
        1
      } else {
        0
      }
    (@engine.Value::Varchar(l), @engine.Value::Varchar(r)) =>
      l.lexical_compare(r)
    _ => raise ExecuteError::Execute("invalid aggregate comparison")
  }
}

///|
fn finalize_aggregate_state(state : AggregateState) -> @engine.Value {
  match state {
    AggregateState::Count(count) => @engine.Value::BigInt(count)
    AggregateState::SumInt64(sum, seen) =>
      if seen {
        @engine.Value::BigInt(sum)
      } else {
        @engine.Value::Null
      }
    AggregateState::SumDouble(sum, seen) =>
      if seen {
        @engine.Value::Double(sum)
      } else {
        @engine.Value::Null
      }
    AggregateState::Avg(sum, count) =>
      if count == 0L {
        @engine.Value::Null
      } else {
        @engine.Value::Double(sum / count.to_double())
      }
    AggregateState::Min(value) | AggregateState::Max(value) => value
  }
}

///|
fn encode_group_key(values : Array[@engine.Value]) -> String {
  let parts = []
  for value in values {
    parts.push(encode_group_key_part(value))
  }
  parts.join("|")
}

///|
fn encode_group_key_part(value : @engine.Value) -> String {
  match value {
    @engine.Value::Null => "n:"
    @engine.Value::Boolean(v) => "b:\{v}"
    @engine.Value::BigInt(v) => "i:\{v}"
    @engine.Value::Double(v) => "d:\{v}"
    @engine.Value::Varchar(v) => "s:\{v}"
  }
}

///|
fn chunks_to_rows(
  chunks : Array[@engine.DataChunk],
) -> Array[Array[@engine.Value]] {
  let rows = []
  for chunk in chunks {
    for row_index in 0..<chunk.len {
      rows.push(chunk_row_at(chunk, row_index))
    }
  }
  rows
}

///|
fn chunk_row_at(
  chunk : @engine.DataChunk,
  row_index : Int,
) -> Array[@engine.Value] {
  let row = []
  for column in chunk.columns {
    row.push(vector_value_at(column, row_index))
  }
  row
}

///|
fn encode_join_key(
  value : @engine.Value,
  left_type : @engine.LogicalType,
  right_type : @engine.LogicalType,
) -> String? raise ExecuteError {
  guard value != @engine.Value::Null else { return None }
  if is_mixed_numeric_join(left_type, right_type) {
    Some("n:\{value_to_double(value)}")
  } else {
    Some(encode_join_key_part(value))
  }
}

///|
fn is_mixed_numeric_join(
  left_type : @engine.LogicalType,
  right_type : @engine.LogicalType,
) -> Bool {
  match (left_type, right_type) {
    (@engine.LogicalType::BigInt, @engine.LogicalType::Double)
    | (@engine.LogicalType::Double, @engine.LogicalType::BigInt) => true
    _ => false
  }
}

///|
fn encode_join_key_part(value : @engine.Value) -> String {
  match value {
    @engine.Value::Null => "n"
    @engine.Value::Boolean(v) => if v { "b:1" } else { "b:0" }
    @engine.Value::BigInt(v) => "i:\{v}"
    @engine.Value::Double(v) => "d:\{v}"
    @engine.Value::Varchar(v) => "s:\{v.length()}:\{v}"
  }
}

///|
fn rows_to_chunks(
  schema : @engine.Schema,
  rows : Array[Array[@engine.Value]],
) -> Array[@engine.DataChunk] raise ExecuteError {
  if rows.length() == 0 {
    return []
  }
  let chunks = []
  let mut start = 0
  while start < rows.length() {
    let remaining = rows.length() - start
    let len = if remaining > @engine.fixed_vector_size {
      @engine.fixed_vector_size
    } else {
      remaining
    }
    let columns = []
    for column_index in 0..<schema.columns.length() {
      let values = []
      for row_index in start..<(start + len) {
        values.push(rows[row_index][column_index])
      }
      columns.push(
        build_vector_from_values(schema.columns[column_index].data_type, values),
      )
    }
    chunks.push(@engine.DataChunk::{ schema, columns, len })
    start += len
  }
  chunks
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
        raise ExecuteError::Execute(
          "filter predicate did not evaluate to BOOLEAN",
        )
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
          @string.parse_int64(text[:]) catch {
            _ => raise ExecuteError::Execute("invalid integer literal: \{text}")
          },
        ),
        chunk.len,
      )
    @plan.PlanExpr::DoubleLiteral(text) =>
      constant_vector(
        @engine.Value::Double(
          @string.parse_double(text[:]) catch {
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
    @sql.BinaryOp::Divide => @engine.LogicalType::Double
    @sql.BinaryOp::Add | @sql.BinaryOp::Subtract | @sql.BinaryOp::Multiply =>
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
        @string.parse_int64(text[:]) catch {
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
        @string.parse_double(text[:]) catch {
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

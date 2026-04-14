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
priv enum ExecuteErrorKind {
  InvalidArgument
  Bind
  Scan
  Io
  Unsupported
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
    @plan.QueryPlan::Sort(sort_plan) => sort_plan_chunks(sort_plan)
    @plan.QueryPlan::Limit(limit_plan) => limit_plan_chunks(limit_plan)
  }
}

///|
fn scan_source_chunks(
  source : @plan.ScanSource,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let (kind, path) = planned_source_open_info(source)
  let scanner = @scan.open_source(kind, path) catch {
    err => raise map_scan_error(err)
  }
  collect_scan_chunks(scanner)
}

///|
fn planned_source_open_info(
  source : @plan.ScanSource,
) -> (@scan.ScanSourceKind, String) {
  match source {
    @plan.ScanSource::Csv(scan) => (@scan.ScanSourceKind::Csv, scan.path)
    @plan.ScanSource::Jsonl(scan) => (@scan.ScanSourceKind::Jsonl, scan.path)
  }
}

///|
fn collect_scan_chunks(
  source : @scan.Scanner,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let chunks = []
  while true {
    let next_chunk = source.next_chunk() catch {
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
fn sort_plan_chunks(
  sort_plan : @plan.SortPlan,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let rows = chunks_to_rows(execute_plan_chunks(sort_plan.input))
  let indices = []
  for index in 0..<rows.length() {
    indices.push(index)
  }
  stable_sort_row_indices(indices, rows, sort_plan.items)
  let sorted_rows = []
  for index in indices {
    sorted_rows.push(rows[index])
  }
  rows_to_chunks(sort_plan.output_schema, sorted_rows)
}

///|
fn limit_plan_chunks(
  limit_plan : @plan.LimitPlan,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let rows = chunks_to_rows(execute_plan_chunks(limit_plan.input))
  let limited_rows = []
  let take_count = if limit_plan.limit < rows.length() {
    limit_plan.limit
  } else {
    rows.length()
  }
  for index in 0..<take_count {
    limited_rows.push(rows[index])
  }
  rows_to_chunks(@plan.query_plan_schema(limit_plan.input), limited_rows)
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
fn stable_sort_row_indices(
  indices : Array[Int],
  rows : Array[Array[@engine.Value]],
  items : Array[@plan.PlanOrderByItem],
) -> Unit raise ExecuteError {
  let len = indices.length()
  if len <= 1 {
    return
  }
  let mut i = 1
  while i < len {
    let current = indices[i]
    let mut j = i
    while j > 0 &&
          compare_sorted_rows(rows[current], rows[indices[j - 1]], items) < 0 {
      indices[j] = indices[j - 1]
      j -= 1
    }
    indices[j] = current
    i += 1
  }
}

///|
fn compare_sorted_rows(
  left_row : Array[@engine.Value],
  right_row : Array[@engine.Value],
  items : Array[@plan.PlanOrderByItem],
) -> Int raise ExecuteError {
  for item in items {
    let left_value = eval_sort_expr_on_row(item.expr, left_row)
    let right_value = eval_sort_expr_on_row(item.expr, right_row)
    let ordering = compare_sort_values(left_value, right_value, item.direction)
    if ordering != 0 {
      return ordering
    }
  }
  0
}

///|
fn eval_sort_expr_on_row(
  expr : @plan.PlanExpr,
  row : Array[@engine.Value],
) -> @engine.Value raise ExecuteError {
  match expr {
    @plan.PlanExpr::ColumnRef(column_ref) => row[column_ref.index]
    _ => eval_expr_scalar(expr, row)
  }
}

///|
fn compare_sort_values(
  left : @engine.Value,
  right : @engine.Value,
  direction : @sql.SortDirection,
) -> Int raise ExecuteError {
  match (left, right) {
    (@engine.Value::Null, @engine.Value::Null) => 0
    (@engine.Value::Null, _) => 1
    (_, @engine.Value::Null) => -1
    (@engine.Value::BigInt(_), @engine.Value::Double(_))
    | (@engine.Value::Double(_), @engine.Value::BigInt(_)) => {
      let left_value = value_to_double(left)
      let right_value = value_to_double(right)
      let ordering = if left_value < right_value {
        -1
      } else if left_value > right_value {
        1
      } else {
        0
      }
      match direction {
        @sql.SortDirection::Asc => ordering
        @sql.SortDirection::Desc => -ordering
      }
    }
    _ => {
      let ordering = compare_values(left, right)
      match direction {
        @sql.SortDirection::Asc => ordering
        @sql.SortDirection::Desc => -ordering
      }
    }
  }
}

///|
fn eval_expr_scalar(
  expr : @plan.PlanExpr,
  row : Array[@engine.Value],
) -> @engine.Value raise ExecuteError {
  match expr {
    @plan.PlanExpr::ColumnRef(column_ref) => row[column_ref.index]
    @plan.PlanExpr::StringLiteral(text) => @engine.Value::Varchar(text)
    @plan.PlanExpr::IntegerLiteral(text) =>
      @engine.Value::BigInt(
        @string.parse_int64(text[:]) catch {
          _ => raise ExecuteError::Execute("invalid integer literal: \{text}")
        },
      )
    @plan.PlanExpr::DoubleLiteral(text) =>
      @engine.Value::Double(
        @string.parse_double(text[:]) catch {
          _ => raise ExecuteError::Execute("invalid double literal: \{text}")
        },
      )
    @plan.PlanExpr::BooleanLiteral(value) => @engine.Value::Boolean(value)
    @plan.PlanExpr::NullLiteral => @engine.Value::Null
    @plan.PlanExpr::Unary(op, inner) =>
      eval_unary(op, eval_expr_scalar(inner, row))
    @plan.PlanExpr::Binary(op, left, right) =>
      eval_binary(op, eval_expr_scalar(left, row), eval_expr_scalar(right, row))
    @plan.PlanExpr::IsNull(inner) =>
      @engine.Value::Boolean(
        match eval_expr_scalar(inner, row) {
          @engine.Value::Null => true
          _ => false
        },
      )
    @plan.PlanExpr::IsNotNull(inner) =>
      @engine.Value::Boolean(
        match eval_expr_scalar(inner, row) {
          @engine.Value::Null => false
          _ => true
        },
      )
    @plan.PlanExpr::Cast(inner, logical_type) =>
      cast_value(eval_expr_scalar(inner, row), logical_type)
  }
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
  match op {
    @sql.BinaryOp::And => eval_boolean_and(left, right)
    @sql.BinaryOp::Or => eval_boolean_or(left, right)
    _ => raise ExecuteError::Execute("invalid boolean operator")
  }
}

///|
fn eval_boolean_and(
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Boolean(false), _) | (_, @engine.Value::Boolean(false)) =>
      @engine.Value::Boolean(false)
    (@engine.Value::Boolean(true), @engine.Value::Boolean(true)) =>
      @engine.Value::Boolean(true)
    (@engine.Value::Boolean(true), @engine.Value::Null)
    | (@engine.Value::Null, @engine.Value::Boolean(true))
    | (@engine.Value::Null, @engine.Value::Null) => @engine.Value::Null
    _ =>
      raise ExecuteError::Execute("boolean operator requires BOOLEAN operands")
  }
}

///|
fn eval_boolean_or(
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Boolean(true), _) | (_, @engine.Value::Boolean(true)) =>
      @engine.Value::Boolean(true)
    (@engine.Value::Boolean(false), @engine.Value::Boolean(false)) =>
      @engine.Value::Boolean(false)
    (@engine.Value::Boolean(false), @engine.Value::Null)
    | (@engine.Value::Null, @engine.Value::Boolean(false))
    | (@engine.Value::Null, @engine.Value::Null) => @engine.Value::Null
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
  let (kind, message) = execute_error_parts_from_scan(err)
  map_execute_error(kind, message)
}

///|
fn map_plan_error(err : @plan.PlanError) -> ExecuteError {
  let (kind, message) = execute_error_parts_from_plan(err)
  map_execute_error(kind, message)
}

///|
fn execute_error_parts_from_scan(
  err : @scan.ScanError,
) -> (ExecuteErrorKind, String) {
  match err {
    @scan.ScanError::Io(message) => (ExecuteErrorKind::Io, message)
    @scan.ScanError::CsvMalformed(message) => (ExecuteErrorKind::Scan, message)
    @scan.ScanError::JsonParse(line_no, message) =>
      (
        ExecuteErrorKind::Scan,
        "json parse error at line \{line_no}: \{message}",
      )
    @scan.ScanError::JsonRootNotObject(line_no) =>
      (ExecuteErrorKind::Scan, "expected JSON object at line \{line_no}")
    @scan.ScanError::TypeMismatch(column, line_no, message) =>
      (
        ExecuteErrorKind::Scan,
        "type mismatch for column \{column} at line \{line_no}: \{message}",
      )
  }
}

///|
fn execute_error_parts_from_plan(
  err : @plan.PlanError,
) -> (ExecuteErrorKind, String) {
  match err {
    @plan.PlanError::InvalidArgument(message) =>
      (ExecuteErrorKind::InvalidArgument, message)
    @plan.PlanError::Bind(message) => (ExecuteErrorKind::Bind, message)
    @plan.PlanError::Scan(message) => (ExecuteErrorKind::Scan, message)
    @plan.PlanError::Io(message) => (ExecuteErrorKind::Io, message)
    @plan.PlanError::Unsupported(message) =>
      (ExecuteErrorKind::Unsupported, message)
  }
}

///|
fn map_execute_error(kind : ExecuteErrorKind, message : String) -> ExecuteError {
  match kind {
    ExecuteErrorKind::InvalidArgument => ExecuteError::InvalidArgument(message)
    ExecuteErrorKind::Bind => ExecuteError::Bind(message)
    ExecuteErrorKind::Scan => ExecuteError::Scan(message)
    ExecuteErrorKind::Io => ExecuteError::Io(message)
    ExecuteErrorKind::Unsupported => ExecuteError::Unsupported(message)
  }
}

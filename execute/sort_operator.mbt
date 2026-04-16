///|
async fn build_sort_operator(
  sort_plan : @plan.SortPlan,
) -> ChunkOperator raise ExecuteError {
  ChunkOperator::Sort(SortOperator::{
    input: build_operator(sort_plan.input),
    sort_plan,
    build_ready: false,
    output_chunks: [],
    next_index: 0,
  })
}

///|
async fn SortOperator::next_chunk(
  self : SortOperator,
) -> @engine.DataChunk? raise ExecuteError {
  self.ensure_build_ready()
  guard self.next_index < self.output_chunks.length() else { return None }
  let chunk = self.output_chunks[self.next_index]
  self.next_index += 1
  Some(chunk)
}

///|
async fn SortOperator::ensure_build_ready(
  self : SortOperator,
) -> Unit raise ExecuteError {
  guard !self.build_ready else { return }
  self.output_chunks = self.build_output_chunks()
  self.build_ready = true
}

///|
async fn SortOperator::build_output_chunks(
  self : SortOperator,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let rows = []
  while true {
    match self.input.next_chunk() {
      Some(chunk) =>
        for row_index in 0..<chunk.len {
          rows.push(chunk_row_at(chunk, row_index))
        }
      None => break
    }
  } nobreak {
    ()
  }
  let indices = []
  for index in 0..<rows.length() {
    indices.push(index)
  }
  stable_sort_row_indices(indices, rows, self.sort_plan.items)
  let sorted_rows = []
  for index in indices {
    sorted_rows.push(rows[index])
  }
  rows_to_chunks(self.sort_plan.output_schema, sorted_rows)
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

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
async fn build_aggregate_operator(
  aggregate_plan : @plan.AggregatePlan,
) -> ChunkOperator raise ExecuteError {
  ChunkOperator::Aggregate(AggregateOperator::{
    input: build_operator(aggregate_plan.input),
    aggregate_plan,
    build_ready: false,
    output_chunks: [],
    next_index: 0,
  })
}

///|
async fn AggregateOperator::next_chunk(
  self : AggregateOperator,
) -> @engine.DataChunk? raise ExecuteError {
  self.ensure_build_ready()
  guard self.next_index < self.output_chunks.length() else { return None }
  let chunk = self.output_chunks[self.next_index]
  self.next_index += 1
  Some(chunk)
}

///|
async fn AggregateOperator::ensure_build_ready(
  self : AggregateOperator,
) -> Unit raise ExecuteError {
  guard !self.build_ready else { return }
  self.output_chunks = self.build_output_chunks()
  self.build_ready = true
}

///|
async fn AggregateOperator::build_output_chunks(
  self : AggregateOperator,
) -> Array[@engine.DataChunk] raise ExecuteError {
  let group_indices : Map[String, Int] = {}
  let group_values = []
  let group_states = []

  if self.aggregate_plan.group_keys.length() == 0 {
    group_indices[""] = 0
    group_values.push([])
    group_states.push(init_aggregate_states(self.aggregate_plan.aggregates))
  }

  while true {
    match self.input.next_chunk() {
      Some(chunk) => {
        let group_vectors = []
        for group_key in self.aggregate_plan.group_keys {
          group_vectors.push(chunk.columns[group_key.index])
        }
        let aggregate_input_vectors = []
        for aggregate in self.aggregate_plan.aggregates {
          match aggregate.input_expr {
            Some(expr) =>
              aggregate_input_vectors.push(
                Some(eval_expr_to_vector(expr, chunk)),
              )
            None => aggregate_input_vectors.push(None)
          }
        }

        for row_index in 0..<chunk.len {
          let group_index = if self.aggregate_plan.group_keys.length() == 0 {
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
                group_states.push(
                  init_aggregate_states(self.aggregate_plan.aggregates),
                )
                index
              }
            }
          }
          let states = group_states[group_index]
          for aggregate_index in 0..<self.aggregate_plan.aggregates.length() {
            let aggregate = self.aggregate_plan.aggregates[aggregate_index]
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
      None => break
    }
  } nobreak {
    ()
  }

  if self.aggregate_plan.group_keys.length() > 0 && group_values.length() == 0 {
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
  rows_to_chunks(self.aggregate_plan.output_schema, rows)
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
    _ =>
      raise ExecuteError::Internal(
        "aggregate update received values that violate binder typing",
      )
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

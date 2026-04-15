///|
fn build_join_operator(
  join_plan : @plan.JoinPlan,
) -> ChunkOperator raise ExecuteError {
  ChunkOperator::Join(JoinOperator::{
    left: build_operator(join_plan.left),
    right: build_operator(join_plan.right),
    join_plan,
    build_ready: false,
    right_rows: [],
    right_indices: {},
    left_chunk: None,
    left_row_index: 0,
    pending_left_row: None,
    pending_match_indices: [],
    pending_match_index: 0,
  })
}

///|
fn JoinOperator::next_chunk(
  self : JoinOperator,
) -> @engine.DataChunk? raise ExecuteError {
  self.ensure_build_ready()
  let output_rows = []
  while output_rows.length() < @engine.fixed_vector_size {
    if self.pending_left_row is Some(left_row) {
      while self.pending_match_index < self.pending_match_indices.length() &&
            output_rows.length() < @engine.fixed_vector_size {
        let right_index = self.pending_match_indices[self.pending_match_index]
        output_rows.push(join_rows(left_row, self.right_rows[right_index]))
        self.pending_match_index += 1
      }
      if self.pending_match_index >= self.pending_match_indices.length() {
        self.pending_left_row = None
        self.pending_match_indices = []
        self.pending_match_index = 0
        continue
      }
      break
    }
    match self.next_left_row() {
      Some(left_row) => {
        let match_indices = self.lookup_match_indices(left_row)
        if match_indices.length() == 0 {
          continue
        }
        self.pending_left_row = Some(left_row)
        self.pending_match_indices = match_indices
        self.pending_match_index = 0
      }
      None => break
    }
  } nobreak {
    ()
  }
  if output_rows.length() == 0 {
    None
  } else {
    Some(rows_to_chunks(self.join_plan.output_schema, output_rows)[0])
  }
}

///|
fn JoinOperator::ensure_build_ready(
  self : JoinOperator,
) -> Unit raise ExecuteError {
  guard !self.build_ready else { return }
  while true {
    match self.right.next_chunk() {
      Some(chunk) =>
        for row_index in 0..<chunk.len {
          let row = chunk_row_at(chunk, row_index)
          let index = self.right_rows.length()
          let key = encode_join_key(
            row[self.join_plan.right_key.index],
            self.join_plan.left_key.column.data_type,
            self.join_plan.right_key.column.data_type,
          )
          self.right_rows.push(row)
          match key {
            Some(key) =>
              match self.right_indices.get(key) {
                Some(indices) => indices.push(index)
                None => self.right_indices[key] = [index]
              }
            None => ()
          }
        }
      None => break
    }
  } nobreak {
    ()
  }
  self.build_ready = true
}

///|
fn JoinOperator::next_left_row(
  self : JoinOperator,
) -> Array[@engine.Value]? raise ExecuteError {
  while true {
    if self.left_chunk is Some(chunk) {
      if self.left_row_index < chunk.len {
        let row = chunk_row_at(chunk, self.left_row_index)
        self.left_row_index += 1
        return Some(row)
      }
      self.left_chunk = None
      continue
    }
    match self.left.next_chunk() {
      Some(chunk) => {
        if chunk.is_empty() {
          continue
        }
        self.left_chunk = Some(chunk)
        self.left_row_index = 0
      }
      None => return None
    }
  } nobreak {
    None
  }
}

///|
fn JoinOperator::lookup_match_indices(
  self : JoinOperator,
  left_row : Array[@engine.Value],
) -> Array[Int] raise ExecuteError {
  let key = encode_join_key(
    left_row[self.join_plan.left_key.index],
    self.join_plan.left_key.column.data_type,
    self.join_plan.right_key.column.data_type,
  )
  match key {
    Some(key) =>
      match self.right_indices.get(key) {
        Some(indices) => indices
        None => []
      }
    None => []
  }
}

///|
fn join_rows(
  left_row : Array[@engine.Value],
  right_row : Array[@engine.Value],
) -> Array[@engine.Value] {
  let joined_row = []
  for value in left_row {
    joined_row.push(value)
  }
  for value in right_row {
    joined_row.push(value)
  }
  joined_row
}

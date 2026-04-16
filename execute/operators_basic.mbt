///|
async fn build_scan_operator(
  source : @plan.ScanSource,
) -> ChunkOperator raise ExecuteError {
  let (kind, path, schema) = planned_source_open_info(source)
  let scanner = @scan.open_source_with_schema(kind, path, schema) catch {
    err => raise map_scan_error(err)
  }
  ChunkOperator::Scan(ScanOperator::{ scanner, })
}

///|
async fn collect_operator_chunks(
  operator : ChunkOperator,
) -> Array[@engine.DataChunk] raise ExecuteError {
  defer operator.close()
  let chunks = []
  while true {
    match operator.next_chunk() {
      Some(chunk) => chunks.push(chunk)
      None => break
    }
  }
  chunks
}

///|
async fn ChunkOperator::next_chunk(
  self : ChunkOperator,
) -> @engine.DataChunk? raise ExecuteError {
  match self {
    Scan(operator) => operator.next_chunk()
    Filter(operator) => operator.next_chunk()
    Projection(operator) => operator.next_chunk()
    Aggregate(operator) => operator.next_chunk()
    Sort(operator) => operator.next_chunk()
    Join(operator) => operator.next_chunk()
    Limit(operator) => operator.next_chunk()
  }
}

///|
async fn ScanOperator::next_chunk(
  self : ScanOperator,
) -> @engine.DataChunk? raise ExecuteError {
  self.scanner.next_chunk() catch {
    err => raise map_scan_error(err)
  }
}

///|
fn ChunkOperator::close(self : ChunkOperator) -> Unit {
  match self {
    Scan(operator) => operator.scanner.close()
    Filter(operator) => operator.input.close()
    Projection(operator) => operator.input.close()
    Aggregate(operator) => operator.input.close()
    Sort(operator) => operator.input.close()
    Join(operator) => {
      operator.left.close()
      operator.right.close()
    }
    Limit(operator) => operator.input.close()
  }
}

///|
async fn FilterOperator::next_chunk(
  self : FilterOperator,
) -> @engine.DataChunk? raise ExecuteError {
  while true {
    match self.input.next_chunk() {
      Some(chunk) => {
        let filtered = filter_chunk(chunk, self.predicate)
        if !filtered.is_empty() {
          return Some(filtered)
        }
      }
      None => return None
    }
  } nobreak {
    None
  }
}

///|
async fn ProjectionOperator::next_chunk(
  self : ProjectionOperator,
) -> @engine.DataChunk? raise ExecuteError {
  match self.input.next_chunk() {
    Some(chunk) =>
      Some(project_chunk(chunk, self.projections, self.output_schema))
    None => None
  }
}

///|
async fn LimitOperator::next_chunk(
  self : LimitOperator,
) -> @engine.DataChunk? raise ExecuteError {
  guard self.remaining > 0 else { return None }
  while true {
    match self.input.next_chunk() {
      Some(chunk) => {
        if chunk.is_empty() {
          continue
        }
        if chunk.len <= self.remaining {
          self.remaining -= chunk.len
          return Some(chunk)
        }
        let limited = take_chunk_prefix(chunk, self.remaining)
        self.remaining = 0
        return Some(limited)
      }
      None => return None
    }
  } nobreak {
    None
  }
}

///|
fn take_chunk_prefix(
  chunk : @engine.DataChunk,
  len : Int,
) -> @engine.DataChunk raise ExecuteError {
  let indices = []
  for index in 0..<len {
    indices.push(index)
  }
  let columns = []
  for column in chunk.columns {
    columns.push(take_vector(column, indices))
  }
  @engine.DataChunk::{ schema: chunk.schema, columns, len }
}

///|
fn planned_source_open_info(
  source : @plan.ScanSource,
) -> (@scan.ScanSourceKind, String, @engine.Schema) {
  match source {
    @plan.ScanSource::Csv(scan) =>
      (@scan.ScanSourceKind::Csv, scan.path, scan.schema)
    @plan.ScanSource::Jsonl(scan) =>
      (@scan.ScanSourceKind::Jsonl, scan.path, scan.schema)
  }
}

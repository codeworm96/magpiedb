///|
fn chunk_row_at(
  chunk : @engine.DataChunk,
  row_index : Int,
) -> Array[@engine.Value] {
  @engine.chunk_row_at(chunk, row_index)
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
      _ =>
        raise ExecuteError::Internal(
          "vector materialization received non-BOOLEAN values for a BOOLEAN column",
        )
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
      _ =>
        raise ExecuteError::Internal(
          "vector materialization received non-BIGINT values for a BIGINT column",
        )
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
      _ =>
        raise ExecuteError::Internal(
          "vector materialization received non-DOUBLE values for a DOUBLE column",
        )
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
      _ =>
        raise ExecuteError::Internal(
          "vector materialization received non-VARCHAR values for a VARCHAR column",
        )
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
    values.push(@engine.vector_value_at(vector, index))
  }
  build_vector_from_values(vector.logical_type, values)
}

///|
fn vector_value_at(vector : @engine.Vector, row_index : Int) -> @engine.Value {
  @engine.vector_value_at(vector, row_index)
}

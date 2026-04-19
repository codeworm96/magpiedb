///|
/// The Parquet scan interface is pull-based so execution can consume one chunk at a time.
pub struct ParquetScanner {
  priv path : String
  priv schema : Schema
  priv mut data : @parquet.ParquetColumnarFile
  priv mut next_row_index : Int
  priv mut closed : Bool
}

///|
/// Full Parquet scan entrypoint uses the file metadata as the planned schema.
pub fn read_parquet(path : String) -> ParquetScanner raise ScanError {
  let data = open_parquet_file(path)
  let schema = parquet_schema_from_file(data)
  ParquetScanner::{ path, schema, data, next_row_index: 0, closed: false }
}

///|
/// Execution can reuse a planned schema and rematerialize the Parquet file on demand.
pub fn read_parquet_with_schema(
  path : String,
  schema : Schema,
) -> ParquetScanner raise ScanError {
  let data = open_parquet_file(path)
  validate_parquet_schema(schema, data)
  ParquetScanner::{ path, schema, data, next_row_index: 0, closed: false }
}

///|
/// Schema inference maps Parquet metadata into the engine's current scalar type set.
pub fn infer_parquet_schema(path : String) -> Schema raise ScanError {
  parquet_schema_from_file(open_parquet_file(path))
}

///|
/// `schema()` is stable across the full scan.
pub fn ParquetScanner::schema(self : ParquetScanner) -> Schema {
  self.schema
}

///|
pub fn ParquetScanner::close(self : ParquetScanner) -> Unit {
  self.next_row_index = self.data.row_count()
  self.closed = true
}

///|
/// Chunks are produced lazily from the loaded column buffers so execution stays vectorized.
pub fn ParquetScanner::next_chunk(
  self : ParquetScanner,
) -> DataChunk? raise ScanError {
  self.next_parquet_chunk() catch {
    err => {
      self.close()
      raise err
    }
  }
}

///|
fn ParquetScanner::next_parquet_chunk(
  self : ParquetScanner,
) -> DataChunk? raise ScanError {
  guard !self.closed else { return None }
  let row_count = self.data.row_count()
  guard self.next_row_index < row_count else {
    self.closed = true
    return None
  }
  let start = self.next_row_index
  let end = if start + fixed_vector_size < row_count {
    start + fixed_vector_size
  } else {
    row_count
  }
  let len = end - start
  let parquet_columns = self.data.column_data()
  let columns = []
  for column_index in 0..<self.schema.columns.length() {
    columns.push(
      build_parquet_vector(
        self.schema.columns[column_index],
        parquet_columns[column_index],
        start,
        len,
      ),
    )
  }
  self.next_row_index = end
  if self.next_row_index >= row_count {
    self.closed = true
  }
  Some(DataChunk::{ schema: self.schema, columns, len })
}

///|
/// Reset rematerializes the current Parquet file so later scans see the latest bytes on disk.
pub fn ParquetScanner::reset(self : ParquetScanner) -> Unit raise ScanError {
  self.close()
  let data = open_parquet_file(self.path)
  validate_parquet_schema(self.schema, data)
  self.data = data
  self.next_row_index = 0
  self.closed = false
}

///|
/// `scan_parquet` is the scanner constructor used by execution code.
pub fn scan_parquet(path : String) -> ParquetScanner raise ScanError {
  read_parquet(path)
}

///|
/// TODO: `mizchi/parquet` currently materializes the full file in memory before
/// MagpieDB can slice `DataChunk`s out of it. Keep this MVP path for now, but
/// revisit row-group/page streaming once the scan layer can hand off Parquet
/// ranges lazily.
fn open_parquet_file(
  path : String,
) -> @parquet.ParquetColumnarFile raise ScanError {
  @parquet.read_file_columnar(path) catch {
    @parquet.ParquetError::Io(message) => raise ScanError::Io(message)
    @parquet.ParquetError::InvalidData(message)
    | @parquet.ParquetError::Unsupported(message) =>
      raise ScanError::Parquet(message)
  }
}

///|
/// Convert Parquet column metadata into the engine's planned schema.
fn parquet_schema_from_file(
  data : @parquet.ParquetColumnarFile,
) -> Schema raise ScanError {
  let columns = []
  for column in data.columns() {
    let nullable = match column.repetition() {
      @parquet.Required => false
      @parquet.Optional => true
      @parquet.Repeated =>
        raise ScanError::Parquet(
          "repeated parquet columns are not supported: \{column.name()}",
        )
    }
    columns.push(ColumnDef::{
      name: column.name(),
      data_type: parquet_logical_type(column.column_type()),
      nullable,
    })
  }
  Schema::{ columns, }
}

///|
/// Validate that the runtime Parquet schema still matches the planned schema.
fn validate_parquet_schema(
  schema : Schema,
  data : @parquet.ParquetColumnarFile,
) -> Unit raise ScanError {
  guard schema == parquet_schema_from_file(data) else {
    raise ScanError::Parquet("parquet schema does not match planned schema")
  }
}

///|
/// Map Parquet physical/logical types into the engine's current scalar type set.
fn parquet_logical_type(column_type : @parquet.ColumnType) -> LogicalType {
  match column_type {
    @parquet.Boolean => LogicalType::Boolean
    @parquet.Int32 => LogicalType::BigInt
    @parquet.Int64 => LogicalType::BigInt
    @parquet.TimestampMicros => LogicalType::BigInt
    @parquet.Float => LogicalType::Double
    @parquet.Double => LogicalType::Double
    @parquet.String => LogicalType::Varchar
    @parquet.Binary => LogicalType::Varchar
  }
}

///|
/// Dispatch chunk materialization to the typed vector builder for one Parquet column.
fn build_parquet_vector(
  column : ColumnDef,
  parquet_column : @parquet.ParquetColumnData,
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  match column.data_type {
    LogicalType::Null => {
      let validity = ValidityMask::all_null(len)
      {
        logical_type: LogicalType::Null,
        values: VectorBuffer::Nulls(len),
        validity,
      }
    }
    LogicalType::Boolean =>
      build_parquet_bool_vector(column, parquet_column, start, len)
    LogicalType::BigInt =>
      build_parquet_int64_vector(column, parquet_column, start, len)
    LogicalType::Double =>
      build_parquet_double_vector(column, parquet_column, start, len)
    LogicalType::Varchar =>
      build_parquet_varchar_vector(column, parquet_column, start, len)
  }
}

///|
/// Materialize a boolean vector and track nulls through the validity mask.
fn build_parquet_bool_vector(
  column : ColumnDef,
  parquet_column : @parquet.ParquetColumnData,
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  match parquet_column {
    @parquet.BooleanValues(source) =>
      for index in start..<(start + len) {
        values.push(source[index])
        validity.push(true)
      }
    @parquet.Values(source) =>
      for index in start..<(start + len) {
        match source[index] {
          @parquet.Value::Boolean(value) => {
            values.push(value)
            validity.push(true)
          }
          @parquet.Value::Null => {
            values.push(false)
            validity.push(false)
          }
          _ =>
            raise parquet_type_mismatch(
              column.name,
              index + 1,
              "expected boolean or null",
            )
        }
      }
    _ =>
      raise ScanError::Parquet(
        "parquet column \{column.name} cannot be read as BOOLEAN",
      )
  }
  {
    logical_type: LogicalType::Boolean,
    values: VectorBuffer::Bool(values),
    validity: ValidityMask::new(validity),
  }
}

///|
/// Materialize an int64 vector from Parquet integer and timestamp columns.
fn build_parquet_int64_vector(
  column : ColumnDef,
  parquet_column : @parquet.ParquetColumnData,
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  match parquet_column {
    @parquet.Int32Values(source) =>
      for index in start..<(start + len) {
        values.push(source[index].to_int64())
        validity.push(true)
      }
    @parquet.NullableInt32Values(source) =>
      for index in start..<(start + len) {
        match source[index] {
          Some(value) => {
            values.push(value.to_int64())
            validity.push(true)
          }
          None => {
            values.push(0L)
            validity.push(false)
          }
        }
      }
    @parquet.Int64Values(source) =>
      for index in start..<(start + len) {
        values.push(source[index])
        validity.push(true)
      }
    @parquet.NullableInt64Values(source) =>
      for index in start..<(start + len) {
        match source[index] {
          Some(value) => {
            values.push(value)
            validity.push(true)
          }
          None => {
            values.push(0L)
            validity.push(false)
          }
        }
      }
    @parquet.TimestampMicrosValues(source) =>
      for index in start..<(start + len) {
        values.push(source[index])
        validity.push(true)
      }
    @parquet.NullableTimestampMicrosValues(source) =>
      for index in start..<(start + len) {
        match source[index] {
          Some(value) => {
            values.push(value)
            validity.push(true)
          }
          None => {
            values.push(0L)
            validity.push(false)
          }
        }
      }
    @parquet.Values(source) =>
      for index in start..<(start + len) {
        match source[index] {
          @parquet.Value::Int32(value) => {
            values.push(value.to_int64())
            validity.push(true)
          }
          @parquet.Value::Int64(value) => {
            values.push(value)
            validity.push(true)
          }
          @parquet.Value::TimestampMicros(value) => {
            values.push(value)
            validity.push(true)
          }
          @parquet.Value::Null => {
            values.push(0L)
            validity.push(false)
          }
          _ =>
            raise parquet_type_mismatch(
              column.name,
              index + 1,
              "expected bigint-compatible parquet value or null",
            )
        }
      }
    _ =>
      raise ScanError::Parquet(
        "parquet column \{column.name} cannot be read as BIGINT",
      )
  }
  {
    logical_type: LogicalType::BigInt,
    values: VectorBuffer::Int64(values),
    validity: ValidityMask::new(validity),
  }
}

///|
/// Materialize a double vector from Parquet floating-point columns.
fn build_parquet_double_vector(
  column : ColumnDef,
  parquet_column : @parquet.ParquetColumnData,
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  match parquet_column {
    @parquet.FloatValues(source) =>
      for index in start..<(start + len) {
        values.push(source[index].to_double())
        validity.push(true)
      }
    @parquet.DoubleValues(source) =>
      for index in start..<(start + len) {
        values.push(source[index])
        validity.push(true)
      }
    @parquet.Values(source) =>
      for index in start..<(start + len) {
        match source[index] {
          @parquet.Value::Float(value) => {
            values.push(value.to_double())
            validity.push(true)
          }
          @parquet.Value::Double(value) => {
            values.push(value)
            validity.push(true)
          }
          @parquet.Value::Null => {
            values.push(0.0)
            validity.push(false)
          }
          _ =>
            raise parquet_type_mismatch(
              column.name,
              index + 1,
              "expected numeric parquet value or null",
            )
        }
      }
    _ =>
      raise ScanError::Parquet(
        "parquet column \{column.name} cannot be read as DOUBLE",
      )
  }
  {
    logical_type: LogicalType::Double,
    values: VectorBuffer::Double(values),
    validity: ValidityMask::new(validity),
  }
}

///|
/// Materialize a varchar vector from Parquet utf8 and binary payloads.
fn build_parquet_varchar_vector(
  column : ColumnDef,
  parquet_column : @parquet.ParquetColumnData,
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  match parquet_column {
    @parquet.Utf8Values(source) =>
      for index in start..<(start + len) {
        values.push(parquet_bytes_to_varchar(source[index]))
        validity.push(true)
      }
    @parquet.NullableUtf8Values(source) =>
      for index in start..<(start + len) {
        match source[index] {
          Some(value) => {
            values.push(parquet_bytes_to_varchar(value))
            validity.push(true)
          }
          None => {
            values.push("")
            validity.push(false)
          }
        }
      }
    @parquet.BinaryValues(source) =>
      for index in start..<(start + len) {
        values.push(parquet_bytes_to_varchar(source[index]))
        validity.push(true)
      }
    @parquet.NullableBinaryValues(source) =>
      for index in start..<(start + len) {
        match source[index] {
          Some(value) => {
            values.push(parquet_bytes_to_varchar(value))
            validity.push(true)
          }
          None => {
            values.push("")
            validity.push(false)
          }
        }
      }
    @parquet.Values(source) =>
      for index in start..<(start + len) {
        match source[index] {
          @parquet.Value::String(value) => {
            values.push(value)
            validity.push(true)
          }
          @parquet.Value::Binary(value) => {
            values.push(parquet_bytes_to_varchar(value))
            validity.push(true)
          }
          @parquet.Value::Null => {
            values.push("")
            validity.push(false)
          }
          _ =>
            raise parquet_type_mismatch(
              column.name,
              index + 1,
              "expected string/binary parquet value or null",
            )
        }
      }
    _ =>
      raise ScanError::Parquet(
        "parquet column \{column.name} cannot be read as VARCHAR",
      )
  }
  {
    logical_type: LogicalType::Varchar,
    values: VectorBuffer::Varchar(values),
    validity: ValidityMask::new(validity),
  }
}

///|
/// Convert Parquet bytes into the scanner's current `VARCHAR` representation.
fn parquet_bytes_to_varchar(bytes : Bytes) -> String {
  @utf8.decode_lossy(bytes[:])
}

///|
/// Build a stable Parquet row-level type mismatch message for the scan layer.
fn parquet_type_mismatch(
  column_name : String,
  row_no : Int,
  message : String,
) -> ScanError {
  ScanError::Parquet(
    "type mismatch for column \{column_name} at row \{row_no}: \{message}",
  )
}

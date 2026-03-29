///|
pub struct CsvScanner {
  path : String
  schema : Schema
  priv rows : Array[Array[String]]
  mut next_row : Int
} derive(Eq, Show)

///|
/// Full CSV scan entrypoint used by later planning/execution stages.
pub fn read_csv(path : String) -> CsvScanner raise ScanError {
  // TODO(MVP follow-up): keep this pull-based interface, but replace the current
  // full-file buffering with a true streaming implementation so large CSV files
  // do not need to fit in memory.
  let (headers, rows) = parse_csv_rows(path)
  let schema = infer_schema_from_csv(headers, rows)
  CsvScanner::{ path, schema, rows, next_row: 0 }
}

///|
/// Schema inference is a separate phase so the executor can stay chunk-oriented.
pub fn infer_csv_schema(path : String) -> Schema raise ScanError {
  let (headers, rows) = parse_csv_rows(path)
  infer_schema_from_csv(headers, rows)
}

///|
/// `schema()` is stable across the full scan.
pub fn CsvScanner::schema(self : CsvScanner) -> Schema {
  self.schema
}

///|
/// Chunks are produced lazily so the executor does not need an in-memory chunk array.
pub fn CsvScanner::next_chunk(self : CsvScanner) -> DataChunk? raise ScanError {
  guard self.next_row < self.rows.length() else { return None }
  let remaining = self.rows.length() - self.next_row
  let len = if remaining > fixed_vector_size {
    fixed_vector_size
  } else {
    remaining
  }
  let chunk = materialize_csv_chunk(self.schema, self.rows, self.next_row, len)
  self.next_row += len
  Some(chunk)
}

///|
/// Reset allows repeated scans after schema inference/binding has already happened.
pub fn CsvScanner::reset(self : CsvScanner) -> Unit {
  self.next_row = 0
}

///|
/// `scan_csv` is the scanner constructor used by execution code.
pub fn scan_csv(path : String) -> CsvScanner raise ScanError {
  read_csv(path)
}

///|
/// Parse the CSV file into headers and row arrays for schema inference and MVP chunk materialization.
fn parse_csv_rows(
  path : String,
) -> (Array[String], Array[Array[String]]) raise ScanError {
  let content = @fs.read_file_to_string(path) catch {
    err => raise map_io_error(err)
  }
  let csv = @NyaCSV.CSV::parse_string(content, options={
    delimiter: ',',
    allow_newlines_in_quotes: true,
    quote_char: '"',
    skip_empty_lines: true,
    trim_spaces: false,
  })
  let raw_headers = csv.header()
  let rows = csv.data()
  let headers = normalize_headers(raw_headers)
  validate_csv_rows(headers, rows)
  (headers, rows)
}

///|
/// Normalize header names so downstream binding sees stable non-empty column names.
fn normalize_headers(raw_headers : Array[String]) -> Array[String] {
  let headers = []
  let seen : Map[String, Int] = {}
  for index in 0..<raw_headers.length() {
    let trimmed = raw_headers[index].trim()
    let base = if trimmed == "" {
      "column\{index + 1}"
    } else {
      trimmed.to_string()
    }
    let count = seen.get(base).unwrap_or(0)
    seen[base] = count + 1
    if count == 0 {
      headers.push(base)
    } else {
      headers.push("\{base}_\{count + 1}")
    }
  }
  headers
}

///|
/// Validate row widths up front so execution can assume schema/row arity alignment.
fn validate_csv_rows(
  headers : Array[String],
  rows : Array[Array[String]],
) -> Unit raise ScanError {
  let width = headers.length()
  for row_index in 0..<rows.length() {
    if rows[row_index].length() != width {
      raise ScanError::CsvMalformed(
        "row \{row_index + 1} has \{rows[row_index].length()} fields, expected \{width}",
      )
    }
  }
}

///|
/// Infer a deterministic schema across all observed CSV rows.
fn infer_schema_from_csv(
  headers : Array[String],
  rows : Array[Array[String]],
) -> Schema {
  let columns = []
  for column_index in 0..<headers.length() {
    let mut data_type = LogicalType::Null
    let mut nullable = false
    for row in rows {
      let field = row[column_index]
      if field == "" {
        nullable = true
      } else {
        let value_type = infer_csv_field_type(field)
        data_type = merge_csv_logical_types(data_type, value_type)
      }
    }
    columns.push(ColumnDef::{ name: headers[column_index], data_type, nullable })
  }
  Schema::{ columns, }
}

///|
/// Infer the narrowest supported logical type for one non-empty CSV field.
fn infer_csv_field_type(field : String) -> LogicalType {
  if is_csv_bool(field) {
    LogicalType::Boolean
  } else if parse_csv_int64(field) is Some(_) {
    LogicalType::BigInt
  } else if parse_csv_double(field) is Some(_) {
    LogicalType::Double
  } else {
    LogicalType::Varchar
  }
}

///|
/// Merge observed CSV scalar categories into the narrowest supported v1 logical type.
fn merge_csv_logical_types(
  left : LogicalType,
  right : LogicalType,
) -> LogicalType {
  match (left, right) {
    (LogicalType::Null, other) => other
    (other, LogicalType::Null) => other
    (LogicalType::BigInt, LogicalType::Double) => LogicalType::Double
    (LogicalType::Double, LogicalType::BigInt) => LogicalType::Double
    (same_left, same_right) if same_left == same_right => same_left
    _ => LogicalType::Varchar
  }
}

///|
fn parse_csv_int64(field : String) -> Int64? {
  Some(@strconv.parse_int64(field[:])) catch {
    _ => None
  }
}

///|
fn parse_csv_double(field : String) -> Double? {
  Some(@strconv.parse_double(field[:])) catch {
    _ => None
  }
}

///|
fn is_csv_bool(field : String) -> Bool {
  field == "true" || field == "false"
}

///|
/// Convert one row slice into a single columnar `DataChunk`.
fn materialize_csv_chunk(
  schema : Schema,
  rows : Array[Array[String]],
  start : Int,
  len : Int,
) -> DataChunk raise ScanError {
  let columns = []
  for column_index in 0..<schema.columns.length() {
    columns.push(
      build_csv_vector(
        schema.columns[column_index],
        column_index,
        rows,
        start,
        len,
      ),
    )
  }
  DataChunk::{ schema, columns, len }
}

///|
/// Dispatch chunk materialization to the typed vector builder for one CSV column.
fn build_csv_vector(
  column : ColumnDef,
  column_index : Int,
  rows : Array[Array[String]],
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
      build_csv_bool_vector(column, column_index, rows, start, len)
    LogicalType::BigInt =>
      build_csv_int64_vector(column, column_index, rows, start, len)
    LogicalType::Double =>
      build_csv_double_vector(column, column_index, rows, start, len)
    LogicalType::Varchar =>
      build_csv_varchar_vector(column_index, rows, start, len)
  }
}

///|
/// Materialize a boolean vector and track nulls through the validity mask.
fn build_csv_bool_vector(
  column : ColumnDef,
  column_index : Int,
  rows : Array[Array[String]],
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for row_index in start..<(start + len) {
    let field = rows[row_index][column_index]
    if field == "" {
      values.push(false)
      validity.push(false)
    } else if field == "true" {
      values.push(true)
      validity.push(true)
    } else if field == "false" {
      values.push(false)
      validity.push(true)
    } else {
      raise ScanError::TypeMismatch(
        column.name,
        row_index + 1,
        "expected boolean or null",
      )
    }
  }
  {
    logical_type: LogicalType::Boolean,
    values: VectorBuffer::Bool(values),
    validity: ValidityMask::new(validity),
  }
}

///|
/// Materialize an int64 vector, rejecting non-integral or incompatible CSV fields.
fn build_csv_int64_vector(
  column : ColumnDef,
  column_index : Int,
  rows : Array[Array[String]],
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for row_index in start..<(start + len) {
    let field = rows[row_index][column_index]
    if field == "" {
      values.push(0L)
      validity.push(false)
    } else if parse_csv_int64(field) is Some(value) {
      values.push(value)
      validity.push(true)
    } else {
      raise ScanError::TypeMismatch(
        column.name,
        row_index + 1,
        "expected bigint-compatible number or null",
      )
    }
  }
  {
    logical_type: LogicalType::BigInt,
    values: VectorBuffer::Int64(values),
    validity: ValidityMask::new(validity),
  }
}

///|
/// Materialize a double vector while keeping nullability separate from payload values.
fn build_csv_double_vector(
  column : ColumnDef,
  column_index : Int,
  rows : Array[Array[String]],
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for row_index in start..<(start + len) {
    let field = rows[row_index][column_index]
    if field == "" {
      values.push(0.0)
      validity.push(false)
    } else if parse_csv_double(field) is Some(value) {
      values.push(value)
      validity.push(true)
    } else {
      raise ScanError::TypeMismatch(
        column.name,
        row_index + 1,
        "expected numeric value or null",
      )
    }
  }
  {
    logical_type: LogicalType::Double,
    values: VectorBuffer::Double(values),
    validity: ValidityMask::new(validity),
  }
}

///|
/// Materialize a varchar vector directly from CSV text fields.
fn build_csv_varchar_vector(
  column_index : Int,
  rows : Array[Array[String]],
  start : Int,
  len : Int,
) -> Vector {
  let values = []
  let validity = []
  for row_index in start..<(start + len) {
    let field = rows[row_index][column_index]
    if field == "" {
      values.push("")
      validity.push(false)
    } else {
      values.push(field)
      validity.push(true)
    }
  }
  {
    logical_type: LogicalType::Varchar,
    values: VectorBuffer::Varchar(values),
    validity: ValidityMask::new(validity),
  }
}

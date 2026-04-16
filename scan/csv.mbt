///|
/// The CSV scan interface is pull-based so execution can consume one chunk at a time.
pub struct CsvScanner {
  path : String
  schema : Schema
  priv mut file : @async_fs.File
  priv width : Int
  mut next_row_no : Int
  mut finished : Bool
}

///|
/// Parsed CSV rows carry their logical row number so later type errors remain stable across chunking.
priv struct ParsedCsvRow {
  row_no : Int
  fields : Array[String]
}

///|
/// Per-column inference state tracks the narrowest observed type plus nullability.
priv struct CsvColumnState {
  data_type : LogicalType
  nullable : Bool
}

///|
/// The CSV parser tracks whether it is entering, consuming, or closing a field.
priv enum CsvFieldState {
  StartField
  InUnquoted
  InQuoted
  AfterQuoted
}

///|
/// Full CSV scan entrypoint infers schema first, then reopens the file for chunked execution.
pub async fn read_csv(path : String) -> CsvScanner raise ScanError {
  let schema = infer_csv_schema(path)
  read_csv_with_schema(path, schema)
}

///|
/// Execution can reuse a planned schema and reopen the CSV stream directly at the first data row.
pub async fn read_csv_with_schema(
  path : String,
  schema : Schema,
) -> CsvScanner raise ScanError {
  let file = open_csv_file(path)
  let finished = initialize_csv_scan(file, schema)
  CsvScanner::{
    path,
    schema,
    file,
    width: schema.columns.length(),
    next_row_no: 1,
    finished,
  }
}

///|
/// Schema inference streams through the CSV file once so large inputs do not need full buffering.
pub async fn infer_csv_schema(path : String) -> Schema raise ScanError {
  let file = open_csv_file(path)
  defer file.close()
  let raw_headers = read_next_csv_record(file)
  match raw_headers {
    None => Schema::{ columns: [] }
    Some(raw_headers) => {
      let headers = normalize_headers(raw_headers)
      let states = []
      for _ in 0..<headers.length() {
        states.push(CsvColumnState::{
          data_type: LogicalType::Null,
          nullable: false,
        })
      }
      let mut row_no = 1
      while true {
        match read_next_csv_record(file) {
          Some(fields) => {
            validate_csv_row_width(headers.length(), fields, row_no)
            update_csv_schema_states(states, fields)
            row_no += 1
          }
          None => break
        }
      } nobreak {
        ()
      }
      finalize_csv_schema(headers, states)
    }
  }
}

///|
/// `schema()` is stable across the full scan.
pub fn CsvScanner::schema(self : CsvScanner) -> Schema {
  self.schema
}

///|
/// Chunks are produced lazily so the executor does not need an in-memory chunk array.
pub async fn CsvScanner::next_chunk(
  self : CsvScanner,
) -> DataChunk? raise ScanError {
  guard !self.finished else { return None }
  let rows = []
  while rows.length() < fixed_vector_size {
    match read_next_csv_record(self.file) {
      Some(fields) => {
        let row_no = self.next_row_no
        validate_csv_row_width(self.width, fields, row_no)
        rows.push(ParsedCsvRow::{ row_no, fields })
        self.next_row_no += 1
      }
      None => {
        self.finished = true
        break
      }
    }
  } nobreak {
    ()
  }
  if rows.length() == 0 {
    None
  } else {
    Some(materialize_csv_chunk(self.schema, rows))
  }
}

///|
/// Reset allows repeated scans after schema inference and binding have already happened.
pub async fn CsvScanner::reset(self : CsvScanner) -> Unit raise ScanError {
  self.file.close()
  self.file = open_csv_file(self.path)
  self.finished = initialize_csv_scan(self.file, self.schema)
  self.next_row_no = 1
}

///|
/// `scan_csv` is the scanner constructor used by execution code.
pub async fn scan_csv(path : String) -> CsvScanner raise ScanError {
  read_csv(path)
}

///|
/// Open the CSV file as an async stream for schema inference and chunked execution.
async fn open_csv_file(path : String) -> @async_fs.File raise ScanError {
  @async_fs.open(path, mode=ReadOnly) catch {
    err => raise ScanError::Io(err.to_string())
  }
}

///|
/// Initialize a streaming CSV scan by consuming and validating the header row once.
async fn initialize_csv_scan(
  file : @async_fs.File,
  schema : Schema,
) -> Bool raise ScanError {
  match read_next_csv_record(file) {
    None => {
      guard schema.columns.length() == 0 else {
        raise ScanError::CsvMalformed("missing CSV header row")
      }
      true
    }
    Some(raw_headers) => {
      validate_csv_header(schema, normalize_headers(raw_headers))
      false
    }
  }
}

///|
/// Read the next logical CSV record, allowing quoted fields to span multiple physical lines.
async fn read_next_csv_record(
  file : @async_fs.File,
) -> Array[String]? raise ScanError {
  let fields = []
  let field_chars : Array[Char] = []
  let mut state = CsvFieldState::StartField
  let mut started = false
  let mut pending_quoted_newline = false
  while true {
    let next_line = file.read_until("\n") catch {
      err => raise ScanError::Io(err.to_string())
    }
    match next_line {
      None => {
        guard started else { return None }
        match state {
          CsvFieldState::InQuoted =>
            raise ScanError::CsvMalformed("unterminated quoted field")
          CsvFieldState::StartField => {
            fields.push(chars_to_string(field_chars))
            return Some(fields)
          }
          CsvFieldState::InUnquoted | CsvFieldState::AfterQuoted => {
            fields.push(chars_to_string(field_chars))
            return Some(fields)
          }
        }
      }
      Some(raw_line) => {
        let line = raw_line.trim_end(chars="\r").to_string()
        if !started && line == "" {
          continue
        }
        if pending_quoted_newline {
          field_chars.push('\n')
          pending_quoted_newline = false
        }
        started = true
        for ch in line {
          state = consume_csv_char(state, fields, field_chars, ch)
        }
        match state {
          CsvFieldState::InQuoted => {
            pending_quoted_newline = true
            continue
          }
          CsvFieldState::StartField => {
            fields.push(chars_to_string(field_chars))
            return Some(fields)
          }
          CsvFieldState::InUnquoted | CsvFieldState::AfterQuoted => {
            fields.push(chars_to_string(field_chars))
            return Some(fields)
          }
        }
      }
    }
  } nobreak {
    None
  }
}

///|
/// Consume one CSV character and update parser state without materializing full-file buffers.
fn consume_csv_char(
  state : CsvFieldState,
  fields : Array[String],
  field_chars : Array[Char],
  ch : Char,
) -> CsvFieldState raise ScanError {
  match state {
    CsvFieldState::StartField =>
      if ch == ',' {
        fields.push(chars_to_string(field_chars))
        CsvFieldState::StartField
      } else if ch == '"' {
        CsvFieldState::InQuoted
      } else {
        field_chars.push(ch)
        CsvFieldState::InUnquoted
      }
    CsvFieldState::InUnquoted =>
      if ch == ',' {
        fields.push(chars_to_string(field_chars))
        CsvFieldState::StartField
      } else if ch == '"' {
        raise ScanError::CsvMalformed("unexpected quote in unquoted field")
      } else {
        field_chars.push(ch)
        CsvFieldState::InUnquoted
      }
    CsvFieldState::InQuoted =>
      if ch == '"' {
        CsvFieldState::AfterQuoted
      } else {
        field_chars.push(ch)
        CsvFieldState::InQuoted
      }
    CsvFieldState::AfterQuoted =>
      if ch == '"' {
        field_chars.push('"')
        CsvFieldState::InQuoted
      } else if ch == ',' {
        fields.push(chars_to_string(field_chars))
        CsvFieldState::StartField
      } else {
        raise ScanError::CsvMalformed(
          "unexpected character after closing quote",
        )
      }
  }
}

///|
/// Convert the current field buffer into a string and clear it for the next field.
fn chars_to_string(chars : Array[Char]) -> String {
  let text = String::from_array(chars)
  chars.clear()
  text
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
/// Validate that the runtime header still matches the planned CSV schema when reopening the file.
fn validate_csv_header(
  schema : Schema,
  headers : Array[String],
) -> Unit raise ScanError {
  guard headers.length() == schema.columns.length() else {
    raise ScanError::CsvMalformed(
      "header has \{headers.length()} fields, expected \{schema.columns.length()}",
    )
  }
  for index in 0..<headers.length() {
    guard headers[index] == schema.columns[index].name else {
      raise ScanError::CsvMalformed("header does not match planned schema")
    }
  }
}

///|
/// Validate one data row width so execution and inference can assume schema/row arity alignment.
fn validate_csv_row_width(
  width : Int,
  fields : Array[String],
  row_no : Int,
) -> Unit raise ScanError {
  if fields.length() != width {
    raise ScanError::CsvMalformed(
      "row \{row_no} has \{fields.length()} fields, expected \{width}",
    )
  }
}

///|
/// Update streaming inference state with one validated CSV row.
fn update_csv_schema_states(
  states : Array[CsvColumnState],
  fields : Array[String],
) -> Unit {
  for column_index in 0..<fields.length() {
    let field = fields[column_index]
    let state = states[column_index]
    if field == "" {
      states[column_index] = CsvColumnState::{
        data_type: state.data_type,
        nullable: true,
      }
    } else {
      states[column_index] = CsvColumnState::{
        data_type: merge_csv_logical_types(
          state.data_type,
          infer_csv_field_type(field),
        ),
        nullable: state.nullable,
      }
    }
  }
}

///|
/// Finalize the inferred CSV schema after the full row stream has been observed once.
fn finalize_csv_schema(
  headers : Array[String],
  states : Array[CsvColumnState],
) -> Schema {
  let columns = []
  for column_index in 0..<headers.length() {
    let state = states[column_index]
    columns.push(ColumnDef::{
      name: headers[column_index],
      data_type: state.data_type,
      nullable: state.nullable,
    })
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
/// Parse an integer CSV field if it fits the v1 `BIGINT` type.
fn parse_csv_int64(field : String) -> Int64? {
  Some(@string.parse_int64(field[:])) catch {
    _ => None
  }
}

///|
/// Parse a floating-point CSV field if it fits the v1 `DOUBLE` type.
fn parse_csv_double(field : String) -> Double? {
  Some(@string.parse_double(field[:])) catch {
    _ => None
  }
}

///|
/// Recognize the CSV boolean literals accepted by the v1 type inference path.
fn is_csv_bool(field : String) -> Bool {
  field == "true" || field == "false"
}

///|
/// Convert one streamed row slice into a single columnar `DataChunk`.
fn materialize_csv_chunk(
  schema : Schema,
  rows : Array[ParsedCsvRow],
) -> DataChunk raise ScanError {
  let columns = []
  for column_index in 0..<schema.columns.length() {
    columns.push(
      build_csv_vector(schema.columns[column_index], column_index, rows),
    )
  }
  DataChunk::{ schema, columns, len: rows.length() }
}

///|
/// Dispatch chunk materialization to the typed vector builder for one streamed CSV column.
fn build_csv_vector(
  column : ColumnDef,
  column_index : Int,
  rows : Array[ParsedCsvRow],
) -> Vector raise ScanError {
  match column.data_type {
    LogicalType::Null => {
      let validity = ValidityMask::all_null(rows.length())
      {
        logical_type: LogicalType::Null,
        values: VectorBuffer::Nulls(rows.length()),
        validity,
      }
    }
    LogicalType::Boolean => build_csv_bool_vector(column, column_index, rows)
    LogicalType::BigInt => build_csv_int64_vector(column, column_index, rows)
    LogicalType::Double => build_csv_double_vector(column, column_index, rows)
    LogicalType::Varchar => build_csv_varchar_vector(column_index, rows)
  }
}

///|
/// Materialize a boolean vector and track nulls through the validity mask.
fn build_csv_bool_vector(
  column : ColumnDef,
  column_index : Int,
  rows : Array[ParsedCsvRow],
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for row in rows {
    let field = row.fields[column_index]
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
        row.row_no,
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
  rows : Array[ParsedCsvRow],
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for row in rows {
    let field = row.fields[column_index]
    if field == "" {
      values.push(0L)
      validity.push(false)
    } else if parse_csv_int64(field) is Some(value) {
      values.push(value)
      validity.push(true)
    } else {
      raise ScanError::TypeMismatch(
        column.name,
        row.row_no,
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
  rows : Array[ParsedCsvRow],
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for row in rows {
    let field = row.fields[column_index]
    if field == "" {
      values.push(0.0)
      validity.push(false)
    } else if parse_csv_double(field) is Some(value) {
      values.push(value)
      validity.push(true)
    } else {
      raise ScanError::TypeMismatch(
        column.name,
        row.row_no,
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
/// Materialize a varchar vector directly from streamed CSV text fields.
fn build_csv_varchar_vector(
  column_index : Int,
  rows : Array[ParsedCsvRow],
) -> Vector {
  let values = []
  let validity = []
  for row in rows {
    let field = row.fields[column_index]
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

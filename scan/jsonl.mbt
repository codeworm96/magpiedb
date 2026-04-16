///|
using @engine {
  type ColumnDef,
  type DataChunk,
  type LogicalType,
  type Schema,
  type ValidityMask,
  type Vector,
  type VectorBuffer,
  fixed_vector_size,
}

///|
/// The scan interface is pull-based so execution can consume one chunk at a time.
pub struct JsonlScanner {
  path : String
  schema : Schema
  priv mut file : @async_fs.File
  mut next_line_no : Int
  mut finished : Bool
}

///|
priv struct ParsedJsonlRow {
  line_no : Int
  object : Map[String, Json]
}

///|
/// Per-column inference state tracks observed non-null types and whether any row leaves the column nullable.
priv struct JsonlColumnState {
  present_count : Int
  data_type : LogicalType
  nullable : Bool
}

///|
/// Full JSONL scan entrypoint used by later planning/execution stages.
pub async fn read_jsonl(path : String) -> JsonlScanner raise ScanError {
  let schema = infer_jsonl_schema(path)
  read_jsonl_with_schema(path, schema)
}

///|
/// Execution can reuse a planned schema and stream rows from the beginning of the file.
pub async fn read_jsonl_with_schema(
  path : String,
  schema : Schema,
) -> JsonlScanner raise ScanError {
  let file = open_jsonl_file(path)
  JsonlScanner::{ path, schema, file, next_line_no: 1, finished: false }
}

///|
/// Schema inference is a separate phase so the executor can stay chunk-oriented.
pub async fn infer_jsonl_schema(path : String) -> Schema raise ScanError {
  let file = open_jsonl_file(path)
  defer file.close()
  let mut next_line_no = 1
  let mut finished = false
  let mut row_count = 0
  let column_states : Map[String, JsonlColumnState] = {}
  let column_names = []
  while !finished {
    let (next_row, next_line_no_, finished_) = read_next_jsonl_row(
      file, next_line_no,
    )
    next_line_no = next_line_no_
    finished = finished_
    match next_row {
      Some(row) => {
        row_count += 1
        update_schema_state(column_states, column_names, row)
      }
      None => ()
    }
  }
  finalize_inferred_schema(column_states, column_names, row_count)
}

///|
/// `schema()` is stable across the full scan.
pub fn JsonlScanner::schema(self : JsonlScanner) -> Schema {
  self.schema
}

///|
/// Chunks are produced lazily so the executor does not need an in-memory chunk array.
pub async fn JsonlScanner::next_chunk(
  self : JsonlScanner,
) -> DataChunk? raise ScanError {
  guard !self.finished else { return None }
  let rows = []
  while rows.length() < fixed_vector_size {
    let (next_row, next_line_no, finished) = read_next_jsonl_row(
      self.file,
      self.next_line_no,
    )
    self.next_line_no = next_line_no
    self.finished = finished
    match next_row {
      Some(row) => rows.push(row)
      None => break
    }
  } nobreak {
    ()
  }
  if rows.length() == 0 {
    None
  } else {
    Some(materialize_chunk(self.schema, rows, 0, rows.length()))
  }
}

///|
/// Reset allows repeated scans after schema inference/binding has already happened.
pub async fn JsonlScanner::reset(self : JsonlScanner) -> Unit raise ScanError {
  self.file.close()
  self.file = open_jsonl_file(self.path)
  self.next_line_no = 1
  self.finished = false
}

///|
/// `scan_jsonl` is the scanner constructor used by execution code.
pub async fn scan_jsonl(path : String) -> JsonlScanner raise ScanError {
  read_jsonl(path)
}

///|
/// Open the JSONL file as an async stream for chunk-by-chunk execution.
async fn open_jsonl_file(path : String) -> @async_fs.File raise ScanError {
  @async_fs.open(path, mode=ReadOnly) catch {
    err => raise ScanError::Io(err.to_string())
  }
}

///|
/// Read and parse the next non-empty JSONL object from the async file stream.
async fn read_next_jsonl_row(
  file : @async_fs.File,
  next_line_no : Int,
) -> (ParsedJsonlRow?, Int, Bool) raise ScanError {
  let mut line_no = next_line_no
  while true {
    let next_line = file.read_until("\n") catch {
      err => raise ScanError::Io(err.to_string())
    }
    match next_line {
      Some(raw_line) => {
        let current_line_no = line_no
        line_no += 1
        let line = raw_line.trim(chars="\r")
        if line.trim() == "" {
          continue
        }
        return (
          Some(parse_jsonl_line(line.to_string(), current_line_no)),
          line_no,
          false,
        )
      }
      None => return (None, line_no, true)
    }
  } nobreak {
    (None, line_no, true)
  }
}

///|
/// Parse one JSONL text line and enforce the v1 object-per-line contract.
fn parse_jsonl_line(
  line : String,
  line_no : Int,
) -> ParsedJsonlRow raise ScanError {
  let parsed = @json.parse(line) catch {
    err => raise ScanError::JsonParse(line_no, json_parse_message(err))
  }
  match parsed {
    Object(object) => { line_no, object }
    _ => raise ScanError::JsonRootNotObject(line_no)
  }
}

///|
/// Update streaming inference state with one parsed JSONL object row.
fn update_schema_state(
  column_states : Map[String, JsonlColumnState],
  column_names : Array[String],
  row : ParsedJsonlRow,
) -> Unit {
  row.object.each((name, value) => {
    match column_states.get(name) {
      Some(state) => {
        let present_count = state.present_count + 1
        let value_type = infer_json_logical_type(value)
        if value_type == LogicalType::Null {
          column_states[name] = JsonlColumnState::{
            present_count,
            data_type: state.data_type,
            nullable: true,
          }
        } else {
          column_states[name] = JsonlColumnState::{
            present_count,
            data_type: merge_logical_types(state.data_type, value_type),
            nullable: state.nullable,
          }
        }
      }
      None => {
        column_names.push(name)
        let value_type = infer_json_logical_type(value)
        if value_type == LogicalType::Null {
          column_states[name] = JsonlColumnState::{
            present_count: 1,
            data_type: LogicalType::Null,
            nullable: true,
          }
        } else {
          column_states[name] = JsonlColumnState::{
            present_count: 1,
            data_type: value_type,
            nullable: false,
          }
        }
      }
    }
  })
}

///|
/// Finalize the inferred schema after the full JSONL stream has been observed once.
fn finalize_inferred_schema(
  column_states : Map[String, JsonlColumnState],
  column_names : Array[String],
  row_count : Int,
) -> Schema {
  let columns = []
  column_names.sort_by((left, right) => left.lexical_compare(right))
  for name in column_names {
    let state = column_states[name]
    columns.push(ColumnDef::{
      name,
      data_type: state.data_type,
      nullable: state.nullable || state.present_count < row_count,
    })
  }
  Schema::{ columns, }
}

///|
fn infer_json_logical_type(value : Json) -> LogicalType {
  match value {
    Null => LogicalType::Null
    True | False => LogicalType::Boolean
    Number(number, repr~) =>
      if json_number_to_bigint(number, repr) is Some(_) {
        LogicalType::BigInt
      } else {
        LogicalType::Double
      }
    String(_) => LogicalType::Varchar
    Array(_) | Object(_) => LogicalType::Varchar
  }
}

///|
/// Merge observed JSON scalar categories into the narrowest supported v1 logical type.
fn merge_logical_types(left : LogicalType, right : LogicalType) -> LogicalType {
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
fn json_number_to_bigint(number : Double, repr : String?) -> Int64? {
  match repr {
    Some(text) => Some(@string.parse_int64(text[:])) catch { _ => None }
    None =>
      // REVIEW: this fallback is only safe while core/json preserves integral
      // values exactly in `Double`. Large integers can lose precision before we
      // reach this conversion, so later work should prefer original numeric text
      // or add explicit checked range/precision handling here.
      if number.trunc() == number {
        Some(number.to_int64())
      } else {
        None
      }
  }
}

///|
/// Convert one row slice into a single columnar `DataChunk`.
fn materialize_chunk(
  schema : Schema,
  rows : Array[ParsedJsonlRow],
  start : Int,
  len : Int,
) -> DataChunk raise ScanError {
  let columns = []
  for column in schema.columns {
    columns.push(build_vector(column, rows, start, len))
  }
  DataChunk::{ schema, columns, len }
}

///|
/// Dispatch chunk materialization to the typed vector builder for one column.
fn build_vector(
  column : ColumnDef,
  rows : Array[ParsedJsonlRow],
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
    LogicalType::Boolean => build_bool_vector(column, rows, start, len)
    LogicalType::BigInt => build_int64_vector(column, rows, start, len)
    LogicalType::Double => build_double_vector(column, rows, start, len)
    LogicalType::Varchar => build_varchar_vector(column, rows, start, len)
  }
}

///|
/// Materialize a boolean vector and track nulls through the validity mask.
fn build_bool_vector(
  column : ColumnDef,
  rows : Array[ParsedJsonlRow],
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for index in start..<(start + len) {
    match rows[index].object.get(column.name) {
      None | Some(Null) => {
        values.push(false)
        validity.push(false)
      }
      Some(True) => {
        values.push(true)
        validity.push(true)
      }
      Some(False) => {
        values.push(false)
        validity.push(true)
      }
      Some(_) =>
        raise ScanError::TypeMismatch(
          column.name,
          rows[index].line_no,
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
/// Materialize an int64 vector, rejecting non-integral or incompatible JSON numbers.
fn build_int64_vector(
  column : ColumnDef,
  rows : Array[ParsedJsonlRow],
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for index in start..<(start + len) {
    match rows[index].object.get(column.name) {
      None | Some(Null) => {
        values.push(0L)
        validity.push(false)
      }
      Some(Number(number, repr~)) =>
        match json_number_to_bigint(number, repr) {
          Some(value) => {
            values.push(value)
            validity.push(true)
          }
          None =>
            raise ScanError::TypeMismatch(
              column.name,
              rows[index].line_no,
              "expected bigint-compatible number or null",
            )
        }
      Some(_) =>
        raise ScanError::TypeMismatch(
          column.name,
          rows[index].line_no,
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
fn build_double_vector(
  column : ColumnDef,
  rows : Array[ParsedJsonlRow],
  start : Int,
  len : Int,
) -> Vector raise ScanError {
  let values = []
  let validity = []
  for index in start..<(start + len) {
    match rows[index].object.get(column.name) {
      None | Some(Null) => {
        values.push(0.0)
        validity.push(false)
      }
      Some(Number(value, ..)) => {
        values.push(value)
        validity.push(true)
      }
      Some(_) =>
        raise ScanError::TypeMismatch(
          column.name,
          rows[index].line_no,
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
/// Materialize a varchar vector, stringifying nested JSON values for v1 compatibility.
fn build_varchar_vector(
  column : ColumnDef,
  rows : Array[ParsedJsonlRow],
  start : Int,
  len : Int,
) -> Vector {
  let values = []
  let validity = []
  for index in start..<(start + len) {
    match rows[index].object.get(column.name) {
      None | Some(Null) => {
        values.push("")
        validity.push(false)
      }
      Some(value) => {
        values.push(json_value_to_varchar(value))
        validity.push(true)
      }
    }
  }
  {
    logical_type: LogicalType::Varchar,
    values: VectorBuffer::Varchar(values),
    validity: ValidityMask::new(validity),
  }
}

///|
/// Convert a JSON scalar or nested value into the scanner's v1 `VARCHAR` representation.
fn json_value_to_varchar(value : Json) -> String {
  match value {
    String(text) => text
    True => "true"
    False => "false"
    Number(number, repr~) =>
      match repr {
        Some(text) => text
        None => number.to_string()
      }
    Array(_) | Object(_) => value.stringify()
    Null => ""
  }
}

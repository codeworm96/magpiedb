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
pub fn infer_jsonl_schema(path : String) -> Schema raise ScanError {
  parse_jsonl_rows(path) |> infer_schema_from_rows
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
    match self.read_next_row() {
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
async fn JsonlScanner::read_next_row(
  self : JsonlScanner,
) -> ParsedJsonlRow? raise ScanError {
  while true {
    let next_line = self.file.read_until("\n") catch {
      err => raise ScanError::Io(err.to_string())
    }
    match next_line {
      Some(raw_line) => {
        let line_no = self.next_line_no
        self.next_line_no += 1
        let line = raw_line.trim(chars="\r")
        if line.trim() == "" {
          continue
        }
        return Some(parse_jsonl_line(line.to_string(), line_no))
      }
      None => {
        self.finished = true
        return None
      }
    }
  } nobreak {
    None
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
/// Parse the JSONL file into object rows for schema inference and MVP chunk materialization.
fn parse_jsonl_rows(path : String) -> Array[ParsedJsonlRow] raise ScanError {
  let content = @fs.read_file_to_string(path) catch {
    err => raise map_io_error(err)
  }
  let rows = []
  let lines = content.split("\n").map(StringView::to_string).collect()
  for index in 0..<lines.length() {
    let line_no = index + 1
    let line = lines[index].trim(chars="\r")
    if line.trim() == "" {
      continue
    }
    rows.push(parse_jsonl_line(line.to_string(), line_no))
  }
  rows
}

///|
/// Infer a deterministic schema across all observed JSONL object rows.
fn infer_schema_from_rows(rows : Array[ParsedJsonlRow]) -> Schema {
  let column_names = collect_column_names(rows)
  let columns = []
  for name in column_names {
    let mut data_type = LogicalType::Null
    let mut nullable = false
    for row in rows {
      match row.object.get(name) {
        None => nullable = true
        Some(value) => {
          let value_type = infer_json_logical_type(value)
          if value_type == LogicalType::Null {
            nullable = true
          } else {
            data_type = merge_logical_types(data_type, value_type)
          }
        }
      }
    }
    columns.push(ColumnDef::{ name, data_type, nullable })
  }
  Schema::{ columns, }
}

///|
/// Collect column names from all rows and sort them lexically for stable schemas.
fn collect_column_names(rows : Array[ParsedJsonlRow]) -> Array[String] {
  let seen : Map[String, Bool] = {}
  let names = []
  for row in rows {
    row.object.each((name, _) => {
      if !seen.contains(name) {
        seen[name] = true
        names.push(name)
      }
    })
  }
  names.sort_by((left, right) => left.lexical_compare(right))
  names
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

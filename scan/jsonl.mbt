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
/// Parsed JSONL data is exposed as inferred schema plus vectorized chunks.
pub struct JsonlScan {
  path : String
  schema : Schema
  chunks : Array[DataChunk]
} derive(Eq, Show)

///|
priv struct ParsedJsonlRow {
  line_no : Int
  object : Map[String, Json]
}

///|
/// Full JSONL scan entrypoint used by later planning/execution stages.
pub fn read_jsonl(path : String) -> JsonlScan raise ScanError {
  let rows = parse_jsonl_rows(path)
  let schema = infer_schema_from_rows(rows)
  let chunks = materialize_chunks(schema, rows)
  JsonlScan::{ path, schema, chunks }
}

///|
/// Schema inference is a separate phase so the executor can stay chunk-oriented.
pub fn infer_jsonl_schema(path : String) -> Schema raise ScanError {
  parse_jsonl_rows(path) |> infer_schema_from_rows
}

///|
/// Physical scan output is already chunked for the vectorized engine.
pub fn scan_jsonl(path : String) -> Array[DataChunk] raise ScanError {
  read_jsonl(path).chunks
}

///|
fn parse_jsonl_rows(path : String) -> Array[ParsedJsonlRow] raise ScanError {
  let content = @fs.read_file_to_string(path) catch { err =>
    raise map_io_error(err)
  }
  let rows = []
  let lines = content.split("\n").map(StringView::to_string).collect()
  for index in 0..<lines.length() {
    let line_no = index + 1
    let line = lines[index].trim(chars="\r")
    if line.trim() == "" {
      continue
    }
    let parsed = @json.parse(line) catch { err =>
      raise ScanError::JsonParse(line_no, json_parse_message(err))
    }
    match parsed {
      Object(object) => rows.push({ line_no, object })
      _ => raise ScanError::JsonRootNotObject(line_no)
    }
  }
  rows
}

///|
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
  Schema::{ columns }
}

///|
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
    Some(text) =>
      try {
        Some(@strconv.parse_int64(text[:]))
      } catch {
        _ => None
      }
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
fn materialize_chunks(
  schema : Schema,
  rows : Array[ParsedJsonlRow],
) -> Array[DataChunk] raise ScanError {
  let chunks = []
  let total_rows = rows.length()
  let mut start = 0
  while start < total_rows {
    let remaining = total_rows - start
    let len = if remaining > fixed_vector_size {
      fixed_vector_size
    } else {
      remaining
    }
    let columns = []
    for column in schema.columns {
      columns.push(build_vector(column, rows, start, len))
    }
    chunks.push(DataChunk::{ schema, columns, len })
    start += len
  }
  chunks
}

///|
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

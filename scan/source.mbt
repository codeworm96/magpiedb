///|
pub(all) enum ScanSourceKind {
  Csv
  Jsonl
} derive(Eq, Debug)

///|
pub(all) enum Scanner {
  Csv(CsvScanner)
  Jsonl(JsonlScanner)
}

///|
pub fn scan_source_kind(name : String) -> ScanSourceKind? {
  match name {
    "read_csv" => Some(ScanSourceKind::Csv)
    "read_jsonl" => Some(ScanSourceKind::Jsonl)
    _ => None
  }
}

///|
pub fn infer_source_schema(
  kind : ScanSourceKind,
  path : String,
) -> Schema raise ScanError {
  match kind {
    ScanSourceKind::Csv => infer_csv_schema(path)
    ScanSourceKind::Jsonl => infer_jsonl_schema(path)
  }
}

///|
pub async fn open_source(
  kind : ScanSourceKind,
  path : String,
) -> Scanner raise ScanError {
  match kind {
    ScanSourceKind::Csv => Scanner::Csv(read_csv(path))
    ScanSourceKind::Jsonl => Scanner::Jsonl(read_jsonl(path))
  }
}

///|
pub async fn open_source_with_schema(
  kind : ScanSourceKind,
  path : String,
  schema : Schema,
) -> Scanner raise ScanError {
  match kind {
    ScanSourceKind::Csv => Scanner::Csv(read_csv_with_schema(path, schema))
    ScanSourceKind::Jsonl =>
      Scanner::Jsonl(read_jsonl_with_schema(path, schema))
  }
}

///|
pub fn Scanner::schema(self : Scanner) -> Schema {
  match self {
    Csv(scanner) => scanner.schema()
    Jsonl(scanner) => scanner.schema()
  }
}

///|
pub async fn Scanner::next_chunk(self : Scanner) -> DataChunk? raise ScanError {
  match self {
    Csv(scanner) => scanner.next_chunk()
    Jsonl(scanner) => scanner.next_chunk()
  }
}

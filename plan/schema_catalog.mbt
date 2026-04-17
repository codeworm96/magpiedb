///|
pub(all) struct SchemaCatalog {
  entries : Map[String, (@scan.ScanSourceKind, @engine.Schema)]
}

///|
pub fn new_schema_catalog() -> SchemaCatalog {
  SchemaCatalog::{ entries: {} }
}

///|
pub fn SchemaCatalog::entry_count(self : SchemaCatalog) -> Int {
  self.entries.length()
}

///|
fn SchemaCatalog::lookup(
  self : SchemaCatalog,
  path : String,
) -> (@scan.ScanSourceKind, @engine.Schema)? {
  self.entries.get(path)
}

///|
fn SchemaCatalog::remember(
  self : SchemaCatalog,
  path : String,
  kind : @scan.ScanSourceKind,
  schema : @engine.Schema,
) -> Unit {
  self.entries[path] = (kind, schema)
}

///|
fn schema_catalog_kind_name(kind : @scan.ScanSourceKind) -> String {
  match kind {
    @scan.ScanSourceKind::Csv => "read_csv"
    @scan.ScanSourceKind::Jsonl => "read_jsonl"
  }
}

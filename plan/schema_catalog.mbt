///|
pub(all) struct SchemaCatalog {
  state : @ref.Ref[Map[String, (@scan.ScanSourceKind, @engine.Schema)]]
}

///|
pub fn new_schema_catalog() -> SchemaCatalog {
  SchemaCatalog::{ state: @ref.new({}) }
}

///|
pub fn SchemaCatalog::entry_count(self : SchemaCatalog) -> Int {
  self.state.val.length()
}

///|
fn SchemaCatalog::lookup(
  self : SchemaCatalog,
  path : String,
) -> (@scan.ScanSourceKind, @engine.Schema)? {
  self.state.val.get(path)
}

///|
fn SchemaCatalog::remember(
  self : SchemaCatalog,
  path : String,
  kind : @scan.ScanSourceKind,
  schema : @engine.Schema,
) -> Unit {
  self.state.val[path] = (kind, schema)
}

///|
fn schema_catalog_kind_name(kind : @scan.ScanSourceKind) -> String {
  match kind {
    @scan.ScanSourceKind::Csv => "read_csv"
    @scan.ScanSourceKind::Jsonl => "read_jsonl"
  }
}

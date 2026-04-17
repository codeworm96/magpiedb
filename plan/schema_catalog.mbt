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
async fn SchemaCatalog::get_or_infer_schema(
  self : SchemaCatalog,
  path : String,
  kind : @scan.ScanSourceKind,
) -> @engine.Schema raise PlanError {
  match self.lookup(path) {
    Some((cached_kind, schema)) =>
      if cached_kind == kind {
        schema
      } else {
        raise PlanError::Bind(
          "source path \{path} was already used as \{schema_catalog_kind_name(cached_kind)} and cannot be used as \{schema_catalog_kind_name(kind)}",
        )
      }
    None => {
      let schema = @scan.infer_source_schema(kind, path) catch {
        err => raise map_scan_error(err)
      }
      self.remember(path, kind, schema)
      schema
    }
  }
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

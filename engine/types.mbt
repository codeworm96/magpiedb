///|
/// Scalar logical types shared by planning, scanning, and execution.
pub(all) enum LogicalType {
  Null
  Boolean
  BigInt
  Double
  Varchar
} derive(Eq, Debug)

///|
/// Column metadata is stable across chunks and result sets.
pub(all) struct ColumnDef {
  name : String
  data_type : LogicalType
  nullable : Bool
} derive(Eq, Debug)

///|
/// Schemas describe column order and names; vectors follow this order exactly.
pub(all) struct Schema {
  columns : Array[ColumnDef]
} derive(Eq, Debug)

///|
/// Public scalar value container used at API boundaries.
pub(all) enum Value {
  Null
  Boolean(Bool)
  BigInt(Int64)
  Double(Double)
  Varchar(String)
} derive(Eq, Debug)

///|
/// Rows stay as a public convenience type; internal operators should stay columnar.
pub type Row = Array[Value]

///|
pub fn Value::logical_type(self : Value) -> LogicalType {
  match self {
    Null => LogicalType::Null
    Boolean(_) => LogicalType::Boolean
    BigInt(_) => LogicalType::BigInt
    Double(_) => LogicalType::Double
    Varchar(_) => LogicalType::Varchar
  }
}

///|
pub fn Value::is_null(self : Value) -> Bool {
  match self {
    Null => true
    _ => false
  }
}

///|
pub fn Schema::column_count(self : Schema) -> Int {
  self.columns.length()
}

///|
/// Column names are resolved by exact schema order for deterministic plans/results.
pub fn Schema::column_index(self : Schema, name : String) -> Int? {
  for index in 0..<self.columns.length() {
    if self.columns[index].name == name {
      return Some(index)
    }
  }
  None
}

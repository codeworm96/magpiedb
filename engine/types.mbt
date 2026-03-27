///|
pub(all) enum LogicalType {
  Null
  Boolean
  BigInt
  Double
  Varchar
} derive(Eq, Show)

///|
pub(all) struct ColumnDef {
  name : String
  data_type : LogicalType
  nullable : Bool
} derive(Eq, Show)

///|
pub(all) struct Schema {
  columns : Array[ColumnDef]
} derive(Eq, Show)

///|
pub(all) enum Value {
  Null
  Boolean(Bool)
  BigInt(Int64)
  Double(Double)
  Varchar(String)
} derive(Eq, Show)

///|
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
pub fn Schema::column_index(self : Schema, name : String) -> Int? {
  for index in 0..<self.columns.length() {
    if self.columns[index].name == name {
      return Some(index)
    }
  }
  None
}

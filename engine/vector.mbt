///|
pub let fixed_vector_size : Int = 2048

///|
pub(all) struct ValidityMask {
  bits : Array[Bool]
} derive(Eq, Show)

///|
pub(all) enum VectorBuffer {
  Nulls(Int)
  Bool(Array[Bool])
  Int64(Array[Int64])
  Double(Array[Double])
  Varchar(Array[String])
} derive(Eq, Show)

///|
pub(all) struct Vector {
  logical_type : LogicalType
  values : VectorBuffer
  validity : ValidityMask
} derive(Eq, Show)

///|
pub(all) struct DataChunk {
  schema : Schema
  columns : Array[Vector]
  len : Int
} derive(Eq, Show)

///|
pub fn ValidityMask::new(bits : Array[Bool]) -> ValidityMask {
  { bits, }
}

///|
pub fn ValidityMask::all_valid(len : Int) -> ValidityMask {
  let bits = []
  for _ in 0..<len {
    bits.push(true)
  }
  { bits, }
}

///|
pub fn ValidityMask::all_null(len : Int) -> ValidityMask {
  let bits = []
  for _ in 0..<len {
    bits.push(false)
  }
  { bits, }
}

///|
pub fn ValidityMask::len(self : ValidityMask) -> Int {
  self.bits.length()
}

///|
pub fn ValidityMask::is_valid(self : ValidityMask, index : Int) -> Bool? {
  self.bits.get(index)
}

///|
pub fn Vector::len(self : Vector) -> Int {
  match self.values {
    Nulls(len) => len
    Bool(values) => values.length()
    Int64(values) => values.length()
    Double(values) => values.length()
    Varchar(values) => values.length()
  }
}

///|
pub fn Vector::is_empty(self : Vector) -> Bool {
  self.len() == 0
}

///|
pub fn empty_vector(logical_type : LogicalType) -> Vector {
  let values = match logical_type {
    Null => VectorBuffer::Nulls(0)
    Boolean => VectorBuffer::Bool([])
    BigInt => VectorBuffer::Int64([])
    Double => VectorBuffer::Double([])
    Varchar => VectorBuffer::Varchar([])
  }
  { logical_type, values, validity: ValidityMask::all_valid(0) }
}

///|
pub fn DataChunk::empty(schema : Schema) -> DataChunk {
  let columns = []
  for column in schema.columns {
    columns.push(empty_vector(column.data_type))
  }
  { schema, columns, len: 0 }
}

///|
pub fn DataChunk::column_count(self : DataChunk) -> Int {
  self.columns.length()
}

///|
pub fn DataChunk::is_empty(self : DataChunk) -> Bool {
  self.len == 0
}

///|
pub fn DataChunk::is_full(self : DataChunk) -> Bool {
  self.len >= fixed_vector_size
}

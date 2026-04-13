///|
priv enum KeyEncodingMode {
  Group
  Join(@engine.LogicalType, @engine.LogicalType)
}

///|
fn encode_group_key(values : Array[@engine.Value]) -> String raise ExecuteError {
  let parts = []
  for value in values {
    parts.push(encode_key_part(value, KeyEncodingMode::Group))
  }
  parts.join("|")
}

///|
fn encode_join_key(
  value : @engine.Value,
  left_type : @engine.LogicalType,
  right_type : @engine.LogicalType,
) -> String? raise ExecuteError {
  guard value != @engine.Value::Null else { return None }
  Some(encode_key_part(value, KeyEncodingMode::Join(left_type, right_type)))
}

///|
fn encode_key_part(
  value : @engine.Value,
  mode : KeyEncodingMode,
) -> String raise ExecuteError {
  match mode {
    KeyEncodingMode::Group => encode_group_key_part(value)
    KeyEncodingMode::Join(left_type, right_type) =>
      encode_join_key_part(value, left_type, right_type)
  }
}

///|
fn encode_group_key_part(value : @engine.Value) -> String {
  match value {
    @engine.Value::Null => "n:"
    @engine.Value::Boolean(v) => "b:\{v}"
    @engine.Value::BigInt(v) => "i:\{v}"
    @engine.Value::Double(v) => "d:\{v}"
    @engine.Value::Varchar(v) => "s:\{v}"
  }
}

///|
fn encode_join_key_part(
  value : @engine.Value,
  left_type : @engine.LogicalType,
  right_type : @engine.LogicalType,
) -> String raise ExecuteError {
  if is_mixed_numeric_join(left_type, right_type) {
    "n:\{value_to_double(value)}"
  } else {
    match value {
      @engine.Value::Null => "n"
      @engine.Value::Boolean(v) => if v { "b:1" } else { "b:0" }
      @engine.Value::BigInt(v) => "i:\{v}"
      @engine.Value::Double(v) => "d:\{v}"
      @engine.Value::Varchar(v) => "s:\{v.length()}:\{v}"
    }
  }
}

///|
fn is_mixed_numeric_join(
  left_type : @engine.LogicalType,
  right_type : @engine.LogicalType,
) -> Bool {
  match (left_type, right_type) {
    (@engine.LogicalType::BigInt, @engine.LogicalType::Double)
    | (@engine.LogicalType::Double, @engine.LogicalType::BigInt) => true
    _ => false
  }
}

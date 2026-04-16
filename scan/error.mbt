///|
/// Scan errors stay package-local for now and are mapped to `DbError` at the public API boundary.
pub(all) suberror ScanError {
  Io(String)
  JsonParse(Int, String)
  JsonRootNotObject(Int)
  CsvMalformed(String)
  TypeMismatch(String, Int, String)
} derive(Debug)

///|
pub fn ScanError::message(self : ScanError) -> String {
  match self {
    Io(message) | CsvMalformed(message) => message
    JsonParse(line_no, message) =>
      "json parse error at line \{line_no}: \{message}"
    JsonRootNotObject(line_no) => "expected JSON object at line \{line_no}"
    TypeMismatch(column, line_no, message) =>
      "type mismatch for column \{column} at line \{line_no}: \{message}"
  }
}

///|
fn json_parse_message(err : @json.ParseError) -> String {
  match err {
    InvalidChar(position, char) =>
      "invalid character \{to_repr(char)} at line \{position.line}, column \{position.column}"
    InvalidEof => "unexpected end of input"
    InvalidNumber(position, repr) =>
      "invalid number \{repr} at line \{position.line}, column \{position.column}"
    InvalidIdentEscape(position) =>
      "invalid identifier escape at line \{position.line}, column \{position.column}"
    DepthLimitExceeded => "json nesting depth limit exceeded"
  }
}

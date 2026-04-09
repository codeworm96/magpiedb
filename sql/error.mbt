///|
pub struct Position {
  offset : Int
  line : Int
  column : Int
} derive(Eq, Debug)

///|
pub struct Span {
  start : Position
  end_ : Position
} derive(Eq, Debug)

///|
pub suberror LexError {
  UnterminatedString(Int)
  UnrecognizedChar(Int, Char)
} derive(Debug)

///|
pub suberror SqlSyntaxError {
  Lex(LexError)
  Parse(ParseError)
}

///|
pub fn span_from_offsets(sql : String, start : Int, end_ : Int) -> Span {
  { start: offset_to_position(sql, start), end_: offset_to_position(sql, end_) }
}

///|
pub fn SqlSyntaxError::span(self : SqlSyntaxError, sql : String) -> Span {
  match self {
    Lex(UnterminatedString(offset)) => span_from_offsets(sql, offset, offset)
    Lex(UnrecognizedChar(offset, _)) =>
      span_from_offsets(sql, offset, offset + 1)
    Parse(UnexpectedToken(_, (start, end_), _)) =>
      span_from_offsets(sql, start, end_)
    Parse(UnexpectedEndOfInput(offset, _)) =>
      span_from_offsets(sql, offset, offset)
  }
}

///|
fn offset_to_position(sql : String, target : Int) -> Position {
  let mut offset = 0
  let mut line = 1
  let mut column = 1
  while offset < target && offset < sql.length() {
    let unit = sql.code_unit_at(offset).to_int()
    if unit >= 0xD800 && unit <= 0xDBFF && offset + 1 < sql.length() {
      let next = sql.code_unit_at(offset + 1).to_int()
      if next >= 0xDC00 && next <= 0xDFFF {
        offset += 2
      } else {
        offset += 1
      }
    } else {
      offset += 1
    }
    if unit == 10 {
      line += 1
      column = 1
    } else {
      column += 1
    }
  }
  { offset: target, line, column }
}

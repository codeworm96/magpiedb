///|
using @lexbuf {type StringLexbuf}

///|
priv suberror EndOfInput

///|
fn lex_token(lexbuf : StringLexbuf) -> (Token, Int, Int) raise {
  // The matched pattern id
  let mut _match_pattern = @int.max_value
  let mut _match_start = lexbuf.curr_pos()
  let mut _match_end = -1
  let mut _capture_0_start = -1
  let mut _capture_0_end = -1
  let mut _capture_1_start = -1
  let mut _capture_1_end = -1
  loop 0 {
    0 =>
      continue match lexbuf.next_as_int() {
          -1 => 1
          0..=8 => 2
          9..=10 => 3
          11..=12 => 2
          13 => 3
          14..=31 => 2
          32 => 3
          33 => 4
          34..=38 => 2
          39 => 5
          40 => 6
          41 => 7
          42 => 8
          43 => 9
          44 => 10
          45 => 11
          46 => 12
          47 => 13
          48..=57 => 14
          58 => 2
          59 => 15
          60 => 16
          61 => 17
          62 => 18
          63..=64 => 2
          65..=90 => 19
          91..=94 => 2
          95 => 19
          96 => 2
          97..=122 => 19
          123..=1114111 => 2
          _ => break
        }
    1 => {
      _match_pattern = 0
      _match_end = lexbuf.curr_pos()
      break
    }
    2 => {
      _match_pattern = 22
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      break
    }
    3 => {
      _match_pattern = 1
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
          9..=10 => 3
          13 => 3
          32 => 3
          _ => break
        }
    }
    4 => {
      _match_pattern = 22
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_start + 1
      continue match lexbuf.next_as_int() {
          61 => 20
          _ => break
        }
    }
    5 => {
      _match_pattern = 3
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
          0..=9 => 5
          11..=12 => 5
          14..=38 => 5
          39 => 29
          40..=1114111 => 5
          _ => break
        }
    }
    6 => {
      _match_pattern = 10
      _match_end = lexbuf.curr_pos()
      break
    }
    7 => {
      _match_pattern = 11
      _match_end = lexbuf.curr_pos()
      break
    }
    8 => {
      _match_pattern = 16
      _match_end = lexbuf.curr_pos()
      break
    }
    9 => {
      _match_pattern = 14
      _match_end = lexbuf.curr_pos()
      break
    }
    10 => {
      _match_pattern = 12
      _match_end = lexbuf.curr_pos()
      break
    }
    11 => {
      _match_pattern = 15
      _match_end = lexbuf.curr_pos()
      break
    }
    12 => {
      _match_pattern = 13
      _match_end = lexbuf.curr_pos()
      break
    }
    13 => {
      _match_pattern = 17
      _match_end = lexbuf.curr_pos()
      break
    }
    14 => {
      _match_pattern = 8
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
          46 => 27
          48..=57 => 14
          69 => 24
          101 => 24
          _ => break
        }
    }
    15 => {
      _match_pattern = 18
      _match_end = lexbuf.curr_pos()
      break
    }
    16 => {
      _match_pattern = 20
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
          61 => 22
          62 => 23
          _ => break
        }
    }
    17 => {
      _match_pattern = 19
      _match_end = lexbuf.curr_pos()
      break
    }
    18 => {
      _match_pattern = 21
      _match_end = lexbuf.curr_pos()
      continue match lexbuf.next_as_int() {
          61 => 21
          _ => break
        }
    }
    19 => {
      _match_pattern = 9
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
          48..=57 => 19
          65..=90 => 19
          95 => 19
          97..=122 => 19
          _ => break
        }
    }
    20 => {
      _match_pattern = 7
      _match_end = lexbuf.curr_pos()
      break
    }
    21 => {
      _match_pattern = 5
      _match_end = lexbuf.curr_pos()
      break
    }
    22 => {
      _match_pattern = 4
      _match_end = lexbuf.curr_pos()
      break
    }
    23 => {
      _match_pattern = 6
      _match_end = lexbuf.curr_pos()
      break
    }
    24 =>
      continue match lexbuf.next_as_int() {
          43 => 25
          45 => 25
          48..=57 => 26
          _ => break
        }
    25 =>
      continue match lexbuf.next_as_int() {
          48..=57 => 26
          _ => break
        }
    26 => {
      _match_pattern = 8
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
          48..=57 => 26
          _ => break
        }
    }
    27 =>
      continue match lexbuf.next_as_int() {
          48..=57 => 28
          _ => break
        }
    28 => {
      _match_pattern = 8
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
          48..=57 => 28
          69 => 24
          101 => 24
          _ => break
        }
    }
    29 => {
      _match_pattern = 2
      _match_end = lexbuf.curr_pos()
      _capture_0_start = _match_start
      _capture_0_end = _match_end
      continue match lexbuf.next_as_int() {
          39 => 5
          _ => break
        }
    }
    _ => panic()
  }

  guard _match_pattern <= 22 else {
    // No pattern matched
    panic()
  }

  lexbuf.reset(pos=_match_end)
  match _match_pattern {
    0 => {
      ()
      raise EndOfInput
    }
    1 => {
      ()
      lex_token(lexbuf)
    }
    2 => {
      ()
      let text = lexbuf.get_string(_capture_0_start, _capture_0_end)
      make_string_token(text, _match_start, _match_end)
    }
    3 => {
      ()
      raise UnterminatedString(_match_start)
    }
    4 => {
      ()
      (LTE, _match_start, _match_end)
    }
    5 => {
      ()
      (GTE, _match_start, _match_end)
    }
    6 => {
      ()
      (NEQ, _match_start, _match_end)
    }
    7 => {
      ()
      (NEQ, _match_start, _match_end)
    }
    8 => {
      ()
      let text = lexbuf.get_string(_capture_0_start, _capture_0_end)
      make_number_token(text, _match_start, _match_end)
    }
    9 => {
      ()
      let ident = lexbuf.get_string(_capture_0_start, _capture_0_end)
      make_ident_or_keyword(ident, _match_start, _match_end)
    }
    10 => {
      ()
      (LPAREN, _match_start, _match_end)
    }
    11 => {
      ()
      (RPAREN, _match_start, _match_end)
    }
    12 => {
      ()
      (COMMA, _match_start, _match_end)
    }
    13 => {
      ()
      (DOT, _match_start, _match_end)
    }
    14 => {
      ()
      (PLUS, _match_start, _match_end)
    }
    15 => {
      ()
      (MINUS, _match_start, _match_end)
    }
    16 => {
      ()
      (STAR, _match_start, _match_end)
    }
    17 => {
      ()
      (SLASH, _match_start, _match_end)
    }
    18 => {
      ()
      (SEMICOLON, _match_start, _match_end)
    }
    19 => {
      ()
      (EQ, _match_start, _match_end)
    }
    20 => {
      ()
      (LT, _match_start, _match_end)
    }
    21 => {
      ()
      (GT, _match_start, _match_end)
    }
    22 => {
      ()
      let c = lexbuf.get_char(_capture_0_start, _capture_0_end)
      raise UnrecognizedChar(_match_start, c)
    }
    _ => panic()
  }
}

///|
fn make_ident_or_keyword(
  text : String,
  start : Int,
  end_ : Int,
) -> (Token, Int, Int) {
  let upper = text.to_upper()
  let token = match upper {
    "SELECT" => SELECT
    "FROM" => FROM
    "WHERE" => WHERE
    "GROUP" => GROUP
    "BY" => BY
    "HAVING" => HAVING
    "ORDER" => ORDER
    "LIMIT" => LIMIT
    "JOIN" => JOIN
    "INNER" => INNER
    "ON" => ON
    "ASC" => ASC
    "DESC" => DESC
    "AS" => AS
    "CAST" => CAST
    "IS" => IS
    "NULL" => NULL
    "NOT" => NOT
    "AND" => AND
    "OR" => OR
    "TRUE" => TRUE
    "FALSE" => FALSE
    "BOOLEAN" => BOOLEAN_T
    "BIGINT" => BIGINT_T
    "DOUBLE" => DOUBLE_T
    "VARCHAR" => VARCHAR_T
    _ => IDENT(text)
  }
  (token, start, end_)
}

///|
fn make_number_token(
  text : String,
  start : Int,
  end_ : Int,
) -> (Token, Int, Int) {
  let token = if is_double_literal(text) {
    DOUBLE_LITERAL(text)
  } else {
    INTEGER_LITERAL(text)
  }
  (token, start, end_)
}

///|
fn is_double_literal(text : String) -> Bool {
  text.contains(".") || text.contains("e") || text.contains("E")
}

///|
fn make_string_token(
  raw : String,
  start : Int,
  end_ : Int,
) -> (Token, Int, Int) {
  (STRING_LITERAL(decode_sql_string(raw)), start, end_)
}

///|
fn decode_sql_string(raw : String) -> String {
  if raw.length() < 2 {
    return ""
  }
  let chars = []
  let mut index = 1
  let stop = raw.length() - 1
  while index < stop {
    let char = raw.get_char(index).unwrap()
    if char == '\'' && index + 1 < stop && raw.get_char(index + 1) == Some('\'') {
      chars.push('\'')
      index += 2
    } else {
      chars.push(char)
      index += 1
    }
  }
  String::from_array(chars)
}

///|
pub fn tokenize(input : String) -> Array[(Token, Int, Int)] raise LexError {
  let lexbuf = StringLexbuf::from_string(input)
  let tokens = []
  for ;; {
    let token = lex_token(lexbuf) catch {
      EndOfInput => break
      UnrecognizedChar(_, _) as err => raise err
      UnterminatedString(_) as err => raise err
      _ => panic()
    }
    tokens.push(token)
  }
  tokens
}

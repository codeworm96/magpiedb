
pub(all) enum Token {
  IDENT(String)
  STRING_LITERAL(String)
  INTEGER_LITERAL(String)
  DOUBLE_LITERAL(String)
  SELECT
  FROM
  WHERE
  AS
  CAST
  IS
  NULL
  NOT
  AND
  OR
  TRUE
  FALSE
  BOOLEAN_T
  BIGINT_T
  DOUBLE_T
  VARCHAR_T
  LPAREN
  RPAREN
  COMMA
  DOT
  PLUS
  MINUS
  STAR
  SLASH
  EQ
  NEQ
  LT
  LTE
  GT
  GTE
  SEMICOLON
} derive(Show)

pub fn Token::kind(self : Token) -> TokenKind {
  match self {
    IDENT(_) => TK_IDENT
    STRING_LITERAL(_) => TK_STRING_LITERAL
    INTEGER_LITERAL(_) => TK_INTEGER_LITERAL
    DOUBLE_LITERAL(_) => TK_DOUBLE_LITERAL
    SELECT => TK_SELECT
    FROM => TK_FROM
    WHERE => TK_WHERE
    AS => TK_AS
    CAST => TK_CAST
    IS => TK_IS
    NULL => TK_NULL
    NOT => TK_NOT
    AND => TK_AND
    OR => TK_OR
    TRUE => TK_TRUE
    FALSE => TK_FALSE
    BOOLEAN_T => TK_BOOLEAN_T
    BIGINT_T => TK_BIGINT_T
    DOUBLE_T => TK_DOUBLE_T
    VARCHAR_T => TK_VARCHAR_T
    LPAREN => TK_LPAREN
    RPAREN => TK_RPAREN
    COMMA => TK_COMMA
    DOT => TK_DOT
    PLUS => TK_PLUS
    MINUS => TK_MINUS
    STAR => TK_STAR
    SLASH => TK_SLASH
    EQ => TK_EQ
    NEQ => TK_NEQ
    LT => TK_LT
    LTE => TK_LTE
    GT => TK_GT
    GTE => TK_GTE
    SEMICOLON => TK_SEMICOLON
  }
}

pub(all) enum TokenKind {
  TK_IDENT
  TK_STRING_LITERAL
  TK_INTEGER_LITERAL
  TK_DOUBLE_LITERAL
  TK_SELECT
  TK_FROM
  TK_WHERE
  TK_AS
  TK_CAST
  TK_IS
  TK_NULL
  TK_NOT
  TK_AND
  TK_OR
  TK_TRUE
  TK_FALSE
  TK_BOOLEAN_T
  TK_BIGINT_T
  TK_DOUBLE_T
  TK_VARCHAR_T
  TK_LPAREN
  TK_RPAREN
  TK_COMMA
  TK_DOT
  TK_PLUS
  TK_MINUS
  TK_STAR
  TK_SLASH
  TK_EQ
  TK_NEQ
  TK_LT
  TK_LTE
  TK_GT
  TK_GTE
  TK_SEMICOLON
}

pub impl Show for TokenKind with output(self, logger) {
  logger.write_string(
    match self {
      TK_IDENT => "IDENT"
      TK_STRING_LITERAL => "STRING_LITERAL"
      TK_INTEGER_LITERAL => "INTEGER_LITERAL"
      TK_DOUBLE_LITERAL => "DOUBLE_LITERAL"
      TK_SELECT => "\"SELECT\""
      TK_FROM => "\"FROM\""
      TK_WHERE => "\"WHERE\""
      TK_AS => "\"AS\""
      TK_CAST => "\"CAST\""
      TK_IS => "\"IS\""
      TK_NULL => "\"NULL\""
      TK_NOT => "\"NOT\""
      TK_AND => "\"AND\""
      TK_OR => "\"OR\""
      TK_TRUE => "\"TRUE\""
      TK_FALSE => "\"FALSE\""
      TK_BOOLEAN_T => "\"BOOLEAN\""
      TK_BIGINT_T => "\"BIGINT\""
      TK_DOUBLE_T => "\"DOUBLE\""
      TK_VARCHAR_T => "\"VARCHAR\""
      TK_LPAREN => "\"(\""
      TK_RPAREN => "\")\""
      TK_COMMA => "\",\""
      TK_DOT => "\".\""
      TK_PLUS => "\"+\""
      TK_MINUS => "\"-\""
      TK_STAR => "\"*\""
      TK_SLASH => "\"/\""
      TK_EQ => "\"=\""
      TK_NEQ => "\"!=\""
      TK_LT => "\"<\""
      TK_LTE => "\"<=\""
      TK_GT => "\">\""
      TK_GTE => "\">=\""
      TK_SEMICOLON => "\";\""
    }
  )
}

pub suberror ParseError {
  UnexpectedToken(Token, (Int, Int), Array[TokenKind])
  UnexpectedEndOfInput(Int, Array[TokenKind])
} derive(Show)

type YYObj = Error

priv suberror YYObj_Void

priv suberror YYObj_Expr {
  YYObj_Expr(Expr)
}

priv suberror YYObj_Unit {
  YYObj_Unit(Unit)
}

priv suberror YYObj_Array_Expr_ {
  YYObj_Array_Expr_(Array[Expr])
}

priv suberror YYObj_Array_String_ {
  YYObj_Array_String_(Array[String])
}

priv suberror YYObj_Array_SelectItem_ {
  YYObj_Array_SelectItem_(Array[SelectItem])
}

priv suberror YYObj_Query {
  YYObj_Query(Query)
}

priv suberror YYObj_String {
  YYObj_String(String)
}

priv suberror YYObj_TypeName {
  YYObj_TypeName(TypeName)
}

priv suberror YYObj_SelectItem {
  YYObj_SelectItem(SelectItem)
}

priv suberror YYObj_TableFunction {
  YYObj_TableFunction(TableFunction)
}

priv suberror YYObj_Expr_ {
  YYObj_Expr_(Expr?)
}

priv suberror YYObj_String_ {
  YYObj_String_(String?)
}

type YYState = (YYSymbol) -> YYDecision

type YYAction = (Int, ArrayView[(YYObj, Int, Int)]) -> YYObj

priv enum YYDecision {
  Accept
  Shift(YYState)
  Reduce(Int, YYSymbol, YYAction)
  ReduceNoLookahead(Int, YYSymbol, YYAction)
  Error
}

priv enum YYSymbol {
  T_IDENT
  T_STRING_LITERAL
  T_INTEGER_LITERAL
  T_DOUBLE_LITERAL
  T_SELECT
  T_FROM
  T_WHERE
  T_AS
  T_CAST
  T_IS
  T_NULL
  T_NOT
  T_AND
  T_OR
  T_TRUE
  T_FALSE
  T_BOOLEAN_T
  T_BIGINT_T
  T_DOUBLE_T
  T_VARCHAR_T
  T_LPAREN
  T_RPAREN
  T_COMMA
  T_DOT
  T_PLUS
  T_MINUS
  T_STAR
  T_SLASH
  T_EQ
  T_NEQ
  T_LT
  T_LTE
  T_GT
  T_GTE
  T_SEMICOLON
  NT_query
  NT_opt_semicolon
  NT_select_list
  NT_select_item
  NT_opt_alias
  NT_table_function
  NT_argument_list
  NT_opt_where
  NT_expr
  NT_or_expr
  NT_and_expr
  NT_not_expr
  NT_comparison_expr
  NT_additive_expr
  NT_multiplicative_expr
  NT_unary_expr
  NT_primary_expr
  NT_identifier_path
  NT_type_name
  EOI
}

// Workaround for EOI unused warning
fn init {
  match (EOI : YYSymbol) {
    EOI => ()
    _ => ()
  }
}

// file:///./parser.mbty
// 65|    "SELECT" select_list "FROM" table_function opt_where opt_semicolon
// 66|      { make_query($2, $4, $5) }
fn yy_action_0(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Array_SelectItem_(_dollar2)
  guard _args[3].0 is YYObj_TableFunction(_dollar4)
  guard _args[4].0 is YYObj_Expr_(_dollar5)
  YYObj_Query({();  make_query(_dollar2, _dollar4, _dollar5) })
}

// file:///./parser.mbty
// 72|    ";"
// 73|      { () }
fn yy_action_1(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Unit({();  () })
}

// file:///./parser.mbty
// 70|   
// 71|      { () }
fn yy_action_2(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Unit({();  () })
}

// file:///./parser.mbty
// 114|    "WHERE" expr
// 115|      { Some($2) }
fn yy_action_3(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr_({();  Some(_dollar2) })
}

// file:///./parser.mbty
// 112|   
// 113|      { None }
fn yy_action_4(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr_({();  None })
}

// file:///./parser.mbty
// 98|    IDENT "(" ")"
// 99|      { make_table_function($1, []) }
fn yy_action_5(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_TableFunction({();  make_table_function(_dollar1, []) })
}

// file:///./parser.mbty
// 100|    IDENT "(" argument_list ")"
// 101|      { make_table_function($1, $3) }
fn yy_action_6(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Array_Expr_(_dollar3)
  YYObj_TableFunction({();  make_table_function(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 107|    argument_list "," expr
// 108|      { push_expr($1, $3) }
fn yy_action_7(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_Expr_(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Array_Expr_({();  push_expr(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 105|    expr
// 106|      { [$1] }
fn yy_action_8(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Array_Expr_({();  [_dollar1] })
}

// file:///./parser.mbty
// 79|    select_list "," select_item
// 80|      { push_select_item($1, $3) }
fn yy_action_9(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_SelectItem_(_dollar1)
  guard _args[2].0 is YYObj_SelectItem(_dollar3)
  YYObj_Array_SelectItem_({();  push_select_item(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 77|    select_item
// 78|      { [$1] }
fn yy_action_10(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_SelectItem(_dollar1)
  YYObj_Array_SelectItem_({();  [_dollar1] })
}

// file:///./parser.mbty
// 84|    expr opt_alias
// 85|      { make_select_item($1, $2) }
fn yy_action_11(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[1].0 is YYObj_String_(_dollar2)
  YYObj_SelectItem({();  make_select_item(_dollar1, _dollar2) })
}

// file:///./parser.mbty
// 91|    "AS" IDENT
// 92|      { Some($2) }
fn yy_action_12(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  YYObj_String_({();  Some(_dollar2) })
}

// file:///./parser.mbty
// 93|    IDENT
// 94|      { Some($1) }
fn yy_action_13(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_String_({();  Some(_dollar1) })
}

// file:///./parser.mbty
// 89|   
// 90|      { None }
fn yy_action_14(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_String_({();  None })
}

// file:///./parser.mbty
// 126|    or_expr "OR" and_expr
// 127|      { Expr::Binary(BinaryOp::Or, $1, $3) }
fn yy_action_15(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Or, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 119|    or_expr
// 120|      { $1 }
fn yy_action_16(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 133|    and_expr "AND" not_expr
// 134|      { Expr::Binary(BinaryOp::And, $1, $3) }
fn yy_action_17(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::And, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 124|    and_expr
// 125|      { $1 }
fn yy_action_18(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 131|    not_expr
// 132|      { $1 }
fn yy_action_19(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 138|    comparison_expr
// 139|      { $1 }
fn yy_action_20(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 140|    "NOT" not_expr
// 141|      { Expr::Unary(UnaryOp::Not, $2) }
fn yy_action_21(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  Expr::Unary(UnaryOp::Not, _dollar2) })
}

// file:///./parser.mbty
// 147|    additive_expr "=" additive_expr
// 148|      { Expr::Binary(BinaryOp::Equal, $1, $3) }
fn yy_action_22(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Equal, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 149|    additive_expr "!=" additive_expr
// 150|      { Expr::Binary(BinaryOp::NotEqual, $1, $3) }
fn yy_action_23(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::NotEqual, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 151|    additive_expr "<" additive_expr
// 152|      { Expr::Binary(BinaryOp::LessThan, $1, $3) }
fn yy_action_24(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::LessThan, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 153|    additive_expr "<=" additive_expr
// 154|      { Expr::Binary(BinaryOp::LessThanOrEqual, $1, $3) }
fn yy_action_25(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::LessThanOrEqual, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 155|    additive_expr ">" additive_expr
// 156|      { Expr::Binary(BinaryOp::GreaterThan, $1, $3) }
fn yy_action_26(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::GreaterThan, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 157|    additive_expr ">=" additive_expr
// 158|      { Expr::Binary(BinaryOp::GreaterThanOrEqual, $1, $3) }
fn yy_action_27(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::GreaterThanOrEqual, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 159|    additive_expr "IS" "NULL"
// 160|      { Expr::IsNull($1) }
fn yy_action_28(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  Expr::IsNull(_dollar1) })
}

// file:///./parser.mbty
// 161|    additive_expr "IS" "NOT" "NULL"
// 162|      { Expr::IsNotNull($1) }
fn yy_action_29(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  Expr::IsNotNull(_dollar1) })
}

// file:///./parser.mbty
// 168|    additive_expr "+" multiplicative_expr
// 169|      { Expr::Binary(BinaryOp::Add, $1, $3) }
fn yy_action_30(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Add, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 170|    additive_expr "-" multiplicative_expr
// 171|      { Expr::Binary(BinaryOp::Subtract, $1, $3) }
fn yy_action_31(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Subtract, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 145|    additive_expr
// 146|      { $1 }
fn yy_action_32(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 177|    multiplicative_expr "*" unary_expr
// 178|      { Expr::Binary(BinaryOp::Multiply, $1, $3) }
fn yy_action_33(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Multiply, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 179|    multiplicative_expr "/" unary_expr
// 180|      { Expr::Binary(BinaryOp::Divide, $1, $3) }
fn yy_action_34(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Divide, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 166|    multiplicative_expr
// 167|      { $1 }
fn yy_action_35(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 175|    unary_expr
// 176|      { $1 }
fn yy_action_36(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 184|    primary_expr
// 185|      { $1 }
fn yy_action_37(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 186|    "+" unary_expr
// 187|      { Expr::Unary(UnaryOp::Plus, $2) }
fn yy_action_38(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  Expr::Unary(UnaryOp::Plus, _dollar2) })
}

// file:///./parser.mbty
// 188|    "-" unary_expr
// 189|      { Expr::Unary(UnaryOp::Minus, $2) }
fn yy_action_39(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  Expr::Unary(UnaryOp::Minus, _dollar2) })
}

// file:///./parser.mbty
// 216|    identifier_path "." IDENT
// 217|      { push_string($1, $3) }
fn yy_action_40(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_String_(_dollar1)
  guard _args[2].0 is YYObj_String(_dollar3)
  YYObj_Array_String_({();  push_string(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 193|    identifier_path
// 194|      { Expr::ColumnRef($1) }
fn yy_action_41(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_String_(_dollar1)
  YYObj_Expr({();  Expr::ColumnRef(_dollar1) })
}

// file:///./parser.mbty
// 195|    STRING_LITERAL
// 196|      { Expr::StringLiteral($1) }
fn yy_action_42(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::StringLiteral(_dollar1) })
}

// file:///./parser.mbty
// 197|    INTEGER_LITERAL
// 198|      { Expr::IntegerLiteral($1) }
fn yy_action_43(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::IntegerLiteral(_dollar1) })
}

// file:///./parser.mbty
// 199|    DOUBLE_LITERAL
// 200|      { Expr::DoubleLiteral($1) }
fn yy_action_44(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::DoubleLiteral(_dollar1) })
}

// file:///./parser.mbty
// 201|    "TRUE"
// 202|      { Expr::BooleanLiteral(true) }
fn yy_action_45(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr({();  Expr::BooleanLiteral(true) })
}

// file:///./parser.mbty
// 203|    "FALSE"
// 204|      { Expr::BooleanLiteral(false) }
fn yy_action_46(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr({();  Expr::BooleanLiteral(false) })
}

// file:///./parser.mbty
// 205|    "NULL"
// 206|      { Expr::NullLiteral }
fn yy_action_47(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr({();  Expr::NullLiteral })
}

// file:///./parser.mbty
// 207|    "(" expr ")"
// 208|      { $2 }
fn yy_action_48(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  _dollar2 })
}

// file:///./parser.mbty
// 209|    "CAST" "(" expr "AS" type_name ")"
// 210|      { Expr::Cast($3, $5) }
fn yy_action_49(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[2].0 is YYObj_Expr(_dollar3)
  guard _args[4].0 is YYObj_TypeName(_dollar5)
  YYObj_Expr({();  Expr::Cast(_dollar3, _dollar5) })
}

// file:///./parser.mbty
// 221|    "NULL"
// 222|      { TypeName::Null }
fn yy_action_50(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::Null })
}

// file:///./parser.mbty
// 223|    "BOOLEAN"
// 224|      { TypeName::Boolean }
fn yy_action_51(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::Boolean })
}

// file:///./parser.mbty
// 225|    "BIGINT"
// 226|      { TypeName::BigInt }
fn yy_action_52(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::BigInt })
}

// file:///./parser.mbty
// 227|    "DOUBLE"
// 228|      { TypeName::Double }
fn yy_action_53(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::Double })
}

// file:///./parser.mbty
// 229|    "VARCHAR"
// 230|      { TypeName::Varchar }
fn yy_action_54(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::Varchar })
}

// file:///./parser.mbty
// 214|    IDENT
// 215|      { [$1] }
fn yy_action_55(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Array_String_({();  [_dollar1] })
}

fn yy_input(token : Token, _start_pos : Int, _end_pos : Int) -> (YYSymbol, YYObj) {
  match token {
    IDENT(data) => (T_IDENT, YYObj_String(data))
    STRING_LITERAL(data) => (T_STRING_LITERAL, YYObj_String(data))
    INTEGER_LITERAL(data) => (T_INTEGER_LITERAL, YYObj_String(data))
    DOUBLE_LITERAL(data) => (T_DOUBLE_LITERAL, YYObj_String(data))
    SELECT => (T_SELECT, YYObj_Void)
    FROM => (T_FROM, YYObj_Void)
    WHERE => (T_WHERE, YYObj_Void)
    AS => (T_AS, YYObj_Void)
    CAST => (T_CAST, YYObj_Void)
    IS => (T_IS, YYObj_Void)
    NULL => (T_NULL, YYObj_Void)
    NOT => (T_NOT, YYObj_Void)
    AND => (T_AND, YYObj_Void)
    OR => (T_OR, YYObj_Void)
    TRUE => (T_TRUE, YYObj_Void)
    FALSE => (T_FALSE, YYObj_Void)
    BOOLEAN_T => (T_BOOLEAN_T, YYObj_Void)
    BIGINT_T => (T_BIGINT_T, YYObj_Void)
    DOUBLE_T => (T_DOUBLE_T, YYObj_Void)
    VARCHAR_T => (T_VARCHAR_T, YYObj_Void)
    LPAREN => (T_LPAREN, YYObj_Void)
    RPAREN => (T_RPAREN, YYObj_Void)
    COMMA => (T_COMMA, YYObj_Void)
    DOT => (T_DOT, YYObj_Void)
    PLUS => (T_PLUS, YYObj_Void)
    MINUS => (T_MINUS, YYObj_Void)
    STAR => (T_STAR, YYObj_Void)
    SLASH => (T_SLASH, YYObj_Void)
    EQ => (T_EQ, YYObj_Void)
    NEQ => (T_NEQ, YYObj_Void)
    LT => (T_LT, YYObj_Void)
    LTE => (T_LTE, YYObj_Void)
    GT => (T_GT, YYObj_Void)
    GTE => (T_GTE, YYObj_Void)
    SEMICOLON => (T_SEMICOLON, YYObj_Void)
  }
}

// [0, query → • SELECT select_list FROM table_function opt_where opt_semicolon, $]
// [56, query_prime → • query, $]
fn yy_state_0(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_query => Shift(yy_state_1)
    T_SELECT => Shift(yy_state_2)
    _ => Error
  }
}

// [56, query_prime → query •, $]
fn yy_state_1(_lookahead : YYSymbol) -> YYDecision {
  Accept
}

// [0, query → SELECT • select_list FROM table_function opt_where opt_semicolon, $]
// [3, select_list → • select_item, FROM / COMMA]
// [4, select_list → • select_list COMMA select_item, FROM / COMMA]
// [5, select_item → • expr opt_alias, FROM / COMMA]
// [15, expr → • or_expr, IDENT / FROM / AS / COMMA]
// [16, or_expr → • and_expr, IDENT / FROM / AS / OR / COMMA]
// [17, or_expr → • or_expr OR and_expr, IDENT / FROM / AS / OR / COMMA]
// [18, and_expr → • not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [19, and_expr → • and_expr AND not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [20, not_expr → • comparison_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [21, not_expr → • NOT not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [22, comparison_expr → • additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [23, comparison_expr → • additive_expr EQ additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [24, comparison_expr → • additive_expr NEQ additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [25, comparison_expr → • additive_expr LT additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [26, comparison_expr → • additive_expr LTE additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [27, comparison_expr → • additive_expr GT additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [28, comparison_expr → • additive_expr GTE additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [29, comparison_expr → • additive_expr IS NULL, IDENT / FROM / AS / AND / OR / COMMA]
// [30, comparison_expr → • additive_expr IS NOT NULL, IDENT / FROM / AS / AND / OR / COMMA]
// [31, additive_expr → • multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [34, multiplicative_expr → • unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [37, unary_expr → • primary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [38, unary_expr → • PLUS unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [39, unary_expr → • MINUS unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [40, primary_expr → • identifier_path, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [41, primary_expr → • STRING_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [42, primary_expr → • INTEGER_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [43, primary_expr → • DOUBLE_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [44, primary_expr → • TRUE, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [45, primary_expr → • FALSE, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [46, primary_expr → • NULL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [47, primary_expr → • LPAREN expr RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [49, identifier_path → • IDENT, IDENT / FROM / AS / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [50, identifier_path → • identifier_path DOT IDENT, IDENT / FROM / AS / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_2(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_62)
    NT_and_expr => Shift(yy_state_63)
    NT_or_expr => Shift(yy_state_66)
    NT_expr => Shift(yy_state_69)
    NT_select_item => Shift(yy_state_74)
    NT_select_list => Shift(yy_state_75)
    _ => Error
  }
}

// [49, identifier_path → IDENT •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_3(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_identifier_path, yy_action_55)
}

// [48, primary_expr → CAST • LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_4(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_5)
    _ => Error
  }
}

// [15, expr → • or_expr, AS]
// [16, or_expr → • and_expr, AS / OR]
// [17, or_expr → • or_expr OR and_expr, AS / OR]
// [18, and_expr → • not_expr, AS / AND / OR]
// [19, and_expr → • and_expr AND not_expr, AS / AND / OR]
// [20, not_expr → • comparison_expr, AS / AND / OR]
// [21, not_expr → • NOT not_expr, AS / AND / OR]
// [22, comparison_expr → • additive_expr, AS / AND / OR]
// [23, comparison_expr → • additive_expr EQ additive_expr, AS / AND / OR]
// [24, comparison_expr → • additive_expr NEQ additive_expr, AS / AND / OR]
// [25, comparison_expr → • additive_expr LT additive_expr, AS / AND / OR]
// [26, comparison_expr → • additive_expr LTE additive_expr, AS / AND / OR]
// [27, comparison_expr → • additive_expr GT additive_expr, AS / AND / OR]
// [28, comparison_expr → • additive_expr GTE additive_expr, AS / AND / OR]
// [29, comparison_expr → • additive_expr IS NULL, AS / AND / OR]
// [30, comparison_expr → • additive_expr IS NOT NULL, AS / AND / OR]
// [31, additive_expr → • multiplicative_expr, AS / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, AS / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, AS / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [34, multiplicative_expr → • unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [37, unary_expr → • primary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [38, unary_expr → • PLUS unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [39, unary_expr → • MINUS unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [40, primary_expr → • identifier_path, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [41, primary_expr → • STRING_LITERAL, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [42, primary_expr → • INTEGER_LITERAL, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [43, primary_expr → • DOUBLE_LITERAL, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [44, primary_expr → • TRUE, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [45, primary_expr → • FALSE, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [46, primary_expr → • NULL, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [47, primary_expr → • LPAREN expr RPAREN, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [48, primary_expr → CAST LPAREN • expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, AS / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [50, identifier_path → • identifier_path DOT IDENT, AS / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_5(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    NT_expr => Shift(yy_state_6)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_62)
    NT_and_expr => Shift(yy_state_63)
    NT_or_expr => Shift(yy_state_66)
    _ => Error
  }
}

// [48, primary_expr → CAST LPAREN expr • AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_6(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_AS => Shift(yy_state_7)
    _ => Error
  }
}

// [48, primary_expr → CAST LPAREN expr AS • type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [51, type_name → • NULL, RPAREN]
// [52, type_name → • BOOLEAN_T, RPAREN]
// [53, type_name → • BIGINT_T, RPAREN]
// [54, type_name → • DOUBLE_T, RPAREN]
// [55, type_name → • VARCHAR_T, RPAREN]
fn yy_state_7(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_VARCHAR_T => Shift(yy_state_8)
    T_DOUBLE_T => Shift(yy_state_9)
    T_BIGINT_T => Shift(yy_state_10)
    T_BOOLEAN_T => Shift(yy_state_11)
    T_NULL => Shift(yy_state_12)
    NT_type_name => Shift(yy_state_13)
    _ => Error
  }
}

// [55, type_name → VARCHAR_T •, RPAREN]
fn yy_state_8(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_54)
}

// [54, type_name → DOUBLE_T •, RPAREN]
fn yy_state_9(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_53)
}

// [53, type_name → BIGINT_T •, RPAREN]
fn yy_state_10(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_52)
}

// [52, type_name → BOOLEAN_T •, RPAREN]
fn yy_state_11(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_51)
}

// [51, type_name → NULL •, RPAREN]
fn yy_state_12(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_50)
}

// [48, primary_expr → CAST LPAREN expr AS type_name • RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_13(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_14)
    _ => Error
  }
}

// [48, primary_expr → CAST LPAREN expr AS type_name RPAREN •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_14(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(6, NT_primary_expr, yy_action_49)
}

// [15, expr → • or_expr, RPAREN]
// [16, or_expr → • and_expr, OR / RPAREN]
// [17, or_expr → • or_expr OR and_expr, OR / RPAREN]
// [18, and_expr → • not_expr, AND / OR / RPAREN]
// [19, and_expr → • and_expr AND not_expr, AND / OR / RPAREN]
// [20, not_expr → • comparison_expr, AND / OR / RPAREN]
// [21, not_expr → • NOT not_expr, AND / OR / RPAREN]
// [22, comparison_expr → • additive_expr, AND / OR / RPAREN]
// [23, comparison_expr → • additive_expr EQ additive_expr, AND / OR / RPAREN]
// [24, comparison_expr → • additive_expr NEQ additive_expr, AND / OR / RPAREN]
// [25, comparison_expr → • additive_expr LT additive_expr, AND / OR / RPAREN]
// [26, comparison_expr → • additive_expr LTE additive_expr, AND / OR / RPAREN]
// [27, comparison_expr → • additive_expr GT additive_expr, AND / OR / RPAREN]
// [28, comparison_expr → • additive_expr GTE additive_expr, AND / OR / RPAREN]
// [29, comparison_expr → • additive_expr IS NULL, AND / OR / RPAREN]
// [30, comparison_expr → • additive_expr IS NOT NULL, AND / OR / RPAREN]
// [31, additive_expr → • multiplicative_expr, IS / AND / OR / RPAREN / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, IS / AND / OR / RPAREN / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, IS / AND / OR / RPAREN / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [34, multiplicative_expr → • unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [37, unary_expr → • primary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [38, unary_expr → • PLUS unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [39, unary_expr → • MINUS unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [40, primary_expr → • identifier_path, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [41, primary_expr → • STRING_LITERAL, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [42, primary_expr → • INTEGER_LITERAL, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [43, primary_expr → • DOUBLE_LITERAL, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [44, primary_expr → • TRUE, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [45, primary_expr → • FALSE, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [46, primary_expr → • NULL, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [47, primary_expr → • LPAREN expr RPAREN, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [47, primary_expr → LPAREN • expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [49, identifier_path → • IDENT, IS / AND / OR / RPAREN / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [50, identifier_path → • identifier_path DOT IDENT, IS / AND / OR / RPAREN / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_15(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    NT_expr => Shift(yy_state_16)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_62)
    NT_and_expr => Shift(yy_state_63)
    NT_or_expr => Shift(yy_state_66)
    _ => Error
  }
}

// [47, primary_expr → LPAREN expr • RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_16(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_17)
    _ => Error
  }
}

// [47, primary_expr → LPAREN expr RPAREN •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_17(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_primary_expr, yy_action_48)
}

// [46, primary_expr → NULL •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_18(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_47)
}

// [45, primary_expr → FALSE •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_19(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_46)
}

// [44, primary_expr → TRUE •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_20(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_45)
}

// [43, primary_expr → DOUBLE_LITERAL •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_21(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_44)
}

// [42, primary_expr → INTEGER_LITERAL •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_22(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_43)
}

// [41, primary_expr → STRING_LITERAL •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_23(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_42)
}

// [40, primary_expr → identifier_path •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → identifier_path • DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_24(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_25)
    T_IDENT | T_FROM | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_PLUS | T_MINUS | T_STAR | T_SLASH | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(1, NT_primary_expr, yy_action_41)
    _ => Error
  }
}

// [50, identifier_path → identifier_path DOT • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_25(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_26)
    _ => Error
  }
}

// [50, identifier_path → identifier_path DOT IDENT •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_26(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_identifier_path, yy_action_40)
}

// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → MINUS • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_27(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    NT_unary_expr => Shift(yy_state_28)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    _ => Error
  }
}

// [39, unary_expr → MINUS unary_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_28(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_unary_expr, yy_action_39)
}

// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → PLUS • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_29(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_unary_expr => Shift(yy_state_30)
    NT_primary_expr => Shift(yy_state_31)
    _ => Error
  }
}

// [38, unary_expr → PLUS unary_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_30(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_unary_expr, yy_action_38)
}

// [37, unary_expr → primary_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_31(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_unary_expr, yy_action_37)
}

// [34, multiplicative_expr → unary_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_32(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_multiplicative_expr, yy_action_36)
}

// [31, additive_expr → multiplicative_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → multiplicative_expr • STAR unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → multiplicative_expr • SLASH unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_33(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_34)
    T_STAR => Shift(yy_state_36)
    T_IDENT | T_FROM | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_PLUS | T_MINUS | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(1, NT_additive_expr, yy_action_35)
    _ => Error
  }
}

// [36, multiplicative_expr → multiplicative_expr SLASH • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_34(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_35)
    _ => Error
  }
}

// [36, multiplicative_expr → multiplicative_expr SLASH unary_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_35(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_multiplicative_expr, yy_action_34)
}

// [35, multiplicative_expr → multiplicative_expr STAR • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_36(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_37)
    _ => Error
  }
}

// [35, multiplicative_expr → multiplicative_expr STAR unary_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_37(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_multiplicative_expr, yy_action_33)
}

// [22, comparison_expr → additive_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [23, comparison_expr → additive_expr • EQ additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [24, comparison_expr → additive_expr • NEQ additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [25, comparison_expr → additive_expr • LT additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [26, comparison_expr → additive_expr • LTE additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [27, comparison_expr → additive_expr • GT additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [28, comparison_expr → additive_expr • GTE additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [29, comparison_expr → additive_expr • IS NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [30, comparison_expr → additive_expr • IS NOT NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [32, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [33, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_38(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_39)
    T_PLUS => Shift(yy_state_41)
    T_IS => Shift(yy_state_43)
    T_GTE => Shift(yy_state_47)
    T_GT => Shift(yy_state_49)
    T_LTE => Shift(yy_state_51)
    T_LT => Shift(yy_state_53)
    T_NEQ => Shift(yy_state_55)
    T_EQ => Shift(yy_state_57)
    T_IDENT | T_FROM | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(1, NT_comparison_expr, yy_action_32)
    _ => Error
  }
}

// [33, additive_expr → additive_expr MINUS • multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_39(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_40)
    _ => Error
  }
}

// [33, additive_expr → additive_expr MINUS multiplicative_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → multiplicative_expr • STAR unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → multiplicative_expr • SLASH unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_40(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_34)
    T_STAR => Shift(yy_state_36)
    T_IDENT | T_FROM | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_PLUS | T_MINUS | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(3, NT_additive_expr, yy_action_31)
    _ => Error
  }
}

// [32, additive_expr → additive_expr PLUS • multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_41(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_42)
    _ => Error
  }
}

// [32, additive_expr → additive_expr PLUS multiplicative_expr •, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → multiplicative_expr • STAR unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → multiplicative_expr • SLASH unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_42(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_34)
    T_STAR => Shift(yy_state_36)
    T_IDENT | T_FROM | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_PLUS | T_MINUS | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(3, NT_additive_expr, yy_action_30)
    _ => Error
  }
}

// [29, comparison_expr → additive_expr IS • NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [30, comparison_expr → additive_expr IS • NOT NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_43(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_NOT => Shift(yy_state_44)
    T_NULL => Shift(yy_state_46)
    _ => Error
  }
}

// [30, comparison_expr → additive_expr IS NOT • NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_44(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_NULL => Shift(yy_state_45)
    _ => Error
  }
}

// [30, comparison_expr → additive_expr IS NOT NULL •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_45(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_comparison_expr, yy_action_29)
}

// [29, comparison_expr → additive_expr IS NULL •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_46(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_comparison_expr, yy_action_28)
}

// [28, comparison_expr → additive_expr GTE • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_47(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_48)
    _ => Error
  }
}

// [28, comparison_expr → additive_expr GTE additive_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [32, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_48(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_39)
    T_PLUS => Shift(yy_state_41)
    T_IDENT | T_FROM | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_27)
    _ => Error
  }
}

// [27, comparison_expr → additive_expr GT • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_49(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_50)
    _ => Error
  }
}

// [27, comparison_expr → additive_expr GT additive_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [32, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_50(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_39)
    T_PLUS => Shift(yy_state_41)
    T_IDENT | T_FROM | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_26)
    _ => Error
  }
}

// [26, comparison_expr → additive_expr LTE • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_51(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_52)
    _ => Error
  }
}

// [26, comparison_expr → additive_expr LTE additive_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [32, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_52(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_39)
    T_PLUS => Shift(yy_state_41)
    T_IDENT | T_FROM | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_25)
    _ => Error
  }
}

// [25, comparison_expr → additive_expr LT • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_53(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_54)
    _ => Error
  }
}

// [25, comparison_expr → additive_expr LT additive_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [32, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_54(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_39)
    T_PLUS => Shift(yy_state_41)
    T_IDENT | T_FROM | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_24)
    _ => Error
  }
}

// [24, comparison_expr → additive_expr NEQ • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_55(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_56)
    _ => Error
  }
}

// [24, comparison_expr → additive_expr NEQ additive_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [32, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_56(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_39)
    T_PLUS => Shift(yy_state_41)
    T_IDENT | T_FROM | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_23)
    _ => Error
  }
}

// [23, comparison_expr → additive_expr EQ • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_57(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_58)
    _ => Error
  }
}

// [23, comparison_expr → additive_expr EQ additive_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [32, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [33, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_58(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_39)
    T_PLUS => Shift(yy_state_41)
    T_IDENT | T_FROM | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_22)
    _ => Error
  }
}

// [20, not_expr → • comparison_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [21, not_expr → • NOT not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [21, not_expr → NOT • not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [22, comparison_expr → • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [23, comparison_expr → • additive_expr EQ additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [24, comparison_expr → • additive_expr NEQ additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [25, comparison_expr → • additive_expr LT additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [26, comparison_expr → • additive_expr LTE additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [27, comparison_expr → • additive_expr GT additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [28, comparison_expr → • additive_expr GTE additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [29, comparison_expr → • additive_expr IS NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [30, comparison_expr → • additive_expr IS NOT NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_59(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_not_expr => Shift(yy_state_60)
    NT_comparison_expr => Shift(yy_state_61)
    _ => Error
  }
}

// [21, not_expr → NOT not_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_60(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_not_expr, yy_action_21)
}

// [20, not_expr → comparison_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_61(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_not_expr, yy_action_20)
}

// [18, and_expr → not_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_62(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_and_expr, yy_action_19)
}

// [16, or_expr → and_expr •, $ / IDENT / FROM / AS / OR / RPAREN / COMMA / SEMICOLON]
// [19, and_expr → and_expr • AND not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_63(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_AND => Shift(yy_state_64)
    T_IDENT | T_FROM | T_AS | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(1, NT_or_expr, yy_action_18)
    _ => Error
  }
}

// [19, and_expr → and_expr AND • not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [20, not_expr → • comparison_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [21, not_expr → • NOT not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [22, comparison_expr → • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [23, comparison_expr → • additive_expr EQ additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [24, comparison_expr → • additive_expr NEQ additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [25, comparison_expr → • additive_expr LT additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [26, comparison_expr → • additive_expr LTE additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [27, comparison_expr → • additive_expr GT additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [28, comparison_expr → • additive_expr GTE additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [29, comparison_expr → • additive_expr IS NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [30, comparison_expr → • additive_expr IS NOT NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_64(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_65)
    _ => Error
  }
}

// [19, and_expr → and_expr AND not_expr •, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_65(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_and_expr, yy_action_17)
}

// [15, expr → or_expr •, $ / IDENT / FROM / AS / RPAREN / COMMA / SEMICOLON]
// [17, or_expr → or_expr • OR and_expr, $ / IDENT / FROM / AS / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_66(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_OR => Shift(yy_state_67)
    T_IDENT | T_FROM | T_AS | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(1, NT_expr, yy_action_16)
    _ => Error
  }
}

// [17, or_expr → or_expr OR • and_expr, $ / IDENT / FROM / AS / OR / RPAREN / COMMA / SEMICOLON]
// [18, and_expr → • not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [19, and_expr → • and_expr AND not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [20, not_expr → • comparison_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [21, not_expr → • NOT not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [22, comparison_expr → • additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [23, comparison_expr → • additive_expr EQ additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [24, comparison_expr → • additive_expr NEQ additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [25, comparison_expr → • additive_expr LT additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [26, comparison_expr → • additive_expr LTE additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [27, comparison_expr → • additive_expr GT additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [28, comparison_expr → • additive_expr GTE additive_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [29, comparison_expr → • additive_expr IS NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [30, comparison_expr → • additive_expr IS NOT NULL, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_67(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_62)
    NT_and_expr => Shift(yy_state_68)
    _ => Error
  }
}

// [17, or_expr → or_expr OR and_expr •, $ / IDENT / FROM / AS / OR / RPAREN / COMMA / SEMICOLON]
// [19, and_expr → and_expr • AND not_expr, $ / IDENT / FROM / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_68(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_AND => Shift(yy_state_64)
    T_IDENT | T_FROM | T_AS | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_or_expr, yy_action_15)
    _ => Error
  }
}

// [5, select_item → expr • opt_alias, FROM / COMMA]
// [6, opt_alias → •, FROM / COMMA]
// [7, opt_alias → • AS IDENT, FROM / COMMA]
// [8, opt_alias → • IDENT, FROM / COMMA]
fn yy_state_69(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_70)
    T_AS => Shift(yy_state_71)
    NT_opt_alias => Shift(yy_state_73)
    T_FROM | T_COMMA => Reduce(0, NT_opt_alias, yy_action_14)
    _ => Error
  }
}

// [8, opt_alias → IDENT •, FROM / COMMA]
fn yy_state_70(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_opt_alias, yy_action_13)
}

// [7, opt_alias → AS • IDENT, FROM / COMMA]
fn yy_state_71(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_72)
    _ => Error
  }
}

// [7, opt_alias → AS IDENT •, FROM / COMMA]
fn yy_state_72(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_opt_alias, yy_action_12)
}

// [5, select_item → expr opt_alias •, FROM / COMMA]
fn yy_state_73(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_select_item, yy_action_11)
}

// [3, select_list → select_item •, FROM / COMMA]
fn yy_state_74(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_select_list, yy_action_10)
}

// [0, query → SELECT select_list • FROM table_function opt_where opt_semicolon, $]
// [4, select_list → select_list • COMMA select_item, FROM / COMMA]
fn yy_state_75(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_76)
    T_FROM => Shift(yy_state_78)
    _ => Error
  }
}

// [4, select_list → select_list COMMA • select_item, FROM / COMMA]
// [5, select_item → • expr opt_alias, FROM / COMMA]
// [15, expr → • or_expr, IDENT / FROM / AS / COMMA]
// [16, or_expr → • and_expr, IDENT / FROM / AS / OR / COMMA]
// [17, or_expr → • or_expr OR and_expr, IDENT / FROM / AS / OR / COMMA]
// [18, and_expr → • not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [19, and_expr → • and_expr AND not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [20, not_expr → • comparison_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [21, not_expr → • NOT not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [22, comparison_expr → • additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [23, comparison_expr → • additive_expr EQ additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [24, comparison_expr → • additive_expr NEQ additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [25, comparison_expr → • additive_expr LT additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [26, comparison_expr → • additive_expr LTE additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [27, comparison_expr → • additive_expr GT additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [28, comparison_expr → • additive_expr GTE additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [29, comparison_expr → • additive_expr IS NULL, IDENT / FROM / AS / AND / OR / COMMA]
// [30, comparison_expr → • additive_expr IS NOT NULL, IDENT / FROM / AS / AND / OR / COMMA]
// [31, additive_expr → • multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [34, multiplicative_expr → • unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [37, unary_expr → • primary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [38, unary_expr → • PLUS unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [39, unary_expr → • MINUS unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [40, primary_expr → • identifier_path, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [41, primary_expr → • STRING_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [42, primary_expr → • INTEGER_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [43, primary_expr → • DOUBLE_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [44, primary_expr → • TRUE, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [45, primary_expr → • FALSE, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [46, primary_expr → • NULL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [47, primary_expr → • LPAREN expr RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [49, identifier_path → • IDENT, IDENT / FROM / AS / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [50, identifier_path → • identifier_path DOT IDENT, IDENT / FROM / AS / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_76(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_62)
    NT_and_expr => Shift(yy_state_63)
    NT_or_expr => Shift(yy_state_66)
    NT_expr => Shift(yy_state_69)
    NT_select_item => Shift(yy_state_77)
    _ => Error
  }
}

// [4, select_list → select_list COMMA select_item •, FROM / COMMA]
fn yy_state_77(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_select_list, yy_action_9)
}

// [0, query → SELECT select_list FROM • table_function opt_where opt_semicolon, $]
// [9, table_function → • IDENT LPAREN RPAREN, $ / WHERE / SEMICOLON]
// [10, table_function → • IDENT LPAREN argument_list RPAREN, $ / WHERE / SEMICOLON]
fn yy_state_78(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_79)
    NT_table_function => Shift(yy_state_87)
    _ => Error
  }
}

// [9, table_function → IDENT • LPAREN RPAREN, $ / WHERE / SEMICOLON]
// [10, table_function → IDENT • LPAREN argument_list RPAREN, $ / WHERE / SEMICOLON]
fn yy_state_79(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_80)
    _ => Error
  }
}

// [9, table_function → IDENT LPAREN • RPAREN, $ / WHERE / SEMICOLON]
// [10, table_function → IDENT LPAREN • argument_list RPAREN, $ / WHERE / SEMICOLON]
// [11, argument_list → • expr, RPAREN / COMMA]
// [12, argument_list → • argument_list COMMA expr, RPAREN / COMMA]
// [15, expr → • or_expr, RPAREN / COMMA]
// [16, or_expr → • and_expr, OR / RPAREN / COMMA]
// [17, or_expr → • or_expr OR and_expr, OR / RPAREN / COMMA]
// [18, and_expr → • not_expr, AND / OR / RPAREN / COMMA]
// [19, and_expr → • and_expr AND not_expr, AND / OR / RPAREN / COMMA]
// [20, not_expr → • comparison_expr, AND / OR / RPAREN / COMMA]
// [21, not_expr → • NOT not_expr, AND / OR / RPAREN / COMMA]
// [22, comparison_expr → • additive_expr, AND / OR / RPAREN / COMMA]
// [23, comparison_expr → • additive_expr EQ additive_expr, AND / OR / RPAREN / COMMA]
// [24, comparison_expr → • additive_expr NEQ additive_expr, AND / OR / RPAREN / COMMA]
// [25, comparison_expr → • additive_expr LT additive_expr, AND / OR / RPAREN / COMMA]
// [26, comparison_expr → • additive_expr LTE additive_expr, AND / OR / RPAREN / COMMA]
// [27, comparison_expr → • additive_expr GT additive_expr, AND / OR / RPAREN / COMMA]
// [28, comparison_expr → • additive_expr GTE additive_expr, AND / OR / RPAREN / COMMA]
// [29, comparison_expr → • additive_expr IS NULL, AND / OR / RPAREN / COMMA]
// [30, comparison_expr → • additive_expr IS NOT NULL, AND / OR / RPAREN / COMMA]
// [31, additive_expr → • multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [34, multiplicative_expr → • unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [37, unary_expr → • primary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [38, unary_expr → • PLUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [39, unary_expr → • MINUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [40, primary_expr → • identifier_path, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [41, primary_expr → • STRING_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [42, primary_expr → • INTEGER_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [43, primary_expr → • DOUBLE_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [44, primary_expr → • TRUE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [45, primary_expr → • FALSE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [46, primary_expr → • NULL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [47, primary_expr → • LPAREN expr RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [49, identifier_path → • IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [50, identifier_path → • identifier_path DOT IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_80(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_62)
    NT_and_expr => Shift(yy_state_63)
    NT_or_expr => Shift(yy_state_66)
    NT_expr => Shift(yy_state_81)
    NT_argument_list => Shift(yy_state_82)
    T_RPAREN => Shift(yy_state_86)
    _ => Error
  }
}

// [11, argument_list → expr •, RPAREN / COMMA]
fn yy_state_81(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_argument_list, yy_action_8)
}

// [10, table_function → IDENT LPAREN argument_list • RPAREN, $ / WHERE / SEMICOLON]
// [12, argument_list → argument_list • COMMA expr, RPAREN / COMMA]
fn yy_state_82(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_83)
    T_RPAREN => Shift(yy_state_85)
    _ => Error
  }
}

// [12, argument_list → argument_list COMMA • expr, RPAREN / COMMA]
// [15, expr → • or_expr, RPAREN / COMMA]
// [16, or_expr → • and_expr, OR / RPAREN / COMMA]
// [17, or_expr → • or_expr OR and_expr, OR / RPAREN / COMMA]
// [18, and_expr → • not_expr, AND / OR / RPAREN / COMMA]
// [19, and_expr → • and_expr AND not_expr, AND / OR / RPAREN / COMMA]
// [20, not_expr → • comparison_expr, AND / OR / RPAREN / COMMA]
// [21, not_expr → • NOT not_expr, AND / OR / RPAREN / COMMA]
// [22, comparison_expr → • additive_expr, AND / OR / RPAREN / COMMA]
// [23, comparison_expr → • additive_expr EQ additive_expr, AND / OR / RPAREN / COMMA]
// [24, comparison_expr → • additive_expr NEQ additive_expr, AND / OR / RPAREN / COMMA]
// [25, comparison_expr → • additive_expr LT additive_expr, AND / OR / RPAREN / COMMA]
// [26, comparison_expr → • additive_expr LTE additive_expr, AND / OR / RPAREN / COMMA]
// [27, comparison_expr → • additive_expr GT additive_expr, AND / OR / RPAREN / COMMA]
// [28, comparison_expr → • additive_expr GTE additive_expr, AND / OR / RPAREN / COMMA]
// [29, comparison_expr → • additive_expr IS NULL, AND / OR / RPAREN / COMMA]
// [30, comparison_expr → • additive_expr IS NOT NULL, AND / OR / RPAREN / COMMA]
// [31, additive_expr → • multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [34, multiplicative_expr → • unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [37, unary_expr → • primary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [38, unary_expr → • PLUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [39, unary_expr → • MINUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [40, primary_expr → • identifier_path, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [41, primary_expr → • STRING_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [42, primary_expr → • INTEGER_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [43, primary_expr → • DOUBLE_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [44, primary_expr → • TRUE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [45, primary_expr → • FALSE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [46, primary_expr → • NULL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [47, primary_expr → • LPAREN expr RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [49, identifier_path → • IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [50, identifier_path → • identifier_path DOT IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_83(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_62)
    NT_and_expr => Shift(yy_state_63)
    NT_or_expr => Shift(yy_state_66)
    NT_expr => Shift(yy_state_84)
    _ => Error
  }
}

// [12, argument_list → argument_list COMMA expr •, RPAREN / COMMA]
fn yy_state_84(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_argument_list, yy_action_7)
}

// [10, table_function → IDENT LPAREN argument_list RPAREN •, $ / WHERE / SEMICOLON]
fn yy_state_85(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_table_function, yy_action_6)
}

// [9, table_function → IDENT LPAREN RPAREN •, $ / WHERE / SEMICOLON]
fn yy_state_86(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_table_function, yy_action_5)
}

// [0, query → SELECT select_list FROM table_function • opt_where opt_semicolon, $]
// [13, opt_where → •, $ / SEMICOLON]
// [14, opt_where → • WHERE expr, $ / SEMICOLON]
fn yy_state_87(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_WHERE => Shift(yy_state_88)
    NT_opt_where => Shift(yy_state_90)
    T_SEMICOLON | EOI => Reduce(0, NT_opt_where, yy_action_4)
    _ => Error
  }
}

// [14, opt_where → WHERE • expr, $ / SEMICOLON]
// [15, expr → • or_expr, $ / SEMICOLON]
// [16, or_expr → • and_expr, $ / OR / SEMICOLON]
// [17, or_expr → • or_expr OR and_expr, $ / OR / SEMICOLON]
// [18, and_expr → • not_expr, $ / AND / OR / SEMICOLON]
// [19, and_expr → • and_expr AND not_expr, $ / AND / OR / SEMICOLON]
// [20, not_expr → • comparison_expr, $ / AND / OR / SEMICOLON]
// [21, not_expr → • NOT not_expr, $ / AND / OR / SEMICOLON]
// [22, comparison_expr → • additive_expr, $ / AND / OR / SEMICOLON]
// [23, comparison_expr → • additive_expr EQ additive_expr, $ / AND / OR / SEMICOLON]
// [24, comparison_expr → • additive_expr NEQ additive_expr, $ / AND / OR / SEMICOLON]
// [25, comparison_expr → • additive_expr LT additive_expr, $ / AND / OR / SEMICOLON]
// [26, comparison_expr → • additive_expr LTE additive_expr, $ / AND / OR / SEMICOLON]
// [27, comparison_expr → • additive_expr GT additive_expr, $ / AND / OR / SEMICOLON]
// [28, comparison_expr → • additive_expr GTE additive_expr, $ / AND / OR / SEMICOLON]
// [29, comparison_expr → • additive_expr IS NULL, $ / AND / OR / SEMICOLON]
// [30, comparison_expr → • additive_expr IS NOT NULL, $ / AND / OR / SEMICOLON]
// [31, additive_expr → • multiplicative_expr, $ / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [32, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [33, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [34, multiplicative_expr → • unary_expr, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [35, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [36, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [37, unary_expr → • primary_expr, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [38, unary_expr → • PLUS unary_expr, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [39, unary_expr → • MINUS unary_expr, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [40, primary_expr → • identifier_path, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [41, primary_expr → • STRING_LITERAL, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [42, primary_expr → • INTEGER_LITERAL, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [43, primary_expr → • DOUBLE_LITERAL, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [44, primary_expr → • TRUE, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [45, primary_expr → • FALSE, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [46, primary_expr → • NULL, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [47, primary_expr → • LPAREN expr RPAREN, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [48, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [49, identifier_path → • IDENT, $ / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [50, identifier_path → • identifier_path DOT IDENT, $ / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_88(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_4)
    T_LPAREN => Shift(yy_state_15)
    T_NULL => Shift(yy_state_18)
    T_FALSE => Shift(yy_state_19)
    T_TRUE => Shift(yy_state_20)
    T_DOUBLE_LITERAL => Shift(yy_state_21)
    T_INTEGER_LITERAL => Shift(yy_state_22)
    T_STRING_LITERAL => Shift(yy_state_23)
    NT_identifier_path => Shift(yy_state_24)
    T_MINUS => Shift(yy_state_27)
    T_PLUS => Shift(yy_state_29)
    NT_primary_expr => Shift(yy_state_31)
    NT_unary_expr => Shift(yy_state_32)
    NT_multiplicative_expr => Shift(yy_state_33)
    NT_additive_expr => Shift(yy_state_38)
    T_NOT => Shift(yy_state_59)
    NT_comparison_expr => Shift(yy_state_61)
    NT_not_expr => Shift(yy_state_62)
    NT_and_expr => Shift(yy_state_63)
    NT_or_expr => Shift(yy_state_66)
    NT_expr => Shift(yy_state_89)
    _ => Error
  }
}

// [14, opt_where → WHERE expr •, $ / SEMICOLON]
fn yy_state_89(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_opt_where, yy_action_3)
}

// [0, query → SELECT select_list FROM table_function opt_where • opt_semicolon, $]
// [1, opt_semicolon → •, $]
// [2, opt_semicolon → • SEMICOLON, $]
fn yy_state_90(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SEMICOLON => Shift(yy_state_91)
    NT_opt_semicolon => Shift(yy_state_92)
    EOI => Reduce(0, NT_opt_semicolon, yy_action_2)
    _ => Error
  }
}

// [2, opt_semicolon → SEMICOLON •, $]
fn yy_state_91(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_opt_semicolon, yy_action_1)
}

// [0, query → SELECT select_list FROM table_function opt_where opt_semicolon •, $]
fn yy_state_92(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(6, NT_query, yy_action_0)
}

fn[T] yy_parse(
  tokens : Array[(Token, Int, Int)],
  start : YYState,
  return_ : (YYObj) -> T,
  initial_pos? : Int,
) -> T raise ParseError {
  let mut cursor = 0
  let mut state_stack : @list.List[YYState] = @list.cons(start, @list.empty())
  let data_stack : Array[(YYObj, Int, Int)] = []
  let mut last_pos = initial_pos.unwrap_or(tokens[0].1)
  let mut state = start
  let mut lookahead : Option[(YYSymbol, (YYObj, Int, Int), Token?)] = None
  let mut last_shifted_state_stack = state_stack
  while true {
    let decision = match state(EOI) {
      ReduceNoLookahead(_) | Accept as t => t
      _ => {
        match lookahead {
          Some(la) => state(la.0)
          None => {
            if cursor < tokens.length() {
              let (token, start_pos, end_pos) = tokens[cursor]
              cursor += 1
              let (symbol, data) = yy_input(token, start_pos, end_pos)
              lookahead = Some((symbol, (data, start_pos, end_pos), Some(token)))
              state(symbol)
            } else {
              lookahead = Some((EOI, (YYObj_Void, last_pos, last_pos), None))
              state(EOI)
            }
          }
        }
      }
    }
    match decision {
      Accept => return return_(data_stack.unsafe_pop().0)
      Shift(next_state) => {
        guard lookahead is Some(la)
        data_stack.push(la.1)
        state_stack = @list.cons(next_state, state_stack)
        last_shifted_state_stack = state_stack
        state = next_state
        last_pos = la.1.2
        lookahead = None
      }
      Reduce(count, symbol, action)
      | ReduceNoLookahead(count, symbol, action) => {
        loop (count, symbol, action) {
          _ => {
            let args = data_stack[data_stack.length() - count:]
            let data = action(last_pos, args)
            let (start_pos, end_pos) = if args.length() == 0 {
              (last_pos, last_pos)
            } else {
              (args[0].1, args[args.length() - 1].2)
            }
            for _ in 0..<count {
              ignore(data_stack.unsafe_pop())
              state_stack = state_stack.unsafe_tail()
            }
            state = state_stack.unsafe_head()
            data_stack.push((data, start_pos, end_pos))
            match state(symbol) {
              Accept => return return_(data_stack.unsafe_pop().0)
              Shift(next_state) => {
                state_stack = @list.cons(next_state, state_stack)
                state = next_state
              }
              Reduce(count, symbol, action)
              | ReduceNoLookahead(count, symbol, action) => continue (count, symbol, action)
              _ => panic()
            }
          }
        }
      }
      Error => {
        let (_, (_, start_pos, end_pos), token) = lookahead.unwrap()
        error(last_shifted_state_stack, token, (start_pos, end_pos))
      }
    }
  }
  panic()
}

fn error(stack : @list.List[YYState], token : Token?, loc : (Int, Int)) -> Unit raise ParseError {
  let expected = []
  fn try_add(symbol : YYSymbol, kind : TokenKind) {
    fn go(stack : @list.List[YYState]) {
      match stack {
        Empty => ()
        More(state, ..) => {
          match state(symbol) {
            Accept | Shift(_) => expected.push(kind)
            Reduce(count, symbol, _) | ReduceNoLookahead(count, symbol, _) => {
              fn inner_go(stack : @list.List[YYState], count, symbol) {
                let stack = stack.drop(count)
                guard stack is More(state, ..)
                match state(symbol) {
                  Shift(state) => go(@list.cons(state, stack))
                  Reduce(count, symbol, _) | ReduceNoLookahead(count, symbol, _) => inner_go(stack, count, symbol)
                  _ => panic()
                }
              }
              inner_go(stack, count, symbol)
            }
            Error => ()
          }
        }
      }
    }
    go(stack)
  }
  for term in ([(T_IDENT, TK_IDENT), (T_STRING_LITERAL, TK_STRING_LITERAL), (T_INTEGER_LITERAL, TK_INTEGER_LITERAL), (T_DOUBLE_LITERAL, TK_DOUBLE_LITERAL), (T_SELECT, TK_SELECT), (T_FROM, TK_FROM), (T_WHERE, TK_WHERE), (T_AS, TK_AS), (T_CAST, TK_CAST), (T_IS, TK_IS), (T_NULL, TK_NULL), (T_NOT, TK_NOT), (T_AND, TK_AND), (T_OR, TK_OR), (T_TRUE, TK_TRUE), (T_FALSE, TK_FALSE), (T_BOOLEAN_T, TK_BOOLEAN_T), (T_BIGINT_T, TK_BIGINT_T), (T_DOUBLE_T, TK_DOUBLE_T), (T_VARCHAR_T, TK_VARCHAR_T), (T_LPAREN, TK_LPAREN), (T_RPAREN, TK_RPAREN), (T_COMMA, TK_COMMA), (T_DOT, TK_DOT), (T_PLUS, TK_PLUS), (T_MINUS, TK_MINUS), (T_STAR, TK_STAR), (T_SLASH, TK_SLASH), (T_EQ, TK_EQ), (T_NEQ, TK_NEQ), (T_LT, TK_LT), (T_LTE, TK_LTE), (T_GT, TK_GT), (T_GTE, TK_GTE), (T_SEMICOLON, TK_SEMICOLON)] : Array[(YYSymbol, TokenKind)]) {
    try_add(term.0, term.1)
  }
  match token {
    None => raise UnexpectedEndOfInput(loc.1, expected)
    Some(token) => raise UnexpectedToken(token, loc, expected)
  }
}

pub fn query(tokens : Array[(Token, Int, Int)], initial_pos? : Int) -> Query raise ParseError {
  yy_parse(
    tokens,
    yy_state_0,
    (it) => {
      guard it is YYObj_Query(result)
      result
    },
    initial_pos?,
  )
}

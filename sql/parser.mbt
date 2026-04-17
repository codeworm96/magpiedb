
pub(all) enum Token {
  IDENT(String)
  STRING_LITERAL(String)
  INTEGER_LITERAL(String)
  DOUBLE_LITERAL(String)
  SELECT
  FROM
  WHERE
  GROUP
  BY
  HAVING
  ORDER
  LIMIT
  JOIN
  INNER
  ON
  ASC
  DESC
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
} derive(Debug)

pub fn Token::kind(self : Token) -> TokenKind {
  match self {
    IDENT(_) => TK_IDENT
    STRING_LITERAL(_) => TK_STRING_LITERAL
    INTEGER_LITERAL(_) => TK_INTEGER_LITERAL
    DOUBLE_LITERAL(_) => TK_DOUBLE_LITERAL
    SELECT => TK_SELECT
    FROM => TK_FROM
    WHERE => TK_WHERE
    GROUP => TK_GROUP
    BY => TK_BY
    HAVING => TK_HAVING
    ORDER => TK_ORDER
    LIMIT => TK_LIMIT
    JOIN => TK_JOIN
    INNER => TK_INNER
    ON => TK_ON
    ASC => TK_ASC
    DESC => TK_DESC
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
  TK_GROUP
  TK_BY
  TK_HAVING
  TK_ORDER
  TK_LIMIT
  TK_JOIN
  TK_INNER
  TK_ON
  TK_ASC
  TK_DESC
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
      TK_GROUP => "\"GROUP\""
      TK_BY => "\"BY\""
      TK_HAVING => "\"HAVING\""
      TK_ORDER => "\"ORDER\""
      TK_LIMIT => "\"LIMIT\""
      TK_JOIN => "\"JOIN\""
      TK_INNER => "\"INNER\""
      TK_ON => "\"ON\""
      TK_ASC => "\"ASC\""
      TK_DESC => "\"DESC\""
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

pub impl Debug for TokenKind with to_repr(self) {
    match self {
      TK_IDENT => to_repr("IDENT")
      TK_STRING_LITERAL => to_repr("STRING_LITERAL")
      TK_INTEGER_LITERAL => to_repr("INTEGER_LITERAL")
      TK_DOUBLE_LITERAL => to_repr("DOUBLE_LITERAL")
      TK_SELECT => to_repr("SELECT")
      TK_FROM => to_repr("FROM")
      TK_WHERE => to_repr("WHERE")
      TK_GROUP => to_repr("GROUP")
      TK_BY => to_repr("BY")
      TK_HAVING => to_repr("HAVING")
      TK_ORDER => to_repr("ORDER")
      TK_LIMIT => to_repr("LIMIT")
      TK_JOIN => to_repr("JOIN")
      TK_INNER => to_repr("INNER")
      TK_ON => to_repr("ON")
      TK_ASC => to_repr("ASC")
      TK_DESC => to_repr("DESC")
      TK_AS => to_repr("AS")
      TK_CAST => to_repr("CAST")
      TK_IS => to_repr("IS")
      TK_NULL => to_repr("NULL")
      TK_NOT => to_repr("NOT")
      TK_AND => to_repr("AND")
      TK_OR => to_repr("OR")
      TK_TRUE => to_repr("TRUE")
      TK_FALSE => to_repr("FALSE")
      TK_BOOLEAN_T => to_repr("BOOLEAN")
      TK_BIGINT_T => to_repr("BIGINT")
      TK_DOUBLE_T => to_repr("DOUBLE")
      TK_VARCHAR_T => to_repr("VARCHAR")
      TK_LPAREN => to_repr("(")
      TK_RPAREN => to_repr(")")
      TK_COMMA => to_repr(",")
      TK_DOT => to_repr(".")
      TK_PLUS => to_repr("+")
      TK_MINUS => to_repr("-")
      TK_STAR => to_repr("*")
      TK_SLASH => to_repr("/")
      TK_EQ => to_repr("=")
      TK_NEQ => to_repr("!=")
      TK_LT => to_repr("<")
      TK_LTE => to_repr("<=")
      TK_GT => to_repr(">")
      TK_GTE => to_repr(">=")
      TK_SEMICOLON => to_repr(";")
    }
}

pub suberror ParseError {
  UnexpectedToken(Token, (Int, Int), Array[TokenKind])
  UnexpectedEndOfInput(Int, Array[TokenKind])
} derive(Debug)

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

priv suberror YYObj_Array_Array_String__ {
  YYObj_Array_Array_String__(Array[Array[String]])
}

priv suberror YYObj_Array_String_ {
  YYObj_Array_String_(Array[String])
}

priv suberror YYObj_Array_SelectItem_ {
  YYObj_Array_SelectItem_(Array[SelectItem])
}

priv suberror YYObj_Array_OrderByItem_ {
  YYObj_Array_OrderByItem_(Array[OrderByItem])
}

priv suberror YYObj_Query {
  YYObj_Query(Query)
}

priv suberror YYObj_String {
  YYObj_String(String)
}

priv suberror YYObj_FromItem {
  YYObj_FromItem(FromItem)
}

priv suberror YYObj_TypeName {
  YYObj_TypeName(TypeName)
}

priv suberror YYObj_SourceRef {
  YYObj_SourceRef(SourceRef)
}

priv suberror YYObj_SelectItem {
  YYObj_SelectItem(SelectItem)
}

priv suberror YYObj_OrderByItem {
  YYObj_OrderByItem(OrderByItem)
}

priv suberror YYObj_SortDirection {
  YYObj_SortDirection(SortDirection)
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
  T_GROUP
  T_BY
  T_HAVING
  T_ORDER
  T_LIMIT
  T_JOIN
  T_INNER
  T_ON
  T_ASC
  T_DESC
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
  NT_from_item
  NT_table_function
  NT_source_ref
  NT_opt_source_alias
  NT_argument_list
  NT_opt_where
  NT_opt_group_by
  NT_group_key_list
  NT_opt_having
  NT_opt_order_by
  NT_order_by_list
  NT_order_by_item
  NT_opt_sort_direction
  NT_opt_limit
  NT_expr
  NT_or_expr
  NT_and_expr
  NT_not_expr
  NT_comparison_expr
  NT_additive_expr
  NT_multiplicative_expr
  NT_unary_expr
  NT_primary_expr
  NT_function_call_expr
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
// 87|    "SELECT" select_list "FROM" from_item opt_where opt_group_by opt_having opt_order_by opt_limit opt_semicolon
// 88|      { make_query($2, $4, $5, $6, $7, $8, $9) }
fn yy_action_0(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Array_SelectItem_(_dollar2)
  guard _args[3].0 is YYObj_FromItem(_dollar4)
  guard _args[4].0 is YYObj_Expr_(_dollar5)
  guard _args[5].0 is YYObj_Array_Array_String__(_dollar6)
  guard _args[6].0 is YYObj_Expr_(_dollar7)
  guard _args[7].0 is YYObj_Array_OrderByItem_(_dollar8)
  guard _args[8].0 is YYObj_String_(_dollar9)
  YYObj_Query({();  make_query(_dollar2, _dollar4, _dollar5, _dollar6, _dollar7, _dollar8, _dollar9) })
}

// file:///./parser.mbty
// 94|    ";"
// 95|      { () }
fn yy_action_1(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Unit({();  () })
}

// file:///./parser.mbty
// 92|   
// 93|      { () }
fn yy_action_2(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Unit({();  () })
}

// file:///./parser.mbty
// 217|    "LIMIT" INTEGER_LITERAL
// 218|      { Some($2) }
fn yy_action_3(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  YYObj_String_({();  Some(_dollar2) })
}

// file:///./parser.mbty
// 215|   
// 216|      { None }
fn yy_action_4(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_String_({();  None })
}

// file:///./parser.mbty
// 196|    order_by_list "," order_by_item
// 197|      { push_order_by_item($1, $3) }
fn yy_action_5(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_OrderByItem_(_dollar1)
  guard _args[2].0 is YYObj_OrderByItem(_dollar3)
  YYObj_Array_OrderByItem_({();  push_order_by_item(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 189|    "ORDER" "BY" order_by_list
// 190|      { $3 }
fn yy_action_6(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[2].0 is YYObj_Array_OrderByItem_(_dollar3)
  YYObj_Array_OrderByItem_({();  _dollar3 })
}

// file:///./parser.mbty
// 194|    order_by_item
// 195|      { [$1] }
fn yy_action_7(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_OrderByItem(_dollar1)
  YYObj_Array_OrderByItem_({();  [_dollar1] })
}

// file:///./parser.mbty
// 201|    expr opt_sort_direction
// 202|      { make_order_by_item($1, $2) }
fn yy_action_8(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[1].0 is YYObj_SortDirection(_dollar2)
  YYObj_OrderByItem({();  make_order_by_item(_dollar1, _dollar2) })
}

// file:///./parser.mbty
// 208|    "ASC"
// 209|      { SortDirection::Asc }
fn yy_action_9(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_SortDirection({();  SortDirection::Asc })
}

// file:///./parser.mbty
// 210|    "DESC"
// 211|      { SortDirection::Desc }
fn yy_action_10(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_SortDirection({();  SortDirection::Desc })
}

// file:///./parser.mbty
// 206|   
// 207|      { SortDirection::Asc }
fn yy_action_11(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_SortDirection({();  SortDirection::Asc })
}

// file:///./parser.mbty
// 187|   
// 188|      { [] }
fn yy_action_12(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Array_OrderByItem_({();  [] })
}

// file:///./parser.mbty
// 182|    "HAVING" expr
// 183|      { Some($2) }
fn yy_action_13(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr_({();  Some(_dollar2) })
}

// file:///./parser.mbty
// 180|   
// 181|      { None }
fn yy_action_14(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr_({();  None })
}

// file:///./parser.mbty
// 175|    group_key_list "," identifier_path
// 176|      { push_group_key($1, $3) }
fn yy_action_15(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_Array_String__(_dollar1)
  guard _args[2].0 is YYObj_Array_String_(_dollar3)
  YYObj_Array_Array_String__({();  push_group_key(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 168|    "GROUP" "BY" group_key_list
// 169|      { $3 }
fn yy_action_16(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[2].0 is YYObj_Array_Array_String__(_dollar3)
  YYObj_Array_Array_String__({();  _dollar3 })
}

// file:///./parser.mbty
// 173|    identifier_path
// 174|      { [$1] }
fn yy_action_17(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_String_(_dollar1)
  YYObj_Array_Array_String__({();  [_dollar1] })
}

// file:///./parser.mbty
// 166|   
// 167|      { [] }
fn yy_action_18(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Array_Array_String__({();  [] })
}

// file:///./parser.mbty
// 161|    "WHERE" expr
// 162|      { Some($2) }
fn yy_action_19(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr_({();  Some(_dollar2) })
}

// file:///./parser.mbty
// 159|   
// 160|      { None }
fn yy_action_20(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr_({();  None })
}

// file:///./parser.mbty
// 122|    source_ref "JOIN" source_ref "ON" expr
// 123|      { make_join_from_item($1, $3, $5) }
fn yy_action_21(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_SourceRef(_dollar1)
  guard _args[2].0 is YYObj_SourceRef(_dollar3)
  guard _args[4].0 is YYObj_Expr(_dollar5)
  YYObj_FromItem({();  make_join_from_item(_dollar1, _dollar3, _dollar5) })
}

// file:///./parser.mbty
// 124|    source_ref "INNER" "JOIN" source_ref "ON" expr
// 125|      { make_join_from_item($1, $4, $6) }
fn yy_action_22(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_SourceRef(_dollar1)
  guard _args[3].0 is YYObj_SourceRef(_dollar4)
  guard _args[5].0 is YYObj_Expr(_dollar6)
  YYObj_FromItem({();  make_join_from_item(_dollar1, _dollar4, _dollar6) })
}

// file:///./parser.mbty
// 120|    source_ref
// 121|      { make_source_from_item($1) }
fn yy_action_23(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_SourceRef(_dollar1)
  YYObj_FromItem({();  make_source_from_item(_dollar1) })
}

// file:///./parser.mbty
// 129|    IDENT "(" ")"
// 130|      { make_table_function($1, []) }
fn yy_action_24(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_TableFunction({();  make_table_function(_dollar1, []) })
}

// file:///./parser.mbty
// 131|    IDENT "(" argument_list ")"
// 132|      { make_table_function($1, $3) }
fn yy_action_25(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Array_Expr_(_dollar3)
  YYObj_TableFunction({();  make_table_function(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 136|    table_function opt_source_alias
// 137|      { make_source_ref($1, $2) }
fn yy_action_26(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_TableFunction(_dollar1)
  guard _args[1].0 is YYObj_String_(_dollar2)
  YYObj_SourceRef({();  make_source_ref(_dollar1, _dollar2) })
}

// file:///./parser.mbty
// 138|    STRING_LITERAL opt_source_alias
// 139|      { make_path_source_ref($1, $2) }
fn yy_action_27(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[1].0 is YYObj_String_(_dollar2)
  YYObj_SourceRef({();  make_path_source_ref(_dollar1, _dollar2) })
}

// file:///./parser.mbty
// 145|    "AS" IDENT
// 146|      { Some($2) }
fn yy_action_28(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  YYObj_String_({();  Some(_dollar2) })
}

// file:///./parser.mbty
// 147|    IDENT
// 148|      { Some($1) }
fn yy_action_29(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_String_({();  Some(_dollar1) })
}

// file:///./parser.mbty
// 143|   
// 144|      { None }
fn yy_action_30(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_String_({();  None })
}

// file:///./parser.mbty
// 101|    select_list "," select_item
// 102|      { push_select_item($1, $3) }
fn yy_action_31(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_SelectItem_(_dollar1)
  guard _args[2].0 is YYObj_SelectItem(_dollar3)
  YYObj_Array_SelectItem_({();  push_select_item(_dollar1, _dollar3) })
}

// file:///./parser.mbty
//  99|    select_item
// 100|      { [$1] }
fn yy_action_32(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_SelectItem(_dollar1)
  YYObj_Array_SelectItem_({();  [_dollar1] })
}

// file:///./parser.mbty
// 106|    expr opt_alias
// 107|      { make_select_item($1, $2) }
fn yy_action_33(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[1].0 is YYObj_String_(_dollar2)
  YYObj_SelectItem({();  make_select_item(_dollar1, _dollar2) })
}

// file:///./parser.mbty
// 113|    "AS" IDENT
// 114|      { Some($2) }
fn yy_action_34(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_String(_dollar2)
  YYObj_String_({();  Some(_dollar2) })
}

// file:///./parser.mbty
// 115|    IDENT
// 116|      { Some($1) }
fn yy_action_35(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_String_({();  Some(_dollar1) })
}

// file:///./parser.mbty
// 111|   
// 112|      { None }
fn yy_action_36(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_String_({();  None })
}

// file:///./parser.mbty
// 152|    expr
// 153|      { [$1] }
fn yy_action_37(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Array_Expr_({();  [_dollar1] })
}

// file:///./parser.mbty
// 154|    argument_list "," expr
// 155|      { push_expr($1, $3) }
fn yy_action_38(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_Expr_(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Array_Expr_({();  push_expr(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 321|    IDENT "(" argument_list ")"
// 322|      { Expr::FunctionCall($1, $3) }
fn yy_action_39(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  guard _args[2].0 is YYObj_Array_Expr_(_dollar3)
  YYObj_Expr({();  Expr::FunctionCall(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 229|    or_expr "OR" and_expr
// 230|      { Expr::Binary(BinaryOp::Or, $1, $3) }
fn yy_action_40(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Or, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 222|    or_expr
// 223|      { $1 }
fn yy_action_41(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 236|    and_expr "AND" not_expr
// 237|      { Expr::Binary(BinaryOp::And, $1, $3) }
fn yy_action_42(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::And, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 227|    and_expr
// 228|      { $1 }
fn yy_action_43(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 234|    not_expr
// 235|      { $1 }
fn yy_action_44(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 241|    comparison_expr
// 242|      { $1 }
fn yy_action_45(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 243|    "NOT" not_expr
// 244|      { Expr::Unary(UnaryOp::Not, $2) }
fn yy_action_46(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  Expr::Unary(UnaryOp::Not, _dollar2) })
}

// file:///./parser.mbty
// 250|    additive_expr "=" additive_expr
// 251|      { Expr::Binary(BinaryOp::Equal, $1, $3) }
fn yy_action_47(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Equal, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 252|    additive_expr "!=" additive_expr
// 253|      { Expr::Binary(BinaryOp::NotEqual, $1, $3) }
fn yy_action_48(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::NotEqual, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 254|    additive_expr "<" additive_expr
// 255|      { Expr::Binary(BinaryOp::LessThan, $1, $3) }
fn yy_action_49(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::LessThan, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 256|    additive_expr "<=" additive_expr
// 257|      { Expr::Binary(BinaryOp::LessThanOrEqual, $1, $3) }
fn yy_action_50(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::LessThanOrEqual, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 258|    additive_expr ">" additive_expr
// 259|      { Expr::Binary(BinaryOp::GreaterThan, $1, $3) }
fn yy_action_51(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::GreaterThan, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 260|    additive_expr ">=" additive_expr
// 261|      { Expr::Binary(BinaryOp::GreaterThanOrEqual, $1, $3) }
fn yy_action_52(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::GreaterThanOrEqual, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 262|    additive_expr "IS" "NULL"
// 263|      { Expr::IsNull($1) }
fn yy_action_53(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  Expr::IsNull(_dollar1) })
}

// file:///./parser.mbty
// 264|    additive_expr "IS" "NOT" "NULL"
// 265|      { Expr::IsNotNull($1) }
fn yy_action_54(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  Expr::IsNotNull(_dollar1) })
}

// file:///./parser.mbty
// 271|    additive_expr "+" multiplicative_expr
// 272|      { Expr::Binary(BinaryOp::Add, $1, $3) }
fn yy_action_55(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Add, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 273|    additive_expr "-" multiplicative_expr
// 274|      { Expr::Binary(BinaryOp::Subtract, $1, $3) }
fn yy_action_56(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Subtract, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 248|    additive_expr
// 249|      { $1 }
fn yy_action_57(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 280|    multiplicative_expr "*" unary_expr
// 281|      { Expr::Binary(BinaryOp::Multiply, $1, $3) }
fn yy_action_58(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Multiply, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 282|    multiplicative_expr "/" unary_expr
// 283|      { Expr::Binary(BinaryOp::Divide, $1, $3) }
fn yy_action_59(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  guard _args[2].0 is YYObj_Expr(_dollar3)
  YYObj_Expr({();  Expr::Binary(BinaryOp::Divide, _dollar1, _dollar3) })
}

// file:///./parser.mbty
// 269|    multiplicative_expr
// 270|      { $1 }
fn yy_action_60(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 278|    unary_expr
// 279|      { $1 }
fn yy_action_61(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 287|    primary_expr
// 288|      { $1 }
fn yy_action_62(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 289|    "+" unary_expr
// 290|      { Expr::Unary(UnaryOp::Plus, $2) }
fn yy_action_63(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  Expr::Unary(UnaryOp::Plus, _dollar2) })
}

// file:///./parser.mbty
// 291|    "-" unary_expr
// 292|      { Expr::Unary(UnaryOp::Minus, $2) }
fn yy_action_64(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  Expr::Unary(UnaryOp::Minus, _dollar2) })
}

// file:///./parser.mbty
// 296|    function_call_expr
// 297|      { $1 }
fn yy_action_65(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Expr(_dollar1)
  YYObj_Expr({();  _dollar1 })
}

// file:///./parser.mbty
// 330|    identifier_path "." IDENT
// 331|      { push_string($1, $3) }
fn yy_action_66(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_String_(_dollar1)
  guard _args[2].0 is YYObj_String(_dollar3)
  YYObj_Array_String_({();  push_string(_dollar1, _dollar3) })
}

// file:///./parser.mbty
// 298|    identifier_path
// 299|      { Expr::ColumnRef($1) }
fn yy_action_67(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_Array_String_(_dollar1)
  YYObj_Expr({();  Expr::ColumnRef(_dollar1) })
}

// file:///./parser.mbty
// 300|    STRING_LITERAL
// 301|      { Expr::StringLiteral($1) }
fn yy_action_68(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::StringLiteral(_dollar1) })
}

// file:///./parser.mbty
// 302|    INTEGER_LITERAL
// 303|      { Expr::IntegerLiteral($1) }
fn yy_action_69(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::IntegerLiteral(_dollar1) })
}

// file:///./parser.mbty
// 304|    DOUBLE_LITERAL
// 305|      { Expr::DoubleLiteral($1) }
fn yy_action_70(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::DoubleLiteral(_dollar1) })
}

// file:///./parser.mbty
// 306|    "TRUE"
// 307|      { Expr::BooleanLiteral(true) }
fn yy_action_71(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr({();  Expr::BooleanLiteral(true) })
}

// file:///./parser.mbty
// 308|    "FALSE"
// 309|      { Expr::BooleanLiteral(false) }
fn yy_action_72(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr({();  Expr::BooleanLiteral(false) })
}

// file:///./parser.mbty
// 310|    "NULL"
// 311|      { Expr::NullLiteral }
fn yy_action_73(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_Expr({();  Expr::NullLiteral })
}

// file:///./parser.mbty
// 312|    "(" expr ")"
// 313|      { $2 }
fn yy_action_74(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[1].0 is YYObj_Expr(_dollar2)
  YYObj_Expr({();  _dollar2 })
}

// file:///./parser.mbty
// 314|    "CAST" "(" expr "AS" type_name ")"
// 315|      { Expr::Cast($3, $5) }
fn yy_action_75(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[2].0 is YYObj_Expr(_dollar3)
  guard _args[4].0 is YYObj_TypeName(_dollar5)
  YYObj_Expr({();  Expr::Cast(_dollar3, _dollar5) })
}

// file:///./parser.mbty
// 335|    "NULL"
// 336|      { TypeName::Null }
fn yy_action_76(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::Null })
}

// file:///./parser.mbty
// 337|    "BOOLEAN"
// 338|      { TypeName::Boolean }
fn yy_action_77(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::Boolean })
}

// file:///./parser.mbty
// 339|    "BIGINT"
// 340|      { TypeName::BigInt }
fn yy_action_78(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::BigInt })
}

// file:///./parser.mbty
// 341|    "DOUBLE"
// 342|      { TypeName::Double }
fn yy_action_79(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::Double })
}

// file:///./parser.mbty
// 343|    "VARCHAR"
// 344|      { TypeName::Varchar }
fn yy_action_80(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  YYObj_TypeName({();  TypeName::Varchar })
}

// file:///./parser.mbty
// 319|    IDENT "(" ")"
// 320|      { Expr::FunctionCall($1, []) }
fn yy_action_81(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::FunctionCall(_dollar1, []) })
}

// file:///./parser.mbty
// 323|    IDENT "(" "*" ")"
// 324|      { Expr::FunctionCallStar($1) }
fn yy_action_82(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
  guard _args[0].0 is YYObj_String(_dollar1)
  YYObj_Expr({();  Expr::FunctionCallStar(_dollar1) })
}

// file:///./parser.mbty
// 328|    IDENT
// 329|      { [$1] }
fn yy_action_83(_last_pos : Int, _args : ArrayView[(YYObj, Int, Int)]) -> YYObj {
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
    GROUP => (T_GROUP, YYObj_Void)
    BY => (T_BY, YYObj_Void)
    HAVING => (T_HAVING, YYObj_Void)
    ORDER => (T_ORDER, YYObj_Void)
    LIMIT => (T_LIMIT, YYObj_Void)
    JOIN => (T_JOIN, YYObj_Void)
    INNER => (T_INNER, YYObj_Void)
    ON => (T_ON, YYObj_Void)
    ASC => (T_ASC, YYObj_Void)
    DESC => (T_DESC, YYObj_Void)
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

// [0, query → • SELECT select_list FROM from_item opt_where opt_group_by opt_having opt_order_by opt_limit opt_semicolon, $]
// [84, query_prime → • query, $]
fn yy_state_0(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    NT_query => Shift(yy_state_1)
    T_SELECT => Shift(yy_state_2)
    _ => Error
  }
}

// [84, query_prime → query •, $]
fn yy_state_1(_lookahead : YYSymbol) -> YYDecision {
  Accept
}

// [0, query → SELECT • select_list FROM from_item opt_where opt_group_by opt_having opt_order_by opt_limit opt_semicolon, $]
// [3, select_list → • select_item, FROM / COMMA]
// [4, select_list → • select_list COMMA select_item, FROM / COMMA]
// [5, select_item → • expr opt_alias, FROM / COMMA]
// [39, expr → • or_expr, IDENT / FROM / AS / COMMA]
// [40, or_expr → • and_expr, IDENT / FROM / AS / OR / COMMA]
// [41, or_expr → • or_expr OR and_expr, IDENT / FROM / AS / OR / COMMA]
// [42, and_expr → • not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [43, and_expr → • and_expr AND not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [44, not_expr → • comparison_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [45, not_expr → • NOT not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [46, comparison_expr → • additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [47, comparison_expr → • additive_expr EQ additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [48, comparison_expr → • additive_expr NEQ additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [49, comparison_expr → • additive_expr LT additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [50, comparison_expr → • additive_expr LTE additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [51, comparison_expr → • additive_expr GT additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [52, comparison_expr → • additive_expr GTE additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [53, comparison_expr → • additive_expr IS NULL, IDENT / FROM / AS / AND / OR / COMMA]
// [54, comparison_expr → • additive_expr IS NOT NULL, IDENT / FROM / AS / AND / OR / COMMA]
// [55, additive_expr → • multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [58, multiplicative_expr → • unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [61, unary_expr → • primary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [62, unary_expr → • PLUS unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [63, unary_expr → • MINUS unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [64, primary_expr → • function_call_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [65, primary_expr → • identifier_path, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [66, primary_expr → • STRING_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [67, primary_expr → • INTEGER_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [68, primary_expr → • DOUBLE_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [69, primary_expr → • TRUE, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [70, primary_expr → • FALSE, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [71, primary_expr → • NULL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [72, primary_expr → • LPAREN expr RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [74, function_call_expr → • IDENT LPAREN RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [77, identifier_path → • IDENT, IDENT / FROM / AS / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [78, identifier_path → • identifier_path DOT IDENT, IDENT / FROM / AS / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_2(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_79)
    NT_select_item => Shift(yy_state_84)
    NT_select_list => Shift(yy_state_85)
    _ => Error
  }
}

// [74, function_call_expr → IDENT • LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → IDENT • LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → IDENT • LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → IDENT •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_3(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_4)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_DOT | T_PLUS | T_MINUS | T_STAR | T_SLASH | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(1, NT_identifier_path, yy_action_83)
    _ => Error
  }
}

// [19, argument_list → • expr, RPAREN / COMMA]
// [20, argument_list → • argument_list COMMA expr, RPAREN / COMMA]
// [39, expr → • or_expr, RPAREN / COMMA]
// [40, or_expr → • and_expr, OR / RPAREN / COMMA]
// [41, or_expr → • or_expr OR and_expr, OR / RPAREN / COMMA]
// [42, and_expr → • not_expr, AND / OR / RPAREN / COMMA]
// [43, and_expr → • and_expr AND not_expr, AND / OR / RPAREN / COMMA]
// [44, not_expr → • comparison_expr, AND / OR / RPAREN / COMMA]
// [45, not_expr → • NOT not_expr, AND / OR / RPAREN / COMMA]
// [46, comparison_expr → • additive_expr, AND / OR / RPAREN / COMMA]
// [47, comparison_expr → • additive_expr EQ additive_expr, AND / OR / RPAREN / COMMA]
// [48, comparison_expr → • additive_expr NEQ additive_expr, AND / OR / RPAREN / COMMA]
// [49, comparison_expr → • additive_expr LT additive_expr, AND / OR / RPAREN / COMMA]
// [50, comparison_expr → • additive_expr LTE additive_expr, AND / OR / RPAREN / COMMA]
// [51, comparison_expr → • additive_expr GT additive_expr, AND / OR / RPAREN / COMMA]
// [52, comparison_expr → • additive_expr GTE additive_expr, AND / OR / RPAREN / COMMA]
// [53, comparison_expr → • additive_expr IS NULL, AND / OR / RPAREN / COMMA]
// [54, comparison_expr → • additive_expr IS NOT NULL, AND / OR / RPAREN / COMMA]
// [55, additive_expr → • multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [58, multiplicative_expr → • unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [61, unary_expr → • primary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [62, unary_expr → • PLUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [63, unary_expr → • MINUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [64, primary_expr → • function_call_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [65, primary_expr → • identifier_path, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [66, primary_expr → • STRING_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [67, primary_expr → • INTEGER_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [68, primary_expr → • DOUBLE_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [69, primary_expr → • TRUE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [70, primary_expr → • FALSE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [71, primary_expr → • NULL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [72, primary_expr → • LPAREN expr RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [74, function_call_expr → • IDENT LPAREN RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [74, function_call_expr → IDENT LPAREN • RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [75, function_call_expr → IDENT LPAREN • argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [76, function_call_expr → IDENT LPAREN • STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [78, identifier_path → • identifier_path DOT IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_4(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_STAR => Shift(yy_state_5)
    T_RPAREN => Shift(yy_state_7)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_argument_list => Shift(yy_state_74)
    NT_expr => Shift(yy_state_78)
    _ => Error
  }
}

// [76, function_call_expr → IDENT LPAREN STAR • RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_5(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_6)
    _ => Error
  }
}

// [76, function_call_expr → IDENT LPAREN STAR RPAREN •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_6(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_function_call_expr, yy_action_82)
}

// [74, function_call_expr → IDENT LPAREN RPAREN •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_7(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_function_call_expr, yy_action_81)
}

// [73, primary_expr → CAST • LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_8(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_9)
    _ => Error
  }
}

// [39, expr → • or_expr, AS]
// [40, or_expr → • and_expr, AS / OR]
// [41, or_expr → • or_expr OR and_expr, AS / OR]
// [42, and_expr → • not_expr, AS / AND / OR]
// [43, and_expr → • and_expr AND not_expr, AS / AND / OR]
// [44, not_expr → • comparison_expr, AS / AND / OR]
// [45, not_expr → • NOT not_expr, AS / AND / OR]
// [46, comparison_expr → • additive_expr, AS / AND / OR]
// [47, comparison_expr → • additive_expr EQ additive_expr, AS / AND / OR]
// [48, comparison_expr → • additive_expr NEQ additive_expr, AS / AND / OR]
// [49, comparison_expr → • additive_expr LT additive_expr, AS / AND / OR]
// [50, comparison_expr → • additive_expr LTE additive_expr, AS / AND / OR]
// [51, comparison_expr → • additive_expr GT additive_expr, AS / AND / OR]
// [52, comparison_expr → • additive_expr GTE additive_expr, AS / AND / OR]
// [53, comparison_expr → • additive_expr IS NULL, AS / AND / OR]
// [54, comparison_expr → • additive_expr IS NOT NULL, AS / AND / OR]
// [55, additive_expr → • multiplicative_expr, AS / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, AS / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, AS / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [58, multiplicative_expr → • unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [61, unary_expr → • primary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [62, unary_expr → • PLUS unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [63, unary_expr → • MINUS unary_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [64, primary_expr → • function_call_expr, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [65, primary_expr → • identifier_path, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [66, primary_expr → • STRING_LITERAL, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [67, primary_expr → • INTEGER_LITERAL, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [68, primary_expr → • DOUBLE_LITERAL, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [69, primary_expr → • TRUE, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [70, primary_expr → • FALSE, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [71, primary_expr → • NULL, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [72, primary_expr → • LPAREN expr RPAREN, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [73, primary_expr → CAST LPAREN • expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, AS / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [77, identifier_path → • IDENT, AS / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [78, identifier_path → • identifier_path DOT IDENT, AS / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_9(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    NT_expr => Shift(yy_state_10)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    _ => Error
  }
}

// [73, primary_expr → CAST LPAREN expr • AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_10(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_AS => Shift(yy_state_11)
    _ => Error
  }
}

// [73, primary_expr → CAST LPAREN expr AS • type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [79, type_name → • NULL, RPAREN]
// [80, type_name → • BOOLEAN_T, RPAREN]
// [81, type_name → • BIGINT_T, RPAREN]
// [82, type_name → • DOUBLE_T, RPAREN]
// [83, type_name → • VARCHAR_T, RPAREN]
fn yy_state_11(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_VARCHAR_T => Shift(yy_state_12)
    T_DOUBLE_T => Shift(yy_state_13)
    T_BIGINT_T => Shift(yy_state_14)
    T_BOOLEAN_T => Shift(yy_state_15)
    T_NULL => Shift(yy_state_16)
    NT_type_name => Shift(yy_state_17)
    _ => Error
  }
}

// [83, type_name → VARCHAR_T •, RPAREN]
fn yy_state_12(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_80)
}

// [82, type_name → DOUBLE_T •, RPAREN]
fn yy_state_13(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_79)
}

// [81, type_name → BIGINT_T •, RPAREN]
fn yy_state_14(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_78)
}

// [80, type_name → BOOLEAN_T •, RPAREN]
fn yy_state_15(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_77)
}

// [79, type_name → NULL •, RPAREN]
fn yy_state_16(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_type_name, yy_action_76)
}

// [73, primary_expr → CAST LPAREN expr AS type_name • RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_17(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_18)
    _ => Error
  }
}

// [73, primary_expr → CAST LPAREN expr AS type_name RPAREN •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_18(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(6, NT_primary_expr, yy_action_75)
}

// [39, expr → • or_expr, RPAREN]
// [40, or_expr → • and_expr, OR / RPAREN]
// [41, or_expr → • or_expr OR and_expr, OR / RPAREN]
// [42, and_expr → • not_expr, AND / OR / RPAREN]
// [43, and_expr → • and_expr AND not_expr, AND / OR / RPAREN]
// [44, not_expr → • comparison_expr, AND / OR / RPAREN]
// [45, not_expr → • NOT not_expr, AND / OR / RPAREN]
// [46, comparison_expr → • additive_expr, AND / OR / RPAREN]
// [47, comparison_expr → • additive_expr EQ additive_expr, AND / OR / RPAREN]
// [48, comparison_expr → • additive_expr NEQ additive_expr, AND / OR / RPAREN]
// [49, comparison_expr → • additive_expr LT additive_expr, AND / OR / RPAREN]
// [50, comparison_expr → • additive_expr LTE additive_expr, AND / OR / RPAREN]
// [51, comparison_expr → • additive_expr GT additive_expr, AND / OR / RPAREN]
// [52, comparison_expr → • additive_expr GTE additive_expr, AND / OR / RPAREN]
// [53, comparison_expr → • additive_expr IS NULL, AND / OR / RPAREN]
// [54, comparison_expr → • additive_expr IS NOT NULL, AND / OR / RPAREN]
// [55, additive_expr → • multiplicative_expr, IS / AND / OR / RPAREN / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, IS / AND / OR / RPAREN / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, IS / AND / OR / RPAREN / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [58, multiplicative_expr → • unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [61, unary_expr → • primary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [62, unary_expr → • PLUS unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [63, unary_expr → • MINUS unary_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [64, primary_expr → • function_call_expr, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [65, primary_expr → • identifier_path, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [66, primary_expr → • STRING_LITERAL, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [67, primary_expr → • INTEGER_LITERAL, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [68, primary_expr → • DOUBLE_LITERAL, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [69, primary_expr → • TRUE, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [70, primary_expr → • FALSE, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [71, primary_expr → • NULL, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [72, primary_expr → • LPAREN expr RPAREN, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [72, primary_expr → LPAREN • expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [74, function_call_expr → • IDENT LPAREN RPAREN, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, IS / AND / OR / RPAREN / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [77, identifier_path → • IDENT, IS / AND / OR / RPAREN / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [78, identifier_path → • identifier_path DOT IDENT, IS / AND / OR / RPAREN / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_19(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    NT_expr => Shift(yy_state_20)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    _ => Error
  }
}

// [72, primary_expr → LPAREN expr • RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_20(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_21)
    _ => Error
  }
}

// [72, primary_expr → LPAREN expr RPAREN •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_21(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_primary_expr, yy_action_74)
}

// [71, primary_expr → NULL •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_22(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_73)
}

// [70, primary_expr → FALSE •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_23(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_72)
}

// [69, primary_expr → TRUE •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_24(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_71)
}

// [68, primary_expr → DOUBLE_LITERAL •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_25(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_70)
}

// [67, primary_expr → INTEGER_LITERAL •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_26(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_69)
}

// [66, primary_expr → STRING_LITERAL •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_27(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_68)
}

// [65, primary_expr → identifier_path •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → identifier_path • DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_28(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_29)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_PLUS | T_MINUS | T_STAR | T_SLASH | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(1, NT_primary_expr, yy_action_67)
    _ => Error
  }
}

// [78, identifier_path → identifier_path DOT • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_29(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_30)
    _ => Error
  }
}

// [78, identifier_path → identifier_path DOT IDENT •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_30(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_identifier_path, yy_action_66)
}

// [64, primary_expr → function_call_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_31(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_primary_expr, yy_action_65)
}

// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → MINUS • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_32(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    NT_unary_expr => Shift(yy_state_33)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    _ => Error
  }
}

// [63, unary_expr → MINUS unary_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_33(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_unary_expr, yy_action_64)
}

// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → PLUS • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_34(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_unary_expr => Shift(yy_state_35)
    NT_primary_expr => Shift(yy_state_36)
    _ => Error
  }
}

// [62, unary_expr → PLUS unary_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_35(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_unary_expr, yy_action_63)
}

// [61, unary_expr → primary_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_36(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_unary_expr, yy_action_62)
}

// [58, multiplicative_expr → unary_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_37(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_multiplicative_expr, yy_action_61)
}

// [55, additive_expr → multiplicative_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → multiplicative_expr • STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → multiplicative_expr • SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_38(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_39)
    T_STAR => Shift(yy_state_41)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_PLUS | T_MINUS | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(1, NT_additive_expr, yy_action_60)
    _ => Error
  }
}

// [60, multiplicative_expr → multiplicative_expr SLASH • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_39(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_40)
    _ => Error
  }
}

// [60, multiplicative_expr → multiplicative_expr SLASH unary_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_40(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_multiplicative_expr, yy_action_59)
}

// [59, multiplicative_expr → multiplicative_expr STAR • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_41(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_42)
    _ => Error
  }
}

// [59, multiplicative_expr → multiplicative_expr STAR unary_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_42(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_multiplicative_expr, yy_action_58)
}

// [46, comparison_expr → additive_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [47, comparison_expr → additive_expr • EQ additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [48, comparison_expr → additive_expr • NEQ additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [49, comparison_expr → additive_expr • LT additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [50, comparison_expr → additive_expr • LTE additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [51, comparison_expr → additive_expr • GT additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [52, comparison_expr → additive_expr • GTE additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [53, comparison_expr → additive_expr • IS NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [54, comparison_expr → additive_expr • IS NOT NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [56, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_43(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_44)
    T_PLUS => Shift(yy_state_46)
    T_IS => Shift(yy_state_48)
    T_GTE => Shift(yy_state_52)
    T_GT => Shift(yy_state_54)
    T_LTE => Shift(yy_state_56)
    T_LT => Shift(yy_state_58)
    T_NEQ => Shift(yy_state_60)
    T_EQ => Shift(yy_state_62)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(1, NT_comparison_expr, yy_action_57)
    _ => Error
  }
}

// [57, additive_expr → additive_expr MINUS • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_44(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_45)
    _ => Error
  }
}

// [57, additive_expr → additive_expr MINUS multiplicative_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → multiplicative_expr • STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → multiplicative_expr • SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_45(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_39)
    T_STAR => Shift(yy_state_41)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_PLUS | T_MINUS | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(3, NT_additive_expr, yy_action_56)
    _ => Error
  }
}

// [56, additive_expr → additive_expr PLUS • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_46(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_47)
    _ => Error
  }
}

// [56, additive_expr → additive_expr PLUS multiplicative_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → multiplicative_expr • STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → multiplicative_expr • SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_47(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SLASH => Shift(yy_state_39)
    T_STAR => Shift(yy_state_41)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_IS | T_AND | T_OR | T_RPAREN | T_COMMA | T_PLUS | T_MINUS | T_EQ | T_NEQ | T_LT | T_LTE | T_GT | T_GTE | T_SEMICOLON | EOI => Reduce(3, NT_additive_expr, yy_action_55)
    _ => Error
  }
}

// [53, comparison_expr → additive_expr IS • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [54, comparison_expr → additive_expr IS • NOT NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_48(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_NOT => Shift(yy_state_49)
    T_NULL => Shift(yy_state_51)
    _ => Error
  }
}

// [54, comparison_expr → additive_expr IS NOT • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_49(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_NULL => Shift(yy_state_50)
    _ => Error
  }
}

// [54, comparison_expr → additive_expr IS NOT NULL •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_50(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_comparison_expr, yy_action_54)
}

// [53, comparison_expr → additive_expr IS NULL •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_51(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_comparison_expr, yy_action_53)
}

// [52, comparison_expr → additive_expr GTE • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_52(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_53)
    _ => Error
  }
}

// [52, comparison_expr → additive_expr GTE additive_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [56, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_53(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_44)
    T_PLUS => Shift(yy_state_46)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_52)
    _ => Error
  }
}

// [51, comparison_expr → additive_expr GT • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_54(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_55)
    _ => Error
  }
}

// [51, comparison_expr → additive_expr GT additive_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [56, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_55(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_44)
    T_PLUS => Shift(yy_state_46)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_51)
    _ => Error
  }
}

// [50, comparison_expr → additive_expr LTE • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_56(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_57)
    _ => Error
  }
}

// [50, comparison_expr → additive_expr LTE additive_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [56, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_57(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_44)
    T_PLUS => Shift(yy_state_46)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_50)
    _ => Error
  }
}

// [49, comparison_expr → additive_expr LT • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_58(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_59)
    _ => Error
  }
}

// [49, comparison_expr → additive_expr LT additive_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [56, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_59(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_44)
    T_PLUS => Shift(yy_state_46)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_49)
    _ => Error
  }
}

// [48, comparison_expr → additive_expr NEQ • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_60(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_61)
    _ => Error
  }
}

// [48, comparison_expr → additive_expr NEQ additive_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [56, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_61(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_44)
    T_PLUS => Shift(yy_state_46)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_48)
    _ => Error
  }
}

// [47, comparison_expr → additive_expr EQ • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / SEMICOLON]
fn yy_state_62(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_63)
    _ => Error
  }
}

// [47, comparison_expr → additive_expr EQ additive_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [56, additive_expr → additive_expr • PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
// [57, additive_expr → additive_expr • MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / PLUS / MINUS / SEMICOLON]
fn yy_state_63(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_MINUS => Shift(yy_state_44)
    T_PLUS => Shift(yy_state_46)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_AND | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_comparison_expr, yy_action_47)
    _ => Error
  }
}

// [44, not_expr → • comparison_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [45, not_expr → NOT • not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_64(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_not_expr => Shift(yy_state_65)
    NT_comparison_expr => Shift(yy_state_66)
    _ => Error
  }
}

// [45, not_expr → NOT not_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_65(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_not_expr, yy_action_46)
}

// [44, not_expr → comparison_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_66(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_not_expr, yy_action_45)
}

// [42, and_expr → not_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_67(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_and_expr, yy_action_44)
}

// [40, or_expr → and_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / OR / RPAREN / COMMA / SEMICOLON]
// [43, and_expr → and_expr • AND not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_68(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_AND => Shift(yy_state_69)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(1, NT_or_expr, yy_action_43)
    _ => Error
  }
}

// [43, and_expr → and_expr AND • not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [44, not_expr → • comparison_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_69(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_70)
    _ => Error
  }
}

// [43, and_expr → and_expr AND not_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_70(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_and_expr, yy_action_42)
}

// [39, expr → or_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / RPAREN / COMMA / SEMICOLON]
// [41, or_expr → or_expr • OR and_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_71(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_OR => Shift(yy_state_72)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(1, NT_expr, yy_action_41)
    _ => Error
  }
}

// [41, or_expr → or_expr OR • and_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / OR / RPAREN / COMMA / SEMICOLON]
// [42, and_expr → • not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [43, and_expr → • and_expr AND not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [44, not_expr → • comparison_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_72(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_73)
    _ => Error
  }
}

// [41, or_expr → or_expr OR and_expr •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / OR / RPAREN / COMMA / SEMICOLON]
// [43, and_expr → and_expr • AND not_expr, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / AND / OR / RPAREN / COMMA / SEMICOLON]
fn yy_state_73(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_AND => Shift(yy_state_69)
    T_IDENT | T_FROM | T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_ASC | T_DESC | T_AS | T_OR | T_RPAREN | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_or_expr, yy_action_40)
    _ => Error
  }
}

// [20, argument_list → argument_list • COMMA expr, RPAREN / COMMA]
// [75, function_call_expr → IDENT LPAREN argument_list • RPAREN, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_74(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_RPAREN => Shift(yy_state_75)
    T_COMMA => Shift(yy_state_76)
    _ => Error
  }
}

// [75, function_call_expr → IDENT LPAREN argument_list RPAREN •, $ / IDENT / FROM / WHERE / GROUP / HAVING / ORDER / LIMIT / ASC / DESC / AS / IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_75(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_function_call_expr, yy_action_39)
}

// [20, argument_list → argument_list COMMA • expr, RPAREN / COMMA]
// [39, expr → • or_expr, RPAREN / COMMA]
// [40, or_expr → • and_expr, OR / RPAREN / COMMA]
// [41, or_expr → • or_expr OR and_expr, OR / RPAREN / COMMA]
// [42, and_expr → • not_expr, AND / OR / RPAREN / COMMA]
// [43, and_expr → • and_expr AND not_expr, AND / OR / RPAREN / COMMA]
// [44, not_expr → • comparison_expr, AND / OR / RPAREN / COMMA]
// [45, not_expr → • NOT not_expr, AND / OR / RPAREN / COMMA]
// [46, comparison_expr → • additive_expr, AND / OR / RPAREN / COMMA]
// [47, comparison_expr → • additive_expr EQ additive_expr, AND / OR / RPAREN / COMMA]
// [48, comparison_expr → • additive_expr NEQ additive_expr, AND / OR / RPAREN / COMMA]
// [49, comparison_expr → • additive_expr LT additive_expr, AND / OR / RPAREN / COMMA]
// [50, comparison_expr → • additive_expr LTE additive_expr, AND / OR / RPAREN / COMMA]
// [51, comparison_expr → • additive_expr GT additive_expr, AND / OR / RPAREN / COMMA]
// [52, comparison_expr → • additive_expr GTE additive_expr, AND / OR / RPAREN / COMMA]
// [53, comparison_expr → • additive_expr IS NULL, AND / OR / RPAREN / COMMA]
// [54, comparison_expr → • additive_expr IS NOT NULL, AND / OR / RPAREN / COMMA]
// [55, additive_expr → • multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [58, multiplicative_expr → • unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [61, unary_expr → • primary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [62, unary_expr → • PLUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [63, unary_expr → • MINUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [64, primary_expr → • function_call_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [65, primary_expr → • identifier_path, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [66, primary_expr → • STRING_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [67, primary_expr → • INTEGER_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [68, primary_expr → • DOUBLE_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [69, primary_expr → • TRUE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [70, primary_expr → • FALSE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [71, primary_expr → • NULL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [72, primary_expr → • LPAREN expr RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [74, function_call_expr → • IDENT LPAREN RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [77, identifier_path → • IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [78, identifier_path → • identifier_path DOT IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_76(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_77)
    _ => Error
  }
}

// [20, argument_list → argument_list COMMA expr •, RPAREN / COMMA]
fn yy_state_77(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_argument_list, yy_action_38)
}

// [19, argument_list → expr •, RPAREN / COMMA]
fn yy_state_78(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_argument_list, yy_action_37)
}

// [5, select_item → expr • opt_alias, FROM / COMMA]
// [6, opt_alias → •, FROM / COMMA]
// [7, opt_alias → • AS IDENT, FROM / COMMA]
// [8, opt_alias → • IDENT, FROM / COMMA]
fn yy_state_79(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_80)
    T_AS => Shift(yy_state_81)
    NT_opt_alias => Shift(yy_state_83)
    T_FROM | T_COMMA => Reduce(0, NT_opt_alias, yy_action_36)
    _ => Error
  }
}

// [8, opt_alias → IDENT •, FROM / COMMA]
fn yy_state_80(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_opt_alias, yy_action_35)
}

// [7, opt_alias → AS • IDENT, FROM / COMMA]
fn yy_state_81(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_82)
    _ => Error
  }
}

// [7, opt_alias → AS IDENT •, FROM / COMMA]
fn yy_state_82(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_opt_alias, yy_action_34)
}

// [5, select_item → expr opt_alias •, FROM / COMMA]
fn yy_state_83(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_select_item, yy_action_33)
}

// [3, select_list → select_item •, FROM / COMMA]
fn yy_state_84(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_select_list, yy_action_32)
}

// [0, query → SELECT select_list • FROM from_item opt_where opt_group_by opt_having opt_order_by opt_limit opt_semicolon, $]
// [4, select_list → select_list • COMMA select_item, FROM / COMMA]
fn yy_state_85(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_86)
    T_FROM => Shift(yy_state_88)
    _ => Error
  }
}

// [4, select_list → select_list COMMA • select_item, FROM / COMMA]
// [5, select_item → • expr opt_alias, FROM / COMMA]
// [39, expr → • or_expr, IDENT / FROM / AS / COMMA]
// [40, or_expr → • and_expr, IDENT / FROM / AS / OR / COMMA]
// [41, or_expr → • or_expr OR and_expr, IDENT / FROM / AS / OR / COMMA]
// [42, and_expr → • not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [43, and_expr → • and_expr AND not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [44, not_expr → • comparison_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [45, not_expr → • NOT not_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [46, comparison_expr → • additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [47, comparison_expr → • additive_expr EQ additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [48, comparison_expr → • additive_expr NEQ additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [49, comparison_expr → • additive_expr LT additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [50, comparison_expr → • additive_expr LTE additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [51, comparison_expr → • additive_expr GT additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [52, comparison_expr → • additive_expr GTE additive_expr, IDENT / FROM / AS / AND / OR / COMMA]
// [53, comparison_expr → • additive_expr IS NULL, IDENT / FROM / AS / AND / OR / COMMA]
// [54, comparison_expr → • additive_expr IS NOT NULL, IDENT / FROM / AS / AND / OR / COMMA]
// [55, additive_expr → • multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [58, multiplicative_expr → • unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [61, unary_expr → • primary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [62, unary_expr → • PLUS unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [63, unary_expr → • MINUS unary_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [64, primary_expr → • function_call_expr, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [65, primary_expr → • identifier_path, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [66, primary_expr → • STRING_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [67, primary_expr → • INTEGER_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [68, primary_expr → • DOUBLE_LITERAL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [69, primary_expr → • TRUE, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [70, primary_expr → • FALSE, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [71, primary_expr → • NULL, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [72, primary_expr → • LPAREN expr RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [74, function_call_expr → • IDENT LPAREN RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, IDENT / FROM / AS / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [77, identifier_path → • IDENT, IDENT / FROM / AS / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [78, identifier_path → • identifier_path DOT IDENT, IDENT / FROM / AS / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_86(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_79)
    NT_select_item => Shift(yy_state_87)
    _ => Error
  }
}

// [4, select_list → select_list COMMA select_item •, FROM / COMMA]
fn yy_state_87(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_select_list, yy_action_31)
}

// [0, query → SELECT select_list FROM • from_item opt_where opt_group_by opt_having opt_order_by opt_limit opt_semicolon, $]
// [9, from_item → • source_ref, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [10, from_item → • source_ref JOIN source_ref ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [11, from_item → • source_ref INNER JOIN source_ref ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [12, table_function → • IDENT LPAREN RPAREN, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / AS / SEMICOLON]
// [13, table_function → • IDENT LPAREN argument_list RPAREN, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / AS / SEMICOLON]
// [14, source_ref → • table_function opt_source_alias, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / SEMICOLON]
// [15, source_ref → • STRING_LITERAL opt_source_alias, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / SEMICOLON]
fn yy_state_88(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_STRING_LITERAL => Shift(yy_state_89)
    NT_table_function => Shift(yy_state_94)
    T_IDENT => Shift(yy_state_96)
    NT_source_ref => Shift(yy_state_101)
    NT_from_item => Shift(yy_state_111)
    _ => Error
  }
}

// [15, source_ref → STRING_LITERAL • opt_source_alias, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
// [16, opt_source_alias → •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
// [17, opt_source_alias → • AS IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
// [18, opt_source_alias → • IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
fn yy_state_89(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_90)
    T_AS => Shift(yy_state_91)
    NT_opt_source_alias => Shift(yy_state_93)
    T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_JOIN | T_INNER | T_ON | T_SEMICOLON | EOI => Reduce(0, NT_opt_source_alias, yy_action_30)
    _ => Error
  }
}

// [18, opt_source_alias → IDENT •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
fn yy_state_90(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_opt_source_alias, yy_action_29)
}

// [17, opt_source_alias → AS • IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
fn yy_state_91(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_92)
    _ => Error
  }
}

// [17, opt_source_alias → AS IDENT •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
fn yy_state_92(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_opt_source_alias, yy_action_28)
}

// [15, source_ref → STRING_LITERAL opt_source_alias •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
fn yy_state_93(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_source_ref, yy_action_27)
}

// [14, source_ref → table_function • opt_source_alias, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
// [16, opt_source_alias → •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
// [17, opt_source_alias → • AS IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
// [18, opt_source_alias → • IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
fn yy_state_94(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_90)
    T_AS => Shift(yy_state_91)
    NT_opt_source_alias => Shift(yy_state_95)
    T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_JOIN | T_INNER | T_ON | T_SEMICOLON | EOI => Reduce(0, NT_opt_source_alias, yy_action_30)
    _ => Error
  }
}

// [14, source_ref → table_function opt_source_alias •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / SEMICOLON]
fn yy_state_95(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_source_ref, yy_action_26)
}

// [12, table_function → IDENT • LPAREN RPAREN, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / AS / SEMICOLON]
// [13, table_function → IDENT • LPAREN argument_list RPAREN, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / AS / SEMICOLON]
fn yy_state_96(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LPAREN => Shift(yy_state_97)
    _ => Error
  }
}

// [12, table_function → IDENT LPAREN • RPAREN, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / AS / SEMICOLON]
// [13, table_function → IDENT LPAREN • argument_list RPAREN, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / AS / SEMICOLON]
// [19, argument_list → • expr, RPAREN / COMMA]
// [20, argument_list → • argument_list COMMA expr, RPAREN / COMMA]
// [39, expr → • or_expr, RPAREN / COMMA]
// [40, or_expr → • and_expr, OR / RPAREN / COMMA]
// [41, or_expr → • or_expr OR and_expr, OR / RPAREN / COMMA]
// [42, and_expr → • not_expr, AND / OR / RPAREN / COMMA]
// [43, and_expr → • and_expr AND not_expr, AND / OR / RPAREN / COMMA]
// [44, not_expr → • comparison_expr, AND / OR / RPAREN / COMMA]
// [45, not_expr → • NOT not_expr, AND / OR / RPAREN / COMMA]
// [46, comparison_expr → • additive_expr, AND / OR / RPAREN / COMMA]
// [47, comparison_expr → • additive_expr EQ additive_expr, AND / OR / RPAREN / COMMA]
// [48, comparison_expr → • additive_expr NEQ additive_expr, AND / OR / RPAREN / COMMA]
// [49, comparison_expr → • additive_expr LT additive_expr, AND / OR / RPAREN / COMMA]
// [50, comparison_expr → • additive_expr LTE additive_expr, AND / OR / RPAREN / COMMA]
// [51, comparison_expr → • additive_expr GT additive_expr, AND / OR / RPAREN / COMMA]
// [52, comparison_expr → • additive_expr GTE additive_expr, AND / OR / RPAREN / COMMA]
// [53, comparison_expr → • additive_expr IS NULL, AND / OR / RPAREN / COMMA]
// [54, comparison_expr → • additive_expr IS NOT NULL, AND / OR / RPAREN / COMMA]
// [55, additive_expr → • multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE]
// [58, multiplicative_expr → • unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [61, unary_expr → • primary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [62, unary_expr → • PLUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [63, unary_expr → • MINUS unary_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [64, primary_expr → • function_call_expr, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [65, primary_expr → • identifier_path, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [66, primary_expr → • STRING_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [67, primary_expr → • INTEGER_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [68, primary_expr → • DOUBLE_LITERAL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [69, primary_expr → • TRUE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [70, primary_expr → • FALSE, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [71, primary_expr → • NULL, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [72, primary_expr → • LPAREN expr RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [74, function_call_expr → • IDENT LPAREN RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, IS / AND / OR / RPAREN / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [77, identifier_path → • IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
// [78, identifier_path → • identifier_path DOT IDENT, IS / AND / OR / RPAREN / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE]
fn yy_state_97(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_78)
    NT_argument_list => Shift(yy_state_98)
    T_RPAREN => Shift(yy_state_100)
    _ => Error
  }
}

// [13, table_function → IDENT LPAREN argument_list • RPAREN, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / AS / SEMICOLON]
// [20, argument_list → argument_list • COMMA expr, RPAREN / COMMA]
fn yy_state_98(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_76)
    T_RPAREN => Shift(yy_state_99)
    _ => Error
  }
}

// [13, table_function → IDENT LPAREN argument_list RPAREN •, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / AS / SEMICOLON]
fn yy_state_99(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(4, NT_table_function, yy_action_25)
}

// [12, table_function → IDENT LPAREN RPAREN •, $ / IDENT / WHERE / GROUP / HAVING / ORDER / LIMIT / JOIN / INNER / ON / AS / SEMICOLON]
fn yy_state_100(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_table_function, yy_action_24)
}

// [9, from_item → source_ref •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [10, from_item → source_ref • JOIN source_ref ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [11, from_item → source_ref • INNER JOIN source_ref ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_101(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_INNER => Shift(yy_state_102)
    T_JOIN => Shift(yy_state_107)
    T_WHERE | T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_SEMICOLON | EOI => Reduce(1, NT_from_item, yy_action_23)
    _ => Error
  }
}

// [11, from_item → source_ref INNER • JOIN source_ref ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_102(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_JOIN => Shift(yy_state_103)
    _ => Error
  }
}

// [11, from_item → source_ref INNER JOIN • source_ref ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [12, table_function → • IDENT LPAREN RPAREN, IDENT / ON / AS]
// [13, table_function → • IDENT LPAREN argument_list RPAREN, IDENT / ON / AS]
// [14, source_ref → • table_function opt_source_alias, ON]
// [15, source_ref → • STRING_LITERAL opt_source_alias, ON]
fn yy_state_103(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_STRING_LITERAL => Shift(yy_state_89)
    NT_table_function => Shift(yy_state_94)
    T_IDENT => Shift(yy_state_96)
    NT_source_ref => Shift(yy_state_104)
    _ => Error
  }
}

// [11, from_item → source_ref INNER JOIN source_ref • ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_104(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_ON => Shift(yy_state_105)
    _ => Error
  }
}

// [11, from_item → source_ref INNER JOIN source_ref ON • expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [39, expr → • or_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [40, or_expr → • and_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / OR / SEMICOLON]
// [41, or_expr → • or_expr OR and_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / OR / SEMICOLON]
// [42, and_expr → • not_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [43, and_expr → • and_expr AND not_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [44, not_expr → • comparison_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_105(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_106)
    _ => Error
  }
}

// [11, from_item → source_ref INNER JOIN source_ref ON expr •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_106(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(6, NT_from_item, yy_action_22)
}

// [10, from_item → source_ref JOIN • source_ref ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [12, table_function → • IDENT LPAREN RPAREN, IDENT / ON / AS]
// [13, table_function → • IDENT LPAREN argument_list RPAREN, IDENT / ON / AS]
// [14, source_ref → • table_function opt_source_alias, ON]
// [15, source_ref → • STRING_LITERAL opt_source_alias, ON]
fn yy_state_107(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_STRING_LITERAL => Shift(yy_state_89)
    NT_table_function => Shift(yy_state_94)
    T_IDENT => Shift(yy_state_96)
    NT_source_ref => Shift(yy_state_108)
    _ => Error
  }
}

// [10, from_item → source_ref JOIN source_ref • ON expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_108(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_ON => Shift(yy_state_109)
    _ => Error
  }
}

// [10, from_item → source_ref JOIN source_ref ON • expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [39, expr → • or_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [40, or_expr → • and_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / OR / SEMICOLON]
// [41, or_expr → • or_expr OR and_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / OR / SEMICOLON]
// [42, and_expr → • not_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [43, and_expr → • and_expr AND not_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [44, not_expr → • comparison_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_109(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_110)
    _ => Error
  }
}

// [10, from_item → source_ref JOIN source_ref ON expr •, $ / WHERE / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_110(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(5, NT_from_item, yy_action_21)
}

// [0, query → SELECT select_list FROM from_item • opt_where opt_group_by opt_having opt_order_by opt_limit opt_semicolon, $]
// [21, opt_where → •, $ / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [22, opt_where → • WHERE expr, $ / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_111(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_WHERE => Shift(yy_state_112)
    NT_opt_where => Shift(yy_state_114)
    T_GROUP | T_HAVING | T_ORDER | T_LIMIT | T_SEMICOLON | EOI => Reduce(0, NT_opt_where, yy_action_20)
    _ => Error
  }
}

// [22, opt_where → WHERE • expr, $ / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [39, expr → • or_expr, $ / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
// [40, or_expr → • and_expr, $ / GROUP / HAVING / ORDER / LIMIT / OR / SEMICOLON]
// [41, or_expr → • or_expr OR and_expr, $ / GROUP / HAVING / ORDER / LIMIT / OR / SEMICOLON]
// [42, and_expr → • not_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [43, and_expr → • and_expr AND not_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [44, not_expr → • comparison_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / GROUP / HAVING / ORDER / LIMIT / AND / OR / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / GROUP / HAVING / ORDER / LIMIT / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_112(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_113)
    _ => Error
  }
}

// [22, opt_where → WHERE expr •, $ / GROUP / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_113(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_opt_where, yy_action_19)
}

// [0, query → SELECT select_list FROM from_item opt_where • opt_group_by opt_having opt_order_by opt_limit opt_semicolon, $]
// [23, opt_group_by → •, $ / HAVING / ORDER / LIMIT / SEMICOLON]
// [24, opt_group_by → • GROUP BY group_key_list, $ / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_114(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_GROUP => Shift(yy_state_115)
    NT_opt_group_by => Shift(yy_state_122)
    T_HAVING | T_ORDER | T_LIMIT | T_SEMICOLON | EOI => Reduce(0, NT_opt_group_by, yy_action_18)
    _ => Error
  }
}

// [24, opt_group_by → GROUP • BY group_key_list, $ / HAVING / ORDER / LIMIT / SEMICOLON]
fn yy_state_115(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BY => Shift(yy_state_116)
    _ => Error
  }
}

// [24, opt_group_by → GROUP BY • group_key_list, $ / HAVING / ORDER / LIMIT / SEMICOLON]
// [25, group_key_list → • identifier_path, $ / HAVING / ORDER / LIMIT / COMMA / SEMICOLON]
// [26, group_key_list → • group_key_list COMMA identifier_path, $ / HAVING / ORDER / LIMIT / COMMA / SEMICOLON]
// [77, identifier_path → • IDENT, $ / HAVING / ORDER / LIMIT / COMMA / DOT / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / HAVING / ORDER / LIMIT / COMMA / DOT / SEMICOLON]
fn yy_state_116(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_117)
    NT_identifier_path => Shift(yy_state_118)
    NT_group_key_list => Shift(yy_state_119)
    _ => Error
  }
}

// [77, identifier_path → IDENT •, $ / HAVING / ORDER / LIMIT / COMMA / DOT / SEMICOLON]
fn yy_state_117(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_identifier_path, yy_action_83)
}

// [25, group_key_list → identifier_path •, $ / HAVING / ORDER / LIMIT / COMMA / SEMICOLON]
// [78, identifier_path → identifier_path • DOT IDENT, $ / HAVING / ORDER / LIMIT / COMMA / DOT / SEMICOLON]
fn yy_state_118(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_29)
    T_HAVING | T_ORDER | T_LIMIT | T_COMMA | T_SEMICOLON | EOI => Reduce(1, NT_group_key_list, yy_action_17)
    _ => Error
  }
}

// [24, opt_group_by → GROUP BY group_key_list •, $ / HAVING / ORDER / LIMIT / SEMICOLON]
// [26, group_key_list → group_key_list • COMMA identifier_path, $ / HAVING / ORDER / LIMIT / COMMA / SEMICOLON]
fn yy_state_119(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_120)
    T_HAVING | T_ORDER | T_LIMIT | T_SEMICOLON | EOI => Reduce(3, NT_opt_group_by, yy_action_16)
    _ => Error
  }
}

// [26, group_key_list → group_key_list COMMA • identifier_path, $ / HAVING / ORDER / LIMIT / COMMA / SEMICOLON]
// [77, identifier_path → • IDENT, $ / HAVING / ORDER / LIMIT / COMMA / DOT / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / HAVING / ORDER / LIMIT / COMMA / DOT / SEMICOLON]
fn yy_state_120(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_117)
    NT_identifier_path => Shift(yy_state_121)
    _ => Error
  }
}

// [26, group_key_list → group_key_list COMMA identifier_path •, $ / HAVING / ORDER / LIMIT / COMMA / SEMICOLON]
// [78, identifier_path → identifier_path • DOT IDENT, $ / HAVING / ORDER / LIMIT / COMMA / DOT / SEMICOLON]
fn yy_state_121(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DOT => Shift(yy_state_29)
    T_HAVING | T_ORDER | T_LIMIT | T_COMMA | T_SEMICOLON | EOI => Reduce(3, NT_group_key_list, yy_action_15)
    _ => Error
  }
}

// [0, query → SELECT select_list FROM from_item opt_where opt_group_by • opt_having opt_order_by opt_limit opt_semicolon, $]
// [27, opt_having → •, $ / ORDER / LIMIT / SEMICOLON]
// [28, opt_having → • HAVING expr, $ / ORDER / LIMIT / SEMICOLON]
fn yy_state_122(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_HAVING => Shift(yy_state_123)
    NT_opt_having => Shift(yy_state_125)
    T_ORDER | T_LIMIT | T_SEMICOLON | EOI => Reduce(0, NT_opt_having, yy_action_14)
    _ => Error
  }
}

// [28, opt_having → HAVING • expr, $ / ORDER / LIMIT / SEMICOLON]
// [39, expr → • or_expr, $ / ORDER / LIMIT / SEMICOLON]
// [40, or_expr → • and_expr, $ / ORDER / LIMIT / OR / SEMICOLON]
// [41, or_expr → • or_expr OR and_expr, $ / ORDER / LIMIT / OR / SEMICOLON]
// [42, and_expr → • not_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [43, and_expr → • and_expr AND not_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [44, not_expr → • comparison_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / ORDER / LIMIT / AND / OR / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / ORDER / LIMIT / IS / AND / OR / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / ORDER / LIMIT / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / ORDER / LIMIT / IS / AND / OR / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_123(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_124)
    _ => Error
  }
}

// [28, opt_having → HAVING expr •, $ / ORDER / LIMIT / SEMICOLON]
fn yy_state_124(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_opt_having, yy_action_13)
}

// [0, query → SELECT select_list FROM from_item opt_where opt_group_by opt_having • opt_order_by opt_limit opt_semicolon, $]
// [29, opt_order_by → •, $ / LIMIT / SEMICOLON]
// [30, opt_order_by → • ORDER BY order_by_list, $ / LIMIT / SEMICOLON]
fn yy_state_125(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_ORDER => Shift(yy_state_126)
    NT_opt_order_by => Shift(yy_state_136)
    T_LIMIT | T_SEMICOLON | EOI => Reduce(0, NT_opt_order_by, yy_action_12)
    _ => Error
  }
}

// [30, opt_order_by → ORDER • BY order_by_list, $ / LIMIT / SEMICOLON]
fn yy_state_126(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_BY => Shift(yy_state_127)
    _ => Error
  }
}

// [30, opt_order_by → ORDER BY • order_by_list, $ / LIMIT / SEMICOLON]
// [31, order_by_list → • order_by_item, $ / LIMIT / COMMA / SEMICOLON]
// [32, order_by_list → • order_by_list COMMA order_by_item, $ / LIMIT / COMMA / SEMICOLON]
// [33, order_by_item → • expr opt_sort_direction, $ / LIMIT / COMMA / SEMICOLON]
// [39, expr → • or_expr, $ / LIMIT / ASC / DESC / COMMA / SEMICOLON]
// [40, or_expr → • and_expr, $ / LIMIT / ASC / DESC / OR / COMMA / SEMICOLON]
// [41, or_expr → • or_expr OR and_expr, $ / LIMIT / ASC / DESC / OR / COMMA / SEMICOLON]
// [42, and_expr → • not_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [43, and_expr → • and_expr AND not_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [44, not_expr → • comparison_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_127(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_128)
    NT_order_by_item => Shift(yy_state_132)
    NT_order_by_list => Shift(yy_state_133)
    _ => Error
  }
}

// [33, order_by_item → expr • opt_sort_direction, $ / LIMIT / COMMA / SEMICOLON]
// [34, opt_sort_direction → •, $ / LIMIT / COMMA / SEMICOLON]
// [35, opt_sort_direction → • ASC, $ / LIMIT / COMMA / SEMICOLON]
// [36, opt_sort_direction → • DESC, $ / LIMIT / COMMA / SEMICOLON]
fn yy_state_128(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_DESC => Shift(yy_state_129)
    T_ASC => Shift(yy_state_130)
    NT_opt_sort_direction => Shift(yy_state_131)
    T_LIMIT | T_COMMA | T_SEMICOLON | EOI => Reduce(0, NT_opt_sort_direction, yy_action_11)
    _ => Error
  }
}

// [36, opt_sort_direction → DESC •, $ / LIMIT / COMMA / SEMICOLON]
fn yy_state_129(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_opt_sort_direction, yy_action_10)
}

// [35, opt_sort_direction → ASC •, $ / LIMIT / COMMA / SEMICOLON]
fn yy_state_130(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_opt_sort_direction, yy_action_9)
}

// [33, order_by_item → expr opt_sort_direction •, $ / LIMIT / COMMA / SEMICOLON]
fn yy_state_131(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_order_by_item, yy_action_8)
}

// [31, order_by_list → order_by_item •, $ / LIMIT / COMMA / SEMICOLON]
fn yy_state_132(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_order_by_list, yy_action_7)
}

// [30, opt_order_by → ORDER BY order_by_list •, $ / LIMIT / SEMICOLON]
// [32, order_by_list → order_by_list • COMMA order_by_item, $ / LIMIT / COMMA / SEMICOLON]
fn yy_state_133(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_COMMA => Shift(yy_state_134)
    T_LIMIT | T_SEMICOLON | EOI => Reduce(3, NT_opt_order_by, yy_action_6)
    _ => Error
  }
}

// [32, order_by_list → order_by_list COMMA • order_by_item, $ / LIMIT / COMMA / SEMICOLON]
// [33, order_by_item → • expr opt_sort_direction, $ / LIMIT / COMMA / SEMICOLON]
// [39, expr → • or_expr, $ / LIMIT / ASC / DESC / COMMA / SEMICOLON]
// [40, or_expr → • and_expr, $ / LIMIT / ASC / DESC / OR / COMMA / SEMICOLON]
// [41, or_expr → • or_expr OR and_expr, $ / LIMIT / ASC / DESC / OR / COMMA / SEMICOLON]
// [42, and_expr → • not_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [43, and_expr → • and_expr AND not_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [44, not_expr → • comparison_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [45, not_expr → • NOT not_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [46, comparison_expr → • additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [47, comparison_expr → • additive_expr EQ additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [48, comparison_expr → • additive_expr NEQ additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [49, comparison_expr → • additive_expr LT additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [50, comparison_expr → • additive_expr LTE additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [51, comparison_expr → • additive_expr GT additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [52, comparison_expr → • additive_expr GTE additive_expr, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [53, comparison_expr → • additive_expr IS NULL, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [54, comparison_expr → • additive_expr IS NOT NULL, $ / LIMIT / ASC / DESC / AND / OR / COMMA / SEMICOLON]
// [55, additive_expr → • multiplicative_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [56, additive_expr → • additive_expr PLUS multiplicative_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [57, additive_expr → • additive_expr MINUS multiplicative_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [58, multiplicative_expr → • unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [59, multiplicative_expr → • multiplicative_expr STAR unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [60, multiplicative_expr → • multiplicative_expr SLASH unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [61, unary_expr → • primary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [62, unary_expr → • PLUS unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [63, unary_expr → • MINUS unary_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [64, primary_expr → • function_call_expr, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [65, primary_expr → • identifier_path, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [66, primary_expr → • STRING_LITERAL, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [67, primary_expr → • INTEGER_LITERAL, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [68, primary_expr → • DOUBLE_LITERAL, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [69, primary_expr → • TRUE, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [70, primary_expr → • FALSE, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [71, primary_expr → • NULL, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [72, primary_expr → • LPAREN expr RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [73, primary_expr → • CAST LPAREN expr AS type_name RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [74, function_call_expr → • IDENT LPAREN RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [75, function_call_expr → • IDENT LPAREN argument_list RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [76, function_call_expr → • IDENT LPAREN STAR RPAREN, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [77, identifier_path → • IDENT, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
// [78, identifier_path → • identifier_path DOT IDENT, $ / LIMIT / ASC / DESC / IS / AND / OR / COMMA / DOT / PLUS / MINUS / STAR / SLASH / EQ / NEQ / LT / LTE / GT / GTE / SEMICOLON]
fn yy_state_134(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_IDENT => Shift(yy_state_3)
    T_CAST => Shift(yy_state_8)
    T_LPAREN => Shift(yy_state_19)
    T_NULL => Shift(yy_state_22)
    T_FALSE => Shift(yy_state_23)
    T_TRUE => Shift(yy_state_24)
    T_DOUBLE_LITERAL => Shift(yy_state_25)
    T_INTEGER_LITERAL => Shift(yy_state_26)
    T_STRING_LITERAL => Shift(yy_state_27)
    NT_identifier_path => Shift(yy_state_28)
    NT_function_call_expr => Shift(yy_state_31)
    T_MINUS => Shift(yy_state_32)
    T_PLUS => Shift(yy_state_34)
    NT_primary_expr => Shift(yy_state_36)
    NT_unary_expr => Shift(yy_state_37)
    NT_multiplicative_expr => Shift(yy_state_38)
    NT_additive_expr => Shift(yy_state_43)
    T_NOT => Shift(yy_state_64)
    NT_comparison_expr => Shift(yy_state_66)
    NT_not_expr => Shift(yy_state_67)
    NT_and_expr => Shift(yy_state_68)
    NT_or_expr => Shift(yy_state_71)
    NT_expr => Shift(yy_state_128)
    NT_order_by_item => Shift(yy_state_135)
    _ => Error
  }
}

// [32, order_by_list → order_by_list COMMA order_by_item •, $ / LIMIT / COMMA / SEMICOLON]
fn yy_state_135(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(3, NT_order_by_list, yy_action_5)
}

// [0, query → SELECT select_list FROM from_item opt_where opt_group_by opt_having opt_order_by • opt_limit opt_semicolon, $]
// [37, opt_limit → •, $ / SEMICOLON]
// [38, opt_limit → • LIMIT INTEGER_LITERAL, $ / SEMICOLON]
fn yy_state_136(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_LIMIT => Shift(yy_state_137)
    NT_opt_limit => Shift(yy_state_139)
    T_SEMICOLON | EOI => Reduce(0, NT_opt_limit, yy_action_4)
    _ => Error
  }
}

// [38, opt_limit → LIMIT • INTEGER_LITERAL, $ / SEMICOLON]
fn yy_state_137(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_INTEGER_LITERAL => Shift(yy_state_138)
    _ => Error
  }
}

// [38, opt_limit → LIMIT INTEGER_LITERAL •, $ / SEMICOLON]
fn yy_state_138(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(2, NT_opt_limit, yy_action_3)
}

// [0, query → SELECT select_list FROM from_item opt_where opt_group_by opt_having opt_order_by opt_limit • opt_semicolon, $]
// [1, opt_semicolon → •, $]
// [2, opt_semicolon → • SEMICOLON, $]
fn yy_state_139(_lookahead : YYSymbol) -> YYDecision {
  match _lookahead {
    T_SEMICOLON => Shift(yy_state_140)
    NT_opt_semicolon => Shift(yy_state_141)
    EOI => Reduce(0, NT_opt_semicolon, yy_action_2)
    _ => Error
  }
}

// [2, opt_semicolon → SEMICOLON •, $]
fn yy_state_140(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(1, NT_opt_semicolon, yy_action_1)
}

// [0, query → SELECT select_list FROM from_item opt_where opt_group_by opt_having opt_order_by opt_limit opt_semicolon •, $]
fn yy_state_141(_lookahead : YYSymbol) -> YYDecision {
  ReduceNoLookahead(10, NT_query, yy_action_0)
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
        for count = count, symbol = symbol, action = action {
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
              break ()
            }
            Reduce(count, symbol, action)
            | ReduceNoLookahead(count, symbol, action) => continue count, symbol, action
            _ => panic()
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
  for term in ([(T_IDENT, TK_IDENT), (T_STRING_LITERAL, TK_STRING_LITERAL), (T_INTEGER_LITERAL, TK_INTEGER_LITERAL), (T_DOUBLE_LITERAL, TK_DOUBLE_LITERAL), (T_SELECT, TK_SELECT), (T_FROM, TK_FROM), (T_WHERE, TK_WHERE), (T_GROUP, TK_GROUP), (T_BY, TK_BY), (T_HAVING, TK_HAVING), (T_ORDER, TK_ORDER), (T_LIMIT, TK_LIMIT), (T_JOIN, TK_JOIN), (T_INNER, TK_INNER), (T_ON, TK_ON), (T_ASC, TK_ASC), (T_DESC, TK_DESC), (T_AS, TK_AS), (T_CAST, TK_CAST), (T_IS, TK_IS), (T_NULL, TK_NULL), (T_NOT, TK_NOT), (T_AND, TK_AND), (T_OR, TK_OR), (T_TRUE, TK_TRUE), (T_FALSE, TK_FALSE), (T_BOOLEAN_T, TK_BOOLEAN_T), (T_BIGINT_T, TK_BIGINT_T), (T_DOUBLE_T, TK_DOUBLE_T), (T_VARCHAR_T, TK_VARCHAR_T), (T_LPAREN, TK_LPAREN), (T_RPAREN, TK_RPAREN), (T_COMMA, TK_COMMA), (T_DOT, TK_DOT), (T_PLUS, TK_PLUS), (T_MINUS, TK_MINUS), (T_STAR, TK_STAR), (T_SLASH, TK_SLASH), (T_EQ, TK_EQ), (T_NEQ, TK_NEQ), (T_LT, TK_LT), (T_LTE, TK_LTE), (T_GT, TK_GT), (T_GTE, TK_GTE), (T_SEMICOLON, TK_SEMICOLON)] : Array[(YYSymbol, TokenKind)]) {
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

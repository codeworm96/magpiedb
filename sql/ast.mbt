///|
pub(all) enum TypeName {
  Null
  Boolean
  BigInt
  Double
  Varchar
} derive(Eq, Debug)

///|
pub(all) enum UnaryOp {
  Plus
  Minus
  Not
} derive(Eq, Debug)

///|
pub(all) enum BinaryOp {
  Add
  Subtract
  Multiply
  Divide
  Equal
  NotEqual
  LessThan
  LessThanOrEqual
  GreaterThan
  GreaterThanOrEqual
  And
  Or
} derive(Eq, Debug)

///|
pub(all) enum Expr {
  ColumnRef(Array[String])
  StringLiteral(String)
  IntegerLiteral(String)
  DoubleLiteral(String)
  BooleanLiteral(Bool)
  NullLiteral
  Unary(UnaryOp, Expr)
  Binary(BinaryOp, Expr, Expr)
  IsNull(Expr)
  IsNotNull(Expr)
  Cast(Expr, TypeName)
} derive(Eq, Debug)

///|
pub struct SelectItem {
  expr : Expr
  output_name : String?
} derive(Eq, Debug)

///|
pub struct TableFunction {
  name : String
  arguments : Array[Expr]
} derive(Eq, Debug)

///|
pub struct Query {
  select_items : Array[SelectItem]
  from : TableFunction
  where_clause : Expr?
} derive(Eq, Debug)

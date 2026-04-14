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
  FunctionCall(String, Array[Expr])
  FunctionCallStar(String)
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
pub struct SourceRef {
  source : TableFunction
  alias_name : String?
} derive(Eq, Debug)

///|
pub(all) enum JoinKind {
  Inner
} derive(Eq, Debug)

///|
pub struct JoinRelation {
  left : SourceRef
  right : SourceRef
  join_kind : JoinKind
  on : Expr
} derive(Eq, Debug)

///|
pub(all) enum FromItem {
  Source(SourceRef)
  Join(JoinRelation)
} derive(Eq, Debug)

///|
pub(all) enum SortDirection {
  Asc
  Desc
} derive(Eq, Debug)

///|
pub struct OrderByItem {
  expr : Expr
  direction : SortDirection
} derive(Eq, Debug)

///|
pub struct Query {
  select_items : Array[SelectItem]
  from : FromItem
  where_clause : Expr?
  // Each GROUP BY item is a column-reference path like ["active"] or ["people", "active"].
  group_by : Array[Array[String]]
  having_clause : Expr?
  order_by : Array[OrderByItem]
  limit : String?
} derive(Eq, Debug)

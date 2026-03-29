///|
pub suberror PlanError {
  InvalidArgument(String)
  Bind(String)
  Scan(String)
  Io(String)
  Unsupported(String)
} derive(Show)

///|
pub(all) struct JsonlScan {
  path : String
  schema : @engine.Schema
} derive(Eq, Show)

///|
pub(all) enum ScanSource {
  Jsonl(JsonlScan)
} derive(Eq, Show)

///|
pub(all) struct BoundColumnRef {
  index : Int
  column : @engine.ColumnDef
} derive(Eq, Show)

///|
pub(all) enum PlanExpr {
  ColumnRef(BoundColumnRef)
  StringLiteral(String)
  IntegerLiteral(String)
  DoubleLiteral(String)
  BooleanLiteral(Bool)
  NullLiteral
  Unary(@sql.UnaryOp, PlanExpr)
  Binary(@sql.BinaryOp, PlanExpr, PlanExpr)
  IsNull(PlanExpr)
  IsNotNull(PlanExpr)
  Cast(PlanExpr, @engine.LogicalType)
} derive(Eq, Show)

///|
pub(all) struct PlanSelectItem {
  expr : PlanExpr
  output_name : String
} derive(Eq, Show)

///|
pub(all) struct ScanPlan {
  source : ScanSource
} derive(Eq, Show)

///|
pub(all) struct FilterPlan {
  input : QueryPlan
  predicate : PlanExpr
} derive(Eq, Show)

///|
pub(all) struct ProjectionPlan {
  input : QueryPlan
  projections : Array[PlanSelectItem]
  output_schema : @engine.Schema
} derive(Eq, Show)

///|
pub(all) enum QueryPlan {
  Scan(ScanPlan)
  Filter(FilterPlan)
  Projection(ProjectionPlan)
} derive(Eq, Show)

///|
pub fn plan_query(query : @sql.Query) -> QueryPlan raise PlanError {
  let source = bind_scan_source(query.from)
  let scan_plan = QueryPlan::Scan(ScanPlan::{ source, })
  let input_schema = query_plan_schema(scan_plan)
  let with_filter = match query.where_clause {
    None => scan_plan
    Some(expr) => {
      let predicate = bind_where_clause(expr, input_schema)
      QueryPlan::Filter(FilterPlan::{ input: scan_plan, predicate })
    }
  }
  let projections = bind_select_items(query.select_items, input_schema)
  let output_schema = build_output_schema(projections)
  QueryPlan::Projection(ProjectionPlan::{
    input: with_filter,
    projections,
    output_schema,
  })
}

///|
pub fn query_plan_schema(plan : QueryPlan) -> @engine.Schema {
  match plan {
    Scan(scan_plan) => scan_source_schema(scan_plan.source)
    Filter(filter_plan) => query_plan_schema(filter_plan.input)
    Projection(projection_plan) => projection_plan.output_schema
  }
}

///|
fn bind_scan_source(from : @sql.TableFunction) -> ScanSource raise PlanError {
  guard from.name == "read_jsonl" else {
    raise PlanError::Unsupported(
      "only read_jsonl(path) is supported in the current MVP",
    )
  }
  guard from.arguments.length() == 1 else {
    raise PlanError::InvalidArgument("read_jsonl requires exactly one argument")
  }
  let path = match from.arguments[0] {
    @sql.Expr::StringLiteral(path) => path
    _ =>
      raise PlanError::InvalidArgument(
        "read_jsonl path must be a string literal",
      )
  }
  let scanner = @scan.read_jsonl(path) catch {
    err => raise map_scan_error(err)
  }
  ScanSource::Jsonl(JsonlScan::{ path, schema: scanner.schema() })
}

///|
fn bind_where_clause(
  expr : @sql.Expr,
  schema : @engine.Schema,
) -> PlanExpr raise PlanError {
  let bound = bind_expr(expr, schema)
  match plan_expr_type(bound) {
    @engine.LogicalType::Boolean | @engine.LogicalType::Null => bound
    _ => raise PlanError::Bind("WHERE clause must evaluate to BOOLEAN")
  }
}

///|
fn bind_select_items(
  select_items : Array[@sql.SelectItem],
  schema : @engine.Schema,
) -> Array[PlanSelectItem] raise PlanError {
  let projections = []
  for index in 0..<select_items.length() {
    let item = select_items[index]
    let expr = bind_expr(item.expr, schema)
    let output_name = match item.output_name {
      Some(name) => name
      None => default_output_name(expr, index)
    }
    projections.push(PlanSelectItem::{ expr, output_name })
  }
  projections
}

///|
fn build_output_schema(
  projections : Array[PlanSelectItem],
) -> @engine.Schema raise PlanError {
  let columns = []
  for item in projections {
    columns.push(@engine.ColumnDef::{
      name: item.output_name,
      data_type: plan_expr_type(item.expr),
      nullable: plan_expr_nullable(item.expr),
    })
  }
  @engine.Schema::{ columns, }
}

///|
fn bind_expr(
  expr : @sql.Expr,
  schema : @engine.Schema,
) -> PlanExpr raise PlanError {
  match expr {
    @sql.Expr::ColumnRef(path) =>
      PlanExpr::ColumnRef(resolve_column(path, schema))
    @sql.Expr::StringLiteral(text) => PlanExpr::StringLiteral(text)
    @sql.Expr::IntegerLiteral(text) => PlanExpr::IntegerLiteral(text)
    @sql.Expr::DoubleLiteral(text) => PlanExpr::DoubleLiteral(text)
    @sql.Expr::BooleanLiteral(value) => PlanExpr::BooleanLiteral(value)
    @sql.Expr::NullLiteral => PlanExpr::NullLiteral
    @sql.Expr::Unary(op, inner) => bind_unary_expr(op, inner, schema)
    @sql.Expr::Binary(op, left, right) =>
      bind_binary_expr(op, left, right, schema)
    @sql.Expr::IsNull(inner) => PlanExpr::IsNull(bind_expr(inner, schema))
    @sql.Expr::IsNotNull(inner) => PlanExpr::IsNotNull(bind_expr(inner, schema))
    @sql.Expr::Cast(inner, type_name) =>
      PlanExpr::Cast(
        bind_expr(inner, schema),
        type_name_to_logical_type(type_name),
      )
  }
}

///|
fn bind_unary_expr(
  op : @sql.UnaryOp,
  inner : @sql.Expr,
  schema : @engine.Schema,
) -> PlanExpr raise PlanError {
  let bound_inner = bind_expr(inner, schema)
  match op {
    @sql.UnaryOp::Not =>
      match plan_expr_type(bound_inner) {
        @engine.LogicalType::Boolean | @engine.LogicalType::Null =>
          PlanExpr::Unary(op, bound_inner)
        _ => raise PlanError::Bind("NOT requires a BOOLEAN expression")
      }
    @sql.UnaryOp::Plus | @sql.UnaryOp::Minus =>
      match plan_expr_type(bound_inner) {
        @engine.LogicalType::BigInt
        | @engine.LogicalType::Double
        | @engine.LogicalType::Null => PlanExpr::Unary(op, bound_inner)
        _ =>
          raise PlanError::Bind("numeric expression requires BIGINT or DOUBLE")
      }
  }
}

///|
fn bind_binary_expr(
  op : @sql.BinaryOp,
  left : @sql.Expr,
  right : @sql.Expr,
  schema : @engine.Schema,
) -> PlanExpr raise PlanError {
  let bound_left = bind_expr(left, schema)
  let bound_right = bind_expr(right, schema)
  match op {
    @sql.BinaryOp::Add
    | @sql.BinaryOp::Subtract
    | @sql.BinaryOp::Multiply
    | @sql.BinaryOp::Divide => {
      ignore(infer_binary_numeric_type(bound_left, bound_right))
      PlanExpr::Binary(op, bound_left, bound_right)
    }
    @sql.BinaryOp::And | @sql.BinaryOp::Or => {
      validate_boolean_expr(bound_left)
      validate_boolean_expr(bound_right)
      PlanExpr::Binary(op, bound_left, bound_right)
    }
    _ => {
      ignore(plan_expr_type(bound_left))
      ignore(plan_expr_type(bound_right))
      PlanExpr::Binary(op, bound_left, bound_right)
    }
  }
}

///|
fn scan_source_schema(source : ScanSource) -> @engine.Schema {
  match source {
    Jsonl(scan) => scan.schema
  }
}

///|
fn validate_boolean_expr(expr : PlanExpr) -> Unit raise PlanError {
  match plan_expr_type(expr) {
    @engine.LogicalType::Boolean => ()
    @engine.LogicalType::Null => ()
    _ => raise PlanError::Bind("boolean operator requires BOOLEAN operands")
  }
}

///|
fn infer_binary_numeric_type(
  left : PlanExpr,
  right : PlanExpr,
) -> @engine.LogicalType raise PlanError {
  let left_type = infer_numeric_type(left)
  let right_type = infer_numeric_type(right)
  match (left_type, right_type) {
    (@engine.LogicalType::Double, _) => @engine.LogicalType::Double
    (_, @engine.LogicalType::Double) => @engine.LogicalType::Double
    (@engine.LogicalType::Null, other) => other
    (other, @engine.LogicalType::Null) => other
    _ => @engine.LogicalType::BigInt
  }
}

///|
fn infer_numeric_type(expr : PlanExpr) -> @engine.LogicalType raise PlanError {
  match plan_expr_type(expr) {
    @engine.LogicalType::BigInt => @engine.LogicalType::BigInt
    @engine.LogicalType::Double => @engine.LogicalType::Double
    @engine.LogicalType::Null => @engine.LogicalType::Null
    _ => raise PlanError::Bind("numeric expression requires BIGINT or DOUBLE")
  }
}

///|
fn resolve_column(
  path : Array[String],
  schema : @engine.Schema,
) -> BoundColumnRef raise PlanError {
  guard path.length() > 0 else {
    raise PlanError::Bind("empty column reference")
  }
  let name = path[path.length() - 1]
  match schema.column_index(name) {
    Some(index) => BoundColumnRef::{ index, column: schema.columns[index] }
    None => raise PlanError::Bind("unknown column: \{name}")
  }
}

///|
fn plan_expr_type(expr : PlanExpr) -> @engine.LogicalType raise PlanError {
  match expr {
    ColumnRef(column_ref) => column_ref.column.data_type
    StringLiteral(_) => @engine.LogicalType::Varchar
    IntegerLiteral(_) => @engine.LogicalType::BigInt
    DoubleLiteral(_) => @engine.LogicalType::Double
    BooleanLiteral(_) => @engine.LogicalType::Boolean
    NullLiteral => @engine.LogicalType::Null
    Unary(op, inner) =>
      match op {
        @sql.UnaryOp::Not => @engine.LogicalType::Boolean
        @sql.UnaryOp::Plus | @sql.UnaryOp::Minus => plan_expr_type(inner)
      }
    Binary(op, left, right) =>
      match op {
        @sql.BinaryOp::Add
        | @sql.BinaryOp::Subtract
        | @sql.BinaryOp::Multiply
        | @sql.BinaryOp::Divide => infer_binary_numeric_type(left, right)
        _ => @engine.LogicalType::Boolean
      }
    IsNull(_) | IsNotNull(_) => @engine.LogicalType::Boolean
    Cast(_, logical_type) => logical_type
  }
}

///|
fn plan_expr_nullable(expr : PlanExpr) -> Bool {
  match expr {
    ColumnRef(column_ref) => column_ref.column.nullable
    NullLiteral => true
    Unary(_, inner) => plan_expr_nullable(inner)
    Binary(_, left, right) =>
      plan_expr_nullable(left) || plan_expr_nullable(right)
    Cast(inner, _) => plan_expr_nullable(inner)
    _ => false
  }
}

///|
fn default_output_name(expr : PlanExpr, index : Int) -> String {
  match expr {
    ColumnRef(column_ref) => column_ref.column.name
    _ => "expr\{index + 1}"
  }
}

///|
fn type_name_to_logical_type(type_name : @sql.TypeName) -> @engine.LogicalType {
  match type_name {
    @sql.TypeName::Null => @engine.LogicalType::Null
    @sql.TypeName::Boolean => @engine.LogicalType::Boolean
    @sql.TypeName::BigInt => @engine.LogicalType::BigInt
    @sql.TypeName::Double => @engine.LogicalType::Double
    @sql.TypeName::Varchar => @engine.LogicalType::Varchar
  }
}

///|
fn map_scan_error(err : @scan.ScanError) -> PlanError {
  match err {
    @scan.ScanError::Io(message) => PlanError::Io(message)
    @scan.ScanError::CsvMalformed(message) => PlanError::Scan(message)
    @scan.ScanError::JsonParse(line_no, message) =>
      PlanError::Scan("json parse error at line \{line_no}: \{message}")
    @scan.ScanError::JsonRootNotObject(line_no) =>
      PlanError::Scan("expected JSON object at line \{line_no}")
    @scan.ScanError::TypeMismatch(column, line_no, message) =>
      PlanError::Scan(
        "type mismatch for column \{column} at line \{line_no}: \{message}",
      )
  }
}

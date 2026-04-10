///|
pub suberror PlanError {
  InvalidArgument(String)
  Bind(String)
  Scan(String)
  Io(String)
  Unsupported(String)
} derive(Debug)

///|
pub(all) struct CsvScan {
  path : String
  schema : @engine.Schema
} derive(Eq, Debug)

///|
pub(all) struct JsonlScan {
  path : String
  schema : @engine.Schema
} derive(Eq, Debug)

///|
pub(all) enum ScanSource {
  Csv(CsvScan)
  Jsonl(JsonlScan)
} derive(Eq, Debug)

///|
pub(all) struct BoundColumnRef {
  index : Int
  column : @engine.ColumnDef
} derive(Eq, Debug)

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
} derive(Eq, Debug)

///|
pub(all) struct PlanSelectItem {
  expr : PlanExpr
  output_name : String
} derive(Eq, Debug)

///|
pub(all) enum AggregateKind {
  CountStar
  Count
  Sum
  Avg
  Min
  Max
} derive(Eq, Debug)

///|
pub(all) struct AggregateDef {
  kind : AggregateKind
  input_expr : PlanExpr?
  result_column : @engine.ColumnDef
} derive(Eq, Debug)

///|
pub(all) struct ScanPlan {
  source : ScanSource
} derive(Eq, Debug)

///|
pub(all) struct FilterPlan {
  input : QueryPlan
  predicate : PlanExpr
} derive(Eq, Debug)

///|
pub(all) struct AggregatePlan {
  input : QueryPlan
  group_keys : Array[BoundColumnRef]
  aggregates : Array[AggregateDef]
  output_schema : @engine.Schema
} derive(Eq, Debug)

///|
pub(all) struct ProjectionPlan {
  input : QueryPlan
  projections : Array[PlanSelectItem]
  output_schema : @engine.Schema
} derive(Eq, Debug)

///|
pub(all) enum QueryPlan {
  Scan(ScanPlan)
  Filter(FilterPlan)
  Aggregate(AggregatePlan)
  Projection(ProjectionPlan)
} derive(Eq, Debug)

///|
priv struct AggregateBindContext {
  input_schema : @engine.Schema
  group_keys : Array[BoundColumnRef]
  aggregates : Array[AggregateDef]
}

///|
pub fn plan_query(query : @sql.Query) -> QueryPlan raise PlanError {
  let source = bind_scan_source(query.from)
  let scan_plan = QueryPlan::Scan(ScanPlan::{ source, })
  let input_schema = query_plan_schema(scan_plan)

  if contains_aggregate_in_query(query) || query.group_by.length() > 0 {
    plan_aggregate_query(query, scan_plan, input_schema)
  } else {
    guard query.having_clause is None else {
      raise PlanError::Bind("HAVING requires GROUP BY or aggregate functions")
    }
    plan_scalar_query(query, scan_plan, input_schema)
  }
}

///|
pub fn query_plan_schema(plan : QueryPlan) -> @engine.Schema {
  match plan {
    Scan(scan_plan) => scan_source_schema(scan_plan.source)
    Filter(filter_plan) => query_plan_schema(filter_plan.input)
    Aggregate(aggregate_plan) => aggregate_plan.output_schema
    Projection(projection_plan) => projection_plan.output_schema
  }
}

///|
fn plan_scalar_query(
  query : @sql.Query,
  scan_plan : QueryPlan,
  input_schema : @engine.Schema,
) -> QueryPlan raise PlanError {
  guard !contains_aggregate_expr_option(query.where_clause) else {
    raise PlanError::Bind("aggregate functions are not allowed in WHERE")
  }
  let with_filter = match query.where_clause {
    None => scan_plan
    Some(expr) => {
      let predicate = bind_scalar_expr(expr, input_schema)
      match plan_expr_type(predicate) {
        @engine.LogicalType::Boolean | @engine.LogicalType::Null => ()
        _ => raise PlanError::Bind("WHERE clause must evaluate to BOOLEAN")
      }
      QueryPlan::Filter(FilterPlan::{ input: scan_plan, predicate })
    }
  }
  let projections = bind_scalar_select_items(query.select_items, input_schema)
  let output_schema = build_output_schema(projections)
  QueryPlan::Projection(ProjectionPlan::{
    input: with_filter,
    projections,
    output_schema,
  })
}

///|
fn plan_aggregate_query(
  query : @sql.Query,
  scan_plan : QueryPlan,
  input_schema : @engine.Schema,
) -> QueryPlan raise PlanError {
  guard !contains_aggregate_expr_option(query.where_clause) else {
    raise PlanError::Bind("aggregate functions are not allowed in WHERE")
  }
  let with_filter = match query.where_clause {
    None => scan_plan
    Some(expr) => {
      let predicate = bind_scalar_expr(expr, input_schema)
      match plan_expr_type(predicate) {
        @engine.LogicalType::Boolean | @engine.LogicalType::Null => ()
        _ => raise PlanError::Bind("WHERE clause must evaluate to BOOLEAN")
      }
      QueryPlan::Filter(FilterPlan::{ input: scan_plan, predicate })
    }
  }

  let group_keys = bind_group_keys(query.group_by, input_schema)
  let context = AggregateBindContext::{
    input_schema,
    group_keys,
    aggregates: [],
  }
  let projections = bind_aggregate_select_items(query.select_items, context)
  let having_expr = match query.having_clause {
    None => None
    Some(expr) => {
      let predicate = bind_post_aggregate_expr(expr, context)
      match plan_expr_type(predicate) {
        @engine.LogicalType::Boolean | @engine.LogicalType::Null =>
          Some(predicate)
        _ => raise PlanError::Bind("HAVING clause must evaluate to BOOLEAN")
      }
    }
  }

  let aggregate_output_schema = build_aggregate_output_schema(context)
  let aggregate_plan = QueryPlan::Aggregate(AggregatePlan::{
    input: with_filter,
    group_keys: context.group_keys,
    aggregates: context.aggregates,
    output_schema: aggregate_output_schema,
  })
  let with_having = match having_expr {
    Some(predicate) =>
      QueryPlan::Filter(FilterPlan::{ input: aggregate_plan, predicate })
    None => aggregate_plan
  }
  let output_schema = build_output_schema(projections)
  QueryPlan::Projection(ProjectionPlan::{
    input: with_having,
    projections,
    output_schema,
  })
}

///|
fn bind_scan_source(from : @sql.TableFunction) -> ScanSource raise PlanError {
  guard from.arguments.length() == 1 else {
    raise PlanError::InvalidArgument(
      "\{from.name} requires exactly one argument",
    )
  }
  let path = match from.arguments[0] {
    @sql.Expr::StringLiteral(path) => path
    _ =>
      raise PlanError::InvalidArgument(
        "\{from.name} path must be a string literal",
      )
  }
  match from.name {
    "read_csv" => {
      let scanner = @scan.read_csv(path) catch {
        err => raise map_scan_error(err)
      }
      ScanSource::Csv(CsvScan::{ path, schema: scanner.schema() })
    }
    "read_jsonl" => {
      let scanner = @scan.read_jsonl(path) catch {
        err => raise map_scan_error(err)
      }
      ScanSource::Jsonl(JsonlScan::{ path, schema: scanner.schema() })
    }
    _ =>
      raise PlanError::Unsupported(
        "only read_csv(path) and read_jsonl(path) are supported in the current MVP",
      )
  }
}

///|
fn bind_group_keys(
  group_by : Array[Array[String]],
  input_schema : @engine.Schema,
) -> Array[BoundColumnRef] raise PlanError {
  let keys = []
  for path in group_by {
    keys.push(resolve_column(path, input_schema))
  }
  keys
}

///|
fn bind_scalar_select_items(
  select_items : Array[@sql.SelectItem],
  schema : @engine.Schema,
) -> Array[PlanSelectItem] raise PlanError {
  let projections = []
  for index in 0..<select_items.length() {
    let item = select_items[index]
    let expr = bind_scalar_expr(item.expr, schema)
    let output_name = match item.output_name {
      Some(name) => name
      None => default_output_name_from_sql_expr(item.expr, expr, index)
    }
    projections.push(PlanSelectItem::{ expr, output_name })
  }
  projections
}

///|
fn bind_aggregate_select_items(
  select_items : Array[@sql.SelectItem],
  context : AggregateBindContext,
) -> Array[PlanSelectItem] raise PlanError {
  let projections = []
  for index in 0..<select_items.length() {
    let item = select_items[index]
    let expr = bind_post_aggregate_expr(item.expr, context)
    let output_name = match item.output_name {
      Some(name) => name
      None => default_output_name_from_sql_expr(item.expr, expr, index)
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
fn build_aggregate_output_schema(
  context : AggregateBindContext,
) -> @engine.Schema {
  let columns = []
  for group_key in context.group_keys {
    columns.push(group_key.column)
  }
  for aggregate in context.aggregates {
    columns.push(aggregate.result_column)
  }
  @engine.Schema::{ columns, }
}

///|
fn bind_scalar_expr(
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
    @sql.Expr::FunctionCall(name, _) =>
      raise unsupported_or_nested_function(name, false)
    @sql.Expr::FunctionCallStar(name) =>
      raise unsupported_or_nested_function(name, false)
    @sql.Expr::Unary(op, inner) => bind_unary_expr(op, inner, schema)
    @sql.Expr::Binary(op, left, right) =>
      bind_binary_expr(op, left, right, schema)
    @sql.Expr::IsNull(inner) =>
      PlanExpr::IsNull(bind_scalar_expr(inner, schema))
    @sql.Expr::IsNotNull(inner) =>
      PlanExpr::IsNotNull(bind_scalar_expr(inner, schema))
    @sql.Expr::Cast(inner, type_name) =>
      PlanExpr::Cast(
        bind_scalar_expr(inner, schema),
        type_name_to_logical_type(type_name),
      )
  }
}

///|
fn bind_scalar_expr_disallow_aggregate(
  expr : @sql.Expr,
  schema : @engine.Schema,
) -> PlanExpr raise PlanError {
  match expr {
    @sql.Expr::FunctionCall(name, _) =>
      raise unsupported_or_nested_function(name, true)
    @sql.Expr::FunctionCallStar(name) =>
      raise unsupported_or_nested_function(name, true)
    _ => bind_scalar_expr(expr, schema)
  }
}

///|
fn bind_post_aggregate_expr(
  expr : @sql.Expr,
  context : AggregateBindContext,
) -> PlanExpr raise PlanError {
  match expr {
    @sql.Expr::ColumnRef(path) => bind_grouped_column_ref(path, context)
    @sql.Expr::StringLiteral(text) => PlanExpr::StringLiteral(text)
    @sql.Expr::IntegerLiteral(text) => PlanExpr::IntegerLiteral(text)
    @sql.Expr::DoubleLiteral(text) => PlanExpr::DoubleLiteral(text)
    @sql.Expr::BooleanLiteral(value) => PlanExpr::BooleanLiteral(value)
    @sql.Expr::NullLiteral => PlanExpr::NullLiteral
    @sql.Expr::FunctionCall(name, args) =>
      bind_aggregate_call(name, args, context)
    @sql.Expr::FunctionCallStar(name) => bind_aggregate_star(name, context)
    @sql.Expr::Unary(op, inner) =>
      bind_post_aggregate_unary_expr(op, inner, context)
    @sql.Expr::Binary(op, left, right) =>
      bind_post_aggregate_binary_expr(op, left, right, context)
    @sql.Expr::IsNull(inner) =>
      PlanExpr::IsNull(bind_post_aggregate_expr(inner, context))
    @sql.Expr::IsNotNull(inner) =>
      PlanExpr::IsNotNull(bind_post_aggregate_expr(inner, context))
    @sql.Expr::Cast(inner, type_name) =>
      PlanExpr::Cast(
        bind_post_aggregate_expr(inner, context),
        type_name_to_logical_type(type_name),
      )
  }
}

///|
fn bind_grouped_column_ref(
  path : Array[String],
  context : AggregateBindContext,
) -> PlanExpr raise PlanError {
  guard path.length() > 0 else {
    raise PlanError::Bind("empty column reference")
  }
  let name = path[path.length() - 1]
  for index in 0..<context.group_keys.length() {
    if context.group_keys[index].column.name == name {
      return PlanExpr::ColumnRef(BoundColumnRef::{
        index,
        column: context.group_keys[index].column,
      })
    }
  }
  raise PlanError::Bind(
    "column must appear in GROUP BY or be used in an aggregate function: \{name}",
  )
}

///|
fn bind_aggregate_call(
  name : String,
  args : Array[@sql.Expr],
  context : AggregateBindContext,
) -> PlanExpr raise PlanError {
  let normalized = normalize_function_name(name)
  let kind = aggregate_kind_from_name(normalized) catch {
    _ =>
      raise PlanError::Unsupported("function calls are not supported: \{name}")
  }
  guard normalized != "COUNT" else {
    guard args.length() == 1 else {
      raise PlanError::Bind("COUNT requires exactly one argument")
    }
    let input_expr = bind_scalar_expr_disallow_aggregate(
      args[0],
      context.input_schema,
    )
    return register_aggregate(kind, Some(input_expr), context)
  }
  guard args.length() == 1 else {
    raise PlanError::Bind("\{normalized} requires exactly one argument")
  }
  let input_expr = bind_scalar_expr_disallow_aggregate(
    args[0],
    context.input_schema,
  )
  register_aggregate(kind, Some(input_expr), context)
}

///|
fn bind_aggregate_star(
  name : String,
  context : AggregateBindContext,
) -> PlanExpr raise PlanError {
  let normalized = normalize_function_name(name)
  guard normalized == "COUNT" else {
    raise PlanError::Bind("only COUNT supports *")
  }
  register_aggregate(AggregateKind::CountStar, None, context)
}

///|
fn register_aggregate(
  kind : AggregateKind,
  input_expr : PlanExpr?,
  context : AggregateBindContext,
) -> PlanExpr raise PlanError {
  for index in 0..<context.aggregates.length() {
    let aggregate = context.aggregates[index]
    if aggregate.kind == kind && aggregate.input_expr == input_expr {
      return PlanExpr::ColumnRef(BoundColumnRef::{
        index: context.group_keys.length() + index,
        column: aggregate.result_column,
      })
    }
  }
  let result_column = aggregate_result_column(
    kind,
    input_expr,
    context.aggregates.length() + 1,
  )
  context.aggregates.push(AggregateDef::{ kind, input_expr, result_column })
  let index = context.group_keys.length() + context.aggregates.length() - 1
  PlanExpr::ColumnRef(BoundColumnRef::{ index, column: result_column })
}

///|
fn aggregate_result_column(
  kind : AggregateKind,
  input_expr : PlanExpr?,
  ordinal : Int,
) -> @engine.ColumnDef raise PlanError {
  let name = "__agg\{ordinal}"
  match kind {
    AggregateKind::CountStar | AggregateKind::Count =>
      @engine.ColumnDef::{
        name,
        data_type: @engine.LogicalType::BigInt,
        nullable: false,
      }
    AggregateKind::Sum => {
      let input_type = require_aggregate_input_type(kind, input_expr)
      match input_type {
        @engine.LogicalType::BigInt =>
          @engine.ColumnDef::{
            name,
            data_type: @engine.LogicalType::BigInt,
            nullable: true,
          }
        @engine.LogicalType::Double =>
          @engine.ColumnDef::{
            name,
            data_type: @engine.LogicalType::Double,
            nullable: true,
          }
        _ => raise PlanError::Bind("SUM requires BIGINT or DOUBLE input")
      }
    }
    AggregateKind::Avg => {
      let input_type = require_aggregate_input_type(kind, input_expr)
      match input_type {
        @engine.LogicalType::BigInt | @engine.LogicalType::Double =>
          @engine.ColumnDef::{
            name,
            data_type: @engine.LogicalType::Double,
            nullable: true,
          }
        _ => raise PlanError::Bind("AVG requires BIGINT or DOUBLE input")
      }
    }
    AggregateKind::Min | AggregateKind::Max => {
      let input_type = require_aggregate_input_type(kind, input_expr)
      match input_type {
        @engine.LogicalType::Boolean
        | @engine.LogicalType::BigInt
        | @engine.LogicalType::Double
        | @engine.LogicalType::Varchar =>
          @engine.ColumnDef::{ name, data_type: input_type, nullable: true }
        @engine.LogicalType::Null =>
          @engine.ColumnDef::{
            name,
            data_type: @engine.LogicalType::Null,
            nullable: true,
          }
      }
    }
  }
}

///|
fn require_aggregate_input_type(
  kind : AggregateKind,
  input_expr : PlanExpr?,
) -> @engine.LogicalType raise PlanError {
  match input_expr {
    Some(expr) => plan_expr_type(expr)
    None =>
      raise PlanError::Bind(
        "aggregate \{aggregate_default_name(kind)} requires an input expression",
      )
  }
}

///|
fn bind_post_aggregate_unary_expr(
  op : @sql.UnaryOp,
  inner : @sql.Expr,
  context : AggregateBindContext,
) -> PlanExpr raise PlanError {
  let bound_inner = bind_post_aggregate_expr(inner, context)
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
fn bind_post_aggregate_binary_expr(
  op : @sql.BinaryOp,
  left : @sql.Expr,
  right : @sql.Expr,
  context : AggregateBindContext,
) -> PlanExpr raise PlanError {
  let bound_left = bind_post_aggregate_expr(left, context)
  let bound_right = bind_post_aggregate_expr(right, context)
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
fn bind_unary_expr(
  op : @sql.UnaryOp,
  inner : @sql.Expr,
  schema : @engine.Schema,
) -> PlanExpr raise PlanError {
  let bound_inner = bind_scalar_expr(inner, schema)
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
  let bound_left = bind_scalar_expr(left, schema)
  let bound_right = bind_scalar_expr(right, schema)
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
fn contains_aggregate_in_query(query : @sql.Query) -> Bool {
  contains_aggregate_select_items(query.select_items) ||
  contains_aggregate_expr_option(query.having_clause)
}

///|
fn contains_aggregate_select_items(
  select_items : Array[@sql.SelectItem],
) -> Bool {
  for item in select_items {
    if contains_aggregate_expr(item.expr) {
      return true
    }
  }
  false
}

///|
fn contains_aggregate_expr_option(expr : @sql.Expr?) -> Bool {
  match expr {
    Some(expr) => contains_aggregate_expr(expr)
    None => false
  }
}

///|
fn contains_aggregate_expr(expr : @sql.Expr) -> Bool {
  match expr {
    @sql.Expr::FunctionCall(name, args) =>
      if is_aggregate_name(name) {
        true
      } else {
        for arg in args {
          if contains_aggregate_expr(arg) {
            return true
          }
        }
        false
      }
    @sql.Expr::FunctionCallStar(name) => is_aggregate_name(name)
    @sql.Expr::Unary(_, inner) => contains_aggregate_expr(inner)
    @sql.Expr::Binary(_, left, right) =>
      contains_aggregate_expr(left) || contains_aggregate_expr(right)
    @sql.Expr::IsNull(inner) | @sql.Expr::IsNotNull(inner) =>
      contains_aggregate_expr(inner)
    @sql.Expr::Cast(inner, _) => contains_aggregate_expr(inner)
    _ => false
  }
}

///|
fn is_aggregate_name(name : String) -> Bool {
  match normalize_function_name(name) {
    "COUNT" | "SUM" | "AVG" | "MIN" | "MAX" => true
    _ => false
  }
}

///|
fn aggregate_kind_from_name(name : String) -> AggregateKind raise PlanError {
  match name {
    "COUNT" => AggregateKind::Count
    "SUM" => AggregateKind::Sum
    "AVG" => AggregateKind::Avg
    "MIN" => AggregateKind::Min
    "MAX" => AggregateKind::Max
    _ =>
      raise PlanError::Unsupported("function calls are not supported: \{name}")
  }
}

///|
fn normalize_function_name(name : String) -> String {
  name.to_upper()
}

///|
fn unsupported_or_nested_function(name : String, nested : Bool) -> PlanError {
  if is_aggregate_name(name) && nested {
    PlanError::Bind("nested aggregates are not allowed")
  } else if is_aggregate_name(name) {
    PlanError::Bind("aggregate functions are only valid in aggregate queries")
  } else {
    PlanError::Unsupported("function calls are not supported: \{name}")
  }
}

///|
fn scan_source_schema(source : ScanSource) -> @engine.Schema {
  match source {
    Csv(scan) => scan.schema
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
fn default_output_name_from_sql_expr(
  original_expr : @sql.Expr,
  bound_expr : PlanExpr,
  index : Int,
) -> String {
  match original_expr {
    @sql.Expr::FunctionCall(name, _) =>
      aggregate_default_name_from_function(name)
    @sql.Expr::FunctionCallStar(name) =>
      aggregate_default_name_from_function(name)
    _ => default_output_name(bound_expr, index)
  }
}

///|
fn aggregate_default_name_from_function(name : String) -> String {
  match normalize_function_name(name) {
    "COUNT" => "count"
    "SUM" => "sum"
    "AVG" => "avg"
    "MIN" => "min"
    "MAX" => "max"
    _ => "expr"
  }
}

///|
fn aggregate_default_name(kind : AggregateKind) -> String {
  match kind {
    AggregateKind::CountStar | AggregateKind::Count => "count"
    AggregateKind::Sum => "sum"
    AggregateKind::Avg => "avg"
    AggregateKind::Min => "min"
    AggregateKind::Max => "max"
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

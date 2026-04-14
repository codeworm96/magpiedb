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
pub(all) struct JoinPlan {
  left : QueryPlan
  right : QueryPlan
  join_kind : @sql.JoinKind
  left_key : BoundColumnRef
  right_key : BoundColumnRef
  output_schema : @engine.Schema
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
  Join(JoinPlan)
  Filter(FilterPlan)
  Aggregate(AggregatePlan)
  Projection(ProjectionPlan)
} derive(Eq, Debug)

///|
priv struct BoundRelation {
  schema : @engine.Schema
  alias_name : String?
  relation_name : String
  output_offset : Int
}

///|
priv struct ColumnBindContext {
  schema : @engine.Schema
  relations : Array[BoundRelation]
}

///|
priv struct BoundFrom {
  plan : QueryPlan
  context : ColumnBindContext
}

///|
priv struct JoinColumnRef {
  relation_index : Int
  local_ref : BoundColumnRef
}

///|
priv struct AggregateBindContext {
  input_context : ColumnBindContext
  group_keys : Array[BoundColumnRef]
  aggregates : Array[AggregateDef]
}

///|
priv enum PlanErrorKind {
  Scan
  Io
}

///|
pub fn plan_query(query : @sql.Query) -> QueryPlan raise PlanError {
  guard query.order_by.length() == 0 else {
    raise PlanError::Unsupported("ORDER BY is not planned yet")
  }
  guard query.limit is None else {
    raise PlanError::Unsupported("LIMIT is not planned yet")
  }
  let bound_from = bind_from_item(query.from)

  if contains_aggregate_in_query(query) || query.group_by.length() > 0 {
    plan_aggregate_query(query, bound_from.plan, bound_from.context)
  } else {
    guard query.having_clause is None else {
      raise PlanError::Bind("HAVING requires GROUP BY or aggregate functions")
    }
    plan_scalar_query(query, bound_from.plan, bound_from.context)
  }
}

///|
pub fn query_plan_schema(plan : QueryPlan) -> @engine.Schema {
  match plan {
    Scan(scan_plan) => scan_source_schema(scan_plan.source)
    Join(join_plan) => join_plan.output_schema
    Filter(filter_plan) => query_plan_schema(filter_plan.input)
    Aggregate(aggregate_plan) => aggregate_plan.output_schema
    Projection(projection_plan) => projection_plan.output_schema
  }
}

///|
fn plan_scalar_query(
  query : @sql.Query,
  input_plan : QueryPlan,
  context : ColumnBindContext,
) -> QueryPlan raise PlanError {
  let with_filter = apply_where_filter(query.where_clause, input_plan, context)
  let projections = bind_scalar_select_items(query.select_items, context)
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
  input_plan : QueryPlan,
  context : ColumnBindContext,
) -> QueryPlan raise PlanError {
  let with_filter = apply_where_filter(query.where_clause, input_plan, context)

  let group_keys = bind_group_keys(query.group_by, context)
  let context = AggregateBindContext::{
    input_context: context,
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
fn apply_where_filter(
  where_clause : @sql.Expr?,
  input_plan : QueryPlan,
  context : ColumnBindContext,
) -> QueryPlan raise PlanError {
  guard !contains_aggregate_expr_option(where_clause) else {
    raise PlanError::Bind("aggregate functions are not allowed in WHERE")
  }
  match where_clause {
    None => input_plan
    Some(expr) => {
      let predicate = bind_scalar_expr(expr, context)
      match plan_expr_type(predicate) {
        @engine.LogicalType::Boolean | @engine.LogicalType::Null => ()
        _ => raise PlanError::Bind("WHERE clause must evaluate to BOOLEAN")
      }
      QueryPlan::Filter(FilterPlan::{ input: input_plan, predicate })
    }
  }
}

///|
fn bind_from_item(from : @sql.FromItem) -> BoundFrom raise PlanError {
  match from {
    @sql.FromItem::Source(source_ref) => {
      let source = bind_source_ref(source_ref)
      let schema = scan_source_schema(source)
      let relation = BoundRelation::{
        schema,
        alias_name: source_ref.alias_name,
        relation_name: source_ref.source.name,
        output_offset: 0,
      }
      BoundFrom::{
        plan: QueryPlan::Scan(ScanPlan::{ source, }),
        context: ColumnBindContext::{ schema, relations: [relation] },
      }
    }
    @sql.FromItem::Join(join) => bind_join_from_item(join)
  }
}

///|
fn bind_join_from_item(join : @sql.JoinRelation) -> BoundFrom raise PlanError {
  let left_source = bind_source_ref(join.left)
  let right_source = bind_source_ref(join.right)
  let left_schema = scan_source_schema(left_source)
  let right_schema = scan_source_schema(right_source)
  let left_relation = BoundRelation::{
    schema: left_schema,
    alias_name: join.left.alias_name,
    relation_name: join.left.source.name,
    output_offset: 0,
  }
  let right_relation = BoundRelation::{
    schema: right_schema,
    alias_name: join.right.alias_name,
    relation_name: join.right.source.name,
    output_offset: left_schema.columns.length(),
  }
  let context = ColumnBindContext::{
    schema: join_output_schema(left_schema, right_schema),
    relations: [left_relation, right_relation],
  }
  let (left_key, right_key) = bind_join_predicate(join.on, context)
  let plan = QueryPlan::Join(JoinPlan::{
    left: QueryPlan::Scan(ScanPlan::{ source: left_source }),
    right: QueryPlan::Scan(ScanPlan::{ source: right_source }),
    join_kind: join.join_kind,
    left_key: left_key.local_ref,
    right_key: right_key.local_ref,
    output_schema: context.schema,
  })
  BoundFrom::{ plan, context }
}

///|
fn bind_source_ref(source_ref : @sql.SourceRef) -> ScanSource raise PlanError {
  let source = source_ref.source
  guard source.arguments.length() == 1 else {
    raise PlanError::InvalidArgument(
      "\{source.name} requires exactly one argument",
    )
  }
  let path = match source.arguments[0] {
    @sql.Expr::StringLiteral(path) => path
    _ =>
      raise PlanError::InvalidArgument(
        "\{source.name} path must be a string literal",
      )
  }
  let kind = match @scan.scan_source_kind(source.name) {
    Some(kind) => kind
    None =>
      raise PlanError::Unsupported(
        "only read_csv(path) and read_jsonl(path) are supported in the current MVP",
      )
  }
  let schema = @scan.infer_source_schema(kind, path) catch {
    err => raise map_scan_error(err)
  }
  match kind {
    @scan.ScanSourceKind::Csv => ScanSource::Csv(CsvScan::{ path, schema })
    @scan.ScanSourceKind::Jsonl =>
      ScanSource::Jsonl(JsonlScan::{ path, schema })
  }
}

///|
fn join_output_schema(
  left_schema : @engine.Schema,
  right_schema : @engine.Schema,
) -> @engine.Schema {
  let columns = []
  for column in left_schema.columns {
    columns.push(column)
  }
  for column in right_schema.columns {
    columns.push(column)
  }
  @engine.Schema::{ columns, }
}

///|
fn bind_group_keys(
  group_by : Array[Array[String]],
  context : ColumnBindContext,
) -> Array[BoundColumnRef] raise PlanError {
  let keys = []
  for path in group_by {
    keys.push(resolve_column(path, context))
  }
  keys
}

///|
fn bind_scalar_select_items(
  select_items : Array[@sql.SelectItem],
  context : ColumnBindContext,
) -> Array[PlanSelectItem] raise PlanError {
  let projections = []
  for index in 0..<select_items.length() {
    let item = select_items[index]
    let expr = bind_scalar_expr(item.expr, context)
    projections.push(build_bound_select_item(item, expr, index))
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
    projections.push(build_bound_select_item(item, expr, index))
  }
  projections
}

///|
fn build_bound_select_item(
  item : @sql.SelectItem,
  expr : PlanExpr,
  index : Int,
) -> PlanSelectItem {
  let output_name = match item.output_name {
    Some(name) => name
    None => default_output_name_from_sql_expr(item.expr, expr, index)
  }
  PlanSelectItem::{ expr, output_name }
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
  context : ColumnBindContext,
) -> PlanExpr raise PlanError {
  match expr {
    @sql.Expr::ColumnRef(path) =>
      PlanExpr::ColumnRef(resolve_column(path, context))
    @sql.Expr::StringLiteral(text) => PlanExpr::StringLiteral(text)
    @sql.Expr::IntegerLiteral(text) => PlanExpr::IntegerLiteral(text)
    @sql.Expr::DoubleLiteral(text) => PlanExpr::DoubleLiteral(text)
    @sql.Expr::BooleanLiteral(value) => PlanExpr::BooleanLiteral(value)
    @sql.Expr::NullLiteral => PlanExpr::NullLiteral
    @sql.Expr::FunctionCall(name, _) =>
      raise unsupported_or_nested_function(name, false)
    @sql.Expr::FunctionCallStar(name) =>
      raise unsupported_or_nested_function(name, false)
    @sql.Expr::Unary(op, inner) => bind_unary_expr(op, inner, context)
    @sql.Expr::Binary(op, left, right) =>
      bind_binary_expr(op, left, right, context)
    @sql.Expr::IsNull(inner) =>
      PlanExpr::IsNull(bind_scalar_expr(inner, context))
    @sql.Expr::IsNotNull(inner) =>
      PlanExpr::IsNotNull(bind_scalar_expr(inner, context))
    @sql.Expr::Cast(inner, type_name) =>
      PlanExpr::Cast(
        bind_scalar_expr(inner, context),
        type_name_to_logical_type(type_name),
      )
  }
}

///|
fn bind_scalar_expr_disallow_aggregate(
  expr : @sql.Expr,
  context : ColumnBindContext,
) -> PlanExpr raise PlanError {
  match expr {
    @sql.Expr::FunctionCall(name, _) =>
      raise unsupported_or_nested_function(name, true)
    @sql.Expr::FunctionCallStar(name) =>
      raise unsupported_or_nested_function(name, true)
    _ => bind_scalar_expr(expr, context)
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
  let bound_ref = resolve_column(path, context.input_context)
  let path_name = path.join(".")
  for index in 0..<context.group_keys.length() {
    if context.group_keys[index] == bound_ref {
      return PlanExpr::ColumnRef(BoundColumnRef::{
        index,
        column: context.group_keys[index].column,
      })
    }
  }
  raise PlanError::Bind(
    "column must appear in GROUP BY or be used in an aggregate function: \{path_name}",
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
      context.input_context,
    )
    return register_aggregate(kind, Some(input_expr), context)
  }
  guard args.length() == 1 else {
    raise PlanError::Bind("\{normalized} requires exactly one argument")
  }
  let input_expr = bind_scalar_expr_disallow_aggregate(
    args[0],
    context.input_context,
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
  context : ColumnBindContext,
) -> PlanExpr raise PlanError {
  let bound_inner = bind_scalar_expr(inner, context)
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
  context : ColumnBindContext,
) -> PlanExpr raise PlanError {
  let bound_left = bind_scalar_expr(left, context)
  let bound_right = bind_scalar_expr(right, context)
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
fn infer_binary_expr_type(
  op : @sql.BinaryOp,
  left : PlanExpr,
  right : PlanExpr,
) -> @engine.LogicalType raise PlanError {
  match op {
    @sql.BinaryOp::Divide => {
      ignore(infer_numeric_type(left))
      ignore(infer_numeric_type(right))
      @engine.LogicalType::Double
    }
    @sql.BinaryOp::Add | @sql.BinaryOp::Subtract | @sql.BinaryOp::Multiply =>
      infer_binary_numeric_type(left, right)
    _ => @engine.LogicalType::Boolean
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
  context : ColumnBindContext,
) -> BoundColumnRef raise PlanError {
  guard path.length() > 0 else {
    raise PlanError::Bind("empty column reference")
  }
  if path.length() == 1 {
    let name = path[0]
    let matches = []
    for relation in context.relations {
      match relation.schema.column_index(name) {
        Some(index) =>
          matches.push(BoundColumnRef::{
            index: relation.output_offset + index,
            column: relation.schema.columns[index],
          })
        None => ()
      }
    }
    match matches.length() {
      0 => raise PlanError::Bind("unknown column: \{name}")
      1 => matches[0]
      _ =>
        raise PlanError::Bind(
          "ambiguous column reference requires qualification: \{name}",
        )
    }
  } else if path.length() == 2 {
    let relation_name = path[0]
    let column_name = path[1]
    let matches = []
    for relation in context.relations {
      let qualified_name = match relation.alias_name {
        Some(alias_name) => alias_name
        None => relation.relation_name
      }
      if relation_name == qualified_name {
        match relation.schema.column_index(column_name) {
          Some(index) =>
            matches.push(BoundColumnRef::{
              index: relation.output_offset + index,
              column: relation.schema.columns[index],
            })
          None => ()
        }
      }
    }
    match matches.length() {
      0 =>
        raise PlanError::Bind(
          "unknown qualified column: \{relation_name}.\{column_name}",
        )
      1 => matches[0]
      _ =>
        raise PlanError::Bind(
          "ambiguous qualified column: \{relation_name}.\{column_name}",
        )
    }
  } else {
    raise PlanError::Bind("column references support at most one qualifier")
  }
}

///|
fn bind_join_predicate(
  expr : @sql.Expr,
  context : ColumnBindContext,
) -> (JoinColumnRef, JoinColumnRef) raise PlanError {
  guard context.relations.length() == 2 else {
    raise PlanError::Bind("join binding requires exactly two relations")
  }
  let (left_expr, right_expr) = match expr {
    @sql.Expr::Binary(@sql.BinaryOp::Equal, left, right) => (left, right)
    _ =>
      raise PlanError::Bind(
        "JOIN ON only supports equality between one left column and one right column",
      )
  }
  let left_ref = bind_join_key_expr(left_expr, context)
  let right_ref = bind_join_key_expr(right_expr, context)
  if left_ref.relation_index == right_ref.relation_index {
    raise PlanError::Bind(
      "JOIN ON must compare one left column with one right column",
    )
  }
  let ordered = if left_ref.relation_index == 0 && right_ref.relation_index == 1 {
    (left_ref, right_ref)
  } else if left_ref.relation_index == 1 && right_ref.relation_index == 0 {
    (right_ref, left_ref)
  } else {
    raise PlanError::Bind(
      "JOIN ON must compare one left column with one right column",
    )
  }
  validate_join_key_types(
    ordered.0.local_ref.column,
    ordered.1.local_ref.column,
  )
  ordered
}

///|
fn bind_join_key_expr(
  expr : @sql.Expr,
  context : ColumnBindContext,
) -> JoinColumnRef raise PlanError {
  let path = match expr {
    @sql.Expr::ColumnRef(path) => path
    _ =>
      raise PlanError::Bind(
        "JOIN ON only supports column references on both sides",
      )
  }
  let bound_ref = resolve_column(path, context)
  for relation_index in 0..<context.relations.length() {
    let relation = context.relations[relation_index]
    let start = relation.output_offset
    let end = start + relation.schema.columns.length()
    if bound_ref.index >= start && bound_ref.index < end {
      return JoinColumnRef::{
        relation_index,
        local_ref: BoundColumnRef::{
          index: bound_ref.index - start,
          column: bound_ref.column,
        },
      }
    }
  }
  raise PlanError::Bind("failed to map join key to an input relation")
}

///|
fn validate_join_key_types(
  left : @engine.ColumnDef,
  right : @engine.ColumnDef,
) -> Unit raise PlanError {
  if left.data_type == right.data_type {
    ()
  } else {
    match (left.data_type, right.data_type) {
      (@engine.LogicalType::BigInt, @engine.LogicalType::Double)
      | (@engine.LogicalType::Double, @engine.LogicalType::BigInt) => ()
      _ =>
        raise PlanError::Bind(
          "JOIN keys must have matching types or numeric BIGINT/DOUBLE coercion",
        )
    }
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
        | @sql.BinaryOp::Divide => infer_binary_expr_type(op, left, right)
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
  let (kind, message) = plan_error_parts_from_scan(err)
  map_plan_error(kind, message)
}

///|
fn plan_error_parts_from_scan(err : @scan.ScanError) -> (PlanErrorKind, String) {
  match err {
    @scan.ScanError::Io(message) => (PlanErrorKind::Io, message)
    @scan.ScanError::CsvMalformed(message) => (PlanErrorKind::Scan, message)
    @scan.ScanError::JsonParse(line_no, message) =>
      (PlanErrorKind::Scan, "json parse error at line \{line_no}: \{message}")
    @scan.ScanError::JsonRootNotObject(line_no) =>
      (PlanErrorKind::Scan, "expected JSON object at line \{line_no}")
    @scan.ScanError::TypeMismatch(column, line_no, message) =>
      (
        PlanErrorKind::Scan,
        "type mismatch for column \{column} at line \{line_no}: \{message}",
      )
  }
}

///|
fn map_plan_error(kind : PlanErrorKind, message : String) -> PlanError {
  match kind {
    PlanErrorKind::Scan => PlanError::Scan(message)
    PlanErrorKind::Io => PlanError::Io(message)
  }
}

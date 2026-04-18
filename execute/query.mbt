///|
pub struct QueryOutput {
  schema : @engine.Schema
  chunks : Array[@engine.DataChunk]
} derive(Eq, Debug)

///|
pub suberror ExecuteError {
  InvalidArgument(String)
  Bind(String)
  Scan(String)
  Io(String)
  Execute(String)
  Unsupported(String)
  Internal(String)
} derive(Debug)

///|
pub async fn execute_query(
  query : @sql.Query,
) -> QueryOutput raise ExecuteError {
  let plan = @plan.plan_query(query) catch { err => raise map_plan_error(err) }
  execute_plan(plan)
}

///|
pub async fn execute_plan(
  plan : @plan.QueryPlan,
) -> QueryOutput raise ExecuteError {
  let chunks = execute_plan_chunks(plan)
  QueryOutput::{ schema: @plan.query_plan_schema(plan), chunks }
}

///|
async fn execute_plan_chunks(
  plan : @plan.QueryPlan,
) -> Array[@engine.DataChunk] raise ExecuteError {
  collect_operator_chunks(build_operator(plan))
}

///|
async fn build_operator(
  plan : @plan.QueryPlan,
) -> ChunkOperator raise ExecuteError {
  match plan {
    @plan.QueryPlan::Scan(scan_plan) => build_scan_operator(scan_plan.source)
    @plan.QueryPlan::Join(join_plan) => build_join_operator(join_plan)
    @plan.QueryPlan::Filter(filter_plan) =>
      ChunkOperator::Filter(FilterOperator::{
        input: build_operator(filter_plan.input),
        predicate: filter_plan.predicate,
      })
    @plan.QueryPlan::Aggregate(aggregate_plan) =>
      build_aggregate_operator(aggregate_plan)
    @plan.QueryPlan::Projection(projection_plan) =>
      ChunkOperator::Projection(ProjectionOperator::{
        input: build_operator(projection_plan.input),
        projections: projection_plan.projections,
        output_schema: projection_plan.output_schema,
      })
    @plan.QueryPlan::Sort(sort_plan) => build_sort_operator(sort_plan)
    @plan.QueryPlan::Limit(limit_plan) =>
      ChunkOperator::Limit(LimitOperator::{
        input: build_operator(limit_plan.input),
        remaining: limit_plan.limit,
      })
  }
}

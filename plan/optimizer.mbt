///|
priv struct OptimizerOptions {
  enable_filter_pushdown : Bool
  enable_projection_pruning : Bool
}

///|
fn default_optimizer_options() -> OptimizerOptions {
  OptimizerOptions::{
    enable_filter_pushdown: true,
    enable_projection_pruning: true,
  }
}

///|
fn optimize_query_plan(plan : QueryPlan) -> QueryPlan {
  optimize_query_plan_with_options(plan, default_optimizer_options())
}

///|
fn optimize_query_plan_with_options(
  plan : QueryPlan,
  options : OptimizerOptions,
) -> QueryPlan {
  let with_filter_pushdown = if options.enable_filter_pushdown {
    apply_filter_pushdown(plan)
  } else {
    plan
  }
  if options.enable_projection_pruning {
    apply_projection_pruning(with_filter_pushdown)
  } else {
    with_filter_pushdown
  }
}

///|
fn apply_filter_pushdown(plan : QueryPlan) -> QueryPlan {
  plan
}

///|
fn apply_projection_pruning(plan : QueryPlan) -> QueryPlan {
  plan
}

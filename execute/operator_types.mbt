///|
priv struct ScanOperator {
  scanner : @scan.Scanner
}

///|
priv struct FilterOperator {
  input : ChunkOperator
  predicate : @plan.PlanExpr
}

///|
priv struct ProjectionOperator {
  input : ChunkOperator
  projections : Array[@plan.PlanSelectItem]
  output_schema : @engine.Schema
}

///|
priv struct AggregateOperator {
  input : ChunkOperator
  aggregate_plan : @plan.AggregatePlan
  mut build_ready : Bool
  mut output_chunks : Array[@engine.DataChunk]
  mut next_index : Int
}

///|
priv struct SortOperator {
  input : ChunkOperator
  sort_plan : @plan.SortPlan
  mut build_ready : Bool
  mut output_chunks : Array[@engine.DataChunk]
  mut next_index : Int
}

///|
priv struct JoinOperator {
  left : ChunkOperator
  right : ChunkOperator
  join_plan : @plan.JoinPlan
  mut build_ready : Bool
  right_rows : Array[Array[@engine.Value]]
  right_indices : Map[String, Array[Int]]
  mut left_chunk : @engine.DataChunk?
  mut left_row_index : Int
  mut pending_left_row : Array[@engine.Value]?
  mut pending_match_indices : Array[Int]
  mut pending_match_index : Int
}

///|
priv struct LimitOperator {
  input : ChunkOperator
  mut remaining : Int
}

///|
priv enum ChunkOperator {
  Scan(ScanOperator)
  Filter(FilterOperator)
  Projection(ProjectionOperator)
  Aggregate(AggregateOperator)
  Sort(SortOperator)
  Join(JoinOperator)
  Limit(LimitOperator)
}

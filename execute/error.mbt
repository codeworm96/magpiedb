///|
priv enum ExecuteErrorKind {
  InvalidArgument
  Bind
  Scan
  Io
  Unsupported
}

///|
fn map_scan_error(err : @scan.ScanError) -> ExecuteError {
  let kind = match err {
    @scan.ScanError::Io(_) => ExecuteErrorKind::Io
    _ => ExecuteErrorKind::Scan
  }
  map_execute_error(kind, err.message())
}

///|
fn map_plan_error(err : @plan.PlanError) -> ExecuteError {
  let (kind, message) = execute_error_parts_from_plan(err)
  map_execute_error(kind, message)
}

///|
fn execute_error_parts_from_plan(
  err : @plan.PlanError,
) -> (ExecuteErrorKind, String) {
  match err {
    @plan.PlanError::InvalidArgument(message) =>
      (ExecuteErrorKind::InvalidArgument, message)
    @plan.PlanError::Bind(message) => (ExecuteErrorKind::Bind, message)
    @plan.PlanError::Scan(message) => (ExecuteErrorKind::Scan, message)
    @plan.PlanError::Io(message) => (ExecuteErrorKind::Io, message)
    @plan.PlanError::Unsupported(message) =>
      (ExecuteErrorKind::Unsupported, message)
  }
}

///|
fn map_execute_error(kind : ExecuteErrorKind, message : String) -> ExecuteError {
  match kind {
    ExecuteErrorKind::InvalidArgument => ExecuteError::InvalidArgument(message)
    ExecuteErrorKind::Bind => ExecuteError::Bind(message)
    ExecuteErrorKind::Scan => ExecuteError::Scan(message)
    ExecuteErrorKind::Io => ExecuteError::Io(message)
    ExecuteErrorKind::Unsupported => ExecuteError::Unsupported(message)
  }
}

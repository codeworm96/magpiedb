///|
pub struct Database {} derive(Eq, Debug)

///|
pub struct Connection {} derive(Eq, Debug)

///|
pub struct ResultSet {
  schema : Schema
  priv rows : Array[Row]
  priv mut next_row : Int
} derive(Eq, Debug)

///|
priv enum DbErrorKind {
  InvalidArgument
  Bind
  Scan
  Io
  Execute
  Unsupported
}

///|
pub fn Database::new() -> Database {
  Database::{  }
}

///|
pub fn Database::connect(self : Database) -> Connection {
  ignore(self)
  Connection::{  }
}

///|
pub fn Connection::query(
  self : Connection,
  sql : String,
) -> Result[ResultSet, DbError] {
  ignore(self)
  let parsed = @sql.parse_sql(sql)
  match parsed {
    Ok(query) =>
      try {
        let plan = @plan.plan_query(query) catch {
          err => return Err(map_plan_error(err))
        }
        Ok(make_result_set(@execute.execute_plan(plan)))
      } catch {
        err => Err(map_execute_error(err))
      }
    Err(err) => Err(DbError::SqlSyntax(err.to_string()))
  }
}

///|
pub fn ResultSet::schema(self : ResultSet) -> Schema {
  self.schema
}

///|
pub fn ResultSet::next(self : ResultSet) -> Row? {
  guard self.next_row < self.rows.length() else { return None }
  let row = self.rows[self.next_row]
  self.next_row += 1
  Some(row)
}

///|
fn make_result_set(output : @execute.QueryOutput) -> ResultSet {
  ResultSet::{
    schema: output.schema,
    rows: @engine.chunks_to_rows(output.chunks),
    next_row: 0,
  }
}

///|
fn map_execute_error(err : @execute.ExecuteError) -> DbError {
  let (kind, message) = match err {
    @execute.ExecuteError::InvalidArgument(message) =>
      (DbErrorKind::InvalidArgument, message)
    @execute.ExecuteError::Bind(message) => (DbErrorKind::Bind, message)
    @execute.ExecuteError::Scan(message) => (DbErrorKind::Scan, message)
    @execute.ExecuteError::Io(message) => (DbErrorKind::Io, message)
    @execute.ExecuteError::Execute(message) => (DbErrorKind::Execute, message)
    @execute.ExecuteError::Unsupported(message) =>
      (DbErrorKind::Unsupported, message)
  }
  map_db_error(kind, message)
}

///|
fn map_plan_error(err : @plan.PlanError) -> DbError {
  let (kind, message) = match err {
    @plan.PlanError::InvalidArgument(message) =>
      (DbErrorKind::InvalidArgument, message)
    @plan.PlanError::Bind(message) => (DbErrorKind::Bind, message)
    @plan.PlanError::Scan(message) => (DbErrorKind::Scan, message)
    @plan.PlanError::Io(message) => (DbErrorKind::Io, message)
    @plan.PlanError::Unsupported(message) => (DbErrorKind::Unsupported, message)
  }
  map_db_error(kind, message)
}

///|
fn map_db_error(kind : DbErrorKind, message : String) -> DbError {
  match kind {
    DbErrorKind::InvalidArgument => DbError::InvalidArgument(message)
    DbErrorKind::Bind => DbError::Bind(message)
    DbErrorKind::Scan => DbError::Scan(message)
    DbErrorKind::Io => DbError::Io(message)
    DbErrorKind::Execute => DbError::Execute(message)
    DbErrorKind::Unsupported => DbError::Unsupported(message)
  }
}

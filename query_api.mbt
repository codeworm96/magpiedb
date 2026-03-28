///|
pub struct Database {} derive(Eq, Show)

///|
pub struct Connection {} derive(Eq, Show)

///|
pub struct ResultSet {
  schema : Schema
  priv rows : Array[Row]
  priv mut next_row : Int
} derive(Eq, Show)

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
        let plan = @execute.plan_query(query)
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
  ResultSet::{ schema: output.schema, rows: output.rows, next_row: 0 }
}

///|
fn map_execute_error(err : @execute.ExecuteError) -> DbError {
  match err {
    @execute.ExecuteError::InvalidArgument(message) =>
      DbError::InvalidArgument(message)
    @execute.ExecuteError::Bind(message) => DbError::Bind(message)
    @execute.ExecuteError::Scan(message) => DbError::Scan(message)
    @execute.ExecuteError::Io(message) => DbError::Io(message)
    @execute.ExecuteError::Execute(message) => DbError::Execute(message)
    @execute.ExecuteError::Unsupported(message) => DbError::Unsupported(message)
  }
}

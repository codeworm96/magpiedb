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
    rows: materialize_rows(output.chunks),
    next_row: 0,
  }
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

///|
fn map_plan_error(err : @plan.PlanError) -> DbError {
  match err {
    @plan.PlanError::InvalidArgument(message) =>
      DbError::InvalidArgument(message)
    @plan.PlanError::Bind(message) => DbError::Bind(message)
    @plan.PlanError::Scan(message) => DbError::Scan(message)
    @plan.PlanError::Io(message) => DbError::Io(message)
    @plan.PlanError::Unsupported(message) => DbError::Unsupported(message)
  }
}

///|
fn materialize_rows(chunks : Array[@engine.DataChunk]) -> Array[Row] {
  let rows = []
  for chunk in chunks {
    for row_index in 0..<chunk.len {
      let row = []
      for column in chunk.columns {
        row.push(vector_value_at(column, row_index))
      }
      rows.push(row)
    }
  }
  rows
}

///|
fn vector_value_at(vector : @engine.Vector, row_index : Int) -> Value {
  let is_valid = match vector.validity.is_valid(row_index) {
    Some(value) => value
    None => false
  }
  guard is_valid else { return Value::Null }
  match vector.values {
    @engine.VectorBuffer::Nulls(_) => Value::Null
    @engine.VectorBuffer::Bool(values) => Value::Boolean(values[row_index])
    @engine.VectorBuffer::Int64(values) => Value::BigInt(values[row_index])
    @engine.VectorBuffer::Double(values) => Value::Double(values[row_index])
    @engine.VectorBuffer::Varchar(values) => Value::Varchar(values[row_index])
  }
}

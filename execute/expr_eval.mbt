///|
fn filter_chunk(
  chunk : @engine.DataChunk,
  predicate : @plan.PlanExpr,
) -> @engine.DataChunk raise ExecuteError {
  let predicate_vector = eval_expr_to_vector(predicate, chunk)
  let selected_indices = []
  for row_index in 0..<chunk.len {
    match vector_value_at(predicate_vector, row_index) {
      @engine.Value::Boolean(true) => selected_indices.push(row_index)
      @engine.Value::Boolean(false) | @engine.Value::Null => ()
      _ =>
        raise ExecuteError::Execute(
          "filter predicate did not evaluate to BOOLEAN",
        )
    }
  }
  if selected_indices.length() == 0 {
    return @engine.DataChunk::empty(chunk.schema)
  }
  let columns = []
  for column in chunk.columns {
    columns.push(take_vector(column, selected_indices))
  }
  @engine.DataChunk::{
    schema: chunk.schema,
    columns,
    len: selected_indices.length(),
  }
}

///|
fn project_chunk(
  chunk : @engine.DataChunk,
  projections : Array[@plan.PlanSelectItem],
  output_schema : @engine.Schema,
) -> @engine.DataChunk raise ExecuteError {
  let columns = []
  for item in projections {
    columns.push(eval_expr_to_vector(item.expr, chunk))
  }
  @engine.DataChunk::{ schema: output_schema, columns, len: chunk.len }
}

///|
fn eval_expr_to_vector(
  expr : @plan.PlanExpr,
  chunk : @engine.DataChunk,
) -> @engine.Vector raise ExecuteError {
  match expr {
    @plan.PlanExpr::ColumnRef(column_ref) => chunk.columns[column_ref.index]
    @plan.PlanExpr::StringLiteral(text) =>
      constant_vector(@engine.Value::Varchar(text), chunk.len)
    @plan.PlanExpr::IntegerLiteral(text) =>
      constant_vector(
        @engine.Value::BigInt(
          @string.parse_int64(text[:]) catch {
            _ => raise ExecuteError::Execute("invalid integer literal: \{text}")
          },
        ),
        chunk.len,
      )
    @plan.PlanExpr::DoubleLiteral(text) =>
      constant_vector(
        @engine.Value::Double(
          @string.parse_double(text[:]) catch {
            _ => raise ExecuteError::Execute("invalid double literal: \{text}")
          },
        ),
        chunk.len,
      )
    @plan.PlanExpr::BooleanLiteral(value) =>
      constant_vector(@engine.Value::Boolean(value), chunk.len)
    @plan.PlanExpr::NullLiteral =>
      constant_vector(@engine.Value::Null, chunk.len)
    @plan.PlanExpr::Unary(op, inner) => {
      let inner_vector = eval_expr_to_vector(inner, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(eval_unary(op, vector_value_at(inner_vector, row_index)))
      }
      build_vector_from_values(
        infer_unary_type(op, inner_vector.logical_type),
        values,
      )
    }
    @plan.PlanExpr::Binary(op, left, right) => {
      let left_vector = eval_expr_to_vector(left, chunk)
      let right_vector = eval_expr_to_vector(right, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(
          eval_binary(
            op,
            vector_value_at(left_vector, row_index),
            vector_value_at(right_vector, row_index),
          ),
        )
      }
      build_vector_from_values(
        infer_binary_type(
          op,
          left_vector.logical_type,
          right_vector.logical_type,
        ),
        values,
      )
    }
    @plan.PlanExpr::IsNull(inner) => {
      let inner_vector = eval_expr_to_vector(inner, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(
          @engine.Value::Boolean(
            match vector_value_at(inner_vector, row_index) {
              @engine.Value::Null => true
              _ => false
            },
          ),
        )
      }
      build_vector_from_values(@engine.LogicalType::Boolean, values)
    }
    @plan.PlanExpr::IsNotNull(inner) => {
      let inner_vector = eval_expr_to_vector(inner, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(
          @engine.Value::Boolean(
            match vector_value_at(inner_vector, row_index) {
              @engine.Value::Null => false
              _ => true
            },
          ),
        )
      }
      build_vector_from_values(@engine.LogicalType::Boolean, values)
    }
    @plan.PlanExpr::Cast(inner, logical_type) => {
      let inner_vector = eval_expr_to_vector(inner, chunk)
      let values = []
      for row_index in 0..<chunk.len {
        values.push(
          cast_value(vector_value_at(inner_vector, row_index), logical_type),
        )
      }
      build_vector_from_values(logical_type, values)
    }
  }
}

///|
fn infer_unary_type(
  op : @sql.UnaryOp,
  inner_type : @engine.LogicalType,
) -> @engine.LogicalType {
  match op {
    @sql.UnaryOp::Not => @engine.LogicalType::Boolean
    @sql.UnaryOp::Plus | @sql.UnaryOp::Minus => inner_type
  }
}

///|
fn infer_binary_type(
  op : @sql.BinaryOp,
  left_type : @engine.LogicalType,
  right_type : @engine.LogicalType,
) -> @engine.LogicalType {
  match op {
    @sql.BinaryOp::And | @sql.BinaryOp::Or => @engine.LogicalType::Boolean
    @sql.BinaryOp::Divide => @engine.LogicalType::Double
    @sql.BinaryOp::Add | @sql.BinaryOp::Subtract | @sql.BinaryOp::Multiply =>
      match (left_type, right_type) {
        (@engine.LogicalType::Double, _) => @engine.LogicalType::Double
        (_, @engine.LogicalType::Double) => @engine.LogicalType::Double
        (@engine.LogicalType::Null, other) => other
        (other, @engine.LogicalType::Null) => other
        _ => @engine.LogicalType::BigInt
      }
    _ => @engine.LogicalType::Boolean
  }
}

///|
fn constant_vector(value : @engine.Value, len : Int) -> @engine.Vector {
  match value {
    @engine.Value::Null =>
      @engine.Vector::{
        logical_type: @engine.LogicalType::Null,
        values: @engine.VectorBuffer::Nulls(len),
        validity: @engine.ValidityMask::all_null(len),
      }
    @engine.Value::Boolean(value) => {
      let values = []
      for _ in 0..<len {
        values.push(value)
      }
      @engine.Vector::{
        logical_type: @engine.LogicalType::Boolean,
        values: @engine.VectorBuffer::Bool(values),
        validity: @engine.ValidityMask::all_valid(len),
      }
    }
    @engine.Value::BigInt(value) => {
      let values = []
      for _ in 0..<len {
        values.push(value)
      }
      @engine.Vector::{
        logical_type: @engine.LogicalType::BigInt,
        values: @engine.VectorBuffer::Int64(values),
        validity: @engine.ValidityMask::all_valid(len),
      }
    }
    @engine.Value::Double(value) => {
      let values = []
      for _ in 0..<len {
        values.push(value)
      }
      @engine.Vector::{
        logical_type: @engine.LogicalType::Double,
        values: @engine.VectorBuffer::Double(values),
        validity: @engine.ValidityMask::all_valid(len),
      }
    }
    @engine.Value::Varchar(value) => {
      let values = []
      for _ in 0..<len {
        values.push(value)
      }
      @engine.Vector::{
        logical_type: @engine.LogicalType::Varchar,
        values: @engine.VectorBuffer::Varchar(values),
        validity: @engine.ValidityMask::all_valid(len),
      }
    }
  }
}

///|
fn eval_expr_scalar(
  expr : @plan.PlanExpr,
  row : Array[@engine.Value],
) -> @engine.Value raise ExecuteError {
  match expr {
    @plan.PlanExpr::ColumnRef(column_ref) => row[column_ref.index]
    @plan.PlanExpr::StringLiteral(text) => @engine.Value::Varchar(text)
    @plan.PlanExpr::IntegerLiteral(text) =>
      @engine.Value::BigInt(
        @string.parse_int64(text[:]) catch {
          _ => raise ExecuteError::Execute("invalid integer literal: \{text}")
        },
      )
    @plan.PlanExpr::DoubleLiteral(text) =>
      @engine.Value::Double(
        @string.parse_double(text[:]) catch {
          _ => raise ExecuteError::Execute("invalid double literal: \{text}")
        },
      )
    @plan.PlanExpr::BooleanLiteral(value) => @engine.Value::Boolean(value)
    @plan.PlanExpr::NullLiteral => @engine.Value::Null
    @plan.PlanExpr::Unary(op, inner) =>
      eval_unary(op, eval_expr_scalar(inner, row))
    @plan.PlanExpr::Binary(op, left, right) =>
      eval_binary(op, eval_expr_scalar(left, row), eval_expr_scalar(right, row))
    @plan.PlanExpr::IsNull(inner) =>
      @engine.Value::Boolean(
        match eval_expr_scalar(inner, row) {
          @engine.Value::Null => true
          _ => false
        },
      )
    @plan.PlanExpr::IsNotNull(inner) =>
      @engine.Value::Boolean(
        match eval_expr_scalar(inner, row) {
          @engine.Value::Null => false
          _ => true
        },
      )
    @plan.PlanExpr::Cast(inner, logical_type) =>
      cast_value(eval_expr_scalar(inner, row), logical_type)
  }
}

///|
fn compare_values(
  left : @engine.Value,
  right : @engine.Value,
) -> Int raise ExecuteError {
  match (left, right) {
    (@engine.Value::Boolean(l), @engine.Value::Boolean(r)) =>
      if l == r {
        0
      } else if !l && r {
        -1
      } else {
        1
      }
    (@engine.Value::BigInt(l), @engine.Value::BigInt(r)) =>
      if l < r {
        -1
      } else if l > r {
        1
      } else {
        0
      }
    (@engine.Value::Double(l), @engine.Value::Double(r)) =>
      if l < r {
        -1
      } else if l > r {
        1
      } else {
        0
      }
    (@engine.Value::Varchar(l), @engine.Value::Varchar(r)) =>
      l.lexical_compare(r)
    _ => raise ExecuteError::Execute("invalid aggregate comparison")
  }
}

///|
fn eval_unary(
  op : @sql.UnaryOp,
  value : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Null => @engine.Value::Null
    _ =>
      match (op, value) {
        (@sql.UnaryOp::Plus, @engine.Value::BigInt(v)) =>
          @engine.Value::BigInt(v)
        (@sql.UnaryOp::Plus, @engine.Value::Double(v)) =>
          @engine.Value::Double(v)
        (@sql.UnaryOp::Minus, @engine.Value::BigInt(v)) =>
          @engine.Value::BigInt(-v)
        (@sql.UnaryOp::Minus, @engine.Value::Double(v)) =>
          @engine.Value::Double(-v)
        (@sql.UnaryOp::Not, @engine.Value::Boolean(v)) =>
          @engine.Value::Boolean(!v)
        _ => raise ExecuteError::Execute("invalid unary expression")
      }
  }
}

///|
fn eval_binary(
  op : @sql.BinaryOp,
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match op {
    @sql.BinaryOp::And | @sql.BinaryOp::Or =>
      eval_boolean_binary(op, left, right)
    @sql.BinaryOp::Add
    | @sql.BinaryOp::Subtract
    | @sql.BinaryOp::Multiply
    | @sql.BinaryOp::Divide => eval_numeric_binary(op, left, right)
    _ => eval_comparison(op, left, right)
  }
}

///|
fn eval_boolean_binary(
  op : @sql.BinaryOp,
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match op {
    @sql.BinaryOp::And => eval_boolean_and(left, right)
    @sql.BinaryOp::Or => eval_boolean_or(left, right)
    _ => raise ExecuteError::Execute("invalid boolean operator")
  }
}

///|
fn eval_boolean_and(
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Boolean(false), _) | (_, @engine.Value::Boolean(false)) =>
      @engine.Value::Boolean(false)
    (@engine.Value::Boolean(true), @engine.Value::Boolean(true)) =>
      @engine.Value::Boolean(true)
    (@engine.Value::Boolean(true), @engine.Value::Null)
    | (@engine.Value::Null, @engine.Value::Boolean(true))
    | (@engine.Value::Null, @engine.Value::Null) => @engine.Value::Null
    _ =>
      raise ExecuteError::Execute("boolean operator requires BOOLEAN operands")
  }
}

///|
fn eval_boolean_or(
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Boolean(true), _) | (_, @engine.Value::Boolean(true)) =>
      @engine.Value::Boolean(true)
    (@engine.Value::Boolean(false), @engine.Value::Boolean(false)) =>
      @engine.Value::Boolean(false)
    (@engine.Value::Boolean(false), @engine.Value::Null)
    | (@engine.Value::Null, @engine.Value::Boolean(false))
    | (@engine.Value::Null, @engine.Value::Null) => @engine.Value::Null
    _ =>
      raise ExecuteError::Execute("boolean operator requires BOOLEAN operands")
  }
}

///|
fn eval_numeric_binary(
  op : @sql.BinaryOp,
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Null, _) => @engine.Value::Null
    (_, @engine.Value::Null) => @engine.Value::Null
    (@engine.Value::BigInt(l), @engine.Value::BigInt(r)) =>
      match op {
        @sql.BinaryOp::Add => @engine.Value::BigInt(l + r)
        @sql.BinaryOp::Subtract => @engine.Value::BigInt(l - r)
        @sql.BinaryOp::Multiply => @engine.Value::BigInt(l * r)
        @sql.BinaryOp::Divide =>
          @engine.Value::Double(l.to_double() / r.to_double())
        _ => raise ExecuteError::Execute("invalid numeric operator")
      }
    _ => {
      let l = value_to_double(left)
      let r = value_to_double(right)
      @engine.Value::Double(
        match op {
          @sql.BinaryOp::Add => l + r
          @sql.BinaryOp::Subtract => l - r
          @sql.BinaryOp::Multiply => l * r
          @sql.BinaryOp::Divide => l / r
          _ => raise ExecuteError::Execute("invalid numeric operator")
        },
      )
    }
  }
}

///|
fn eval_comparison(
  op : @sql.BinaryOp,
  left : @engine.Value,
  right : @engine.Value,
) -> @engine.Value raise ExecuteError {
  match (left, right) {
    (@engine.Value::Null, _) => @engine.Value::Null
    (_, @engine.Value::Null) => @engine.Value::Null
    (@engine.Value::Boolean(l), @engine.Value::Boolean(r)) =>
      match op {
        @sql.BinaryOp::Equal => @engine.Value::Boolean(l == r)
        @sql.BinaryOp::NotEqual => @engine.Value::Boolean(l != r)
        _ => raise ExecuteError::Execute("invalid BOOLEAN comparison")
      }
    (@engine.Value::Varchar(l), @engine.Value::Varchar(r)) =>
      @engine.Value::Boolean(compare_int(op, l.lexical_compare(r)))
    _ => {
      let l = value_to_double(left)
      let r = value_to_double(right)
      @engine.Value::Boolean(compare_double(op, l, r))
    }
  }
}

///|
fn compare_int(op : @sql.BinaryOp, ordering : Int) -> Bool raise ExecuteError {
  match op {
    @sql.BinaryOp::Equal => ordering == 0
    @sql.BinaryOp::NotEqual => ordering != 0
    @sql.BinaryOp::LessThan => ordering < 0
    @sql.BinaryOp::LessThanOrEqual => ordering <= 0
    @sql.BinaryOp::GreaterThan => ordering > 0
    @sql.BinaryOp::GreaterThanOrEqual => ordering >= 0
    _ => raise ExecuteError::Execute("invalid comparison operator")
  }
}

///|
fn compare_double(
  op : @sql.BinaryOp,
  left : Double,
  right : Double,
) -> Bool raise ExecuteError {
  match op {
    @sql.BinaryOp::Equal => left == right
    @sql.BinaryOp::NotEqual => left != right
    @sql.BinaryOp::LessThan => left < right
    @sql.BinaryOp::LessThanOrEqual => left <= right
    @sql.BinaryOp::GreaterThan => left > right
    @sql.BinaryOp::GreaterThanOrEqual => left >= right
    _ => raise ExecuteError::Execute("invalid comparison operator")
  }
}

///|
fn value_to_double(value : @engine.Value) -> Double raise ExecuteError {
  match value {
    @engine.Value::BigInt(v) => v.to_double()
    @engine.Value::Double(v) => v
    _ =>
      raise ExecuteError::Execute(
        "numeric operator requires BIGINT or DOUBLE operands",
      )
  }
}

///|
fn cast_value(
  value : @engine.Value,
  target_type : @engine.LogicalType,
) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Null => @engine.Value::Null
    _ =>
      match target_type {
        @engine.LogicalType::Null => @engine.Value::Null
        @engine.LogicalType::Boolean => cast_to_boolean(value)
        @engine.LogicalType::BigInt => cast_to_bigint(value)
        @engine.LogicalType::Double => cast_to_double(value)
        @engine.LogicalType::Varchar =>
          @engine.Value::Varchar(value.to_string())
      }
  }
}

///|
fn cast_to_boolean(value : @engine.Value) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Boolean(v) => @engine.Value::Boolean(v)
    @engine.Value::BigInt(v) => @engine.Value::Boolean(v != 0L)
    @engine.Value::Double(v) => @engine.Value::Boolean(v != 0.0)
    @engine.Value::Varchar(text) =>
      match text {
        "true" | "TRUE" => @engine.Value::Boolean(true)
        "false" | "FALSE" => @engine.Value::Boolean(false)
        _ => raise ExecuteError::Execute("cannot cast VARCHAR to BOOLEAN")
      }
    @engine.Value::Null => @engine.Value::Null
  }
}

///|
fn cast_to_bigint(value : @engine.Value) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Boolean(v) => @engine.Value::BigInt(if v { 1L } else { 0L })
    @engine.Value::BigInt(v) => @engine.Value::BigInt(v)
    @engine.Value::Double(v) => @engine.Value::BigInt(v.to_int64())
    @engine.Value::Varchar(text) =>
      @engine.Value::BigInt(
        @string.parse_int64(text[:]) catch {
          _ => raise ExecuteError::Execute("cannot cast VARCHAR to BIGINT")
        },
      )
    @engine.Value::Null => @engine.Value::Null
  }
}

///|
fn cast_to_double(value : @engine.Value) -> @engine.Value raise ExecuteError {
  match value {
    @engine.Value::Boolean(v) =>
      @engine.Value::Double(if v { 1.0 } else { 0.0 })
    @engine.Value::BigInt(v) => @engine.Value::Double(v.to_double())
    @engine.Value::Double(v) => @engine.Value::Double(v)
    @engine.Value::Varchar(text) =>
      @engine.Value::Double(
        @string.parse_double(text[:]) catch {
          _ => raise ExecuteError::Execute("cannot cast VARCHAR to DOUBLE")
        },
      )
    @engine.Value::Null => @engine.Value::Null
  }
}

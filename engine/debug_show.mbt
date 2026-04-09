///|
fn[T : Debug] write_debug(logger : &Logger, value : T) -> Unit {
  logger.write_string("\{value.to_repr()}")
}

///|
pub impl Show for LogicalType with output(self, logger) {
  write_debug(logger, self)
}

///|
pub impl Show for ColumnDef with output(self, logger) {
  write_debug(logger, self)
}

///|
pub impl Show for Value with output(self, logger) {
  write_debug(logger, self)
}

///|
pub impl Show for ValidityMask with output(self, logger) {
  write_debug(logger, self)
}

///|
pub impl Show for VectorBuffer with output(self, logger) {
  write_debug(logger, self)
}

///|
pub impl Show for DataChunk with output(self, logger) {
  write_debug(logger, self)
}

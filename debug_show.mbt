///|
pub impl Show for DbError with output(self, logger) {
  logger.write_string("\{self.to_repr()}")
}

///|
pub impl Show for Expr with output(self, logger) {
  logger.write_string("\{self.to_repr()}")
}

///|
pub impl Show for SqlSyntaxError with output(self, logger) {
  match self {
    Lex(err) => logger.write_string("Lex(\{err.to_repr()})")
    Parse(err) => logger.write_string("Parse(\{err.to_string()})")
  }
}

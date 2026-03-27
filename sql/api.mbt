///|
pub fn parse_sql(sql : String) -> Result[Query, SqlSyntaxError] {
  let tokens = tokenize(sql) catch { err => return Err(Lex(err)) }
  let parsed = query(tokens, initial_pos=0) catch {
    err => return Err(Parse(err))
  }
  Ok(parsed)
}

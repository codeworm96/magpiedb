///|
/// Thin manual query runner for the current JSONL MVP.
fn main {
  let args = @env.args()
  guard args.length() >= 2 else {
    println(
      "usage: moon run cmd/main -- \"SELECT ... FROM read_jsonl('file.jsonl')\"",
    )
    return
  }

  let sql = args[1]
  let conn = @lib.Database::new().connect()
  match conn.query(sql) {
    Ok(result) => {
      println(result.schema().columns.map(col => col.name).to_string())
      while true {
        match result.next() {
          Some(row) => println(row.to_string())
          None => break
        }
      }
    }
    Err(err) => println(err.to_string())
  }
}

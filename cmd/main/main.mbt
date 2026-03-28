///|
/// Thin manual query runner and REPL for the current JSONL MVP.
async fn main {
  let args = @env.args()
  let conn = @lib.Database::new().connect()

  if args.length() >= 2 {
    run_query(conn, args[1])
    return
  }

  let prompt = @pp.Prompt::new(
    @ppsys.SystemConsolePort::new(),
    @ppsys.SystemClipboardPort::new(),
  )
  let prompt_text = @pp.FormattedString::new("M ")

  while true {
    let result = prompt.read_line_with_prompt(prompt_text)
    guard result.is_success else { break }
    if result.text == ".quit" {
      break
    }
    if result.text.trim() == "" {
      continue
    }
    run_query(conn, result.text)
  }

  prompt.dispose()
}

///|
fn run_query(conn : @lib.Connection, sql : String) -> Unit {
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

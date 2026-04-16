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
async fn run_query(conn : @lib.Connection, sql : String) -> Unit {
  match conn.query(sql) {
    Ok(result) => {
      let rows = [result.schema().columns.map(col => col.name)]
      while true {
        match result.next() {
          Some(row) => rows.push(row.map(value_to_cell))
          None => break
        }
      }
      let table = @tabular.Table::from_rows(rows)
      table.apply(@tabular.Style::modern()) |> ignore
      println(table.to_string())
    }
    Err(err) => println(err.to_string())
  }
}

///|
fn value_to_cell(value : @lib.Value) -> String {
  match value {
    @lib.Value::Null => "NULL"
    @lib.Value::Boolean(v) => v.to_string()
    @lib.Value::BigInt(v) => v.to_string()
    @lib.Value::Double(v) => v.to_string()
    @lib.Value::Varchar(v) => v
  }
}

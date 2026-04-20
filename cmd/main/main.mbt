///|
/// Thin manual query runner and REPL for the current JSONL MVP.
async fn main {
  let args = @env.args()
  let conn = @lib.Database::new().connect()

  if args.length() == 1 {
    run_repl(conn)
    return
  }

  if args.length() != 3 {
    print_usage()
    return
  }

  match args[1] {
    "-c" => run_query(conn, args[2])
    "-f" => run_sql_file(conn, args[2])
    _ => print_usage()
  }
}

///|
async fn run_repl(conn : @lib.Connection) -> Unit {
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
fn print_usage() -> Unit {
  println("Usage: magpiedb")
  println("       magpiedb -c \"SQL\"")
  println("       magpiedb -f FILE")
}

///|
async fn run_sql_file(conn : @lib.Connection, path : String) -> Unit {
  let result = try? @fs.read_file(path).text()
  match result {
    Ok(sql) => run_query(conn, sql)
    Err(err) => println("failed to read SQL file \{path}: \{err}")
  }
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

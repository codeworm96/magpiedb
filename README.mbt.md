# magpiedb

`magpiedb` is an experimental embedded OLAP database engine written in MoonBit.

Today it runs as a native-first library and small CLI, with support for querying
CSV and JSONL files using a compact SQL subset.

## Current status

Implemented today:

- `SELECT ... FROM read_csv('...')`
- `SELECT ... FROM read_jsonl('...')`
- `SELECT ... FROM 'path.csv'` / `SELECT ... FROM 'path.jsonl'`
- `WHERE`
- aliases and scalar expressions
- aggregates: `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`
- `GROUP BY`
- `HAVING`
- `INNER JOIN`
- aggregate queries over joined inputs
- `ORDER BY`
- `LIMIT`

Not implemented yet:

- `LEFT JOIN`
- multiple joins in one query
- persistent tables / on-disk storage
- Parquet / Arrow

## Quick start

Run the CLI:

```bash
moon run cmd/main
```

Run a single query directly:

```bash
moon run cmd/main "SELECT name, age FROM read_csv('fixtures/csv/people.csv') WHERE age > 18"
```

You can also query a file path directly and let `magpiedb` infer the format from
the suffix:

```bash
moon run cmd/main "SELECT name, age FROM 'fixtures/csv/people.csv' WHERE age > 18"
```

Run tests:

```bash
moon test --target native
```

## Example queries

Simple scan:

```sql
SELECT name, age
FROM read_csv('fixtures/csv/people.csv')
WHERE age > 18
```

Simple scan with suffix-based source inference:

```sql
SELECT name, age
FROM 'fixtures/csv/people.csv'
WHERE age > 18
```

Sort and limit:

```sql
SELECT name, age
FROM read_csv('fixtures/csv/people.csv')
ORDER BY age DESC
LIMIT 2
```

Grouped aggregate:

```sql
SELECT active, COUNT(*) AS total
FROM read_jsonl('fixtures/jsonl/events.jsonl')
GROUP BY active
HAVING COUNT(*) > 1
```

Inner join:

```sql
SELECT people.name, events.active
FROM read_csv('fixtures/csv/join_people.csv') AS people
JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events
ON people.id = events.id
WHERE events.active = true
```

Aggregate over a join:

```sql
SELECT people.name, COUNT(*) AS total
FROM read_csv('fixtures/csv/join_people.csv') AS people
JOIN read_csv('fixtures/csv/join_flags.csv') AS flags
ON people.id = flags.id
GROUP BY people.name
HAVING COUNT(*) > 1
```

Aggregate over a join with sort and limit:

```sql
SELECT people.name, COUNT(*) AS total
FROM read_csv('fixtures/csv/join_people.csv') AS people
JOIN read_csv('fixtures/csv/join_flags.csv') AS flags
ON people.id = flags.id
GROUP BY people.name
ORDER BY total DESC, people.name
LIMIT 2
```

## Library usage

At the API level, usage is intentionally small:

```moonbit nocheck
import {
  "codeworm96/magpiedb" @db
}

async fn run_query() -> Result[Unit, @db.DbError] {
  let conn = @db.Database::new().connect()
  let result = conn.query(
    "SELECT COUNT(*) AS total FROM read_csv('fixtures/csv/people.csv')",
  )?

  println(result.schema().columns.length().to_string())
  while true {
    match result.next() {
      Some(row) => println(row.to_string())
      None => break
    }
  }
  Ok(())
}
```

Public entrypoints:

- `Database::new()`
- `Database::connect()`
- `Connection::query(sql)` (async)
- `ResultSet::schema()`
- `ResultSet::next()`

## Data model

Current logical types:

- `NULL`
- `BOOLEAN`
- `BIGINT`
- `DOUBLE`
- `VARCHAR`

CSV empty fields and missing JSONL keys become `NULL`.

## Development notes

- Preferred target is `native`.
- The project currently uses `moonlex` and `moonyacc` for SQL front-end generation.
- CSV input currently uses `xunyoyo/NyaCSV`.
- The roadmap lives in `PLAN.md`.

## License

Apache-2.0.

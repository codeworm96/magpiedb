# Pure-MoonBit OLAP Engine, Native-First

## Summary

- Build `magpiedb` as a pure MoonBit embedded OLAP engine.
- First usable milestone is read-only analytics over external files: `SELECT ... FROM read_csv('...')` and `SELECT ... FROM read_jsonl('...')`.
- Keep the public API small, but make the execution core columnar and vectorized from the start so later phases extend the engine instead of replacing it.
- Explicit non-goals for this phase: persisted tables, joins, subqueries, CTEs, DDL/DML, transactions, Parquet/Arrow, and file-format compatibility with other databases.

## Public API

- Expose a library-first API: `Database`, `Connection`, `ResultSet`, `Schema`, `Row`, `Value`, and `DbError`.
- Public entrypoints are `Database::new()`, `Database::connect()`, `Connection::query(sql)`, `ResultSet::schema()`, and `ResultSet::next()`.
- Keep result consumption row-oriented in the public API for simplicity, but keep internal execution chunk-oriented.
- SQL v1 supports `SELECT`, projection aliases, literals, arithmetic, comparisons, `AND`/`OR`/`NOT`, `IS NULL`, `CAST`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, and aggregates `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.
- Type system in v1 is `NULL`, `BOOLEAN`, `BIGINT`, `DOUBLE`, and `VARCHAR`.
- File access is only through built-in table functions `read_csv(path)` and `read_jsonl(path)` with a single required path argument in v1.

## Implementation Changes

- Split the module into packages for `sql`, `scan`, `engine`, and the root public API. Keep `cmd/main` as a thin manual query runner only.
- Implement the SQL front end as owned code: hand-written tokenizer plus recursive-descent/Pratt parser for the supported subset. Do not depend on `moonbitlang/parser`. Do not use `moonyacc` in v1.
- Add binder and planner stages that resolve names against exactly one scan source, check types, apply coercions, and lower to logical nodes `ScanCsv`, `ScanJsonl`, `Projection`, `Filter`, `Aggregate`, `Sort`, and `Limit`.
- Implement a physical executor over `DataChunk`s with a fixed vector size of `2048`. Every operator consumes and produces typed column vectors plus null bitmaps.
- Represent columns as typed vectors for `Bool`, `Int64`, `Double`, and `String`, with nullable wrappers handled separately through validity masks.
- Make scans two-phase in v1: infer schema first, then execute. CSV supports UTF-8, comma delimiter, quoted fields, and header row defaulting to true. JSONL supports one UTF-8 object per line.
- Convert empty CSV fields and missing JSONL keys to `NULL`. Nested JSON values are serialized to `VARCHAR` instead of introducing nested types yet.
- Add only lightweight optimization in this phase: constant folding, projection pruning, and filter pushdown into file scans.
- Do not introduce a persistent catalog. Built-in table functions are the only relation sources in v1.

## Milestones

- Milestone 1: SQL lexer/parser/AST, file scanners, schema inference, public `query()` API, and projection/filter over CSV and JSONL.
- Milestone 2: typed expression evaluation, null semantics, aggregate execution, grouped aggregation, and stable result materialization.
- Milestone 3: sort/limit, filter pushdown, projection pruning, end-to-end fixtures, and CLI demo package.
- Milestone 4: internal cleanup for the later roadmap: operator interfaces, vector APIs, and planner boundaries frozen so joins and persistent storage can be added without reworking the public API.

## Test Plan

- Parser tests for precedence, aliases, aggregates, invalid SQL, and readable diagnostics.
- Scanner tests for CSV quoting, header handling, null detection, numeric inference, JSONL missing keys, mixed numeric types, and malformed input.
- Binder/planner tests for unknown columns, invalid aggregate usage, type mismatch, cast behavior, and pushdown eligibility.
- Executor tests for projection, filters, grouped aggregates, null semantics, ordering, limits, and deterministic schema output.
- End-to-end blackbox tests over fixture CSV/JSONL files with exact schema assertions and result snapshots.
- Performance smoke tests for full-file scan, filtered aggregate, and grouped aggregate to confirm chunked execution paths are exercised.

## Assumptions

- Native execution is the only initial target.
- Input is external `.csv` and `.jsonl`; the engine does not persist output or maintain local tables in this phase.
- Columnar plus vectorized execution is a hard architectural requirement from day one, even though SQL scope is intentionally narrow at first.
- Parser-generator investigation result: `moonbitlang/parser` is unrelated; the relevant official projects are `moonlex` and `moonyacc`. `moonlex` can be evaluated later for lexer generation, but v1 should not depend on `moonyacc` because of licensing and tooling risk.

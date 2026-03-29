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
- Implement the SQL front end with `moonlex` and `moonyacc` for the milestone-1 subset, while keeping the owned AST, binder, and planner interfaces local to this repo.
- Add binder and planner stages that resolve names against exactly one scan source, check types, apply coercions, and lower to logical nodes `ScanCsv`, `ScanJsonl`, `Projection`, `Filter`, `Aggregate`, `Sort`, and `Limit`.
- Implement a physical executor over `DataChunk`s with a fixed vector size of `2048`. Every operator consumes and produces typed column vectors plus null bitmaps.
- Represent columns as typed vectors for `Bool`, `Int64`, `Double`, and `String`, with nullable wrappers handled separately through validity masks.
- Make scans two-phase in v1: infer schema first, then execute. CSV supports UTF-8, comma delimiter, quoted fields, and header row defaulting to true. JSONL supports one UTF-8 object per line.
- Build JSONL support directly on `moonbitlang/core/json` plus `moonbitlang/x/fs`.
- Treat `xunyoyo/NyaCSV` as reference material or a short-lived spike dependency only; the planned production scanner remains owned in-repo so it can support chunked OLAP ingestion and future pushdown work.
- Add an explicit licensing checkpoint around generated parser artifacts: confirm how `moonlex` and `moonyacc` license their generated output and only commit generated files if that distribution model is acceptable for this Apache-licensed repo.
- Convert empty CSV fields and missing JSONL keys to `NULL`. Nested JSON values are serialized to `VARCHAR` instead of introducing nested types yet.
- Add only lightweight optimization in this phase: constant folding, projection pruning, and filter pushdown into file scans.
- Do not introduce a persistent catalog. Built-in table functions are the only relation sources in v1.

## Milestones

- Milestone 1: SQL lexer/parser/AST, file scanners, schema inference, public `query()` API, and projection/filter over CSV and JSONL.
- Milestone 2: typed expression evaluation, null semantics, aggregate execution, grouped aggregation, and stable result materialization.
- Milestone 3: sort/limit, filter pushdown, projection pruning, end-to-end fixtures, and CLI demo package.
- Milestone 4: internal cleanup for the later roadmap: operator interfaces, vector APIs, and planner boundaries frozen so joins and persistent storage can be added without reworking the public API.

## Milestone 1 Breakdown

### Scope

- Deliver one end-to-end query path: `Connection::query(sql)` executes `SELECT ... FROM read_csv('...')` or `SELECT ... FROM read_jsonl('...')` with projection and `WHERE`.
- Support exactly one scan source per query and no joins, subqueries, grouping, sorting, or limits in this milestone.
- Keep the internal executor columnar and chunked even if the public result API is row-oriented.

### Task 1: Package and File Scaffolding

- Create package directories `sql`, `scan`, and `engine`, each with its own `moon.pkg`.
- Keep the root package responsible only for public APIs and error/result types.
- Add fixture directories for CSV and JSONL test data and decide one stable location for blackbox test inputs.
- Define a minimal dependency direction: root depends on `sql`, `scan`, and `engine`; `engine` depends on `scan`; `scan` and `sql` stay independent.
- Add `moonbitlang/x/fs` and `moonbitlang/core/json` as the only planned external scan dependencies in milestone 1.
- Add `moonlex` and `moonyacc` to the SQL package toolchain plan and keep generated lexer/parser files isolated under the `sql` package.

### Task 2: Core Shared Types

- Define logical types for milestone 1: `Null`, `Boolean`, `BigInt`, `Double`, and `Varchar`.
- Define `Schema`, `ColumnDef`, `Value`, `Row`, and `DbError`.
- Define internal vector primitives: typed value buffers, validity bitmap, and `DataChunk`.
- Fix the first internal conventions now: vector size `2048`, UTF-8 strings only, and nulls represented by validity masks rather than sentinel values.

### Task 3: SQL Front End

- Implement the SQL lexer with `moonlex` for identifiers, keywords, strings, numbers, punctuation, and operators.
- Implement the SQL parser with `moonyacc` for the milestone-1 subset:
  `SELECT`, aliases, literals, column references, arithmetic, comparisons, boolean operators, parentheses, `CAST`, `IS NULL`, `FROM`, and `WHERE`.
- Define an owned AST with separate nodes for query, select item, table function call, and expressions.
- Standardize parser diagnostics early so later milestones reuse the same error shape and location reporting.
- Keep the grammar intentionally narrow so unsupported syntax fails cleanly instead of forcing early grammar expansion.
- Decide whether generated lexer/parser artifacts are checked into git or regenerated in build/test flows only after the licensing checkpoint is complete.

### Task 4: File Scan Interfaces

- Define one scan abstraction that returns inferred schema plus chunked rows for execution.
- Implement `read_csv(path)` and `read_jsonl(path)` as built-in scan sources.
- Make file opening and read failures explicit `DbError` cases so they flow through the public API without ad hoc string errors.
- Keep scan options out of scope for now beyond the required path argument.
- Keep the abstraction independent of any third-party row-materializing package API so the executor can stay chunk-oriented.

### Task 5: CSV Reader and Schema Inference

- Implement UTF-8 CSV reading with comma delimiter, quoted fields, escaped quotes, and header row enabled by default.
- Review `xunyoyo/NyaCSV` before implementation for edge cases and test fixtures, but do not couple the production scanner to its in-memory row model.
- Add a schema inference pass that samples the full file in milestone 1, resolves each column to the narrowest supported type, and falls back to `Varchar` on conflicts.
- Treat empty fields as `NULL`.
- Preserve original column names from the header row and define deterministic fallback names if the header is missing or invalid.

### Task 6: JSONL Reader and Schema Inference

- Implement UTF-8 line-by-line JSON object reading for one JSON object per line.
- Build the parser path directly on `moonbitlang/core/json` and file reading on `moonbitlang/x/fs`; do not look for a dedicated JSONL dependency for milestone 1.
- Infer schema across all observed keys, treating missing keys as `NULL`.
- Map booleans, integers, floats, and strings to supported scalar types.
- Serialize nested arrays or objects to `Varchar` instead of introducing nested types.

### Task 7: Binder and Logical Plan

- Bind parsed column references against exactly one scan source.
- Resolve select aliases, validate `WHERE` expressions, and reject unsupported constructs with clear planner errors.
- Lower bound queries to a minimal logical plan with `Scan`, `Filter`, and `Projection`.
- Apply only the coercion rules needed for milestone 1: numeric widening `BigInt -> Double` and explicit `CAST`.

### Task 8: Physical Executor

- Implement physical operators for scan, filter, and projection over `DataChunk`.
- Evaluate expressions column-at-a-time where practical and keep row materialization at the result boundary only.
- Convert chunked internal output into a public `ResultSet` that can be iterated row-by-row through `next()`.
- Ensure executor behavior is deterministic for projection order, column naming, and null handling.

### Task 9: Public API and CLI Wiring

- Implement `Database::new()`, `Database::connect()`, and `Connection::query(sql)`.
- Keep `Database` lightweight in milestone 1; it can be mostly a namespace for future catalog state.
- Expose `ResultSet::schema()` and `ResultSet::next()` on top of executor output.
- Update `cmd/main` into a thin debug CLI that accepts a SQL string and prints rows for manual validation.

### Task 10: Tests and Fixtures

- Add parser tests for valid queries, precedence, alias parsing, and invalid syntax.
- Add scanner tests for CSV quotes, null fields, inferred numeric types, JSONL missing keys, and malformed input.
- Add planner tests for unknown columns, invalid casts, and unsupported syntax rejection.
- Add executor blackbox tests for projection and `WHERE` over both CSV and JSONL fixtures.
- Add at least one end-to-end test per file format through the public `Connection::query(sql)` API.

### Acceptance Criteria

- A user can run `SELECT name FROM read_csv('fixtures/people.csv') WHERE age > 18`.
- A user can run `SELECT id, active FROM read_jsonl('fixtures/events.jsonl') WHERE active = true`.
- Result schemas are inferred correctly and returned through `ResultSet::schema()`.
- `ResultSet::next()` yields rows in scan order after filtering and projection.
- Invalid SQL, missing files, malformed CSV/JSONL, and unknown columns return structured errors rather than panics.
- All milestone-1 tests pass under `moon test`, and the public surface generated by `moon info` matches the intended API.

## Milestone 1 Status

- Milestone 1 is accepted as complete for the current repo state.
- Validation status at acceptance:
  `moon check --target native` passes,
  `moon test --target native` passes,
  and `moon info --target native` passes.
- The acceptance query shapes are working through the public API and CLI:
  `SELECT name FROM read_csv('fixtures/csv/people.csv') WHERE age > 18`
  and
  `SELECT id, active FROM read_jsonl('fixtures/jsonl/events.jsonl') WHERE active = true`.

### Implemented in Milestone 1

- Package layout now includes `sql`, `scan`, `engine`, `plan`, `execute`, and the root public API package.
- Public API is in place with `Database::new()`, `Database::connect()`, `Connection::query(sql)`, `ResultSet::schema()`, and `ResultSet::next()`.
- Shared engine types are implemented: `LogicalType`, `ColumnDef`, `Schema`, `Value`, `Row`, `ValidityMask`, `VectorBuffer`, `Vector`, and `DataChunk`.
- SQL front end is implemented with `moonlex` and `moonyacc`, producing an owned AST for:
  `SELECT`, aliases, literals, column references, arithmetic, comparisons, boolean operators, `CAST`, `IS NULL`, `FROM`, and `WHERE`.
- Planner/binder is implemented for one scan source per query and lowers queries into `Scan`, `Filter`, and `Projection` plans.
- CSV scanning is implemented with schema inference, header normalization, quoted-field support, malformed-row detection, and chunk materialization.
- JSONL scanning is implemented with line-by-line object parsing, schema inference across rows, missing-key null handling, nested value fallback to `VARCHAR`, and chunk materialization.
- Execution is implemented for scan, filter, and projection over chunked column vectors, with row materialization only at the public result boundary.
- CLI support is implemented in `cmd/main` as a thin manual query runner / REPL for ad hoc validation.
- Test coverage exists across parser, planner, scan, executor, and public query API paths, with fixture data under `fixtures/`.

### Accepted Deviations

- The CSV scanner currently uses `xunyoyo/NyaCSV` in the production scan path instead of a fully owned parser implementation.
- JSONL numeric inference still depends on current `moonbitlang/core/json` behavior for preserving integral values accurately enough for the current fixtures.
- The SQL build path currently uses `moonlex` and `moonyacc`, with the licensing checkpoint tracked as follow-up rather than a blocker for Milestone 1 acceptance.

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
- Parser-generator investigation result: `moonbitlang/parser` is unrelated; the relevant official projects are `moonlex` and `moonyacc`, and this plan now assumes both will be used for milestone 1.
- Licensing caveat: `moonyacc`'s GPLv2 licensing creates redistribution risk for an Apache-licensed project if generated output contains GPL-covered code. The plan assumes the project will still proceed with `moonlex` and `moonyacc`, but will add a checkpoint before committing or shipping generated artifacts.
- Package investigation result: `xunyoyo/NyaCSV` exists and is worth reviewing for CSV behavior, but the plan assumes an owned CSV scanner for chunked ingestion. No dedicated JSONL package is assumed; JSONL support is built directly on `moonbitlang/core/json` and `moonbitlang/x/fs`.

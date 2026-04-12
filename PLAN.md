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
- Milestone 3: table joins, multi-source binding, qualified column resolution, and join execution over chunked inputs.
- Milestone 4: combining joins and aggregation, including grouped aggregates over joined inputs and `HAVING` on joined aggregate results.
- Milestone 5: sort/limit, filter pushdown, projection pruning, end-to-end fixtures, and CLI demo package.
- Milestone 6: internal cleanup for the later roadmap: operator interfaces, vector APIs, and planner boundaries frozen so persistent storage and broader SQL features can be added without reworking the public API.

## Milestone 2 Breakdown

### Scope

- Extend the current single-source query engine to support scalar aggregates and grouped aggregation over existing CSV and JSONL scan sources.
- Support global aggregate queries without `GROUP BY`, grouped aggregate queries with `GROUP BY`, and post-aggregate filtering with `HAVING`.
- Keep the milestone limited to one scan source per query; joins, sort/limit, subqueries, and window functions remain out of scope.
- Support aggregate functions `COUNT(*)`, `COUNT(expr)`, `SUM`, `AVG`, `MIN`, and `MAX`.
- Exclude `DISTINCT`, `COUNT(DISTINCT ...)`, `GROUPING SETS`, rollups, and aggregate `ORDER BY` from this milestone.

### Task 1: SQL Surface Expansion

- Extend the SQL AST and parser to represent function-call expressions for aggregates, `GROUP BY`, and optional `HAVING`.
- Treat aggregate function names case-insensitively and normalize them during binding.
- Add parser support for `COUNT(*)` as a dedicated aggregate form instead of treating `*` as a normal expression.
- Keep the first grouped-aggregation surface intentionally narrow: `GROUP BY` items are column references only, not arbitrary expressions.

### Task 2: Aggregate Binding and Validation

- Add binder logic that distinguishes scalar expressions, grouped column references, and aggregate expressions.
- Reject invalid shapes early: nested aggregates, aggregates in `WHERE`, non-grouped/non-aggregated expressions in aggregate queries, and invalid `HAVING` references.
- Allow `HAVING` to reference grouped columns and aggregate results only.
- Define aggregate output types and nullability now:
  `COUNT(*)` and `COUNT(expr)` -> `BIGINT NOT NULL`,
  `SUM(BIGINT)` -> `BIGINT NULL`,
  `SUM(DOUBLE)` -> `DOUBLE NULL`,
  `AVG(...)` -> `DOUBLE NULL`,
  `MIN/MAX(T)` -> `T NULL`.
- Restrict `SUM` and `AVG` to numeric input, allow `COUNT` on any input, and allow `MIN/MAX` on `BOOLEAN`, `BIGINT`, `DOUBLE`, and `VARCHAR`.

### Task 3: Null and Scalar Semantics

- Centralize scalar expression semantics so the same rules apply in `WHERE`, aggregate arguments, `HAVING`, and final projections.
- Use SQL-style null propagation for arithmetic and comparisons.
- Keep three-valued logic for boolean expressions: `TRUE`, `FALSE`, and `NULL`, with `WHERE` and `HAVING` treating `NULL` as not passing the filter.
- Define aggregate null behavior explicitly:
  `COUNT(expr)` ignores nulls,
  `SUM/AVG/MIN/MAX` ignore nulls,
  and aggregates over an all-null group return `NULL` except `COUNT`, which returns `0`.
- Define empty-input behavior explicitly:
  a global aggregate query without `GROUP BY` returns one row,
  while a grouped aggregate query over empty input returns zero rows.

### Task 4: Logical Plan Changes

- Add an `Aggregate` logical plan node that carries input plan, group keys, aggregate definitions, and output schema.
- Model query flow as `Scan -> Filter(where) -> Aggregate(optional) -> Filter(having optional) -> Projection`.
- Keep projection as the top layer so the public result materialization path stays unchanged.
- Preserve the current single-source scan model under the aggregate node; multi-source binding is deferred to the join milestone.

### Task 5: Aggregate State Model

- Define explicit internal aggregate states for `Count`, `SumInt64`, `SumDouble`, `Avg`, `Min`, and `Max`.
- Make state update and finalize behavior explicit so later partial aggregation or parallel execution can reuse the same interfaces.
- For `AVG`, track running count plus running double sum and finalize to `DOUBLE`.
- Keep group-key storage separate from aggregate states so grouped output schema and hash-key handling stay straightforward.

### Task 6: Physical Aggregation Executor

- Implement a global aggregation path for queries without `GROUP BY`.
- Implement grouped hash aggregation for `GROUP BY`, keyed by the grouped columns.
- Preserve deterministic group output order by emitting groups in first-seen input order rather than raw hash-table order.
- Materialize aggregate output into `DataChunk`s using the same vector and validity-mask conventions as the current executor.
- Keep row materialization only at the public `ResultSet` boundary.
- Future follow-up: avoid delimiter-based string serialization for grouped keys; use a collision-safe structured key or length-prefixed encoding so `VARCHAR` group values cannot merge distinct groups accidentally.

### Task 7: Expression Evaluation Refactor

- Refactor expression evaluation so scalar kernels can be reused across pre-aggregate filters, aggregate argument evaluation, `HAVING`, and final projections.
- Keep existing filter/projection behavior intact for non-aggregate queries.
- Add explicit coercion points needed by aggregation, especially `BIGINT -> DOUBLE` for mixed numeric flows and `AVG`.
- Make aggregate-query column naming deterministic: explicit aliases win; otherwise use stable defaults such as `count`, `sum`, `avg`, `min`, and `max`.

### Task 8: Public API and CLI Wiring

- Keep the public API shape unchanged: `Connection::query(sql)` still returns `Result[ResultSet, DbError]`.
- Ensure `ResultSet::schema()` reports aggregate output columns with correct types and nullability.
- Keep `ResultSet::next()` row-oriented even though grouped execution stays chunked internally.
- Update the CLI path and any inline documentation/examples to demonstrate at least one global aggregate and one grouped aggregate query.

### Task 9: Tests and Fixtures

- Add parser tests for aggregate function syntax, `COUNT(*)`, `GROUP BY`, `HAVING`, and invalid aggregate forms.
- Add binder/planner tests for grouped-column validation, aggregate type rules, nested-aggregate rejection, and invalid `HAVING` references.
- Add executor tests for global aggregation, grouped aggregation, null handling, empty-input behavior, and deterministic group output ordering.
- Add end-to-end public API tests for CSV and JSONL aggregate queries, including aliases and `HAVING`.
- Add fixtures with repeated group keys, null values, and empty result cases so aggregate semantics are tested directly.

### Acceptance Criteria

- A user can run `SELECT COUNT(*) AS total FROM read_csv('fixtures/csv/people.csv')`.
- A user can run `SELECT active, COUNT(*) AS total FROM read_jsonl('fixtures/jsonl/events.jsonl') GROUP BY active`.
- A user can run a grouped aggregate with `HAVING`, and rows that do not satisfy the `HAVING` predicate are excluded.
- Aggregate result schemas report the correct types and nullability through `ResultSet::schema()`.
- Invalid aggregate queries return structured bind or execution errors rather than panics.
- All Milestone 2 tests pass under `moon test`, and the public API generated by `moon info` reflects only the intended surface changes.

## Milestone 2 Status

- Milestone 2 is accepted as complete for the current repo state.
- Validation status at acceptance:
  `moon check --target native` passes,
  `moon test --target native` passes,
  and `moon info --target native` passes.
- Validation snapshot at acceptance: `57` tests passed with `0` failures.
- Global aggregates, grouped aggregation, and `HAVING` are all implemented and working through the parser, planner, executor, public API, and CLI paths.

### Implemented in Milestone 2

- SQL parsing now supports aggregate function calls, `COUNT(*)`, `GROUP BY`, and `HAVING`.
- Planner and binder now support aggregate binding, grouped-column validation, aggregate result typing, aggregate plans, and post-aggregate filtering.
- Execution now supports global aggregation, grouped hash aggregation, aggregate state tracking, grouped output materialization, and `HAVING` filtering.
- Division inside aggregate expressions now infers and executes as `DOUBLE` consistently, including queries such as `SELECT SUM(age / 2) ...`.
- Public API and end-to-end tests cover aggregate queries over both CSV and JSONL sources.

### Accepted Follow-up

- Grouped-key collision risk is tracked as future work: grouped aggregation should move away from delimiter-based string serialization toward a collision-safe structured or length-prefixed key representation.

## Join Plan

### Scope

- Add table joins as the next major relational capability after grouped aggregation.
- Support exactly two input sources in the first join milestone.
- Support `INNER JOIN` first, with `LEFT JOIN` as the next extension if the executor structure remains clean.
- Restrict join predicates to equality conditions between columns from the left and right inputs in the first implementation.
- Keep relation sources limited to built-in table functions such as `read_csv(path)` and `read_jsonl(path)`.

### SQL Surface

- Extend `FROM` to support `source [AS alias] JOIN source [AS alias] ON left_col = right_col`.
- Support qualified references such as `left.id` and `right.id`, and require qualification when column names are ambiguous.
- Preserve existing `WHERE` behavior after join output is formed.
- Keep non-equality joins, `USING`, `NATURAL JOIN`, and multi-join chains out of scope for the first join milestone.

### Planner and Binder Changes

- Extend the SQL AST to represent joined relations, relation aliases, and join predicates.
- Replace the single-source binder with relation-scope binding that tracks left and right schemas plus optional aliases.
- Add ambiguity checks so duplicate column names require qualification.
- Lower bound joins to a logical `Join` node with explicit left input, right input, join kind, join keys, and output schema.
- Preserve the current `Filter` and `Projection` layering above the join node so existing executor code can be reused.

### Execution Changes

- Add a physical join operator over `DataChunk`s.
- Start with an in-memory hash join for `INNER JOIN`, building on the smaller or right-side input and probing with the other side.
- Materialize join output as chunked column vectors, not rows, and keep row materialization only at the public `ResultSet` boundary.
- Define null join semantics explicitly: `NULL` never matches `NULL` for equality joins.
- Delay join reordering and cost-based decisions; the first implementation can execute joins in written order.

### Tests

- Parser tests for join syntax, aliases, qualified columns, and unsupported join forms.
- Binder tests for ambiguous columns, missing aliases, wrong join predicate shapes, and schema/output naming.
- Executor tests for successful inner joins across CSV/CSV, CSV/JSONL, and JSONL/JSONL fixtures.
- Null-behavior tests confirming rows with null join keys do not match.
- End-to-end public API tests for joined queries with projection and `WHERE`.

## Join + Aggregate Plan

### Scope

- Add aggregate queries over joined inputs as the next major capability after Milestone 3.
- Support aggregate and grouped-aggregate queries over exactly one explicit `INNER JOIN`.
- Allow `GROUP BY` and `HAVING` to reference columns from either side of the join, with qualification required when names are ambiguous.
- Keep the first combined milestone bounded to the existing aggregate surface:
  `COUNT(*)`, `COUNT(expr)`, `SUM`, `AVG`, `MIN`, and `MAX`.
- Keep `LEFT JOIN` aggregates, multi-join chains, window functions, and aggregate `DISTINCT` out of scope for the first combined milestone.

### Planner and Binder Changes

- Unify the current aggregate and join planning paths so the engine can lower:
  `Join -> Filter(where optional) -> Aggregate(optional) -> Filter(having optional) -> Projection`.
- Allow aggregate arguments and group keys to bind against the joined output schema while preserving relation/alias-aware name resolution.
- Keep grouped-column validation and aggregate-shape validation identical to Milestone 2, but applied after join binding.
- Preserve deterministic output naming for grouped columns and aggregate expressions, with explicit aliases taking precedence.

### Execution Changes

- Reuse the Milestone 3 join executor as the input source for aggregate execution rather than introducing a separate joined-row materialization API.
- Support global aggregates over joined rows and grouped hash aggregation over joined rows.
- Keep null semantics unchanged across the combined path:
  join null keys do not match,
  aggregate functions ignore null inputs as defined in Milestone 2,
  and `HAVING` treats `NULL` as not passing.
- Preserve deterministic group output ordering using first-seen group order over the joined stream.

### Tests

- Add end-to-end tests for aggregate-over-join queries across CSV/CSV, CSV/JSONL, and JSONL/JSONL inputs.
- Add grouped-aggregate tests where group keys come from the left side, right side, and both sides of the join.
- Add `HAVING` tests over joined aggregate results.
- Add binder tests for ambiguous grouped columns and invalid aggregate references over joined inputs.

## Milestone 4 Breakdown

### Scope

- Deliver aggregate queries over exactly one explicit `INNER JOIN`.
- Support global aggregates and grouped aggregates over joined CSV/CSV, CSV/JSONL, and JSONL/JSONL inputs.
- Support `WHERE` before aggregation and `HAVING` after aggregation over joined inputs.
- Reuse the existing aggregate surface: `COUNT(*)`, `COUNT(expr)`, `SUM`, `AVG`, `MIN`, and `MAX`.
- Keep `LEFT JOIN`, multi-join chains, aggregate `DISTINCT`, window functions, aggregate pushdown, and join reordering out of scope.

### Task 1: SQL Surface Verification

- Verify the existing grammar accepts `FROM <join> WHERE ... GROUP BY ... HAVING ...` in the intended clause order.
- Add parser tests for aggregate-over-join queries with aliases, qualified columns, `WHERE`, `GROUP BY`, and `HAVING`.
- Reject unsupported forms cleanly, especially aggregates inside `ON` predicates and unsupported join shapes inside aggregate queries.
- Keep `GROUP BY` items limited to column references, matching Milestone 2.

### Task 2: Combined Query Classification

- Update query classification so aggregate queries are allowed when the input relation is a join.
- Preserve the existing non-aggregate join path from Milestone 3.
- Preserve the existing single-source aggregate path from Milestone 2.
- Ensure aggregate-over-join planning chooses the combined path only when the query contains aggregate functions, `GROUP BY`, or `HAVING`.

### Task 3: Joined Aggregate Binding

- Bind aggregate arguments, grouped columns, `HAVING`, and final projections against the joined output schema.
- Preserve Milestone 3 qualification rules: unqualified names are allowed only when unique across both joined inputs.
- Preserve Milestone 2 aggregate validation rules: no nested aggregates, no aggregates in `WHERE`, and no non-grouped/non-aggregated projection expressions in aggregate queries.
- Allow group keys and aggregate arguments to reference columns from the left side, right side, or both sides of the join.
- Return structured bind errors for ambiguous group keys, ambiguous aggregate arguments, and invalid `HAVING` references.

### Task 4: Logical Plan Composition

- Compose plans in the fixed order:
  `Join -> Filter(where optional) -> Aggregate -> Filter(having optional) -> Projection`.
- Allow `Aggregate` input to be either a scan/filter subtree or a join/filter subtree.
- Keep join output schema as left-then-right input columns before aggregate binding.
- Keep aggregate output schema consistent with Milestone 2, including types, nullability, and alias/default-name rules.
- Do not introduce aggregate pushdown below the join in this milestone.

### Task 5: Executor Integration

- Reuse the Milestone 3 join executor to produce joined `DataChunk`s as aggregate input.
- Reuse the Milestone 2 aggregate executor for global and grouped aggregation over those joined chunks.
- Keep `WHERE` evaluation before aggregation and `HAVING` evaluation after aggregation.
- Preserve deterministic output order: join output is deterministic first, then grouped aggregate output follows first-seen group order.
- Keep row materialization only at the public `ResultSet` boundary.

### Task 6: Semantics

- Count joined rows according to inner-join multiplicity, including duplicate key matches.
- Preserve null semantics across the combined pipeline:
  null join keys do not match,
  aggregate inputs ignore nulls as defined in Milestone 2,
  and `HAVING` treats `NULL` as not passing.
- Preserve numeric coercion and division behavior from Milestone 2 for aggregate arguments over joined columns.
- Preserve join-key coercion behavior from Milestone 3 for numeric `BIGINT`/`DOUBLE` keys.

### Task 7: Tests and Fixtures

- Add public API tests for global aggregate-over-join queries across CSV/CSV, CSV/JSONL, and JSONL/JSONL inputs.
- Add grouped aggregate-over-join tests with group keys from the left side, right side, and both sides.
- Add `HAVING` tests over joined aggregate results.
- Add `WHERE`-before-aggregate tests that filter joined rows before grouping.
- Add binder tests for ambiguous aggregate arguments, ambiguous group keys, aggregates in `ON`, aggregates in `WHERE`, and invalid non-grouped projections.
- Reuse existing join fixtures where possible and add only the smallest extra fixture data needed for duplicate-match and null-key aggregate cases.

### Task 8: Public API and CLI Wiring

- Keep the public API unchanged: `Connection::query(sql)` returns `Result[ResultSet, DbError]`.
- Ensure `ResultSet::schema()` reports aggregate-over-join output types and nullability correctly.
- Add CLI/manual examples for at least one global aggregate-over-join query and one grouped aggregate-over-join query.
- Document qualification requirements for aggregate-over-join queries in the README or examples.

### Acceptance Criteria

- A user can run `SELECT COUNT(*) AS total FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id`.
- A user can run `SELECT people.name, COUNT(*) AS total FROM read_csv('fixtures/csv/join_people.csv') AS people JOIN read_jsonl('fixtures/jsonl/join_events.jsonl') AS events ON people.id = events.id GROUP BY people.name`.
- A user can run a grouped aggregate-over-join query with `HAVING`, and rows that do not satisfy `HAVING` are excluded.
- `WHERE` filters joined rows before aggregation.
- Ambiguous unqualified aggregate arguments and group keys return structured bind errors.
- Aggregate-over-join result schemas report correct types and nullability through `ResultSet::schema()`.
- All Milestone 4 tests pass under `moon test`, and the public API generated by `moon info` reflects only intended surface changes.

## Milestone 3 Breakdown

### Scope

- Deliver the first join-capable query path over exactly two relation sources.
- Support exactly one explicit `INNER JOIN` per query in this milestone.
- Support only equality join predicates of the form `left_col = right_col`, with both sides resolving to column references.
- Keep projection and `WHERE` over the joined result in scope.
- Keep `LEFT JOIN`, multi-join chains, non-equality joins, `USING`, `NATURAL JOIN`, and aggregate-over-join queries out of scope for this milestone.

### Task 1: SQL Surface Expansion

- Extend the SQL AST so `FROM` can represent either a single table function source or a binary join relation.
- Add parser support for `source [AS alias] INNER JOIN source [AS alias] ON left_col = right_col`.
- Accept `JOIN` as `INNER JOIN` shorthand.
- Keep relation aliases optional, but preserve them in the AST whenever present.
- Reject unsupported join forms early in parsing or binding with explicit diagnostics rather than silently accepting partial syntax.

### Task 2: Relation and Name Binding

- Replace the current single-source binding path with relation binding that can bind one source or one joined pair of sources.
- Track per-relation schema, optional alias, and source order so later phases can resolve qualified references consistently.
- Allow unqualified column references only when the name is unique across both input schemas.
- Require qualification when a column name appears on both sides of the join.
- Support qualified references against aliases first, and against raw relation names only when no alias is present.

### Task 3: Join Predicate Validation

- Bind the `ON` predicate separately from `WHERE`.
- Restrict the first implementation to a single equality predicate between one left-side column reference and one right-side column reference.
- Reject predicates that compare columns from the same side, literals against columns, computed expressions, or boolean combinations.
- Define join-key coercion rules now: allow exact type matches and numeric widening between `BIGINT` and `DOUBLE`; reject all other cross-type join keys.
- Treat nullable join keys as valid inputs, but rows with `NULL` join-key values never match.

### Task 4: Logical Plan Changes

- Add a logical `Join` node with fields for left input, right input, join kind, left key, right key, and output schema.
- Preserve the current planning order above the join node as `Join -> Filter(where optional) -> Projection`.
- Build join output schema by concatenating left columns followed by right columns, preserving each side’s original column order.
- Carry enough bound-column metadata so post-join projection and `WHERE` can still resolve columns without re-binding against raw source schemas.
- Keep the aggregate plan separate from join planning for now; joined aggregates remain a later milestone.

### Task 5: Physical Join Operator

- Implement an in-memory hash join over `DataChunk`s.
- Build the hash table from the right input and probe it with left input chunks in scan order.
- Store right-side matches in encounter order so output remains deterministic within each left-row match set.
- Skip rows with null join keys on either side when building or probing.
- Materialize join output as columnar `DataChunk`s, preserving the engine’s fixed vector size and validity-mask conventions.

### Task 6: Join Key Representation

- Introduce a collision-safe internal join-key representation; do not use delimiter-based string concatenation.
- Use typed key components or a length-prefixed binary/text encoding so `VARCHAR` values cannot merge distinct keys accidentally.
- Keep the representation internal to the join operator so it can later be reused by grouped aggregation and future multi-key joins.
- Design the initial implementation for a single join key, but avoid interfaces that would block later extension to composite keys.

### Task 7: Executor Integration

- Extend execution entrypoints so they can execute either a scan-based plan or a join-based plan before applying existing `WHERE` and projection logic.
- Reuse the current scalar expression evaluator for joined-row filtering and projections after the join output is formed.
- Preserve deterministic output order: left input scan order first, then right match order for each left row.
- Keep row materialization only at the public `ResultSet` boundary.
- Ensure joined result schemas flow through `ResultSet::schema()` with the expected left-then-right column order and nullability.

### Task 8: Public API and CLI Wiring

- Keep the public API shape unchanged: `Connection::query(sql)` still returns `Result[ResultSet, DbError]`.
- Update CLI examples and manual validation flows to include at least one joined CSV/JSONL query.
- Document qualification rules clearly in repo docs and examples so ambiguous-column behavior is predictable.

### Task 9: Tests and Fixtures

- Add parser tests for `JOIN`, `INNER JOIN`, aliases, qualified references, and unsupported join syntax.
- Add binder tests for ambiguous unqualified columns, alias resolution, invalid join predicate shapes, and join-key type mismatches.
- Add executor tests for CSV/CSV, CSV/JSONL, and JSONL/JSONL inner joins.
- Add null-key tests to confirm rows with null join keys do not match.
- Add end-to-end public API tests covering projection plus `WHERE` on joined results.
- Add fixtures with duplicate keys, unmatched keys, null keys, and overlapping column names across both inputs.

### Acceptance Criteria

- A user can run `SELECT people.name, events.active FROM read_csv('fixtures/csv/people.csv') AS people JOIN read_jsonl('fixtures/jsonl/events.jsonl') AS events ON people.id = events.id`.
- A user can filter joined output with `WHERE`, and the result rows reflect inner-join semantics only.
- Ambiguous unqualified column references return structured bind errors.
- Null join keys do not match, and unmatched rows are excluded from the result.
- Joined result schemas report columns in left-then-right order through `ResultSet::schema()`.
- All Milestone 3 tests pass under `moon test`, and the public API generated by `moon info` reflects only the intended surface changes.

## Milestone 3 Status

- Milestone 3 is accepted as complete for the current repo state.
- Validation status at acceptance:
  `moon check --target native` passes,
  `moon test --target native` passes,
  and `moon info --target native` passes.
- Validation snapshot at acceptance: `57` tests passed with `0` failures.
- The acceptance query shapes are working through the public API and CLI, including joined queries with `WHERE` and structured bind errors for ambiguous unqualified column references.

### Implemented in Milestone 3

- SQL parsing now supports `JOIN` / `INNER JOIN`, `ON`, source aliases, and qualified column references across two relation sources.
- Planner and binder now support two-source relation binding, alias-aware column resolution, ambiguity detection, join-key validation, and logical `Join` plans.
- Join execution is implemented as an in-memory inner hash join over chunked inputs, with deterministic left-input-first output order.
- Null join keys are excluded from matches, and joined output remains columnar internally until the public `ResultSet` boundary.
- Join result schemas preserve left-then-right column order.
- Test coverage now includes parser, planner, executor, and public API join cases for CSV/JSONL, CSV/CSV, and JSONL/JSONL inputs.

### Accepted Scope Limits

- Milestone 3 supports exactly one explicit `INNER JOIN` over exactly two relation sources.
- Join predicates are limited to one equality condition between a left-side column and a right-side column.
- `LEFT JOIN`, multi-join chains, `USING`, `NATURAL JOIN`, non-equality joins, and aggregate-over-join queries remain out of scope for this milestone.
- The current build still emits non-blocking warnings from generated `sql/lexer.mbt`; these do not block Milestone 3 acceptance.

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

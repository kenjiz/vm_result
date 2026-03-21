# Roadmap

This document tracks what is missing or incomplete in `vm_result` as a focused state management package. Scope is intentionally limited to the package boundary — app-level concerns (networking, routing, auth, data layers) are out of scope.

---

## Phase 0 — Fix Broken Contracts

### 0.1 Unit Tests

The package has zero tests. Every public surface needs coverage:

- All four `Result<T>` state transitions and convenience getters
- `ValueResult<T>` success/failure paths
- `VMResult` guard methods — `run`, `runWithValueResult`, `runSilent`, `runOptimistic` — including disposed-VM safety, rollback correctness, and `isExecuting` toggling
- `VMResultEffect` effect stream lifecycle (emit before and after dispose)
- `ResultBuilder` renders the correct widget per state
- `EffectListener` invokes the callback and cancels subscription on dispose

Without tests, any dependency bump or internal refactor is a blind change.

---

## Phase 1 — ViewModel Completeness

### 1.1 In-Flight Deduplication

Rapid back-to-back calls to `run()` or `runWithValueResult()` — from pull-to-refresh hammering, fast navigation, or search-as-you-type — stack concurrent async operations that resolve in arbitrary order. The last writer wins, which is a silent race condition.

The guard methods need a defined policy: **drop** subsequent calls while `isExecuting` is true, or expose a **cancel-and-replace** variant for search use cases.

---

### 1.2 `PaginatedResult<T>` + `VMPaginated<S>`

Paginated lists are common enough to warrant a shared contract:

```
PaginatedResult<T>
├── items: List<T>
├── hasNextPage: bool
├── isLoadingMore: bool
└── page: int
```

A `VMPaginated<S>` base would expose `loadFirst()`, `loadMore()`, and `refresh()` with correct state transitions for the append-vs-replace distinction. Without this, every developer re-implements pagination with subtly different edge-case handling.

---

### 1.3 `FormViewModel` with Validation State

Forms need state that doesn't map cleanly onto `Result<T>`:

- Per-field `touched` / `dirty` / `errorMessage` state
- Form-level submission guard (delegates to the existing `run`/`runWithValueResult`)
- `isSubmitting` separate from `isExecuting` for fine-grained UI control

A `FormViewModel<S>` base enforces that validation logic never drifts into widgets.

---

## Phase 2 — Developer Experience

### 2.1 Test Utilities

A `vm_result_testing` companion library (or a `testing/` export) with:

- `effectsOf(vm)` — collects emitted effects into a list for assertion
- `statesOf(vm)` — collects state transitions into a list for assertion

These make widget tests trivially easy to write against any `VMResult` subclass without wiring real async operations.

---

### 2.2 Mason Brick

A single `mason` brick to scaffold a new feature:

```
ViewModel file + test file
```

Enforces consistent naming and structure across the team without manual copy-paste.

---

## Phase 3 — Package Health

### 3.1 CI Pipeline

GitHub Actions running on every PR:

- `flutter analyze`
- `flutter test --coverage`
- `dart pub publish --dry-run`

Blocks merge on lint failures or coverage drops.

---

### 3.2 pub.dev Publishing

Populate `CHANGELOG.md`, verify `pubspec.yaml` metadata (homepage, repository, issue tracker), and publish to pub.dev.

---

## Summary

| #   | Item                              | Priority |
| --- | --------------------------------- | -------- |
| 0.1 | Unit tests                        | Critical |
| 1.1 | In-flight deduplication           | High     |
| 1.2 | `PaginatedResult` + `VMPaginated` | High     |
| 1.3 | `FormViewModel`                   | Medium   |
| 2.1 | Test utilities                    | Medium   |
| 2.2 | Mason brick                       | Low      |
| 3.1 | CI pipeline                       | Medium   |
| 3.2 | pub.dev publishing                | Low      |

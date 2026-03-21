# Roadmap

This document tracks what is missing or incomplete in `vm_result` as a focused state management package.

---

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

### ~~1.1 In-Flight Deduplication~~ ✅

Implemented in `VMResult`:

- `run`, `runWithValueResult`, `runSilent`, and `runOptimistic` now drop duplicate calls while `_isExecuting` is `true`, logging a warning in debug mode.
- New `runLatest(action)` guard for cancel-and-replace semantics (search-as-you-type). Results from superseded in-flight calls are silently discarded via an internal generation counter.

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

## Phase 2 — Package Health

### 2.1 CI Pipeline

GitHub Actions running on every PR:

- `flutter analyze`
- `flutter test --coverage`
- `dart pub publish --dry-run`

Blocks merge on lint failures or coverage drops.

---

### 2.2 pub.dev Publishing

Populate `CHANGELOG.md`, verify `pubspec.yaml` metadata (homepage, repository, issue tracker), and publish to pub.dev.

---

## Summary

| #       | Item                              | Priority |
| ------- | --------------------------------- | -------- |
| 0.1     | Unit tests                        | Critical |
| ~~1.1~~ | ~~In-flight deduplication~~ ✅    | ~~High~~ |
| 1.2     | `PaginatedResult` + `VMPaginated` | High     |
| 1.3     | `FormViewModel`                   | Medium   |
| 2.1     | Test utilities                    | Medium   |
| 2.2     | Mason brick                       | Low      |
| 3.1     | CI pipeline                       | Medium   |
| 3.2     | pub.dev publishing                | Low      |

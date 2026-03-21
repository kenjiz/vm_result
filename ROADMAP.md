# Roadmap

This document tracks what is missing or incomplete in `vm_result` as a focused state management package.

---

### ~~0.1 Unit Test~~ ✅

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

### ~~1.2 `PaginatedResult<T>` + `VMPaginated<S>`~~ ✅

Implemented:

- `PageResult<T>` — plain class returned by `fetchPage(int page)`, carries `items` and `hasNextPage`
- `PaginatedResult<T>` — freezed model holding accumulated `items`, current `page`, `hasNextPage`, and `isLoadingMore`
- `VMPaginated<S> extends VMResult<PaginatedResult<S>>` — exposes `loadFirst()`, `loadMore()`, and `refresh()`
  - `loadFirst()` / `refresh()` delegate to `run()` — get the drop guard and full loading state for free
  - `loadMore()` uses `isLoadingMore` for inline progress; on error the item list is preserved and `ValueResult.failure` is returned
  - Subclasses implement one abstract method: `Future<PageResult<S>> fetchPage(int page)`

---

### ~~1.3 `runStream` / `cancelStream` — Stream-Based Operations~~ ✅

Implemented in `VMResult`:

- `runStream(Stream<S> Function() factory)` — subscribes to a long-lived stream (WebSocket, Firestore `snapshots()`, SSE, etc.).
  - Transitions to `ResultLoading` once on connect.
  - Each emitted event transitions to `ResultData(event)`.
  - A stream error transitions to `ResultError` and cancels the subscription.
  - Natural stream close (`onDone`) keeps the last data state and clears `isExecuting`.
- Calling `runStream` while already subscribed **replaces** the active subscription — no manual teardown needed for reconnect or source-swap.
- `cancelStream()` — explicit teardown that preserves the current state and clears `isExecuting`.
- `dispose()` automatically cancels the active subscription to prevent memory leaks.

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

| #       | Item                                     | Priority |
| ------- | ---------------------------------------- | -------- |
| 0.1     | Unit tests                               | Critical |
| ~~1.1~~ | ~~In-flight deduplication~~ ✅           | ~~High~~ |
| ~~1.2~~ | ~~`PaginatedResult` + `VMPaginated`~~ ✅ | ~~High~~ |
| ~~1.3~~ | ~~`runStream` / `cancelStream`~~ ✅      | ~~High~~ |
| 2.1     | CI pipeline                              | Medium   |
| 2.2     | pub.dev publishing                       | Low      |

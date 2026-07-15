# vm_result API Reference

Detailed reference for all public APIs in vm_result v0.1.2.

---

## Result\<T\> (Sealed Class)

**Import**: `package:vm_result/vm_result.dart`
**Source**: `lib/src/models/result.dart`

### Factories

| Factory | Creates | Const? |
|---------|---------|--------|
| `Result.initial()` | `ResultInitial<T>` | Yes |
| `Result.loading()` | `ResultLoading<T>` | Yes |
| `Result.data(T value)` | `ResultData<T>` | Yes |
| `Result.error(Exception error)` | `ResultError<T>` | Yes |

### Getters

| Getter | Return Type | Description |
|--------|-------------|-------------|
| `isLoading` | `bool` | True if `ResultLoading` |
| `hasError` | `bool` | True if `ResultError` |
| `hasValue` | `bool` | True if `ResultData` |
| `value` | `T?` | Data value, null otherwise |
| `errorValue` | `Exception?` | Error, null otherwise |
| `asData` | `ResultData<T>?` | Cast or null |
| `asError` | `ResultError<T>?` | Cast or null |
| `asLoading` | `ResultLoading<T>?` | Cast or null |

### Pattern Matching (via freezed)

- `when({initial, loading, data, error})` — exhaustive
- `maybeWhen({initial?, loading?, data?, error?, required orElse})` — with fallback
- `map({initial, loading, data, error})` — receives typed subclass
- `maybeMap({initial?, loading?, data?, error?, required orElse})` — with fallback

---

## ValueResult\<T\> (Sealed Class)

**Source**: `lib/src/models/result.dart`

### Factories

| Factory | Creates |
|---------|---------|
| `ValueResult.success(T data)` | `ValueResultSuccess<T>` |
| `ValueResult.failure(Exception error)` | `ValueResultFailure<T>` |

### Getters

| Getter | Return Type | Description |
|--------|-------------|-------------|
| `isSuccess` | `bool` | True if success |
| `isFailure` | `bool` | True if failure |
| `data` | `T?` | Success value, null otherwise |
| `failure` | `Exception?` | Failure, null otherwise |
| `asSuccess` | `ValueResultSuccess<T>?` | Cast or null |
| `asFailure` | `ValueResultFailure<T>?` | Cast or null |

---

## PaginatedResult\<T\> (Freezed Class)

**Source**: `lib/src/models/paginated_result.dart`

### Constructor

```dart
const PaginatedResult({
  required List<T> items,
  required int page,
  required bool hasNextPage,
  @Default(false) bool isLoadingMore,
})
```

### Getters

| Getter | Type | Description |
|--------|------|-------------|
| `items` | `List<T>` | All accumulated items |
| `page` | `int` | Current page (1-based) |
| `hasNextPage` | `bool` | More pages available? |
| `isLoadingMore` | `bool` | loadMore in-flight? |
| `isEmpty` | `bool` | `items.isEmpty` |
| `isNotEmpty` | `bool` | `items.isNotEmpty` |

Has `copyWith` support via freezed.

---

## PageResult\<T\> (Plain Class)

**Source**: `lib/src/models/paginated_result.dart`

```dart
const PageResult({required List<T> items, required bool hasNextPage})
```

Returned by `VMPaginated.fetchPage()`. Carries a single page of items.

---

## BaseUiEffect / UiEffect

**Source**: `lib/src/models/ui_effect.dart`

- `BaseUiEffect` — abstract base class for all custom UI effects
- `UiEffect.showMessage(String message)` — built-in toast/snackbar variant
- `UiEffect.isProcessing(bool isProcessing)` — built-in processing indicator

Custom effects: extend `BaseUiEffect` (or use a sealed subclass hierarchy).

---

## VMResult\<S\> (Abstract Class)

**Source**: `lib/src/vms/vm_result.dart`
**Extends**: `ChangeNotifier`
**Implements**: `ValueListenable<Result<S>>`

### Constructor

```dart
VMResult(Result<S> initial)
```

### Public Properties

| Property | Type | Description |
|----------|------|-------------|
| `value` | `Result<S>` | Current state (ValueListenable) |
| `state` | `Result<S>` | Alias for `value` |
| `isExecuting` | `bool` | True while a guard is in-flight |
| `disposed` | `bool` | True after `dispose()` |

### Protected Guard Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `run` | `Future<void> run(Future<S> Function() action)` | Standard fetch with loading state |
| `runWithValueResult` | `Future<ValueResult<S>> runWithValueResult(Future<S> Function() action)` | Returns ValueResult for branching |
| `runSilent` | `Future<void> runSilent(Future<S> Function() action)` | No loading state shown |
| `runOptimistic` | `Future<void> runOptimistic({required S optimisticState, required Future<S> Function() action})` | Instant UI update + auto rollback |
| `runLatest` | `Future<void> runLatest(Future<S> Function() action)` | Cancel-and-replace (generation counter) |
| `runStream` | `void runStream(Stream<S> Function() factory)` | Subscribe to long-lived stream |
| `cancelStream` | `Future<void> cancelStream()` | Cancel active stream subscription |

### Protected State Setters

| Method | Description |
|--------|-------------|
| `setLoading()` | → `ResultLoading` |
| `setData(S data)` | → `ResultData` |
| `setError(Exception error, [StackTrace?])` | → `ResultError` + logs |

### Deduplication Behavior

- `run`, `runWithValueResult`, `runSilent`, `runOptimistic`: **Drop** calls while `isExecuting == true`
- `runLatest`: **Cancel-and-replace** — all calls go through, stale results discarded
- `runStream`: **Replace** — cancels existing subscription, starts new one

### Dispose Safety

All state mutations and effect emissions are silently dropped after `dispose()`.
Stream subscriptions are automatically cancelled on dispose.

---

## VMPaginated\<S\> (Abstract Class)

**Source**: `lib/src/vms/vm_paginated.dart`
**Extends**: `VMResult<PaginatedResult<S>>`

### Constructor

```dart
VMPaginated() : super(Result<PaginatedResult<S>>.initial())
```

### Abstract Method (Must Override)

```dart
@protected
Future<PageResult<S>> fetchPage(int page)
```

### Public Methods

| Method | Returns | Loading | Description |
|--------|---------|---------|-------------|
| `loadFirst()` | `Future<void>` | Full screen | Fetches page 1, replaces all items |
| `loadMore()` | `Future<ValueResult<PaginatedResult<S>>>` | Inline only | Appends next page |
| `refresh()` | `Future<void>` | Full screen | Alias for `loadFirst()` |

### loadMore Behavior

- Returns `ValueResult.failure` without mutating state if:
  - `loadFirst`/`refresh` is currently executing
  - No data loaded yet (state is not `ResultData`)
  - `hasNextPage` is false
  - A previous `loadMore` is already in-flight
- On error: preserves existing items, resets `isLoadingMore` to false
- Does **not** set `Result.error` (avoids blanking the visible list)

---

## VMResultEffect\<S, UE extends BaseUiEffect\> (Abstract Class)

**Source**: `lib/src/vms/vm_result_effect.dart`
**Extends**: `VMResult<S>`

### Constructor

```dart
VMResultEffect(Result<S> initial)
```

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `effects` | `Stream<UE>` | Broadcast stream of UI effects |

### Methods

| Method | Description |
|--------|-------------|
| `emitEffect(UE effect)` | Adds effect to the broadcast stream. No-op after dispose. |

Dispose automatically closes the `StreamController`.

---

## ResultBuilder\<T\> (Widget)

**Source**: `lib/src/widgets/result_builder.dart`
**Extends**: `StatelessWidget`

```dart
const ResultBuilder({
  required ValueListenable<Result<T>> listenable,
  required Widget Function(BuildContext, Result<T>, Widget?) builder,
  Widget? child,
})
```

Thin wrapper around `ValueListenableBuilder<Result<T>>`.

---

## EffectListener\<VM, S, UE\> (Widget)

**Source**: `lib/src/widgets/effect_listener.dart`
**Extends**: `StatefulWidget`

Type parameters:
- `VM extends VMResultEffect<S, UE>` — the ViewModel type
- `S` — the state type
- `UE extends BaseUiEffect` — the effect type

```dart
const EffectListener({
  required VM vm,
  required void Function(BuildContext, UE) listener,
  required Widget child,
})
```

Handles subscription lifecycle:
- Subscribes in `initState`
- Re-subscribes on ViewModel swap via `didUpdateWidget`
- Cancels in `dispose`

---

## VMResultLogging (Static Registry)

**Source**: `lib/src/logging/vm_result_logger.dart`

```dart
class VMResultLogging {
  static VMResultLogger logger = const DefaultVMResultLogger();
}
```

Set `VMResultLogging.logger` to a custom `VMResultLogger` implementation
in `main()` before `runApp()`.

### VMResultLogger Interface

```dart
abstract class VMResultLogger {
  void info(String message);
  void warning(String message);
  void error(String message, [StackTrace? stackTrace]);
}
```

### DefaultVMResultLogger

Uses `dart:developer` log. Only emits in `kDebugMode`. Zero overhead in release.

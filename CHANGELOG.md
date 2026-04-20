## 0.1.0

### Bug Fixes

- **Web compatibility**: removed `dart:io` (`Platform.environment`) from `logger.dart`;
  logging is now gated on `kDebugMode`, which works on all Flutter targets including Web.
- **`EffectListener`**: added `didUpdateWidget` override so the effect stream subscription is
  correctly replaced when the `vm` prop is swapped at runtime, preventing silently lost effects.
- **`VMResultEffect`**: removed a duplicate `_disposed` field that shadowed `VMResult._disposed`,
  eliminating a maintenance trap and a potential gap where `emitEffect` could add to a closed
  stream controller. `dispose()` now calls `super.dispose()` first (which sets the inherited
  `disposed` flag) before closing the controller.
- **`VMResult._executeLatest`**: the `finally` block now also clears `isExecuting` when the VM
  is disposed mid-flight in a non-latest generation, preventing a stale `true` value.

### Improvements

- Removed the redundant `_isDisposed` private getter from `VMResult`; all internal checks now
  use `_disposed` directly.
- Clarified `runOptimistic` docs: the rollback on failure is transient — the terminal state is
  always `ResultError`, not the previous data state.
- Added debug-mode logging before Dart `Error` rethrows in all `_execute*` helpers, making it
  easier to identify which ViewModel operation triggered a programming error.
- Added `Result.isInitial` convenience getter for symmetry with `isLoading`, `hasError`, and `hasValue`.

### Package metadata

- Added `homepage`, `repository`, `issue_tracker`, and `topics` to `pubspec.yaml`.
- Added BSD 3-Clause `LICENSE` file.

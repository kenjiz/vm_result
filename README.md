# vm_result

A minimal, production-grade MVVM ViewModel contract for Flutter.

`vm_result` provides a typed `Result<T>` state model and a `ChangeNotifier`-based `VMResult<S>` base class that eliminates boilerplate for async state management. It enforces a clear contract: every async operation is represented as one of four states — `initial`, `loading`, `data`, or `error` — and gives you guard helpers that handle transitions automatically.

---

## Features

- **`Result<T>`** — A freezed sealed class representing the four lifecycle states of an async value.
- **`ValueResult<T>`** — A lightweight success/failure type for operations where you need to branch on the outcome.
- **`VMResult<S>`** — Abstract `ChangeNotifier` ViewModel base class backed by `ValueListenable<Result<S>>`.
- **`VMResultEffect<S, UE>`** — Extends `VMResult` with a broadcast `Stream` for one-shot UI side effects.
- **`ResultBuilder<T>`** — A thin `ValueListenableBuilder` wrapper for reactive UI.
- **`EffectListener`** — A `StatefulWidget` that subscribes to an effect stream and dispatches callbacks to the UI.
- Built-in debug-mode state transition logging via [talker_flutter](https://pub.dev/packages/talker_flutter).
- Dispose safety — all state updates and effect emissions are silently dropped after `dispose()`.

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  vm_result:
    path: ../vm_result # or your pub.dev version once published
```

Then run:

```sh
flutter pub get
```

---

## Core Concepts

### `Result<T>`

A freezed sealed class with four states:

| State           | Factory                   | Use                                   |
| --------------- | ------------------------- | ------------------------------------- |
| `ResultInitial` | `Result.initial()`        | Before any operation starts           |
| `ResultLoading` | `Result.loading()`        | While an async operation is in flight |
| `ResultData<T>` | `Result.data(value)`      | Successful completion with a value    |
| `ResultError`   | `Result.error(exception)` | Failed operation                      |

**Convenience getters:**

```dart
result.isLoading   // bool
result.hasError    // bool
result.hasValue    // bool
result.value       // T? — null if not data state
result.errorValue  // Exception? — null if not error state
result.asData      // ResultData<T>?
result.asError     // ResultError<T>?
result.asLoading   // ResultLoading<T>?
```

**Pattern matching (via freezed):**

```dart
result.when(
  initial: () => const SizedBox.shrink(),
  loading: () => const CircularProgressIndicator(),
  data:    (value) => Text(value.name),
  error:   (error) => Text('Error: ${error.message}'),
);
```

---

### `ValueResult<T>`

A two-state result type for operations where you need to act differently on success vs. failure — typically used with `runWithValueResult`.

```dart
ValueResult.success(data)
ValueResult.failure(exception)

result.isSuccess  // bool
result.isFailure  // bool
result.data       // T?
result.failure    // Exception?
```

---

### `VMResult<S>`

The abstract ViewModel base class. Extend this for any screen or feature that manages a single async value.

```dart
class UserViewModel extends VMResult<User> {
  UserViewModel(this._repository) : super(const Result.initial());

  final UserRepository _repository;

  Future<void> load(String id) => run(() => _repository.getUser(id));

  Future<void> updateName(String name) async {
    final result = await runWithValueResult(
      () => _repository.updateName(name),
    );
    result.when(
      success: (_) => navigateBack(),
      failure: (e) => showError(e.message),
    );
  }
}
```

#### Guard methods

| Method                                   | Loading state | Returns                  | Use when                                             |
| ---------------------------------------- | ------------- | ------------------------ | ---------------------------------------------------- |
| `run(action)`                            | Yes           | `Future<void>`           | Standard async fetch                                 |
| `runWithValueResult(action)`             | Yes           | `Future<ValueResult<S>>` | Need to branch on success/failure (e.g., navigation) |
| `runSilent(action)`                      | No            | `Future<void>`           | Background updates (auto-save, background sync)      |
| `runOptimistic(optimisticState, action)` | No            | `Future<void>`           | Instant feedback with automatic rollback on failure  |

#### Manual state setters (protected)

```dart
setLoading();          // transitions to ResultLoading
setData(value);        // transitions to ResultData
setError(exception);   // transitions to ResultError + logs via talker
```

#### ViewModel lifecycle

```dart
vm.isExecuting  // bool — true while an action is running
vm.disposed     // bool — true after dispose() is called
```

> **Important:** Always call `dispose()` in your widget's `dispose()` method to prevent memory leaks. The class handles this via `ChangeNotifier.dispose()`.

---

### `VMResultEffect<S, UE>`

Extends `VMResult<S>` with a broadcast `Stream<UE>` for one-shot UI side effects (toasts, navigation events, dialogs) that don't belong in the state.

```dart
// 1. Define your effects
class AuthEffect extends BaseUiEffect {
  const AuthEffect();
}

class ShowError extends AuthEffect {
  const ShowError(this.message);
  final String message;
}

class NavigateToHome extends AuthEffect {
  const NavigateToHome();
}

// 2. Extend VMResultEffect
class AuthViewModel extends VMResultEffect<User, AuthEffect> {
  AuthViewModel(this._repository) : super(const Result.initial());

  final AuthRepository _repository;

  Future<void> login(String email, String password) async {
    final result = await runWithValueResult(
      () => _repository.login(email, password),
    );
    result.when(
      success: (_) => emitEffect(const NavigateToHome()),
      failure: (e) => emitEffect(ShowError(e.toString())),
    );
  }
}
```

The built-in `UiEffect` variants cover common cases:

```dart
UiEffect.showMessage('Profile saved')
UiEffect.isProcessing(true)
```

---

## Widgets

### `ResultBuilder<T>`

A thin wrapper around `ValueListenableBuilder` for building UI from a `VMResult`.

```dart
ResultBuilder<User>(
  listenable: viewModel,
  builder: (context, result, child) {
    return result.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const Center(child: CircularProgressIndicator()),
      data:    (user) => UserProfile(user: user),
      error:   (error) => ErrorView(error: error),
    );
  },
);
```

The optional `child` parameter is passed through to `ValueListenableBuilder` for subtree optimization — use it for expensive widgets that don't depend on the result.

---

### `EffectListener<VM, S, UE>`

Subscribes to a `VMResultEffect`'s effect stream and invokes a callback on each emission. It wraps a child widget and does not modify the widget tree.

```dart
EffectListener<AuthViewModel, User, AuthEffect>(
  vm: viewModel,
  listener: (context, effect) {
    switch (effect) {
      case NavigateToHome():
        Navigator.of(context).pushReplacementNamed('/home');
      case ShowError(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  },
  child: LoginForm(vm: viewModel),
);
```

---

## Full Example

```dart
// model
class Post {
  const Post({required this.id, required this.title});
  final int id;
  final String title;
}

// effect
class PostEffect extends BaseUiEffect {
  const PostEffect();
}

class PostSavedEffect extends PostEffect {
  const PostSavedEffect();
}

// viewmodel
class PostViewModel extends VMResultEffect<Post, PostEffect> {
  PostViewModel(this._repo) : super(const Result.initial());

  final PostRepository _repo;

  Future<void> load(int id) => run(() => _repo.getPost(id));

  Future<void> save(Post post) async {
    final result = await runWithValueResult(() => _repo.save(post));
    result.when(
      success: (_) => emitEffect(const PostSavedEffect()),
      failure: (e) => setError(e),
    );
  }
}

// widget
class PostScreen extends StatefulWidget { ... }

class _PostScreenState extends State<PostScreen> {
  late final PostViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = PostViewModel(context.read<PostRepository>());
    _vm.load(widget.postId);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EffectListener<PostViewModel, Post, PostEffect>(
      vm: _vm,
      listener: (context, effect) {
        if (effect is PostSavedEffect) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Saved!')));
        }
      },
      child: ResultBuilder<Post>(
        listenable: _vm,
        builder: (context, result, _) => result.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          data:    (post) => PostBody(post: post),
          error:   (error) => ErrorView(error: error),
        ),
      ),
    );
  }
}
```

---

## Architecture Overview

```
Widget Layer
  └── ResultBuilder          — reactive state rendering
  └── EffectListener         — one-shot side-effect handling

ViewModel Layer
  └── VMResultEffect<S, UE>  — ViewModel with effects
        └── VMResult<S>      — base ViewModel (ChangeNotifier + ValueListenable)

Model Layer
  └── Result<T>              — 4-state async value (initial/loading/data/error)
  └── ValueResult<T>         — 2-state operation result (success/failure)
  └── BaseUiEffect / UiEffect — side-effect contracts
```

---

## Requirements

- Flutter SDK
- Dart `^3.10.0`
- [`freezed_annotation`](https://pub.dev/packages/freezed_annotation) `^3.1.0`
- [`talker_flutter`](https://pub.dev/packages/talker_flutter) `^5.1.13`

### Code generation

This package uses [freezed](https://pub.dev/packages/freezed) for the `Result` and `UiEffect` models. If you modify those files, regenerate with:

```sh
dart run build_runner build --delete-conflicting-outputs
```

---

## License

BSD 3-Clause — see [LICENSE](LICENSE) for details.

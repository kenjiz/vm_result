# vm_result

A minimal, production-grade MVVM ViewModel contract for Flutter.

**[📖 Read the Documentation Website](https://kenjiz.github.io/vm_result/)**

---

`vm_result` provides a typed `Result<T>` state model and a `ChangeNotifier`-based `VMResult<S>` base class that eliminates boilerplate for async state management. It enforces a clear contract: every async operation is represented as one of four states — `initial`, `loading`, `data`, or `error` — and gives you guard helpers that handle transitions automatically.

---

## Features

- **`Result<T>`** — A freezed sealed class representing the four lifecycle states of an async value.
- **`ValueResult<T>`** — A lightweight success/failure type for operations where you need to branch on the outcome.
- **`PaginatedResult<T>`** — A freezed model for accumulated paginated list state (items, page, hasNextPage, isLoadingMore).
- **`VMResult<S>`** — Abstract `ChangeNotifier` ViewModel base class backed by `ValueListenable<Result<S>>`.
- **`VMPaginated<S>`** — Extends `VMResult` with built-in `loadFirst`, `loadMore`, and `refresh` pagination logic.
- **`VMResultEffect<S, UE>`** — Extends `VMResult` with a broadcast `Stream` for one-shot UI side effects.
- **`runStream`** — Subscribe to a long-lived `Stream<S>` (WebSocket, Firestore, SSE) directly from a ViewModel with automatic loading/error state management and dispose-safe teardown.- **`ResultBuilder<T>`** — A thin `ValueListenableBuilder` wrapper for reactive UI.
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
result.errorAs<E>() // E? — cast exception to E if matches, else null
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

result.isSuccess    // bool
result.isFailure    // bool
result.data         // T?
result.failure      // Exception?
result.errorAs<E>() // E? — cast failure to E if matches, else null
```

---

### Handling Custom Exceptions

In many projects, you might define a custom exception hierarchy, such as:

```dart
class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkFailure extends AppException {
  const NetworkFailure() : super('Connection error');
}
```

Since `Result.error` and `ValueResult.failure` accept the standard `Exception` class, custom exceptions are fully supported (as they extend `Exception`). 

To easily extract and cast custom exceptions in your UI/logic without manually casting, use the `errorAs<E>()` helper method on both `Result` and `ValueResult`:

```dart
// Result
if (result.hasError) {
  final appException = result.errorAs<AppException>();
  if (appException != null) {
    print(appException.message);
  }
}

// ValueResult
result.when(
  success: (data) => handleSuccess(data),
  failure: (exception) {
    // Cast explicitly using errorAs:
    final appException = result.errorAs<AppException>();
    
    // Or pattern match on the exception directly:
    switch (exception) {
      case NetworkFailure():
        showToast('No internet connection');
      default:
        showToast(exception.toString());
    }
  },
);
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

| Method                                   | Loading state | Returns                  | Use when                                                |
| ---------------------------------------- | ------------- | ------------------------ | ------------------------------------------------------- |
| `run(action)`                            | Yes           | `Future<void>`           | Standard async fetch                                    |
| `runWithValueResult(action)`             | Yes           | `Future<ValueResult<S>>` | Need to branch on success/failure (e.g., navigation)    |
| `runSilent(action)`                      | No            | `Future<void>`           | Background updates (auto-save, background sync)         |
| `runOptimistic(optimisticState, action)` | No            | `Future<void>`           | Instant feedback with automatic rollback on failure     |
| `runLatest(action)`                      | Yes           | `Future<void>`           | Search-as-you-type; only the most recent result applies |
| `runStream(factory)`                     | Yes (once)    | `void`                   | Long-lived streams (WebSocket, Firestore, SSE)          |
| `cancelStream()`                         | —             | `Future<void>`           | Explicit disconnect while preserving current state      |

**Deduplication behaviour:**

- `run`, `runWithValueResult`, `runSilent`, and `runOptimistic` **drop** any call made while `isExecuting` is `true`. A debug warning is logged for each dropped call.
- `runLatest` uses **cancel-and-replace** semantics. Every call is allowed through, but results from superseded in-flight calls are silently discarded via an internal generation counter. `isExecuting` stays `true` until the most recently dispatched call settles.

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

### `runStream` — Real-Time / Long-Lived Streams

Use `runStream` when your data source is a `Stream<S>` that emits values continuously — WebSocket connections, Firestore `snapshots()`, SSE feeds, Bluetooth characteristic notifications, etc.

```dart
class ChatViewModel extends VMResult<List<Message>> {
  ChatViewModel(this._socket) : super(const Result.initial());

  final ChatSocket _socket;

  void connect() => runStream(() => _socket.messageStream);
  Future<void> disconnect() => cancelStream();
}
```

**Behaviour:**

| Event                   | State transition                              |
| ----------------------- | --------------------------------------------- |
| Subscription opens      | `ResultLoading` (once)                        |
| Each emitted event      | `ResultData(event)`                           |
| Stream error            | `ResultError` + subscription cancelled        |
| Stream closes (onDone)  | Last `ResultData` kept; `isExecuting → false` |
| `cancelStream()` called | Last state preserved; `isExecuting → false`   |
| `dispose()` called      | Subscription cancelled automatically          |

**Reconnect / source-swap:** Calling `runStream` while already subscribed replaces the active subscription — no manual `cancelStream()` needed first.

```dart
// Reconnect on network restore — just call connect() again
void onNetworkRestored() => connect();
```

---

### `VMPaginated<S>`

Extends `VMResult<PaginatedResult<S>>` with built-in pagination logic. Implement one abstract method — `fetchPage(int page)` — and get `loadFirst`, `loadMore`, and `refresh` for free.

```dart
class PostsViewModel extends VMPaginated<Post> {
  PostsViewModel(this._repository);

  final PostRepository _repository;

  @override
  Future<PageResult<Post>> fetchPage(int page) async {
    final response = await _repository.getPosts(page: page);
    return PageResult(
      items: response.posts,
      hasNextPage: response.hasNextPage,
    );
  }
}
```

| Method        | Loading state | Returns                                   | Use when                |
| ------------- | ------------- | ----------------------------------------- | ----------------------- |
| `loadFirst()` | Full          | `Future<void>`                            | Initial load            |
| `loadMore()`  | Inline only   | `Future<ValueResult<PaginatedResult<S>>>` | Appending the next page |
| `refresh()`   | Full          | `Future<void>`                            | Pull-to-refresh         |

**`loadMore` error handling:** on failure the existing item list is preserved. `isLoadingMore` is reset to `false` and a `ValueResult.failure` is returned so the caller can show a toast or inline error — the full `Result.error` state is intentionally not set.

```dart
// In your widget:
Future<void> _onScrolledToEnd() async {
  final result = await _vm.loadMore();
  result.whenOrNull(
    failure: (e) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString()))),
  );
}
```

The `PaginatedResult<T>` state is rendered via `ResultBuilder` like any other `VMResult`:

```dart
ResultBuilder<PaginatedResult<Post>>(
  listenable: viewModel,
  builder: (context, result, _) => result.when(
    initial: () => const SizedBox.shrink(),
    loading: () => const Center(child: CircularProgressIndicator()),
    error:   (error) => ErrorView(error: error),
    data: (paginated) => ListView.builder(
      itemCount: paginated.items.length + (paginated.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == paginated.items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return PostTile(post: paginated.items[index]);
      },
    ),
  ),
);
```

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
  └── VMPaginated<S>         — ViewModel for paginated lists
        └── VMResult<S>      — base ViewModel (ChangeNotifier + ValueListenable)
                               Future guards: run / runSilent / runOptimistic / runWithValueResult
                               Search guard:  runLatest (cancel-and-replace)
                               Stream guard:  runStream / cancelStream (long-lived streams)

Model Layer
  └── Result<T>              — 4-state async value (initial/loading/data/error)
  └── PaginatedResult<T>     — accumulated paginated list state
  └── PageResult<T>          — single-page DTO from fetchPage
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

This package uses [freezed](https://pub.dev/packages/freezed) for the `Result`, `UiEffect`, and `PaginatedResult` models. If you modify those files, regenerate with:

```sh
dart run build_runner build --delete-conflicting-outputs
```

---

## License

BSD 3-Clause — see [LICENSE](LICENSE) for details.

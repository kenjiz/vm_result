---
name: vm-result
description: >
  Use the vm_result package for Flutter MVVM state management. Covers Result types,
  ViewModel guard methods (run, runSilent, runOptimistic, runLatest, runStream),
  pagination (VMPaginated), UI side effects (VMResultEffect + EffectListener),
  reactive widgets (ResultBuilder), custom logging, and testing patterns.
  Triggers: "vm_result", "VMResult", "ViewModel", "Result state", "guard method",
  "runOptimistic", "runLatest", "runStream", "VMPaginated", "VMResultEffect",
  "EffectListener", "ResultBuilder", "async state management Flutter".
---

# vm_result — Flutter MVVM State Management

Use this skill when implementing ViewModels, async state management, pagination,
real-time streams, or UI side effects in a Flutter project that uses `vm_result`.

> **Source of truth**: Always cross-reference against the actual source code in
> the workspace. This skill reflects vm_result v0.1.2. If the API has changed,
> defer to the live code.

## Package Overview

`vm_result` is a minimal, production-grade MVVM ViewModel contract for Flutter.
It provides:

- **`Result<T>`** — A 4-state sealed class: `initial`, `loading`, `data`, `error`
- **`ValueResult<T>`** — A 2-state sealed class: `success`, `failure`
- **`VMResult<S>`** — Abstract `ChangeNotifier` ViewModel with async guard methods
- **`VMPaginated<S>`** — Paginated list ViewModel with `loadFirst`, `loadMore`, `refresh`
- **`VMResultEffect<S, UE>`** — ViewModel with a broadcast stream for one-shot UI effects
- **`ResultBuilder<T>`** — Reactive `ValueListenableBuilder` wrapper for UI rendering
- **`EffectListener<VM, S, UE>`** — Widget that subscribes to the effect stream

Import: `import 'package:vm_result/vm_result.dart';`

---

## Architecture Layers

```
Widget Layer
  └── ResultBuilder<T>           — reactive state → UI
  └── EffectListener<VM, S, UE>  — one-shot side-effects → UI

ViewModel Layer
  └── VMResultEffect<S, UE>     — state + effects
  └── VMPaginated<S>            — paginated lists
        └── VMResult<S>         — base (ChangeNotifier + ValueListenable<Result<S>>)
              Guards: run / runSilent / runOptimistic / runWithValueResult
              Search: runLatest (cancel-and-replace)
              Stream: runStream / cancelStream

Model Layer
  └── Result<T>             — initial / loading / data / error
  └── PaginatedResult<T>    — items + page + hasNextPage + isLoadingMore
  └── PageResult<T>         — single-page DTO (items + hasNextPage)
  └── ValueResult<T>        — success / failure
  └── BaseUiEffect          — effect contract base class
  └── UiEffect              — built-in showMessage / isProcessing variants
```

---

## Guard Method Decision Tree

Use this to pick the correct guard for each use case:

```
Is it a long-lived stream (WebSocket, Firestore, SSE)?
  └─ YES → runStream(factory)
  └─ NO ↓

Is it search-as-you-type / only-latest-matters?
  └─ YES → runLatest(action)
  └─ NO ↓

Do you need to branch on success/failure (navigate, show dialog)?
  └─ YES → runWithValueResult(action)
  └─ NO ↓

Should the user see a loading spinner?
  └─ NO → Is there an optimistic local state to show immediately?
       └─ YES → runOptimistic(optimisticState: ..., action: ...)
       └─ NO  → runSilent(action)
  └─ YES → run(action)
```

### Guard Matrix (Quick Reference)

| Guard | Loading? | Dedup Strategy | Returns | Use Case |
|-------|----------|---------------|---------|----------|
| `run` | Yes | Drop duplicate | `Future<void>` | Standard fetch |
| `runWithValueResult` | Yes | Drop duplicate | `Future<ValueResult<S>>` | Branch on outcome |
| `runSilent` | No | Drop duplicate | `Future<void>` | Background sync/save |
| `runOptimistic` | No | Drop duplicate | `Future<void>` | Instant UI + rollback |
| `runLatest` | Yes | Cancel-replace | `Future<void>` | Search typeahead |
| `runStream` | Yes (once) | Cancel-replace | `void` | Real-time streams |

---

## Implementation Patterns

### Pattern 1: Simple Fetch ViewModel

```dart
class UserViewModel extends VMResult<User> {
  UserViewModel(this._repo) : super(const Result.initial());
  final UserRepository _repo;

  Future<void> load(String id) => run(() => _repo.getUser(id));
}
```

### Pattern 2: Submit with Navigation

```dart
class LoginViewModel extends VMResult<User> {
  LoginViewModel(this._auth) : super(const Result.initial());
  final AuthService _auth;

  Future<void> login(String email, String pass) async {
    final result = await runWithValueResult(
      () => _auth.login(email, pass),
    );
    result.when(
      success: (_) => navigateToHome(),
      failure: (e) => showErrorDialog(e.toString()),
    );
  }
}
```

### Pattern 3: Background Save (No Spinner)

```dart
Future<void> autoSave(Settings s) => runSilent(
  () => _repo.saveSettings(s),
);
```

### Pattern 4: Optimistic Update with Rollback

```dart
Future<void> toggleLike(Post post) {
  final optimistic = post.copyWith(isLiked: !post.isLiked);
  return runOptimistic(
    optimisticState: optimistic,
    action: () => _repo.toggleLike(post.id),
  );
}
```

### Pattern 5: Search-as-you-type

```dart
Future<void> search(String query) => runLatest(
  () => _searchApi.find(query),
);
```

### Pattern 6: Real-time Stream (WebSocket / Firestore)

```dart
class ChatViewModel extends VMResult<List<Message>> {
  ChatViewModel(this._socket) : super(const Result.initial());
  final ChatSocket _socket;

  void connect() => runStream(() => _socket.messageStream);
  Future<void> disconnect() => cancelStream();
}
```

### Pattern 7: Paginated List

```dart
class PostsViewModel extends VMPaginated<Post> {
  PostsViewModel(this._repo);
  final PostRepository _repo;

  @override
  Future<PageResult<Post>> fetchPage(int page) async {
    final response = await _repo.getPosts(page: page, limit: 20);
    return PageResult(
      items: response.posts,
      hasNextPage: response.hasNextPage,
    );
  }
}
```

### Pattern 8: ViewModel with UI Effects

```dart
// 1. Define effects
sealed class AuthEffect extends BaseUiEffect {
  const AuthEffect();
}
class NavigateToHome extends AuthEffect { const NavigateToHome(); }
class ShowError extends AuthEffect {
  const ShowError(this.message);
  final String message;
}

// 2. ViewModel
class AuthViewModel extends VMResultEffect<User, AuthEffect> {
  AuthViewModel(this._repo) : super(const Result.initial());
  final AuthRepository _repo;

  Future<void> login(String email, String pass) async {
    final result = await runWithValueResult(
      () => _repo.login(email, pass),
    );
    result.when(
      success: (_) => emitEffect(const NavigateToHome()),
      failure: (e) => emitEffect(ShowError(e.toString())),
    );
  }
}
```

---

## Widget Integration

### ResultBuilder — Reactive State Rendering

```dart
ResultBuilder<User>(
  listenable: viewModel,
  builder: (context, result, child) => result.when(
    initial: () => const SizedBox.shrink(),
    loading: () => const Center(child: CircularProgressIndicator()),
    data:    (user) => UserProfile(user: user),
    error:   (e) => ErrorView(error: e, onRetry: viewModel.load),
  ),
)
```

**Optimization**: Use the `child` parameter for expensive subtrees that
don't depend on the result state:

```dart
ResultBuilder<User>(
  listenable: viewModel,
  child: const ExpensiveStaticWidget(), // built once
  builder: (context, result, child) => Column(
    children: [
      child!, // reused across rebuilds
      result.when(/* ... */),
    ],
  ),
)
```

### EffectListener — One-shot Side Effects

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
)
```

### Paginated ListView

```dart
// In initState:
_scrollController = ScrollController()..addListener(_onScroll);
_viewModel.loadFirst();

void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    _viewModel.loadMore();
  }
}

// In build:
ResultBuilder<PaginatedResult<Post>>(
  listenable: _viewModel,
  builder: (context, state, _) => state.when(
    initial: () => const SizedBox.shrink(),
    loading: () => const Center(child: CircularProgressIndicator()),
    error:   (e) => ErrorView(error: e),
    data: (paginated) => RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: paginated.items.length +
            (paginated.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == paginated.items.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return PostTile(post: paginated.items[index]);
        },
      ),
    ),
  ),
)
```

---

## Screen Composition Template

Full-screen pattern combining state rendering + effect handling:

```dart
class FeatureScreen extends StatefulWidget {
  const FeatureScreen({super.key});
  @override
  State<FeatureScreen> createState() => _FeatureScreenState();
}

class _FeatureScreenState extends State<FeatureScreen> {
  late final FeatureViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = FeatureViewModel(context.read<FeatureRepository>());
    _vm.load();
  }

  @override
  void dispose() {
    _vm.dispose(); // ALWAYS dispose to prevent leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EffectListener<FeatureViewModel, FeatureState, FeatureEffect>(
      vm: _vm,
      listener: (context, effect) { /* handle one-shot effects */ },
      child: ResultBuilder<FeatureState>(
        listenable: _vm,
        builder: (context, result, _) => result.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          data:    (data) => FeatureContent(data: data),
          error:   (e) => ErrorView(error: e, onRetry: _vm.load),
        ),
      ),
    );
  }
}
```

---

## Custom Logging

Register a custom logger in `main.dart` before `runApp`:

```dart
// Contract
abstract class VMResultLogger {
  void info(String message);
  void warning(String message);
  void error(String message, [StackTrace? stackTrace]);
}

// Talker integration example
class TalkerVMLogger implements VMResultLogger {
  TalkerVMLogger(this.talker);
  final Talker talker;

  @override
  void info(String message) => talker.info(message);
  @override
  void warning(String message) => talker.warning(message);
  @override
  void error(String message, [StackTrace? stackTrace]) =>
      talker.handle(message, stackTrace, 'VMResult Error');
}

void main() {
  VMResultLogging.logger = TalkerVMLogger(Talker());
  runApp(const MyApp());
}
```

Default: `DefaultVMResultLogger` uses `dart:developer` logs in debug mode only.
In release/profile mode, all log calls are no-ops (zero overhead).

---

## Testing Guide

### Testing a VMResult ViewModel

```dart
// Create a concrete test subclass
class TestVM extends VMResult<String> {
  TestVM() : super(const Result.initial());

  Future<void> load() => run(() async => 'hello');
  Future<void> fail() => run(() async => throw Exception('boom'));
}

test('run transitions through loading → data', () async {
  final vm = TestVM();
  final states = <Result<String>>[];
  vm.addListener(() => states.add(vm.value));

  await vm.load();

  expect(states, [
    isA<ResultLoading<String>>(),
    isA<ResultData<String>>(),
  ]);
  expect(vm.value, const Result.data('hello'));
  vm.dispose();
});

test('run transitions through loading → error on failure', () async {
  final vm = TestVM();
  await vm.fail();
  expect(vm.value, isA<ResultError<String>>());
  vm.dispose();
});
```

### Testing VMResultEffect

```dart
test('emitEffect delivers to stream', () async {
  final vm = TestEffectVM();
  final effects = <TestEffect>[];
  vm.effects.listen(effects.add);

  vm.emitEffect(const TestEffect.success());

  await Future<void>.delayed(Duration.zero);
  expect(effects, [const TestEffect.success()]);
  vm.dispose();
});
```

### Testing VMPaginated

```dart
test('loadFirst populates items', () async {
  final vm = TestPaginatedVM();
  await vm.loadFirst();

  final data = vm.value as ResultData<PaginatedResult<String>>;
  expect(data.value.items, isNotEmpty);
  expect(data.value.page, 1);
  vm.dispose();
});
```

### Widget Testing with ResultBuilder

```dart
testWidgets('ResultBuilder rebuilds on state change', (tester) async {
  final vm = TestVM();

  await tester.pumpWidget(
    MaterialApp(
      home: ResultBuilder<String>(
        listenable: vm,
        builder: (_, result, __) => result.when(
          initial: () => const Text('initial'),
          loading: () => const Text('loading'),
          data:    (d) => Text('data: $d'),
          error:   (e) => Text('error: $e'),
        ),
      ),
    ),
  );

  expect(find.text('initial'), findsOneWidget);

  vm.load();
  await tester.pump();
  expect(find.text('loading'), findsOneWidget);

  await tester.pumpAndSettle();
  expect(find.text('data: hello'), findsOneWidget);

  vm.dispose();
});
```

---

## Critical Rules

1. **Always dispose ViewModels** in the widget's `dispose()` method. Forgetting
   this causes memory leaks. All guards silently drop post-dispose updates.

2. **Guard methods are `@protected`**. Call them from within the ViewModel
   subclass, not from the widget layer. Expose named public methods instead:
   ```dart
   // ✅ Correct: Public method delegates to protected guard
   Future<void> load() => run(() => _repo.fetch());

   // ❌ Wrong: Calling run directly from widget
   vm.run(() => repo.fetch()); // Won't compile — run is protected
   ```

3. **Never store transient events in Result state**. Use `VMResultEffect` +
   `emitEffect()` for toasts, navigation, dialogs. Storing them as state causes
   re-firing on rebuilds.

4. **Choose the right guard**. Using `run()` for search input causes
   dropped keystrokes. Use `runLatest()` instead. Using `run()` for
   auto-save blocks the UI with a spinner. Use `runSilent()` instead.

5. **Deduplication is automatic**. `run`, `runWithValueResult`, `runSilent`,
   and `runOptimistic` all drop calls while `isExecuting` is true. Don't add
   your own dedup checks on top.

6. **`runLatest` does NOT drop calls**. It uses cancel-and-replace via a
   generation counter. Every call goes through; only stale results are discarded.

7. **`runStream` replaces active subscriptions**. Calling it again cancels
   the old subscription automatically. No need for manual `cancelStream()` first.

8. **`Result<T>` errors require `Exception`**, not `Error`. The guards catch
   `Exception` and rethrow `Error`. Design your failure types as Exceptions.

9. **`loadMore()` preserves the list on failure**. It returns
   `ValueResult.failure` and resets `isLoadingMore` to false without entering
   `Result.error`. The existing items stay visible.

10. **Start ViewModels with `Result.initial()`** unless you have pre-loaded
    data. Use `Result.data(preloaded)` only when the data is synchronously
    available at construction time.

---

## Anti-Patterns to Avoid

| Anti-pattern | Why it's wrong | Correct approach |
|---|---|---|
| Calling `setData`/`setError` from widget | Guards handle this automatically | Use `run()` or other guards |
| Manual `try/catch` around `run()` | `run` already catches exceptions | Let the guard handle it |
| Adding dedup logic before `run()` | Guards already deduplicate | Remove manual checks |
| Using `run()` for search input | Drops intermediate queries | Use `runLatest()` |
| Using `run()` for background save | Shows unnecessary spinner | Use `runSilent()` |
| Storing snackbar/navigation in state | Re-fires on rebuild | Use `emitEffect()` |
| Forgetting `vm.dispose()` | Memory leak, stale listeners | Always dispose in widget's `dispose()` |
| Extending `VMResult` and `VMResultEffect` for same VM | Effect stream not available | Pick `VMResultEffect` when you need effects |
| Not handling initial state in `when()` | Build error or assertion fail | Always handle all 4 states |

---

## ViewModel Type Decision Tree

```
Does the screen need paginated list loading?
  └─ YES → VMPaginated<ItemType>
  └─ NO ↓

Does the screen need one-shot UI side effects (toast, navigation, dialog)?
  └─ YES → VMResultEffect<StateType, EffectType>
  └─ NO  → VMResult<StateType>
```

## File Organization Convention

```
lib/
  features/
    auth/
      models/
        auth_effect.dart          # sealed class AuthEffect extends BaseUiEffect
      view_models/
        auth_view_model.dart      # extends VMResultEffect<User, AuthEffect>
      views/
        login_screen.dart         # StatefulWidget with EffectListener + ResultBuilder
    posts/
      models/
        post.dart
      view_models/
        posts_view_model.dart     # extends VMPaginated<Post>
      views/
        posts_screen.dart
```

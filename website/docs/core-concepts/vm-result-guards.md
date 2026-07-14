---
sidebar_position: 2
---

# ViewModel Guard Methods

`VMResult<S>` provides six guard methods designed to safely wrap asynchronous operations. They handle loading states, try-catch exception handling, deduplication, cancel-and-replace semantics, and optimistic rollbacks automatically.

---

## The Guard Matrix

| Guard Method | Loading State? | Deduplication Strategy | Use Case |
| :--- | :--- | :--- | :--- |
| **`run(action)`** | 🟢 Yes | 🚫 Drops duplicate calls | Standard loading fetches |
| **`runWithValueResult(action)`** | 🟢 Yes | 🚫 Drops duplicate calls | Submissions requiring branching logic |
| **`runSilent(action)`** | 🔴 No | 🚫 Drops duplicate calls | Background saves/syncs |
| **`runOptimistic(state, action)`** | 🔴 No | 🚫 Drops duplicate calls | Fast local changes with rollback |
| **`runLatest(action)`** | 🟢 Yes | 🔄 Cancel-and-replace | Search-as-you-type inputs |
| **`runStream(factory)`** | 🟢 Yes (once) | 🔄 Cancel-and-replace | WebSocket / Firebase subscriptions |

---

## 1. `run` (Standard Async Fetch)

`run` is the most common guard. It shows a loading state, runs the task, and sets the state to data or error.

```dart
Future<void> loadUserProfile(String userId) {
  return run(() => userRepository.getUser(userId));
}
```
* **Reactivity:** Sets state to `Result.loading()`, then either `Result.data(user)` or `Result.error(exception)`.
* **Deduplication:** If `loadUserProfile` is called while the operation is in progress, the second call is silently dropped to save network bandwidth.

---

## 2. `runWithValueResult` (Branching Logic)

`runWithValueResult` transitions the state to loading but returns a `ValueResult<S>` upon completion, allowing you to run conditional logic (like navigation) in the UI or ViewModel.

```dart
Future<void> login(String email, String password) async {
  final outcome = await runWithValueResult(() => authService.login(email, password));
  
  outcome.when(
    success: (user) => navigateToHome(user),
    failure: (error) => showMessage(error.toString()),
  );
}
```

---

## 3. `runSilent` (Background Updates)

`runSilent` executes the operation and updates the state *without* entering the `ResultLoading` state. This prevents full-screen loading spinners from blocking the user during background synchronization.

```dart
Future<void> autoSaveSettings(Settings settings) {
  return runSilent(() => settingsRepository.save(settings));
}
```
* **Reactivity:** Keeps the current data visible. Once completed, transitions the state directly to `Result.data(updatedSettings)` or `Result.error(exception)`.

---

## 4. `runOptimistic` (Immediate UI updates + Rollback)

`runOptimistic` lets you apply a local change to the state immediately before waiting for the server to confirm it. If the server request fails, the ViewModel automatically rolls back the state to the exact value it held prior to the change.

```dart
Future<void> toggleLike(Post post) {
  final optimisticPost = post.copyWith(isLiked: !post.isLiked);
  
  return runOptimistic(
    optimisticState: currentPostState.copyWith(post: optimisticPost),
    action: () => postRepository.likePost(post.id),
  );
}
```
* **Reactivity:** Immediately updates the UI with `optimisticState`. If the network call fails, it restores the previous state, transitions to `Result.error(exception)`, and notifies listeners.

---

## 5. `runLatest` (Search-as-you-Type)

`runLatest` is designed for search inputs, typeaheads, or any scenario where the user triggers multiple requests in rapid succession, but only the most recent one matters.

```dart
Future<void> search(String query) {
  return runLatest(() => searchApi.find(query));
}
```
* **Cancel-and-Replace:** It does **not** drop subsequent calls. Instead, it lets all calls run but uses an internal generation counter. If a newer search query completes before an older one, the older result is silently discarded, preventing race conditions (stale data overwriting fresh data).

---

## 6. `runStream` & `cancelStream` (Streaming Data)

`runStream` connects your ViewModel to a long-lived stream (e.g. WebSocket messages, Firestore real-time queries).

```dart
void connectToChat(String channelId) {
  runStream(() => chatService.messageStream(channelId));
}

Future<void> disconnect() => cancelStream();
```
* **Reactivity:** Transitions to `Result.loading()` once when starting. Every event emitted by the stream updates the state to `Result.data(event)`. If the stream throws an error, the subscription is closed and the state changes to `Result.error(exception)`.
* **Safe Subscriptions:** Calling `runStream` again automatically cancels the active stream subscription first—meaning you don't need manual teardown for reconnects or channel swaps.
* **Leak Protection:** Exiting the screen and calling `viewModel.dispose()` automatically cancels any active stream subscription.

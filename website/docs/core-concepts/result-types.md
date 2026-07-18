---
sidebar_position: 1
---

# Result and ValueResult Types

`vm_result` provides two sealed container types to represent the outcome of operations: `Result<T>` for UI-driven state, and `ValueResult<T>` for branching business logic.

---

## 1. `Result<T>`

`Result<T>` is a sealed class representing the lifecycle of an asynchronous operation. It can be in one of four states:

| State | Factory | Meaning |
| :--- | :--- | :--- |
| **Initial** | `Result.initial()` | Idle state, before an action has begun. |
| **Loading** | `Result.loading()` | The operation is actively in-flight. |
| **Data** | `Result.data(T value)` | The operation completed successfully with a value. |
| **Error** | `Result.error(Exception error)` | The operation failed with an exception. |

### Convenience Getters
`Result<T>` exposes simple getters to safely inspect the current state without manual type checking:

```dart
final Result<String> result = ...;

result.isInitial;     // true if state is Initial
result.isLoading;     // true if state is Loading
result.hasError;      // true if state is Error
result.hasValue;      // true if state is Data

// Safe type casting: returns null if the state does not match
result.value;         // returns String? (null if not Data)
result.errorValue;    // returns Exception? (null if not Error)
result.errorAs<E>();  // returns E? (cast exception to E if matches, else null)

result.asData;        // returns ResultData<String>?
result.asError;       // returns ResultError<String>?
result.asLoading;     // returns ResultLoading<String>?
result.asInitial;     // returns ResultInitial<String>?
```

### Pattern Matching (`when` & `maybeWhen`)
Because `Result<T>` is a sealed class, you can pattern match all states safely. The compiler will warn you if you miss a case.

#### Using `when` (Requires handling all cases):
```dart
Widget build(BuildContext context, Result<User> state) {
  return state.when(
    initial: () => const Text('Tap "Load" to start.'),
    loading: () => const CircularProgressIndicator(),
    data: (user) => Text('Hello, ${user.name}!'),
    error: (exception) => Text('Error: ${exception.toString()}'),
  );
}
```

#### Using `maybeWhen` (Allows specifying a fallback):
```dart
Widget build(BuildContext context, Result<User> state) {
  return state.maybeWhen(
    loading: () => const SmallSpinner(),
    orElse: () => const Text('Idle or loaded'),
  );
}
```

---

## 2. `ValueResult<T>`

While `Result<T>` is perfect for building UI screens, it is less suited for business logic decisions. For example, if a user logs in, you need to branch your logic: *if successful, navigate to Home; if failed, show an error dialog.*

`ValueResult<T>` is a two-state sealed container designed exactly for this:

| State | Factory | Meaning |
| :--- | :--- | :--- |
| **Success** | `ValueResult.success(T data)` | The operation was successful, carries the data. |
| **Failure** | `ValueResult.failure(Exception error)` | The operation failed, carries the exception. |

### When to use `ValueResult`
`ValueResult` is returned by the `runWithValueResult` guard. You handle the outcome using pattern matching:

```dart
Future<void> submitOrder() async {
  final result = await runWithValueResult(() => repository.placeOrder());
  
  result.when(
    success: (order) {
      // Transition UI to the success screen
      navigator.pushReplacementNamed('/order-success', arguments: order);
    },
    failure: (exception) {
      // Trigger a one-shot UI snackbar/effect
      emitEffect(ShowErrorSnackbar(exception.toString()));
    },
  );
}
```

### Convenience Getters
```dart
final ValueResult<User> result = ...;

result.isSuccess;    // true if success
result.isFailure;    // true if failure

result.data;         // returns T? (null if failure)
result.failure;      // returns Exception? (null if success)
result.errorAs<E>(); // returns E? (cast failure to E if matches, else null)
```

---

## 3. Handling Custom Exceptions

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

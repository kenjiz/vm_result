---
sidebar_position: 2
---

# Getting Started

This guide walks you through installing `vm_result` and building your first reactive ViewModel screen.

---

## 1. Installation

Add `vm_result` to your Flutter project's `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  vm_result: ^0.1.1 # Use the latest version
```

Or run the following command in your terminal:

```bash
flutter pub add vm_result
```

---

## 2. Basic Concepts

Every `vm_result` screen is built using two core objects:
1. **The ViewModel (`VMResult<T>`):** Manages your state and business logic. It exposes a single listenable `state` holding a `Result<T>`.
2. **The View Widget (`ResultBuilder<T>`):** Listens to your ViewModel's state and rebuilds the screen to match the active state (`initial`, `loading`, `data`, or `error`).

---

## 3. Create a ViewModel

Let's build a ViewModel that fetches a simple greeting message from an API.

Create a file `greeting_view_model.dart`:

```dart
import 'package:vm_result/vm_result.dart';

class GreetingViewModel extends VMResult<String> {
  // 1. Initialize the ViewModel with an initial state
  GreetingViewModel() : super(const Result.initial());

  // 2. Wrap async actions with the `run` guard
  Future<void> fetchGreeting() {
    return run(() async {
      // Simulate network latency
      await Future<void>.delayed(const Duration(seconds: 1));
      
      return 'Hello, Welcome to vm_result!';
    });
  }
}
```

### What happens here?
- `super(const Result.initial())` sets the state of the ViewModel to `ResultInitial` on startup.
- `run(...)` automatically manages the request lifecycle:
  1. Transitions state to `ResultLoading` and notifies the UI.
  2. Runs the async operation.
  3. If successful, transitions state to `ResultData(value)` and notifies the UI.
  4. If an exception is thrown, catches it, logs it, transitions state to `ResultError(exception)`, and notifies the UI.
  5. Drops duplicate concurrent calls if `fetchGreeting()` is pressed multiple times.

---

## 4. Bind to the UI

Create a widget that displays the greeting message and provides a refresh button.

```dart
import 'package:flutter/material.dart';
import 'package:vm_result/vm_result.dart';
import 'greeting_view_model.dart';

class GreetingScreen extends StatefulWidget {
  const GreetingScreen({super.key});

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {
  late final GreetingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GreetingViewModel();
    _viewModel.fetchGreeting(); // Fetch greeting on load
  }

  @override
  void dispose() {
    _viewModel.dispose(); // Always dispose ViewModels to prevent leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Greeting Screen')),
      body: Center(
        child: ResultBuilder<String>(
          listenable: _viewModel,
          builder: (context, state, child) {
            // Pattern match the 4 possible states
            return state.when(
              initial: () => const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(),
              data: (greeting) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(greeting, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _viewModel.fetchGreeting,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              error: (exception) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load greeting: $exception', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _viewModel.fetchGreeting,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

## Next Steps

Now that you have your first screen up and running, learn more about how `vm_result` manages state transitions and advanced async logic:
- Learn about the [Result and ValueResult Types](./core-concepts/result-types.md).
- Explore the [ViewModel Guards](./core-concepts/vm-result-guards.md) like optimistic updates and streaming.

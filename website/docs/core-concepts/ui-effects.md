---
sidebar_position: 4
---

# UI Side Effects

In a clean architecture, certain events are meant to trigger one-shot actions in the UI, rather than persisting in the screen's state. Examples include showing a snackbar, displaying a toast notification, popping up a dialog, or navigating to another screen.

If you store these events in your view state (e.g., setting `hasError: true` to show a snackbar), you have to write complex "state reset" logic after the snackbar dismisses. If the screen rotates, the snackbar might show again.

`VMResultEffect` solves this by providing a clean, stream-based **side-effect channel** alongside your normal view state.

---

## 1. Defining the Effects

All effects must inherit from the `BaseUiEffect` contract class. You can define your screen's effects using a sealed class:

```dart
import 'package:vm_result/vm_result.dart';

sealed class CheckoutEffect extends BaseUiEffect {
  const CheckoutEffect();
}

class ShowSuccessToast extends CheckoutEffect {
  const ShowSuccessToast(this.message);
  final String message;
}

class NavigateToReceipt extends CheckoutEffect {
  const NavigateToReceipt(this.orderId);
  final String orderId;
}
```

---

## 2. Emitting Effects in the ViewModel

To emit effects, extend `VMResultEffect<S, UE>` instead of `VMResult<S>`:

```dart
class CheckoutViewModel extends VMResultEffect<CheckoutState, CheckoutEffect> {
  CheckoutViewModel(this._repository) : super(const Result.initial());
  
  final CheckoutRepository _repository;

  Future<void> submitPayment() async {
    final outcome = await runWithValueResult(() => _repository.checkout());
    
    outcome.when(
      success: (receipt) {
        // Emit side effect for navigation
        emitEffect(NavigateToReceipt(receipt.id));
      },
      failure: (error) {
        // Emit side effect for notification
        emitEffect(ShowSuccessToast('Payment failed: ${error.toString()}'));
      },
    );
  }
}
```

* **Safety:** Effects emitted after the ViewModel is disposed are silently dropped to avoid exceptions, and warnings are printed in debug mode.

---

## 3. Listening to Effects in the UI

To receive side-effects, wrap your widget subtree with the `EffectListener` widget.

```dart
import 'package:flutter/material.dart';
import 'package:vm_result/vm_result.dart';
import 'checkout_view_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CheckoutViewModel(CheckoutRepository());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      // Wrap your screen structure with the EffectListener
      body: EffectListener<CheckoutViewModel, CheckoutState, CheckoutEffect>(
        vm: _viewModel,
        listener: (context, effect) {
          // React to one-shot actions cleanly
          switch (effect) {
            case ShowSuccessToast(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            case NavigateToReceipt(:final orderId):
              Navigator.of(context).pushReplacementNamed(
                '/receipt',
                arguments: orderId,
              );
          }
        },
        child: Center(
          child: ElevatedButton(
            onPressed: _viewModel.submitPayment,
            child: const Text('Submit Payment'),
          ),
        ),
      ),
    );
  }
}
```

### Why use `EffectListener`?
- **Lifecycle Bound:** It automatically handles stream subscription lifecycle hooks, subscribing in `initState` and canceling in `dispose` to prevent memory leaks.
- **Dynamic Swapping:** It implements `didUpdateWidget`. If your widget structure rebuilds and swaps the ViewModel instance, `EffectListener` automatically unsubscribes from the old stream and hooks into the new one.

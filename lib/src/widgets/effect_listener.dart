import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:vm_result/vm_result.dart';

/// A widget that listens to one-shot UI side effects emitted by a [VMResultEffect].
///
/// Use [EffectListener] to react to transient events (like showing a snackbar,
/// showing an alert dialog, or triggering navigation) that should not cause
/// the widget tree to rebuild.
class EffectListener<VM extends VMResultEffect<S, UE>, S, UE extends BaseUiEffect> extends StatefulWidget {
  /// Creates an [EffectListener] that monitors [vm] for new effects.
  ///
  /// Executes the [listener] callback when a new side effect is emitted.
  const EffectListener({required this.listener, required this.vm, required this.child, super.key});

  /// The ViewModel instance whose effects are being listened to.
  final VM vm;

  /// Callback function executed on the UI thread when a new effect is emitted.
  final void Function(BuildContext context, UE effect) listener;

  /// The child widget subtree built under this listener.
  final Widget child;

  @override
  State<EffectListener<VM, S, UE>> createState() => _EffectListenerState<VM, S, UE>();
}

class _EffectListenerState<VM extends VMResultEffect<S, UE>, S, UE extends BaseUiEffect>
    extends State<EffectListener<VM, S, UE>> {
  StreamSubscription<UE>? _effectSubscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant EffectListener<VM, S, UE> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm != widget.vm) {
      _unsubscribe();
      _subscribe();
    }
  }

  void _subscribe() {
    _effectSubscription = widget.vm.effects.listen(_onEffectsChanged);
  }

  void _unsubscribe() {
    _effectSubscription?.cancel();
    _effectSubscription = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _onEffectsChanged(UE effect) {
    widget.listener(context, effect);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

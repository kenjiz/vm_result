import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:vm_result/vm_result.dart';

class EffectListener<VM extends VMResultEffect<S, UE>, S, UE extends BaseUiEffect> extends StatefulWidget {
  const EffectListener({required this.listener, required this.vm, required this.child, super.key});

  final VM vm;
  final void Function(BuildContext context, UE effect) listener;
  final Widget child;

  @override
  State<EffectListener<VM, S, UE>> createState() => _EffectListenerState<VM, S, UE>();
}

class _EffectListenerState<VM extends VMResultEffect<S, UE>, S, UE extends BaseUiEffect>
    extends State<EffectListener<VM, S, UE>> {
  late final StreamSubscription<UE>? _effectSubscription;

  @override
  void initState() {
    super.initState();
    _effectSubscription = widget.vm.effects.listen(_onEffectsChanged);
  }

  @override
  void dispose() {
    _effectSubscription?.cancel();
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

import 'dart:async';

import 'package:vm_result/src/logging/vm_result_logger.dart';
import 'package:vm_result/src/models/ui_effect.dart';
import 'package:vm_result/src/vms/vm_result.dart';

abstract class VMResultEffect<S, UE extends BaseUiEffect> extends VMResult<S> {
  VMResultEffect(super.initial);

  final _effectsController = StreamController<UE>.broadcast();

  Stream<UE> get effects => _effectsController.stream;

  void emitEffect(UE effect) {
    if (disposed) {
      VMResultLogging.logger.warning('Attempted to emit effect on disposed ViewModel: $runtimeType: $effect');
      return;
    }
    _effectsController.add(effect);
  }

  @override
  void dispose() {
    _effectsController.close();
    super.dispose();
  }
}

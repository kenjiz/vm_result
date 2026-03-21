import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_effect.freezed.dart';

abstract class BaseUiEffect {
  const BaseUiEffect();
}

@Freezed(copyWith: false)
abstract class UiEffect extends BaseUiEffect with _$UiEffect {
  const factory UiEffect.showMessage(String message) = _UiEffectShowMessage;
  const factory UiEffect.isProcessing(bool isProcessing) = _UiEffectIsProcessing;
  const UiEffect._();
}

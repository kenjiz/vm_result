import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_effect.freezed.dart';

/// Base class for all UI side effects emitted from a [VMResultEffect] ViewModel.
///
/// UI effects are one-shot events meant to trigger temporary UI changes
/// like showing a snackbar, toast, alert, or executing navigation.
abstract class BaseUiEffect {
  /// Const constructor for subclasses.
  const BaseUiEffect();
}

/// A standard implementation of [BaseUiEffect] for common UI notifications.
@Freezed(copyWith: false)
abstract class UiEffect extends BaseUiEffect with _$UiEffect {
  /// Tells the UI to display a toast or snackbar message.
  const factory UiEffect.showMessage(String message) = _UiEffectShowMessage;

  /// Tells the UI to display or hide a global processing spinner/indicator.
  const factory UiEffect.isProcessing(bool isProcessing) = _UiEffectIsProcessing;

  const UiEffect._();
}

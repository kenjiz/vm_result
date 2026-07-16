/// Base class for all UI side effects emitted from a [VMResultEffect] ViewModel.
///
/// UI effects are one-shot events meant to trigger temporary UI changes
/// like showing a snackbar, toast, alert, or executing navigation.
abstract class BaseUiEffect {
  /// Const constructor for subclasses.
  const BaseUiEffect();
}

/// A standard implementation of [BaseUiEffect] for common UI notifications.
sealed class UiEffect extends BaseUiEffect {
  const UiEffect._();

  /// Tells the UI to display a toast or snackbar message.
  const factory UiEffect.showMessage(String message) = UiEffectShowMessage;

  /// Tells the UI to display or hide a global processing spinner/indicator.
  const factory UiEffect.isProcessing(bool isProcessing) = UiEffectIsProcessing;

  /// Exhaustive pattern matching.
  R when<R>({
    required R Function(String message) showMessage,
    required R Function(bool isProcessing) isProcessing,
  }) {
    return switch (this) {
      UiEffectShowMessage(message: final msg) => showMessage(msg),
      UiEffectIsProcessing(isProcessing: final val) => isProcessing(val),
    };
  }

  /// Exhaustive pattern matching with a fallback.
  R maybeWhen<R>({
    R Function(String message)? showMessage,
    R Function(bool isProcessing)? isProcessing,
    required R Function() orElse,
  }) {
    return switch (this) {
      UiEffectShowMessage(message: final msg) => showMessage != null ? showMessage(msg) : orElse(),
      UiEffectIsProcessing(isProcessing: final val) => isProcessing != null ? isProcessing(val) : orElse(),
    };
  }

  /// Exhaustive pattern matching with a fallback returning null.
  R? whenOrNull<R>({
    R? Function(String message)? showMessage,
    R? Function(bool isProcessing)? isProcessing,
  }) {
    return switch (this) {
      UiEffectShowMessage(message: final msg) => showMessage?.call(msg),
      UiEffectIsProcessing(isProcessing: final val) => isProcessing?.call(val),
    };
  }
}

/// The showMessage UI effect subclass.
class UiEffectShowMessage extends UiEffect {
  /// The message to display.
  final String message;

  /// Creates a [UiEffectShowMessage].
  const UiEffectShowMessage(this.message) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UiEffectShowMessage &&
          other.runtimeType == runtimeType &&
          other.message == message);

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'UiEffect.showMessage(message: $message)';
}

/// The isProcessing UI effect subclass.
class UiEffectIsProcessing extends UiEffect {
  /// Whether processing is in-flight.
  final bool isProcessing;

  /// Creates a [UiEffectIsProcessing].
  const UiEffectIsProcessing(this.isProcessing) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UiEffectIsProcessing &&
          other.runtimeType == runtimeType &&
          other.isProcessing == isProcessing);

  @override
  int get hashCode => isProcessing.hashCode;

  @override
  String toString() => 'UiEffect.isProcessing(isProcessing: $isProcessing)';
}

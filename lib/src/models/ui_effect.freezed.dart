// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_effect.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UiEffect {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UiEffect);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UiEffect()';
}


}




/// Adds pattern-matching-related methods to [UiEffect].
extension UiEffectPatterns on UiEffect {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _UiEffectShowMessage value)?  showMessage,TResult Function( _UiEffectIsProcessing value)?  isProcessing,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UiEffectShowMessage() when showMessage != null:
return showMessage(_that);case _UiEffectIsProcessing() when isProcessing != null:
return isProcessing(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _UiEffectShowMessage value)  showMessage,required TResult Function( _UiEffectIsProcessing value)  isProcessing,}){
final _that = this;
switch (_that) {
case _UiEffectShowMessage():
return showMessage(_that);case _UiEffectIsProcessing():
return isProcessing(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _UiEffectShowMessage value)?  showMessage,TResult? Function( _UiEffectIsProcessing value)?  isProcessing,}){
final _that = this;
switch (_that) {
case _UiEffectShowMessage() when showMessage != null:
return showMessage(_that);case _UiEffectIsProcessing() when isProcessing != null:
return isProcessing(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message)?  showMessage,TResult Function( bool isProcessing)?  isProcessing,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UiEffectShowMessage() when showMessage != null:
return showMessage(_that.message);case _UiEffectIsProcessing() when isProcessing != null:
return isProcessing(_that.isProcessing);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message)  showMessage,required TResult Function( bool isProcessing)  isProcessing,}) {final _that = this;
switch (_that) {
case _UiEffectShowMessage():
return showMessage(_that.message);case _UiEffectIsProcessing():
return isProcessing(_that.isProcessing);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message)?  showMessage,TResult? Function( bool isProcessing)?  isProcessing,}) {final _that = this;
switch (_that) {
case _UiEffectShowMessage() when showMessage != null:
return showMessage(_that.message);case _UiEffectIsProcessing() when isProcessing != null:
return isProcessing(_that.isProcessing);case _:
  return null;

}
}

}

/// @nodoc


class _UiEffectShowMessage extends UiEffect {
  const _UiEffectShowMessage(this.message): super._();
  

 final  String message;




@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UiEffectShowMessage&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'UiEffect.showMessage(message: $message)';
}


}




/// @nodoc


class _UiEffectIsProcessing extends UiEffect {
  const _UiEffectIsProcessing(this.isProcessing): super._();
  

 final  bool isProcessing;




@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UiEffectIsProcessing&&(identical(other.isProcessing, isProcessing) || other.isProcessing == isProcessing));
}


@override
int get hashCode => Object.hash(runtimeType,isProcessing);

@override
String toString() {
  return 'UiEffect.isProcessing(isProcessing: $isProcessing)';
}


}




// dart format on

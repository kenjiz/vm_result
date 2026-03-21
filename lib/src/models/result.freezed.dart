// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Result<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Result<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Result<$T>()';
}


}

/// @nodoc
class $ResultCopyWith<T,$Res>  {
$ResultCopyWith(Result<T> _, $Res Function(Result<T>) __);
}


/// Adds pattern-matching-related methods to [Result].
extension ResultPatterns<T> on Result<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ResultInitial<T> value)?  initial,TResult Function( ResultData<T> value)?  data,TResult Function( ResultLoading<T> value)?  loading,TResult Function( ResultError<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ResultInitial() when initial != null:
return initial(_that);case ResultData() when data != null:
return data(_that);case ResultLoading() when loading != null:
return loading(_that);case ResultError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ResultInitial<T> value)  initial,required TResult Function( ResultData<T> value)  data,required TResult Function( ResultLoading<T> value)  loading,required TResult Function( ResultError<T> value)  error,}){
final _that = this;
switch (_that) {
case ResultInitial():
return initial(_that);case ResultData():
return data(_that);case ResultLoading():
return loading(_that);case ResultError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ResultInitial<T> value)?  initial,TResult? Function( ResultData<T> value)?  data,TResult? Function( ResultLoading<T> value)?  loading,TResult? Function( ResultError<T> value)?  error,}){
final _that = this;
switch (_that) {
case ResultInitial() when initial != null:
return initial(_that);case ResultData() when data != null:
return data(_that);case ResultLoading() when loading != null:
return loading(_that);case ResultError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( T value)?  data,TResult Function()?  loading,TResult Function( Exception error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ResultInitial() when initial != null:
return initial();case ResultData() when data != null:
return data(_that.value);case ResultLoading() when loading != null:
return loading();case ResultError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( T value)  data,required TResult Function()  loading,required TResult Function( Exception error)  error,}) {final _that = this;
switch (_that) {
case ResultInitial():
return initial();case ResultData():
return data(_that.value);case ResultLoading():
return loading();case ResultError():
return error(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( T value)?  data,TResult? Function()?  loading,TResult? Function( Exception error)?  error,}) {final _that = this;
switch (_that) {
case ResultInitial() when initial != null:
return initial();case ResultData() when data != null:
return data(_that.value);case ResultLoading() when loading != null:
return loading();case ResultError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ResultInitial<T> extends Result<T> {
  const ResultInitial(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultInitial<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Result<$T>.initial()';
}


}




/// @nodoc


class ResultData<T> extends Result<T> {
  const ResultData(this.value): super._();
  

 final  T value;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultDataCopyWith<T, ResultData<T>> get copyWith => _$ResultDataCopyWithImpl<T, ResultData<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultData<T>&&const DeepCollectionEquality().equals(other.value, value));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'Result<$T>.data(value: $value)';
}


}

/// @nodoc
abstract mixin class $ResultDataCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $ResultDataCopyWith(ResultData<T> value, $Res Function(ResultData<T>) _then) = _$ResultDataCopyWithImpl;
@useResult
$Res call({
 T value
});




}
/// @nodoc
class _$ResultDataCopyWithImpl<T,$Res>
    implements $ResultDataCopyWith<T, $Res> {
  _$ResultDataCopyWithImpl(this._self, this._then);

  final ResultData<T> _self;
  final $Res Function(ResultData<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? value = freezed,}) {
  return _then(ResultData<T>(
freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class ResultLoading<T> extends Result<T> {
  const ResultLoading(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultLoading<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Result<$T>.loading()';
}


}




/// @nodoc


class ResultError<T> extends Result<T> {
  const ResultError(this.error): super._();
  

 final  Exception error;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultErrorCopyWith<T, ResultError<T>> get copyWith => _$ResultErrorCopyWithImpl<T, ResultError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultError<T>&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'Result<$T>.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $ResultErrorCopyWith<T,$Res> implements $ResultCopyWith<T, $Res> {
  factory $ResultErrorCopyWith(ResultError<T> value, $Res Function(ResultError<T>) _then) = _$ResultErrorCopyWithImpl;
@useResult
$Res call({
 Exception error
});




}
/// @nodoc
class _$ResultErrorCopyWithImpl<T,$Res>
    implements $ResultErrorCopyWith<T, $Res> {
  _$ResultErrorCopyWithImpl(this._self, this._then);

  final ResultError<T> _self;
  final $Res Function(ResultError<T>) _then;

/// Create a copy of Result
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ResultError<T>(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Exception,
  ));
}


}

/// @nodoc
mixin _$ValueResult<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValueResult<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ValueResult<$T>()';
}


}

/// @nodoc
class $ValueResultCopyWith<T,$Res>  {
$ValueResultCopyWith(ValueResult<T> _, $Res Function(ValueResult<T>) __);
}


/// Adds pattern-matching-related methods to [ValueResult].
extension ValueResultPatterns<T> on ValueResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ValueResultSuccess<T> value)?  success,TResult Function( ValueResultFailure<T> value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ValueResultSuccess() when success != null:
return success(_that);case ValueResultFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ValueResultSuccess<T> value)  success,required TResult Function( ValueResultFailure<T> value)  failure,}){
final _that = this;
switch (_that) {
case ValueResultSuccess():
return success(_that);case ValueResultFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ValueResultSuccess<T> value)?  success,TResult? Function( ValueResultFailure<T> value)?  failure,}){
final _that = this;
switch (_that) {
case ValueResultSuccess() when success != null:
return success(_that);case ValueResultFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T data)?  success,TResult Function( Exception error)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ValueResultSuccess() when success != null:
return success(_that.data);case ValueResultFailure() when failure != null:
return failure(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T data)  success,required TResult Function( Exception error)  failure,}) {final _that = this;
switch (_that) {
case ValueResultSuccess():
return success(_that.data);case ValueResultFailure():
return failure(_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T data)?  success,TResult? Function( Exception error)?  failure,}) {final _that = this;
switch (_that) {
case ValueResultSuccess() when success != null:
return success(_that.data);case ValueResultFailure() when failure != null:
return failure(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ValueResultSuccess<T> extends ValueResult<T> {
  const ValueResultSuccess(this.data): super._();
  

 final  T data;

/// Create a copy of ValueResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValueResultSuccessCopyWith<T, ValueResultSuccess<T>> get copyWith => _$ValueResultSuccessCopyWithImpl<T, ValueResultSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValueResultSuccess<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'ValueResult<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $ValueResultSuccessCopyWith<T,$Res> implements $ValueResultCopyWith<T, $Res> {
  factory $ValueResultSuccessCopyWith(ValueResultSuccess<T> value, $Res Function(ValueResultSuccess<T>) _then) = _$ValueResultSuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$ValueResultSuccessCopyWithImpl<T,$Res>
    implements $ValueResultSuccessCopyWith<T, $Res> {
  _$ValueResultSuccessCopyWithImpl(this._self, this._then);

  final ValueResultSuccess<T> _self;
  final $Res Function(ValueResultSuccess<T>) _then;

/// Create a copy of ValueResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(ValueResultSuccess<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class ValueResultFailure<T> extends ValueResult<T> {
  const ValueResultFailure(this.error): super._();
  

 final  Exception error;

/// Create a copy of ValueResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValueResultFailureCopyWith<T, ValueResultFailure<T>> get copyWith => _$ValueResultFailureCopyWithImpl<T, ValueResultFailure<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValueResultFailure<T>&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ValueResult<$T>.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $ValueResultFailureCopyWith<T,$Res> implements $ValueResultCopyWith<T, $Res> {
  factory $ValueResultFailureCopyWith(ValueResultFailure<T> value, $Res Function(ValueResultFailure<T>) _then) = _$ValueResultFailureCopyWithImpl;
@useResult
$Res call({
 Exception error
});




}
/// @nodoc
class _$ValueResultFailureCopyWithImpl<T,$Res>
    implements $ValueResultFailureCopyWith<T, $Res> {
  _$ValueResultFailureCopyWithImpl(this._self, this._then);

  final ValueResultFailure<T> _self;
  final $Res Function(ValueResultFailure<T>) _then;

/// Create a copy of ValueResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ValueResultFailure<T>(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Exception,
  ));
}


}

// dart format on

import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// A [Result] is a utility for safely manipulating async data.
///
/// By using [Result], you are guaranteed that you cannot forget to
/// handle the loading/error state of an asynchronous operation.
@freezed
sealed class Result<T> with _$Result<T> {
  /// Creates a [Result] with initial state.
  const factory Result.initial() = ResultInitial<T>;

  /// Creates an [Result] with a data.
  const factory Result.data(T value) = ResultData<T>;

  /// Creates an [Result] in loading state.
  ///
  /// Prefer always using this constructor with the `const` keyword.
  const factory Result.loading() = ResultLoading<T>;

  /// Creates an [Result] in error state.
  const factory Result.error(Exception error) = ResultError<T>;

  const Result._();

  /// Upcast [Result] into an [ResultData], or return null if the [Result]
  /// is not a [ResultData].
  ResultData<T>? get asData => this is ResultData<T> ? this as ResultData<T> : null;

  /// Upcast [Result] into an [ResultError], or return null if the [Result]
  /// is not a [ResultError].
  ResultError<T>? get asError => this is ResultError<T> ? this as ResultError<T> : null;

  /// Upcast [Result] into an [ResultLoading], or return null if the [Result]
  /// is not a [ResultLoading].
  ResultLoading<T>? get asLoading => this is ResultLoading<T> ? this as ResultLoading<T> : null;

  /// Whether the associated value is in a loading state.
  bool get isLoading => this is ResultLoading<T>;

  /// Whether the associated value is in an error state.
  bool get hasError => this is ResultError<T>;

  /// Whether the associated value has data.
  bool get hasValue => this is ResultData<T>;

  /// The data value, or null if in loading or error state.
  T? get value => maybeWhen(
    data: (value) => value,
    orElse: () => null,
  );

  /// The error value, or null if in loading or data state.
  Exception? get errorValue => maybeWhen(
    error: (error) => error,
    orElse: () => null,
  );
}

/// Result type for operations that need explicit success/failure handling.
///
/// Example:
/// ```dart
/// final result = await runWithValueResult(() => repository.login());
/// result.when(
///   success: (user) => print('Logged in as ${user.name}'),
///   failure: (error) => print('Login failed: ${error.message}'),
/// );
/// ```
@freezed
sealed class ValueResult<T> with _$ValueResult<T> {
  /// Creates a successful result.
  const factory ValueResult.success(T data) = ValueResultSuccess<T>;

  /// Creates a failed result.
  const factory ValueResult.failure(Exception error) = ValueResultFailure<T>;

  const ValueResult._();

  /// Upcast [ValueResult] into a [ValueResultSuccess], or return null if the [ValueResult]
  /// is not a [ValueResultSuccess].
  ValueResultSuccess<T>? get asSuccess => this is ValueResultSuccess<T> ? this as ValueResultSuccess<T> : null;

  /// Upcast [ValueResult] into an [ValueResultFailure], or return null if the [ValueResult]
  /// is not a [ValueResultFailure].
  ValueResultFailure<T>? get asFailure => this is ValueResultFailure<T> ? this as ValueResultFailure<T> : null;

  /// Whether the associated value is in a failure state.
  bool get isFailure => this is ValueResultFailure<T>;

  /// Whether the associated value has data.
  bool get isSuccess => this is ValueResultSuccess<T>;

  /// The data value, or null if in loading or error state.
  T? get data => maybeWhen(
    success: (data) => data,
    orElse: () => null,
  );

  /// The error value, or null if in loading or data state.
  Exception? get failure => maybeWhen(
    failure: (error) => error,
    orElse: () => null,
  );
}

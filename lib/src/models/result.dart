/// A [Result] is a utility for safely manipulating async data.
///
/// By using [Result], you are guaranteed that you cannot forget to
/// handle the loading/error state of an asynchronous operation.
sealed class Result<T> {
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

  /// Returns the error cast to [E], or null if the error is not of type [E].
  E? errorAs<E extends Exception>() {
    final err = errorValue;
    return err is E ? err : null;
  }

  /// Exhaustive pattern matching.
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T value) data,
    required R Function(Exception error) error,
  }) {
    return switch (this) {
      ResultInitial() => initial(),
      ResultLoading() => loading(),
      ResultData(value: final val) => data(val),
      ResultError(error: final err) => error(err),
    };
  }

  /// Exhaustive pattern matching with a fallback.
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T value)? data,
    R Function(Exception error)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      ResultInitial() => initial != null ? initial() : orElse(),
      ResultLoading() => loading != null ? loading() : orElse(),
      ResultData(value: final val) => data != null ? data(val) : orElse(),
      ResultError(error: final err) => error != null ? error(err) : orElse(),
    };
  }

  /// Exhaustive pattern matching with a fallback returning null.
  R? whenOrNull<R>({
    R? Function()? initial,
    R? Function()? loading,
    R? Function(T value)? data,
    R? Function(Exception error)? error,
  }) {
    return switch (this) {
      ResultInitial() => initial?.call(),
      ResultLoading() => loading?.call(),
      ResultData(value: final val) => data?.call(val),
      ResultError(error: final err) => error?.call(err),
    };
  }

  /// Map over the underlying subclasses.
  R map<R>({
    required R Function(ResultInitial<T> value) initial,
    required R Function(ResultLoading<T> value) loading,
    required R Function(ResultData<T> value) data,
    required R Function(ResultError<T> value) error,
  }) {
    return switch (this) {
      ResultInitial<T> val => initial(val),
      ResultLoading<T> val => loading(val),
      ResultData<T> val => data(val),
      ResultError<T> val => error(val),
    };
  }

  /// Map over the underlying subclasses with a fallback.
  R maybeMap<R>({
    R Function(ResultInitial<T> value)? initial,
    R Function(ResultLoading<T> value)? loading,
    R Function(ResultData<T> value)? data,
    R Function(ResultError<T> value)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      ResultInitial<T> val => initial != null ? initial(val) : orElse(),
      ResultLoading<T> val => loading != null ? loading(val) : orElse(),
      ResultData<T> val => data != null ? data(val) : orElse(),
      ResultError<T> val => error != null ? error(val) : orElse(),
    };
  }

  /// Map over the underlying subclasses with a fallback returning null.
  R? mapOrNull<R>({
    R? Function(ResultInitial<T> value)? initial,
    R? Function(ResultLoading<T> value)? loading,
    R? Function(ResultData<T> value)? data,
    R? Function(ResultError<T> value)? error,
  }) {
    return switch (this) {
      ResultInitial<T> val => initial?.call(val),
      ResultLoading<T> val => loading?.call(val),
      ResultData<T> val => data?.call(val),
      ResultError<T> val => error?.call(val),
    };
  }
}

/// The initial state subclass.
class ResultInitial<T> extends Result<T> {
  /// Creates a [ResultInitial] state.
  const ResultInitial() : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ResultInitial<T> && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Result<$T>.initial()';
}

/// The loading state subclass.
class ResultLoading<T> extends Result<T> {
  /// Creates a [ResultLoading] state.
  const ResultLoading() : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ResultLoading<T> && other.runtimeType == runtimeType);

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Result<$T>.loading()';
}

/// The data state subclass.
class ResultData<T> extends Result<T> {
  /// The value wrapped by this result.
  @override
  final T value;

  /// Creates a [ResultData] state.
  const ResultData(this.value) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResultData<T> &&
          other.runtimeType == runtimeType &&
          other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Result<$T>.data(value: $value)';
}

/// The error state subclass.
class ResultError<T> extends Result<T> {
  /// The error wrapped by this result.
  final Exception error;

  /// Creates a [ResultError] state.
  const ResultError(this.error) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResultError<T> &&
          other.runtimeType == runtimeType &&
          other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'Result<$T>.error(error: $error)';
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
sealed class ValueResult<T> {
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

  /// The success value, or null if in failure state.
  T? get data => maybeWhen(
    success: (data) => data,
    orElse: () => null,
  );

  /// The failure exception, or null if in success state.
  Exception? get failure => maybeWhen(
    failure: (error) => error,
    orElse: () => null,
  );

  /// Returns the failure exception cast to [E], or null if the failure is not of type [E].
  E? errorAs<E extends Exception>() {
    final err = failure;
    return err is E ? err : null;
  }

  /// Exhaustive pattern matching.
  R when<R>({
    required R Function(T data) success,
    required R Function(Exception error) failure,
  }) {
    return switch (this) {
      ValueResultSuccess(data: final val) => success(val),
      ValueResultFailure(error: final err) => failure(err),
    };
  }

  /// Exhaustive pattern matching with a fallback.
  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(Exception error)? failure,
    required R Function() orElse,
  }) {
    return switch (this) {
      ValueResultSuccess(data: final val) => success != null ? success(val) : orElse(),
      ValueResultFailure(error: final err) => failure != null ? failure(err) : orElse(),
    };
  }

  /// Exhaustive pattern matching with a fallback returning null.
  R? whenOrNull<R>({
    R? Function(T data)? success,
    R? Function(Exception error)? failure,
  }) {
    return switch (this) {
      ValueResultSuccess(data: final val) => success?.call(val),
      ValueResultFailure(error: final err) => failure?.call(err),
    };
  }

  /// Map over the underlying subclasses.
  R map<R>({
    required R Function(ValueResultSuccess<T> value) success,
    required R Function(ValueResultFailure<T> value) failure,
  }) {
    return switch (this) {
      ValueResultSuccess<T> val => success(val),
      ValueResultFailure<T> val => failure(val),
    };
  }

  /// Map over the underlying subclasses with a fallback.
  R maybeMap<R>({
    R Function(ValueResultSuccess<T> value)? success,
    R Function(ValueResultFailure<T> value)? failure,
    required R Function() orElse,
  }) {
    return switch (this) {
      ValueResultSuccess<T> val => success != null ? success(val) : orElse(),
      ValueResultFailure<T> val => failure != null ? failure(val) : orElse(),
    };
  }

  /// Map over the underlying subclasses with a fallback returning null.
  R? mapOrNull<R>({
    R? Function(ValueResultSuccess<T> value)? success,
    R? Function(ValueResultFailure<T> value)? failure,
  }) {
    return switch (this) {
      ValueResultSuccess<T> val => success?.call(val),
      ValueResultFailure<T> val => failure?.call(val),
    };
  }
}

/// The success value subclass.
class ValueResultSuccess<T> extends ValueResult<T> {
  /// The data wrapped by this result.
  @override
  final T data;

  /// Creates a [ValueResultSuccess] state.
  const ValueResultSuccess(this.data) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ValueResultSuccess<T> &&
          other.runtimeType == runtimeType &&
          other.data == data);

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'ValueResult<$T>.success(data: $data)';
}

/// The failure value subclass.
class ValueResultFailure<T> extends ValueResult<T> {
  /// The error wrapped by this result.
  final Exception error;

  /// Creates a [ValueResultFailure] state.
  const ValueResultFailure(this.error) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ValueResultFailure<T> &&
          other.runtimeType == runtimeType &&
          other.error == error);

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'ValueResult<$T>.failure(error: $error)';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vm_result/src/logging/logger.dart';
import 'package:vm_result/src/models/result.dart';

abstract class VMResult<S> extends ChangeNotifier implements ValueListenable<Result<S>> {
  VMResult(Result<S> initial) : _state = initial;

  Result<S> _state;
  bool _isExecuting = false;
  int _runLatestGeneration = 0;

  /// Whether the VM is currently executing an async operation.
  bool get isExecuting => _isExecuting;

  bool _disposed = false;

  /// Whether this VM has been disposed.
  bool get disposed => _disposed;

  @override
  Result<S> get value => _state;

  /// Alias for [value]
  Result<S> get state => _state;

  /// Sets the state to loading.
  ///
  /// Use this when starting a long-running operation.
  /// Typically called automatically by guard methods.
  @protected
  void setLoading() {
    if (_disposed) return;
    _set(Result<S>.loading());
  }

  /// Sets the state to data with the provided value.
  ///
  /// Use this when an operation completes successfully.
  /// Typically called automatically by guard methods.
  @protected
  void setData(S data) {
    if (_disposed) return;
    _set(Result.data(data));
  }

  /// Sets the state to error and logs it for debugging.
  ///
  /// Use this when an operation fails.
  /// Typically called automatically by guard methods.
  @protected
  void setError(Exception error, [StackTrace? stackTrace]) {
    if (_disposed) return;
    logger.error('ViewModel Error: $error, stackTrace: $stackTrace');
    _set(Result<S>.error(error));
  }

  /// Wraps an async action with automatic loading state management.
  ///
  /// Shows loading state → executes action → sets data or error.
  /// This is the most common guard pattern for simple async operations.
  ///
  /// Calls are deduplicated: if an operation is already in-flight, subsequent
  /// calls are dropped and a debug warning is logged.
  ///
  /// Example:
  /// ```dart
  /// Future<void> loadUser() => run(() => repository.getUser());
  /// ```
  @protected
  Future<void> run(Future<S> Function() action) async {
    if (_dropIfExecuting()) return;
    setLoading();
    await _execute(action, onSuccess: setData);
  }

  /// Similar to [run] but returns a [ValueResult] for conditional logic.
  ///
  /// Use this when you need to perform different actions based on success/failure,
  /// such as navigation or showing specific error messages.
  ///
  /// Calls are deduplicated: if an operation is already in-flight, subsequent
  /// calls are dropped and a debug warning is logged.
  ///
  /// Example:
  /// ```dart
  /// final result = await runWithValueResult(() => repository.login(email, pass));
  /// result.when(
  ///   success: (user) => navigateToHome(),
  ///   failure: (error) => showErrorDialog(error.message),
  /// );
  /// ```
  @protected
  Future<ValueResult<S>> runWithValueResult(Future<S> Function() action) async {
    if (_dropIfExecuting()) return ValueResult.failure(_inFlightException());
    setLoading();
    ValueResult<S>? result;
    await _execute(
      action,
      onSuccess: (data) {
        setData(data);
        result = ValueResult.success(data);
      },
      onError: (error) {
        result = ValueResult.failure(error);
      },
    );
    return result ?? ValueResult.failure(_disposedException());
  }

  /// Updates state silently without showing loading indicator.
  ///
  /// Use this for background updates where showing a loading state
  /// would disrupt the user experience (e.g., auto-save, background sync).
  ///
  /// Calls are deduplicated: if an operation is already in-flight, subsequent
  /// calls are dropped and a debug warning is logged.
  ///
  /// Example:
  /// ```dart
  /// Future<void> autoSave() => runSilent(
  ///   () => repository.savePreferences(prefs),
  /// );
  /// ```
  @protected
  Future<void> runSilent(Future<S> Function() action) async {
    if (_dropIfExecuting()) return;
    await _execute(action, onSuccess: setData);
  }

  /// Sets optimistic state immediately, then updates with real result or rolls back.
  ///
  /// Useful for providing instant feedback to users before server confirmation.
  /// If the action fails, automatically restores the previous state.
  ///
  /// Calls are deduplicated: if an operation is already in-flight, subsequent
  /// calls are dropped and a debug warning is logged.
  ///
  /// Example:
  /// ```dart
  /// Future<void> loadMore() => runOptimistic(
  ///   optimisticState: current.copyWith(isLoadingMore: true),
  ///   action: () => repository.getNextPage(),
  /// );
  /// ```
  @protected
  Future<void> runOptimistic({required S optimisticState, required Future<S> Function() action}) async {
    if (_dropIfExecuting()) return;
    setData(optimisticState);
    await _executeWithRollback(action, onSuccess: setData);
  }

  /// Subscribes to a long-lived stream, emitting each event as [ResultData].
  ///
  /// Lifecycle:
  /// 1. Sets the state to [ResultLoading] once when the subscription opens.
  /// 2. Each emitted event transitions the state to `ResultData(event)`.
  /// 3. A stream error transitions the state to [ResultError] and cancels the
  ///    subscription.
  /// 4. When the stream closes naturally (onDone), the last data state is kept
  ///    and [isExecuting] is cleared.
  ///
  /// Calling [runStream] while a subscription is already active **replaces** the
  /// current subscription. The old one is cancelled before the new one opens,
  /// so reconnect and source-swap require no manual teardown.
  ///
  /// The active subscription is automatically cancelled on [dispose].
  ///
  /// Example (WebSocket chat):
  /// ```dart
  /// void connect() => runStream(() => _socket.messages);
  /// ```
  @protected
  void runStream(Stream<S> Function() factory) {
    if (_disposed) return;
    _streamSub?.cancel();
    _isExecuting = true;
    setLoading();
    _streamSub = factory().listen(
      (event) {
        if (_disposed) return;
        setData(event);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (_disposed) return;
        _isExecuting = false;
        final exception = error is Exception ? error : Exception(error.toString());
        setError(exception, stackTrace);
        _streamSub = null;
      },
      onDone: () {
        if (_disposed) return;
        _isExecuting = false;
        _streamSub = null;
      },
      cancelOnError: true,
    );
  }

  /// Cancels the active stream subscription opened by [runStream], if any.
  ///
  /// The current state is preserved. Use this to explicitly disconnect (e.g.,
  /// when the user navigates away) without waiting for the stream to close.
  @protected
  Future<void> cancelStream() async {
    await _streamSub?.cancel();
    _streamSub = null;
    _isExecuting = false;
  }

  StreamSubscription<S>? _streamSub;

  /// Runs the action, discarding results from superseded in-flight calls.
  ///
  /// Each call increments an internal generation counter. If a newer call
  /// starts before an older one completes, the older result is silently
  /// discarded. The loading state is set on every call so the UI stays reactive.
  ///
  /// Use this for search-as-you-type or any scenario where only the most
  /// recent result matters.
  ///
  /// Example:
  /// ```dart
  /// Future<void> search(String query) => runLatest(() => repository.search(query));
  /// ```
  @protected
  Future<void> runLatest(Future<S> Function() action) async {
    final generation = ++_runLatestGeneration;
    setLoading();
    await _executeLatest(action, generation: generation);
  }

  /// Cancel-and-replace execution logic used by [runLatest].
  ///
  /// Results from calls whose generation does not match [_runLatestGeneration]
  /// are silently discarded. [_isExecuting] is only cleared by the latest generation.
  Future<void> _executeLatest(Future<S> Function() action, {required int generation}) async {
    if (_tryHandleDisposed(setError)) return;

    _isExecuting = true;

    try {
      final result = await action();

      if (_runLatestGeneration != generation) return;
      if (_tryHandleDisposed(setError)) return;

      setData(result);
    } on Exception catch (e, s) {
      if (_runLatestGeneration != generation) return;
      if (_tryHandleDisposed(setError)) return;

      setError(e, s);
    } on Error {
      rethrow;
    } finally {
      if (_runLatestGeneration == generation) {
        _isExecuting = false;
      }
    }
  }

  /// Core execution logic with automatic error handling and state management.
  Future<void> _execute<R>(
    Future<R> Function() action, {
    required void Function(R) onSuccess,
    void Function(Exception)? onError,
  }) async {
    if (_tryHandleDisposed(onError ?? setError)) return;

    _isExecuting = true;
    notifyListeners();

    try {
      final result = await action();

      if (_tryHandleDisposed(onError ?? setError, false)) return;

      onSuccess(result);
    } on Exception catch (e, s) {
      if (_tryHandleDisposed(onError ?? setError)) return;

      setError(e, s);
      onError?.call(e);
    } on Error {
      rethrow;
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }

  /// Execution logic with automatic state rollback on error.
  ///
  /// Preserves the previous state before executing the action. If the action
  /// fails, automatically restores the saved state before setting error.
  Future<void> _executeWithRollback<R>(Future<R> Function() action, {required void Function(R) onSuccess}) async {
    if (_isDisposed) {
      return;
    }

    _isExecuting = true;
    final previousState = _state;
    try {
      final result = await action();

      if (_tryHandleDisposed()) return;

      onSuccess(result);
    } on Exception catch (e, s) {
      if (_tryHandleDisposed()) return;

      _rollback(previousState);
      setError(e, s);
    } on Error {
      rethrow;
    } finally {
      _isExecuting = false;
    }
  }

  /// Restores a previous state without triggering error handling.
  ///
  /// Used internally by [_executeWithRollback] to revert optimistic updates.
  void _rollback(Result<S> previousState) {
    if (_disposed) return;
    if (previousState == _state) return; // No need to rollback if state hasn't changed
    _state = previousState;
    notifyListeners();
  }

  /// Sets a new state and notifies listeners if not disposed.
  ///
  /// Automatically logs state transitions in debug mode for easier debugging.
  void _set(Result<S> next) {
    if (_disposed) return;
    if (next == _state) return; // No need to update if state hasn't changed
    _logTransition(_state, next);
    _state = next;
    notifyListeners();
  }

  /// Logs state transitions in debug mode for easier debugging.
  void _logTransition(Result<S> prev, Result<S> next) {
    if (kDebugMode) {
      logger.info('[$runtimeType]: State transition: ${_formatState(prev)} → ${_formatState(next)}');
    }
  }

  /// Formats a [Result] into a readable string for logging.
  String _formatState(Result<S> state) {
    return state.when(
      initial: () => 'Initial State',
      data: (d) => 'Data(${d.runtimeType}): $d',
      loading: () => 'Loading State',
      error: (e) => 'Error($e)',
    );
  }

  bool _dropIfExecuting() {
    if (!_isExecuting) return false;
    if (kDebugMode) {
      logger.warning('[$runtimeType]: Dropped duplicate call — operation already in-flight.');
    }
    return true;
  }

  Exception _inFlightException() {
    return Exception('[$runtimeType]: Call dropped because an operation was already in-flight.');
  }

  Exception _disposedException([bool logWarning = true]) {
    if (logWarning) {
      logger.warning('Attempted to perform an operation on a DISPOSED ViewModel: $runtimeType');
    }

    return Exception('Operation canceled because the $runtimeType was disposed.');
  }

  bool get _isDisposed => _disposed;

  bool _tryHandleDisposed([void Function(Exception)? onError, bool logWarning = true]) {
    if (!_isDisposed) {
      return false;
    }

    onError?.call(_disposedException(logWarning));
    return true;
  }

  /// Marks the ViewModel as disposed and prevents further state updates.
  ///
  /// Must be called manually in your widget's `dispose()` method to prevent memory leaks.
  @override
  void dispose() {
    _disposed = true;
    _streamSub?.cancel();
    _streamSub = null;
    super.dispose();
  }
}

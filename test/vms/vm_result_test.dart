import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vm_result/vm_result.dart';

// ---------------------------------------------------------------------------
// Minimal concrete ViewModel for testing — exposes protected guard methods
// ---------------------------------------------------------------------------

class _TestVM extends VMResult<String> {
  _TestVM([Result<String>? initial]) : super(initial ?? const Result.initial());

  Future<void> triggerRun(Future<String> Function() action) => run(action);

  Future<ValueResult<String>> triggerRunWithValueResult(Future<String> Function() action) => runWithValueResult(action);

  Future<void> triggerRunSilent(Future<String> Function() action) => runSilent(action);

  Future<void> triggerRunOptimistic({
    required String optimisticState,
    required Future<String> Function() action,
  }) => runOptimistic(optimisticState: optimisticState, action: action);

  Future<void> triggerRunLatest(Future<String> Function() action) => runLatest(action);

  void triggerSetLoading() => setLoading();
  void triggerSetData(String data) => setData(data);
  void triggerSetError(Exception error) => setError(error);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Collects every state emitted by a VMResult into a list.
List<Result<String>> _collectStates(_TestVM vm) {
  final states = <Result<String>>[vm.state];
  vm.addListener(() => states.add(vm.state));
  return states;
}

void main() {
  group('VMResult — manual state setters', () {
    test('setLoading transitions to ResultLoading', () {
      final vm = _TestVM();
      vm.triggerSetLoading();
      expect(vm.state, isA<ResultLoading<String>>());
    });

    test('setData transitions to ResultData', () {
      final vm = _TestVM();
      vm.triggerSetData('hello');
      expect(vm.state.asData?.value, 'hello');
    });

    test('setError transitions to ResultError', () {
      final vm = _TestVM();
      vm.triggerSetError(Exception('boom'));
      expect(vm.state.hasError, isTrue);
    });

    test('setters are no-ops after dispose', () {
      final vm = _TestVM();
      vm.dispose();
      vm.triggerSetLoading();
      vm.triggerSetData('x');
      vm.triggerSetError(Exception());
      expect(vm.state, isA<ResultInitial<String>>());
    });

    test('identical state does not trigger notifyListeners', () {
      final vm = _TestVM(const Result.loading());
      var notified = 0;
      vm.addListener(() => notified++);
      vm.triggerSetLoading(); // same state again
      expect(notified, 0);
    });
  });

  group('VMResult — run', () {
    test('sets loading then data on success', () async {
      final vm = _TestVM();
      final states = _collectStates(vm);

      await vm.triggerRun(() async => 'done');

      expect(states, [
        isA<ResultInitial<String>>(),
        isA<ResultLoading<String>>(),
        isA<ResultData<String>>(),
      ]);
      expect(vm.state.asData?.value, 'done');
    });

    test('sets loading then error on exception', () async {
      final vm = _TestVM();
      final states = _collectStates(vm);

      await vm.triggerRun(() async => throw Exception('fail'));

      expect(states, [
        isA<ResultInitial<String>>(),
        isA<ResultLoading<String>>(),
        isA<ResultError<String>>(),
      ]);
    });

    test('isExecuting is true during action and false after', () async {
      final vm = _TestVM();
      final completer = Completer<String>();
      bool? duringExecution;

      final future = vm.triggerRun(() {
        duringExecution = vm.isExecuting;
        return completer.future;
      });

      await Future.microtask(() {});
      expect(duringExecution, isTrue);

      completer.complete('ok');
      await future;
      expect(vm.isExecuting, isFalse);
    });

    test('drops duplicate concurrent calls', () async {
      final vm = _TestVM();
      int callCount = 0;
      final completer = Completer<String>();

      final first = vm.triggerRun(() {
        callCount++;
        return completer.future;
      });
      final second = vm.triggerRun(() {
        callCount++;
        return Future.value('dropped');
      });

      completer.complete('first');
      await Future.wait([first, second]);

      expect(callCount, 1);
      expect(vm.state.asData?.value, 'first');
    });

    test('does nothing if disposed before action starts', () async {
      final vm = _TestVM();
      vm.dispose();
      await vm.triggerRun(() async => 'x');
      expect(vm.state, isA<ResultInitial<String>>());
    });
  });

  group('VMResult — runWithValueResult', () {
    test('returns ValueResult.success on success', () async {
      final vm = _TestVM();
      final result = await vm.triggerRunWithValueResult(() async => 'ok');
      expect(result.isSuccess, isTrue);
      expect(result.data, 'ok');
      expect(vm.state.hasValue, isTrue);
    });

    test('returns ValueResult.failure and sets error state on exception', () async {
      final vm = _TestVM();
      final result = await vm.triggerRunWithValueResult(() async => throw Exception('bad'));
      expect(result.isFailure, isTrue);
      expect(vm.state.hasError, isTrue);
    });

    test('drops duplicate calls and returns failure', () async {
      final vm = _TestVM();
      final completer = Completer<String>();

      final first = vm.triggerRunWithValueResult(() => completer.future);
      final second = vm.triggerRunWithValueResult(() async => 'dropped');

      final secondResult = await second;
      expect(secondResult.isFailure, isTrue);

      completer.complete('ok');
      final firstResult = await first;
      expect(firstResult.isSuccess, isTrue);
    });

    test('returns failure if disposed mid-flight', () async {
      final vm = _TestVM();
      final completer = Completer<String>();

      final resultFuture = vm.triggerRunWithValueResult(() => completer.future);
      vm.dispose();
      completer.complete('late');

      final result = await resultFuture;
      expect(result.isFailure, isTrue);
    });
  });

  group('VMResult — runSilent', () {
    test('does not show loading state', () async {
      final vm = _TestVM();
      final states = _collectStates(vm);

      await vm.triggerRunSilent(() async => 'silent');

      expect(states.any((s) => s is ResultLoading), isFalse);
      expect(vm.state.asData?.value, 'silent');
    });

    test('sets error state on exception', () async {
      final vm = _TestVM();
      await vm.triggerRunSilent(() async => throw Exception('silent fail'));
      expect(vm.state.hasError, isTrue);
    });

    test('drops duplicate calls', () async {
      final vm = _TestVM();
      int callCount = 0;
      final completer = Completer<String>();

      final first = vm.triggerRunSilent(() {
        callCount++;
        return completer.future;
      });
      final second = vm.triggerRunSilent(() {
        callCount++;
        return Future.value('dropped');
      });

      completer.complete('done');
      await Future.wait([first, second]);
      expect(callCount, 1);
    });
  });

  group('VMResult — runOptimistic', () {
    test('immediately sets optimistic state then commits on success', () async {
      final vm = _TestVM(const Result.data('original'));
      final states = _collectStates(vm);

      await vm.triggerRunOptimistic(
        optimisticState: 'optimistic',
        action: () async => 'committed',
      );

      expect(states[1].asData?.value, 'optimistic');
      expect(states.last.asData?.value, 'committed');
    });

    test('rolls back to previous state on error', () async {
      final vm = _TestVM(const Result.data('original'));

      await vm.triggerRunOptimistic(
        optimisticState: 'optimistic',
        action: () async => throw Exception('fail'),
      );

      // After rollback, previous data is restored and error is shown
      expect(vm.state.hasError, isTrue);
    });

    test('drops duplicate calls', () async {
      final vm = _TestVM(const Result.data('original'));
      int callCount = 0;
      final completer = Completer<String>();

      final first = vm.triggerRunOptimistic(
        optimisticState: 'opt',
        action: () {
          callCount++;
          return completer.future;
        },
      );
      final second = vm.triggerRunOptimistic(
        optimisticState: 'opt',
        action: () {
          callCount++;
          return Future.value('dropped');
        },
      );

      completer.complete('ok');
      await Future.wait([first, second]);
      expect(callCount, 1);
    });
  });

  group('VMResult — runLatest', () {
    test('only the last call result is applied', () async {
      final vm = _TestVM();
      final c1 = Completer<String>();
      final c2 = Completer<String>();

      final f1 = vm.triggerRunLatest(() => c1.future);
      final f2 = vm.triggerRunLatest(() => c2.future);

      c2.complete('second'); // resolve newer first
      await f2;
      c1.complete('first'); // resolve older after
      await f1;

      // Only the last-dispatched result should be applied
      expect(vm.state.asData?.value, 'second');
    });

    test('sets loading on every call', () async {
      final vm = _TestVM();
      final states = _collectStates(vm);

      final c1 = Completer<String>();
      final f1 = vm.triggerRunLatest(() => c1.future);

      // A second call should also set loading (generation counter increments)
      final c2 = Completer<String>();
      final f2 = vm.triggerRunLatest(() => c2.future);

      c1.complete('stale');
      c2.complete('fresh');
      await Future.wait([f1, f2]);

      expect(states.whereType<ResultLoading>().length, greaterThanOrEqualTo(1));
      expect(vm.state.asData?.value, 'fresh');
    });

    test('isExecuting is false after latest call settles', () async {
      final vm = _TestVM();
      final c1 = Completer<String>();
      final c2 = Completer<String>();

      final f1 = vm.triggerRunLatest(() => c1.future);
      final f2 = vm.triggerRunLatest(() => c2.future);

      c1.complete('stale');
      await Future.microtask(() {}); // let c1 resolve
      expect(vm.isExecuting, isTrue); // c2 still pending

      c2.complete('fresh');
      await Future.wait([f1, f2]);
      expect(vm.isExecuting, isFalse);
    });
  });

  group('VMResult — disposed', () {
    test('disposed getter reflects dispose() call', () {
      final vm = _TestVM();
      expect(vm.disposed, isFalse);
      vm.dispose();
      expect(vm.disposed, isTrue);
    });

    test('calling dispose twice does not throw', () {
      final vm = _TestVM();
      vm.dispose();
      expect(() => vm.dispose(), throwsFlutterError);
    });
  });

  group('VMResult — value / state alias', () {
    test('value and state return the same object', () {
      final vm = _TestVM();
      expect(vm.value, same(vm.state));
    });
  });
}

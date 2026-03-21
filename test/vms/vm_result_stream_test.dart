import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vm_result/vm_result.dart';

// ---------------------------------------------------------------------------
// Concrete ViewModel for testing
// ---------------------------------------------------------------------------

class _StreamVM extends VMResult<String> {
  _StreamVM() : super(const Result.initial());

  void connect(Stream<String> Function() factory) => runStream(factory);
  Future<void> disconnect() => cancelStream();
}

// ---------------------------------------------------------------------------
// Helper: collect every notified state into a list
// ---------------------------------------------------------------------------

List<Result<String>> _collectStates(_StreamVM vm) {
  final states = <Result<String>>[vm.state];
  vm.addListener(() => states.add(vm.state));
  return states;
}

void main() {
  group('VMResult — runStream', () {
    test('transitions to loading immediately on connect', () async {
      final vm = _StreamVM();
      final controller = StreamController<String>();

      vm.connect(() => controller.stream);

      expect(vm.state, isA<ResultLoading<String>>());
      expect(vm.isExecuting, isTrue);

      await controller.close();
      vm.dispose();
    });

    test('transitions to data for each emitted event', () async {
      final vm = _StreamVM();
      final states = _collectStates(vm);
      final controller = StreamController<String>();

      vm.connect(() => controller.stream);
      controller.add('a');
      controller.add('b');
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<ResultInitial<String>>(),
        isA<ResultLoading<String>>(),
        isA<ResultData<String>>(),
        isA<ResultData<String>>(),
      ]);
      expect((states[2] as ResultData<String>).value, 'a');
      expect((states[3] as ResultData<String>).value, 'b');

      await controller.close();
      vm.dispose();
    });

    test('isExecuting is true while stream is open', () async {
      final vm = _StreamVM();
      final controller = StreamController<String>();

      vm.connect(() => controller.stream);
      await Future<void>.delayed(Duration.zero);
      expect(vm.isExecuting, isTrue);

      await controller.close();
      await Future<void>.delayed(Duration.zero);
      expect(vm.isExecuting, isFalse);

      vm.dispose();
    });

    test('transitions to error on stream error and clears isExecuting', () async {
      final vm = _StreamVM();
      final states = _collectStates(vm);
      final controller = StreamController<String>();

      vm.connect(() => controller.stream);
      controller.addError(Exception('socket error'));
      await Future<void>.delayed(Duration.zero);

      expect(vm.state, isA<ResultError<String>>());
      expect(vm.isExecuting, isFalse);
      expect(states.any((s) => s is ResultLoading), isTrue);

      vm.dispose();
    });

    test('preserves last data state on natural stream close', () async {
      final vm = _StreamVM();
      final controller = StreamController<String>();

      vm.connect(() => controller.stream);
      controller.add('hello');
      await Future<void>.delayed(Duration.zero);

      await controller.close();
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.asData?.value, 'hello');
      expect(vm.isExecuting, isFalse);

      vm.dispose();
    });

    test('replaces active subscription when called again', () async {
      final vm = _StreamVM();
      final c1 = StreamController<String>();
      final c2 = StreamController<String>();

      vm.connect(() => c1.stream);
      c1.add('from-first');
      await Future<void>.delayed(Duration.zero);

      // Replace with second stream — no manual cancel needed
      vm.connect(() => c2.stream);
      c2.add('from-second');
      await Future<void>.delayed(Duration.zero);

      // Emit on the cancelled first stream — must be ignored
      c1.add('stale');
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.asData?.value, 'from-second');

      await c1.close();
      await c2.close();
      vm.dispose();
    });

    test('replace sets loading again between subscriptions', () async {
      final vm = _StreamVM();
      final states = _collectStates(vm);
      final c1 = StreamController<String>();
      final c2 = StreamController<String>();

      vm.connect(() => c1.stream);
      c1.add('first');
      await Future<void>.delayed(Duration.zero);

      vm.connect(() => c2.stream);
      await Future<void>.delayed(Duration.zero);

      // Should have a second loading state after reconnect
      final loadingCount = states.whereType<ResultLoading<String>>().length;
      expect(loadingCount, 2);

      await c1.close();
      await c2.close();
      vm.dispose();
    });

    test('does nothing when called after dispose', () async {
      final vm = _StreamVM();
      vm.dispose();

      vm.connect(() => Stream.value('x'));
      await Future<void>.delayed(Duration.zero);

      expect(vm.state, isA<ResultInitial<String>>());
    });

    test('events emitted after dispose are silently ignored', () async {
      final vm = _StreamVM();
      final controller = StreamController<String>();

      vm.connect(() => controller.stream);
      await Future<void>.delayed(Duration.zero);

      // Dispose while stream is still open
      vm.dispose();

      controller.add('after-dispose');
      await Future<void>.delayed(Duration.zero);

      // Must stay at loading — the add must not trigger setData
      expect(vm.state, isA<ResultLoading<String>>());

      await controller.close();
    });
  });

  group('VMResult — cancelStream', () {
    test('cancels subscription and clears isExecuting', () async {
      final vm = _StreamVM();
      final controller = StreamController<String>();

      vm.connect(() => controller.stream);
      controller.add('first');
      await Future<void>.delayed(Duration.zero);
      expect(vm.isExecuting, isTrue);

      await vm.disconnect();

      expect(vm.isExecuting, isFalse);

      // Events after cancel must not update state
      controller.add('after-cancel');
      await Future<void>.delayed(Duration.zero);
      expect(vm.state.asData?.value, 'first');

      await controller.close();
      vm.dispose();
    });

    test('preserves current data state after cancel', () async {
      final vm = _StreamVM();
      final controller = StreamController<String>();

      vm.connect(() => controller.stream);
      controller.add('saved');
      await Future<void>.delayed(Duration.zero);

      await vm.disconnect();

      expect(vm.state.asData?.value, 'saved');
      vm.dispose();
    });

    test('is a no-op when no subscription is active', () async {
      final vm = _StreamVM();

      // Must not throw
      await vm.disconnect();

      expect(vm.isExecuting, isFalse);
      expect(vm.state, isA<ResultInitial<String>>());
      vm.dispose();
    });
  });

  group('VMResult — dispose cancels stream subscription', () {
    test('dispose cancels the active subscription', () async {
      final vm = _StreamVM();
      var cancelCount = 0;
      final controller = StreamController<String>(
        onCancel: () => cancelCount++,
      );

      vm.connect(() => controller.stream);
      await Future<void>.delayed(Duration.zero);

      vm.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(cancelCount, 1);

      await controller.close();
    });

    test('dispose with no active subscription does not throw', () {
      final vm = _StreamVM();
      expect(() => vm.dispose(), returnsNormally);
    });
  });
}

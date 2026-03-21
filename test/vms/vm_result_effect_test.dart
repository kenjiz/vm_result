import 'package:flutter_test/flutter_test.dart';
import 'package:vm_result/vm_result.dart';

// ---------------------------------------------------------------------------
// Concrete test effect type
// ---------------------------------------------------------------------------

class _TestEffect extends BaseUiEffect {
  const _TestEffect(this.value);
  final String value;
}

// ---------------------------------------------------------------------------
// Concrete ViewModel for testing
// ---------------------------------------------------------------------------

class _TestEffectVM extends VMResultEffect<String, _TestEffect> {
  _TestEffectVM() : super(const Result.initial());

  Future<void> load(Future<String> Function() action) => run(action);

  void emit(_TestEffect effect) => emitEffect(effect);
}

// ---------------------------------------------------------------------------
// Helper: collect all emitted effects into a list
// ---------------------------------------------------------------------------

void main() {
  group('VMResultEffect — emitEffect', () {
    test('emitted effect is received by stream listener', () async {
      final vm = _TestEffectVM();
      final effects = <_TestEffect>[];
      final sub = vm.effects.listen(effects.add);

      vm.emit(const _TestEffect('ping'));
      await Future.microtask(() {});

      expect(effects.length, 1);
      expect(effects.first.value, 'ping');

      await sub.cancel();
      vm.dispose();
    });

    test('multiple effects are received in order', () async {
      final vm = _TestEffectVM();
      final effects = <_TestEffect>[];
      final sub = vm.effects.listen(effects.add);

      vm.emit(const _TestEffect('a'));
      vm.emit(const _TestEffect('b'));
      vm.emit(const _TestEffect('c'));
      // Yield to the event loop so all pending microtasks (async stream delivery)
      // are fully processed before asserting.
      await Future<void>.delayed(Duration.zero);

      expect(effects.map((e) => e.value).toList(), ['a', 'b', 'c']);
      await sub.cancel();
      vm.dispose();
    });

    test('emitEffect after dispose is silently dropped', () async {
      final vm = _TestEffectVM();
      final effects = <_TestEffect>[];
      final sub = vm.effects.listen(effects.add);

      vm.dispose();
      vm.emit(const _TestEffect('after-dispose'));
      await Future.microtask(() {});

      expect(effects, isEmpty);
      await sub.cancel();
    });

    test('effects stream is closed after dispose', () async {
      final vm = _TestEffectVM();
      var streamDone = false;
      final sub = vm.effects.listen((_) {}, onDone: () => streamDone = true);

      vm.dispose();
      await Future.microtask(() {});

      expect(streamDone, isTrue);
      await sub.cancel();
    });
  });

  group('VMResultEffect — state management', () {
    test('inherits run() behaviour from VMResult', () async {
      final vm = _TestEffectVM();
      final states = <Result<String>>[vm.state];
      vm.addListener(() => states.add(vm.state));

      await vm.load(() async => 'loaded');

      expect(states, [
        isA<ResultInitial<String>>(),
        isA<ResultLoading<String>>(),
        isA<ResultData<String>>(),
      ]);
      expect(vm.state.asData?.value, 'loaded');
      vm.dispose();
    });
  });

  group('VMResultEffect — effects + state together', () {
    test('can emit effect and update state in the same operation', () async {
      final vm = _TestEffectVM();
      final effects = <_TestEffect>[];
      final sub = vm.effects.listen(effects.add);

      await vm.load(() async => 'data');
      vm.emit(const _TestEffect('side-effect'));
      await Future.microtask(() {});

      expect(vm.state.hasValue, isTrue);
      expect(effects.length, 1);

      await sub.cancel();
      vm.dispose();
    });
  });

  group('UiEffect built-in variants', () {
    test('UiEffect.showMessage carries message string', () {
      const e = UiEffect.showMessage('hello');
      e.when(
        showMessage: (msg) => expect(msg, 'hello'),
        isProcessing: (_) => fail('wrong branch'),
      );
    });

    test('UiEffect.isProcessing carries bool flag', () {
      const e = UiEffect.isProcessing(true);
      e.when(
        showMessage: (_) => fail('wrong branch'),
        isProcessing: (v) => expect(v, isTrue),
      );
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vm_result/vm_result.dart';

// ---------------------------------------------------------------------------
// Minimal test VMs
// ---------------------------------------------------------------------------

class _StringVM extends VMResult<String> {
  _StringVM([super.initial = const Result.initial()]);

  void set(Result<String> s) {
    // Use the public-via-protected trick: wrap access for testing
    switch (s) {
      case ResultLoading():
        setLoading();
      case ResultData(:final value):
        setData(value);
      case ResultError(:final error):
        setError(error);
      case ResultInitial():
        break;
    }
  }
}

class _TestEffect extends BaseUiEffect {
  const _TestEffect(this.value);
  final String value;
}

class _EffectVM extends VMResultEffect<String, _TestEffect> {
  _EffectVM() : super(const Result.initial());
  void emit(_TestEffect e) => emitEffect(e);
}

// ---------------------------------------------------------------------------
// ResultBuilder widget tests
// ---------------------------------------------------------------------------

void main() {
  group('ResultBuilder', () {
    testWidgets('renders builder output for initial state', (tester) async {
      final vm = _StringVM();
      await tester.pumpWidget(
        MaterialApp(
          home: ResultBuilder<String>(
            listenable: vm,
            builder: (_, result, _) => result.when(
              initial: () => const Text('initial'),
              loading: () => const Text('loading'),
              data: (v) => Text('data:$v'),
              error: (_) => const Text('error'),
            ),
          ),
        ),
      );

      expect(find.text('initial'), findsOneWidget);
    });

    testWidgets('rebuilds when state changes to loading', (tester) async {
      final vm = _StringVM();
      await tester.pumpWidget(
        MaterialApp(
          home: ResultBuilder<String>(
            listenable: vm,
            builder: (_, result, _) => result.when(
              initial: () => const Text('initial'),
              loading: () => const Text('loading'),
              data: (v) => Text('data:$v'),
              error: (_) => const Text('error'),
            ),
          ),
        ),
      );

      vm.set(const Result.loading());
      await tester.pump();

      expect(find.text('loading'), findsOneWidget);
    });

    testWidgets('rebuilds when state changes to data', (tester) async {
      final vm = _StringVM();
      await tester.pumpWidget(
        MaterialApp(
          home: ResultBuilder<String>(
            listenable: vm,
            builder: (_, result, _) => result.when(
              initial: () => const Text('initial'),
              loading: () => const Text('loading'),
              data: (v) => Text('data:$v'),
              error: (_) => const Text('error'),
            ),
          ),
        ),
      );

      vm.set(const Result.data('hello'));
      await tester.pump();

      expect(find.text('data:hello'), findsOneWidget);
    });

    testWidgets('rebuilds when state changes to error', (tester) async {
      final vm = _StringVM();
      await tester.pumpWidget(
        MaterialApp(
          home: ResultBuilder<String>(
            listenable: vm,
            builder: (_, result, _) => result.when(
              initial: () => const Text('initial'),
              loading: () => const Text('loading'),
              data: (v) => Text('data:$v'),
              error: (_) => const Text('error'),
            ),
          ),
        ),
      );

      vm.set(Result.error(Exception('boom')));
      await tester.pump();

      expect(find.text('error'), findsOneWidget);
    });

    testWidgets('passes child through to builder', (tester) async {
      final vm = _StringVM(const Result.data('x'));
      const child = Text('static-child');

      Widget? capturedChild;
      await tester.pumpWidget(
        MaterialApp(
          home: ResultBuilder<String>(
            listenable: vm,
            child: child,
            builder: (_, _, c) {
              capturedChild = c;
              return c ?? const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(capturedChild, isNotNull);
      expect(find.text('static-child'), findsOneWidget);
    });
  });

  group('EffectListener', () {
    testWidgets('invokes listener when effect is emitted', (tester) async {
      final vm = _EffectVM();
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: EffectListener<_EffectVM, String, _TestEffect>(
            vm: vm,
            listener: (_, effect) => received.add(effect.value),
            child: const Text('child'),
          ),
        ),
      );

      vm.emit(const _TestEffect('ping'));
      await tester.pump();

      expect(received, ['ping']);
      vm.dispose();
    });

    testWidgets('receives multiple effects in order', (tester) async {
      final vm = _EffectVM();
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: EffectListener<_EffectVM, String, _TestEffect>(
            vm: vm,
            listener: (_, effect) => received.add(effect.value),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      vm.emit(const _TestEffect('a'));
      vm.emit(const _TestEffect('b'));
      vm.emit(const _TestEffect('c'));
      await tester.pump();

      expect(received, ['a', 'b', 'c']);
      vm.dispose();
    });

    testWidgets('renders child widget unchanged', (tester) async {
      final vm = _EffectVM();

      await tester.pumpWidget(
        MaterialApp(
          home: EffectListener<_EffectVM, String, _TestEffect>(
            vm: vm,
            listener: (_, _) {},
            child: const Text('my-child'),
          ),
        ),
      );

      expect(find.text('my-child'), findsOneWidget);
      vm.dispose();
    });

    testWidgets('cancels subscription when widget is removed', (tester) async {
      final vm = _EffectVM();
      final received = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: EffectListener<_EffectVM, String, _TestEffect>(
            vm: vm,
            listener: (_, effect) => received.add(effect.value),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      // Remove the widget from the tree
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      // Emit after removal — should not be received
      vm.emit(const _TestEffect('after-removal'));
      await tester.pump();

      expect(received, isEmpty);
      vm.dispose();
    });
  });
}

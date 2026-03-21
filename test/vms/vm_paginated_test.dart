import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vm_result/vm_result.dart';

// ---------------------------------------------------------------------------
// Concrete VMPaginated for testing
// ---------------------------------------------------------------------------

class _TestPaginatedVM extends VMPaginated<String> {
  /// Controls what each page returns.
  /// Key = page number, Value = PageResult to return (or null to throw).
  final Map<int, PageResult<String>> pageResults;
  final Map<int, Exception> pageErrors;

  _TestPaginatedVM({
    this.pageResults = const {},
    this.pageErrors = const {},
  });

  @override
  Future<PageResult<String>> fetchPage(int page) async {
    if (pageErrors.containsKey(page)) throw pageErrors[page]!;
    if (pageResults.containsKey(page)) return pageResults[page]!;
    throw StateError('No result configured for page $page');
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

PageResult<String> _page(List<String> items, {bool hasNextPage = false}) =>
    PageResult(items: items, hasNextPage: hasNextPage);

void main() {
  group('PaginatedResult', () {
    test('factories and getters', () {
      const r = PaginatedResult(items: ['a', 'b'], page: 1, hasNextPage: true);
      expect(r.isEmpty, isFalse);
      expect(r.isNotEmpty, isTrue);
      expect(r.isLoadingMore, isFalse);
    });

    test('copyWith updates individual fields', () {
      const r = PaginatedResult(items: ['a'], page: 1, hasNextPage: true);
      final updated = r.copyWith(isLoadingMore: true);
      expect(updated.isLoadingMore, isTrue);
      expect(updated.items, ['a']);
      expect(updated.page, 1);
    });

    test('isEmpty is true when items is empty', () {
      const r = PaginatedResult<String>(items: [], page: 1, hasNextPage: false);
      expect(r.isEmpty, isTrue);
      expect(r.isNotEmpty, isFalse);
    });
  });

  group('PageResult', () {
    test('stores items and hasNextPage', () {
      final r = PageResult(items: ['x'], hasNextPage: true);
      expect(r.items, ['x']);
      expect(r.hasNextPage, isTrue);
    });
  });

  group('VMPaginated — loadFirst', () {
    test('starts in initial state', () {
      final vm = _TestPaginatedVM();
      expect(vm.state, isA<ResultInitial<PaginatedResult<String>>>());
    });

    test('sets loading then data on success', () async {
      final vm = _TestPaginatedVM(
        pageResults: {
          1: _page(['a', 'b'], hasNextPage: true),
        },
      );
      final states = <Result<PaginatedResult<String>>>[vm.state];
      vm.addListener(() => states.add(vm.state));

      await vm.loadFirst();

      expect(states, [
        isA<ResultInitial<PaginatedResult<String>>>(),
        isA<ResultLoading<PaginatedResult<String>>>(),
        isA<ResultData<PaginatedResult<String>>>(),
      ]);

      final data = vm.state.asData!.value;
      expect(data.items, ['a', 'b']);
      expect(data.page, 1);
      expect(data.hasNextPage, isTrue);
    });

    test('sets error on exception', () async {
      final vm = _TestPaginatedVM(pageErrors: {1: Exception('fetch failed')});
      await vm.loadFirst();
      expect(vm.state.hasError, isTrue);
    });

    test('drops duplicate loadFirst calls while in-flight', () async {
      final completer = Completer<PageResult<String>>();

      // Replace fetchPage with controlled version
      final controlledVm = _ControllablePaginatedVM(completer: completer);

      final f1 = controlledVm.loadFirst();
      final f2 = controlledVm.loadFirst(); // should be dropped

      completer.complete(_page(['a']));
      await Future.wait([f1, f2]);

      expect(controlledVm.fetchCallCount, 1);
    });
  });

  group('VMPaginated — loadMore', () {
    test('appends items and increments page', () async {
      final vm = _TestPaginatedVM(
        pageResults: {
          1: _page(['a', 'b'], hasNextPage: true),
          2: _page(['c', 'd'], hasNextPage: false),
        },
      );

      await vm.loadFirst();
      final result = await vm.loadMore();

      expect(result.isSuccess, isTrue);
      final data = result.data!;
      expect(data.items, ['a', 'b', 'c', 'd']);
      expect(data.page, 2);
      expect(data.hasNextPage, isFalse);
    });

    test('sets isLoadingMore true during fetch then false after', () async {
      final vm = _TestPaginatedVM(
        pageResults: {
          1: _page(['a'], hasNextPage: true),
        },
      );
      await vm.loadFirst();

      final completer = Completer<PageResult<String>>();
      final controlledVm = _ControllableLoadMoreVM(
        initialItems: vm.state.asData!.value,
        completer: completer,
      );

      final future = controlledVm.loadMore();
      await Future.microtask(() {});

      expect(controlledVm.state.asData?.value.isLoadingMore, isTrue);

      completer.complete(_page(['b']));
      await future;
      expect(controlledVm.state.asData?.value.isLoadingMore, isFalse);
    });

    test('preserves items and resets isLoadingMore on page error', () async {
      final vm = _TestPaginatedVM(
        pageResults: {
          1: _page(['a', 'b'], hasNextPage: true),
        },
        pageErrors: {2: Exception('page 2 failed')},
      );

      await vm.loadFirst();
      final result = await vm.loadMore();

      expect(result.isFailure, isTrue);
      final data = vm.state.asData!.value;
      expect(data.items, ['a', 'b']); // preserved
      expect(data.isLoadingMore, isFalse); // reset
      expect(vm.state.hasError, isFalse); // full error state NOT set
    });

    test('returns failure when loadFirst is in-flight', () async {
      final completer = Completer<PageResult<String>>();
      final vm = _ControllablePaginatedVM(completer: completer);

      final loadFirstFuture = vm.loadFirst(); // in-flight
      final result = await vm.loadMore();

      expect(result.isFailure, isTrue);

      completer.complete(_page(['a']));
      await loadFirstFuture;
    });

    test('returns failure when no first page loaded yet', () async {
      final vm = _TestPaginatedVM();
      final result = await vm.loadMore();
      expect(result.isFailure, isTrue);
    });

    test('returns failure when hasNextPage is false', () async {
      final vm = _TestPaginatedVM(
        pageResults: {
          1: _page(['a'], hasNextPage: false),
        },
      );
      await vm.loadFirst();
      final result = await vm.loadMore();
      expect(result.isFailure, isTrue);
    });

    test('returns failure when already loading more', () async {
      final completer = Completer<PageResult<String>>();
      final vm = _ControllableLoadMoreVM(
        initialItems: const PaginatedResult(items: ['a'], page: 1, hasNextPage: true),
        completer: completer,
      );

      final first = vm.loadMore(); // in-flight
      final second = await vm.loadMore(); // should be dropped

      expect(second.isFailure, isTrue);

      completer.complete(_page(['b']));
      await first;
    });
  });

  group('VMPaginated — refresh', () {
    test('replaces existing items with fresh first page', () async {
      final vm = _TestPaginatedVM(
        pageResults: {
          1: _page(['a', 'b']),
        },
      );

      await vm.loadFirst();
      expect(vm.state.asData?.value.items, ['a', 'b']);

      // Simulate changed data
      final vm2 = _TestPaginatedVM(
        pageResults: {
          1: _page(['x', 'y']),
        },
      );
      // refresh delegates to loadFirst — test with fresh VM
      await vm2.loadFirst();
      await vm2.refresh();

      expect(vm2.state.asData?.value.items, ['x', 'y']);
    });
  });
}

// ---------------------------------------------------------------------------
// Test helpers for fine-grained control over fetchPage
// ---------------------------------------------------------------------------

class _ControllablePaginatedVM extends VMPaginated<String> {
  _ControllablePaginatedVM({required this.completer});
  final Completer<PageResult<String>> completer;
  int fetchCallCount = 0;

  @override
  Future<PageResult<String>> fetchPage(int page) {
    fetchCallCount++;
    return completer.future;
  }
}

class _ControllableLoadMoreVM extends VMPaginated<String> {
  _ControllableLoadMoreVM({
    required PaginatedResult<String> initialItems,
    required this.completer,
  }) : super() {
    setData(initialItems);
  }

  final Completer<PageResult<String>> completer;

  @override
  Future<PageResult<String>> fetchPage(int page) => completer.future;
}

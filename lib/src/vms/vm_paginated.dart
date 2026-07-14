import 'package:flutter/foundation.dart';
import 'package:vm_result/src/logging/vm_result_logger.dart';
import 'package:vm_result/src/models/paginated_result.dart';
import 'package:vm_result/src/models/result.dart';
import 'package:vm_result/src/vms/vm_result.dart';

/// Abstract ViewModel base class for paginated lists.
///
/// Extend this when managing a list that is loaded one page at a time.
/// The generic [S] is the item type; the ViewModel's state is
/// `Result<PaginatedResult<S>>`.
///
/// ## Usage
///
/// ```dart
/// class PostsViewModel extends VMPaginated<Post> {
///   PostsViewModel(this._repository);
///
///   final PostRepository _repository;
///
///   @override
///   Future<PageResult<Post>> fetchPage(int page) async {
///     final response = await _repository.getPosts(page: page);
///     return PageResult(
///       items: response.posts,
///       hasNextPage: response.hasNextPage,
///     );
///   }
/// }
/// ```
abstract class VMPaginated<S> extends VMResult<PaginatedResult<S>> {
  VMPaginated() : super(Result<PaginatedResult<S>>.initial());

  static const int _firstPage = 1;

  /// Fetches a single page of data from your data source.
  ///
  /// [page] is 1-based. Implement this in your subclass to call your
  /// repository or data source.
  @protected
  Future<PageResult<S>> fetchPage(int page);

  /// Loads the first page, replacing any existing items.
  ///
  /// Shows a full [Result.loading] state while in-flight.
  /// Drops duplicate calls if already executing — see [VMResult.run].
  Future<void> loadFirst() => run(
    () async {
      final result = await fetchPage(_firstPage);
      return PaginatedResult<S>(
        items: result.items,
        page: _firstPage,
        hasNextPage: result.hasNextPage,
      );
    },
  );

  /// Appends the next page of items to the current list.
  ///
  /// Does not show a full loading state — instead sets
  /// [PaginatedResult.isLoadingMore] to `true` while in-flight, allowing
  /// the UI to render an inline indicator without losing the existing list.
  ///
  /// On error the existing items are preserved: [PaginatedResult.isLoadingMore]
  /// is reset to `false` and the error is logged. The full [Result.error] state
  /// is intentionally **not** set to avoid blanking the list.
  ///
  /// Returns [ValueResult.failure] without mutating state if:
  /// - [loadFirst] or [refresh] is currently executing
  /// - there is no next page ([PaginatedResult.hasNextPage] is `false`)
  /// - a previous [loadMore] call is still in-flight
  Future<ValueResult<PaginatedResult<S>>> loadMore() async {
    if (isExecuting) {
      return ValueResult.failure(
        Exception('[$runtimeType]: loadMore dropped — loadFirst/refresh is in-flight.'),
      );
    }

    final current = state.asData?.value;
    if (current == null) {
      return ValueResult.failure(
        Exception('[$runtimeType]: loadMore called before first page was loaded.'),
      );
    }

    if (!current.hasNextPage) {
      return ValueResult.failure(
        Exception('[$runtimeType]: loadMore called but hasNextPage is false.'),
      );
    }

    if (current.isLoadingMore) {
      return ValueResult.failure(
        Exception('[$runtimeType]: loadMore dropped — already loading more.'),
      );
    }

    final nextPage = current.page + 1;
    setData(current.copyWith(isLoadingMore: true));

    try {
      final result = await fetchPage(nextPage);

      if (disposed) {
        return ValueResult.failure(
          Exception('[$runtimeType]: loadMore result discarded — ViewModel was disposed.'),
        );
      }

      // Re-read current state after the async gap to ensure it hasn't changed/refreshed
      final activeData = state.asData?.value;
      if (activeData == null || activeData.page != current.page) {
        return ValueResult.failure(Exception('State was modified or refreshed during fetch.'));
      }

      final updated = PaginatedResult<S>(
        items: [...current.items, ...result.items],
        page: nextPage,
        hasNextPage: result.hasNextPage,
      );
      setData(updated);
      return ValueResult.success(updated);
    } on Exception catch (e, s) {
      if (!disposed) {
        VMResultLogging.logger.error('[$runtimeType] loadMore error: $e', s);
        setData(current.copyWith(isLoadingMore: false));
      }
      return ValueResult.failure(e);
    }
  }

  /// Resets to the first page, replacing all existing items.
  ///
  /// Identical behaviour to [loadFirst].
  Future<void> refresh() => loadFirst();
}

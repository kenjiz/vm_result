import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_result.freezed.dart';

/// A single page of results returned by [VMPaginated.fetchPage].
///
/// Carries the items for that page and a flag indicating whether further
/// pages exist.
class PageResult<T> {
  const PageResult({required this.items, required this.hasNextPage});

  /// The items on this page.
  final List<T> items;

  /// Whether there are more pages available after this one.
  final bool hasNextPage;
}

/// The accumulated state of a paginated list managed by a [VMPaginated] ViewModel.
///
/// Holds all items fetched so far, the current page cursor, and indicators for
/// both inline load-more progress and whether more pages exist.
@freezed
abstract class PaginatedResult<T> with _$PaginatedResult<T> {
  const factory PaginatedResult({
    required List<T> items,
    required int page,
    required bool hasNextPage,
    @Default(false) bool isLoadingMore,
  }) = _PaginatedResult<T>;

  const PaginatedResult._();

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;
}

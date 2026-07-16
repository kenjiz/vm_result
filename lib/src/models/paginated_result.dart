import 'package:flutter/foundation.dart';

/// A single page of results returned by [VMPaginated.fetchPage].
///
/// Carries the items for that page and a flag indicating whether further
/// pages exist.
class PageResult<T> {
  /// Creates a [PageResult].
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
class PaginatedResult<T> {
  /// The accumulated list of items across all loaded pages.
  final List<T> items;

  /// The current page index that has been loaded.
  final int page;

  /// Whether more pages are available to be loaded.
  final bool hasNextPage;

  /// Whether a load-more operation is currently in-flight.
  final bool isLoadingMore;

  /// Creates a [PaginatedResult].
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.hasNextPage,
    this.isLoadingMore = false,
  });

  /// Whether the items list is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the items list is not empty.
  bool get isNotEmpty => items.isNotEmpty;

  /// Creates a copy of this [PaginatedResult] with the given fields replaced.
  PaginatedResult<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasNextPage,
    bool? isLoadingMore,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaginatedResult<T> &&
          other.runtimeType == runtimeType &&
          listEquals(other.items, items) &&
          other.page == page &&
          other.hasNextPage == hasNextPage &&
          other.isLoadingMore == isLoadingMore);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        page,
        hasNextPage,
        isLoadingMore,
      );

  @override
  String toString() =>
      'PaginatedResult<$T>(items: $items, page: $page, hasNextPage: $hasNextPage, isLoadingMore: $isLoadingMore)';
}

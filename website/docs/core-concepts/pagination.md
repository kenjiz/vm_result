---
sidebar_position: 3
---

# Paginated Lists

`VMPaginated<S>` is a dedicated ViewModel base class designed specifically for managing paginated lists (infinite scrolls). It abstracts away the complex state variables (loading status, item accumulation, pagination cursor, check for next page, etc.) into a single, cohesive state.

---

## 1. Core State Models

To manage pagination, the package uses three helper types:

### `PageResult<T>`
A plain model returned by your data fetch function (`fetchPage(int page)`).
```dart
class PageResult<T> {
  const PageResult({
    required this.items, 
    required this.hasNextPage,
  });
  
  final List<T> items;
  final bool hasNextPage;
}
```

### `PaginatedResult<T>`
A sealed state container holding the cumulative state of the list:
- `items`: All accumulated items loaded so far.
- `page`: The current page index (1-based).
- `hasNextPage`: Whether further pages exist.
- `isLoadingMore`: Whether a `loadMore` request is currently in-flight.

---

## 2. Implementing `VMPaginated`

To implement a paginated ViewModel:
1. Extend `VMPaginated<S>` where `S` is your list item type.
2. Override the abstract method `Future<PageResult<S>> fetchPage(int page)`.

```dart
import 'package:vm_result/vm_result.dart';

class PostsViewModel extends VMPaginated<Post> {
  PostsViewModel(this._repository);
  
  final PostRepository _repository;

  @override
  Future<PageResult<Post>> fetchPage(int page) async {
    // 1-based page query
    final response = await _repository.getPosts(page: page, limit: 20);
    
    return PageResult(
      items: response.posts,
      hasNextPage: response.hasNextPage,
    );
  }
}
```

---

## 3. Controlling Pagination in the UI

`VMPaginated` exposes three simple methods to manage list loading:

### `loadFirst()`
Fetches the first page of items. It transitions the state to the full-screen `ResultLoading` state.
* Call this in `initState()` of your screen or on initial load.

### `loadMore()`
Appends the next page of items to the list.
* It does **not** show a full-screen loading spinner. Instead, it sets `isLoadingMore: true` inside the state and notifies listeners, allowing your list view to append an inline spinner at the bottom while retaining all current items on screen.
* Safe against concurrency: `loadMore()` drops incoming calls if a previous `loadMore`, `loadFirst`, or `refresh` is currently running.
* Safe against stale states: Re-verifies state consistency after the fetch to protect against race conditions.

### `refresh()`
Resets the pagination counter to page 1 and fetches fresh data, replacing the current list.

---

## 4. UI Implementation Example

Here is how you bind `VMPaginated` to a scrollable `ListView` in Flutter:

```dart
class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late final PostsViewModel _viewModel;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _viewModel = PostsViewModel(PostRepository());
    _scrollController = ScrollController()..addListener(_onScroll);
    
    _viewModel.loadFirst(); // Load first page
  }

  void _onScroll() {
    // Trigger loadMore when reaching the bottom of the list
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: ResultBuilder<PaginatedResult<Post>>(
        listenable: _viewModel,
        builder: (context, state, child) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e) => Center(child: Text('Error: $e')),
            data: (paginatedData) {
              final posts = paginatedData.items;
              
              if (posts.isEmpty) {
                return const Center(child: Text('No posts found.'));
              }

              return RefreshIndicator(
                onRefresh: _viewModel.refresh,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: posts.length + (paginatedData.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Render an inline loading spinner at the bottom of the list
                    if (index == posts.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final post = posts[index];
                    return ListTile(
                      title: Text(post.title),
                      subtitle: Text(post.body),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

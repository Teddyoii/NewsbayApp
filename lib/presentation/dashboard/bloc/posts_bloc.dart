import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../../core/config/app_config.dart';
import '../../../domain/repositories/posts_repository.dart';
import 'posts_event.dart';
import 'posts_state.dart';

/// Debounces the search box (`SEARCH_DEBOUNCE_MS`, env-configurable) and
/// exposes an env-configurable page size (`PAGINATION_LIMIT`) for backend
/// pagination against either `/posts` or `/posts/search`.
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostsRepository postsRepository;
  final int pageLimit;
  final Duration debounceDuration;

  PostsBloc({
    required this.postsRepository,
    int? pageLimit,
    Duration? debounceDuration,
  })  : pageLimit = pageLimit ?? AppConfig.paginationLimit,
        debounceDuration = debounceDuration ??
            Duration(milliseconds: AppConfig.searchDebounceMs),
        super(const PostsState()) {
    on<PostsRefreshRequested>(_onRefreshRequested);
    on<PostsNextPageRequested>(_onNextPageRequested);

    // debounceTime + switchMap: waits for a pause in typing before firing,
    // and switchMap ensures that if a newer keystroke arrives before the
    // in-flight search resolves, the stale search's result is dropped
    // rather than racing with (and possibly overwriting) the latest one.
    on<PostsSearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: (events, mapper) =>
          events.debounceTime(this.debounceDuration).switchMap(mapper),
    );
  }

  Future<void> _onRefreshRequested(
    PostsRefreshRequested event,
    Emitter<PostsState> emit,
  ) async {
    await _fetchFirstPage(query: state.query, emit: emit);
  }

  Future<void> _onSearchQueryChanged(
    PostsSearchQueryChanged event,
    Emitter<PostsState> emit,
  ) async {
    await _fetchFirstPage(query: event.query, emit: emit);
  }

  Future<void> _fetchFirstPage({
    required String query,
    required Emitter<PostsState> emit,
  }) async {
    emit(state.copyWith(
      status: PostsStatus.loading,
      query: query,
      skip: 0,
      errorMessage: null,
    ));

    final trimmed = query.trim();
    final result = trimmed.isEmpty
        ? await postsRepository.getPosts(limit: pageLimit, skip: 0)
        : await postsRepository.searchPosts(
            query: trimmed, limit: pageLimit, skip: 0);

    result.fold(
      (failure) => emit(state.copyWith(
        status: PostsStatus.failure,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: page.items.isEmpty ? PostsStatus.empty : PostsStatus.success,
        posts: page.items,
        skip: page.skip + page.items.length,
        total: page.total,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onNextPageRequested(
    PostsNextPageRequested event,
    Emitter<PostsState> emit,
  ) async {
    if (!state.hasMore ||
        state.status == PostsStatus.loadingMore ||
        state.status == PostsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: PostsStatus.loadingMore));

    final trimmed = state.query.trim();
    final result = trimmed.isEmpty
        ? await postsRepository.getPosts(limit: pageLimit, skip: state.skip)
        : await postsRepository.searchPosts(
            query: trimmed, limit: pageLimit, skip: state.skip);

    result.fold(
      (failure) => emit(state.copyWith(
        // Keep already-loaded posts visible; only surface the pagination
        // error, don't blow away the list the user is scrolling.
        status: PostsStatus.success,
        errorMessage: failure.message,
      )),
      (page) => emit(state.copyWith(
        status: PostsStatus.success,
        posts: [...state.posts, ...page.items],
        skip: page.skip + page.items.length,
        total: page.total,
        hasMore: page.hasMore,
        errorMessage: null,
      )),
    );
  }
}

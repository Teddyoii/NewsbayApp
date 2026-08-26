import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_posts_app/core/error/failures.dart';
import 'package:flutter_posts_app/data/models/post_model.dart';
import 'package:flutter_posts_app/domain/entities/post_entity.dart';
import 'package:flutter_posts_app/presentation/dashboard/bloc/posts_bloc.dart';
import 'package:flutter_posts_app/presentation/dashboard/bloc/posts_event.dart';
import 'package:flutter_posts_app/presentation/dashboard/bloc/posts_state.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockPostsRepository postsRepository;

  const post1 = PostModel(id: 1, title: 'One', body: 'Body 1', userId: 1);
  const post2 = PostModel(id: 2, title: 'Two', body: 'Body 2', userId: 2);

  setUp(() {
    postsRepository = MockPostsRepository();
  });

  PostsBloc buildBloc() => PostsBloc(
        postsRepository: postsRepository,
        pageLimit: 2,
        // Short debounce so tests stay fast; still exercises the real
        // debounce+switchMap transformer, not a stub.
        debounceDuration: const Duration(milliseconds: 30),
      );

  group('PostsRefreshRequested', () {
    blocTest<PostsBloc, PostsState>(
      'fetchPosts_onSuccess_emitsLoadingThenSuccessWithHasMore',
      build: buildBloc,
      setUp: () {
        when(() => postsRepository.getPosts(limit: 2, skip: 0)).thenAnswer(
          (_) async => const Right(
            PaginatedResult<PostEntity>(
                items: [post1, post2], total: 5, skip: 0, limit: 2),
          ),
        );
      },
      act: (bloc) => bloc.add(const PostsRefreshRequested()),
      expect: () => [
        const PostsState(status: PostsStatus.loading),
        const PostsState(
          status: PostsStatus.success,
          posts: [post1, post2],
          skip: 2,
          total: 5,
          hasMore: true,
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'fetchPosts_emptyResult_emitsEmptyState',
      build: buildBloc,
      setUp: () {
        when(() => postsRepository.getPosts(limit: 2, skip: 0)).thenAnswer(
          (_) async => const Right(
            PaginatedResult<PostEntity>(items: [], total: 0, skip: 0, limit: 2),
          ),
        );
      },
      act: (bloc) => bloc.add(const PostsRefreshRequested()),
      expect: () => [
        const PostsState(status: PostsStatus.loading),
        const PostsState(status: PostsStatus.empty, skip: 0, total: 0, hasMore: false),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'fetchPosts_onNetworkError_emitsFailureState',
      build: buildBloc,
      setUp: () {
        when(() => postsRepository.getPosts(limit: 2, skip: 0)).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection.')),
        );
      },
      act: (bloc) => bloc.add(const PostsRefreshRequested()),
      expect: () => [
        const PostsState(status: PostsStatus.loading),
        const PostsState(
          status: PostsStatus.failure,
          errorMessage: 'No internet connection.',
        ),
      ],
    );
  });

  group('PostsNextPageRequested (pagination)', () {
    blocTest<PostsBloc, PostsState>(
      'nextPage_appendsResultsAndAdvancesSkip',
      build: buildBloc,
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [post1],
        skip: 1,
        total: 2,
        hasMore: true,
      ),
      setUp: () {
        // total: 2 — post1 (already loaded) + post2 (this page) is the
        // whole feed, so this is deliberately the *last* page:
        // hasMore = skip(1) + items.length(1) = 2, which is NOT < total(2).
        when(() => postsRepository.getPosts(limit: 2, skip: 1)).thenAnswer(
          (_) async => const Right(
            PaginatedResult<PostEntity>(items: [post2], total: 2, skip: 1, limit: 2),
          ),
        );
      },
      act: (bloc) => bloc.add(const PostsNextPageRequested()),
      expect: () => [
        const PostsState(
          status: PostsStatus.loadingMore,
          posts: [post1],
          skip: 1,
          total: 2,
          hasMore: true,
        ),
        const PostsState(
          status: PostsStatus.success,
          posts: [post1, post2],
          skip: 2,
          total: 2,
          hasMore: false,
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'nextPage_paginationExhausted_doesNothing',
      build: buildBloc,
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [post1, post2],
        skip: 2,
        total: 2,
        hasMore: false,
      ),
      act: (bloc) => bloc.add(const PostsNextPageRequested()),
      expect: () => <PostsState>[],
      verify: (_) {
        verifyNever(() => postsRepository.getPosts(
              limit: any(named: 'limit'),
              skip: any(named: 'skip'),
            ));
      },
    );
  });

  group('search debounce', () {
    blocTest<PostsBloc, PostsState>(
      'search_rapidKeystrokes_onlyLastQueryHitsRepository',
      build: buildBloc,
      setUp: () {
        when(() => postsRepository.searchPosts(
              query: 'flutter',
              limit: 2,
              skip: 0,
            )).thenAnswer(
          (_) async => const Right(
            PaginatedResult<PostEntity>(items: [post1], total: 1, skip: 0, limit: 2),
          ),
        );
      },
      act: (bloc) {
        bloc.add(const PostsSearchQueryChanged('f'));
        bloc.add(const PostsSearchQueryChanged('fl'));
        bloc.add(const PostsSearchQueryChanged('flutter'));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [
        const PostsState(status: PostsStatus.loading, query: 'flutter'),
        const PostsState(
          status: PostsStatus.success,
          posts: [post1],
          query: 'flutter',
          skip: 1,
          total: 1,
          hasMore: false,
        ),
      ],
      verify: (_) {
        // Only the final, debounced query should ever reach the repository.
        verify(() => postsRepository.searchPosts(query: 'flutter', limit: 2, skip: 0))
            .called(1);
        verifyNever(() => postsRepository.searchPosts(
            query: 'f', limit: any(named: 'limit'), skip: any(named: 'skip')));
        verifyNever(() => postsRepository.searchPosts(
            query: 'fl', limit: any(named: 'limit'), skip: any(named: 'skip')));
      },
    );

    blocTest<PostsBloc, PostsState>(
      'search_emptyQuery_fallsBackToDefaultPostsFeed',
      build: buildBloc,
      setUp: () {
        when(() => postsRepository.getPosts(limit: 2, skip: 0)).thenAnswer(
          (_) async => const Right(
            PaginatedResult<PostEntity>(items: [post1, post2], total: 2, skip: 0, limit: 2),
          ),
        );
      },
      act: (bloc) => bloc.add(const PostsSearchQueryChanged('')),
      wait: const Duration(milliseconds: 60),
      expect: () => [
        const PostsState(status: PostsStatus.loading),
        const PostsState(
          status: PostsStatus.success,
          posts: [post1, post2],
          skip: 2,
          total: 2,
          hasMore: false,
        ),
      ],
    );
  });
}

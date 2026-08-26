import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_posts_app/core/error/exceptions.dart';
import 'package:flutter_posts_app/core/error/failures.dart';
import 'package:flutter_posts_app/data/models/paginated_posts_model.dart';
import 'package:flutter_posts_app/data/models/post_model.dart';
import 'package:flutter_posts_app/data/repositories/posts_repository_impl.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockPostsRemoteDataSource remote;
  late PostsRepositoryImpl repository;

  const post = PostModel(id: 1, title: 'Title', body: 'Body', userId: 1);

  setUp(() {
    remote = MockPostsRemoteDataSource();
    repository = PostsRepositoryImpl(remote);
  });

  group('getPosts', () {
    test('getPosts_onSuccess_returnsPaginatedResult', () async {
      when(() => remote.getPosts(limit: 10, skip: 0)).thenAnswer(
        (_) async => const PaginatedPostsModel(
          posts: [post],
          total: 251,
          skip: 0,
          limit: 10,
        ),
      );

      final result = await repository.getPosts(limit: 10, skip: 0);

      expect(result, isA<Right>());
      result.fold((_) => fail('expected Right'), (page) {
        expect(page.items, hasLength(1));
        expect(page.total, 251);
        expect(page.hasMore, isTrue);
      });
    });

    test('getPosts_onNetworkError_returnsNetworkFailure', () async {
      when(() => remote.getPosts(limit: any(named: 'limit'), skip: any(named: 'skip')))
          .thenThrow(const NetworkException());

      final result = await repository.getPosts(limit: 10, skip: 0);

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('getPosts_on5xxServerError_returnsServerFailure', () async {
      when(() => remote.getPosts(limit: any(named: 'limit'), skip: any(named: 'skip')))
          .thenThrow(const ServerException('Internal error', statusCode: 500));

      final result = await repository.getPosts(limit: 10, skip: 0);

      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).statusCode, 500);
        },
        (_) => fail('expected Left'),
      );
    });

    test('getPosts_onMalformedResponse_returnsParsingFailure', () async {
      when(() => remote.getPosts(limit: any(named: 'limit'), skip: any(named: 'skip')))
          .thenThrow(const ParsingException());

      final result = await repository.getPosts(limit: 10, skip: 0);

      result.fold(
        (failure) => expect(failure, isA<ParsingFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('getPosts_paginationExhausted_hasMoreIsFalse', () async {
      when(() => remote.getPosts(limit: 10, skip: 250)).thenAnswer(
        (_) async => const PaginatedPostsModel(
          posts: [post],
          total: 251,
          skip: 250,
          limit: 10,
        ),
      );

      final result = await repository.getPosts(limit: 10, skip: 250);

      result.fold((_) => fail('expected Right'), (page) {
        expect(page.hasMore, isFalse);
      });
    });
  });

  group('searchPosts', () {
    test('searchPosts_noMatches_returnsEmptyListNotFailure', () async {
      when(() => remote.searchPosts(
            query: 'zzz',
            limit: any(named: 'limit'),
            skip: any(named: 'skip'),
          )).thenAnswer(
        (_) async => const PaginatedPostsModel(posts: [], total: 0, skip: 0, limit: 10),
      );

      final result = await repository.searchPosts(query: 'zzz', limit: 10, skip: 0);

      expect(result, isA<Right>());
      result.fold((_) => fail('expected Right'), (page) {
        expect(page.items, isEmpty);
        expect(page.hasMore, isFalse);
      });
    });
  });

  group('getPostById', () {
    test('getPostById_onSuccess_returnsPost', () async {
      when(() => remote.getPostById(1)).thenAnswer((_) async => post);

      final result = await repository.getPostById(1);

      expect(result, const Right(post));
    });

    test('getPostById_onNotFound_returnsServerFailure', () async {
      when(() => remote.getPostById(any()))
          .thenThrow(const ServerException('Not found', statusCode: 404));

      final result = await repository.getPostById(9999);

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}

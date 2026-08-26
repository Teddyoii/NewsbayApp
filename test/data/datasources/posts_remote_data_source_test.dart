import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_posts_app/core/error/exceptions.dart';
import 'package:flutter_posts_app/data/datasources/posts_remote_data_source.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockApiClient client;
  late PostsRemoteDataSourceImpl dataSource;

  final postsJson = {
    'posts': [
      {'id': 1, 'title': 'A', 'body': 'a', 'userId': 1},
    ],
    'total': 1,
    'skip': 0,
    'limit': 10,
  };

  setUp(() {
    client = MockApiClient();
    dataSource = PostsRemoteDataSourceImpl(client);
  });

  group('getPosts', () {
    test('getPosts_formsCorrectQueryParams_forPagination', () async {
      when(() => client.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => postsJson);

      await dataSource.getPosts(limit: 10, skip: 20);

      verify(() => client.get('/posts', queryParameters: {
            'limit': 10,
            'skip': 20,
          })).called(1);
    });

    test('getPosts_onSuccess_parsesEnvelope', () async {
      when(() => client.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => postsJson);

      final result = await dataSource.getPosts(limit: 10, skip: 0);

      expect(result.posts, hasLength(1));
      expect(result.total, 1);
    });
  });

  group('searchPosts', () {
    test('searchPosts_formsCorrectQueryParams_withQAndPagination', () async {
      when(() => client.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => postsJson);

      await dataSource.searchPosts(query: 'love', limit: 10, skip: 0);

      verify(() => client.get('/posts/search', queryParameters: {
            'q': 'love',
            'limit': 10,
            'skip': 0,
          })).called(1);
    });

    test('searchPosts_noMatches_returnsEmptyEnvelope', () async {
      when(() => client.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => {'posts': [], 'total': 0, 'skip': 0, 'limit': 10});

      final result =
          await dataSource.searchPosts(query: 'zzz', limit: 10, skip: 0);

      expect(result.posts, isEmpty);
      expect(result.total, 0);
    });
  });

  group('getPostById', () {
    test('getPostById_callsCorrectEndpoint', () async {
      when(() => client.get(any())).thenAnswer((_) async => {
            'id': 42,
            'title': 'T',
            'body': 'B',
            'userId': 5,
          });

      await dataSource.getPostById(42);

      verify(() => client.get('/posts/42')).called(1);
    });

    test('getPostById_onMalformedResponse_throwsParsingException', () async {
      when(() => client.get(any())).thenAnswer((_) async => {'title': 'no id'});

      expect(
        () => dataSource.getPostById(1),
        throwsA(isA<ParsingException>()),
      );
    });
  });
}

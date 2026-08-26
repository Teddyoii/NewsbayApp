import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_posts_app/core/error/exceptions.dart';
import 'package:flutter_posts_app/data/datasources/auth_remote_data_source.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockApiClient client;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    client = MockApiClient();
    dataSource = AuthRemoteDataSourceImpl(client);
  });

  group('login', () {
    test('login_formsCorrectRequest_withUsernamePasswordAndExpiry', () async {
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => {
          'id': 1,
          'username': 'emilys',
          'email': 'emily@x.com',
          'firstName': 'Emily',
          'lastName': 'Johnson',
          'accessToken': 'token-abc',
          'refreshToken': 'refresh-abc',
        },
      );

      await dataSource.login(username: 'emilys', password: 'emilyspass');

      verify(() => client.post('/auth/login', body: {
            'username': 'emilys',
            'password': 'emilyspass',
            'expiresInMins': 30,
          })).called(1);
    });

    test('login_onSuccess_parsesAccessTokenAndUser', () async {
      when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => {
          'id': 1,
          'username': 'emilys',
          'email': 'emily@x.com',
          'firstName': 'Emily',
          'lastName': 'Johnson',
          'accessToken': 'token-abc',
          'refreshToken': 'refresh-abc',
        },
      );

      final result =
          await dataSource.login(username: 'emilys', password: 'emilyspass');

      expect(result.accessToken, 'token-abc');
      expect(result.refreshToken, 'refresh-abc');
      expect(result.user.username, 'emilys');
    });

    test('login_whenClientThrows_propagatesException', () async {
      when(() => client.post(any(), body: any(named: 'body')))
          .thenThrow(const InvalidCredentialsException());

      expect(
        () => dataSource.login(username: 'bad', password: 'wrong'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  group('getCurrentUser', () {
    test('getCurrentUser_callsAuthMeEndpoint', () async {
      when(() => client.get(any())).thenAnswer((_) async => {
            'id': 1,
            'username': 'emilys',
          });

      await dataSource.getCurrentUser();

      verify(() => client.get('/auth/me')).called(1);
    });

    test('getCurrentUser_onMalformedResponse_throwsParsingException', () async {
      when(() => client.get(any())).thenAnswer((_) async => {
            // missing required 'id'
            'username': 'emilys',
          });

      expect(
        () => dataSource.getCurrentUser(),
        throwsA(isA<ParsingException>()),
      );
    });
  });
}

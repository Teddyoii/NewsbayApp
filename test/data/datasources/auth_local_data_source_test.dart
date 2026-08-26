import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_posts_app/core/error/exceptions.dart';
import 'package:flutter_posts_app/data/datasources/auth_local_data_source.dart';
import 'package:flutter_posts_app/data/models/user_model.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockBox box;
  late AuthLocalDataSourceImpl dataSource;

  const testUser = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily@x.com',
    firstName: 'Emily',
    lastName: 'Johnson',
  );

  setUp(() {
    box = MockBox();
    dataSource = AuthLocalDataSourceImpl(box);
  });

  group('saveSession', () {
    test('saveSession_storesAccessTokenRefreshTokenAndUserJson', () async {
      when(() => box.put(any(), any())).thenAnswer((_) async {});

      await dataSource.saveSession(
        accessToken: 'access-123',
        refreshToken: 'refresh-123',
        user: testUser,
      );

      verify(() => box.put(AuthLocalDataSourceImpl.keyAccessToken, 'access-123'))
          .called(1);
      verify(() =>
              box.put(AuthLocalDataSourceImpl.keyRefreshToken, 'refresh-123'))
          .called(1);
      verify(() => box.put(
            AuthLocalDataSourceImpl.keyUser,
            jsonEncode(testUser.toJson()),
          )).called(1);
    });

    test('saveSession_whenBoxThrows_throwsCacheException', () async {
      when(() => box.put(any(), any())).thenThrow(Exception('disk error'));

      expect(
        () => dataSource.saveSession(
          accessToken: 'a',
          refreshToken: 'r',
          user: testUser,
        ),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('getAccessToken', () {
    test('getAccessToken_returnsStoredToken', () async {
      when(() => box.get(AuthLocalDataSourceImpl.keyAccessToken))
          .thenReturn('stored-token');

      final token = await dataSource.getAccessToken();

      expect(token, 'stored-token');
    });

    test('getAccessToken_whenNothingStored_returnsNull', () async {
      when(() => box.get(AuthLocalDataSourceImpl.keyAccessToken))
          .thenReturn(null);

      final token = await dataSource.getAccessToken();

      expect(token, isNull);
    });

    test('getAccessToken_whenBoxThrows_throwsCacheException', () async {
      when(() => box.get(AuthLocalDataSourceImpl.keyAccessToken))
          .thenThrow(Exception('corrupt box'));

      expect(() => dataSource.getAccessToken(), throwsA(isA<CacheException>()));
    });
  });

  group('getUser', () {
    test('getUser_whenNoUserStored_returnsNull', () async {
      when(() => box.get(AuthLocalDataSourceImpl.keyUser)).thenReturn(null);

      final user = await dataSource.getUser();

      expect(user, isNull);
    });

    test('getUser_decodesStoredJsonBackIntoUserModel', () async {
      when(() => box.get(AuthLocalDataSourceImpl.keyUser))
          .thenReturn(jsonEncode(testUser.toJson()));

      final user = await dataSource.getUser();

      expect(user, testUser);
    });

    test('getUser_onMalformedStoredJson_throwsCacheException', () async {
      when(() => box.get(AuthLocalDataSourceImpl.keyUser))
          .thenReturn('not valid json');

      expect(() => dataSource.getUser(), throwsA(isA<CacheException>()));
    });
  });

  group('clearSession', () {
    test('clearSession_clearsTheBox', () async {
      when(() => box.clear()).thenAnswer((_) async => 0);

      await dataSource.clearSession();

      verify(() => box.clear()).called(1);
    });

    test('clearSession_whenBoxThrows_throwsCacheException', () async {
      when(() => box.clear()).thenThrow(Exception('disk error'));

      expect(() => dataSource.clearSession(), throwsA(isA<CacheException>()));
    });
  });
}

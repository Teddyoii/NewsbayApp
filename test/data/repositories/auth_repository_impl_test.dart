import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_posts_app/core/error/exceptions.dart';
import 'package:flutter_posts_app/core/error/failures.dart';
import 'package:flutter_posts_app/data/models/auth_response_model.dart';
import 'package:flutter_posts_app/data/models/user_model.dart';
import 'package:flutter_posts_app/data/repositories/auth_repository_impl.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late AuthRepositoryImpl repository;

  const testUser = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily@x.com',
    firstName: 'Emily',
    lastName: 'Johnson',
  );

  const authResponse = AuthResponseModel(
    user: testUser,
    accessToken: 'access-123',
    refreshToken: 'refresh-123',
  );

  setUpAll(() {
    // mocktail needs a registered fallback instance for any type used with
    // `any(named: ...)` — without this, the *next* `when()`/`verify()` call
    // in the file can also fail with a confusing, unrelated error because
    // mocktail's internal matcher stack is left in a bad state.
    registerFallbackValue(testUser);
  });

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(remote: remote, local: local);
  });

  group('login', () {
    test('login_withValidCredentials_returnsUserAndStoresToken', () async {
      when(() => remote.login(username: 'emilys', password: 'emilyspass'))
          .thenAnswer((_) async => authResponse);
      when(() => local.saveSession(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            user: any(named: 'user'),
          )).thenAnswer((_) async {});

      final result = await repository.login(
        username: 'emilys',
        password: 'emilyspass',
      );

      expect(result, Right(testUser));
      verify(() => local.saveSession(
            accessToken: 'access-123',
            refreshToken: 'refresh-123',
            user: testUser,
          )).called(1);
    });

    test('login_withInvalidCredentials_returnsInvalidCredentialsFailure',
        () async {
      when(() => remote.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenThrow(const InvalidCredentialsException('Invalid credentials'));

      final result = await repository.login(
        username: 'bad',
        password: 'wrong',
      );

      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<InvalidCredentialsFailure>()),
        (_) => fail('expected Left'),
      );
      verifyNever(() => local.saveSession(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            user: any(named: 'user'),
          ));
    });

    test('login_onNetworkFailure_returnsNetworkFailure', () async {
      when(() => remote.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenThrow(const NetworkException());

      final result = await repository.login(username: 'x', password: 'y');

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('login_whenLocalSaveFails_returnsCacheFailure', () async {
      when(() => remote.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenAnswer((_) async => authResponse);
      when(() => local.saveSession(
            accessToken: any(named: 'accessToken'),
            refreshToken: any(named: 'refreshToken'),
            user: any(named: 'user'),
          )).thenThrow(const CacheException());

      final result = await repository.login(username: 'emilys', password: 'emilyspass');

      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('logout', () {
    test('logout_clearsLocalSession_returnsRight', () async {
      when(() => local.clearSession()).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, const Right<Failure, void>(null));
      verify(() => local.clearSession()).called(1);
    });
  });

  group('session restore', () {
    test('isLoggedIn_withStoredToken_returnsTrue', () async {
      when(() => local.getAccessToken()).thenAnswer((_) async => 'token');

      expect(await repository.isLoggedIn(), isTrue);
    });

    test('isLoggedIn_withNoToken_returnsFalse', () async {
      when(() => local.getAccessToken()).thenAnswer((_) async => null);

      expect(await repository.isLoggedIn(), isFalse);
    });

    test('getPersistedUser_returnsCachedUser_whenPresent', () async {
      when(() => local.getUser()).thenAnswer((_) async => testUser);

      final user = await repository.getPersistedUser();

      expect(user, testUser);
    });

    test('getPersistedUser_onCacheException_returnsNull', () async {
      when(() => local.getUser()).thenThrow(const CacheException());

      final user = await repository.getPersistedUser();

      expect(user, isNull);
    });
  });
}

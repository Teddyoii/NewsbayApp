import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_posts_app/core/error/failures.dart';
import 'package:flutter_posts_app/data/models/user_model.dart';
import 'package:flutter_posts_app/presentation/auth/bloc/auth_bloc.dart';
import 'package:flutter_posts_app/presentation/auth/bloc/auth_event.dart';
import 'package:flutter_posts_app/presentation/auth/bloc/auth_state.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockAuthRepository authRepository;

  const testUser = UserModel(
    id: 1,
    username: 'emilys',
    email: 'emily@x.com',
    firstName: 'Emily',
    lastName: 'Johnson',
  );

  setUp(() {
    authRepository = MockAuthRepository();
  });

  AuthBloc buildBloc() => AuthBloc(authRepository: authRepository);

  group('AuthSessionCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'sessionCheck_withPersistedSession_emitsAuthenticated',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.isLoggedIn()).thenAnswer((_) async => true);
        when(() => authRepository.getPersistedUser())
            .thenAnswer((_) async => testUser);
      },
      act: (bloc) => bloc.add(const AuthSessionCheckRequested()),
      expect: () => [
        const AuthSessionLoading(),
        const AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'sessionCheck_withNoToken_emitsUnauthenticated',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.isLoggedIn()).thenAnswer((_) async => false);
      },
      act: (bloc) => bloc.add(const AuthSessionCheckRequested()),
      expect: () => [
        const AuthSessionLoading(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'sessionCheck_tokenPresentButNoCachedUser_emitsUnauthenticated',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.isLoggedIn()).thenAnswer((_) async => true);
        when(() => authRepository.getPersistedUser())
            .thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(const AuthSessionCheckRequested()),
      expect: () => [
        const AuthSessionLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'login_withValidCredentials_returnsUserAndStoresToken emits Authenticated',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => const Right(testUser));
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: 'emilys', password: 'emilyspass'),
      ),
      expect: () => [
        const AuthLoginInProgress(),
        const AuthAuthenticated(testUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'login_withInvalidCredentials_emitsLoginFailure',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenAnswer(
          (_) async => const Left(InvalidCredentialsFailure('Invalid username or password.')),
        );
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: 'bad', password: 'wrong'),
      ),
      expect: () => [
        const AuthLoginInProgress(),
        const AuthLoginFailure('Invalid username or password.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'login_onNetworkFailure_emitsLoginFailureWithNetworkMessage',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => const Left(NetworkFailure('No internet connection.')));
      },
      act: (bloc) => bloc.add(
        const AuthLoginRequested(username: 'emilys', password: 'emilyspass'),
      ),
      expect: () => [
        const AuthLoginInProgress(),
        const AuthLoginFailure('No internet connection.'),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'logout_clearsSession_emitsUnauthenticated',
      build: buildBloc,
      setUp: () {
        when(() => authRepository.logout()).thenAnswer((_) async => const Right(null));
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthUnauthenticated()],
      verify: (_) {
        verify(() => authRepository.logout()).called(1);
      },
    );
  });
}

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Calls POST /auth/login, persists the token + user on success.
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  });

  /// Clears any persisted session.
  Future<Either<Failure, void>> logout();

  /// Returns the persisted user if a session exists locally, without
  /// hitting the network — used for the splash/session-restore check.
  Future<UserEntity?> getPersistedUser();

  /// Whether a token is currently stored.
  Future<bool> isLoggedIn();
}

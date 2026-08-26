import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial / checking persisted session on cold start.
class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthSessionLoading extends AuthState {
  const AuthSessionLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Submitting the login form.
class AuthLoginInProgress extends AuthState {
  const AuthLoginInProgress();
}

class AuthLoginFailure extends AuthState {
  final String message;

  const AuthLoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

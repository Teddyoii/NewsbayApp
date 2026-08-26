import 'package:equatable/equatable.dart';


abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// 4xx/5xx responses that reached the server (includes wrong credentials).
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Specifically wrong username/password on login (HTTP 400 from DummyJSON).
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([
    super.message = 'Invalid username or password.',
  ]);
}

/// No connectivity / timeout / DNS failure etc. — the request never got a
/// response from the server.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

/// Response body didn't match the expected shape.
class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Unexpected response from server.']);
}

/// Local storage (Hive) read/write failure.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

/// Catch-all for anything unforeseen.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}

/// Exceptions live only in the data layer (remote/local data sources).
/// Repositories catch these and translate them into [Failure]s so nothing
/// raw ever leaks into domain/presentation.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException(this.message, {this.statusCode});
}

class InvalidCredentialsException implements Exception {
  final String message;

  const InvalidCredentialsException([
    this.message = 'Invalid username or password.',
  ]);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection.']);
}

class ParsingException implements Exception {
  final String message;

  const ParsingException([this.message = 'Unexpected response from server.']);
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Local storage error.']);
}

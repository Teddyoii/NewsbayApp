class AppConfig {
  AppConfig._();

  static const String envName = String.fromEnvironment(
    'ENV_NAME',
    defaultValue: 'Development',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dummyjson.com',
  );

  static const int paginationLimit = int.fromEnvironment(
    'PAGINATION_LIMIT',
    defaultValue: 10,
  );

  static const int searchDebounceMs = int.fromEnvironment(
    'SEARCH_DEBOUNCE_MS',
    defaultValue: 300,
  );

  static bool get isProduction => envName.toLowerCase() == 'production';

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  /// Handy for a debug banner label, e.g. "DEV · limit=10 · debounce=300ms".
  static String get debugLabel =>
      '$envName · limit=$paginationLimit · debounce=${searchDebounceMs}ms';
}

import 'bootstrap.dart';

/// Default entry point. Run with explicit --dart-define flags for a real
/// environment, e.g.:
///   flutter run --dart-define=API_BASE_URL=https://dummyjson.com \
///     --dart-define=PAGINATION_LIMIT=10 --dart-define=SEARCH_DEBOUNCE_MS=300
/// Without flags, AppConfig's defaultValues match the Dev config.
Future<void> main() async {
  await bootstrap();
}

import 'bootstrap.dart';

/// flutter run -t lib/main_staging.dart \
///   --dart-define=ENV_NAME=Staging \
///   --dart-define=API_BASE_URL=https://dummyjson.com \
///   --dart-define=PAGINATION_LIMIT=15 \
///   --dart-define=SEARCH_DEBOUNCE_MS=500
Future<void> main() async {
  await bootstrap();
}

import 'bootstrap.dart';

/// flutter run -t lib/main_dev.dart \
///   --dart-define=ENV_NAME=Development \
///   --dart-define=API_BASE_URL=https://dummyjson.com \
///   --dart-define=PAGINATION_LIMIT=10 \
///   --dart-define=SEARCH_DEBOUNCE_MS=300
Future<void> main() async {
  await bootstrap();
}

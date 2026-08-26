import 'bootstrap.dart';

/// flutter run -t lib/main_prod.dart \
///   --dart-define=ENV_NAME=Production \
///   --dart-define=API_BASE_URL=https://dummyjson.com \
///   --dart-define=PAGINATION_LIMIT=20 \
///   --dart-define=SEARCH_DEBOUNCE_MS=800
Future<void> main() async {
  await bootstrap();
}

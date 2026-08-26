import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_posts_app/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('defaults_matchDevEnvironmentValues_whenNoDartDefinesPassed', () {
      // The test runner itself doesn't pass --dart-define flags, so these
      // assert the *default* values baked into AppConfig — which are
      // deliberately set to mirror the Dev environment from the PDF's
      // config table, so `flutter run` with no flags still behaves sanely.
      expect(AppConfig.apiBaseUrl, 'https://dummyjson.com');
      expect(AppConfig.paginationLimit, 10);
      expect(AppConfig.searchDebounceMs, 300);
      expect(AppConfig.envName, 'Development');
    });

    test('isProduction_falseByDefault', () {
      expect(AppConfig.isProduction, isFalse);
    });

    test('debugLabel_includesEnvNameLimitAndDebounce', () {
      expect(AppConfig.debugLabel, contains('Development'));
      expect(AppConfig.debugLabel, contains('limit=10'));
      expect(AppConfig.debugLabel, contains('debounce=300ms'));
    });
  });
}

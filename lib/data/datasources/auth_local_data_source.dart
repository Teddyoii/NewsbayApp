import 'dart:convert';

import 'package:hive/hive.dart';

import '../../core/error/exceptions.dart';
import '../models/user_model.dart';

/// Persists the session locally.
///
/// Choice of storage: Hive over shared_preferences / flutter_secure_storage.
/// Justification (see README "Auth implementation" section):
///   - Hive is fast (no platform channel round-trip per read like
///     shared_preferences), works well for structured data (we store the
///     user as a JSON string alongside the token) and is already a
///     dependency-light, pure-Dart option that's trivial to mock in tests
///     (just use `Hive.init` with a temp dir, no plugin channel to stub).
///   - flutter_secure_storage would be the stronger choice for a
///     production app (Keychain/Keystore-backed), but it requires a
///     MethodChannel that's awkward to unit test without extra
///     integration-test scaffolding — overkill for this one-day scope.
///     Noted as a "Known Limitation" in the PR.
abstract class AuthLocalDataSource {
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  });

  Future<String?> getAccessToken();

  Future<UserModel?> getUser();

  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String boxName = 'authBox';
  static const String keyAccessToken = 'accessToken';
  static const String keyRefreshToken = 'refreshToken';
  static const String keyUser = 'user';

  final Box _box;

  AuthLocalDataSourceImpl(this._box);

  static Future<Box> openBox() => Hive.openBox(boxName);

  @override
  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) async {
    try {
      await _box.put(keyAccessToken, accessToken);
      await _box.put(keyRefreshToken, refreshToken);
      await _box.put(keyUser, jsonEncode(user.toJson()));
    } catch (_) {
      throw const CacheException('Failed to persist session.');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return _box.get(keyAccessToken) as String?;
    } catch (_) {
      throw const CacheException('Failed to read session.');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final raw = _box.get(keyUser) as String?;
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException('Failed to read cached user.');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _box.clear();
    } catch (_) {
      throw const CacheException('Failed to clear session.');
    }
  }
}

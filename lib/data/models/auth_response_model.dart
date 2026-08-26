import '../../core/error/exceptions.dart';
import 'user_model.dart';

/// DummyJSON's `/auth/login` returns the user fields and the tokens flattened
/// into one object, e.g.:
/// `{ id, username, email, firstName, lastName, image, accessToken, refreshToken }`
class AuthResponseModel {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      return AuthResponseModel(
        user: UserModel.fromJson(json),
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String? ?? '',
      );
    } catch (_) {
      throw const ParsingException('Failed to parse login response.');
    }
  }
}

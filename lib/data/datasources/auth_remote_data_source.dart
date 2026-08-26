import '../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  });

  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    final json = await client.post('/auth/login', body: {
      'username': username,
      'password': password,
      'expiresInMins': 30,
    });
    return AuthResponseModel.fromJson(json);
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final json = await client.get('/auth/me');
    return UserModel.fromJson(json);
  }
}

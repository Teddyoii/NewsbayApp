import 'package:hive/hive.dart';

import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/posts_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/posts_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/posts_repository.dart';
import '../network/api_client.dart';

class Injector {
  final AuthRepository authRepository;
  final PostsRepository postsRepository;
  final AuthLocalDataSource authLocalDataSource;

  Injector._({
    required this.authRepository,
    required this.postsRepository,
    required this.authLocalDataSource,
  });

  static Future<Injector> build() async {
    final Box authBox = await AuthLocalDataSourceImpl.openBox();
    final authLocal = AuthLocalDataSourceImpl(authBox);

    final apiClient = ApiClient();

    apiClient.tokenProvider = () {
      final token = authBox.get(AuthLocalDataSourceImpl.keyAccessToken);
      return token is String ? token : null;
    };

    final authRemote = AuthRemoteDataSourceImpl(apiClient);
    final postsRemote = PostsRemoteDataSourceImpl(apiClient);

    final authRepository =
        AuthRepositoryImpl(remote: authRemote, local: authLocal);
    final postsRepository = PostsRepositoryImpl(postsRemote);

    return Injector._(
      authRepository: authRepository,
      postsRepository: postsRepository,
      authLocalDataSource: authLocal,
    );
  }
}

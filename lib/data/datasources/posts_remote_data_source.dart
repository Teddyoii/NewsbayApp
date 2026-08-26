import '../../core/network/api_client.dart';
import '../models/paginated_posts_model.dart';
import '../models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<PaginatedPostsModel> getPosts({required int limit, required int skip});

  Future<PaginatedPostsModel> searchPosts({
    required String query,
    required int limit,
    required int skip,
  });

  Future<PostModel> getPostById(int id);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final ApiClient client;

  PostsRemoteDataSourceImpl(this.client);

  @override
  Future<PaginatedPostsModel> getPosts({
    required int limit,
    required int skip,
  }) async {
    final json = await client.get('/posts', queryParameters: {
      'limit': limit,
      'skip': skip,
    });
    return PaginatedPostsModel.fromJson(json);
  }

  @override
  Future<PaginatedPostsModel> searchPosts({
    required String query,
    required int limit,
    required int skip,
  }) async {
    final json = await client.get('/posts/search', queryParameters: {
      'q': query,
      'limit': limit,
      'skip': skip,
    });
    return PaginatedPostsModel.fromJson(json);
  }

  @override
  Future<PostModel> getPostById(int id) async {
    final json = await client.get('/posts/$id');
    return PostModel.fromJson(json);
  }
}

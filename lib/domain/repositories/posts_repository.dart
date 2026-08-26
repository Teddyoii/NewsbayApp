import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/post_entity.dart';

abstract class PostsRepository {
  /// GET /posts?limit=&skip=  — used for the default (non-search) feed.
  Future<Either<Failure, PaginatedResult<PostEntity>>> getPosts({
    required int limit,
    required int skip,
  });

  /// GET /posts/search?q=&limit=&skip=
  Future<Either<Failure, PaginatedResult<PostEntity>>> searchPosts({
    required String query,
    required int limit,
    required int skip,
  });

  /// GET /posts/{id}
  Future<Either<Failure, PostEntity>> getPostById(int id);
}

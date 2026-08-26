import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remote;

  PostsRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, PaginatedResult<PostEntity>>> getPosts({
    required int limit,
    required int skip,
  }) async {
    try {
      final model = await remote.getPosts(limit: limit, skip: skip);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, PaginatedResult<PostEntity>>> searchPosts({
    required String query,
    required int limit,
    required int skip,
  }) async {
    try {
      final model =
          await remote.searchPosts(query: query, limit: limit, skip: skip);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_map(e));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(int id) async {
    try {
      final model = await remote.getPostById(id);
      return Right(model);
    } catch (e) {
      return Left(_map(e));
    }
  }

  Failure _map(Object e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is ParsingException) return ParsingFailure(e.message);
    if (e is ServerException) {
      return ServerFailure(e.message, statusCode: e.statusCode);
    }
    if (e is InvalidCredentialsException) {
      return ServerFailure(e.message, statusCode: 401);
    }
    return const UnknownFailure();
  }
}

import '../../core/error/exceptions.dart';
import '../../domain/entities/post_entity.dart';
import 'post_model.dart';

class PaginatedPostsModel {
  final List<PostModel> posts;
  final int total;
  final int skip;
  final int limit;

  const PaginatedPostsModel({
    required this.posts,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory PaginatedPostsModel.fromJson(Map<String, dynamic> json) {
    try {
      final postsJson = json['posts'] as List? ?? const [];
      return PaginatedPostsModel(
        posts: postsJson
            .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num?)?.toInt() ?? 0,
        skip: (json['skip'] as num?)?.toInt() ?? 0,
        limit: (json['limit'] as num?)?.toInt() ?? postsJson.length,
      );
    } catch (_) {
      throw const ParsingException('Failed to parse posts list.');
    }
  }

  PaginatedResult<PostEntity> toEntity() => PaginatedResult<PostEntity>(
        items: posts,
        total: total,
        skip: skip,
        limit: limit,
      );
}

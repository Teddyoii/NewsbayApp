import '../../core/error/exceptions.dart';
import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.userId,
    super.tags,
    super.likes,
    super.dislikes,
    super.views,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    try {
      final reactions = json['reactions'];
      int likes = 0;
      int dislikes = 0;
      if (reactions is Map) {
        likes = (reactions['likes'] as num?)?.toInt() ?? 0;
        dislikes = (reactions['dislikes'] as num?)?.toInt() ?? 0;
      } else if (reactions is num) {
        // Older DummyJSON payloads returned a raw int for reactions.
        likes = reactions.toInt();
      }

      return PostModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        userId: json['userId'] as int? ?? 0,
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        likes: likes,
        dislikes: dislikes,
        views: (json['views'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      throw const ParsingException('Failed to parse post.');
    }
  }
}

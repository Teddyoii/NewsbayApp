import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final int likes;
  final int dislikes;
  final int views;

  const PostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.tags = const [],
    this.likes = 0,
    this.dislikes = 0,
    this.views = 0,
  });

  @override
  List<Object?> get props =>
      [id, title, body, userId, tags, likes, dislikes, views];
}

/// Generic pagination envelope mirroring DummyJSON's
/// `{ posts, total, skip, limit }` shape, generalized to any entity list.
class PaginatedResult<T> extends Equatable {
  final List<T> items;
  final int total;
  final int skip;
  final int limit;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + items.length < total;

  @override
  List<Object?> get props => [items, total, skip, limit];
}

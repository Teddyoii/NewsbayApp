import 'package:equatable/equatable.dart';

import '../../../domain/entities/post_entity.dart';

enum PostsStatus { initial, loading, loadingMore, success, empty, failure }

class PostsState extends Equatable {
  final PostsStatus status;
  final List<PostEntity> posts;
  final String query;
  final int skip;
  final int total;
  final bool hasMore;
  final String? errorMessage;

  const PostsState({
    this.status = PostsStatus.initial,
    this.posts = const [],
    this.query = '',
    this.skip = 0,
    this.total = 0,
    this.hasMore = true,
    this.errorMessage,
  });

  bool get isSearching => query.trim().isNotEmpty;

  PostsState copyWith({
    PostsStatus? status,
    List<PostEntity>? posts,
    String? query,
    int? skip,
    int? total,
    bool? hasMore,
    String? errorMessage,
  }) {
    return PostsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      query: query ?? this.query,
      skip: skip ?? this.skip,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, posts, query, skip, total, hasMore, errorMessage];
}

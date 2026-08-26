import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/repositories/posts_repository.dart';
import '../../shared/widgets/state_views.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  /// The list-item entity we already have, shown instantly so the screen
  /// isn't blank while the network call for the "full" detail resolves.
  final PostEntity? preview;

  const PostDetailPage({super.key, required this.postId, this.preview});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Future<_DetailResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DetailResult> _load() async {
    final repo = context.read<PostsRepository>();
    final result = await repo.getPostById(widget.postId);
    return result.fold(
      (failure) => _DetailResult.failure(failure.message),
      (post) => _DetailResult.success(post),
    );
  }

  void _retry() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: FutureBuilder<_DetailResult>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            if (widget.preview != null) {
              return _DetailBody(post: widget.preview!);
            }
            return const LoadingView();
          }
          final result = snapshot.data!;
          if (result.post != null) {
            return _DetailBody(post: result.post!);
          }
          if (widget.preview != null) {
            // Keep showing what we have even if the "full" fetch failed.
            return _DetailBody(post: widget.preview!);
          }
          return ErrorView(
            message: result.errorMessage ?? 'Failed to load post.',
            onRetry: _retry,
          );
        },
      ),
    );
  }
}

class _DetailResult {
  final PostEntity? post;
  final String? errorMessage;

  _DetailResult.success(this.post) : errorMessage = null;
  _DetailResult.failure(this.errorMessage) : post = null;
}

class _DetailBody extends StatelessWidget {
  final PostEntity post;

  const _DetailBody({required this.post});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post.title, style: AppTextStyles.h1),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary1,
                child: Text(
                  'U${post.userId}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('User ${post.userId}', style: AppTextStyles.bodyMuted),
            ],
          ),
          const SizedBox(height: 20),
          Text(post.body, style: AppTextStyles.body.copyWith(height: 1.5)),
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: post.tags
                  .map((t) => Chip(
                        label: Text('#$t', style: AppTextStyles.caption),
                        backgroundColor: AppColors.surface,
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.favorite, size: 16, color: AppColors.critical),
              const SizedBox(width: 4),
              Text('${post.likes}', style: AppTextStyles.bodyMuted),
              const SizedBox(width: 16),
              const Icon(Icons.thumb_down_alt_outlined,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: 4),
              Text('${post.dislikes}', style: AppTextStyles.bodyMuted),
              const SizedBox(width: 16),
              const Icon(Icons.remove_red_eye_outlined,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: 4),
              Text('${post.views}', style: AppTextStyles.bodyMuted),
            ],
          ),
        ],
      ),
    );
  }
}

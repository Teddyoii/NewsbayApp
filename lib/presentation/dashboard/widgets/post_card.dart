import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/post_entity.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onTap;

  const PostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
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
            const SizedBox(height: 10),
            Text(
              post.title,
              style: AppTextStyles.h2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              post.body,
              style: AppTextStyles.bodyMuted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.favorite, size: 14, color: AppColors.critical),
                const SizedBox(width: 4),
                Text('${post.likes}', style: AppTextStyles.caption),
                const SizedBox(width: 14),
                const Icon(Icons.remove_red_eye_outlined,
                    size: 14, color: AppColors.secondary),
                const SizedBox(width: 4),
                Text('${post.views}', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

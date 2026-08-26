import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/post_entity.dart';

/// Fixed-width card used in the dashboard's horizontal "Featured Posts"
/// carousel — a colored hero block on top (DummyJSON has no post images, so
/// a gradient + icon stands in, per the design's colored placeholder block)
/// with title/author/likes on a white footer below.
class FeaturedPostCard extends StatelessWidget {
  final PostEntity post;
  final VoidCallback onTap;

  const FeaturedPostCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        height: 196,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 96,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.heroGradient,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.menu_book_rounded,
                  color: AppColors.white, size: 30),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post.title,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text('User ${post.userId}', style: AppTextStyles.caption),
                        const Spacer(),
                        const Icon(Icons.favorite, size: 12, color: AppColors.critical),
                        const SizedBox(width: 3),
                        Text('${post.likes}', style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
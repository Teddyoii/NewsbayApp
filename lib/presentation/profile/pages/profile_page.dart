import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/user_entity.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

class ProfilePage extends StatelessWidget {
  final UserEntity user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text('Profile', style: AppTextStyles.h2),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary1,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(user.fullName.isEmpty ? user.username : user.fullName,
                style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(user.email, style: AppTextStyles.bodyMuted),
            const SizedBox(height: 28),
            _MenuTile(icon: Icons.settings_outlined, label: 'Settings'),
            _MenuTile(icon: Icons.people_outline, label: 'My Friends'),
            _MenuTile(icon: Icons.favorite_border, label: 'My Favourite'),
            _MenuTile(icon: Icons.star_border, label: 'Latest Reviews'),
            _MenuTile(icon: Icons.rss_feed, label: 'Followers'),
            const Spacer(),
            _MenuTile(
              icon: Icons.power_settings_new,
              label: 'Log Out',
              color: AppColors.critical,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Log out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context
                              .read<AuthBloc>()
                              .add(const AuthLogoutRequested());
                        },
                        child: const Text('Log Out',
                            style: TextStyle(color: AppColors.critical)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.onSurface;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: tileColor),
      title: Text(label, style: AppTextStyles.body.copyWith(color: tileColor)),
    );
  }
}

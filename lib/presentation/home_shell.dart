import 'package:flutter/material.dart';
import 'package:flutter_posts_app/presentation/dashboard/pages/dashboard_page.dart';
import 'package:flutter_posts_app/presentation/profile/pages/profile_page.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/user_entity.dart';


/// Bottom-nav shell matching the design's tab bar (Home, Top Rate, News,
/// Chat, Profile). Only Home (Dashboard) and Profile are implemented per
/// the assessment's scope — the other three are stubbed placeholders so
/// the nav bar matches the Figma reference without over-building
/// out-of-scope screens.
class HomeShell extends StatefulWidget {
  final UserEntity user;

  const HomeShell({super.key, required this.user});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(user: widget.user),
      const _PlaceholderTab(label: 'Top Rate'),
      const _PlaceholderTab(label: 'News'),
      const _PlaceholderTab(label: 'Chat'),
      ProfilePage(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Top Rate'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;

  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label — out of scope for this assessment',
        style: const TextStyle(color: AppColors.secondary),
        textAlign: TextAlign.center,
      ),
    );
  }
}

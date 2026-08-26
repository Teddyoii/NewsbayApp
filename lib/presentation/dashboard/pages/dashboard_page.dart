import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/posts_repository.dart';
import '../../post_detail/pages/post_detail_page.dart';
import '../../shared/widgets/state_views.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/featured_post_card.dart';
import '../widgets/post_card.dart';

class DashboardPage extends StatefulWidget {
  final UserEntity user;

  const DashboardPage({super.key, required this.user});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  /// The design's "Featured Posts" carousel has no equivalent flag on
  /// DummyJSON's post model, so it's derived client-side: fetch a slightly
  /// larger first page once and surface the most-liked few as "featured".
  /// Fetched directly from the repository (not through PostsBloc) since
  /// it's a one-shot, independent piece of content -- it shouldn't reset,
  /// paginate, or get cleared by search the way the main feed does.
  late Future<List<PostEntity>> _featuredFuture;

  @override
  void initState() {
    super.initState();
    context.read<PostsBloc>().add(const PostsRefreshRequested());
    _scrollController.addListener(_onScroll);
    _featuredFuture = _loadFeatured();
  }

  Future<List<PostEntity>> _loadFeatured() async {
    final result = await context
        .read<PostsRepository>()
        .getPosts(limit: 10, skip: 0);
    return result.fold(
      (_) => const [],
      (page) {
        final sorted = [...page.items]
          ..sort((a, b) => b.likes.compareTo(a.likes));
        return sorted.take(5).toList();
      },
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      context.read<PostsBloc>().add(const PostsNextPageRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Good Morning!', style: AppTextStyles.h1),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary1,
                  child: Text(
                    widget.user.initials,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search posts ...',
                prefixIcon: Icon(Icons.search, color: AppColors.secondary),
              ),
              onChanged: (value) {
                context.read<PostsBloc>().add(PostsSearchQueryChanged(value));
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<PostsBloc, PostsState>(
                builder: (context, state) {
                  return RefreshIndicator(
                    color: AppColors.primary1,
                    onRefresh: () async {
                      context
                          .read<PostsBloc>()
                          .add(const PostsRefreshRequested());
                      setState(() => _featuredFuture = _loadFeatured());
                      await Future<void>.delayed(
                          const Duration(milliseconds: 400));
                    },
                    child: _buildBody(state),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PostsState state) {
    switch (state.status) {
      case PostsStatus.initial:
      case PostsStatus.loading:
        return const LoadingView();
      case PostsStatus.failure:
        if (state.posts.isEmpty) {
          return ListView(
            children: [
              const SizedBox(height: 80),
              ErrorView(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () => context
                    .read<PostsBloc>()
                    .add(const PostsRefreshRequested()),
              ),
            ],
          );
        }
        return _buildList(state);
      case PostsStatus.empty:
        return ListView(
          children: [
            if (!state.isSearching) ..._featuredSectionSlivers(),
            const SizedBox(height: 80),
            EmptyView(
              message: state.isSearching
                  ? 'No posts match "${state.query}".'
                  : 'No posts yet.',
            ),
          ],
        );
      case PostsStatus.success:
      case PostsStatus.loadingMore:
        return _buildList(state);
    }
  }

  /// Header rows + horizontal carousel, returned as plain widgets so they
  /// can be spliced into either the ListView.builder (via itemCount offset)
  /// or a plain ListView (empty/error states).
  List<Widget> _featuredSectionSlivers() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Featured Posts', style: AppTextStyles.h2),
          TextButton(
            onPressed: () {},
            child: const Text('View All', style: AppTextStyles.link),
          ),
        ],
      ),
      SizedBox(
        height: 196,
        child: FutureBuilder<List<PostEntity>>(
          future: _featuredFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.primary1,
                  ),
                ),
              );
            }
            final featured = snapshot.data ?? const [];
            if (featured.isEmpty) {
              return const SizedBox.shrink();
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              itemBuilder: (context, index) {
                final post = featured[index];
                return FeaturedPostCard(
                  post: post,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          PostDetailPage(postId: post.id, preview: post),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Recent Posts', style: AppTextStyles.h2),
          TextButton(
            onPressed: () {},
            child: const Text('View All', style: AppTextStyles.link),
          ),
        ],
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _buildList(PostsState state) {
    final showFeatured = !state.isSearching;
    // Featured header + carousel + "Recent Posts" header render as one
    // extra leading item ahead of the post list itself, so the same
    // ListView.builder drives both sections and the infinite-scroll
    // listener (_onScroll) keeps working unmodified.
    final headerCount = showFeatured ? 1 : 0;

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: headerCount + state.posts.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (showFeatured && index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _featuredSectionSlivers(),
          );
        }
        final postIndex = index - headerCount;

        if (postIndex >= state.posts.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.primary1,
                ),
              ),
            ),
          );
        }
        final post = state.posts[postIndex];
        return PostCard(
          post: post,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PostDetailPage(postId: post.id, preview: post),
              ),
            );
          },
        );
      },
    );
  }
}
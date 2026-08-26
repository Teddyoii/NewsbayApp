import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/posts_repository.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/bloc/auth_state.dart';
import 'presentation/auth/pages/login_page.dart';
import 'presentation/auth/pages/splash_page.dart';
import 'presentation/dashboard/bloc/posts_bloc.dart';
import 'presentation/home_shell.dart';

class PostsApp extends StatelessWidget {
  final Injector injector;

  const PostsApp({super.key, required this.injector});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: injector.authRepository),
        RepositoryProvider<PostsRepository>.value(value: injector.postsRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'NewsBay',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const _RootRouter(),
        ),
      ),
    );
  }
}

/// Swaps between Splash / Login / HomeShell purely by listening to
/// [AuthBloc] state — no named-route table needed for a 3-screen scope.
class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return BlocProvider<PostsBloc>(
            create: (context) =>
                PostsBloc(postsRepository: context.read<PostsRepository>()),
            child: HomeShell(user: state.user),
          );
        }
        if (state is AuthInitial || state is AuthSessionLoading) {
          return const SplashPage();
        }
        return const LoginPage();
      },
    );
  }
}

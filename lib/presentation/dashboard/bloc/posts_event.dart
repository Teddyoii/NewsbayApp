import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

/// First load / pull-to-refresh (resets pagination to skip=0).
class PostsRefreshRequested extends PostsEvent {
  const PostsRefreshRequested();
}

/// Infinite-scroll / "load more" — fetches the next page and appends.
class PostsNextPageRequested extends PostsEvent {
  const PostsNextPageRequested();
}

/// Raw text-field changes; the bloc itself owns the debounce timer so this
/// behavior is directly unit-testable with bloc_test's `wait:`.
class PostsSearchQueryChanged extends PostsEvent {
  final String query;

  const PostsSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}


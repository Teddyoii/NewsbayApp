import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_posts_app/data/models/paginated_posts_model.dart';

void main() {
  group('PaginatedPostsModel', () {
    test('fromJson_withPosts_parsesEnvelopeAndItems', () {
      final json = {
        'posts': [
          {'id': 1, 'title': 'A', 'body': 'a', 'userId': 1},
          {'id': 2, 'title': 'B', 'body': 'b', 'userId': 2},
        ],
        'total': 251,
        'skip': 0,
        'limit': 10,
      };

      final model = PaginatedPostsModel.fromJson(json);

      expect(model.posts, hasLength(2));
      expect(model.total, 251);
      expect(model.skip, 0);
      expect(model.limit, 10);
    });

    test('fromJson_noSearchMatches_returnsEmptyListNotError', () {
      final json = {'posts': [], 'total': 0, 'skip': 0, 'limit': 10};

      final model = PaginatedPostsModel.fromJson(json);

      expect(model.posts, isEmpty);
      expect(model.total, 0);
    });

    test('toEntity_computesHasMoreFromSkipAndTotal', () {
      final model = PaginatedPostsModel.fromJson({
        'posts': [
          {'id': 1, 'title': 'A', 'body': 'a', 'userId': 1},
        ],
        'total': 5,
        'skip': 0,
        'limit': 1,
      });

      final entity = model.toEntity();

      expect(entity.hasMore, isTrue);
    });

    test('toEntity_lastPage_hasMoreIsFalse', () {
      final model = PaginatedPostsModel.fromJson({
        'posts': [
          {'id': 1, 'title': 'A', 'body': 'a', 'userId': 1},
        ],
        'total': 1,
        'skip': 0,
        'limit': 10,
      });

      expect(model.toEntity().hasMore, isFalse);
    });
  });
}

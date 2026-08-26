import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_posts_app/core/error/exceptions.dart';
import 'package:flutter_posts_app/data/models/post_model.dart';

void main() {
  group('PostModel', () {
    test('fromJson_withFullPayload_returnsPostModel', () {
      final json = {
        'id': 1,
        'title': 'Some post',
        'body': 'Some body text',
        'userId': 121,
        'tags': ['history', 'american'],
        'reactions': {'likes': 192, 'dislikes': 25},
        'views': 305,
      };

      final post = PostModel.fromJson(json);

      expect(post.id, 1);
      expect(post.title, 'Some post');
      expect(post.userId, 121);
      expect(post.tags, ['history', 'american']);
      expect(post.likes, 192);
      expect(post.dislikes, 25);
      expect(post.views, 305);
    });

    test('fromJson_withLegacyIntReactions_mapsToLikesOnly', () {
      final json = {
        'id': 2,
        'title': 'Legacy shape',
        'body': 'Body',
        'userId': 5,
        'reactions': 40,
      };

      final post = PostModel.fromJson(json);

      expect(post.likes, 40);
      expect(post.dislikes, 0);
    });

    test('fromJson_missingOptionalFields_defaultsGracefully', () {
      final post = PostModel.fromJson({'id': 3});

      expect(post.title, '');
      expect(post.body, '');
      expect(post.userId, 0);
      expect(post.tags, isEmpty);
      expect(post.likes, 0);
      expect(post.views, 0);
    });

    test('fromJson_missingId_throwsParsingException', () {
      expect(
        () => PostModel.fromJson({'title': 'No id'}),
        throwsA(isA<ParsingException>()),
      );
    });
  });
}

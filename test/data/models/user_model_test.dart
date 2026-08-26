import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_posts_app/core/error/exceptions.dart';
import 'package:flutter_posts_app/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final validJson = {
      'id': 1,
      'username': 'emilys',
      'email': 'emily.johnson@x.dummyjson.com',
      'firstName': 'Emily',
      'lastName': 'Johnson',
      'image': 'https://example.com/emily.png',
    };

    test('fromJson_withValidPayload_returnsUserModel', () {
      final user = UserModel.fromJson(validJson);

      expect(user.id, 1);
      expect(user.username, 'emilys');
      expect(user.email, 'emily.johnson@x.dummyjson.com');
      expect(user.firstName, 'Emily');
      expect(user.lastName, 'Johnson');
      expect(user.fullName, 'Emily Johnson');
      expect(user.initials, 'EJ');
    });

    test('fromJson_missingOptionalFields_fallsBackToEmptyStrings', () {
      final user = UserModel.fromJson({'id': 2, 'username': 'michaelw'});

      expect(user.email, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
      // Falls back to the username's first letter when no name is present.
      expect(user.initials, 'M');
    });

    test('fromJson_missingRequiredId_throwsParsingException', () {
      expect(
        () => UserModel.fromJson({'username': 'emilys'}),
        throwsA(isA<ParsingException>()),
      );
    });

    test('toJson_thenFromJson_roundTripsCorrectly', () {
      final original = UserModel.fromJson(validJson);
      final roundTripped = UserModel.fromJson(original.toJson());

      expect(roundTripped, equals(original));
    });
  });
}

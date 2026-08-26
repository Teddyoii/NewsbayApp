import 'package:equatable/equatable.dart';

/// Pure domain representation of the logged-in user — no JSON, no Hive.
class UserEntity extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    final result = '$f$l'.toUpperCase();
    return result.isEmpty ? username.substring(0, 1).toUpperCase() : result;
  }

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, image];
}

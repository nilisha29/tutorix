import 'package:equatable/equatable.dart';

/// Represents the user in the domain layer
class AuthEntity extends Equatable {
  final String? authId;          // Optional unique ID
  final String fullName;         // Full name of the user
  final String email;            // Email
  final String? phoneNumber;     // Optional phone number
  final String username;         // Username
  final String? password;        // Optional password (only for local storage)
  final String? profilePicture;  // Optional profile picture URL

  const AuthEntity({
    this.authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.username,
    this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
        authId,
        fullName,
        email,
        phoneNumber,
        username,
        password,
        profilePicture,
      ];
}


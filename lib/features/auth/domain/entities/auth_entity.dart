import 'package:equatable/equatable.dart';

/// Represents the user in the domain layer
class AuthEntity extends Equatable {
  final String? authId;  
  final String token;        // Optional unique ID
  final String firstName;        // First name of the user
  final String email;            // Email
  final String? phoneNumber;     // Optional phone number
  final String lastName;         // Last name of the user
  final String? password;        // Optional password (only for local storage)
  final String? profilePicture;  // Optional profile picture URL


  const AuthEntity({
    this.authId,
    required this.token,
    required this.firstName,
    required this.email,
    this.phoneNumber,
    required this.lastName,
    this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
        authId,
        firstName,
        email,
        phoneNumber,
        lastName,
        password,
        profilePicture,
      ];
}


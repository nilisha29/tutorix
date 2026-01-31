// import 'package:equatable/equatable.dart';

// /// Represents the user in the domain layer
// class AuthEntity extends Equatable {
//   final String? authId;  
//   final String token;        // Optional unique ID
//    final String fullName;  
//   // final String firstName;        // First name of the user
//   final String email;            // Email
//   final String? phoneNumber;     // Optional phone number
//   // final String lastName;         // Last name of the user
//   final String? username;
//   final String? password;
//   final String? confirmPassword;
//    final String? address;        // Optional password (only for local storage)
//   final String? profilePicture;  // Optional profile picture URL


//   const AuthEntity({
//     this.authId,
//     required this.token,
//     required this.fullName,

//     // required this.firstName,
//     required this.email,
//     this.phoneNumber,
//     // required this.lastName,
//     this.username,
//     this.password,
//     this.confirmPassword,
//       this.address,
//     this.profilePicture,
//   });

//   @override
//   List<Object?> get props => [
//         authId,
//         fullName,
//         // firstName,
//         email,
//         phoneNumber,
//         // lastName,
//         username,
//         password,
//         confirmPassword,
//         address,
//         profilePicture,
//       ];
// }



import 'package:equatable/equatable.dart';

/// Represents the user in the domain layer
class AuthEntity extends Equatable {
  final String? authId;
  final String token;         // Required unique token
  final String fullName;      // Full name
  final String email;         // Email
  final String? phoneNumber;  // Optional phone number
  final String? username;     
  final String? password;
  final String? confirmPassword;
  final String? address;      // Optional address
  final String? profilePicture; // Optional profile picture URL

  const AuthEntity({
    this.authId,
    required this.token,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.username,
    this.password,
    this.confirmPassword,
    this.address,
    this.profilePicture,
  });

  /// ✅ Add this method to update fields immutably
  AuthEntity copyWith({
    String? authId,
    String? token,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? username,
    String? password,
    String? confirmPassword,
    String? address,
    String? profilePicture,
  }) {
    return AuthEntity(
      authId: authId ?? this.authId,
      token: token ?? this.token,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  List<Object?> get props => [
        authId,
        token,
        fullName,
        email,
        phoneNumber,
        username,
        password,
        confirmPassword,
        address,
        profilePicture,
      ];
}



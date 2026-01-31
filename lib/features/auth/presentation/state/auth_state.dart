// import 'package:equatable/equatable.dart';
// import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';

// /// Possible authentication states
// enum AuthStatus {
//   initial,          // Initial state before any action
//   authenticated,    // User successfully logged in
//   unauthenticated,  // User is not logged in
//   loading,          // Operation in progress (login/register)
//   registered,       // User successfully registered
//   error,            // An error occurred
// }


// /// AuthState class to hold the current authentication state
// class AuthState extends Equatable {
//   final AuthStatus status;
//   final String? errorMessage;
//   final AuthEntity? authEntity;

//   const AuthState({
//     this.status = AuthStatus.initial,
//     // this.status = AuthStatus.unauthenticated,
//     this.errorMessage,
//     this.authEntity,
//   });

//   /// Copy the current state with new values
//   AuthState copyWith({
//     AuthStatus? status,
//     String? errorMessage,
//     AuthEntity? authEntity,
//   }) {
//     return AuthState(
//       status: status ?? this.status,
//       errorMessage: errorMessage ?? this.errorMessage,
//       authEntity: authEntity ?? this.authEntity,
//     );
//   }

//   @override
//   List<Object?> get props => [status, errorMessage, authEntity];
// }



import 'package:equatable/equatable.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  registered,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final AuthEntity? authEntity;
  final String? profilePicture; // ✅ Add this

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.authEntity,
    this.profilePicture, // ✅ Add this
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    AuthEntity? authEntity,
    String? profilePicture, // ✅ Add this
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      authEntity: authEntity ?? this.authEntity,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, authEntity, profilePicture];
}


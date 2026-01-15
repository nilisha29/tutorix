class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String username;
  final String password;
  final String? batchId;
  final String? profilePicture;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.password,
    this.batchId,
    this.profilePicture,

  });

  
}
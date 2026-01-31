class AuthApiModel {
  final String? id;
   final String fullName;  
  // final String firstName;
  // final String lastName;
  final String email;
  final String phoneNumber;
  final String username;
  final String password;
  final String confirmPassword;
   final String? address; 
  // final String? batchId;
  final String? profilePicture;



  AuthApiModel({
    this.id,
     required this.fullName,
    // required this.firstName,
    // required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.password,
    required this.confirmPassword,
     this.address,
    // this.batchId,
    this.profilePicture,

  });

  
}
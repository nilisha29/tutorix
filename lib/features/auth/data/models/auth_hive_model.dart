import 'package:hive/hive.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0) // Make sure this matches HiveTableConstant.authTypeId
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String authId; // Unique ID for the user

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String password;

  AuthHiveModel({
    String? authId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  }) : authId = authId ?? DateTime.now().millisecondsSinceEpoch.toString();
}


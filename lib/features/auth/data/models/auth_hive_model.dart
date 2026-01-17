import 'package:hive/hive.dart';
import 'package:tutorix/core/constants/hive_table_constant.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? authId;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String lastName;

  @HiveField(5)
  final String? password;

  @HiveField(6)
  final String? profilePicture;

  @HiveField(7)
  final String token;

  AuthHiveModel({
    this.authId,
    required this.firstName,
    required this.email,
    this.phoneNumber,
    required this.lastName,
    this.password,
    this.profilePicture,
    required this.token,
  });


  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      firstName: firstName,
      email: email,
      phoneNumber: phoneNumber,
      lastName: lastName,
      password: password,
      profilePicture: profilePicture,
      token: token,
    );
  }

  /// Create Hive model from domain entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId,
      firstName: entity.firstName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      lastName: entity.lastName,
      password: entity.password,
      profilePicture: entity.profilePicture,
      token: entity.token,
    );
  }
}



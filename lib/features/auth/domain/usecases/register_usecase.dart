import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/auth/data/repositories/auth_repository.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/domain/repositories/auth_repository.dart';

/// Params for register usecase
class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String username;
  final String? password;
  final String? phoneNumber;
  final String? profilePicture;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.username,
    this.password,
    this.phoneNumber,
    this.profilePicture,
  });

  @override
  List<Object?> get props =>
      [fullName, email, username, password, phoneNumber, profilePicture];
}

/// Provider for RegisterUsecase
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

/// Register Usecase
class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) async {
    final entity = AuthEntity(
      authId: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: params.fullName,
      email: params.email,
      username: params.username,
      password: params.password,
      phoneNumber: params.phoneNumber,
      profilePicture: params.profilePicture,
    );

    return _authRepository.register(entity);
  }
}

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
  final String firstName;
  final String email;
  final String lastName;
  final String? password;
  final String? phoneNumber;
  final String? profilePicture;

  const RegisterUsecaseParams({
    required this.firstName,
    required this.email,
    required this.lastName,
    this.password,
    this.phoneNumber,
    this.profilePicture,
  });

  @override
  List<Object?> get props =>
      [firstName, email, lastName, password, phoneNumber, profilePicture];
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
      token: '', // Token can be set after registration
      firstName: params.firstName,
      email: params.email,
      lastName: params.lastName,
      password: params.password,
      phoneNumber: params.phoneNumber,
      profilePicture: params.profilePicture,
    );

    return _authRepository.register(entity);
  }
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/auth/data/repositories/auth_repository.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/domain/repositories/auth_repository.dart';

/// Params for login usecase
class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}


/// Provider for login usecase
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

/// Login Usecase
class LoginUsecase implements UsecaseWithParams<AuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginUsecaseParams params) async{
    await Future.delayed(const Duration(seconds: 2));
  // return right(AuthEntity(authId: '1', token: 'dummy_token', email: params.email, firstName: 'John', lastName: 'Doe', phoneNumber: '1234567890', profilePicture: '', password: params.password));
    return _authRepository.login(params.email, params.password);
  }
}

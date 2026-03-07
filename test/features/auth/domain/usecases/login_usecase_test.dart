import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/domain/repositories/auth_repository.dart';
import 'package:tutorix/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase loginUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUsecase = LoginUsecase(authRepository: mockAuthRepository);
  });

  const loginParams = LoginUsecaseParams(
    email: 'test@gmail.com',
    password: 'password123',
  );

  final authEntity = AuthEntity(
    authId: '1',
    token: 'token_123',
    email: 'test@gmail.com',
    fullName: 'Test',
    // lastName: 'User',
    phoneNumber: '9800000000',
    profilePicture: '',
    password: 'password123',
  );

  group('Login Usecase Test', () {
    test('✅ should return AuthEntity when login is successful', () async {
      when(() => mockAuthRepository.login(
            loginParams.email,
            loginParams.password,
          )).thenAnswer((_) async => Right(authEntity));

      final result = await loginUsecase(loginParams);

      expect(result, Right(authEntity));
      verify(() => mockAuthRepository.login(
            loginParams.email,
            loginParams.password,
          )).called(1);
    });

    test('❌ should return failure when login fails', () async {
      const failure = NetworkFailure(message: 'No internet');
      when(() => mockAuthRepository.login(
            loginParams.email,
            loginParams.password,
          )).thenAnswer((_) async => const Left(failure));

      final result = await loginUsecase(loginParams);

      expect(result, const Left(failure));
      verify(() => mockAuthRepository.login(
            loginParams.email,
            loginParams.password,
          )).called(1);
    });

    test('📦 should forward email and password to repository', () async {
      String? capturedEmail;
      String? capturedPassword;
      when(() => mockAuthRepository.login(any(), any())).thenAnswer((invocation) async {
        capturedEmail = invocation.positionalArguments[0] as String;
        capturedPassword = invocation.positionalArguments[1] as String;
        return Right(authEntity);
      });

      await loginUsecase(loginParams);

      expect(capturedEmail, loginParams.email);
      expect(capturedPassword, loginParams.password);
    });

    test('🧪 should pass empty credentials as-is to repository', () async {
      const emptyParams = LoginUsecaseParams(email: '', password: '');
      when(() => mockAuthRepository.login('', ''))
          .thenAnswer((_) async => Right(authEntity));

      final result = await loginUsecase(emptyParams);

      expect(result, Right(authEntity));
      verify(() => mockAuthRepository.login('', '')).called(1);
    });

    test('🔁 should call repository exactly once per execution', () async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => Right(authEntity));

      await loginUsecase(loginParams);

      verify(() => mockAuthRepository.login(any(), any())).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}

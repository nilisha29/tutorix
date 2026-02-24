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
      // arrange
      when(() => mockAuthRepository.login(
            loginParams.email,
            loginParams.password,
          )).thenAnswer((_) async => Right(authEntity));

      // act
      final result = await loginUsecase(loginParams);

      // assert
      expect(result, Right(authEntity));
      verify(() => mockAuthRepository.login(
            loginParams.email,
            loginParams.password,
          )).called(1);
    });

    // test('❌ should return Failure when login fails', () async {
    //   // arrange (INLINE failure, no external setup)
    //   when(() => mockAuthRepository.login(
    //         loginParams.email,
    //         loginParams.password,
    //       )).thenAnswer(
    //         (_) async => Left(ServerFailure('Server error')),
    //       );

    //   // act
    //   final result = await loginUsecase(loginParams);

    //   // assert
    //   expect(
    //     result,
    //     Left(('Server error')),
    //   );
    //   verify(() => mockAuthRepository.login(
    //         loginParams.email,
    //         loginParams.password,
    //       )).called(1);
    // });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/domain/repositories/auth_repository.dart';
import 'package:tutorix/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      AuthEntity(
        authId: '0',
        token: '',
        fullName: '',
        username: '',
        email: '',
        password: '',
        confirmPassword: '',
        phoneNumber: '',
        address: '',
        profilePicture: '',
      ),
    );
  });

  late RegisterUsecase registerUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerUsecase = RegisterUsecase(authRepository: mockAuthRepository);
  });

  const registerParams = RegisterUsecaseParams(
    fullName: 'John Doe',
    username: 'johndoe',
    email: 'john@gmail.com',
    password: 'password123',
    confirmPassword: 'password123',
    phoneNumber: '9800000000',
    profilePicture: '',
    address: 'Kathmandu',
  );

  group('Register Usecase Test', () {
    test('✅ should return true when registration is successful', () async {
      // arrange
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await registerUsecase(registerParams);

      // assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.register(any())).called(1);
    });

    // test('❌ should return Failure when registration fails', () async {
    //   // arrange
    //   when(() => mockAuthRepository.register(any())).thenAnswer(
    //     (_) async => Left(ServerFailure('Registration failed')),
    //   );

    //   // act
    //   final result = await registerUsecase(registerParams);

    //   // assert
    //   expect(
    //     result,
    //     Left(ServerFailure('Registration failed')),
    //   );
    //   verify(() => mockAuthRepository.register(any())).called(1);
    // });
  });
}

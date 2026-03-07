import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
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
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      final result = await registerUsecase(registerParams);

      expect(result, const Right(true));
      verify(() => mockAuthRepository.register(any())).called(1);
    });

    test('❌ should return failure when repository returns failure', () async {
      const failure = ApiFailure(message: 'Registration failed', statusCode: 400);
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Left(failure));

      final result = await registerUsecase(registerParams);

      expect(result, const Left(failure));
      verify(() => mockAuthRepository.register(any())).called(1);
    });

    test('📦 should map params to AuthEntity fields before calling repository', () async {
      late AuthEntity capturedEntity;
      when(() => mockAuthRepository.register(any())).thenAnswer((invocation) async {
        capturedEntity = invocation.positionalArguments.first as AuthEntity;
        return const Right(true);
      });

      await registerUsecase(registerParams);

      expect(capturedEntity.fullName, registerParams.fullName);
      expect(capturedEntity.username, registerParams.username);
      expect(capturedEntity.email, registerParams.email);
      expect(capturedEntity.password, registerParams.password);
      expect(capturedEntity.confirmPassword, registerParams.confirmPassword);
      expect(capturedEntity.phoneNumber, registerParams.phoneNumber);
      expect(capturedEntity.address, registerParams.address);
      expect(capturedEntity.profilePicture, registerParams.profilePicture);
      expect(capturedEntity.token, '');
      expect(capturedEntity.authId, isNotEmpty);
    });

    test('🧪 should pass nullable optional fields as null when omitted', () async {
      const params = RegisterUsecaseParams(
        fullName: 'Jane Doe',
        username: 'janedoe',
        email: 'jane@gmail.com',
      );

      late AuthEntity capturedEntity;
      when(() => mockAuthRepository.register(any())).thenAnswer((invocation) async {
        capturedEntity = invocation.positionalArguments.first as AuthEntity;
        return const Right(true);
      });

      await registerUsecase(params);

      expect(capturedEntity.password, isNull);
      expect(capturedEntity.confirmPassword, isNull);
      expect(capturedEntity.phoneNumber, isNull);
      expect(capturedEntity.address, isNull);
      expect(capturedEntity.profilePicture, isNull);
    });

    test('🔁 should call repository exactly once per execution', () async {
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Right(true));

      await registerUsecase(registerParams);

      verify(() => mockAuthRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}

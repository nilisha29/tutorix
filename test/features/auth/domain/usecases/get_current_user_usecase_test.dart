import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/domain/repositories/auth_repository.dart';
import 'package:tutorix/features/auth/domain/usecases/get_current_user_usecase.dart';

/// Mock Repository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase getCurrentUserUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getCurrentUserUsecase =
        GetCurrentUserUsecase(authRepository: mockAuthRepository);
  });

  final authEntity = AuthEntity(
    authId: '1',
    token: 'token_123',
    fullName: 'John Doe',
    username: 'johndoe',
    email: 'john@gmail.com',
    password: 'password123',
    confirmPassword: 'password123',
    phoneNumber: '9800000000',
    address: 'Kathmandu',
    profilePicture: '',
  );

  group('GetCurrentUser Usecase Test', () {
    test('✅ should return AuthEntity when user is logged in', () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(authEntity));

      final result = await getCurrentUserUsecase();

      expect(result, Right(authEntity));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('❌ should return failure when repository has no user', () async {
      const failure = ValidationFailure(message: 'User not found');
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(failure));

      final result = await getCurrentUserUsecase();

      expect(result, const Left(failure));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    test('📦 should return same entity instance from repository result', () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(authEntity));

      final result = await getCurrentUserUsecase();

      expect(result, Right(authEntity));
      result.fold(
        (_) => fail('Expected Right<AuthEntity> but got Left<Failure>'),
        (entity) => expect(identical(entity, authEntity), true),
      );
    });

    test('🔁 should call repository on each invocation', () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(authEntity));

      await getCurrentUserUsecase();
      await getCurrentUserUsecase();

      verify(() => mockAuthRepository.getCurrentUser()).called(2);
    });

    test('📞 should call only getCurrentUser method in repository', () async {
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(authEntity));

      await getCurrentUserUsecase();

      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}

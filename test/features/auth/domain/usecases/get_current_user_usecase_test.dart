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
      // arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(authEntity));

      // act
      final result = await getCurrentUserUsecase();

      // assert
      expect(result, Right(authEntity));
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });

    // test('❌ should return Failure when no user is found', () async {
    //   // arrange
    //   when(() => mockAuthRepository.getCurrentUser()).thenAnswer(
    //     (_) async => Left(ServerFailure('User not found')),
    //   );

    //   // act
    //   final result = await getCurrentUserUsecase();

    //   // assert
    //   expect(
    //     result,
    //     Left(ServerFailure('User not found')),
    //   );
    //   verify(() => mockAuthRepository.getCurrentUser()).called(1);
    // });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/auth/domain/repositories/auth_repository.dart';
import 'package:tutorix/features/auth/domain/usecases/logout_usecase.dart';

/// Mock Repository
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LogoutUsecase logoutUsecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    logoutUsecase = LogoutUsecase(authRepository: mockAuthRepository);
  });

  group('Logout Usecase Test', () {
    test('✅ should return true when logout is successful', () async {
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      final result = await logoutUsecase();

      expect(result, const Right(true));
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('❌ should return failure when repository fails logout', () async {
      const failure = LocalDatabaseFailure(message: 'Logout failed');
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Left(failure));

      final result = await logoutUsecase();

      expect(result, const Left(failure));
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('📦 should propagate Right(false) from repository', () async {
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(false));

      final result = await logoutUsecase();

      expect(result, const Right(false));
      verify(() => mockAuthRepository.logout()).called(1);
    });

    test('🔁 should call repository on each usecase invocation', () async {
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      await logoutUsecase();
      await logoutUsecase();

      verify(() => mockAuthRepository.logout()).called(2);
    });

    test('📞 should call only logout method in repository', () async {
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      await logoutUsecase();

      verify(() => mockAuthRepository.logout()).called(1);
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}

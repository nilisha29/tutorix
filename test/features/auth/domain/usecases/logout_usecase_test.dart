import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
      // arrange
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await logoutUsecase();

      // assert
      expect(result, const Right(true));
      verify(() => mockAuthRepository.logout()).called(1);
    });

    // test('❌ should return Failure when logout fails', () async {
    //   // arrange
    //   when(() => mockAuthRepository.logout()).thenAnswer(
    //     (_) async => Left(ServerFailure('Logout failed')),
    //   );

    //   // act
    //   final result = await logoutUsecase();

    //   // assert
    //   expect(
    //     result,
    //     Left(ServerFailure('Logout failed')),
    //   );
    //   verify(() => mockAuthRepository.logout()).called(1);
    // });
  });
}

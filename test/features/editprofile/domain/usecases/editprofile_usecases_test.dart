import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/editprofile/domain/repositories/edit_profile_repository.dart';
import 'package:tutorix/features/editprofile/domain/usecases/get_profile_usecase.dart';
import 'package:tutorix/features/editprofile/domain/usecases/update_profile_usecase.dart';

class MockEditProfileRepository extends Mock implements IEditProfileRepository {}

void main() {
  late MockEditProfileRepository repository;
  late GetProfileUseCase getProfileUseCase;
  late UpdateProfileUseCase updateProfileUseCase;

  setUp(() {
    repository = MockEditProfileRepository();
    getProfileUseCase = GetProfileUseCase(editProfileRepository: repository);
    updateProfileUseCase = UpdateProfileUseCase(editProfileRepository: repository);
  });

  group('EditProfile usecases', () {
    test('GetProfileUseCase returns profile on success', () async {
      final profile = {'name': 'Jane', 'phoneNumber': '9800000000'};
      when(() => repository.getProfile()).thenAnswer((_) async => Right(profile));

      final result = await getProfileUseCase();

      expect(result, Right(profile));
      verify(() => repository.getProfile()).called(1);
    });

    test('GetProfileUseCase returns failure on error', () async {
      const failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
      when(() => repository.getProfile()).thenAnswer((_) async => const Left(failure));

      final result = await getProfileUseCase();

      expect(result, const Left(failure));
    });

    test('UpdateProfileUseCase forwards payload and returns updated profile', () async {
      const params = UpdateProfileUseCaseParams(
        fullName: 'Jane Updated',
        phoneNumber: '9800000000',
        address: 'Pokhara',
      );
      final updated = {'name': 'Jane Updated'};

      when(() => repository.updateProfile(params.toJson()))
          .thenAnswer((_) async => Right(updated));

      final result = await updateProfileUseCase(params);

      expect(result, Right(updated));
      verify(() => repository.updateProfile(params.toJson())).called(1);
    });

    test('UpdateProfileUseCase returns failure on error', () async {
      const params = UpdateProfileUseCaseParams(
        fullName: 'Jane',
        phoneNumber: '12',
        address: 'Pokhara',
      );
      const failure = ValidationFailure(message: 'Invalid phone');

      when(() => repository.updateProfile(params.toJson()))
          .thenAnswer((_) async => const Left(failure));

      final result = await updateProfileUseCase(params);

      expect(result, const Left(failure));
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/editprofile/domain/usecases/get_profile_usecase.dart';
import 'package:tutorix/features/editprofile/domain/usecases/update_profile_usecase.dart';
import 'package:tutorix/features/editprofile/presentation/view_model/edit_profile_viewmodel.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const UpdateProfileUseCaseParams(
        fullName: 'John',
        phoneNumber: '9800000000',
        address: 'KTM',
      ),
    );
  });

  group('EditProfileViewModel', () {
    test('fetchProfile sets profile on success', () async {
      final getUseCase = MockGetProfileUseCase();
      final updateUseCase = MockUpdateProfileUseCase();
      final profile = {'name': 'John'};
      when(() => getUseCase()).thenAnswer((_) async => Right(profile));
      final vm = EditProfileViewModel(
        getProfileUseCase: getUseCase,
        updateProfileUseCase: updateUseCase,
      );

      await vm.fetchProfile();

      expect(vm.state.profile, profile);
      expect(vm.state.errorMessage, isNull);
    });

    test('updateProfile sets profile on success', () async {
      final getUseCase = MockGetProfileUseCase();
      final updateUseCase = MockUpdateProfileUseCase();
      const params = UpdateProfileUseCaseParams(
        fullName: 'John Updated',
        phoneNumber: '9800000000',
        address: 'Pokhara',
      );
      final updated = {'name': 'John Updated'};
      when(() => updateUseCase(params)).thenAnswer((_) async => Right(updated));
      final vm = EditProfileViewModel(
        getProfileUseCase: getUseCase,
        updateProfileUseCase: updateUseCase,
      );

      await vm.updateProfile(params);

      expect(vm.state.profile, updated);
      expect(vm.state.isUpdating, false);
    });

    test('updateProfile sets error on failure', () async {
      final getUseCase = MockGetProfileUseCase();
      final updateUseCase = MockUpdateProfileUseCase();
      const params = UpdateProfileUseCaseParams(
        fullName: 'John',
        phoneNumber: '12',
        address: 'Pokhara',
      );
      const failure = ValidationFailure(message: 'invalid');
      when(() => updateUseCase(params)).thenAnswer((_) async => const Left(failure));
      final vm = EditProfileViewModel(
        getProfileUseCase: getUseCase,
        updateProfileUseCase: updateUseCase,
      );

      await vm.updateProfile(params);

      expect(vm.state.errorMessage, failure.message);
      expect(vm.state.isUpdating, false);
    });
  });
}

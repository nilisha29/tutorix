import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/editprofile/domain/usecases/get_profile_usecase.dart';
import 'package:tutorix/features/editprofile/domain/usecases/update_profile_usecase.dart';
import 'package:tutorix/features/editprofile/presentation/state/edit_profile_state.dart';

class EditProfileViewModel extends StateNotifier<EditProfileState> {
  EditProfileViewModel({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const EditProfileState());

  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getProfileUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (profile) => state = state.copyWith(
        isLoading: false,
        profile: profile,
        clearError: true,
      ),
    );
  }

  Future<void> updateProfile(UpdateProfileUseCaseParams params) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    final result = await _updateProfileUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isUpdating: false,
        errorMessage: failure.message,
      ),
      (updated) => state = state.copyWith(
        isUpdating: false,
        profile: updated,
        clearError: true,
      ),
    );
  }
}

final editProfileViewModelProvider =
    StateNotifierProvider<EditProfileViewModel, EditProfileState>((ref) {
  return EditProfileViewModel(
    getProfileUseCase: ref.read(getProfileUseCaseProvider),
    updateProfileUseCase: ref.read(updateProfileUseCaseProvider),
  );
});

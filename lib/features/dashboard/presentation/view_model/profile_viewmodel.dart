import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_user_profile_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/update_profile_usecase.dart';
import 'package:tutorix/features/dashboard/presentation/state/profile_state.dart';

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        super(const ProfileState());

  final GetUserProfileUseCase _getUserProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getUserProfileUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (profile) {
        state = state.copyWith(
          isLoading: false,
          profile: profile,
          clearError: true,
        );
      },
    );
  }

  Future<void> updateProfile(UpdateProfileUseCaseParams params) async {
    state = state.copyWith(isUpdating: true, clearError: true);
    final result = await _updateProfileUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          errorMessage: failure.message,
        );
      },
      (updatedProfile) {
        state = state.copyWith(
          isUpdating: false,
          profile: updatedProfile,
          clearError: true,
        );
      },
    );
  }
}

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    getUserProfileUseCase: ref.read(getUserProfileUseCaseProvider),
    updateProfileUseCase: ref.read(updateProfileUseCaseProvider),
  );
});

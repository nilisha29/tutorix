class EditProfileState {
  const EditProfileState({
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.profile,
  });

  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final Map<String, dynamic>? profile;

  EditProfileState copyWith({
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
    Map<String, dynamic>? profile,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      profile: profile ?? this.profile,
    );
  }
}

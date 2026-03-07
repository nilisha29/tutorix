class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.isUpdating = false,
    this.errorMessage,
    this.profile,
  });

  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final Map<String, dynamic>? profile;

  ProfileState copyWith({
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
    Map<String, dynamic>? profile,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      profile: profile ?? this.profile,
    );
  }
}

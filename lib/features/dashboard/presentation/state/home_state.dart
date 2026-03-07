class HomeState {
  const HomeState({
    this.isLoading = false,
    this.errorMessage,
    this.tutors = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> tutors;

  HomeState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? tutors,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      tutors: tutors ?? this.tutors,
    );
  }
}

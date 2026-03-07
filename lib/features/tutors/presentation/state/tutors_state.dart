class TutorsState {
  const TutorsState({
    this.isLoading = false,
    this.errorMessage,
    this.categoryTutors = const [],
    this.selectedTutor,
    this.availability = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> categoryTutors;
  final Map<String, dynamic>? selectedTutor;
  final List<Map<String, dynamic>> availability;

  TutorsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? categoryTutors,
    Map<String, dynamic>? selectedTutor,
    List<Map<String, dynamic>>? availability,
  }) {
    return TutorsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      categoryTutors: categoryTutors ?? this.categoryTutors,
      selectedTutor: selectedTutor ?? this.selectedTutor,
      availability: availability ?? this.availability,
    );
  }
}

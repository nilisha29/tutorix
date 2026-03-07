class SavedTutorsState {
  const SavedTutorsState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> items;

  SavedTutorsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? items,
  }) {
    return SavedTutorsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
    );
  }
}

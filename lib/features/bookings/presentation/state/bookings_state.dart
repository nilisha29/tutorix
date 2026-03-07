class BookingsState {
  const BookingsState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> items;

  BookingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? items,
  }) {
    return BookingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
    );
  }
}

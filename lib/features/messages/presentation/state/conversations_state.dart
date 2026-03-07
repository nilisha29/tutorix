class ConversationsState {
  const ConversationsState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> items;

  ConversationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? items,
  }) {
    return ConversationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
    );
  }
}

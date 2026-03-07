class CategoriesState {
  const CategoriesState({
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, dynamic>> categories;

  CategoriesState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? categories,
  }) {
    return CategoriesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      categories: categories ?? this.categories,
    );
  }
}

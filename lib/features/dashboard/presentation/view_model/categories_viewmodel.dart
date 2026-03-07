import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_categories_usecase.dart';
import 'package:tutorix/features/dashboard/presentation/state/categories_state.dart';

class CategoriesViewModel extends StateNotifier<CategoriesState> {
  CategoriesViewModel({required GetCategoriesUseCase getCategoriesUseCase})
      : _getCategoriesUseCase = getCategoriesUseCase,
        super(const CategoriesState());

  final GetCategoriesUseCase _getCategoriesUseCase;

  Future<void> fetchCategories() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getCategoriesUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (categories) {
        state = state.copyWith(
          isLoading: false,
          categories: categories,
          clearError: true,
        );
      },
    );
  }
}

final categoriesViewModelProvider =
    StateNotifierProvider<CategoriesViewModel, CategoriesState>((ref) {
  return CategoriesViewModel(
    getCategoriesUseCase: ref.read(getCategoriesUseCaseProvider),
  );
});

import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_tutors_usecase.dart';
import 'package:tutorix/features/dashboard/presentation/state/home_state.dart';

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel({required GetTutorsUseCase getTutorsUseCase})
      : _getTutorsUseCase = getTutorsUseCase,
        super(const HomeState());

  final GetTutorsUseCase _getTutorsUseCase;

  Future<void> fetchTutors() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getTutorsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (tutors) {
        state = state.copyWith(
          isLoading: false,
          tutors: tutors,
          clearError: true,
        );
      },
    );
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(getTutorsUseCase: ref.read(getTutorsUseCaseProvider));
});

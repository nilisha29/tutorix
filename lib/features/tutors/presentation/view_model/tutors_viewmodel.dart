import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_category_tutors_usecase.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_tutor_availability_usecase.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_tutor_detail_usecase.dart';
import 'package:tutorix/features/tutors/presentation/state/tutors_state.dart';

class TutorsViewModel extends StateNotifier<TutorsState> {
  TutorsViewModel({
    required GetCategoryTutorsUseCase getCategoryTutorsUseCase,
    required GetTutorDetailUseCase getTutorDetailUseCase,
    required GetTutorAvailabilityUseCase getTutorAvailabilityUseCase,
  })  : _getCategoryTutorsUseCase = getCategoryTutorsUseCase,
        _getTutorDetailUseCase = getTutorDetailUseCase,
        _getTutorAvailabilityUseCase = getTutorAvailabilityUseCase,
        super(const TutorsState());

  final GetCategoryTutorsUseCase _getCategoryTutorsUseCase;
  final GetTutorDetailUseCase _getTutorDetailUseCase;
  final GetTutorAvailabilityUseCase _getTutorAvailabilityUseCase;

  Future<void> fetchCategoryTutors(String category) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getCategoryTutorsUseCase(
      GetCategoryTutorsUseCaseParams(category: category),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        categoryTutors: items,
        clearError: true,
      ),
    );
  }

  Future<void> fetchTutorDetail(String tutorId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getTutorDetailUseCase(
      GetTutorDetailUseCaseParams(tutorId: tutorId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (item) => state = state.copyWith(
        isLoading: false,
        selectedTutor: item,
        clearError: true,
      ),
    );
  }

  Future<void> fetchTutorAvailability(String tutorId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getTutorAvailabilityUseCase(
      GetTutorAvailabilityUseCaseParams(tutorId: tutorId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        availability: items,
        clearError: true,
      ),
    );
  }
}

final tutorsViewModelProvider =
    StateNotifierProvider<TutorsViewModel, TutorsState>((ref) {
  return TutorsViewModel(
    getCategoryTutorsUseCase: ref.read(getCategoryTutorsUseCaseProvider),
    getTutorDetailUseCase: ref.read(getTutorDetailUseCaseProvider),
    getTutorAvailabilityUseCase: ref.read(getTutorAvailabilityUseCaseProvider),
  );
});

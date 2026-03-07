import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/get_saved_tutors_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/remove_saved_tutor_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/save_tutor_usecase.dart';
import 'package:tutorix/features/saved_tutors/presentation/state/saved_tutors_state.dart';

class SavedTutorsViewModel extends StateNotifier<SavedTutorsState> {
  SavedTutorsViewModel({
    required GetSavedTutorsUseCase getSavedTutorsUseCase,
    required SaveTutorUseCase saveTutorUseCase,
    required RemoveSavedTutorUseCase removeSavedTutorUseCase,
  })  : _getSavedTutorsUseCase = getSavedTutorsUseCase,
        _saveTutorUseCase = saveTutorUseCase,
        _removeSavedTutorUseCase = removeSavedTutorUseCase,
        super(const SavedTutorsState());

  final GetSavedTutorsUseCase _getSavedTutorsUseCase;
  final SaveTutorUseCase _saveTutorUseCase;
  final RemoveSavedTutorUseCase _removeSavedTutorUseCase;

  Future<void> fetchSavedTutors() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getSavedTutorsUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        items: items,
        clearError: true,
      ),
    );
  }

  Future<void> saveTutor(Map<String, dynamic> tutor) async {
    final result = await _saveTutorUseCase(SaveTutorUseCaseParams(tutor: tutor));
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => fetchSavedTutors(),
    );
  }

  Future<void> removeTutor(String tutorId) async {
    final result =
        await _removeSavedTutorUseCase(RemoveSavedTutorUseCaseParams(tutorId: tutorId));
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => fetchSavedTutors(),
    );
  }
}

final savedTutorsViewModelProvider =
    StateNotifierProvider<SavedTutorsViewModel, SavedTutorsState>((ref) {
  return SavedTutorsViewModel(
    getSavedTutorsUseCase: ref.read(getSavedTutorsUseCaseProvider),
    saveTutorUseCase: ref.read(saveTutorUseCaseProvider),
    removeSavedTutorUseCase: ref.read(removeSavedTutorUseCaseProvider),
  );
});

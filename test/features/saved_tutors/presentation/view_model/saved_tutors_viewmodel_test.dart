import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/get_saved_tutors_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/remove_saved_tutor_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/save_tutor_usecase.dart';
import 'package:tutorix/features/saved_tutors/presentation/view_model/saved_tutors_viewmodel.dart';

class MockGetSavedTutorsUseCase extends Mock implements GetSavedTutorsUseCase {}

class MockSaveTutorUseCase extends Mock implements SaveTutorUseCase {}

class MockRemoveSavedTutorUseCase extends Mock implements RemoveSavedTutorUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const SaveTutorUseCaseParams(tutor: {'id': 't1'}));
    registerFallbackValue(const RemoveSavedTutorUseCaseParams(tutorId: 't1'));
  });

  group('SavedTutorsViewModel', () {
    test('fetchSavedTutors sets list on success', () async {
      final getSaved = MockGetSavedTutorsUseCase();
      final save = MockSaveTutorUseCase();
      final remove = MockRemoveSavedTutorUseCase();
      final items = [
        {'id': 't1'}
      ];
      when(() => getSaved()).thenAnswer((_) async => Right(items));
      final vm = SavedTutorsViewModel(
        getSavedTutorsUseCase: getSaved,
        saveTutorUseCase: save,
        removeSavedTutorUseCase: remove,
      );

      await vm.fetchSavedTutors();

      expect(vm.state.items, items);
      expect(vm.state.errorMessage, isNull);
    });

    test('saveTutor sets error on failure', () async {
      final getSaved = MockGetSavedTutorsUseCase();
      final save = MockSaveTutorUseCase();
      final remove = MockRemoveSavedTutorUseCase();
      const failure = LocalDatabaseFailure(message: 'save failed');
      when(() => save(any())).thenAnswer((_) async => const Left(failure));
      final vm = SavedTutorsViewModel(
        getSavedTutorsUseCase: getSaved,
        saveTutorUseCase: save,
        removeSavedTutorUseCase: remove,
      );

      await vm.saveTutor({'id': 't1'});

      expect(vm.state.errorMessage, failure.message);
    });

    test('saveTutor triggers refresh on success', () async {
      final getSaved = MockGetSavedTutorsUseCase();
      final save = MockSaveTutorUseCase();
      final remove = MockRemoveSavedTutorUseCase();
      when(() => save(any())).thenAnswer((_) async => const Right(true));
      when(() => getSaved()).thenAnswer((_) async => const Right([]));
      final vm = SavedTutorsViewModel(
        getSavedTutorsUseCase: getSaved,
        saveTutorUseCase: save,
        removeSavedTutorUseCase: remove,
      );

      await vm.saveTutor({'id': 't1'});
      await Future<void>.delayed(Duration.zero);

      verify(() => getSaved()).called(1);
    });

    test('removeTutor triggers refresh on success', () async {
      final getSaved = MockGetSavedTutorsUseCase();
      final save = MockSaveTutorUseCase();
      final remove = MockRemoveSavedTutorUseCase();
      when(() => remove(any())).thenAnswer((_) async => const Right(true));
      when(() => getSaved()).thenAnswer((_) async => const Right([]));
      final vm = SavedTutorsViewModel(
        getSavedTutorsUseCase: getSaved,
        saveTutorUseCase: save,
        removeSavedTutorUseCase: remove,
      );

      await vm.removeTutor('t1');
      await Future<void>.delayed(Duration.zero);

      verify(() => getSaved()).called(1);
    });
  });
}

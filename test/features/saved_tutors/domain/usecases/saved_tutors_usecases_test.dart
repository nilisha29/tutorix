import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/saved_tutors/domain/repositories/saved_tutors_repository.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/get_saved_tutors_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/remove_saved_tutor_usecase.dart';
import 'package:tutorix/features/saved_tutors/domain/usecases/save_tutor_usecase.dart';

class MockSavedTutorsRepository extends Mock implements ISavedTutorsRepository {}

void main() {
  late MockSavedTutorsRepository repository;
  late GetSavedTutorsUseCase getSavedTutorsUseCase;
  late SaveTutorUseCase saveTutorUseCase;
  late RemoveSavedTutorUseCase removeSavedTutorUseCase;

  setUp(() {
    repository = MockSavedTutorsRepository();
    getSavedTutorsUseCase = GetSavedTutorsUseCase(savedTutorsRepository: repository);
    saveTutorUseCase = SaveTutorUseCase(savedTutorsRepository: repository);
    removeSavedTutorUseCase =
        RemoveSavedTutorUseCase(savedTutorsRepository: repository);
  });

  group('Saved tutors usecases', () {
    test('GetSavedTutorsUseCase returns list on success', () async {
      final tutors = [
        {'id': 't1', 'name': 'Tutor A'},
      ];
      when(() => repository.getSavedTutors()).thenAnswer((_) async => Right(tutors));

      final result = await getSavedTutorsUseCase();

      expect(result, Right(tutors));
      verify(() => repository.getSavedTutors()).called(1);
    });

    test('GetSavedTutorsUseCase returns failure on error', () async {
      const failure = LocalDatabaseFailure(message: 'DB error');
      when(() => repository.getSavedTutors()).thenAnswer((_) async => const Left(failure));

      final result = await getSavedTutorsUseCase();

      expect(result, const Left(failure));
    });

    test('SaveTutorUseCase forwards tutor and returns true', () async {
      final tutor = {'id': 't1', 'name': 'Tutor A'};
      final params = SaveTutorUseCaseParams(tutor: tutor);
      when(() => repository.saveTutor(params.tutor))
          .thenAnswer((_) async => const Right(true));

      final result = await saveTutorUseCase(params);

      expect(result, const Right(true));
      verify(() => repository.saveTutor(params.tutor)).called(1);
    });

    test('SaveTutorUseCase returns failure on error', () async {
      final tutor = {'id': 't1'};
      final params = SaveTutorUseCaseParams(tutor: tutor);
      const failure = ValidationFailure(message: 'Invalid tutor');
      when(() => repository.saveTutor(params.tutor))
          .thenAnswer((_) async => const Left(failure));

      final result = await saveTutorUseCase(params);

      expect(result, const Left(failure));
    });

    test('RemoveSavedTutorUseCase forwards id and returns true', () async {
      const params = RemoveSavedTutorUseCaseParams(tutorId: 't1');
      when(() => repository.removeSavedTutor(params.tutorId))
          .thenAnswer((_) async => const Right(true));

      final result = await removeSavedTutorUseCase(params);

      expect(result, const Right(true));
      verify(() => repository.removeSavedTutor(params.tutorId)).called(1);
    });

    test('RemoveSavedTutorUseCase returns failure on error', () async {
      const params = RemoveSavedTutorUseCaseParams(tutorId: 't1');
      const failure = ApiFailure(message: 'Delete failed');
      when(() => repository.removeSavedTutor(params.tutorId))
          .thenAnswer((_) async => const Left(failure));

      final result = await removeSavedTutorUseCase(params);

      expect(result, const Left(failure));
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/tutors/domain/repositories/tutors_repository.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_category_tutors_usecase.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_tutor_availability_usecase.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_tutor_detail_usecase.dart';

class MockTutorsRepository extends Mock implements ITutorsRepository {}

void main() {
  late MockTutorsRepository repository;
  late GetCategoryTutorsUseCase getCategoryTutorsUseCase;
  late GetTutorDetailUseCase getTutorDetailUseCase;
  late GetTutorAvailabilityUseCase getTutorAvailabilityUseCase;

  setUp(() {
    repository = MockTutorsRepository();
    getCategoryTutorsUseCase = GetCategoryTutorsUseCase(tutorsRepository: repository);
    getTutorDetailUseCase = GetTutorDetailUseCase(tutorsRepository: repository);
    getTutorAvailabilityUseCase = GetTutorAvailabilityUseCase(tutorsRepository: repository);
  });

  group('Tutors usecases', () {
    test('GetCategoryTutorsUseCase returns list on success', () async {
      const params = GetCategoryTutorsUseCaseParams(category: 'Math');
      final tutors = [
        {'id': 't1', 'name': 'A'},
      ];

      when(() => repository.getCategoryTutors(params.category))
          .thenAnswer((_) async => Right(tutors));

      final result = await getCategoryTutorsUseCase(params);

      expect(result, Right(tutors));
      verify(() => repository.getCategoryTutors(params.category)).called(1);
    });

    test('GetCategoryTutorsUseCase returns failure on error', () async {
      const params = GetCategoryTutorsUseCaseParams(category: 'Math');
      const failure = ApiFailure(message: 'Fetch failed');
      when(() => repository.getCategoryTutors(params.category))
          .thenAnswer((_) async => const Left(failure));

      final result = await getCategoryTutorsUseCase(params);

      expect(result, const Left(failure));
    });

    test('GetTutorDetailUseCase returns detail on success', () async {
      const params = GetTutorDetailUseCaseParams(tutorId: 't1');
      final tutor = {'id': 't1', 'name': 'Tutor A'};

      when(() => repository.getTutorDetail(params.tutorId))
          .thenAnswer((_) async => Right(tutor));

      final result = await getTutorDetailUseCase(params);

      expect(result, Right(tutor));
      verify(() => repository.getTutorDetail(params.tutorId)).called(1);
    });

    test('GetTutorDetailUseCase returns failure on error', () async {
      const params = GetTutorDetailUseCaseParams(tutorId: 't1');
      const failure = NetworkFailure(message: 'No internet');

      when(() => repository.getTutorDetail(params.tutorId))
          .thenAnswer((_) async => const Left(failure));

      final result = await getTutorDetailUseCase(params);

      expect(result, const Left(failure));
    });

    test('GetTutorAvailabilityUseCase returns slots on success', () async {
      const params = GetTutorAvailabilityUseCaseParams(tutorId: 't1');
      final slots = [
        {'date': '2026-03-10', 'time': '10:00'},
      ];

      when(() => repository.getTutorAvailability(params.tutorId))
          .thenAnswer((_) async => Right(slots));

      final result = await getTutorAvailabilityUseCase(params);

      expect(result, Right(slots));
      verify(() => repository.getTutorAvailability(params.tutorId)).called(1);
    });

    test('GetTutorAvailabilityUseCase returns failure on error', () async {
      const params = GetTutorAvailabilityUseCaseParams(tutorId: 't1');
      const failure = ApiFailure(message: 'Slots failed');

      when(() => repository.getTutorAvailability(params.tutorId))
          .thenAnswer((_) async => const Left(failure));

      final result = await getTutorAvailabilityUseCase(params);

      expect(result, const Left(failure));
    });
  });
}

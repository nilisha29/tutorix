import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_category_tutors_usecase.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_tutor_availability_usecase.dart';
import 'package:tutorix/features/tutors/domain/usecases/get_tutor_detail_usecase.dart';
import 'package:tutorix/features/tutors/presentation/view_model/tutors_viewmodel.dart';

class MockGetCategoryTutorsUseCase extends Mock implements GetCategoryTutorsUseCase {}

class MockGetTutorDetailUseCase extends Mock implements GetTutorDetailUseCase {}

class MockGetTutorAvailabilityUseCase extends Mock
    implements GetTutorAvailabilityUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GetCategoryTutorsUseCaseParams(category: 'Math'));
    registerFallbackValue(const GetTutorDetailUseCaseParams(tutorId: 't1'));
    registerFallbackValue(
      const GetTutorAvailabilityUseCaseParams(tutorId: 't1'),
    );
  });

  group('TutorsViewModel', () {
    test('fetchCategoryTutors sets tutors on success', () async {
      final getCategory = MockGetCategoryTutorsUseCase();
      final getDetail = MockGetTutorDetailUseCase();
      final getAvailability = MockGetTutorAvailabilityUseCase();
      final tutors = [
        {'id': 't1'}
      ];
      when(() => getCategory(any())).thenAnswer((_) async => Right(tutors));
      final vm = TutorsViewModel(
        getCategoryTutorsUseCase: getCategory,
        getTutorDetailUseCase: getDetail,
        getTutorAvailabilityUseCase: getAvailability,
      );

      await vm.fetchCategoryTutors('Math');

      expect(vm.state.categoryTutors, tutors);
      expect(vm.state.errorMessage, isNull);
    });

    test('fetchTutorDetail sets selected tutor on success', () async {
      final getCategory = MockGetCategoryTutorsUseCase();
      final getDetail = MockGetTutorDetailUseCase();
      final getAvailability = MockGetTutorAvailabilityUseCase();
      final tutor = {'id': 't1', 'name': 'Tutor A'};
      when(() => getDetail(any())).thenAnswer((_) async => Right(tutor));
      final vm = TutorsViewModel(
        getCategoryTutorsUseCase: getCategory,
        getTutorDetailUseCase: getDetail,
        getTutorAvailabilityUseCase: getAvailability,
      );

      await vm.fetchTutorDetail('t1');

      expect(vm.state.selectedTutor, tutor);
    });

    test('fetchTutorAvailability sets slots on success', () async {
      final getCategory = MockGetCategoryTutorsUseCase();
      final getDetail = MockGetTutorDetailUseCase();
      final getAvailability = MockGetTutorAvailabilityUseCase();
      final slots = [
        {'time': '10:00'}
      ];
      when(() => getAvailability(any())).thenAnswer((_) async => Right(slots));
      final vm = TutorsViewModel(
        getCategoryTutorsUseCase: getCategory,
        getTutorDetailUseCase: getDetail,
        getTutorAvailabilityUseCase: getAvailability,
      );

      await vm.fetchTutorAvailability('t1');

      expect(vm.state.availability, slots);
    });

    test('fetchTutorDetail sets error on failure', () async {
      final getCategory = MockGetCategoryTutorsUseCase();
      final getDetail = MockGetTutorDetailUseCase();
      final getAvailability = MockGetTutorAvailabilityUseCase();
      const failure = ApiFailure(message: 'not found');
      when(() => getDetail(any())).thenAnswer((_) async => const Left(failure));
      final vm = TutorsViewModel(
        getCategoryTutorsUseCase: getCategory,
        getTutorDetailUseCase: getDetail,
        getTutorAvailabilityUseCase: getAvailability,
      );

      await vm.fetchTutorDetail('t1');

      expect(vm.state.errorMessage, failure.message);
      expect(vm.state.isLoading, false);
    });
  });
}

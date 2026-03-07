import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:tutorix/features/dashboard/domain/usecases/book_tutor_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_categories_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_tutors_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_user_profile_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/update_profile_usecase.dart';

class MockDashboardRepository extends Mock implements IDashboardRepository {}

void main() {
  late MockDashboardRepository repository;

  late GetTutorsUseCase getTutorsUseCase;
  late GetCategoriesUseCase getCategoriesUseCase;
  late BookTutorUseCase bookTutorUseCase;
  late GetUserProfileUseCase getUserProfileUseCase;
  late UpdateProfileUseCase updateProfileUseCase;

  setUp(() {
    repository = MockDashboardRepository();
    getTutorsUseCase = GetTutorsUseCase(dashboardRepository: repository);
    getCategoriesUseCase = GetCategoriesUseCase(dashboardRepository: repository);
    bookTutorUseCase = BookTutorUseCase(dashboardRepository: repository);
    getUserProfileUseCase = GetUserProfileUseCase(dashboardRepository: repository);
    updateProfileUseCase = UpdateProfileUseCase(dashboardRepository: repository);
  });

  group('Dashboard usecases', () {
    test('GetTutorsUseCase returns tutors on success', () async {
      final tutors = [
        {'id': '1', 'name': 'Tutor A'},
      ];
      when(() => repository.getTutors()).thenAnswer((_) async => Right(tutors));

      final result = await getTutorsUseCase();

      expect(result, Right(tutors));
      verify(() => repository.getTutors()).called(1);
    });

    test('GetTutorsUseCase returns failure on error', () async {
      const failure = ApiFailure(message: 'Failed to fetch tutors');
      when(() => repository.getTutors()).thenAnswer((_) async => const Left(failure));

      final result = await getTutorsUseCase();

      expect(result, const Left(failure));
    });

    test('GetCategoriesUseCase returns categories on success', () async {
      final categories = [
        {'id': 'math', 'name': 'Mathematics'},
      ];
      when(() => repository.getCategories()).thenAnswer((_) async => Right(categories));

      final result = await getCategoriesUseCase();

      expect(result, Right(categories));
      verify(() => repository.getCategories()).called(1);
    });

    test('GetCategoriesUseCase returns failure on error', () async {
      const failure = NetworkFailure(message: 'No internet');
      when(() => repository.getCategories()).thenAnswer((_) async => const Left(failure));

      final result = await getCategoriesUseCase();

      expect(result, const Left(failure));
    });

    test('BookTutorUseCase forwards payload and returns booking', () async {
      const params = BookTutorUseCaseParams(
        tutorId: 'tutor-1',
        date: '2026-03-10',
        startTime: '10:00',
        durationMinutes: 60,
        paymentMethod: 'khalti',
      );
      final booking = {'bookingId': 'b1', 'status': 'pending'};

      when(() => repository.bookTutor(any())).thenAnswer((_) async => Right(booking));

      final result = await bookTutorUseCase(params);

      expect(result, Right(booking));
      verify(() => repository.bookTutor(params.toJson())).called(1);
    });

    test('BookTutorUseCase returns failure on error', () async {
      const params = BookTutorUseCaseParams(
        tutorId: 'tutor-1',
        date: '2026-03-10',
        startTime: '10:00',
        durationMinutes: 60,
        paymentMethod: 'esewa',
      );
      const failure = ValidationFailure(message: 'Invalid booking');

      when(() => repository.bookTutor(any())).thenAnswer((_) async => const Left(failure));

      final result = await bookTutorUseCase(params);

      expect(result, const Left(failure));
    });

    test('GetUserProfileUseCase returns profile on success', () async {
      final profile = {'name': 'John', 'email': 'john@test.com'};
      when(() => repository.getUserProfile()).thenAnswer((_) async => Right(profile));

      final result = await getUserProfileUseCase();

      expect(result, Right(profile));
      verify(() => repository.getUserProfile()).called(1);
    });

    test('GetUserProfileUseCase returns failure on error', () async {
      const failure = ApiFailure(message: 'Unauthorized', statusCode: 401);
      when(() => repository.getUserProfile()).thenAnswer((_) async => const Left(failure));

      final result = await getUserProfileUseCase();

      expect(result, const Left(failure));
    });

    test('UpdateProfileUseCase forwards payload and returns updated profile', () async {
      const params = UpdateProfileUseCaseParams(
        fullName: 'John Updated',
        phoneNumber: '9800000000',
        address: 'Kathmandu',
      );
      final updated = {'name': 'John Updated'};

      when(() => repository.updateProfile(any())).thenAnswer((_) async => Right(updated));

      final result = await updateProfileUseCase(params);

      expect(result, Right(updated));
      verify(() => repository.updateProfile(params.toJson())).called(1);
    });

    test('UpdateProfileUseCase returns failure on error', () async {
      const params = UpdateProfileUseCaseParams(
        fullName: 'John',
        phoneNumber: '9800',
        address: 'KTM',
      );
      const failure = ValidationFailure(message: 'Invalid phone number');

      when(() => repository.updateProfile(any())).thenAnswer((_) async => const Left(failure));

      final result = await updateProfileUseCase(params);

      expect(result, const Left(failure));
    });
  });
}

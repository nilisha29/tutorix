import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/dashboard/domain/usecases/book_tutor_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_categories_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_tutors_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/get_user_profile_usecase.dart';
import 'package:tutorix/features/dashboard/domain/usecases/update_profile_usecase.dart';
import 'package:tutorix/features/dashboard/presentation/view_model/booking_viewmodel.dart';
import 'package:tutorix/features/dashboard/presentation/view_model/categories_viewmodel.dart';
import 'package:tutorix/features/dashboard/presentation/view_model/home_viewmodel.dart';
import 'package:tutorix/features/dashboard/presentation/view_model/profile_viewmodel.dart';

class MockGetTutorsUseCase extends Mock implements GetTutorsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockBookTutorUseCase extends Mock implements BookTutorUseCase {}

class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const BookTutorUseCaseParams(
        tutorId: 't1',
        date: '2026-01-01',
        startTime: '10:00',
        durationMinutes: 60,
        paymentMethod: 'khalti',
      ),
    );
    registerFallbackValue(
      const UpdateProfileUseCaseParams(
        fullName: 'A',
        phoneNumber: '9800000000',
        address: 'KTM',
      ),
    );
  });

  group('Dashboard ViewModels', () {
    test('HomeViewModel sets tutors on success', () async {
      final useCase = MockGetTutorsUseCase();
      final tutors = [
        {'id': '1'}
      ];
      when(() => useCase()).thenAnswer((_) async => Right(tutors));
      final vm = HomeViewModel(getTutorsUseCase: useCase);

      await vm.fetchTutors();

      expect(vm.state.isLoading, false);
      expect(vm.state.tutors, tutors);
      expect(vm.state.errorMessage, isNull);
    });

    test('HomeViewModel sets error on failure', () async {
      final useCase = MockGetTutorsUseCase();
      const failure = NetworkFailure(message: 'offline');
      when(() => useCase()).thenAnswer((_) async => const Left(failure));
      final vm = HomeViewModel(getTutorsUseCase: useCase);

      await vm.fetchTutors();

      expect(vm.state.isLoading, false);
      expect(vm.state.errorMessage, failure.message);
    });

    test('CategoriesViewModel sets categories on success', () async {
      final useCase = MockGetCategoriesUseCase();
      final categories = [
        {'name': 'Math'}
      ];
      when(() => useCase()).thenAnswer((_) async => Right(categories));
      final vm = CategoriesViewModel(getCategoriesUseCase: useCase);

      await vm.fetchCategories();

      expect(vm.state.categories, categories);
      expect(vm.state.errorMessage, isNull);
    });

    test('BookingViewModel marks booked on success', () async {
      final useCase = MockBookTutorUseCase();
      const params = BookTutorUseCaseParams(
        tutorId: 't1',
        date: '2026-03-08',
        startTime: '10:00',
        durationMinutes: 90,
        paymentMethod: 'esewa',
      );
      final booking = {'bookingId': 'b1'};
      when(() => useCase(params)).thenAnswer((_) async => Right(booking));
      final vm = BookingViewModel(bookTutorUseCase: useCase);

      await vm.bookTutor(params);

      expect(vm.state.isBooked, true);
      expect(vm.state.latestBooking, booking);
      expect(vm.state.errorMessage, isNull);
    });

    test('BookingViewModel resetStatus clears booked flag', () {
      final useCase = MockBookTutorUseCase();
      final vm = BookingViewModel(bookTutorUseCase: useCase);

      vm.resetStatus();

      expect(vm.state.isBooked, false);
    });

    test('ProfileViewModel fetchProfile sets error on failure', () async {
      final getUseCase = MockGetUserProfileUseCase();
      final updateUseCase = MockUpdateProfileUseCase();
      const failure = ApiFailure(message: 'unauthorized', statusCode: 401);
      when(() => getUseCase()).thenAnswer((_) async => const Left(failure));
      final vm = ProfileViewModel(
        getUserProfileUseCase: getUseCase,
        updateProfileUseCase: updateUseCase,
      );

      await vm.fetchProfile();

      expect(vm.state.errorMessage, failure.message);
      expect(vm.state.isLoading, false);
    });

    test('ProfileViewModel updateProfile sets profile on success', () async {
      final getUseCase = MockGetUserProfileUseCase();
      final updateUseCase = MockUpdateProfileUseCase();
      const params = UpdateProfileUseCaseParams(
        fullName: 'John',
        phoneNumber: '9800000000',
        address: 'KTM',
      );
      final updated = {'fullName': 'John'};
      when(() => updateUseCase(params)).thenAnswer((_) async => Right(updated));
      final vm = ProfileViewModel(
        getUserProfileUseCase: getUseCase,
        updateProfileUseCase: updateUseCase,
      );

      await vm.updateProfile(params);

      expect(vm.state.isUpdating, false);
      expect(vm.state.profile, updated);
      expect(vm.state.errorMessage, isNull);
    });
  });
}

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:tutorix/features/bookings/domain/usecases/get_bookings_usecase.dart';
import 'package:tutorix/features/bookings/presentation/view_model/bookings_viewmodel.dart';

class MockGetBookingsUseCase extends Mock implements GetBookingsUseCase {}

class MockCancelBookingUseCase extends Mock implements CancelBookingUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(const CancelBookingUseCaseParams(bookingId: 'b1'));
  });

  group('BookingsViewModel', () {
    test('fetchBookings sets items on success', () async {
      final getUseCase = MockGetBookingsUseCase();
      final cancelUseCase = MockCancelBookingUseCase();
      final items = [
        {'id': 'b1'}
      ];
      when(() => getUseCase()).thenAnswer((_) async => Right(items));
      final vm = BookingsViewModel(
        getBookingsUseCase: getUseCase,
        cancelBookingUseCase: cancelUseCase,
      );

      await vm.fetchBookings();

      expect(vm.state.items, items);
      expect(vm.state.errorMessage, isNull);
    });

    test('fetchBookings sets error on failure', () async {
      final getUseCase = MockGetBookingsUseCase();
      final cancelUseCase = MockCancelBookingUseCase();
      const failure = NetworkFailure(message: 'offline');
      when(() => getUseCase()).thenAnswer((_) async => const Left(failure));
      final vm = BookingsViewModel(
        getBookingsUseCase: getUseCase,
        cancelBookingUseCase: cancelUseCase,
      );

      await vm.fetchBookings();

      expect(vm.state.errorMessage, failure.message);
    });

    test('cancelBooking triggers refresh on success', () async {
      final getUseCase = MockGetBookingsUseCase();
      final cancelUseCase = MockCancelBookingUseCase();
      when(() => cancelUseCase(any())).thenAnswer((_) async => const Right(true));
      when(() => getUseCase()).thenAnswer((_) async => const Right([]));
      final vm = BookingsViewModel(
        getBookingsUseCase: getUseCase,
        cancelBookingUseCase: cancelUseCase,
      );

      await vm.cancelBooking('b1');
      await Future<void>.delayed(Duration.zero);

      verify(() => getUseCase()).called(1);
    });
  });
}

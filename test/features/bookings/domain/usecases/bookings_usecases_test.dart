import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/bookings/domain/repositories/bookings_repository.dart';
import 'package:tutorix/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:tutorix/features/bookings/domain/usecases/get_bookings_usecase.dart';

class MockBookingsRepository extends Mock implements IBookingsRepository {}

void main() {
  late MockBookingsRepository repository;
  late GetBookingsUseCase getBookingsUseCase;
  late CancelBookingUseCase cancelBookingUseCase;

  setUp(() {
    repository = MockBookingsRepository();
    getBookingsUseCase = GetBookingsUseCase(bookingsRepository: repository);
    cancelBookingUseCase = CancelBookingUseCase(bookingsRepository: repository);
  });

  group('Bookings usecases', () {
    test('GetBookingsUseCase returns list on success', () async {
      final bookings = [
        {'id': 'b1', 'status': 'confirmed'},
      ];
      when(() => repository.getBookings()).thenAnswer((_) async => Right(bookings));

      final result = await getBookingsUseCase();

      expect(result, Right(bookings));
      verify(() => repository.getBookings()).called(1);
    });

    test('GetBookingsUseCase returns failure on error', () async {
      const failure = NetworkFailure(message: 'Offline');
      when(() => repository.getBookings()).thenAnswer((_) async => const Left(failure));

      final result = await getBookingsUseCase();

      expect(result, const Left(failure));
    });

    test('CancelBookingUseCase forwards booking id and returns true', () async {
      const params = CancelBookingUseCaseParams(bookingId: 'b1');
      when(() => repository.cancelBooking(params.bookingId))
          .thenAnswer((_) async => const Right(true));

      final result = await cancelBookingUseCase(params);

      expect(result, const Right(true));
      verify(() => repository.cancelBooking(params.bookingId)).called(1);
    });

    test('CancelBookingUseCase returns failure on error', () async {
      const params = CancelBookingUseCaseParams(bookingId: 'b1');
      const failure = ApiFailure(message: 'Cannot cancel', statusCode: 409);
      when(() => repository.cancelBooking(params.bookingId))
          .thenAnswer((_) async => const Left(failure));

      final result = await cancelBookingUseCase(params);

      expect(result, const Left(failure));
    });
  });
}

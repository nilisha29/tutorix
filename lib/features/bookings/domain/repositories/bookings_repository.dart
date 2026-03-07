import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';

abstract interface class IBookingsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getBookings();

  Future<Either<Failure, bool>> cancelBooking(String bookingId);
}

final bookingsRepositoryProvider = Provider<IBookingsRepository>((ref) {
  throw UnimplementedError(
    'bookingsRepositoryProvider must be overridden with a concrete implementation.',
  );
});

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/bookings/data/datasources/bookings_datasource.dart';
import 'package:tutorix/features/bookings/data/datasources/local/bookings_local_datasource.dart';
import 'package:tutorix/features/bookings/data/datasources/remote/bookings_remote_datasource.dart';
import 'package:tutorix/features/bookings/domain/repositories/bookings_repository.dart';

final bookingsRepositoryImplProvider = Provider<IBookingsRepository>((ref) {
  final remoteDatasource = ref.read(bookingsRemoteDatasourceProvider);
  final localDatasource = ref.read(bookingsLocalDatasourceProvider);
  return BookingsRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});

class BookingsRepositoryImpl implements IBookingsRepository {
  BookingsRepositoryImpl({
    required IBookingsDatasource remoteDatasource,
    required IBookingsDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final IBookingsDatasource _remoteDatasource;
  final IBookingsDatasource _localDatasource;

  @override
  Future<Either<Failure, bool>> cancelBooking(String bookingId) async {
    try {
      final result = await _remoteDatasource.cancelBooking(bookingId);
      await _localDatasource.cancelBooking(bookingId);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.cancelBooking(bookingId);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getBookings() async {
    try {
      final result = await _remoteDatasource.getBookings();
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getBookings();
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }
}

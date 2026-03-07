import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/bookings/domain/repositories/bookings_repository.dart';

class CancelBookingUseCaseParams extends Equatable {
  const CancelBookingUseCaseParams({required this.bookingId});

  final String bookingId;

  @override
  List<Object?> get props => [bookingId];
}

class CancelBookingUseCase
    implements UsecaseWithParams<bool, CancelBookingUseCaseParams> {
  CancelBookingUseCase({required IBookingsRepository bookingsRepository})
      : _bookingsRepository = bookingsRepository;

  final IBookingsRepository _bookingsRepository;

  @override
  Future<Either<Failure, bool>> call(CancelBookingUseCaseParams params) {
    return _bookingsRepository.cancelBooking(params.bookingId);
  }
}

final cancelBookingUseCaseProvider = Provider<CancelBookingUseCase>((ref) {
  return CancelBookingUseCase(
    bookingsRepository: ref.read(bookingsRepositoryProvider),
  );
});

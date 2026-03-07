import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/bookings/domain/repositories/bookings_repository.dart';

class GetBookingsUseCase
    implements UsecaseWithoutParams<List<Map<String, dynamic>>> {
  GetBookingsUseCase({required IBookingsRepository bookingsRepository})
      : _bookingsRepository = bookingsRepository;

  final IBookingsRepository _bookingsRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _bookingsRepository.getBookings();
  }
}

final getBookingsUseCaseProvider = Provider<GetBookingsUseCase>((ref) {
  return GetBookingsUseCase(
    bookingsRepository: ref.read(bookingsRepositoryProvider),
  );
});

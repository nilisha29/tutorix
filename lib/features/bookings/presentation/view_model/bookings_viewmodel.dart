import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:tutorix/features/bookings/domain/usecases/get_bookings_usecase.dart';
import 'package:tutorix/features/bookings/presentation/state/bookings_state.dart';

class BookingsViewModel extends StateNotifier<BookingsState> {
  BookingsViewModel({
    required GetBookingsUseCase getBookingsUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
  })  : _getBookingsUseCase = getBookingsUseCase,
        _cancelBookingUseCase = cancelBookingUseCase,
        super(const BookingsState());

  final GetBookingsUseCase _getBookingsUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;

  Future<void> fetchBookings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getBookingsUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        items: items,
        clearError: true,
      ),
    );
  }

  Future<void> cancelBooking(String bookingId) async {
    final result =
        await _cancelBookingUseCase(CancelBookingUseCaseParams(bookingId: bookingId));

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (_) => fetchBookings(),
    );
  }
}

final bookingsViewModelProvider =
    StateNotifierProvider<BookingsViewModel, BookingsState>((ref) {
  return BookingsViewModel(
    getBookingsUseCase: ref.read(getBookingsUseCaseProvider),
    cancelBookingUseCase: ref.read(cancelBookingUseCaseProvider),
  );
});

import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/dashboard/domain/usecases/book_tutor_usecase.dart';
import 'package:tutorix/features/dashboard/presentation/state/booking_state.dart';

class BookingViewModel extends StateNotifier<BookingState> {
  BookingViewModel({required BookTutorUseCase bookTutorUseCase})
      : _bookTutorUseCase = bookTutorUseCase,
        super(const BookingState());

  final BookTutorUseCase _bookTutorUseCase;

  Future<void> bookTutor(BookTutorUseCaseParams params) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      isBooked: false,
    );

    final result = await _bookTutorUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          isBooked: false,
        );
      },
      (booking) {
        state = state.copyWith(
          isLoading: false,
          isBooked: true,
          latestBooking: booking,
          clearError: true,
        );
      },
    );
  }

  void resetStatus() {
    state = state.copyWith(isBooked: false, clearError: true);
  }
}

final bookingViewModelProvider =
    StateNotifierProvider<BookingViewModel, BookingState>((ref) {
  return BookingViewModel(
    bookTutorUseCase: ref.read(bookTutorUseCaseProvider),
  );
});

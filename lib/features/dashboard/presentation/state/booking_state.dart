class BookingState {
  const BookingState({
    this.isLoading = false,
    this.errorMessage,
    this.isBooked = false,
    this.latestBooking,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isBooked;
  final Map<String, dynamic>? latestBooking;

  BookingState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isBooked,
    Map<String, dynamic>? latestBooking,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isBooked: isBooked ?? this.isBooked,
      latestBooking: latestBooking ?? this.latestBooking,
    );
  }
}

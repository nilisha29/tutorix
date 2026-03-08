abstract interface class IBookingsDatasource {
  Future<List<Map<String, dynamic>>> getBookings();

  Future<bool> cancelBooking(String bookingId);
}

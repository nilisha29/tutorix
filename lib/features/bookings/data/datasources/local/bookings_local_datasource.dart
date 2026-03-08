import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/bookings/data/datasources/bookings_datasource.dart';

final bookingsLocalDatasourceProvider = Provider<IBookingsDatasource>((ref) {
  return BookingsLocalDatasource();
});

class BookingsLocalDatasource implements IBookingsDatasource {
  final List<Map<String, dynamic>> _bookings = <Map<String, dynamic>>[];

  @override
  Future<bool> cancelBooking(String bookingId) async {
    _bookings.removeWhere((item) => item['id']?.toString() == bookingId);
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getBookings() async {
    return _bookings;
  }
}

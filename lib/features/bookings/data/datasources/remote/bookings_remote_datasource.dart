import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/features/bookings/data/datasources/bookings_datasource.dart';

final bookingsRemoteDatasourceProvider = Provider<IBookingsDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return BookingsRemoteDatasource(apiClient: apiClient);
});

class BookingsRemoteDatasource implements IBookingsDatasource {
  BookingsRemoteDatasource({required ApiClient apiClient});

  @override
  Future<bool> cancelBooking(String bookingId) async {
    return true;
  }

  @override
  Future<List<Map<String, dynamic>>> getBookings() async {
    return <Map<String, dynamic>>[];
  }
}

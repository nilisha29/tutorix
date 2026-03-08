import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/features/dashboard/data/datasources/dashboard_datasource.dart';

final dashboardRemoteDatasourceProvider = Provider<IDashboardDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return DashboardRemoteDatasource(apiClient: apiClient);
});

class DashboardRemoteDatasource implements IDashboardDatasource {
  DashboardRemoteDatasource({required ApiClient apiClient});

  @override
  Future<List<Map<String, dynamic>>> getTutors() async {
    // Placeholder until feature API endpoints are finalized.
    return <Map<String, dynamic>>[];
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> bookTutor(Map<String, dynamic> bookingPayload) async {
    return <String, dynamic>{'status': 'queued', 'payload': bookingPayload};
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profilePayload) async {
    return profilePayload;
  }
}

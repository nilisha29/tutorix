import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/dashboard/data/datasources/dashboard_datasource.dart';

final dashboardLocalDatasourceProvider = Provider<IDashboardDatasource>((ref) {
  return DashboardLocalDatasource();
});

class DashboardLocalDatasource implements IDashboardDatasource {
  List<Map<String, dynamic>> _tutors = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _categories = <Map<String, dynamic>>[];
  Map<String, dynamic> _profile = <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> bookTutor(Map<String, dynamic> bookingPayload) async {
    return <String, dynamic>{'status': 'cached', 'payload': bookingPayload};
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return _categories;
  }

  @override
  Future<List<Map<String, dynamic>>> getTutors() async {
    return _tutors;
  }

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    return _profile;
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profilePayload) async {
    _profile = profilePayload;
    return _profile;
  }
}

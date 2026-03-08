import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/features/tutors/data/datasources/tutors_datasource.dart';

final tutorsRemoteDatasourceProvider = Provider<ITutorsDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return TutorsRemoteDatasource(apiClient: apiClient);
});

class TutorsRemoteDatasource implements ITutorsDatasource {
  TutorsRemoteDatasource({required ApiClient apiClient});

  @override
  Future<List<Map<String, dynamic>>> getCategoryTutors(String category) async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<List<Map<String, dynamic>>> getTutorAvailability(String tutorId) async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> getTutorDetail(String tutorId) async {
    return <String, dynamic>{'id': tutorId};
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/features/saved_tutors/data/datasources/saved_tutors_datasource.dart';

final savedTutorsRemoteDatasourceProvider = Provider<ISavedTutorsDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return SavedTutorsRemoteDatasource(apiClient: apiClient);
});

class SavedTutorsRemoteDatasource implements ISavedTutorsDatasource {
  SavedTutorsRemoteDatasource({required ApiClient apiClient});

  @override
  Future<List<Map<String, dynamic>>> getSavedTutors() async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<bool> removeSavedTutor(String tutorId) async {
    return true;
  }

  @override
  Future<bool> saveTutor(Map<String, dynamic> tutor) async {
    return true;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/saved_tutors/data/datasources/saved_tutors_datasource.dart';

final savedTutorsLocalDatasourceProvider = Provider<ISavedTutorsDatasource>((ref) {
  return SavedTutorsLocalDatasource();
});

class SavedTutorsLocalDatasource implements ISavedTutorsDatasource {
  final List<Map<String, dynamic>> _savedTutors = <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> getSavedTutors() async {
    return _savedTutors;
  }

  @override
  Future<bool> removeSavedTutor(String tutorId) async {
    _savedTutors.removeWhere((item) => item['id']?.toString() == tutorId);
    return true;
  }

  @override
  Future<bool> saveTutor(Map<String, dynamic> tutor) async {
    _savedTutors.add(tutor);
    return true;
  }
}

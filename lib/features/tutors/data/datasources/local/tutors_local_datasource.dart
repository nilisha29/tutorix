import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/tutors/data/datasources/tutors_datasource.dart';

final tutorsLocalDatasourceProvider = Provider<ITutorsDatasource>((ref) {
  return TutorsLocalDatasource();
});

class TutorsLocalDatasource implements ITutorsDatasource {
  final List<Map<String, dynamic>> _cachedTutors = <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> getCategoryTutors(String category) async {
    return _cachedTutors.where((item) => item['category'] == category).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTutorAvailability(String tutorId) async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> getTutorDetail(String tutorId) async {
    return _cachedTutors.firstWhere(
      (item) => item['id']?.toString() == tutorId,
      orElse: () => <String, dynamic>{},
    );
  }
}

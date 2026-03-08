abstract interface class ITutorsDatasource {
  Future<List<Map<String, dynamic>>> getCategoryTutors(String category);

  Future<Map<String, dynamic>> getTutorDetail(String tutorId);

  Future<List<Map<String, dynamic>>> getTutorAvailability(String tutorId);
}

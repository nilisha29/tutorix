abstract interface class ISavedTutorsDatasource {
  Future<List<Map<String, dynamic>>> getSavedTutors();

  Future<bool> saveTutor(Map<String, dynamic> tutor);

  Future<bool> removeSavedTutor(String tutorId);
}

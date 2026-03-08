abstract interface class IDashboardDatasource {
  Future<List<Map<String, dynamic>>> getTutors();

  Future<List<Map<String, dynamic>>> getCategories();

  Future<Map<String, dynamic>> bookTutor(Map<String, dynamic> bookingPayload);

  Future<Map<String, dynamic>> getUserProfile();

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profilePayload);
}

abstract interface class IEditProfileDatasource {
  Future<Map<String, dynamic>> getProfile();

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload);
}

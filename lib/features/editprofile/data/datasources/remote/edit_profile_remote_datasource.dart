import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/features/editprofile/data/datasources/edit_profile_datasource.dart';

final editProfileRemoteDatasourceProvider = Provider<IEditProfileDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return EditProfileRemoteDatasource(apiClient: apiClient);
});

class EditProfileRemoteDatasource implements IEditProfileDatasource {
  EditProfileRemoteDatasource({required ApiClient apiClient});

  @override
  Future<Map<String, dynamic>> getProfile() async {
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    return payload;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/editprofile/data/datasources/edit_profile_datasource.dart';

final editProfileLocalDatasourceProvider = Provider<IEditProfileDatasource>((ref) {
  return EditProfileLocalDatasource();
});

class EditProfileLocalDatasource implements IEditProfileDatasource {
  Map<String, dynamic> _profile = <String, dynamic>{};

  @override
  Future<Map<String, dynamic>> getProfile() async {
    return _profile;
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    _profile = payload;
    return _profile;
  }
}

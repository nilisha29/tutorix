import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/services/hive/hive_service.dart';
import 'package:tutorix/features/auth/data/datasources/auth_datasource.dart';
import 'package:tutorix/features/auth/data/models/auth_hive_model.dart';


final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService;


  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      final authId = _hiveService.getCurrentAuthId();
      if (authId == null) return null;
      return _hiveService.getCurrentUser(authId);
    } catch (e) {
      return null;
    }
  }

  /// Login with email and password
  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.loginUser(email, password);
      if (user != null && user.authId != null) {
        await _hiveService.setCurrentAuthId(user.authId!);
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Logout the current user
  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutUser();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Register a new user
  @override
  Future<bool> register(AuthHiveModel model) async {
    try {
      if (_hiveService.isEmailExists(model.email)) {
        return false; // Email already exists
      }
      await _hiveService.registerUser(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if email already exists
  @override
  Future<bool> isEmailExists(String email) async {
    try {
      return _hiveService.isEmailExists(email);
    } catch (e) {
      return false;
    }
  }
}

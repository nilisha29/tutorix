import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tutorix/core/constants/hive_table_constant.dart';
import 'package:tutorix/features/auth/data/models/auth_hive_model.dart';


final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {

  Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }


  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  /// Open all Hive boxes
  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<String>(HiveTableConstant.sessionBox);
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ==================== Auth CRUD Operations ====================

  /// Private getter for auth box
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  /// Private getter for session box
  Box<String> get _sessionBox =>
      Hive.box<String>(HiveTableConstant.sessionBox);

  /// Set current auth id in session box
  Future<void> setCurrentAuthId(String authId) async {
    await _sessionBox.put(HiveTableConstant.currentAuthKey, authId);
  }

  /// Get current auth id
  String? getCurrentAuthId() {
    return _sessionBox.get(HiveTableConstant.currentAuthKey);
  }

  /// Clear current auth id
  Future<void> clearCurrentAuthId() async {
    await _sessionBox.delete(HiveTableConstant.currentAuthKey);
  }

  /// Register a new user
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  /// Login user by email & password
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    return users.isNotEmpty ? users.first : null;
  }

  /// Logout user (clear session)
  Future<void> logoutUser() async {
    await clearCurrentAuthId();
  }

  /// Get current user by authId
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  /// Check if an email already exists
  bool isEmailExists(String email) {
    return _authBox.values.any((user) => user.email == email);
  }
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    await Hive.openBox<String>(HiveTableConstant.cacheBox);
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

  /// Private getter for generic cache box
  Box<String> get _cacheBox => Hive.box<String>(HiveTableConstant.cacheBox);

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
    final key = (model.authId ?? model.email).trim();
    await _authBox.put(key, model);
    return model;
  }

  /// Login user by email & password
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();
    final users = _authBox.values.where(
      (user) =>
          user.email.trim().toLowerCase() == normalizedEmail &&
          (user.password ?? '').trim() == normalizedPassword,
    );
    return users.isNotEmpty ? users.first : null;
  }

  /// Get user by email (used for offline fallback)
  AuthHiveModel? getUserByEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final users = _authBox.values.where(
      (user) => user.email.trim().toLowerCase() == normalizedEmail,
    );
    return users.isNotEmpty ? users.first : null;
  }

  /// Returns user from current session auth id if available.
  AuthHiveModel? getSessionUser() {
    final authId = getCurrentAuthId();
    if (authId == null || authId.trim().isEmpty) return null;
    return getCurrentUser(authId.trim());
  }

  /// Returns any cached user as final offline fallback.
  AuthHiveModel? getAnyCachedUser() {
    if (_authBox.values.isEmpty) return null;
    return _authBox.values.first;
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
    final normalizedEmail = email.trim().toLowerCase();
    return _authBox.values
        .any((user) => user.email.trim().toLowerCase() == normalizedEmail);
  }

  // ==================== Generic JSON Cache Operations ====================

  Future<void> setCachedData(String key, dynamic value) async {
    final encoded = jsonEncode(value);
    await _cacheBox.put(key, encoded);
  }

  dynamic getCachedData(String key) {
    final encoded = _cacheBox.get(key);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return jsonDecode(encoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCachedData(String key) async {
    await _cacheBox.delete(key);
  }
}

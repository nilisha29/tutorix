import 'package:tutorix/features/auth/data/models/auth_hive_model.dart';

/// Interface for Auth data source
abstract interface class IAuthDatasource {
  /// Register a new user
  Future<bool> register(AuthHiveModel model);

  /// Login user with email and password
  Future<AuthHiveModel?> login(String email, String password);

  /// Get the currently logged-in user (optional session management)
  Future<AuthHiveModel?> getCurrentUser();

  /// Logout the current user
  Future<bool> logout();

  /// Check if email already exists
  Future<bool> isEmailExists(String email);
}

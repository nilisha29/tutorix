import 'package:dio/dio.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/auth/data/models/auth_api_model.dart';

/// Remote data source for authentication - handles API calls
abstract interface class IRemoteAuthDatasource {
  /// Register a new student
  Future<Map<String, dynamic>> register(AuthApiModel model);

  /// Login with email and password
  Future<Map<String, dynamic>> login(String email, String password);

  /// Logout user
  Future<void> logout();
}

class RemoteAuthDatasource implements IRemoteAuthDatasource {
  final ApiClient _apiClient;

  RemoteAuthDatasource(this._apiClient);

  @override
  Future<Map<String, dynamic>> register(AuthApiModel model) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.studentRegister,
        data: {
          'firstName': model.firstName,
          'lastName': model.lastName,
          'email': model.email,
          'phoneNumber': model.phoneNumber,
          'username': model.username,
          'password': model.password,
          'batchId': model.batchId,
        },
      );

      // Accept any 2xx status code (200, 201, etc.)
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Connection error: ${e.message}');
    }
  }
  

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('[DEBUG] RemoteAuthDatasource.login() called with email: $email');
      final response = await _apiClient.post(
        ApiEndpoints.studentLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('[DEBUG] Login API response status: ${response.statusCode}');
      print('[DEBUG] Login API response data: ${response.data}');

      // Accept any 2xx status code
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      print('[DEBUG] DioException during login: ${e.message}');
      print('[DEBUG] DioException response: ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Connection error: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Call logout endpoint if your backend has one
      // await _apiClient.post(ApiEndpoints.studentLogout);
      // For now, just clear local storage
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
}
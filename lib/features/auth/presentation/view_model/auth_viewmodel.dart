// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/features/auth/domain/usecases/login_usecase.dart';
// import 'package:tutorix/features/auth/domain/usecases/register_usecase.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

// final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
//   return AuthViewModel();
// });

// class AuthViewModel extends Notifier<AuthState> {
//   late final RegisterUsecase _registerUsecase;
//   late final LoginUsecase _loginUsecase;

//   @override
//   AuthState build() {
//     _registerUsecase = ref.read(registerUsecaseProvider);
//     _loginUsecase = ref.read(loginUsecaseProvider);
//     return AuthState(); 
//   }

//   /// REGISTER
//   Future<void> register({
//     // required String firstName,
//     // required String lastName,
//      required String fullName,      // Added
//     required String username,
//     required String email,
//     String? phoneNumber,
//     // required String username,
//     required String password,
//     required String confirmPassword,
//       String? profilePicture,
//     String? address,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     final params = RegisterUsecaseParams(
//       // firstName: firstName,
//       // lastName: lastName,
//         fullName: fullName,
//       username: username,
//       email: email,
//       phoneNumber: phoneNumber,
//       password: password,
//       confirmPassword: confirmPassword,
//        profilePicture: profilePicture,
//       address: address,
//     );

//     final result = await _registerUsecase.call(params);

//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: failure.message,
//         );
//       },
//       (_) {
//         state = state.copyWith(status: AuthStatus.registered);
//       },
//     );
//   }

//  Future<void> login({
//   // required String username,
//    required String email,
//   required String password,
// }) async {
//   print('[DEBUG] login() called with $email'); // ✅ start
//   state = state.copyWith(status: AuthStatus.loading);

//   // final params = LoginUsecaseParams(email: username, password: password);
//   final params = LoginUsecaseParams(email: email, password: password);
//   final result = await _loginUsecase.call(params);

//   print('[DEBUG] login() result: $result'); // ✅ after API call

//   result.fold(
//     (failure) {
//       print('[DEBUG] login() failure: ${failure.message}'); // ✅ failure
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: failure.message,
//       );
//     },
    
//     (authEntity) {
//       print('[DEBUG] login() success: ${authEntity.email}'); // ✅ success
//       state = state.copyWith(
//         status: AuthStatus.authenticated,
//         authEntity: authEntity,
//       );
//     },
//   );
// }
// }




// import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as p;
// import 'package:tutorix/core/api/api_client.dart';
// import 'package:tutorix/core/api/api_endpoints.dart';
// import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

// final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
//   return AuthViewModel();
// });

// class AuthViewModel extends Notifier<AuthState> {
//   late final ApiClient _apiClient;

//   @override
//   AuthState build() {
//     _apiClient = ref.read(apiClientProvider);
//     return const AuthState();
//   }

//   /// =========================
//   /// REGISTER
//   /// =========================
//   Future<void> register({
//     required String fullName,
//     required String username,
//     required String email,
//     String? phoneNumber,
//     required String password,
//     required String confirmPassword,
//     String? profilePicture,
//     String? address,
//   }) async {
//     print('[REGISTER] Starting registration...');
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       print('[REGISTER] Profile picture path: $profilePicture');
      
//       if (profilePicture != null) {
//         final file = File(profilePicture);
//         final exists = await file.exists();
//         final size = exists ? await file.length() : 0;
//         print('[REGISTER] File exists: $exists, Size: ${size ~/ 1024} KB');
//       }

//       final formData = FormData.fromMap({
//         'fullName': fullName,
//         'username': username,
//         'email': email,
//         'password': password,
//         'confirmPassword': confirmPassword,
//         if (phoneNumber != null) 'phoneNumber': phoneNumber,
//         if (address != null) 'address': address,
//         if (profilePicture != null)
//           'profileImage': await MultipartFile.fromFile(
//             profilePicture,
//             filename: p.basename(profilePicture),
//           ),
//       });

//       print('[REGISTER] FormData created, starting upload...');

//       // ✅ Increase timeout for file uploads (up to 5 minutes)
//       final uploadOptions = Options(
//         contentType: 'multipart/form-data',
//         sendTimeout: const Duration(minutes: 5),
//         receiveTimeout: const Duration(minutes: 5),
//       );

//       print('[REGISTER] Calling uploadFile API...');
      
//       // ✅ Add progress tracking for upload
//       final response = await _apiClient.uploadFile(
//         ApiEndpoints.userRegister,
//         formData: formData,
//         options: uploadOptions,
//         onSendProgress: (int sent, int total) {
//           final percent = (sent / total * 100).toStringAsFixed(2);
//           print('[UPLOAD] Progress: $percent% ($sent / $total bytes)');
//         },
//       );

//       print('[REGISTER] Response received: ${response.statusCode}');
//       print('[REGISTER] Response data: ${response.data}');

//       final status = response.statusCode ?? 500;

//       if (status >= 200 && status < 300) {
//         // Registration successful
//         print('[REGISTER] ✅ Registration successful!');
//         state = state.copyWith(
//           status: AuthStatus.registered,
//           profilePicture: profilePicture,
//         );
//       } else {
//         print('[REGISTER] ❌ Server error: ${response.data}');
        
//         // Handle both JSON and HTML error responses
//         String errorMsg = 'Registration failed';
//         if (response.data is Map) {
//           errorMsg = response.data['message'] ?? errorMsg;
//         }
        
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: errorMsg,
//         );
//       }
//     } on DioException catch (e) {
//       print('[ERROR] DioException: ${e.type}');
//       print('[ERROR] Message: ${e.message}');
//       print('[ERROR] Response: ${e.response?.data}');
//       print('[ERROR] Status Code: ${e.response?.statusCode}');
      
//       String errorMsg = 'Unknown error';
      
//       // Try to extract error message from response
//       if (e.response?.data is Map) {
//         errorMsg = e.response?.data['message'] ?? e.message ?? errorMsg;
//       } else if (e.response?.statusCode == 404) {
//         errorMsg = 'Register endpoint not found - check backend';
//       } else {
//         errorMsg = e.message ?? errorMsg;
//       }
      
//       if (e.type == DioExceptionType.connectionTimeout || 
//           e.type == DioExceptionType.sendTimeout ||
//           e.type == DioExceptionType.receiveTimeout) {
//         errorMsg = 'Upload timeout - file might be too large or network is slow';
//       }
      
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: errorMsg,
//       );
//     } catch (e) {
//       print('[ERROR] Unexpected error: $e');
//       print('[ERROR] Stack trace: ${StackTrace.current}');
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   /// =========================
//   /// LOGIN
//   /// =========================
//   Future<void> login({
//     required String email,
//     required String password,
//   }) async {
//     print('[LOGIN] Starting login with email: $email');
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final response = await _apiClient.post(
//         "/auth/login",
//         data: {
//           "email": email,
//           "password": password,
//         },
//       );

//       print('[LOGIN] Response status: ${response.statusCode}');
//       print('[LOGIN] Response data: ${response.data}');

//       if (response.statusCode == 200) {
//         final userData = response.data['data'] ?? response.data;
        
//         print('[LOGIN] User data: $userData');
        
//         // Convert Map to AuthEntity
//         final authEntity = AuthEntity(
//           authId: userData['id']?.toString() ?? userData['_id']?.toString() ?? '',
//           token: userData['token'] ?? '',
//           fullName: userData['fullName'] ?? '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
//           email: userData['email'] ?? email,
//           phoneNumber: userData['phoneNumber'],
//           username: userData['username'],
//           profilePicture: userData['profileImage'] ?? userData['profilePicture'],
//           address: userData['address'],
//         );
        
//         print('[LOGIN] ✅ Login successful!');
//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//           profilePicture: authEntity.profilePicture,
//         );
//       } else {
//         print('[LOGIN] ❌ Login failed: ${response.data}');
        
//         String errorMsg = 'Login failed';
//         if (response.data is Map) {
//           errorMsg = response.data['message'] ?? errorMsg;
//         }
        
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: errorMsg,
//         );
//       }
//     } on DioException catch (e) {
//       print('[ERROR] DioException: ${e.type}');
//       print('[ERROR] Message: ${e.message}');
//       print('[ERROR] Response: ${e.response?.data}');
      
//       String errorMsg = 'Login failed';
//       if (e.response?.data is Map) {
//         errorMsg = e.response?.data['message'] ?? e.message ?? errorMsg;
//       } else {
//         errorMsg = e.message ?? errorMsg;
//       }
      
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: errorMsg,
//       );
//     } catch (e) {
//       print('[ERROR] Unexpected error: $e');
//       print('[ERROR] Stack trace: ${StackTrace.current}');
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   /// =========================
//   /// UPDATE PROFILE PICTURE PATH (LOCAL STATE)
//   /// =========================
//   void setProfilePicture(String path) {
//     state = state.copyWith(profilePicture: path);
//   }
// }


// import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as p;
// import 'package:tutorix/core/api/api_client.dart';
// import 'package:tutorix/core/api/api_endpoints.dart';
// import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

// final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
//   return AuthViewModel();
// });

// class AuthViewModel extends Notifier<AuthState> {
//   late final ApiClient _apiClient;

//   @override
//   AuthState build() {
//     _apiClient = ref.read(apiClientProvider);
//     return const AuthState();
//   }

//   /// =========================
//   /// REGISTER
//   /// =========================
//   Future<void> register({
//     required String fullName,
//     required String username,
//     required String email,
//     String? phoneNumber,
//     required String password,
//     required String confirmPassword,
//     String? profilePicture, // LOCAL PATH ONLY
//     String? address,
//   }) async {
//     print('[REGISTER] Starting registration...');
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       print('[REGISTER] Profile picture path: $profilePicture');

//       final formData = FormData.fromMap({
//         'fullName': fullName,
//         'username': username,
//         'email': email,
//         'password': password,
//         'confirmPassword': confirmPassword,
//         if (phoneNumber != null) 'phoneNumber': phoneNumber,
//         if (address != null) 'address': address,
//       });

//       // ✅ SAFE IMAGE HANDLING
//       if (profilePicture != null && profilePicture.isNotEmpty) {
//         final file = File(profilePicture);

//         if (await file.exists()) {
//           final size = await file.length();
//           print('[REGISTER] Image exists ✅ Size: ${size ~/ 1024} KB');

//           formData.files.add(
//             MapEntry(
//               'profileImage',
//               await MultipartFile.fromFile(
//                 file.path,
//                 filename: p.basename(file.path),
//               ),
//             ),
//           );
//         } else {
//           print('[REGISTER] ⚠️ Image path invalid, skipping upload');
//         }
//       } else {
//         print('[REGISTER] No profile image selected');
//       }

//       print('[REGISTER] FormData ready, starting API call...');

//       final options = Options(
//         contentType: 'multipart/form-data',
//         sendTimeout: const Duration(minutes: 5),
//         receiveTimeout: const Duration(minutes: 5),
//       );

//       final response = await _apiClient.uploadFile(
//         ApiEndpoints.userRegister,
//         formData: formData,
//         options: options,
//         onSendProgress: (sent, total) {
//           if (total > 0) {
//             final percent = (sent / total * 100).toStringAsFixed(2);
//             print('[UPLOAD] $percent%');
//           }
//         },
//       );

//       print('[REGISTER] Status: ${response.statusCode}');
//       print('[REGISTER] Data: ${response.data}');

//       if (response.statusCode != null &&
//           response.statusCode! >= 200 &&
//           response.statusCode! < 300) {
//         print('[REGISTER] ✅ Registration successful');

//         state = state.copyWith(
//           status: AuthStatus.registered,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage:
//               response.data is Map ? response.data['message'] : 'Registration failed',
//         );
//       }
//     } on DioException catch (e) {
//       print('[ERROR] DioException: ${e.message}');
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.response?.data is Map
//             ? e.response?.data['message']
//             : e.message ?? 'Network error',
//       );
//     } catch (e) {
//       print('[ERROR] Unexpected: $e');
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   /// =========================
//   /// LOGIN
//   /// =========================
//   Future<void> login({
//     required String email,
//     required String password,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final response = await _apiClient.post(
//         "/auth/login",
//         data: {
//           "email": email,
//           "password": password,
//         },
//       );

//       if (response.statusCode == 200) {
//         final userData = response.data['data'] ?? response.data;

//         final authEntity = AuthEntity(
//           authId: userData['id']?.toString() ?? userData['_id']?.toString() ?? '',
//           token: userData['token'] ?? '',
//           fullName: userData['fullName'] ?? '',
//           email: userData['email'] ?? email,
//           phoneNumber: userData['phoneNumber'],
//           username: userData['username'],
//           profilePicture: userData['profileImage'],
//           address: userData['address'],
//         );

//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//           profilePicture: authEntity.profilePicture,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Login failed',
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   /// =========================
//   /// LOCAL STATE ONLY
//   /// =========================
//   void setProfilePicture(String path) {
//     state = state.copyWith(profilePicture: path);
//   }
// }




// import 'dart:io';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as p;

// import 'package:tutorix/core/api/api_client.dart';
// import 'package:tutorix/core/api/api_endpoints.dart';
// import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

// final authViewModelProvider =
//     NotifierProvider<AuthViewModel, AuthState>(() {
//   return AuthViewModel();
// });

// class AuthViewModel extends Notifier<AuthState> {
//   late final ApiClient _apiClient;

//   @override
//   AuthState build() {
//     _apiClient = ref.read(apiClientProvider);
//     return const AuthState();
//   }

//   // =========================
//   // REGISTER
//   // =========================
//   Future<void> register({
//     required String fullName,
//     required String username,
//     required String email,
//     String? phoneNumber,
//     required String password,
//     required String confirmPassword,
//     String? profilePicture, // LOCAL PATH
//     String? address,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final formData = FormData.fromMap({
//         'fullName': fullName,
//         'username': username,
//         'email': email,
//         'password': password,
//         'confirmPassword': confirmPassword,
//         if (phoneNumber != null) 'phoneNumber': phoneNumber,
//         if (address != null) 'address': address,
//       });

//       // ✅ Upload local image ONLY if exists
//       if (profilePicture != null && profilePicture.isNotEmpty) {
//         final file = File(profilePicture);
//         if (await file.exists()) {
//           formData.files.add(
//             MapEntry(
//               'profileImage',
//               await MultipartFile.fromFile(
//                 file.path,
//                 filename: p.basename(file.path),
//               ),
//             ),
//           );
//         }
//       }

//       final response = await _apiClient.uploadFile(
//         ApiEndpoints.userRegister,
//         formData: formData,
//         options: Options(contentType: 'multipart/form-data'),
//       );

//       if (response.statusCode != null &&
//           response.statusCode! >= 200 &&
//           response.statusCode! < 300) {
//         final user = response.data['data'];

//         // ✅ IMPORTANT: store SERVER IMAGE URL
//         final authEntity = AuthEntity(
//           authId: user['_id'],
//           token: '',
//           fullName: user['fullName'],
//           email: user['email'],
//           username: user['username'],
//           phoneNumber: user['phoneNumber'],
//           address: user['address'],
//           profilePicture: user['profileImage'], // URL
//         );

//         state = state.copyWith(
//           status: AuthStatus.registered,
//           authEntity: authEntity,
//           profilePicture: authEntity.profilePicture,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Registration failed',
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   // =========================
//   // LOGIN
//   // =========================
//   Future<void> login({
//     required String email,
//     required String password,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final response = await _apiClient.post(
//         "/auth/login",
//         data: {"email": email, "password": password},
//       );

//       if (response.statusCode == 200) {
//         final user = response.data['data'];

//         final authEntity = AuthEntity(
//           authId: user['_id'],
//           token: response.data['token'] ?? '',
//           fullName: user['fullName'],
//           email: user['email'],
//           username: user['username'],
//           phoneNumber: user['phoneNumber'],
//           address: user['address'],
//           profilePicture: user['profileImage'], // SERVER URL
//         );

//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//           profilePicture: authEntity.profilePicture,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Login failed',
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   // =========================
//   // LOCAL IMAGE PICK (TEMP)
//   // =========================
//   void setProfilePicture(String localPath) {
//     state = state.copyWith(profilePicture: localPath);
//   }
// }




// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as p;

// import 'package:tutorix/core/api/api_client.dart';
// import 'package:tutorix/core/api/api_endpoints.dart';
// import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

// final authViewModelProvider =
//     NotifierProvider<AuthViewModel, AuthState>(() {
//   return AuthViewModel();
// });

// class AuthViewModel extends Notifier<AuthState> {
//   late final ApiClient _apiClient;

//   @override
//   AuthState build() {
//     _apiClient = ref.read(apiClientProvider);
//     return const AuthState();
//   }

//   // =========================
//   // REGISTER
//   // =========================
//   Future<void> register({
//     required String fullName,
//     required String username,
//     required String email,
//     String? phoneNumber,
//     required String password,
//     required String confirmPassword,
//     String? profilePicture, // LOCAL PATH
//     String? address,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final formData = FormData.fromMap({
//         'fullName': fullName,
//         'username': username,
//         'email': email,
//         'password': password,
//         'confirmPassword': confirmPassword,
//         if (phoneNumber != null) 'phoneNumber': phoneNumber,
//         if (address != null) 'address': address,
//       });

//       // ✅ Upload local image ONLY if exists
//       if (profilePicture != null && profilePicture.isNotEmpty) {
//         final file = File(profilePicture);
//         if (await file.exists()) {
//           formData.files.add(
//             MapEntry(
//               'profileImage',
//               await MultipartFile.fromFile(
//                 file.path,
//                 filename: p.basename(file.path),
//               ),
//             ),
//           );
//         }
//       }

//       final response = await _apiClient.uploadFile(
//         ApiEndpoints.userRegister,
//         formData: formData,
//         options: Options(contentType: 'multipart/form-data'),
//       );

//       if (response.statusCode != null &&
//           response.statusCode! >= 200 &&
//           response.statusCode! < 300) {
//         final user = response.data['data'];

//         // SERVER returns profile image path like "/uploads/123abc.jpg"
//         final profileUrl = user['profileImage'] != null
//             ? '${ApiEndpoints.mediaServerUrl}${user['profileImage']}'
//             : null;

//         final authEntity = AuthEntity(
//           authId: user['_id'],
//           token: '', // No token on register
//           fullName: user['fullName'],
//           email: user['email'],
//           username: user['username'],
//           phoneNumber: user['phoneNumber'],
//           address: user['address'],
//           profilePicture: profileUrl,
//         );

//         state = state.copyWith(
//           status: AuthStatus.registered,
//           authEntity: authEntity,
//           profilePicture: profileUrl,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Registration failed',
//         );
//       }
//     } on DioException catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.response?.data is Map
//             ? e.response?.data['message']
//             : e.message ?? 'Network error',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   // =========================
//   // LOGIN
//   // =========================
//   Future<void> login({
//     required String email,
//     required String password,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final response = await _apiClient.post(
//         ApiEndpoints.userLogin,
//         data: {"email": email, "password": password},
//       );

//       if (response.statusCode == 200) {
//         final user = response.data['data'];
//         final token = response.data['token'] ?? '';

//         final profileUrl = user['profileImage'] != null
//             ? '${ApiEndpoints.mediaServerUrl}${user['profileImage']}'
//             : null;

//         final authEntity = AuthEntity(
//           authId: user['_id'],
//           token: token,
//           fullName: user['fullName'],
//           email: user['email'],
//           username: user['username'],
//           phoneNumber: user['phoneNumber'],
//           address: user['address'],
//           profilePicture: profileUrl,
//         );

//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//           profilePicture: profileUrl,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Login failed',
//         );
//       }
//     } on DioException catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.response?.data is Map
//             ? e.response?.data['message']
//             : e.message ?? 'Network error',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   // =========================
//   // UPDATE PROFILE (EDIT)
//   // =========================
//   Future<void> updateProfile({
//     String? fullName,
//     String? phoneNumber,
//     String? address,
//     String? profilePicture, // local path
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final formData = FormData();

//       if (fullName != null) formData.fields.add(MapEntry('fullName', fullName));
//       if (phoneNumber != null) formData.fields.add(MapEntry('phoneNumber', phoneNumber));
//       if (address != null) formData.fields.add(MapEntry('address', address));

//       if (profilePicture != null && profilePicture.isNotEmpty) {
//         final file = File(profilePicture);
//         if (await file.exists()) {
//           formData.files.add(
//             MapEntry(
//               'profileImage',
//               await MultipartFile.fromFile(file.path, filename: p.basename(file.path)),
//             ),
//           );
//         }
//       }

//       final response = await _apiClient.uploadFile(
//         ApiEndpoints.users, // PUT /users
//         formData: formData,
//         options: Options(contentType: 'multipart/form-data'),
//       );

//       if (response.statusCode != null &&
//           response.statusCode! >= 200 &&
//           response.statusCode! < 300) {
//         final user = response.data['data'];
//         // final profileUrl = user['profileImage'] != null
//         //     ? '${ApiEndpoints.mediaServerUrl}${user['profileImage']}'
//         //     : null;

//             final profileUrl = user['profileImage']; // Use as-is


//         final authEntity = AuthEntity(
//           authId: user['_id'],
//           token: state.authEntity?.token ?? '',
//           fullName: user['fullName'],
//           email: user['email'],
//           username: user['username'],
//           phoneNumber: user['phoneNumber'],
//           address: user['address'],
//           profilePicture: profileUrl,
//         );

//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//           profilePicture: profileUrl,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Update failed',
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   // =========================
//   // LOCAL IMAGE PICK (TEMP)
//   // =========================
//   void setProfilePicture(String localPath) {
//     state = state.copyWith(profilePicture: localPath);
//   }

//   // =========================
//   // LOGOUT
//   // =========================
//   void logout() {
//     state = const AuthState();
//   }
// }


// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
// import 'package:path/path.dart' as p;

// import 'package:tutorix/core/api/api_client.dart';
// import 'package:tutorix/core/api/api_endpoints.dart';
// import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

// final authViewModelProvider =
//     NotifierProvider<AuthViewModel, AuthState>(() {
//   return AuthViewModel();
// });

// class AuthViewModel extends Notifier<AuthState> {
//   late final ApiClient _apiClient;

//   @override
//   AuthState build() {
//     _apiClient = ref.read(apiClientProvider);
//     return const AuthState();
//   }

//   // =========================
//   // REGISTER
//   // =========================
//   Future<void> register({
//     required String fullName,
//     required String username,
//     required String email,
//     String? phoneNumber,
//     required String password,
//     required String confirmPassword,
//     String? profilePicture, // LOCAL PATH
//     String? address,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final formData = FormData.fromMap({
//         'fullName': fullName,
//         'username': username,
//         'email': email,
//         'password': password,
//         'confirmPassword': confirmPassword,
//         if (phoneNumber != null) 'phoneNumber': phoneNumber,
//         if (address != null) 'address': address,
//       });

//       // ✅ Upload profile picture only if provided
//       if (profilePicture != null && profilePicture.isNotEmpty) {
//         final file = File(profilePicture);
//         if (await file.exists()) {
//           formData.files.add(
//             MapEntry(
//               'profileImage',
//               await MultipartFile.fromFile(
//                 file.path,
//                 filename: p.basename(file.path),
//               ),
//             ),
//           );
//         }
//       }

//       final response = await _apiClient.uploadFile(
//         ApiEndpoints.userRegister,
//         formData: formData,
//         options: Options(contentType: 'multipart/form-data'),
//       );

//       if (response.statusCode != null &&
//           response.statusCode! >= 200 &&
//           response.statusCode! < 300) {
//         final user = response.data['data'];

//         final profileUrl = user['profileImage'] != null
//             ? '${ApiEndpoints.mediaServerUrl}${user['profileImage']}'
//             : null;

//         final authEntity = AuthEntity(
//           authId: user['_id'],
//           token: '', // No token on register
//           fullName: user['fullName'],
//           email: user['email'],
//           username: user['username'],
//           phoneNumber: user['phoneNumber'],
//           address: user['address'],
//           profilePicture: profileUrl,
//         );

//         state = state.copyWith(
//           status: AuthStatus.registered,
//           authEntity: authEntity,
//           profilePicture: profileUrl,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Registration failed',
//         );
//       }
//     } on DioException catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.response?.data is Map
//             ? e.response?.data['message']
//             : e.message ?? 'Network error',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   // =========================
//   // LOGIN
//   // =========================
//   Future<void> login({
//     required String email,
//     required String password,
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final response = await _apiClient.post(
//         ApiEndpoints.userLogin,
//         data: {"email": email, "password": password},
//       );

//       if (response.statusCode == 200) {
//         final user = response.data['data'];
//         final token = response.data['token'] ?? '';

//         final profileUrl = user['profileImage'] != null
//             ? '${ApiEndpoints.mediaServerUrl}${user['profileImage']}'
//             : null;

//         final authEntity = AuthEntity(
//           authId: user['_id'],
//           token: token,
//           fullName: user['fullName'],
//           email: user['email'],
//           username: user['username'],
//           phoneNumber: user['phoneNumber'],
//           address: user['address'],
//           profilePicture: profileUrl,
//         );

//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//           profilePicture: profileUrl,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Login failed',
//         );
//       }
//     } on DioException catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.response?.data is Map
//             ? e.response?.data['message']
//             : e.message ?? 'Network error',
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   // =========================
//   // UPDATE PROFILE (EDIT)
//   // =========================
//   Future<void> updateProfile({
//     String? fullName,
//     String? phoneNumber,
//     String? address,
//     String? profilePicture, // local path
//   }) async {
//     state = state.copyWith(status: AuthStatus.loading);

//     try {
//       final formData = FormData();

//       if (fullName != null) formData.fields.add(MapEntry('fullName', fullName));
//       if (phoneNumber != null) formData.fields.add(MapEntry('phoneNumber', phoneNumber));
//       if (address != null) formData.fields.add(MapEntry('address', address));

//       if (profilePicture != null && profilePicture.isNotEmpty) {
//         final file = File(profilePicture);
//         if (await file.exists()) {
//           formData.files.add(
//             MapEntry(
//               'profileImage',
//               await MultipartFile.fromFile(file.path, filename: p.basename(file.path)),
//             ),
//           );
//         }
//       }

//       final response = await _apiClient.uploadFile(
//         ApiEndpoints.users,
//         formData: formData,
//         options: Options(contentType: 'multipart/form-data'),
//       );

//       if (response.statusCode != null &&
//           response.statusCode! >= 200 &&
//           response.statusCode! < 300) {
//         final user = response.data['data'];

//         final profileUrl = user['profileImage'] != null
//             ? '${ApiEndpoints.mediaServerUrl}${user['profileImage']}'
//             : null;

//         final authEntity = AuthEntity(
//           authId: user['_id'],
//           token: state.authEntity?.token ?? '',
//           fullName: user['fullName'],
//           email: user['email'],
//           username: user['username'],
//           phoneNumber: user['phoneNumber'],
//           address: user['address'],
//           profilePicture: profileUrl,
//         );

//         state = state.copyWith(
//           status: AuthStatus.authenticated,
//           authEntity: authEntity,
//           profilePicture: profileUrl,
//         );
//       } else {
//         state = state.copyWith(
//           status: AuthStatus.error,
//           errorMessage: 'Update failed',
//         );
//       }
//     } catch (e) {
//       state = state.copyWith(
//         status: AuthStatus.error,
//         errorMessage: e.toString(),
//       );
//     }
//   }

//   // =========================
//   // LOCAL IMAGE PICK (TEMP)
//   // =========================
//   void setProfilePicture(String localPath) {
//     state = state.copyWith(profilePicture: localPath);
//   }

//   // =========================
//   // LOGOUT
//   // =========================
//   void logout() {
//     // Clear all auth state
//     state = const AuthState();
//   }
// }





import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;

import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});

class AuthViewModel extends Notifier<AuthState> {
  late final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  @override
  AuthState build() {
    _apiClient = ref.read(apiClientProvider);
    return const AuthState();
  }

  // =========================
  // HELPER: Convert localhost to 10.0.2.2 for Android emulator
  // =========================
  String _fixLocalhostUrl(String? url) {
    if (url == null || url.isEmpty) return url ?? '';
    // Replace localhost with 10.0.2.2 for Android emulator
    return url.replaceAll('http://localhost:', 'http://10.0.2.2:');
  }

  String _sanitizeToken(String? rawToken) {
    if (rawToken == null) return '';
    var token = rawToken.trim();
    if (token.toLowerCase().startsWith('bearer ')) {
      token = token.substring(7).trim();
    }
    if ((token.startsWith('"') && token.endsWith('"')) ||
        (token.startsWith("'") && token.endsWith("'"))) {
      token = token.substring(1, token.length - 1).trim();
    }
    return token;
  }

  // =========================
  // REGISTER
  // =========================
  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    String? phoneNumber,
    required String password,
    required String confirmPassword,
    String? profilePicture, // LOCAL PATH
    String? address,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final formData = FormData.fromMap({
        'fullName': fullName,
        'username': username,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (address != null) 'address': address,
      });

      // Upload image only if provided
      if (profilePicture != null && profilePicture.isNotEmpty) {
        final file = File(profilePicture);
        if (await file.exists()) {
          formData.files.add(
            MapEntry(
              'profileImage',
              await MultipartFile.fromFile(
                file.path,
                filename: p.basename(file.path),
              ),
            ),
          );
        }
      }

      final response = await _apiClient.uploadFile(
        ApiEndpoints.userRegister,
        formData: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final user = response.data['data'];

        // Handle relative vs absolute URL
        final profileUrl = user['profileImage'] != null
            ? (user['profileImage'].startsWith('http')
                ? _fixLocalhostUrl(user['profileImage'])
                : '${ApiEndpoints.mediaServerUrl}${user['profileImage']}')
            : null;

        final authEntity = AuthEntity(
          authId: user['_id'],
          token: '', // No token on register
          fullName: user['fullName'],
          email: user['email'],
          username: user['username'],
          phoneNumber: user['phoneNumber'],
          address: user['address'],
          profilePicture: profileUrl,
        );

        state = state.copyWith(
          status: AuthStatus.registered,
          authEntity: authEntity,
          profilePicture: profileUrl,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Registration failed',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.response?.data is Map
            ? e.response?.data['message']
            : e.message ?? 'Network error',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _apiClient.post(
        ApiEndpoints.userLogin,
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final user = response.data['data'];
        final token = _sanitizeToken(response.data['token']?.toString());

        if (token.isNotEmpty) {
          await _secureStorage.write(key: _tokenKey, value: token);
        } else {
          await _secureStorage.delete(key: _tokenKey);
        }

        final profileUrl = user['profileImage'] != null
            ? (user['profileImage'].startsWith('http')
                ? _fixLocalhostUrl(user['profileImage'])
                : '${ApiEndpoints.mediaServerUrl}${user['profileImage']}')
            : null;

        print('[LOGIN] ✅ Logged in successfully. Profile image: $profileUrl');

        final authEntity = AuthEntity(
          authId: user['_id'],
          token: token,
          fullName: user['fullName'],
          email: user['email'],
          username: user['username'],
          phoneNumber: user['phoneNumber'],
          address: user['address'],
          profilePicture: profileUrl,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
          profilePicture: profileUrl,
        );
        
        print('[LOGIN] ✅ Logged in successfully. Profile image: $profileUrl');
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Login failed',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.response?.data is Map
            ? e.response?.data['message']
            : e.message ?? 'Network error',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // =========================
  // LOGOUT
  // =========================
  void logout() {
    _secureStorage.delete(key: _tokenKey);
    state = const AuthState();
  }

  // =========================
  // LOCAL IMAGE PICK
  // =========================
  void setProfilePicture(String localPath) {
    state = state.copyWith(profilePicture: localPath);
  }

  Future<void> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? address,
    String? profilePicture, // local path
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final formData = FormData();

      // Add text fields
      formData.fields.add(MapEntry('fullName', fullName));
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        formData.fields.add(MapEntry('phoneNumber', phoneNumber));
      }
      if (address != null && address.isNotEmpty) {
        formData.fields.add(MapEntry('address', address));
      }

      // Upload image if provided and is a local file (not a server URL)
      if (profilePicture != null && 
          profilePicture.isNotEmpty && 
          !profilePicture.startsWith('http')) {
        final file = File(profilePicture);
        if (await file.exists()) {
          print('[UPDATE PROFILE] Uploading image: $profilePicture');
          formData.files.add(
            MapEntry(
              'profileImage',
              await MultipartFile.fromFile(
                file.path,
                filename: p.basename(file.path),
              ),
            ),
          );
        }
      }

      print('[UPDATE PROFILE] FormData ready, sending to server...');
      
      final response = await _apiClient.uploadFile(
        ApiEndpoints.users,
        formData: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      print('[UPDATE PROFILE] Response status: ${response.statusCode}');
      print('[UPDATE PROFILE] Response data: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final user = response.data['data'];

        // Handle response image URL
        final profileUrl = user['profileImage'] != null
            ? (user['profileImage'].startsWith('http')
                ? _fixLocalhostUrl(user['profileImage'])
                : '${ApiEndpoints.mediaServerUrl}${user['profileImage']}')
            : state.authEntity?.profilePicture;

        print('[UPDATE PROFILE] Profile image URL: $profileUrl');

        final authEntity = AuthEntity(
          authId: user['_id'] ?? state.authEntity?.authId ?? '',
          token: state.authEntity?.token ?? '',
          fullName: user['fullName'] ?? fullName,
          email: user['email'] ?? state.authEntity?.email ?? '',
          username: user['username'] ?? state.authEntity?.username,
          phoneNumber: user['phoneNumber'] ?? phoneNumber,
          address: user['address'] ?? address,
          profilePicture: profileUrl,
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
          profilePicture: profileUrl,
        );
        
        print('[UPDATE PROFILE] ✅ Profile updated successfully');
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: response.data is Map 
              ? response.data['message'] ?? 'Update failed'
              : 'Update failed',
        );
      }
    } on DioException catch (e) {
      print('[UPDATE PROFILE] DioException: ${e.message}');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.response?.data is Map
            ? e.response?.data['message']
            : e.message ?? 'Network error',
      );
    } catch (e) {
      print('[UPDATE PROFILE] Error: $e');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

}

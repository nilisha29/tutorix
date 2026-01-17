import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/auth/data/datasources/auth_datasource.dart';
import 'package:tutorix/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:tutorix/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:tutorix/features/auth/data/models/auth_api_model.dart';
import 'package:tutorix/features/auth/data/models/auth_hive_model.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/domain/repositories/auth_repository.dart';

/// Provider for RemoteAuthDatasource
final remoteAuthDatasourceProvider = Provider<IRemoteAuthDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return RemoteAuthDatasource(apiClient);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final remoteDataSource = ref.read(remoteAuthDatasourceProvider);
  final localDataSource = ref.read(authLocalDatasourceProvider);
  return AuthRepository(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// Implementation of AuthRepository
class AuthRepository implements IAuthRepository {
  final IRemoteAuthDatasource _remoteDataSource;
  final IAuthDatasource _localDataSource;

  AuthRepository({
    required IRemoteAuthDatasource remoteDataSource,
    required IAuthDatasource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  /// Get currently logged in user
  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: "No user logged in"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  /// Login user using API
  // @override
  // Future<Either<Failure, AuthEntity>> login(
  //     String email, String password) async {
  //   try {
  //     // Call remote API for login
  //     final apiResponse = await _remoteDataSource.login(email, password);
      
  //     print('[DEBUG] Login API Response: $apiResponse');
      
  //     // Check if login was successful - handle both response formats
  //     final hasData = apiResponse['data'] != null;
  //     final isSuccessful = apiResponse['success'] == true || hasData;
      
  //     print('[DEBUG] hasData: $hasData, isSuccessful: $isSuccessful');
      
  //     if (isSuccessful && hasData) {
  //       final userData = apiResponse['data'];
        
  //       // Save to local storage
  //       final hiveModel = AuthHiveModel(
  //         authId: userData['id'] ?? userData['_id'] ?? '',
  //         firstName: userData['firstName'] ?? '',
  //         email: userData['email'] ?? email,
  //         phoneNumber: userData['phoneNumber'],
  //         lastName: userData['lastName'] ?? '',
  //         profilePicture: userData['profilePicture'],
  //         password: password,
  //         token: userData['token'] ?? '',
  //       );
        
  //       await _localDataSource.login(email, password);
  //       print('[DEBUG] Login successful, saved to local storage');
  //       return Right(hiveModel.toEntity());
  //     }
      
  //     return Left(ApiFailure(message: apiResponse['message'] ?? 'Login failed'));
  //   } catch (e) {
  //     print('[DEBUG] Login error: $e');
  //     return Left(ApiFailure(message: e.toString()));
  //   }
  // }


@override
Future<Either<Failure, AuthEntity>> login(
    String email, String password) async {
  try {
    final apiResponse = await _remoteDataSource.login(email, password);

    print('[DEBUG] Login API Response: $apiResponse');

    // ✅ BACKEND DOES NOT WRAP RESPONSE IN `data`
    // So treat entire response as user object

    final localUser = await _localDataSource.login(email, password);
print('[DEBUG] Local Storage Result: $localUser');
    final userData = apiResponse;

    final hiveModel = AuthHiveModel(
      authId: userData['id']?.toString() ?? '',
      firstName: userData['firstName'] ?? '',
      lastName: userData['lastName'] ?? '',
      email: userData['email'] ?? email,
      phoneNumber: userData['phoneNumber'],
      profilePicture: userData['profilePicture'],
      token: userData['token'] ?? '',
      password: password,
    );

    await _localDataSource.login(email, password);

    return Right(hiveModel.toEntity());
  } catch (e) {
    return Left(ApiFailure(message: e.toString()));
  }
}



  /// Register a new user using API
  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      // Create API model from entity
      final apiModel = AuthApiModel(
        firstName: entity.firstName,
        username: entity.email.split('@').first,
        email: entity.email,
        phoneNumber: entity.phoneNumber ?? '',
        lastName: entity.lastName,
        password: entity.password ?? '',
        profilePicture: entity.profilePicture,
      );

      // Call remote API for registration
      final apiResponse = await _remoteDataSource.register(apiModel);
      
      // Check if registration was successful
      if (apiResponse['success'] == true || apiResponse['data'] != null) {
        // Save to local storage
        final model = AuthHiveModel.fromEntity(entity);
        await _localDataSource.register(model);
        return const Right(true);
      }
      
      return Left(ApiFailure(message: apiResponse['message'] ?? 'Registration failed'));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _remoteDataSource.logout();
      final result = await _localDataSource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Logout failed"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}


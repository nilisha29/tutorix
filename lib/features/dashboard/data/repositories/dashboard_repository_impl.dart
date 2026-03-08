import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:tutorix/features/dashboard/data/datasources/local/dashboard_local_datasource.dart';
import 'package:tutorix/features/dashboard/data/datasources/remote/dashboard_remote_datasource.dart';
import 'package:tutorix/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRepositoryImplProvider = Provider<IDashboardRepository>((ref) {
  final remoteDatasource = ref.read(dashboardRemoteDatasourceProvider);
  final localDatasource = ref.read(dashboardLocalDatasourceProvider);
  return DashboardRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});

class DashboardRepositoryImpl implements IDashboardRepository {
  DashboardRepositoryImpl({
    required IDashboardDatasource remoteDatasource,
    required IDashboardDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final IDashboardDatasource _remoteDatasource;
  final IDashboardDatasource _localDatasource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> bookTutor(Map<String, dynamic> bookingPayload) async {
    try {
      final result = await _remoteDatasource.bookTutor(bookingPayload);
      await _localDatasource.bookTutor(bookingPayload);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.bookTutor(bookingPayload);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCategories() async {
    try {
      final result = await _remoteDatasource.getCategories();
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getCategories();
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTutors() async {
    try {
      final result = await _remoteDatasource.getTutors();
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getTutors();
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserProfile() async {
    try {
      final result = await _remoteDatasource.getUserProfile();
      await _localDatasource.updateProfile(result);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getUserProfile();
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateProfile(Map<String, dynamic> profilePayload) async {
    try {
      final result = await _remoteDatasource.updateProfile(profilePayload);
      await _localDatasource.updateProfile(result);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.updateProfile(profilePayload);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }
}

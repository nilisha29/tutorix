import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/tutors/data/datasources/local/tutors_local_datasource.dart';
import 'package:tutorix/features/tutors/data/datasources/remote/tutors_remote_datasource.dart';
import 'package:tutorix/features/tutors/data/datasources/tutors_datasource.dart';
import 'package:tutorix/features/tutors/domain/repositories/tutors_repository.dart';

final tutorsRepositoryImplProvider = Provider<ITutorsRepository>((ref) {
  final remoteDatasource = ref.read(tutorsRemoteDatasourceProvider);
  final localDatasource = ref.read(tutorsLocalDatasourceProvider);
  return TutorsRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});

class TutorsRepositoryImpl implements ITutorsRepository {
  TutorsRepositoryImpl({
    required ITutorsDatasource remoteDatasource,
    required ITutorsDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final ITutorsDatasource _remoteDatasource;
  final ITutorsDatasource _localDatasource;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCategoryTutors(String category) async {
    try {
      final result = await _remoteDatasource.getCategoryTutors(category);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getCategoryTutors(category);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTutorAvailability(String tutorId) async {
    try {
      final result = await _remoteDatasource.getTutorAvailability(tutorId);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getTutorAvailability(tutorId);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTutorDetail(String tutorId) async {
    try {
      final result = await _remoteDatasource.getTutorDetail(tutorId);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getTutorDetail(tutorId);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }
}

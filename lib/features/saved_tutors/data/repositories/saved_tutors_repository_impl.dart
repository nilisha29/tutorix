import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/saved_tutors/data/datasources/local/saved_tutors_local_datasource.dart';
import 'package:tutorix/features/saved_tutors/data/datasources/remote/saved_tutors_remote_datasource.dart';
import 'package:tutorix/features/saved_tutors/data/datasources/saved_tutors_datasource.dart';
import 'package:tutorix/features/saved_tutors/domain/repositories/saved_tutors_repository.dart';

final savedTutorsRepositoryImplProvider = Provider<ISavedTutorsRepository>((ref) {
  final remoteDatasource = ref.read(savedTutorsRemoteDatasourceProvider);
  final localDatasource = ref.read(savedTutorsLocalDatasourceProvider);
  return SavedTutorsRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});

class SavedTutorsRepositoryImpl implements ISavedTutorsRepository {
  SavedTutorsRepositoryImpl({
    required ISavedTutorsDatasource remoteDatasource,
    required ISavedTutorsDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final ISavedTutorsDatasource _remoteDatasource;
  final ISavedTutorsDatasource _localDatasource;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getSavedTutors() async {
    try {
      final result = await _remoteDatasource.getSavedTutors();
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getSavedTutors();
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> removeSavedTutor(String tutorId) async {
    try {
      final result = await _remoteDatasource.removeSavedTutor(tutorId);
      await _localDatasource.removeSavedTutor(tutorId);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.removeSavedTutor(tutorId);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> saveTutor(Map<String, dynamic> tutor) async {
    try {
      final result = await _remoteDatasource.saveTutor(tutor);
      await _localDatasource.saveTutor(tutor);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.saveTutor(tutor);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/editprofile/data/datasources/edit_profile_datasource.dart';
import 'package:tutorix/features/editprofile/data/datasources/local/edit_profile_local_datasource.dart';
import 'package:tutorix/features/editprofile/data/datasources/remote/edit_profile_remote_datasource.dart';
import 'package:tutorix/features/editprofile/domain/repositories/edit_profile_repository.dart';

final editProfileRepositoryImplProvider = Provider<IEditProfileRepository>((ref) {
  final remoteDatasource = ref.read(editProfileRemoteDatasourceProvider);
  final localDatasource = ref.read(editProfileLocalDatasourceProvider);
  return EditProfileRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});

class EditProfileRepositoryImpl implements IEditProfileRepository {
  EditProfileRepositoryImpl({
    required IEditProfileDatasource remoteDatasource,
    required IEditProfileDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final IEditProfileDatasource _remoteDatasource;
  final IEditProfileDatasource _localDatasource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try {
      final result = await _remoteDatasource.getProfile();
      await _localDatasource.updateProfile(result);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getProfile();
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateProfile(Map<String, dynamic> payload) async {
    try {
      final result = await _remoteDatasource.updateProfile(payload);
      await _localDatasource.updateProfile(result);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.updateProfile(payload);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';

abstract interface class ISavedTutorsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getSavedTutors();

  Future<Either<Failure, bool>> saveTutor(Map<String, dynamic> tutor);

  Future<Either<Failure, bool>> removeSavedTutor(String tutorId);
}

final savedTutorsRepositoryProvider = Provider<ISavedTutorsRepository>((ref) {
  throw UnimplementedError(
    'savedTutorsRepositoryProvider must be overridden with a concrete implementation.',
  );
});

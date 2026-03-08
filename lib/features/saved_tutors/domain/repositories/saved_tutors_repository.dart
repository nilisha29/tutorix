import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/saved_tutors/data/repositories/saved_tutors_repository_impl.dart';

abstract interface class ISavedTutorsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getSavedTutors();

  Future<Either<Failure, bool>> saveTutor(Map<String, dynamic> tutor);

  Future<Either<Failure, bool>> removeSavedTutor(String tutorId);
}

final savedTutorsRepositoryProvider = Provider<ISavedTutorsRepository>((ref) {
  return ref.read(savedTutorsRepositoryImplProvider);
});

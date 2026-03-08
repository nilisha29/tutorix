import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/tutors/data/repositories/tutors_repository_impl.dart';

abstract interface class ITutorsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getCategoryTutors(
    String category,
  );

  Future<Either<Failure, Map<String, dynamic>>> getTutorDetail(String tutorId);

  Future<Either<Failure, List<Map<String, dynamic>>>> getTutorAvailability(
    String tutorId,
  );
}

final tutorsRepositoryProvider = Provider<ITutorsRepository>((ref) {
  return ref.read(tutorsRepositoryImplProvider);
});

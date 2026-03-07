import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';

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
  throw UnimplementedError(
    'tutorsRepositoryProvider must be overridden with a concrete implementation.',
  );
});

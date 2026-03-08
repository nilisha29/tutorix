import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/dashboard/data/repositories/dashboard_repository_impl.dart';

abstract interface class IDashboardRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getTutors();

  Future<Either<Failure, List<Map<String, dynamic>>>> getCategories();

  Future<Either<Failure, Map<String, dynamic>>> bookTutor(
    Map<String, dynamic> bookingPayload,
  );

  Future<Either<Failure, Map<String, dynamic>>> getUserProfile();

  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> profilePayload,
  );
}

final dashboardRepositoryProvider = Provider<IDashboardRepository>((ref) {
  return ref.read(dashboardRepositoryImplProvider);
});

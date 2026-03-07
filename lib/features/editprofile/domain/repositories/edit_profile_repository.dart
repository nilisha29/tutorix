import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';

abstract interface class IEditProfileRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProfile();

  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> payload,
  );
}

final editProfileRepositoryProvider = Provider<IEditProfileRepository>((ref) {
  throw UnimplementedError(
    'editProfileRepositoryProvider must be overridden with a concrete implementation.',
  );
});

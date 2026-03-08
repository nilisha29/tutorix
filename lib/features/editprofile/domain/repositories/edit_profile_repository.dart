import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/editprofile/data/repositories/edit_profile_repository_impl.dart';

abstract interface class IEditProfileRepository {
  Future<Either<Failure, Map<String, dynamic>>> getProfile();

  Future<Either<Failure, Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> payload,
  );
}

final editProfileRepositoryProvider = Provider<IEditProfileRepository>((ref) {
  return ref.read(editProfileRepositoryImplProvider);
});

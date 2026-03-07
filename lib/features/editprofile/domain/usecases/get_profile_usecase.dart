import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/editprofile/domain/repositories/edit_profile_repository.dart';

class GetProfileUseCase implements UsecaseWithoutParams<Map<String, dynamic>> {
  GetProfileUseCase({required IEditProfileRepository editProfileRepository})
      : _editProfileRepository = editProfileRepository;

  final IEditProfileRepository _editProfileRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() {
    return _editProfileRepository.getProfile();
  }
}

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(
    editProfileRepository: ref.read(editProfileRepositoryProvider),
  );
});

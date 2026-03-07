import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/editprofile/domain/repositories/edit_profile_repository.dart';

class UpdateProfileUseCaseParams extends Equatable {
  const UpdateProfileUseCaseParams({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.profilePicture,
  });

  final String fullName;
  final String phoneNumber;
  final String address;
  final String? profilePicture;

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'profilePicture': profilePicture,
    };
  }

  @override
  List<Object?> get props => [fullName, phoneNumber, address, profilePicture];
}

class UpdateProfileUseCase
    implements UsecaseWithParams<Map<String, dynamic>, UpdateProfileUseCaseParams> {
  UpdateProfileUseCase({required IEditProfileRepository editProfileRepository})
      : _editProfileRepository = editProfileRepository;

  final IEditProfileRepository _editProfileRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    UpdateProfileUseCaseParams params,
  ) {
    return _editProfileRepository.updateProfile(params.toJson());
  }
}

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(
    editProfileRepository: ref.read(editProfileRepositoryProvider),
  );
});
